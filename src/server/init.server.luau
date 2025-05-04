local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local blinkServer = require(ReplicatedStorage.Shared.Network.Server)

local entityFactory = require(ReplicatedStorage.Shared.EntityFactory)
local components = require(ReplicatedStorage.Shared.Components)
local world = require(ReplicatedStorage.Shared.WorldSingleton)

local ground = require(ReplicatedStorage.Shared.Systems.Ground)
local moduleLoader = require(ReplicatedStorage.Shared.Util.ModuleLoader)
local network = require(script.Network)
local physics = require(ReplicatedStorage.Shared.Systems.Physics)
local worldData = require(ReplicatedStorage.Shared.Data.WorldData)

local handlers = moduleLoader.Load(script)

for _, handler in handlers do
    handler.Init()
end

RunService.Heartbeat:Connect(function()
    ground.Update(worldData.FixedDeltaTime)
    physics.Update(worldData.FixedDeltaTime)
    network.Update(worldData.FixedDeltaTime)
end)

Players.PlayerAdded:Connect(function(player)
    local car = entityFactory.CreateCar("Octane", player.Name, Vector3.new(0, 25, 0))
    world:set(car :: any, components.Owner, player.Name)

    blinkServer.CreateCar.FireAll("Octane", player.Name, Vector3.new(0, 25, 0))
end)