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
        waitingForRestart = false
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

    if love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
    elseif love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
    end

    if self.currentCooldown > 0 then
        self.currentCooldown = self.currentCooldown - dt
    end

    if love.keyboard.isDown("space") and self.currentCooldown <= 0 then
        _G.projectileManager:createPlayerProjectile(self)
        self.currentCooldown = self.shootCooldown
    end

    if self.x < 0 then
        self.x = 0
    elseif self.x > love.graphics.getWidth() - self.width then
        self.x = love.graphics.getWidth() - self.width
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
        Effects.addExplosion(x, y)
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