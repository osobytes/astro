local Level_001 = {}
local EnemyManager = require("enemyManager")
local Player = require("player")
local ProjectileManager = require("projectileManager")

function Level_001:load(sceneManager)
    -- Initialize level 1
    local waveConfig = require("levels.level_001_config")

    -- Create managers and player here, assign them to globals:
    _G.enemyManager = EnemyManager.new()
    _G.player = Player.new(love.graphics.getWidth() / 2, love.graphics.getHeight() - 50, 32, 32, 200, 10, sceneManager)
    _G.projectileManager = ProjectileManager.new()

    -- Keep references inside this level, too:
    self.enemyManager = _G.enemyManager
    self.player = _G.player
    self.projectileManager = _G.projectileManager
    self.enemyManager:configure(waveConfig)
end

function Level_001:update(dt)
    -- Update level 1
    self.enemyManager:update(dt)
    self.player:update(dt)
    self.projectileManager:update(dt)
end

function Level_001:draw()
    self.enemyManager:draw()
    self.player:draw()
    self.projectileManager:draw()
end

function Level_001:unload()
    -- Cleanup: remove globals if desired
    _G.player = nil
    _G.enemyManager = nil
    _G.projectileManager = nil

    self.enemyManager = nil
    self.player = nil
end

return Level_001