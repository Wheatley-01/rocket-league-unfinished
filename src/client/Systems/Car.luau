local CarSystem = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local blinkClient = require(ReplicatedStorage.Shared.Network.Client)
local entityFactory = require(ReplicatedStorage.Shared.EntityFactory)
local components = require(ReplicatedStorage.Shared.Components)
local world = require(ReplicatedStorage.Shared.WorldSingleton)

local renderQuery = world:query(
    components.Model,
    components.Position, 
    components.Rotation
):cached()

function CarSystem.Init()
    blinkClient.CreateCar.On(function(carName, ownerName, position)
        local car, model = entityFactory.CreateCar(carName, ownerName, position)
        if not model then return end

        model.Parent = Workspace
        world:set(car :: any, components.Model, model)
    end)

    RunService.RenderStepped:Connect(function()
        for entity, model, position, rotation in renderQuery :: any do
            if not model:IsA("Model") or not model.PrimaryPart then
                continue
            end
            
            model.PrimaryPart.CFrame = CFrame.new(position) * CFrame.Angles(
                math.rad(rotation.X),
                math.rad(rotation.Y),
                math.rad(rotation.Z)
            )     
        end
    end)
end

return CarSystem