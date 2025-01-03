local Player = {}
Player.__index = Player
local Effects = require("effects")

function Player.new(x, y, width, height, speed, health, sceneManager)
    local obj = {
        x = x,
        y = y,
        width = width,
        height = height,
        speed = speed,
        health = health,
        maxHealth = health,
        sceneManager = sceneManager,
        waitingForRestart = false,
        velocityX = 0,
        velocityY = 0,
        acceleration = speed * 10, -- Convert speed to acceleration
        drag = 4, -- Drag coefficient (adjust for feel)
        maxSpeed = speed * 2 -- Maximum velocity magnitude
    }

    setmetatable(obj, Player)
    obj.shootCooldown = 0.5
    obj.currentCooldown = 0
    obj.type = "player"
    return obj
end

function Player:update(dt)
    if self.destroyed then
        if love.keyboard.isDown("space") then
            self.sceneManager:loadScene("level_001")
        end
        return
    end

    -- Movement handling with physics
    local inputX, inputY = 0, 0
    
    if love.keyboard.isDown("a") then inputX = inputX - 1 end
    if love.keyboard.isDown("d") then inputX = inputX + 1 end
    if love.keyboard.isDown("w") then inputY = inputY - 1 end
    if love.keyboard.isDown("s") then inputY = inputY + 1 end

    -- Apply acceleration based on input
    self.velocityX = self.velocityX + inputX * self.acceleration * dt
    self.velocityY = self.velocityY + inputY * self.acceleration * dt

    -- Apply drag
    local dragX = -self.velocityX * self.drag * dt
    local dragY = -self.velocityY * self.drag * dt
    
    self.velocityX = self.velocityX + dragX
    self.velocityY = self.velocityY + dragY

    -- Limit maximum speed
    local currentSpeed = math.sqrt(self.velocityX^2 + self.velocityY^2)
    if currentSpeed > self.maxSpeed then
        local scale = self.maxSpeed / currentSpeed
        self.velocityX = self.velocityX * scale
        self.velocityY = self.velocityY * scale
    end

    -- Update position
    self.x = self.x + self.velocityX * dt
    self.y = self.y + self.velocityY * dt

    -- Screen boundaries
    if self.x < 0 then
        self.x = 0
        self.velocityX = 0
    elseif self.x > love.graphics.getWidth() - self.width then
        self.x = love.graphics.getWidth() - self.width
        self.velocityX = 0
    end

    if self.y < 0 then
        self.y = 0
        self.velocityY = 0
    elseif self.y > love.graphics.getHeight() - self.height then
        self.y = love.graphics.getHeight() - self.height
        self.velocityY = 0
    end

    -- Shooting logic
    if self.currentCooldown > 0 then
        self.currentCooldown = self.currentCooldown - dt
    end

    if love.keyboard.isDown("space") and self.currentCooldown <= 0 then
        _G.projectileManager:createPlayerProjectile(self)
        self.currentCooldown = self.shootCooldown
    end
end

function Player:draw()
    if self.destroyed then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Press space to re-start", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        return
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Player:destroy()
    if not self.destroyed then
        local x, y = self.x, self.y
        Effects.addExplosion(self)
        self.destroyed = true
        self.waitingForRestart = true
    end
end

function Player:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:destroy()
    end
end

return Player