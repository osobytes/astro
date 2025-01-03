local Behaviors = {}

-- Entrance Behaviors
Behaviors.Entrance = {
    getBehavior = function(behaviorName)
        return Behaviors.Entrance[behaviorName] or Behaviors.Entrance.flyFromTop
    end
}

Behaviors.Entrance.flyFromTop = {
    properties = {
        isComplete = false,
        targetY = nil,
        speed = 200
    },
    
    init = function(self, enemy)
        -- Start from above screen bounds
        local screenHeight = love.graphics.getHeight()
        enemy.y = -screenHeight * 0.1 -- 10% above screen
        self.properties.targetY = enemy.initialY
    end,
    
    execute = function(self, enemy, dt)
        if self.properties.isComplete then return true end
        
        enemy.y = enemy.y + self.properties.speed * dt
        
        if enemy.y >= self.properties.targetY then
            enemy.y = self.properties.targetY
            self.properties.isComplete = true
            return true
        end
        return false
    end,

    new = function(self, overrides)
        local instance = setmetatable({}, { __index = self })
        instance.properties = {
            isComplete = overrides and overrides.isComplete or self.properties.isComplete,
            targetY = overrides and overrides.targetY or self.properties.targetY,
            speed = overrides and overrides.speed or self.properties.speed
        }
        return instance
    end
}

-- Movement Behaviors
Behaviors.Movement = {
    getBehavior = function(behaviorName)
        return Behaviors.Movement[behaviorName] or Behaviors.Movement.hover
    end
}

Behaviors.Movement.hover = {
    properties = {},
    init = function(self, enemy) end,
    execute = function(self, enemy, dt) end, -- Stay in place
    
    new = function(self, overrides)
        local instance = setmetatable({}, { __index = self })
        instance.properties = overrides or self.properties
        return instance
    end
}

Behaviors.Movement.sineWave = {
    properties = {
        time = 0,
        amplitude = 50,
        frequency = 2,
        centerY = nil
    },
    
    init = function(self, enemy)
        self.properties.centerY = enemy.y
    end,
    
    execute = function(self, enemy, dt)
        self.properties.time = self.properties.time + dt
        local newY = self.properties.centerY + 
                    math.sin(self.properties.time * self.properties.frequency) * 
                    self.properties.amplitude
        enemy.y = newY
    end,
    
    new = function(self, overrides)
        local instance = setmetatable({}, { __index = self })
        instance.properties = {
            time = overrides and overrides.time or self.properties.time,
            amplitude = overrides and overrides.amplitude or self.properties.amplitude,
            frequency = overrides and overrides.frequency or self.properties.frequency,
            centerY = overrides and overrides.centerY or self.properties.centerY
        }
        return instance
    end
}

-- Exit Behaviors
Behaviors.Exit = {
    getBehavior = function(behaviorName)
        return Behaviors.Exit[behaviorName] or Behaviors.Exit.flyUp
    end
}

Behaviors.Exit.flyUp = {
    properties = {
        speed = 200,
        isExiting = false,
        isComplete = false
    },
    
    init = function(self, enemy) end,
    
    execute = function(self, enemy, dt)
        if not self.properties.isExiting then return false end
        
        enemy.y = enemy.y - self.properties.speed * dt
        
        if enemy.y + enemy.height < 0 then
            self.properties.isComplete = true
            return true
        end
        return false
    end,

    new = function(self, overrides)
        local instance = setmetatable({}, { __index = self })
        instance.properties = {
            speed = overrides and overrides.speed or self.properties.speed,
            isExiting = overrides and overrides.isExiting or self.properties.isExiting,
            isComplete = overrides and overrides.isComplete or self.properties.isComplete
        }
        return instance
    end
}

Behaviors.Exit.flyDown = {
    properties = {
        speed = 200,
        isExiting = false,
        isComplete = false
    },
    
    init = function(self, enemy) end,
    
    execute = function(self, enemy, dt)
        if not self.properties.isExiting then return false end
        
        enemy.y = enemy.y + self.properties.speed * dt
        
        if enemy.y > love.graphics.getHeight() then
            self.properties.isComplete = true
            return true
        end
        return false
    end,

    new = function(self, overrides)
        local instance = setmetatable({}, { __index = self })
        instance.properties = {
            speed = overrides and overrides.speed or self.properties.speed,
            isExiting = overrides and overrides.isExiting or self.properties.isExiting,
            isComplete = overrides and overrides.isComplete or self.properties.isComplete
        }
        return instance
    end
}

-- Attack Behaviors
Behaviors.Attack = {
    getBehavior = function(behaviorName)
        return Behaviors.Attack[behaviorName] or Behaviors.Attack.noAttack
    end
}

Behaviors.Attack.simpleFire = {
    properties = {
        baseCooldown = 1.0,
        currentCooldown = 0
    },
    
    execute = function(self, enemy, dt, projectileManager)
        local actualCooldown = self.properties.baseCooldown / enemy.attributes.attackSpeed
        self.properties.currentCooldown = self.properties.currentCooldown - dt
        
        if self.properties.currentCooldown <= 0 then
            projectileManager:createEnemyProjectile(enemy)
            self.properties.currentCooldown = actualCooldown
        end
    end,
    
    new = function(self)
        local instance = setmetatable({}, { __index = self })
        instance.properties = {
            baseCooldown = self.properties.baseCooldown,
            currentCooldown = self.properties.currentCooldown
        }
        return instance
    end
}


Behaviors.Attack.burstFire = {
    properties = {
        burstCooldown = 2.0,
        burstDelay = 0.1,
        currentCooldown = 0,
        burstCount = 0,
        maxBurst = 3
    },

    execute = function(self, enemy, dt, projectileManager)
        local actualCooldown = self.properties.burstCooldown / enemy.attributes.attackSpeed
        local actualDelay = self.properties.burstDelay / enemy.attributes.attackSpeed

        self.properties.currentCooldown = self.properties.currentCooldown - dt
        if self.properties.currentCooldown <= 0 then
            if self.properties.burstCount < self.properties.maxBurst then
                projectileManager:createEnemyProjectile(enemy)
                self.properties.burstCount = self.properties.burstCount + 1
                self.properties.currentCooldown = actualDelay
            else
                self.properties.burstCount = 0
                self.properties.currentCooldown = actualCooldown
            end
        end
    end,
    
    new = function(self)
        local instance = setmetatable({}, { __index = self })
        instance.properties = {
            burstCooldown = self.properties.burstCooldown,
            burstDelay = self.properties.burstDelay,
            currentCooldown = self.properties.currentCooldown,
            burstCount = self.properties.burstCount,
            maxBurst = self.properties.maxBurst
        }
        return instance
    end
}

function Behaviors.Attack.noAttack(enemy, dt)
    -- do nothing
end

-- Projectile Movement Behaviors
Behaviors.ProjectileMovement = {}

function Behaviors.ProjectileMovement.straight(projectile, dt)
    local angle = projectile.angle or 0
    local dx = math.cos(angle) * projectile.speed * dt
    local dy = math.sin(angle) * projectile.speed * dt
    projectile.x = projectile.x + dx
    projectile.y = projectile.y + dy
end

function Behaviors.ProjectileMovement.sine(projectile, dt)
    projectile.time = (projectile.time or 0) + dt
    local angle = projectile.angle or 0
    local amplitude = 100
    local frequency = 2
    local dx = math.cos(angle) * projectile.speed
    local dy = math.sin(angle) * projectile.speed + 
               amplitude * math.sin(frequency * projectile.time)
    projectile.x = projectile.x + dx * dt
    projectile.y = projectile.y + dy * dt
end

function Behaviors.ProjectileMovement.spiral(projectile, dt)
    projectile.time = (projectile.time or 0) + dt
    local radius = 50
    local angularSpeed = 5
    local dx = radius * math.cos(projectile.time * angularSpeed)
    local dy = projectile.speed * dt
    projectile.x = projectile.x + dx * dt
    projectile.y = projectile.y + dy
end

return Behaviors