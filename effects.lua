local Effects = {}
local impacts = {}
local explosions = {}
local Camera = require("camera")

function Effects.addImpact(x, y)
    table.insert(impacts, {
        x = x,
        y = y,
        time = love.timer.getTime()
    })
end

function Effects.addExplosion(x, y)
    table.insert(explosions, {
        x = x,
        y = y,
        time = love.timer.getTime()
    })
end

function Effects.update(dt)
    local time = love.timer.getTime()
       -- Remove expired impacts and explosions
    for i = #impacts, 1, -1 do
        if time - impacts[i].time > 1.0 then  -- Example duration
            table.remove(impacts, i)
        end
    end
    for i = #explosions, 1, -1 do
        if time - explosions[i].time > 1.0 then  -- Example duration
            table.remove(explosions, i)
        end
    end
end

function Effects.draw()
    for _, impact in ipairs(impacts) do
        impactShader:send("u_time", love.timer.getTime())
        impactShader:send("u_resolution", { Camera.width, Camera.height })
        impactShader:send("u_impactPosition", { impact.x, impact.y })
        impactShader:send("u_impactTime", impact.time)
        impactShader:send("u_scale", Camera.scale)
        love.graphics.setShader(impactShader)
        love.graphics.rectangle("fill", 0, 0, Camera.width, Camera.height)
        love.graphics.setShader()
    end

    -- For explosions
    for _, explosion in ipairs(explosions) do
        explosionShader:send("u_time", love.timer.getTime())
        explosionShader:send("u_resolution", { Camera.width, Camera.height })
        explosionShader:send("u_explosionPosition", { explosion.x, explosion.y })
        explosionShader:send("u_explosionTime", explosion.time)
        explosionShader:send("u_scale", Camera.scale)
        love.graphics.setShader(explosionShader)
        love.graphics.rectangle("fill", 0, 0, Camera.width, Camera.height)
        love.graphics.setShader()
    end
end

return Effects