local Projectile = {}
Projectile.__index = Projectile
local Vector = require("vector")
local Effects = require("effects")

function Projectile.new(x, y, width, height, direction, attributes, source)
    local obj = setmetatable({}, Projectile)
    obj.x = x - width/2  -- Convert from center to top-left
    obj.y = y - height/2
    obj.width = width or 4
    obj.height = height or 10
    obj.direction = direction or Vector.new(0, -1)  -- Default up
    obj.destroyed = false
    obj.attributes = attributes or {
        baseDamage = 10,
        speed = 400
    }
    obj.creationTime = love.timer.getTime()
    obj.source = source
    obj.type = "projectile"

    return obj
end

function Projectile:update(dt)
    if not self.destroyed then
        local velocity = self.direction:multiply(self.attributes.speed)
        self.x = self.x + velocity.x * dt
        self.y = self.y + velocity.y * dt
    end
end

function Projectile:canCollideWith(target)
    if self.destroyed then return false end
    if (self.source == nil) then return true end

    if self.source.type == "player" then
        return target.type == "enemy" or (target.type == "projectile" and target.source.type == "enemy")
    end

    if self.source.type == "enemy" then
        return target.type == "player" or (target.type == "projectile" and target.source.type == "player")
    end
end

function Projectile:isOffScreen()
    if self.destroyed then return false end
    return self.y + self.height < 0 or self.y - self.height > love.graphics.getHeight()
end

function Projectile:draw()
    if not self.destroyed then
        local elapsedTime = love.timer.getTime() - self.creationTime
        love.graphics.setShader(_G.projectileShader)
        _G.projectileShader:send("u_color", {1.0, 1.0, 0.0})  -- Yellow color
        _G.projectileShader:send("u_time", elapsedTime)
        _G.projectileShader:send("u_resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
        love.graphics.push()
        love.graphics.translate(self.x + self.width/2, self.y + self.height/2)  -- Convert back to center for drawing
        love.graphics.rotate(0)
        love.graphics.rectangle("fill", -self.width/2, -self.height/2, self.width, self.height)
        love.graphics.pop()
        love.graphics.setShader()
    end
end

function Projectile:destroy()
    if not self.destroyed then
        Effects.addImpact(self.x, self.y)
        self.destroyed = true
    end
end

function Projectile:calculateDamage(target)
    local baseDamage = self.attributes.baseDamage or 10
    local specialDamage = self.attributes.specialDamage or 0
    local totalDamage = baseDamage + specialDamage

    -- Apply any target-specific damage modifiers here
    if target.type == "player" then
        totalDamage = totalDamage * 1.0  -- Example modifier
    elseif target.type == "enemy" then
        totalDamage = totalDamage * 1.0  -- Example modifier
    end

    return totalDamage
end

return Projectile