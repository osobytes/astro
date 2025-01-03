local hover = {
    properties = {},
    init = function(self, enemy) end,
    execute = function(self, enemy, dt) end, -- Stay in place
    
    new = function(self, overrides)
        local instance = setmetatable({}, { __index = self })
        instance.properties = overrides or self.properties
        return instance
    end
}
return hover