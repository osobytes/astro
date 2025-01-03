if arg[2] == "debug" then
    require("lldebugger").start()
end

local SceneManager = require("sceneManager")
local sceneManager = SceneManager:new()
local Effects = require("effects")

local Background = require("background")

function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)  -- Set background color to white (RGB values are between 0 and 1)

    -- Load the shader
    _G.impactShader = love.graphics.newShader("shaders/impact.glsl")
    _G.explosionShader = love.graphics.newShader("shaders/explosion.glsl")
    _G.projectileShader = love.graphics.newShader("shaders/projectile.glsl")

    sceneManager:addScene("level_001", require("levels.level_001"))

    sceneManager:loadScene("level_001")

    _G.background = Background:new("bg")  -- Example shader name
end

function love.update(dt)
    sceneManager:update(dt)
    Effects.update(dt)
    if _G.background then
        _G.background:update(dt)
    end
end

-- Draw game objects
function love.draw()
    if _G.background then
        _G.background:draw()
    end

    -- Draw game objects
    sceneManager:draw()
    Effects.draw()
end