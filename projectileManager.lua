local Vector = require("vector")
local Projectile = require("projectile")
local Collision = require("collision")
local Quadtree = require("quadtree")

local ProjectileManager = {}
ProjectileManager.__index = ProjectileManager

-- You may want to dynamically get screenWidth/screenHeight in Love2D, e.g.
--   local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
-- For simplicity, let's assume we have fixed width/height:
local screenWidth  = 800
local screenHeight = 600

function ProjectileManager.new()
    local self = setmetatable({}, ProjectileManager)
    self.projectiles = {}

    -- Create a Quadtree that covers the entire screen:
    self.quadtree = Quadtree.new(0, 0, screenWidth, screenHeight, 8, 5, 0)

    return self
end

function ProjectileManager:createPlayerProjectile(player)
    local w, h = 4, 10
    local direction = Vector.new(0, -1)
    local x = player.x + (player.width/2)  -- Center horizontally
    local y = player.y - h                 -- Top of player
    local projectile = Projectile.new(
        x, y, w, h,
        direction,
        { baseDamage = 10, speed = 400 },
        player -- The "owner"
    )
    self:add(projectile)
    return projectile
end

function ProjectileManager:createEnemyProjectile(enemy)
    local w, h = 4, 10
    local direction = Vector.new(0, 1)
    local x = enemy.x + (enemy.width/2)    -- Center horizontally
    local y = enemy.y + enemy.height       -- Bottom of enemy
    local projectile = Projectile.new(
        x, y, w, h,
        direction,
        { baseDamage = 10, speed = 400 },
        enemy -- The "owner"
    )
    self:add(projectile)
    return projectile
end

function ProjectileManager:add(projectile)
    table.insert(self.projectiles, projectile)
end

function ProjectileManager:update(dt)
    -- 1) Clear out destroyed projectiles first
    for i = #self.projectiles, 1, -1 do
        if self.projectiles[i].destroyed then
            table.remove(self.projectiles, i)
        end
    end

    -- 2) Clear the quadtree and re-insert everything
    self.quadtree:clear()

    -- Insert projectiles
    for _, proj in ipairs(self.projectiles) do
        self.quadtree:insert(proj)
    end

    -- Also insert enemies and player if desired,
    -- so we can do a single broad-phase pass for everything:
    if _G.enemyManager and _G.enemyManager.enemies then
        for _, enemy in ipairs(_G.enemyManager.enemies) do
            if not enemy.destroyed then
                self.quadtree:insert(enemy)
            end
        end
    end

    if _G.player and not _G.player.destroyed then
        self.quadtree:insert(_G.player)
    end

    -- 3) Collision checks
    --    For each projectile, retrieve potential collisions from quadtree
    --    and do narrower collision checks with those objects.
    for i = #self.projectiles, 1, -1 do
        local proj = self.projectiles[i]
        if proj.destroyed then goto continue end

        -- Get list of potential colliders
        local possibleCollisions = self.quadtree:retrieve({}, proj)

        -- Check each possible collider
        for _, other in ipairs(possibleCollisions) do
            -- Don’t check an object against itself
            if other ~= proj and not other.destroyed then
                -- We have both enemies, player, and projectiles in the same broadphase
                if proj:canCollideWith(other) and Collision.rectOverlap(proj, other) then
                    -- Enemy or Player?
                    if other.type == "enemy" then
                        other:takeDamage(proj:calculateDamage({ type = "enemy" }))
                        proj:destroy()
                        break
                    elseif other.type == "player" then
                        other:takeDamage(proj:calculateDamage({ type = "player" }))
                        proj:destroy()
                        break
                    elseif other.type == "projectile" then
                        -- Projectile-vs-Projectile collision
                        -- Decide your own logic: e.g., destroy both
                        proj:destroy()
                        other:destroy()
                        break
                    end
                end
            end
        end

        ::continue::
    end

    -- 4) Update projectiles (movement, etc.)
    --    If off-screen or destroyed, remove them.
    for i = #self.projectiles, 1, -1 do
        local proj = self.projectiles[i]
        if not proj.destroyed then
            proj:update(dt)
            if proj:isOffScreen() then
                proj:destroy(true)
            end
        end
        if proj.destroyed then
            table.remove(self.projectiles, i)
        end
    end
end

function ProjectileManager:draw()
    for _, p in ipairs(self.projectiles) do
        p:draw()
    end
end

return ProjectileManager