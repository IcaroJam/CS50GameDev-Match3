--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- is this a shiny tile?
    self.shiny = math.random(20) == 1

    -- tile appearance/points
    self.color = color
    self.variety = variety
    if self.shiny then
      self.psys = love.graphics.newParticleSystem(gTextures['glow'], 7)

      self.psys:setParticleLifetime(0.7, 1.2)

      self.psys:setLinearAcceleration(0, 1, 0, 5)

      self.psys:setEmissionArea('normal', 14, 14)
    end
end

function Tile:update(dt)
    if self.shiny then
      self.psys:emit(7)
      self.psys:update(dt)
    end
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    -- draw particles if shiny
    if self.shiny then
      love.graphics.draw(self.psys, self.x + 10 + x, self.y + 10 + y)
    end
end
