--!nonstrict
local Collision = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.Components)
local hashGrid = require(script.Parent.Parent.Util.HashGrid)
local world = require(ReplicatedStorage.Shared.WorldSingleton)

local collisionQuery = world:query(
	components.Position,
	components.Rotation,
	components.Colliders,
    components.Mass
):cached()

local function transformAABB(
	position: Vector3,
	rotation: Vector3,
	collider: { Part: MeshPart, Offset: Vector3, Size: Vector3 }
)

	local cframe = CFrame.new(position) * CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
	local worldOffset = cframe:PointToWorldSpace(collider.Offset)

	local halfSize = collider.Size / 2
	return {min = worldOffset - halfSize, max = worldOffset + halfSize}
end

local function aabbIntersects(minA: Vector3, maxA: Vector3, minB: Vector3, maxB: Vector3): boolean
    return minA.X <= maxB.X and maxA.X >= minB.X and
           minA.Y <= maxB.Y and maxA.Y >= minB.Y and
           minA.Z <= maxB.Z and maxA.Z >= minB.Z
end

--Broad phase
function Collision.DetectCollisions()
    local collisions = {} 
    local grid = hashGrid.new()

    for entity, position, rotation, colliders, mass in collisionQuery do
        for i, collider in colliders do
            local aabb = transformAABB(position, rotation, collider)

            hashGrid.insert(grid, {
                Entity = entity,
                ColliderIndex = i,
                AABB = aabb
            })
        end
    end

	local collisionPairs = hashGrid.getCollisionPairs(grid)

    for _, pair in collisionPairs do
        local entityA, entityB = pair.entityA, pair.entityB
        local colliderA = (world:get(entityA, components.Colliders) :: { any })[pair.colliderIndexA]
        local colliderB = (world:get(entityB, components.Colliders) :: { any })[pair.colliderIndexB]
        
        local positionA = world:get(entityA, components.Position)
        local rotationA = world:get(entityA, components.Rotation)
        local positionB = world:get(entityB, components.Position)
        local rotationB = world:get(entityB, components.Rotation)
        
        local aabbA = transformAABB(positionA, rotationA, colliderA)
        local aabbB = transformAABB(positionB, rotationB, colliderB)
        
        if not aabbIntersects(aabbA.min, aabbA.max, aabbB.min, aabbB.max) then
			continue
		end

		table.insert(collisions, {
			EntityA = entityA,
			EntityB = entityB,
			ContactPoint = (aabbA.min + aabbA.max) / 2,
			Normal = Vector3.new(0, 1, 0),
			Penetration = 0
		})
    end

    grid = {}
    return collisions
end

--Narrow phase
function Collision.RefineCollisions(collisions)
	for i, collision in collisions do
		local entityA = collision.entityA
		local entityB = collision.entityB
		local modelA = world:get(entityA, components.Model)
		local modelB = world:get(entityB, components.Model)

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = { modelB }

		local parts = workspace:GetPartBoundsInBox(
			CFrame.new(collision.contactPoint),
			(modelA.PrimaryPart.Size + modelB.PrimaryPart.Size) / 2,
			overlapParams
		)

		if #parts > 0 then
			collision.ContactPoint = parts[1].Position
			collision.Normal = (collision.contactPoint - modelA.PrimaryPart.Position).Unit
			collision.Penetration = 0.1
			
		else
			collisions[i] = nil
		end
	end

	return collisions
end

return Collision