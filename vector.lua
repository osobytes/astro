local Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vector)
end

function Vector:multiply(scalar)
    return Vector.new(self.x * scalar, self.y * scalar)
end

return Vector