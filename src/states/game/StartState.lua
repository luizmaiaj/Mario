--[[
    GD50
    Super Mario Bros. Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

StartState = Class{__includes = BaseState}

function StartState:init()
    local level = LevelMaker()
    self.map = level:generate(math.floor(VIRTUAL_WIDTH/TILE_SIZE), math.floor(VIRTUAL_HEIGHT/TILE_SIZE) + 1)
    self.background = math.random(3)

    print('StartState:init width: ' .. self.map.width .. ' height: ' .. self.map.height)
end

function StartState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        print('StartState:update width: ' .. self.map.width .. ' height: ' .. self.map.height)
        gStateMachine:change('play', {width = self.map.width, height = self.map.height, level = 0, score = 0})
    end
end

function StartState:render()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, gTextures['backgrounds']:getHeight(), 0, 1, -1)
    
    --bg to the right
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 256, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 256, gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 256, gTextures['backgrounds']:getHeight(), 0, 1, -1)
    
    --bg to the right 2
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 512, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 512, gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 512, gTextures['backgrounds']:getHeight(), 0, 1, -1)

    self.map:render()

    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf('Super 50 Bros.', 1, VIRTUAL_HEIGHT / 2 - 40 + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('Super 50 Bros.', 0, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf('Press Enter', 1, VIRTUAL_HEIGHT / 2 + 17, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 16, VIRTUAL_WIDTH, 'center')
end