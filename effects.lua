local Effects = {}
local impacts = {}
local explosions = {}

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
        impactShader:send("u_resolution", { love.graphics.getWidth(), love.graphics.getHeight() })
        impactShader:send("u_impactPosition", { impact.x, impact.y })
        impactShader:send("u_impactTime", impact.time)
        love.graphics.setShader(impactShader)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
    end

    -- For explosions
    for _, explosion in ipairs(explosions) do
        explosionShader:send("u_time", love.timer.getTime())
        explosionShader:send("u_resolution", { love.graphics.getWidth(), love.graphics.getHeight() })
        explosionShader:send("u_explosionPosition", { explosion.x, explosion.y })
        explosionShader:send("u_explosionTime", explosion.time)
        love.graphics.setShader(explosionShader)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
    end
end

return Effects