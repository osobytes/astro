local Vector = require("vector")
local Projectile = require("projectile")
local Config = require("config")
local ProjectileManager = {}
ProjectileManager.__index = ProjectileManager

function ProjectileManager.new(world)
    local self = setmetatable({}, ProjectileManager)
    self.projectiles = {}
    self.world = world
    return self
end

function ProjectileManager:createPlayerProjectile(x, y)
    local direction = Vector.new(0, -1)
    local projectile = Projectile.new(self.world, x, y, 4, 10, direction, Config.CATEGORY_PROJECTILE_PLAYER, Config.CATEGORY_PLAYER)
    self:add(projectile)
    return projectile
end

function ProjectileManager:createEnemyProjectile(x, y)
    local direction = Vector.new(0, 1)
    local projectile = Projectile.new(self.world, x, y, 4, 10, direction, Config.CATEGORY_PROJECTILE_ENEMY, Config.CATEGORY_ENEMY)
    self:add(projectile)
    return projectile
end

function ProjectileManager:add(projectile)
    table.insert(self.projectiles, projectile)
end

function ProjectileManager:update(dt)
    for i = #self.projectiles, 1, -1 do
        local p = self.projectiles[i]
        if (p.destroyed) then
            table.remove(self.projectiles, i)
            goto continue
        end
        p:update(dt)
        if p:isOffScreen() then
            p:destroy()
            table.remove(self.projectiles, i)
        end

        ::continue::
    end
end

function ProjectileManager:draw()
    for _, p in ipairs(self.projectiles) do
        p:draw()
    end
end

return ProjectileManager