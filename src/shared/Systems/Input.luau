local Input = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.Components)

local curves = require(ReplicatedStorage.Shared.Util.Curves)
local physics = require(ReplicatedStorage.Shared.Systems.Physics)

local world = require(ReplicatedStorage.Shared.WorldSingleton)
local carData = require(ReplicatedStorage.Shared.Data.CarData)

export type Input = {
    Throttle: number,
    ThrottleStartTime: number | nil,
    Steer: number,
    Boost: boolean,
    Jump: boolean
}

function Input.applyInput(entity, input: Input)
    local model = world:get(entity, components.Model) :: Model
    if not model.PrimaryPart then return end

    local data = carData[model.Name]
    if not data then return end

    local lookVector = model.PrimaryPart.CFrame.LookVector
    local rightVector = model.PrimaryPart.CFrame.RightVector

    local serverTime = workspace:GetServerTimeNow()
    local throttleForce = Vector3.zero

    if input.Throttle ~= 0 then
        local startTime = input.ThrottleStartTime or serverTime
        local timeHeld = serverTime - startTime

        local magnitude = curves.Sigmoid(timeHeld, data.MaxForce, data.Acceleration, data.MaxForceTime * 0.5) * input.Throttle
        throttleForce = lookVector * magnitude
    end
   
    local steerTorque = Vector3.zero

    if input.Throttle ~= 0 and input.Steer ~= 0 then
        local steerOffset = lookVector * data.HalfSize 
        local steerForce = rightVector * input.Steer * data.SteerStrength

        physics.ApplyImpulse(entity, steerForce, steerOffset)
    end

    physics.ApplyImpulse(entity, throttleForce, Vector3.zero, true)
    physics.ApplyImpulse(entity, steerTorque, Vector3.zero)

    if input.Boost then
        physics.ApplyImpulse(entity, lookVector * data.BoostStrength, Vector3.zero)
    end

    if input.Jump and world:get(entity, components.IsGrounded) then
        physics.ApplyImpulse(entity, Vector3.new(0, data.JumpStrength, 0), Vector3.zero)
    end
end

return Input