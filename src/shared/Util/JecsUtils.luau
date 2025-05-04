--!nocheck
local JecsUtils = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local world = require(ReplicatedStorage.Shared.WorldSingleton)

function JecsUtils.getEntityWithComponent(component: any, value): any
    for entity, entityValue in world:query(component) do
        if entityValue ~= value then
            continue
        end

        return entity
    end

    return nil
end

return JecsUtils