local function sine(projectile, dt)
    projectile.time = (projectile.time or 0) + dt
    local angle = projectile.angle or 0
    local amplitude = 100
    local frequency = 2
    local dx = math.cos(angle) * projectile.speed
    local dy = math.sin(angle) * projectile.speed + 
               amplitude * math.sin(frequency * projectile.time)
    projectile.x = projectile.x + dx * dt
    projectile.y = projectile.y + dy * dt
end
return sine