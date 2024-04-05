local Teardown = require('@pkg/luau-teardown')
local jestGlobals = require('@pkg/@jsdotlua/jest-globals')

local createMenuHandler = require('../init')

local expect = jestGlobals.expect
local it = jestGlobals.it
local beforeAll = jestGlobals.beforeAll
local afterEach = jestGlobals.afterEach

local menuHandler

beforeAll(function()
    menuHandler = createMenuHandler()
    menuHandler.Init()
end)

local cleanup: Teardown.Teardown = nil

afterEach(function()
    Teardown.teardown(cleanup)
end)

local function createMenuInstanceTag(id: string, parent: Instance)
    local menuInstanceEffect = Instance.new('Configuration')
    menuInstanceEffect:AddTag('MenuInstance')
    menuInstanceEffect:SetAttribute('id', id)
    menuInstanceEffect.Parent = parent
    return menuInstanceEffect
end

it('opens a menu', function()
    local menuId = 'screen'

    local screenGui = Instance.new('ScreenGui')
    screenGui.Enabled = false
    createMenuInstanceTag(menuId, screenGui)
    screenGui.Parent = workspace

    cleanup = screenGui :: any

    menuHandler.open(menuId)

    expect(screenGui.Enabled).toEqual(true)
end)

it('closes a menu', function()
    local menuId = 'screen'

    local screenGui = Instance.new('ScreenGui')
    screenGui.Enabled = true
    local tagEffect = createMenuInstanceTag(menuId, screenGui)
    tagEffect:SetAttribute('defaultState', true)
    screenGui.Parent = workspace

    cleanup = screenGui :: any

    menuHandler.close(menuId)

    expect(screenGui.Enabled).toEqual(false)
end)

it('toggles a menu (opening case)', function()
    local menuId = 'screen'

    local screenGui = Instance.new('ScreenGui')
    screenGui.Enabled = false
    createMenuInstanceTag(menuId, screenGui)
    screenGui.Parent = workspace

    cleanup = screenGui :: any

    menuHandler.toggle(menuId)

    expect(screenGui.Enabled).toEqual(true)
end)

it('toggles a menu (closing case)', function()
    local menuId = 'screen'

    local screenGui = Instance.new('ScreenGui')
    screenGui.Enabled = true
    local tagEffect = createMenuInstanceTag(menuId, screenGui)
    tagEffect:SetAttribute('defaultState', true)
    screenGui.Parent = workspace

    cleanup = screenGui :: any

    menuHandler.toggle(menuId)

    expect(screenGui.Enabled).toEqual(false)
end)
