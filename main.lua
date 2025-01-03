if arg[2] == "debug" then
    require("lldebugger").start()
end

local SceneManager = require("sceneManager")
local sceneManager = SceneManager:new()
local Effects = require("effects")
local Camera = require("camera")

local Background = require("background")

love.keyboard.keysPressed = {}

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)  -- Set background color to white (RGB values are between 0 and 1)

    -- Load the shader
    _G.impactShader = love.graphics.newShader("shaders/impact.glsl")
    _G.explosionShader = love.graphics.newShader("shaders/explosion.glsl")
    _G.projectileShader = love.graphics.newShader("shaders/projectile.glsl")

    sceneManager:addScene("level_001", require("levels.level_001"))
    sceneManager:loadScene("level_001")

    _G.background = Background:new("bg")
end

function love.update(dt)
    sceneManager:update(dt)
    Effects.update(dt)
    if _G.background then
        _G.background:update(dt)
    end

    -- Reset keys pressed
    love.keyboard.keysPressed = {}
end

-- Draw game objects
function love.draw()
    love.graphics.push()

    -- Translate so that your main "game area" is centered horizontally
    -- extraWidth is how many *pixels* of empty space we have after scaling.
    local offsetX = Camera.extraWidth / 2
    love.graphics.translate(offsetX, 0)

    -- Scale uniformly by our "scale"
    love.graphics.scale(Camera.scale, Camera.scale)
    drawGame()
    love.graphics.pop()
end

function drawGame()
    if _G.background then
        _G.background:draw()
    end

    -- Draw game objects
    sceneManager:draw()
    Effects.draw()
end