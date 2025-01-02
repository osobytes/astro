local Player = {}
Player.__index = Player
local config = require("config")

function Player.new(world, x, y, width, height, speed, health)
    local obj = {
        x = x,
        y = y,
        width = width,
        height = height,
        speed = speed,
        health = health,
        maxHealth = health
    }

    setmetatable(obj, Player)

    -- Create collider
    obj.physics = {}
    obj.physics.body = love.physics.newBody(world, x, y, "dynamic")
    obj.physics.shape = love.physics.newRectangleShape(width, height)
    obj.physics.fixture = love.physics.newFixture(obj.physics.body, obj.physics.shape)
    obj.physics.fixture:setUserData({type = "player", object = obj})
    obj.physics.fixture:setCategory(config.CATEGORY_PLAYER)
    obj.physics.fixture:setMask(config.CATEGORY_PROJECTILE_PLAYER)
    obj.physics.body:setFixedRotation(true)
    obj.shootCooldown = 0.5 -- Cooldown time in seconds
    obj.currentCooldown = 0 -- Current cooldown timer

    return obj
end

function Player:update(dt)
    -- Movement
    if love.keyboard.isDown("left") then
        self.physics.body:setX(self.physics.body:getX() - self.speed * dt)
    elseif love.keyboard.isDown("right") then
        self.physics.body:setX(self.physics.body:getX() + self.speed * dt)
    end

    if self.currentCooldown > 0 then
        self.currentCooldown = self.currentCooldown - dt
    end

    -- Shooting
    if love.keyboard.isDown("space") and self.currentCooldown <= 0 then
        _G.projectileManager:createPlayerProjectile(self.physics.body:getX(), self.physics.body:getY() - self.height / 2)
        self.currentCooldown = self.shootCooldown
    end

    -- Synchronize position
    self.x = self.physics.body:getX() - self.width / 2
    self.y = self.physics.body:getY() - self.height / 2
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Player:destroy()
    if not self.destroyed then
        local x, y = self.physics.body:getPosition()
        addExplosion(x, y)  -- Add this line
        self.physics.body:destroy()
        self.destroyed = true
    end
end

function Player:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:destroy()
    end
end

return Player