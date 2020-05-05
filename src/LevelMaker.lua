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
    self.blockheight = 0
    self.lastblockheight = 0
    self.lastblock = false
    self.gradient = 0
end

function LevelMaker:generate(width, height)

    self.width = width
    self.height = height

    print('--------------------------------------------------')
    print('LevelMaker:generate width: ' .. width .. ' height: ' .. height)

    -- insert blank tables into tiles for later access
    for y = 1, height do
        table.insert(self.tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local middle = x > 3 and x < (width - 3)

        self:floor(x, middle)

        self.lastblock = false
        if math.random(6) == 1 and middle and self.blockheight < self.height and self.gradient > -1 then -- reduced from 10 to 6
            self.lastblock = true
            self:block(x)
        end
    end

    local map = TileMap(width, height)
    map.tiles = self.tiles
    
    return GameLevel(self.entities, self.objects, map, self.width, self.height)
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

    self.blockheight = middle == true and math.random(4, self.height) or math.random(4, self.height - 1)
    self.gradient = self.lastblockheight - self.blockheight

    if math.abs(self.gradient) > 3 and self.blockheight ~= self.height then -- avoid high walls
        self.blockheight = self.lastblockheight + (self.gradient > 0 and -3 or 3)
    end
    
    if self.lastblock and self.blockheight == (self.lastblockheight + 1) then -- avoid block in middle of stair
        self.blockheight = self.blockheight - 1
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

    print('LevelMaker:block: ' .. (self.blockheight - 4) * TILE_SIZE)

    local block = GameObject {
        texture = 'jump-blocks',
        x = (x - 1) * TILE_SIZE,
        y = (self.blockheight - 4) * TILE_SIZE,
        width = TILE_SIZE,
        height = TILE_SIZE,
        frame = math.random(#JUMP_BLOCKS), -- make it a random variant
        collidable = true,
        hit = false,
        solid = true,
        nil
    }

    block.onCollide = function(obj) -- collision function takes itself

        -- spawn a gem if we haven't already hit the block
        if not obj.hit then
            if math.random(3) == 1 then -- chance to spawn gem, not guaranteed
                self:gem(x, block.y )
            end

            obj.hit = true
        end

        gSounds['empty-block']:play()
    end

    table.insert(self.objects, block)
end

function LevelMaker:gem(x, ref)
    print('LevelMaker:gem: ' .. ref)
    local gem = GameObject {
        texture = 'gems',
        x = (x - 1) * TILE_SIZE,
        y = ref - TILE_SIZE,
        width = TILE_SIZE,
        height = TILE_SIZE,
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
    print('LevelMaker:gem: ' .. (gem.y - TILE_SIZE))
    Timer.tween(0.1, { [gem] = {y = gem.y - TILE_SIZE} })
    gSounds['powerup-reveal']:play()

    table.insert(self.objects, gem)
end