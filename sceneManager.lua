-- scene_manager.lua
local SceneManager = {}
SceneManager.__index = SceneManager

function SceneManager:new()
    local instance = {
        scenes = {},
        currentScene = nil,
        player = nil,
        enemyManager = nil,
        isPaused = false,
        menuItems = {
            {text = "Resume", action = function(self) self.isPaused = false end},
            {text = "Restart Level", action = function(self) 
                self.isPaused = false
                if self.currentScene and self.currentScene.load then
                    self.currentScene:load(self)
                end
            end},
            {text = "Exit Game", action = function() love.event.quit() end}
        },
        selectedMenuItem = 1
    }
    setmetatable(instance, SceneManager)
    return instance
end

function SceneManager:loadScene(sceneName)
    if self.currentScene and self.currentScene.unload then
        self.currentScene:unload()
    end
    self.currentScene = self.scenes[sceneName]
    if self.currentScene and self.currentScene.load then
        self.currentScene:load(self)
    end
end

function SceneManager:addScene(sceneName, scene)
    self.scenes[sceneName] = scene
end

function SceneManager:update(dt)
    if self.isPaused then
        -- Handle menu input
        if love.keyboard.wasPressed('up') then
            self.selectedMenuItem = math.max(1, self.selectedMenuItem - 1)
        elseif love.keyboard.wasPressed('down') then
            self.selectedMenuItem = math.min(#self.menuItems, self.selectedMenuItem + 1)
        elseif love.keyboard.wasPressed('return') or love.keyboard.wasPressed('space') then
            self.menuItems[self.selectedMenuItem].action(self)
        end
    elseif self.currentScene and self.currentScene.update then
        self.currentScene:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        self.isPaused = not self.isPaused
    end
end

function SceneManager:draw()
    if self.currentScene and self.currentScene.draw then
        self.currentScene:draw()
    end

    if self.isPaused then
        -- Draw semi-transparent background
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        -- Draw menu items
        love.graphics.setColor(1, 1, 1, 1)
        local menuX = love.graphics.getWidth() / 2
        local menuY = love.graphics.getHeight() / 2 - (#self.menuItems * 30)
        
        for i, item in ipairs(self.menuItems) do
            local text = item.text
            if i == self.selectedMenuItem then
                text = "> " .. text .. " <"
            end
            love.graphics.printf(text, menuX - 100, menuY + (i-1) * 60, 200, "center")
        end
    end
end

return SceneManager