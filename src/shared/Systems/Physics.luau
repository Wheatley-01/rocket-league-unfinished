--!nonstrict
local Physics = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.Components)
local world = require(ReplicatedStorage.Shared.WorldSingleton)

local carData = require(ReplicatedStorage.Shared.Data.CarData)
local worldData = require(ReplicatedStorage.Shared.Data.WorldData)

local collision = require(script.Parent.Collision)

local physicsQuery = world:query(
    components.Position,
    components.Velocity,
    components.Acceleration,
    components.Rotation,
    components.AngularVelocity,
    components.AngularAcceleration,
    components.Forces,
    components.Mass
):without(components.Fixed):cached()

local frictionQuery = world:query(
    components.Velocity,
    components.Mass, 
    components.Friction,
    components.IsGrounded
):cached()

local angularDampingQuery = world:query(
    components.AngularVelocity,
    components.Mass,
    components.IsGrounded,
    components.Model
):cached()

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = workspace.Map:GetChildren()
raycastParams.FilterType = Enum.RaycastFilterType.Include

function Physics.ApplyImpulse(entity, force: Vector3, offset: Vector3, constant: boolean | nil)
    if world:has(entity, components.Fixed) then return end

    local forces = world:get(entity, components.Forces) or {}
    table.insert(forces, {
        Value = force,
        Offset = offset,
        Constant = constant,
    })

    world:set(entity, components.Forces, forces)

    local acceleration = world:get(entity, components.Acceleration) :: Vector3
    local angularAcceleration = world:get(entity, components.AngularAcceleration) :: Vector3
    local mass = world:get(entity, components.Mass) :: number

    world:set(entity, components.Acceleration, acceleration + force / mass)
    world:set(entity, components.AngularAcceleration, angularAcceleration + offset:Cross(force) / mass) --assuming moment of inertia = 1
end

function Physics.ResolveCollisions(collisions)
    for _, collision in collisions do
        local massA = world:get(collision.EntityA, components.Mass) or 10 :: number
        local massB = world:get(collision.EntityB, components.Mass) or 10 :: number
        local velocityA = world:get(collision.EntityA, components.Velocity)
        local velocityB = world:get(collision.EntityB, components.Velocity)
        
        local relativeVelocity = velocityB - velocityA
        local normal = collision.Normal
        
        local impulseMagnitude = -(1 + worldData.CoefficientOfRestituion) * relativeVelocity:Dot(normal.Unit) / (1/massA + 1/massB)
        local impulse = impulseMagnitude * normal
        
        Physics.ApplyImpulse(collision.EntityA, -impulse, collision.ContactPoint - world:get(collision.EntityA, components.Position))
        Physics.ApplyImpulse(collision.EntityB, impulse, collision.ContactPoint - world:get(collision.EntityB, components.Position))
        
        if collision.Penetration > 0 then
            local correction = normal * collision.Penetration / (1 / massA + 1 / massB)
            world:set(collision.EntityA, components.Position, world:get(collision.EntityA, components.Position) - correction / massA)
            world:set(collision.EntityB, components.Position, world:get(collision.EntityB, components.Position) + correction / massB)
        end
    end
end

function Physics.Update(dt: number)
    for entity, _, _, _, _, _, _, forces, mass in physicsQuery do
        if world:has(entity, components.Fixed) then continue end
        Physics.ApplyImpulse(entity, mass * worldData.Gravity, Vector3.zero)
    end

    local collisions = collision.DetectCollisions()
    Physics.ResolveCollisions(collisions)

    for entity, position, velocity, acceleration, rotation, angularVelocity, angularAcceleration, forces, mass in physicsQuery do
        local newVelocity = velocity + acceleration * dt
        local newPosition = position + newVelocity * dt

        local newAngularVelocity = angularVelocity + angularAcceleration * dt
        local newRotation = rotation + newAngularVelocity * dt

        world:set(entity, components.Position, newPosition)
        world:set(entity, components.Velocity, newVelocity)
        world:set(entity, components.Acceleration, Vector3.zero)
        world:set(entity, components.Rotation, newRotation)
        world:set(entity, components.AngularVelocity, newAngularVelocity)
        world:set(entity, components.AngularAcceleration, Vector3.zero)

        for i, force in forces do
            if force.Value ~= Vector3.zero and force.Constant then
                continue 
            end
            
            forces[i] = nil
        end

        world:set(entity, components.Forces, forces)

        local model = world:get(entity, components.Model) --we dont add it in the query because the server doesnt have a model

        if model and model.PrimaryPart then
            model.PrimaryPart.CFrame = (CFrame.new(newPosition) * CFrame.Angles(math.rad(newRotation.X), math.rad(newRotation.Y), math.rad(newRotation.Z)))
        end
    end

    for entity, velocity, mass, friction, isGrounded in frictionQuery do
        if isGrounded then
            local frictionForce = -friction.Ground * mass * Vector3.new(velocity.X, 0, velocity.Z)
            Physics.ApplyImpulse(entity, frictionForce, Vector3.zero)

        else
            local speed = velocity.Magnitude
            if speed > 0 then
                local dragForce = -friction.Air * speed * speed * velocity.Unit
                Physics.ApplyImpulse(entity, dragForce, Vector3.zero)
            end
        end
    end

    for entity, angularVelocity, mass, isGrounded, model in angularDampingQuery do
        local data = carData[model.Name]

        if not isGrounded or not model.PrimaryPart or not data then
            continue
        end
        
        local velocity = world:get(entity, components.Velocity) or Vector3.zero
        local speed = math.clamp(velocity.Magnitude * 0.01, 0.5, 2) 
        
        local lookVector = model.PrimaryPart.CFrame.LookVector
        local rightVector = model.PrimaryPart.CFrame.RightVector

        local steerOffset = lookVector * data.HalfSize

        local dampingForce = rightVector * angularVelocity.Y * worldData.AngularDampingStrength * speed
        Physics.ApplyImpulse(entity, dampingForce, steerOffset)
    end
   
end

return Physics