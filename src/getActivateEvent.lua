local function getActivateEvent(
    tagName: string,
    instance: Instance,
    eventName: string?
): RBXScriptSignal?
    if eventName and eventName ~= '' then
        local success, member = pcall(function()
            return (instance :: any)[eventName]
        end)

        if success and typeof(member) == 'RBXScriptSignal' then
            return member
        end

        if _G.DEV then
            if success then
                warn(
                    `invalid 'eventName' configuration on '{instance:GetFullName()}' for`
                        .. ` '{tagName}' tag, property '{eventName}' is not an event`
                        .. ` of an instance of class '{instance.ClassName}'`
                )
            else
                warn(
                    `invalid 'eventName' configuration on '{instance:GetFullName()}' for`
                        .. ` '{tagName}' tag, event '{eventName}' does not exist`
                        .. ` for an instance of class '{instance.ClassName}'`
                )
            end
        end

        return nil
    end

    return if instance:IsA('ClickDetector')
        then instance.MouseClick
        elseif instance:IsA('GuiButton') then instance.Activated
        elseif instance:IsA('ValueBase') then instance:GetPropertyChangedSignal('Value' :: any)
        elseif instance:IsA('ProximityPrompt') then instance.Triggered
        else nil
end

return getActivateEvent
