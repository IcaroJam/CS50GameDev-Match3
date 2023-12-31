--[[
	GD50
	Match-3 Remake

	-- Board Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu

	The Board is our arrangement of Tiles with which we must try to find matching
	sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
	self.x = x
	self.y = y
	self.level = level
	self.matches = {}

	self:initializeTiles()
end

function Board:initializeTiles()
	self.tiles = {}

	for tileY = 1, 8 do

		-- empty table that will serve as a new row
		table.insert(self.tiles, {})

		for tileX = 1, 8 do

			-- create a new tile at X,Y with a random color and variety
			table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(9, 16), math.random(self.level)))
		end
	end

	while self:calculateMatches() do

		-- recursively initialize if matches were returned so we always have
		-- a matchless board on start
		self:initializeTiles()
	end
end

--[[
	Goes left to right, top to bottom in the board, calculating matches by counting consecutive
	tiles of the same color. Doesn't need to check the last tile in every row or column if the
	last two haven't been a match.
]]
function Board:calculateMatches()
	local matches = {}

	-- how many of the same color blocks in a row we've found
	local matchNum = 1

	-- flag to check if a shiny tile was matched
	local shinyHit = false

	-- horizontal matches first
	for y = 1, 8 do
		local colorToMatch = self.tiles[y][1].color

		local tmpx

		matchNum = 1
		shinyHit = self.tiles[y][1].shiny

		-- every horizontal tile
		for x = 2, 8 do
			-- if this is the same color as the one we're trying to match...
			if self.tiles[y][x].color == colorToMatch then
				matchNum = matchNum + 1
				-- is the current tile shiny?
				if self.tiles[y][x].shiny then
					shinyHit = true
				end
			else

				-- set this as the new color we want to watch for
				colorToMatch = self.tiles[y][x].color

				-- if we have a match of 3 or more up to now, add it to our matches table
				if matchNum >= 3 then
					local match = {}

					if shinyHit then
						matchNum = 8
						tmpx = 9
						shinyHit = false
					else
						tmpx = x
					end

					-- go backwards from here by matchNum
					for x2 = tmpx - 1, tmpx - matchNum, -1 do

						-- add each tile to the match that's in that match
						table.insert(match, self.tiles[y][x2])
					end

					-- add this match to our total matches table
					table.insert(matches, match)
				end

				matchNum = 1
				shinyHit = self.tiles[y][x].shiny

				-- don't need to check last two if they won't be in a match
				if x >= 7 then
					break
				end
			end
		end

		-- account for the last row ending with a match
		if matchNum >= 3 then
			local match = {}

			if shinyHit then
				matchNum = 8
				shinyHit = false
			end

			-- go backwards from end of last row by matchNum
			for x = 8, 8 - matchNum + 1, -1 do
				table.insert(match, self.tiles[y][x])
			end

			table.insert(matches, match)
		end
	end

	-- vertical matches
	for x = 1, 8 do
		local colorToMatch = self.tiles[1][x].color

		local tmpy

		matchNum = 1
		shinyHit = self.tiles[1][x].shiny

		-- every vertical tile
		for y = 2, 8 do
			if self.tiles[y][x].color == colorToMatch then
				matchNum = matchNum + 1
				-- is the current tile shiny?
				if self.tiles[y][x].shiny then
					shinyHit = true
				end
			else
				colorToMatch = self.tiles[y][x].color

				if matchNum >= 3 then
					local match = {}

					if shinyHit then
						matchNum = 8
						tmpy = 9
						shinyHit = false
					else
						tmpy = y
					end

					for y2 = tmpy - 1, tmpy - matchNum, -1 do
						table.insert(match, self.tiles[y2][x])
					end

					table.insert(matches, match)
				end

				matchNum = 1
				shinyHit = self.tiles[y][x].shiny

				-- don't need to check last two if they won't be in a match
				if y >= 7 then
					break
				end
			end
		end

		-- account for the last column ending with a match
		if matchNum >= 3 then
			local match = {}

			if shinyHit then
				matchNum = 8
				shinyHit = false
			end

			-- go backwards from end of last row by matchNum
			for y = 8, 8 - matchNum + 1, -1 do
				table.insert(match, self.tiles[y][x])
			end

			table.insert(matches, match)
		end
	end

	-- store matches for later reference
	self.matches = matches

	-- return matches table if > 0, else just return false
	return #self.matches > 0 and self.matches or false
end

--[[
	Remove the matches from the Board by just setting the Tile slots within
	them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
	for k, match in pairs(self.matches) do
		-- if the match is a full row/col one, play explosion sound
		if #match == 8 then
			gSounds['shinyexplosion']:play()
		end
		for k, tile in pairs(match) do
			self.tiles[tile.gridY][tile.gridX] = nil
		end
	end

	self.matches = nil
end

--[[
	Shifts down all of the tiles that now have spaces below them, then returns a table that
	contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
	-- tween table, with tiles as keys and their x and y as the to values
	local tweens = {}

	-- for each column, go up tile by tile till we hit a space
	for x = 1, 8 do
		local space = false
		local spaceY = 0

		local y = 8
		while y >= 1 do

			-- if our last tile was a space...
			local tile = self.tiles[y][x]

			if space then

				-- if the current tile is *not* a space, bring this down to the lowest space
				if tile then

					-- put the tile in the correct spot in the board and fix its grid positions
					self.tiles[spaceY][x] = tile
					tile.gridY = spaceY

					-- set its prior position to nil
					self.tiles[y][x] = nil

					-- tween the Y position to 32 x its grid position
					tweens[tile] = {
						y = (tile.gridY - 1) * 32
					}

					-- set Y to spaceY so we start back from here again
					space = false
					y = spaceY

					-- set this back to 0 so we know we don't have an active space
					spaceY = 0
				end
			elseif tile == nil then
				space = true

				-- if we haven't assigned a space yet, set this to it
				if spaceY == 0 then
					spaceY = y
				end
			end

			y = y - 1
		end
	end

	-- create replacement tiles at the top of the screen
	for x = 1, 8 do
		for y = 8, 1, -1 do
			local tile = self.tiles[y][x]

			-- if the tile is nil, we need to add a new one
			if not tile then

				-- new tile with random color and variety
				local tile = Tile(x, y, math.random(9, 16), math.random(self.level))
				tile.y = -32
				self.tiles[y][x] = tile

				-- create a new tween to return for this tile to fall down
				tweens[tile] = {
					y = (tile.gridY - 1) * 32
				}
			end
		end
	end

	return tweens
end

function Board:update(dt)
	for y = 1, #self.tiles do
		for x = 1, #self.tiles[1] do
			self.tiles[y][x]:update(dt)
		end
	end
end

function Board:render()
	for y = 1, #self.tiles do
		for x = 1, #self.tiles[1] do
			self.tiles[y][x]:render(self.x, self.y)
		end
	end
end

--[[
	Check if there are any possible matches, refresh the board if there aren't.
]]
function Board:checkStaleBoard()
	local swap = function(x1, y1, x2, y2)
		local tmpTile = self.tiles[y1][x1]
		local tmpX = tmpTile.gridX
		local tmpY = tmpTile.gridY

		tmpTile.gridX = self.tiles[y2][x2].gridX
		tmpTile.gridY = self.tiles[y2][x2].gridY
		self.tiles[y2][x2].gridX = tmpX
		self.tiles[y2][x2].gridY = tmpY

		self.tiles[y1][x1] = self.tiles[y2][x2]
		self.tiles[y2][x2] = tmpTile
	end

	for y = 1, 8, 1 do
		for x = 1, 8, 1 do
			-- watch out for rightmost column corner case!
			if x < 8 then
				-- swap current tile with the one to its right
				swap(x, y, x + 1, y)
				-- check if this led to a match
				if self:calculateMatches() then
					-- swap back
					swap(x, y, x + 1, y)
					-- if it did return
					print("Matches found", x, y)
					return
				end
				-- swap back
				swap(x, y, x + 1, y)
			end
			-- watch out for bottom row corner case!
			if y < 8 then
				-- swap current tile with the one under it
				swap(x, y, x, y + 1)
				-- check if this led to a match
				if self:calculateMatches() then
					-- swap back
					swap(x, y, x, y + 1)
					-- if it did return
					print("Matches found", x, y)
					return
				end
				-- swap back
				swap(x, y, x, y + 1)
			end
		end
	end

	-- if no possible matches were found, reinitialize the tiles and check again
	print("No matches found")
	self:initializeTiles()
	self:checkStaleBoard()
end
