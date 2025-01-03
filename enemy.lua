-- enemy.lua
local Enemy = {}
Enemy.__index = Enemy
local Behaviors = require("behaviors")
local Effects = require("effects")

Enemy.Phases = {
    ENTERING = "entering",
    ON_SCENE = "on_scene",
    EXITING = "exiting"
}

function Enemy.new(x, y, width, height, speed, health, entranceBehavior, attackBehavior, movementBehavior, exitBehavior)
    local obj = setmetatable({}, Enemy)
    obj.x = x
    obj.y = y
    obj.width = width or 32
    obj.height = height or 32
    obj.speed = speed or 100
    obj.health = health or 100
    obj.maxHealth = health or 100
    obj.attributes = {
        attackSpeed = 1.0,
        damage = 1.0
    }
    obj.initialY = y
    obj.initialX = x
    obj.state = {
        phase = Enemy.Phases.ENTERING,
        entrance = Behaviors.getBehavior(entranceBehavior):new(),
        attack = Behaviors.getBehavior(attackBehavior):new(),
        movement = Behaviors.getBehavior(movementBehavior):new(),
        exit = Behaviors.getBehavior(exitBehavior):new()
    }
    obj.type = "enemy"

    -- Behaviors
    if obj.state.entrance then
        obj.state.entrance:init(obj)
    end

    return obj
end

function Enemy:update(dt)
    if self.destroyed then return end

    if self.state.phase == Enemy.Phases.ENTERING then
        if self.state.entrance then
            local entranceEnded = self.state.entrance:execute(self, dt)
            if entranceEnded then
                self.state.movement:init(self)
                self.state.phase = Enemy.Phases.ON_SCENE
            end
        end
    elseif self.state.phase == Enemy.Phases.ON_SCENE then
        if self.state.movement then
            self.state.movement:execute(self, dt)
        end
    elseif self.state.phase == Enemy.Phases.EXITING then
        if self.state.exit then
            self.state.exit:execute(self, dt)
        end
    end

    if self.entranceBehavior then
        self.entranceBehavior(self, dt)
    end

    -- Execute attack behavior separately
    if self.state.attack then
        self.state.attack:execute(self, dt, _G.projectileManager)
    end
end

function Enemy:draw()
    if not self.destroyed then
        love.graphics.setColor(1, 1, 1)  -- Set color to white
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
end

function Enemy:destroy()
    Effects.addExplosion(self)
    self.destroyed = true
end

function Enemy:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:destroy()
    end
end

return Enemy