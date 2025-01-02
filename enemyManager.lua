local Enemy = require("enemy")
local Behaviors = require("behaviors")

local EnemyManager = {}
EnemyManager.__index = EnemyManager

function EnemyManager.new(world)
    local self = setmetatable({}, EnemyManager)
    self.world = world
    self.enemies = {}
    self.waves = {
        -- Wave 1: Simple line formation
        {
            spawnTime = 0.5,
            count = 5,
            pattern = function(i)
                return 200 + (i * 60), 100, 32, 32, 50, 10
            end
        },
        -- Wave 2: V formation
        {
            spawnTime = 0.5,
            count = 7,
            pattern = function(i)
                return 300 + (i * 50 - 150), 80 + math.abs(i * 30 - 90), 32, 32, 60, 15
            end
        },
        -- Wave 3: Diamond formation with faster enemies
        {
            spawnTime = 0.5,
            count = 9,
            pattern = function(i)
                local centerX = love.graphics.getWidth() / 2
                local offset = math.min(i, 8-i) * 40
                return centerX + offset, 100 + math.abs(i * 40 - 160), 32, 32, 70, 20
            end
        }
    }
    self.currentWave = 1
    self.timer = 0
    self.spawnedCount = 0
    return self
end

function EnemyManager:isWaveComplete()
    return self.spawnedCount >= self.waves[self.currentWave].count and #self.enemies == 0
end

function EnemyManager:startNextWave()
    if self.currentWave < #self.waves then
        self.currentWave = self.currentWave + 1
        self.spawnedCount = 0
        self.timer = 0
        self.waveCompleted = false
    end
end

function EnemyManager:update(dt)
    -- Check if current wave is complete
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
        local x, y, w, h, speed, health = wave.pattern(self.spawnedCount)
        table.insert(self.enemies, Enemy.new(self.world, x, y, w, h, speed, health, "easeIn", "simpleFire", "hover", "easeOut"))
        self.spawnedCount = self.spawnedCount + 1
        self.timer = 0
    end

    -- Update all enemies
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