local DESIGN_WIDTH = 1920
local DESIGN_HEIGHT = 1080
-- Add safe zone constants
local SAFE_ZONE_WIDTH = 1600
local SAFE_ZONE_MARGIN = (DESIGN_WIDTH - SAFE_ZONE_WIDTH) / 2

local Camera = {}
Camera.width = DESIGN_WIDTH
Camera.height = DESIGN_HEIGHT

-- We'll store the "scale" that maps from (DESIGN_WIDTH, DESIGN_HEIGHT)
-- to (actualWidth, actualHeight).
-- We'll also store how much "extra" width is visible when you have a wider screen.

Camera.scale = 1
Camera.extraWidth = 0

function Camera.updateViewport(actualWidth, actualHeight)
    -- The main anchor is to keep the same height ratio:
    Camera.scale = actualHeight / DESIGN_HEIGHT
    
    -- The scaled width if we only scale by "height ratio":
    local scaledWidth = DESIGN_WIDTH * Camera.scale
    
    if scaledWidth <= actualWidth then
        -- The screen is wide enough to show "extra space" on the sides.
        Camera.extraWidth = actualWidth - scaledWidth
    else
        -- This would mean the screen is narrower than our reference ratio
        -- (less common in 16:9-based designs, but can happen).
        -- In that case, maybe anchor on width or letterbox. 
        -- But let's assume for now we never stretch the sprites, 
        -- so we handle it similarly:
        Camera.scale = actualWidth / DESIGN_WIDTH
        Camera.scaledHeight = DESIGN_HEIGHT * Camera.scale
        Camera.extraWidth = 0 
        -- or you do letterbox if you prefer.
    end
end

-- Add coordinate transformation functions
function Camera.transformX(safeX)
    -- Convert safe zone coordinate to actual screen coordinate
    local actualX = safeX + SAFE_ZONE_MARGIN
    -- Account for extra width from wider screens
    return actualX + (Camera.extraWidth / 2)
end

function Camera.transformY(safeY)
    -- Y coordinates don't need horizontal safe zone adjustment
    return safeY
end

function Camera.getSafeZoneWidth()
    return SAFE_ZONE_WIDTH
end

return Camera