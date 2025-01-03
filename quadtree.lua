local Quadtree = {}
Quadtree.__index = Quadtree

-- Constructor
--   x, y, width, height: define the bounding rectangle of this Quadtree node
--   maxObjects: how many objects to store before splitting
--   maxLevels: max depth of the quadtree
--   level: current depth level (0 = root)
function Quadtree.new(x, y, width, height, maxObjects, maxLevels, level)
    local self = setmetatable({}, Quadtree)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.maxObjects = maxObjects or 10
    self.maxLevels  = maxLevels or 5
    self.level      = level or 0

    -- Objects directly in this node
    self.objects = {}

    -- Child nodes (four subdivisions)
    self.nodes = {}

    return self
end

-- Clear the quadtree recursively
function Quadtree:clear()
    self.objects = {}
    for i = 1, #self.nodes do
        self.nodes[i]:clear()
    end
    self.nodes = {}
end

-- Split this node into four child nodes
function Quadtree:split()
    local subWidth  = self.width  / 2
    local subHeight = self.height / 2
    local x = self.x
    local y = self.y

    self.nodes[1] = Quadtree.new(x,            y,            subWidth, subHeight, self.maxObjects, self.maxLevels, self.level+1)
    self.nodes[2] = Quadtree.new(x + subWidth, y,            subWidth, subHeight, self.maxObjects, self.maxLevels, self.level+1)
    self.nodes[3] = Quadtree.new(x,            y + subHeight, subWidth, subHeight, self.maxObjects, self.maxLevels, self.level+1)
    self.nodes[4] = Quadtree.new(x + subWidth, y + subHeight, subWidth, subHeight, self.maxObjects, self.maxLevels, self.level+1)
end

-- Determine which child node the object belongs to.
-- Return:
--   -1 if it does not completely fit within a child node (meaning it might still fit in this node).
--    1..4 for the index of the child node if it fully fits in one node.
function Quadtree:getIndex(obj)
    local midX = self.x + (self.width  / 2)
    local midY = self.y + (self.height / 2)

    local left   = obj.x
    local right  = obj.x + obj.width
    local top    = obj.y
    local bottom = obj.y + obj.height

    local fitsTop    = (top    < midY and bottom < midY)
    local fitsBottom = (top    >= midY)
    local fitsLeft   = (left   < midX and right  < midX)
    local fitsRight  = (left   >= midX)

    -- top-left
    if fitsTop and fitsLeft then
        return 1
    -- top-right
    elseif fitsTop and fitsRight then
        return 2
    -- bottom-left
    elseif fitsBottom and fitsLeft then
        return 3
    -- bottom-right
    elseif fitsBottom and fitsRight then
        return 4
    else
        return -1
    end
end

-- Insert an object into the quadtree
function Quadtree:insert(obj)
    -- If we have children, see if the object fits in one child
    if #self.nodes > 0 then
        local index = self:getIndex(obj)
        if index ~= -1 then
            self.nodes[index]:insert(obj)
            return
        end
    end

    -- Otherwise, store the object in this node
    table.insert(self.objects, obj)

    -- If we've exceeded capacity and haven't reached max depth, split if needed
    if #self.objects > self.maxObjects and self.level < self.maxLevels and #self.nodes == 0 then
        self:split()

        -- Re-insert objects that fit into children
        local i = 1
        while i <= #self.objects do
            local index = self:getIndex(self.objects[i])
            if index ~= -1 then
                local moveObj = table.remove(self.objects, i)
                self.nodes[index]:insert(moveObj)
            else
                i = i + 1
            end
        end
    end
end

-- Retrieve all objects that might collide with 'obj'
function Quadtree:retrieve(returnList, obj)
    -- If we have children, figure out which node(s) to retrieve from
    if #self.nodes > 0 then
        local index = self:getIndex(obj)
        if index ~= -1 then
            self.nodes[index]:retrieve(returnList, obj)
        else
            -- If it doesn't fit in a child node, we need to retrieve from all children
            for i=1, #self.nodes do
                self.nodes[i]:retrieve(returnList, obj)
            end
        end
    end

    -- Also add all objects from this node
    for i = 1, #self.objects do
        table.insert(returnList, self.objects[i])
    end

    return returnList
end

return Quadtree