local Loader = {}

export type Handler = {
    Init: () -> (),
    Priority: number,
}

local handlers: { Handler } = {}

function Loader.Load(parent: Instance): {Handler}
    for _, module in parent:GetChildren() do
        if not module:IsA("ModuleScript") then continue end
        local handler = require(module) :: Handler
        
        if typeof(handler) ~= "table" or typeof(handler.Init) ~= "function" then
            warn("Invalid format for handler " .. module.Name)
            continue
        end
        
        handler.Priority = if typeof(handler.Priority) == "number" then handler.Priority else 1
        table.insert(handlers, handler)
    end
    
    table.sort(handlers, function(a, b)
        return a.Priority < b.Priority
    end)

    return handlers
end

return Loader