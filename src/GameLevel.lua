--[[
    GD50
    Super Mario Bros. Remake

    -- GameLevel Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameLevel = Class{}

function GameLevel:init(entities, objects, tilemap, width, height)
    self.entities = entities
    self.objects = objects
    self.tileMap = tilemap
    self.width = width
    self.height = height
    self.keyframe = math.random(1, 4)
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
    local lock = #self.objects
    local key = math.max(math.floor(lock/2), 1)

    self.objects[key].texture = 'keys-locks'
    self.objects[key].frame = self.keyframe
    self.objects[key].collidable = true
    self.objects[key].consumable = true
    self.objects[key].solid = false
    self.objects[key].hit = true
    self.objects[key].onConsume = function(player)
        gSounds['pickup']:play()
        player.score = player.score + 500
        player.key = true
        return  true
    end

    local sortframes = 7 + (math.random(0, 3) * 9)
    local flagframes = {sortframes, sortframes + 1}

    --find floor level to put pole
    local floorheight = 0
    for y = 1, self.height do
        if self.tileMap.tiles[y][self.width - 1].id == TILE_ID_GROUND then
            floorheight = (self.tileMap.tiles[y][self.width - 1].y - 4) * TILE_SIZE
            break
        end
    end

    self.objects[lock].texture = 'keys-locks'
    self.objects[lock].frame = self.keyframe + 4
    self.objects[lock].collidable = false
    self.objects[lock].consumable = true
    self.objects[lock].solid = false
    self.objects[lock].hit = false
    self.objects[lock].onConsume = function(player)
        if player.key then
            local pole = GameObject {
                texture = 'poles',
                x = TILE_SIZE * (self.width - 2),
                y = floorheight,
                width = TILE_SIZE,
                height = floorheight,
                frame = math.random(6),
                collidable = false,
                consumable = true,
                solid = false,
                onConsume = function(player) -- when the player reaches the pole
                    gSounds['pickup']:play()
                    player.score = player.score + 1000
                    gStateMachine:change('play', {width = self.width, height = self.height, level = player.levelnumber + 1, score = player.score})
                    return false
                end
            }

            local flag = GameObject {
                texture = 'flags',
                x = (TILE_SIZE * (self.width - 2)) + 8,
                y = floorheight,
                width = TILE_SIZE,
                height = TILE_SIZE,
                frame = 7,
                collidable = false,
                consumable = false,
                solid = false,
                animation = Animation { frames = flagframes, interval = 0.2 }
            }
            
            gSounds['powerup-reveal']:play()

            table.insert(self.objects, pole)
            table.insert(self.objects, flag)

            gSounds['empty-block']:play()
            return true
        end
    end

end