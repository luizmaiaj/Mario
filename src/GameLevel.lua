--[[
    GD50
    Super Mario Bros. Remake

    -- GameLevel Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameLevel = Class{}

function GameLevel:init(entities, objects, tilemap)
    self.entities = entities
    self.objects = objects
    self.tileMap = tilemap
end

--[[
    Remove all nil references from tables in case they've set themselves to nil.
]]
function GameLevel:clear()
    for i = #self.objects, 1, -1 do
        if not self.objects[i] then
            table.remove(self.objects, i)
        end
    end

    for i = #self.entities, 1, -1 do
        if not self.objects[i] then
            table.remove(self.objects, i)
        end
    end
end

function GameLevel:update(dt)
    self.tileMap:update(dt)

    for k, object in pairs(self.objects) do
        object:update(dt)
    end

    for k, entity in pairs(self.entities) do
        entity:update(dt)
    end
end

function GameLevel:render()
    self.tileMap:render()

    for k, object in pairs(self.objects) do
        object:render()
    end

    for k, entity in pairs(self.entities) do
        entity:render()
    end
end

-- set the last object of the level to be a lock
-- set the object in the middle to be the key
function GameLevel:key()
    local frame = math.random(1, 4)
    local lock = #self.objects
    local key = math.floor(lock/2)

    self.objects[key].texture = 'keys-locks'
    self.objects[key].frame = frame
    self.objects[key].collidable = true
    self.objects[key].consumable = true
    self.objects[key].solid = false
    self.objects[key].hit = true
    self.objects[key].onConsume = function(player, object)
        gSounds['pickup']:play()
        player.score = player.score + 500
        player.key = true
        return  true
    end

    self.objects[lock].texture = 'keys-locks'
    self.objects[lock].frame = frame + 4
    self.objects[lock].collidable = false
    self.objects[lock].consumable = true
    self.objects[lock].hit = false
    self.objects[lock].onConsume = function(player)
        if player.key then
            gSounds['empty-block']:play()
            return true
        end
    end

end