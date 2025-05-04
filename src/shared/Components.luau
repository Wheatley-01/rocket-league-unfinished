local Components = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jecs = require(ReplicatedStorage.Packages.jecs)
local world = require(ReplicatedStorage.Shared.WorldSingleton)

export type Entity<T> = jecs.Entity<T>
export type Collider = {
    Part: BasePart,
    Offset: Vector3,
    Size: Vector3,
}

export type WheelCollider = {
    Radius: number,
    Stiffness: number,
    Offset: Vector3,
}

export type Force = {
    Value: Vector3,
    Offset: Vector3,
}

Components.Name = world:component() :: Entity<string>
Components.Owner = world:component() :: Entity<string>

Components.Position = world:component() :: Entity<Vector3>
Components.Velocity = world:component() :: Entity<Vector3>
Components.Acceleration = world:component() :: Entity<Vector3>
Components.Forces = world:component() :: Entity<{Force}>

Components.Friction = world:component() :: Entity<{Air: number, Ground: number}> --static coefficient = kinetic coefficient for now
Components.IsGrounded = world:component() :: Entity<boolean>

Components.Rotation = world:component() :: Entity<Vector3>
Components.AngularVelocity = world:component() :: Entity<Vector3>
Components.AngularAcceleration = world:component() :: Entity<Vector3>

Components.Mass = world:component() :: Entity<number>
Components.Model = world:component() :: Entity<Model>

Components.Fixed = world:component()

Components.Colliders = world:component() :: Entity<{ Collider }>
Components.WheelColliders = world:component() :: Entity<{ WheelCollider }>

return Components