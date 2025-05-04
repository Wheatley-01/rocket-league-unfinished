local Network = {}
Network.Priority = 1

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local blinkServer = require(ReplicatedStorage.Shared.Network.Server)
local input = require(ReplicatedStorage.Shared.Systems.Input)

local inputBuffer: {
    [string]: {
        Input: input.Input,
        Timestamp: number,
    }
} = {}

function Network.Init()
    blinkServer.PlayerInput.On(function(player, input, timestamp)
        inputBuffer[player.Name] = inputBuffer[player.Name] or {} :: {
            Input: input.Input,
            Timestamp: number,
        }

        table.insert(inputBuffer[player.Name], {
            Input = input, 
            Timestamp = timestamp
        })

        table.sort(inputBuffer[player.Name], function(a: {Timestamp: number}, b)
            return a.Timestamp < b.Timestamp
        end)
    end)
end


function Network.Update(dt: number)
    for _, player in Players:GetPlayers() do
        local playerBuffer = inputBuffer[player.Name]
    end
    
    for player, inputs in inputBuffer do
        while inputs[1] and inputs[1].Timestamp + 0.2 < os.time()  do
            table.remove(inputs, 1)
        end
    end
end

return Network