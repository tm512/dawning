require 'thing'
require 'sprite'
require 'player'
require 'monster'
require 'level'

function genOverlay (w, h)
	local data = love.image.newImageData (w, h)

	for x = 0, w - 1
	do
		for y = 0, h - 1
		do
			if x % 4 == 0 or y % 4 == 0
			then
				data:setPixel (x, y, 0, 0, 0, 64)
			else
				data:setPixel (x, y, 0, 0, 0, 0)
			end
		end
	end

	return love.graphics.newImage (data)
end

function genStatic (w, h)
	local data = love.image.newImageData (w, h)

	for x = 0, w - 1
	do
		for y = 0, h - 1
		do
			local val = math.random (0, 255)
			data:setPixel (x, y, val, val, val, 255)
		end
	end

	return love.graphics.newImage (data)
end

static = { }
function love.load ()
	ret = love.graphics.setMode (768, 386, false, false, 0)
	love.graphics.setCaption ("october")
	love.graphics.setColorMode ("replace")
	if ret == 0
	then
		error ("couldn't set screen mode")
	end

	screen = love.graphics.newCanvas (192, 96)
	screen:setFilter ("nearest", "nearest")

	overlay = genOverlay (768, 386)

	for i = 1, 64
	do
		table.insert (static, genStatic (192, 96))
	end

	curlevel = Level.new (startlevel)
	monster = love.graphics.newImage ("res/objects/npc/monster.png")
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
	Monster:logic ()
end

drawDebug = false
staticIndx = 0
function love.draw ()
	screen:setFilter ("nearest", "nearest")
	love.graphics.setCanvas (screen) -- draw to original resolution
	love.graphics.push ()

	-- camera
	if curlevel.bg:getWidth () > 192
	then
		if Player.thing.x > 96 and Player.thing.x < curlevel.bg:getWidth () - 96
		then
			love.graphics.translate (-math.floor (Player.thing.x - 96), 0)
		elseif Player.thing.x > curlevel.bg:getWidth () - 96
		then
			love.graphics.translate (-math.floor (curlevel.bg:getWidth () - 192), 0)
		end
	end

	love.graphics.draw (curlevel.bg, 0, 0)
	love.graphics.drawq (Player.sprite.tex, Player.sprite.quad,
	                     math.floor (Player.thing.x + Player.sprite.offsx), math.floor (Player.thing.y + Player.sprite.offsy), 0,
	                     Player.sprite:getFlip (), 1, (Player.sprite:getFlip () == -1) and Player.sprite.w or 0)
	if Monster.visible
	then
		love.graphics.drawq (Monster.sprite.tex, Monster.sprite.quad,
	    	                 math.floor (Monster.thing.x + Monster.sprite.offsx), math.floor (Monster.thing.y + Monster.sprite.offsy), 0,
	        	             Monster.sprite:getFlip (), 1, (Monster.sprite:getFlip () == -1) and Monster.sprite.w or 0)
	end

	if drawDebug
	then
		love.graphics.setBlendMode ("additive")
		love.graphics.setColor (0xff, 0x95, 0x00, 0x80)
		love.graphics.rectangle ("fill", Player.thing.x, Player.thing.y, Player.thing.w, Player.thing.h)
		love.graphics.rectangle ("fill", Monster.thing.x, Monster.thing.y, Monster.thing.w, Monster.thing.h)
		love.graphics.setColor (0xff, 0xa5, 0x00, 0xff)

		for i = 1, #curlevel.tiles [1]
		do
			for j = 1, #curlevel.tiles
			do
				if not (curlevel.tiles [j] [i] == 0) and drawDebug
				then
					love.graphics.rectangle ("fill", (i - 1) * 8, (j - 1) * 8, 8, 8)
				end
			end
		end
		love.graphics.setBlendMode ("alpha")
	end

	love.graphics.pop ()

	-- do static
	love.graphics.setColorMode ("modulate")
	love.graphics.setBlendMode ("subtractive")
	local distance = Monster.visible and 192 - (math.abs (Player.thing.x - Monster.thing.x) * 1.5) or 0
	love.graphics.setColor (255, 255, 255, distance > 192 and 192 or (distance > 0 and distance or 0))
	love.graphics.draw (static [math.floor (staticIndx / 4) + 1], 0, 0)
	staticIndx = (staticIndx + 1) % (#static * 4)
	love.graphics.setColorMode ("replace")
	love.graphics.setBlendMode ("alpha")

	love.graphics.setCanvas () -- reset to full resolution
	love.graphics.draw (screen, 0, 0, 0, 4, 4)
	love.graphics.draw (overlay, 0, 0)
	--love.graphics.print (Player.thing.x .. ", " .. Player.thing.y, 2, 2)
end
