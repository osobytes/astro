local Background = {}
Background.__index = Background

function Background:new(name)
    local obj = setmetatable({}, self)
    obj.shader = love.graphics.newShader("shaders/" .. name .. ".glsl")
    obj.speed = 1
    obj.startTime = love.timer.getTime()
    return obj
end

function Background:setSpeed(newSpeed)
    self.speed = newSpeed
end

function Background:update(dt)
    local time = (love.timer.getTime() - self.startTime) * self.speed
    self.shader:send("u_time", time)
    self.shader:send("u_resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
end

function Background:draw()
    love.graphics.setShader(self.shader)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setShader()
end

return Background
