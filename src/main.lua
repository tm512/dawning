require 'thing'
require 'sprite'
require 'player'
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
			data:setPixel (x, y, val, val, val, 160)
		end
	end

	return love.graphics.newImage (data)
end

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

	curlevel = Level.new (startlevel)
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

drawDebug = false
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
	if drawDebug
	then
		love.graphics.setBlendMode ("additive")
		love.graphics.setColor (0xff, 0x95, 0x00, 0xff)
		love.graphics.rectangle ("fill", Player.thing.x, Player.thing.y, Player.thing.w, Player.thing.h)
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
	love.graphics.setCanvas () -- reset to full resolution
	love.graphics.draw (screen, 0, 0, 0, 4, 4)
	love.graphics.draw (overlay, 0, 0)
	love.graphics.print (Player.thing.x .. ", " .. Player.thing.y, 2, 2)
end
