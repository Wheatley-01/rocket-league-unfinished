local Network = {}
Network.Priority = 1

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

    for player, inputs in inputBuffer do
        while inputs[1] and inputs[1].Timestamp < os.clock() - 0.5 do
            table.remove(inputs, 1)
        end
    end
end

function Network.Update(dt: number)
    
end

return Network