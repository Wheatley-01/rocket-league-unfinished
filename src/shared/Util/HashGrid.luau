--[[
    Credit to sango for telling me about this method
]]

local HashGrid = {}

local CELL_SIZE = Vector3.new(10, 10, 10)

type AABB = {
    min: Vector3,
    max: Vector3
}

type Cell = { Object }

type CollisionPairs = {
    {
        EntityA: number, 
        ColliderIndexA: number, 
        EntityB: number, 
        ColliderIndexB: number 
    }
}

type Grid = {
    [string]: Cell
}

type Object = {
    Entity: number, 
    ColliderIndex: number, 
    AABB: AABB
}

function HashGrid.new()
    return {} :: Grid
end

local function getCellCoordinates(position: Vector3): Vector3
    return Vector3.new(
        math.floor(position.X / CELL_SIZE.X),
        math.floor(position.Y / CELL_SIZE.Y),
        math.floor(position.Z / CELL_SIZE.Z)
    )
end

local function hashCoordinates(coordinates: Vector3): string
    return tostring(coordinates.X) .. "," .. tostring(coordinates.Y) .. "," .. tostring(coordinates.Z)
end

local function getAABBCells(aabb: AABB): { Vector3 }
    local minCell = getCellCoordinates(aabb.min)
    local maxCell = getCellCoordinates(aabb.max)
    
    local cells = {}

    for x = minCell.X, maxCell.X do
        for y = minCell.Y, maxCell.Y do
            for z = minCell.Z, maxCell.Z do
                table.insert(cells, Vector3.new(x, y, z))
            end
        end
    end

    return cells
end

function HashGrid.insert(grid: Grid, object: Object)
    for _, coordinates in getAABBCells(object.AABB) do
        local key = hashCoordinates(coordinates)

        if not grid[key] then
            grid[key] = {}
        end

        table.insert(grid[key], object)
    end
end

function HashGrid.getCollisionPairs(grid: Grid)
    local collisionPairs: CollisionPairs = {}

    for _, cell in grid do
        for i = 1, #cell do
            local objectA = cell[i]

            for j = i + 1, #cell do
                local objectB = cell[j]

                if objectA.Entity == objectB.Entity then
                    continue 
                end

                table.insert(collisionPairs, {
                    EntityA = objectA.Entity,
                    ColliderIndexA = objectA.ColliderIndex,
                    EntityB = objectB.Entity,
                    ColliderIndexB = objectB.ColliderIndex
                })
            end
        end
    end

    return collisionPairs
end

return HashGrid