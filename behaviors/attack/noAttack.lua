local noAttack = {
    properties = {},
    
    execute = function(self, enemy, dt, projectileManager)
        
    end,
    
    new = function(self)
        local instance = setmetatable({}, { __index = self })
        instance.properties = {}
        return instance
    end
}
return noAttack