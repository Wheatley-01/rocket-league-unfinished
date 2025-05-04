--!nonstrict
local Camera = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local components = require(game.ReplicatedStorage.Shared.Components)
local world = require(game.ReplicatedStorage.Shared.WorldSingleton)

local CAMERA_OFFSET = Vector3.new(0, 8, 28)

local player = Players.LocalPlayer

local cameraQuery = world:query(
    components.Owner, 
    components.Model
):cached()

function Camera.Init()
    local camera = Workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable

    RunService.RenderStepped:Connect(function()
        for entity, owner, model in cameraQuery do
            if owner ~= player.Name then
                continue
            end

            local carCFrame = model.PrimaryPart.CFrame :: CFrame
            local cameraCFrame = carCFrame:ToWorldSpace(CFrame.new(CAMERA_OFFSET))
      
            camera.CFrame = cameraCFrame
            camera.Focus = carCFrame

            break
        end
    end)
end

return Camera