if arg[2] == "debug" then
    require("lldebugger").start()
end

local Player = require("player")
local EnemyManager = require("enemyManager")
local ProjectileManager = require("projectileManager")
local bgShader, impactShader, explosionShader
local impacts = {}
local explosions = {}
local projectileManager = {}
local enemyManager = {}
local player = {}

function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)  -- Set background color to white (RGB values are between 0 and 1)
    love.physics.setMeter(64)
    World = love.physics.newWorld(0, 0, true)
    projectileManager = ProjectileManager.new(World)
    enemyManager = EnemyManager.new(World)
    player = Player.new(World, 400, 550, 32, 32, 500, 100)

    -- set globals
    _G.player = player
    _G.projectileManager = projectileManager
    _G.enemyManager = enemyManager

    -- Load the shader
    bgShader = love.graphics.newShader("shaders/bg.glsl")
    impactShader = love.graphics.newShader("shaders/impact.glsl")
    explosionShader = love.graphics.newShader("shaders/explosion.glsl")
    _G.projectileShader = love.graphics.newShader("shaders/projectile.glsl")

    World:setCallbacks(beginContact)
end

function love.update(dt)
    World:update(dt)
    player:update(dt)
    enemyManager:update(dt)
    projectileManager:update(dt)

    -- Update the shader time uniform
    local time = love.timer.getTime()
    bgShader:send("u_time", time)
    bgShader:send("u_resolution", {love.graphics.getWidth(), love.graphics.getHeight()})

    -- Keep the ship within the screen bounds
    if _G.player.x < 0 then
        _G.player.x = 0
    elseif _G.player.x > love.graphics.getWidth() - _G.player.width then
        _G.player.x = love.graphics.getWidth() - _G.player.width
    end

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

-- Draw game objects
function love.draw()
    -- Set the shader and draw the background
    love.graphics.setShader(bgShader)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setShader()

    -- Draw game objects
    player:draw()
    enemyManager:draw()
    projectileManager:draw()

    -- For impacts
    for _, impact in ipairs(impacts) do
        impactShader:send("u_time", love.timer.getTime())
        impactShader:send("u_resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
        impactShader:send("u_impactPosition", {impact.x, impact.y})
        impactShader:send("u_impactTime", impact.time)
        love.graphics.setShader(impactShader)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
    end

    -- For explosions
    for _, explosion in ipairs(explosions) do
        explosionShader:send("u_time", love.timer.getTime())
        explosionShader:send("u_resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
        explosionShader:send("u_explosionPosition", {explosion.x, explosion.y})
        explosionShader:send("u_explosionTime", explosion.time)
        love.graphics.setShader(explosionShader)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
    end
end

function addImpact(x, y)
    table.insert(impacts, {
        x = x,
        y = y,
        time = love.timer.getTime()
    })
end

function addExplosion(x, y)
    table.insert(explosions, {
        x = x,
        y = y,
        time = love.timer.getTime()
    })
end

function beginContact(a, b, coll)
    local userDataA = a:getUserData()
    local userDataB = b:getUserData()
    local xa, ya = a:getBody():getPosition()
    local xb, yb = b:getBody():getPosition()
    if userDataA and userDataB then
        if userDataA.type == "projectile" and userDataB.type == "enemy" then
            local damage = userDataA.object:calculateDamage(userDataB.object)
            userDataB.object:takeDamage(damage)
            addImpact(xa, ya)
            userDataA.object:destroy()
        elseif userDataA.type == "enemy" and userDataB.type == "projectile" then
            local damage = userDataB.object:calculateDamage(userDataA.object)
            userDataA.object:takeDamage(damage)
            addImpact(xb, yb)
            userDataB.object:destroy()
        elseif userDataA.type == "projectile" and userDataB.type == "player" then
            local damage = userDataA.object:calculateDamage(userDataB.object)
            userDataB.object:takeDamage(damage)
            addImpact(xa, ya)
            userDataA.object:destroy()
        elseif userDataA.type == "player" and userDataB.type == "projectile" then
            local damage = userDataB.object:calculateDamage(userDataA.object)
            userDataA.object:takeDamage(damage)
            addImpact(xb, yb)
            userDataB.object:destroy()
        end
    end
end