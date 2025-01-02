local Projectile = {}
Projectile.__index = Projectile
local Vector = require("vector")

function Projectile.new(world, x, y, width, height, direction, category, mask, attributes)
    local obj = setmetatable({}, Projectile)
    obj.width = width or 4
    obj.height = height or 10
    obj.direction = direction or Vector.new(0, -1)  -- Default up
    obj.destroyed = false
    obj.attributes = attributes or {
        baseDamage = 10,
        speed = 400
    }
    obj.creationTime = love.timer.getTime()

    -- Physics setup
    obj.physics = {}
    obj.physics.body = love.physics.newBody(world, x, y, "dynamic")
    obj.physics.shape = love.physics.newRectangleShape(obj.width, obj.height)
    obj.physics.fixture = love.physics.newFixture(obj.physics.body, obj.physics.shape)
    obj.physics.fixture:setSensor(true)
    obj.physics.fixture:setUserData({type = "projectile", object = obj})
    obj.physics.fixture:setCategory(category)
    obj.physics.fixture:setMask(mask)

    return obj
end

function Projectile:update(dt)
    if not self.destroyed then
        local velocity = self.direction:multiply(self.attributes.speed)
        self.physics.body:setLinearVelocity(velocity.x, velocity.y)
    end
end

function Projectile:isOffScreen()
    if self.destroyed then return false end
    local y = self.physics.body:getY()
    return y + self.height < 0 or y - self.height > love.graphics.getHeight()
end

function Projectile:draw()
    if not self.destroyed then
        local elapsedTime = love.timer.getTime() - self.creationTime
        love.graphics.setShader(_G.projectileShader)
        _G.projectileShader:send("u_color", {1.0, 1.0, 0.0})  -- Yellow color
        _G.projectileShader:send("u_time", elapsedTime)
        _G.projectileShader:send("u_resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
        love.graphics.push()
        love.graphics.translate(self.physics.body:getX(), self.physics.body:getY())
        love.graphics.rotate(self.physics.body:getAngle())
        love.graphics.rectangle("fill", -self.width / 2, -self.height / 2, self.width, self.height)
        love.graphics.pop()
        love.graphics.setShader()
    end
end

function Projectile:destroy()
    if not self.destroyed then
        -- Trigger impact shader effect
        local time = love.timer.getTime()
        self.physics.body:destroy()
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