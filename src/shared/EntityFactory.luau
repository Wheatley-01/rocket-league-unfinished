local EntityFactory = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local carData = require(ReplicatedStorage.Shared.Data.CarData)
local components = require(ReplicatedStorage.Shared.Components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local world = require(ReplicatedStorage.Shared.WorldSingleton)

function EntityFactory.CreateCar(carName: string, ownerName: string, position: Vector3) : (jecs.Entity<unknown> | nil, Model | nil)
    local data: carData.Data = carData[carName]
    assert(data, "Car " .. carName .. " does not exist")

    local model: Model = ReplicatedStorage.Assets.Cars[carName]
    assert(model, "Model " .. carName .. " does not exist")
    assert(model.PrimaryPart, "Model " .. carName .. " does not exist")

    local collidersFolder = model:FindFirstChild("Colliders") :: Folder
    local wheelCollidersFolder = model:FindFirstChild("WheelColliders") :: Folder

    if not collidersFolder or not wheelCollidersFolder then
        return nil, nil
    end

    model = model:Clone()

    local car = world:entity()
    world:set(car, components.Name, carName)
    world:set(car, components.Owner, ownerName)

    world:set(car, components.Position, position)
    world:set(car, components.Velocity, Vector3.zero)
    world:set(car, components.Acceleration, Vector3.zero)
    world:set(car, components.Forces, {})

    world:set(car, components.Rotation, Vector3.zero)
    world:set(car, components.AngularVelocity, Vector3.zero)
    world:set(car, components.AngularAcceleration, Vector3.zero)
    
    world:set(car, components.Friction, {Air = data.AirFriction, Ground = data.GroundFriction})
    world:set(car, components.IsGrounded, false)

    world:set(car, components.Mass, data.Mass)

    local colliders = {}
    local wheelColliders = {}
    
    for _, part in collidersFolder:GetChildren() do
        if not part:IsA("BasePart") then
            continue
        end
        
        table.insert(colliders, {
            Part = part,
            Offset = part.Position - model.PrimaryPart.Position,
            Size = part.Size
        })
    end

    for _, part in wheelCollidersFolder:GetChildren() do
        if not part:IsA("BasePart") then
            continue
        end
        
        table.insert(wheelColliders, {
            Radius = part.Size.Y / 2,
            Offset = part.Position - model.PrimaryPart.Position,
            Stiffness = data.WheelStiffness
        })

        table.sort(wheelColliders, function(a, b)
            return a.Radius > b.Radius
        end)
    end

    world:set(car, components.Colliders, colliders)
    world:set(car, components.WheelColliders, wheelColliders)

    return car, model
end

return EntityFactory