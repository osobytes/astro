local function spiral(projectile, dt)
    projectile.time = (projectile.time or 0) + dt
    local radius = 50
    local angularSpeed = 5
    local dx = radius * math.cos(projectile.time * angularSpeed)
    local dy = projectile.speed * dt
    projectile.x = projectile.x + dx * dt
    projectile.y = projectile.y + dy
end
return spiral