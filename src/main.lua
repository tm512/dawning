require 'thing'
require 'sprite'
require 'player'
require 'level'

testMap = { }
--[[{
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 },
	{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1 },
	{ 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1 },
	{ 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
}]]--

function love.load ()
	ret = love.graphics.setMode (576, 288, false, false, 0)
	love.graphics.setCaption ("october")
	love.graphics.setColorMode ("replace")
	screen = love.graphics.newCanvas (192, 96)
	screen:setFilter ("nearest", "nearest")
	if ret == 0
	then
		error ("couldn't set screen mode")
	end

	level = Level.new ("res/bgs/cliff_bed.png", "res/levels/cliff_bed_level.png")
	testMap = level.tiles
end

local frametime = 1.0 / 60
local nextframe = 0
local curtime = 0

function love.update (dt)
	-- skip if we're running ahead
	if nextframe == 0
	then
		nextframe = dt
	end

	curtime = curtime + dt
	if curtime < nextframe
	then
		return
	end
	nextframe = nextframe + frametime

	Player:logic ()
end

drawTiles = false
function love.draw ()
	screen:setFilter ("nearest", "nearest")
	love.graphics.setCanvas (screen) -- draw to original resolution

	love.graphics.draw (level.bg, 0, 0)
	love.graphics.drawq (Player.sprite.tex, Player.sprite.quad,
	                     math.floor (Player.thing.x + Player.sprite.offsx), math.floor (Player.thing.y + Player.sprite.offsy), 0,
	                     Player.sprite:getFlip (), 1, (Player.sprite:getFlip () == -1) and Player.sprite.w or 0)
--	love.graphics.setBlendMode ("additive")
--	love.graphics.setColor (0xff, 0x00, 0x00, 0xff)
--	love.graphics.rectangle ("fill", Player.thing.x, Player.thing.y, Player.thing.w, Player.thing.h)
--	love.graphics.setBlendMode ("alpha")
	love.graphics.setColor (0xff, 0xa5, 0x00, 0xff)
	for i = 1, #testMap [1]
	do
		for j = 1, #testMap
		do
			if testMap [j] [i] == 1 and drawTiles
			then
				love.graphics.rectangle ("fill", (i - 1) * 8, (j - 1) * 8, 8, 8)
			end
		end
	end

	love.graphics.setCanvas () -- reset to full resolution
	love.graphics.draw (screen, 0, 0, 0, 3, 3)
end
