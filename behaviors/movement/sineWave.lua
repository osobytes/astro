local sineWave = {
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
return sineWave