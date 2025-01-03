local BehaviorNames = require("behaviors.behaviorNames")

local waveConfig = {
    waves = {
        -- Wave 1: Simple line formation with default behaviors
        {
            spawnTime = 0.5,
            count = 5,
            -- Wave-level behavior configuration
            behaviors = {
                entrance = {
                    name = BehaviorNames.entrance.flyFromTop,
                    properties = {
                        speed = 150
                    }
                },
                movement = BehaviorNames.movement.hover,
                attack = {
                    name = BehaviorNames.attack.simpleFire,
                    properties = {
                        baseCooldown = 1.5
                    }
                },
                exit = {
                    name = BehaviorNames.exit.flyUp,
                }
            },
            pattern = function(i)
                return 200 + (i * 60), 100, 32, 32, 50, 10
                -- Optional: Return behavior overrides for specific enemies
                -- Example: return x, y, w, h, speed, health, {
                --     movement = {
                --         name = "sineWave",
                --         properties = { amplitude = 30 }
                --     }
                -- }
            end
        },
        -- Wave 2: V formation with sine wave movement
        {
            spawnTime = 0.5,
            count = 7,
            behaviors = {
                entrance = BehaviorNames.entrance.flyFromTop,
                movement = {
                    name = BehaviorNames.movement.sineWave,
                    properties = {
                        amplitude = 40,
                        frequency = 1.5
                    }
                },
                attack = {
                    name = BehaviorNames.attack.burstFire,
                    properties = {
                        maxBurst = 2,
                        burstCooldown = 3.0
                    }
                },
                exit = BehaviorNames.exit.flyUp
            },
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
        },
        {
            count = 10,
            spawnTime = 1,
            pattern = function(index)
                return 100 + index * 50, 50, 20, 20, 100, 10
            end
        },
        {
            count = 15,
            spawnTime = 0.5,
            pattern = function(index)
                return 200 + index * 30, 50, 20, 20, 150, 15
            end
        }
    }
}

return waveConfig