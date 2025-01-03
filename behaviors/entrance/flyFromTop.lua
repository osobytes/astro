local flyFromTop = {
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
return flyFromTop