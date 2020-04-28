--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker:init()
    self.level = 1

    self.tiles = {}
    self.entities = {}
    self.objects = {}
    self.tileset = math.random(20)
    self.topperset = math.random(20)
end

function LevelMaker:generate(width, height)

    self.width = width
    self.height = height
    self.blockheight = 0
    self.lastblockheight = 0

    -- insert blank tables into tiles for later access
    for y = 1, height do
        table.insert(self.tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local middle = x > 3 and x < (width - 3)

        self:floor(x, middle)

        -- chance to spawn a block
        if math.random(8) == 1 and middle and self.blockheight < self.height then -- reduced from 10 to 9
            self:block(x)
        end
    end

    local map = TileMap(width, height)
    map.tiles = self.tiles
    
    return GameLevel(self.entities, self.objects, map, width)
end

function LevelMaker:bush(x)
    table.insert(self.objects,
        GameObject {
            texture = 'bushes',
            x = (x - 1) * TILE_SIZE,
            y = (self.blockheight - 2) * TILE_SIZE,
            width = 16,
            height = 16,
            
            -- select random frame from bush_ids whitelist, then random row for variance
            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
            collidable = false
        }
    )
end

function LevelMaker:floor(x, middle)

    self.blockheight = middle == true and math.random(5, self.height) or 7

    if (self.lastblockheight - self.blockheight) > 3 then -- avoid high walls
        self.blockheight = self.blockheight + 1
    end

    self.lastblockheight = self.blockheight

    for y = 1, self.height do
        local tileID = (y < self.blockheight or y == self.height) and TILE_ID_EMPTY or TILE_ID_GROUND
        local topper = y == self.blockheight
        
        table.insert(self.tiles[y], Tile(x, y, tileID, topper, self.tileset, self.topperset))
    end

    -- chance to generate bushes
    if math.random(4) == 1 and middle and self.blockheight < self.height then
        self:bush(x)
    end
    
end

function LevelMaker:block(x)
    table.insert(self.objects,
        -- jump block
        GameObject {
            texture = 'jump-blocks',
            x = (x - 1) * TILE_SIZE,
            y = (self.blockheight - 4) * TILE_SIZE,
            width = 16,
            height = 16,

            -- make it a random variant
            frame = math.random(#JUMP_BLOCKS),
            collidable = true,
            hit = false,
            solid = true,

            -- collision function takes itself
            onCollide = function(obj)

                -- spawn a gem if we haven't already hit the block
                if not obj.hit then

                    -- chance to spawn gem, not guaranteed
                    if math.random(5) == 1 then
                        self:gem(x)
                    end

                    obj.hit = true
                end

                gSounds['empty-block']:play()
            end
        }
    )
end

function LevelMaker:gem(x)
    -- maintain reference so we can set it to nil
    local gem = GameObject {
        texture = 'gems',
        x = (x - 1) * TILE_SIZE,
        y = (self.blockheight - 4) * TILE_SIZE - 4,
        width = 16,
        height = 16,
        frame = math.random(#GEMS),
        collidable = true,
        consumable = true,
        solid = false,

        -- gem has its own function to add to the player's score
        onConsume = function(player)
            gSounds['pickup']:play()
            player.score = player.score + 100
            return true
        end
    }
    
    -- make the gem move up from the block and play a sound
    Timer.tween(0.1, { [gem] = {y = (self.blockheight - 5) * TILE_SIZE} })
    gSounds['powerup-reveal']:play()

    table.insert(self.objects, gem)
end