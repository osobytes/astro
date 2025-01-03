local Camera = require("camera")

function love.conf(t)
    t.window.width = Camera.width
    t.window.height = Camera.height
    t.window.title = "Space Shooter"
    
    -- Check if debug mode is enabled
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
        t.window.fullscreen = false
    else
        t.window.fullscreen = true
        t.window.fullscreentype = "desktop"
    end
end