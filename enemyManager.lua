-- enemyManager.lua
local EnemyManager = {}
EnemyManager.__index = EnemyManager
Enemy = require("enemy")
local Camera = require("camera")

function EnemyManager.new()
    local instance = {
        enemies = {},
        waves = {},
        currentWave = 1,
        spawnedCount = 0,
        timer = 0,
        waveCompleted = false
    }
    setmetatable(instance, EnemyManager)
    return instance
end

function EnemyManager:configure(config)
    self.waves = config.waves or {}
    self.currentWave = 1
    self.spawnedCount = 0
    self.timer = 0
    self.waveCompleted = false
end

function EnemyManager:startNextWave()
    self.currentWave = self.currentWave + 1
    self.spawnedCount = 0
    self.timer = 0
    self.waveCompleted = false
end

function EnemyManager:isWaveComplete()
    local wave = self.waves[self.currentWave]    
    return wave and self.spawnedCount >= wave.count and self.spawnedCount >= self.waves[self.currentWave].count and #self.enemies == 0
end

function EnemyManager:update(dt)
    if self:isWaveComplete() then
        if not self.waveCompleted then
            self.waveCompleted = true
            self:startNextWave()
        end
        return
    end

    self.timer = self.timer + dt
    local wave = self.waves[self.currentWave]
    
    if wave and self.spawnedCount < wave.count and self.timer >= wave.spawnTime then
        local safeX, y, w, h, speed, health = wave.pattern(self.spawnedCount)
        -- Transform the X coordinate from safe zone to actual screen position
        local screenX = Camera.transformX(safeX)
        table.insert(self.enemies, Enemy.new(screenX, y, w, h, speed, health, "easeIn", "simpleFire", "hover", "easeOut"))
        self.spawnedCount = self.spawnedCount + 1
        self.timer = 0
    end

    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]
        if e.destroyed then
            table.remove(self.enemies, i)
        else
            e:update(dt)
        end
    end
end

function EnemyManager:draw()
    for _, e in ipairs(self.enemies) do
        e:draw()
    end
end

return EnemyManager