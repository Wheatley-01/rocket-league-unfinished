local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local physics = require(ReplicatedStorage.Shared.Systems.Physics)
local ground = require(ReplicatedStorage.Shared.Systems.Ground)
local worldData = require(ReplicatedStorage.Shared.Data.WorldData)

local car = require(script.Systems.Car)
local camera = require(script.Systems.Camera)
local input = require(script.Systems.Input)

car.Init()
camera.Init()

RunService.Heartbeat:Connect(function()
    input.Update(worldData.FixedDeltaTime)
    ground.Update(worldData.FixedDeltaTime)
    physics.Update(worldData.FixedDeltaTime)
end)