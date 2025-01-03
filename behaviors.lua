local Behaviors = {}

Behaviors.getBehavior = function(behaviorName)
    local path = string.format("behaviors.%s", behaviorName)
    return require(path)
end

return Behaviors