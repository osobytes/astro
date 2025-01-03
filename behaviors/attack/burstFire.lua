local burstFire = {
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
return burstFire