local Disk = require('@pkg/luau-disk')
local TagEffect = require('@pkg/@seaofvoices/tag-effect')
local Teardown = require('@pkg/luau-teardown')

local MenuObject = require('./MenuObject')
local getActivateEvent = require('./getActivateEvent')

local Array = Disk.Array

type Teardown = Teardown.Teardown
type MenuObject = MenuObject.MenuObject

return function()
    local module = {}

    type BaseMenuInfo = {
        object: MenuObject,
        id: string,
        state: boolean,
        setState: (any, boolean) -> (),
    }
    type MenuInfo = BaseMenuInfo & {
        compatibleWith: { [string]: true },
    }
    local menuInstances: { MenuInfo } = {}
    local menuExtensions: { BaseMenuInfo } = {}
    local menuEffects: { [string]: { () -> Teardown } } = {}
    local menuEffectCleanUp: { [string]: { [() -> Teardown]: Teardown } } = {}

    local function setMenuState(menu: BaseMenuInfo, value: boolean)
        if menu.state ~= value then
            menu.state = value
            menu.setState(menu.object, value)

            local menuId = menu.id
            local effectFns = menuEffects[menuId]

            if effectFns then
                if value == true and menuEffectCleanUp[menuId] == nil then
                    menuEffectCleanUp[menuId] = Array.reduce(effectFns, function(cleanUp, fn)
                        cleanUp[fn] = fn()
                        return cleanUp
                    end, {})
                elseif value == false and menuEffectCleanUp[menuId] ~= nil then
                    for _, teardownObject in menuEffectCleanUp[menuId] do
                        Teardown.teardown(teardownObject)
                    end
                    menuEffectCleanUp[menuId] = nil
                end
            end
        end
    end

    function module.Init()
        local uiTagConfig = TagEffect.configure():targetParent():ignoreDescendantOf(
            game:GetService('ServerStorage'),
            game:GetService('ReplicatedStorage'),
            game:GetService('StarterGui')
        )

        local menuObjectConfig = uiTagConfig
            :withDefaultConfig({}, {
                id = 'string',
                defaultState = 'boolean?',
            })
            :withValidClass('GuiObject', 'LayerCollector', 'ProximityPrompt')

        local function menuInstanceEffect(
            object: MenuObject,
            config: { id: string, defaultState: boolean? }
        )
            local menuInfo: MenuInfo = {
                id = config.id,
                object = object,
                state = config.defaultState == true,
                setState = MenuObject.getSetStateFn(object),
                compatibleWith = {},
            }

            for prop, value in config :: any do
                if prop ~= 'id' and prop ~= 'defaultState' and type(value) == 'string' then
                    menuInfo.compatibleWith[value] = true
                end
            end
            menuInfo.setState(object, menuInfo.state)
            table.insert(menuInstances, menuInfo)

            return function()
                local index = table.find(menuInstances, menuInfo)
                if index then
                    table.remove(menuInstances, index)
                end
            end
        end
        menuObjectConfig:effect('MenuInstance', menuInstanceEffect :: any)

        local function menuExtensionEffect(
            object: MenuObject,
            config: { id: string, defaultState: boolean? }
        )
            local menuInfo: BaseMenuInfo = {
                id = config.id,
                object = object,
                state = config.defaultState == true,
                setState = MenuObject.getSetStateFn(object),
            }

            menuInfo.setState(object, menuInfo.state)
            table.insert(menuExtensions, menuInfo)

            return function()
                local index = table.find(menuExtensions, menuInfo)
                if index then
                    table.remove(menuInstances, index)
                end
            end
        end
        menuObjectConfig:effect('MenuExtension', menuExtensionEffect :: any)

        local tagButtonConfig = uiTagConfig:withDefaultConfig({}, {
            id = 'string',
            eventName = 'string?',
        })

        local function createMenuButtonEffect(tagName: string, fn: (id: string) -> ())
            local function menuButtonEffect(
                object: Instance,
                config: {
                    id: string,
                    eventName: string?,
                }
            )
                local event = getActivateEvent(tagName, object, config.eventName)

                if event == nil then
                    warn(
                        `no default event defined for instances of class '{object.ClassName}'.`
                            .. ` Provide a 'eventName' string property to '{object:GetFullName()}' for`
                            .. ` '{tagName}' tag, or use a different instance type`
                    )
                    return nil
                else
                    return event:Connect(function()
                        fn(config.id)
                    end) :: any
                end
            end
            tagButtonConfig:effect(tagName, menuButtonEffect :: any)
        end

        createMenuButtonEffect('OpenMenu', module.open)
        createMenuButtonEffect('CloseMenu', module.close)
        createMenuButtonEffect('ToggleMenu', module.toggle)
    end

    function module.open(menuId: string)
        for _, menu in menuExtensions do
            if menu.id == menuId then
                setMenuState(menu, true)
            end
        end
        local menuMatch, others = Array.partition(menuInstances, function(menu)
            return menu.id == menuId
        end)

        for _, menu in menuMatch do
            if not menu.state then
                for _, otherMenu in others do
                    if otherMenu.state and not menu.compatibleWith[otherMenu.id] then
                        setMenuState(otherMenu, false)
                    end
                end

                setMenuState(menu, true)
            end
        end
    end

    function module.close(menuId: string)
        for _, menu in menuExtensions do
            if menu.id == menuId then
                setMenuState(menu, false)
            end
        end
        for _, menu in menuInstances do
            if menu.id == menuId then
                setMenuState(menu, false)
            end
        end
    end

    function module.toggle(menuId: string)
        for _, menu in menuExtensions do
            if menu.id == menuId then
                setMenuState(menu, not menu.state)
            end
        end
        local menuMatch, others = Array.partition(menuInstances, function(menu)
            return menu.id == menuId
        end)

        for _, menu in menuMatch do
            if menu.state then
                setMenuState(menu, false)
            else
                for _, otherMenu in others do
                    if otherMenu.state and not menu.compatibleWith[otherMenu.id] then
                        setMenuState(otherMenu, false)
                    end
                end

                setMenuState(menu, true)
            end
        end
    end

    function module.whileOpened(menuId: string, effect: () -> Teardown): () -> ()
        local menuSpecificEffects = menuEffects[menuId]
        if menuSpecificEffects == nil then
            menuSpecificEffects = { effect }
            menuEffects[menuId] = menuSpecificEffects
        else
            table.insert(menuSpecificEffects, effect)
        end

        local isOpened = Array.any(menuInstances, function(menu)
            return menu.id == menuId and menu.state
        end)

        if isOpened then
            local cleanUp = effect()
            if menuEffectCleanUp[menuId] == nil then
                menuEffectCleanUp[menuId] = { [effect] = cleanUp }
            else
                menuEffectCleanUp[menuId][effect] = cleanUp
            end
        end

        local function removeEffect()
            local index = table.find(menuSpecificEffects, effect)
            if index ~= nil then
                table.remove(menuSpecificEffects, index)
            end

            if menuEffectCleanUp[menuId] then
                local teardownObject = menuEffectCleanUp[menuId][effect]
                if teardownObject then
                    menuEffectCleanUp[menuId][effect] = nil
                    Teardown.teardown(teardownObject)
                end
            end
        end

        return removeEffect
    end

    return module
end
