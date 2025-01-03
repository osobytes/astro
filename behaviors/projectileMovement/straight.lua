local function straight(projectile, dt)
    local angle = projectile.angle or 0
    local dx = math.cos(angle) * projectile.speed * dt
    local dy = math.sin(angle) * projectile.speed * dt
    projectile.x = projectile.x + dx
    projectile.y = projectile.y + dy
end

return straight