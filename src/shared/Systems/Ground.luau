--!nocheck
local Ground = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.Components)
local physics = require(ReplicatedStorage.Shared.Systems.Physics)
local world = require(ReplicatedStorage.Shared.WorldSingleton)

local worldData = require(ReplicatedStorage.Shared.Data.WorldData)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = {workspace.Map}

local wheelQuery = world:query(
    components.Position,
    components.WheelColliders, 
    components.Mass, 
    components.Velocity
):cached()

function Ground.Update(dt: number)
    for entity, position, wheels, mass, velocity in wheelQuery do
        local largestRadius = wheels[1].Radius
        local rayLength = largestRadius + 2

        local result = workspace:Raycast(position, Vector3.new(0, -rayLength, 0), raycastParams)
        
        if result then
            local normalForce = mass * -worldData.Gravity
            physics.ApplyImpulse(entity, normalForce, Vector3.zero)
            world:set(entity, components.IsGrounded, true)

            if velocity.Y < 0 then
                local impulseMagnitude = -mass * (1 + worldData.CoefficientOfRestituion) * velocity.Y
                local collisionForce = Vector3.new(0, impulseMagnitude / dt, 0) -- F = integral J.dt

                physics.ApplyImpulse(entity, collisionForce, Vector3.zero)
            end

            local groundHeight = result.Position.Y + largestRadius

            local penetration = position.Y - groundHeight
            if penetration < 0 then
                local correction = Vector3.new(0, -penetration, 0)
                world:set(entity, components.Position, position + correction)
            end

            for _, wheel in wheels do
                local wheelWorldPos = position + wheel.Offset
                local compression = wheel.Radius - (wheelWorldPos.Y - result.Position.Y)

                if compression > 0 then
                    local suspensionForce = Vector3.new(0, compression * wheel.Stiffness, 0)
                    physics.ApplyImpulse(entity, suspensionForce, Vector3.zero)
                end
            end
        else
            world:set(entity, components.IsGrounded, false)

        end
    end
end

return Ground