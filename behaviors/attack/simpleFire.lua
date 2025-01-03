local simpleFire = {
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
return simpleFire