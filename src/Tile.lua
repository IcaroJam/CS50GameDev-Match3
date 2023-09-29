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
	-- prevent overflow when looking for quads on levels 7+
    self.variety = math.min(variety, 6)
    if self.shiny then
      self.psys = love.graphics.newParticleSystem(gTextures['glow'], 5)

      self.psys:setParticleLifetime(0.6, 2)

      self.psys:setDirection(math.pi / 2)
      self.psys:setSpeed(2, 5)

      self.psys:setColors(1, 1, 1, 1, 1, 1, 1, 0)

      self.psys:setEmissionArea('normal', 6, 6, 0, false)
    end
end

function Tile:update(dt)
    if self.shiny then
      self.psys:emit(1)
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
      love.graphics.draw(self.psys, self.x + 16 + x, self.y + 16 + y)
    end
end
