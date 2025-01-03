local Camera = require("camera")

function love.conf(t)
    t.window.width = Camera.width
    t.window.height = Camera.height
    t.window.title = "Space Shooter"
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"
end