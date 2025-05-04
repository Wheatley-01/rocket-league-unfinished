local InputSystem = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local blinkClient = require(ReplicatedStorage.Shared.Network.Client)
local components = require(ReplicatedStorage.Shared.Components)

local jecsUtils = require(ReplicatedStorage.Shared.Util.JecsUtils)
local input = require(ReplicatedStorage.Shared.Systems.Input)

export type Input = {
    Throttle: number,
    ThrottleStartTime: number | nil,
    Steer: number,
    Boost: boolean,
    Jump: boolean
}

local player = Players.LocalPlayer

local lastInput = {} :: Input

local function getCurrentInput()
    return {
        Throttle = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0,
        Steer = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0,
        Boost = UserInputService:IsKeyDown(Enum.KeyCode.Space),
        Jump = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    } :: Input
end

function InputSystem.Update(dt: number)
    local currentInput = getCurrentInput()
    local serverTime = workspace:GetServerTimeNow()
    local changed = false

    for i, v in currentInput do
        if v == lastInput[i] then
            continue
        end

        changed = true
        break
    end

    local currentCar = jecsUtils.getEntityWithComponent(components.Owner, player.Name)

    if changed then  
        if currentInput.Throttle ~= 0 then
            currentInput.ThrottleStartTime = workspace:GetServerTimeNow()
        else
            currentInput.ThrottleStartTime = nil
        end
    end

    input.applyInput(currentCar, currentInput)

    blinkClient.PlayerInput.Fire(currentInput, serverTime)
    lastInput = currentInput
end

return InputSystem