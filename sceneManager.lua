-- scene_manager.lua
local SceneManager = {}
SceneManager.__index = SceneManager

function SceneManager:new()
    local instance = {
        scenes = {},
        currentScene = nil,
        player = nil,
        enemyManager = nil
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
    if self.currentScene and self.currentScene.update then
        self.currentScene:update(dt)
    end
end

function SceneManager:draw()
    if self.currentScene and self.currentScene.draw then
        self.currentScene:draw()
    end
end

return SceneManager