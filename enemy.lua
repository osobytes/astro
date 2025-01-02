-- enemy.lua
local Enemy = {}
Enemy.__index = Enemy
local config = require("config")
local Behaviors = require("behaviors")

Enemy.Phases = {
    ENTERING = "entering",
    ON_SCENE = "on_scene",
    EXITING = "exiting"
}

function Enemy.new(world, x, y, width, height, speed, health, entranceBehavior, attackBehavior, movementBehavior, exitBehavior)
    local obj = setmetatable({}, Enemy)
    obj.width = width or 32
    obj.height = height or 32
    obj.speed = speed or 100
    obj.health = health or 100
    obj.maxHealth = health or 100
    obj.attributes = {
        attackSpeed = 1.0,
        damage = 1.0
    }
    obj.projectileManager = world.projectileManager
    obj.initialY = y
    obj.initialX = x
    obj.state = {
        phase = Enemy.Phases.ENTERING,
        entrance = Behaviors.Entrance.getBehavior(entranceBehavior):new(),
        attack = Behaviors.Attack.getBehavior(attackBehavior):new(),
        movement = Behaviors.Movement.getBehavior(movementBehavior):new(),
        exit = Behaviors.Exit.getBehavior(exitBehavior):new()
    }

    -- Physics setup
    obj.physics = {}
    obj.physics.body = love.physics.newBody(world, x, y, "dynamic")
    obj.physics.shape = love.physics.newRectangleShape(obj.width, obj.height)
    obj.physics.fixture = love.physics.newFixture(obj.physics.body, obj.physics.shape)
    obj.physics.fixture:setUserData({type = "enemy", object = obj})
    obj.physics.fixture:setCategory(config.CATEGORY_ENEMY)
    obj.physics.fixture:setMask(config.CATEGORY_PROJECTILE_ENEMY)

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
            self.state.entrance:execute(self, dt)
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
        local x, y = self.physics.body:getPosition()
        love.graphics.setColor(1, 1, 1)  -- Set color to white
        love.graphics.rectangle("fill", x - self.width/2, y - self.height/2, self.width, self.height) 
    end
end

function Enemy:destroy()
    if not self.destroyed then
        local x, y = self.physics.body:getPosition()
        addExplosion(x, y)
        self.physics.body:destroy()
        self.destroyed = true
    end
end

function Enemy:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:destroy()
    end
end

return Enemy