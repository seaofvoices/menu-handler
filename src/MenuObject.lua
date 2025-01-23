export type MenuObject = GuiObject | LayerCollector | ProximityPrompt | BoolValue

local function noop() end

local function setGuiObject(object: GuiObject, state: boolean)
    object.Visible = state
end

local function setScreenGui(object: LayerCollector, state: boolean)
    object.Enabled = state
end

local function setProximityPrompt(object: ProximityPrompt, state: boolean)
    object.Enabled = state
end

local function setBoolValue(object: BoolValue, state: boolean)
    object.Value = state
end

local cache: { [string]: any } = {}

local function getSetStateFn(object: MenuObject): (any, boolean) -> ()
    local className = object.ClassName
    local result = cache[className]

    if result then
        return result
    end

    if object:IsA('GuiObject') then
        result = setGuiObject
    elseif object:IsA('LayerCollector') then
        result = setScreenGui
    elseif object:IsA('ProximityPrompt') then
        result = setProximityPrompt
    elseif object:IsA('BoolValue') then
        result = setBoolValue
    else
        warn(`unsupported menu extension of class '{className}'`)
        result = noop
    end

    cache[className] = result
    return result
end

return {
    getSetStateFn = getSetStateFn,
}
