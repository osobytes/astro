local flyDown = {
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
return flyDown