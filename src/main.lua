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
end

local frametime = 1.0 / 60
local nextframe = 0
local curtime = 0

fadeAmount = 0
fadeEnable = false
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

	if not fadeEnable
	then
		Player:logic ()
		Monster:logic ()
	end
end

drawDebug = false
staticIndx = 0
distance = 0
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

	-- draw items on level
	for i in pairs (curlevel.items)
	do
		if curlevel.items [i]
		then
			love.graphics.drawq (curlevel.items [i].tex, curlevel.items [i].quad, curlevel.items [i].offsx, curlevel.items [i].offsy)
		end
	end

	if curlevel.lockbox
	then
		love.graphics.drawq (curlevel.lockbox.sprite.tex, curlevel.lockbox.sprite.quad,
		                     curlevel.lockbox.sprite.offsx, curlevel.lockbox.sprite.offsy)
	end

	love.graphics.drawq (Player.sprite.tex, Player.sprite.quad,
	                     math.floor (Player.thing.x + Player.sprite.offsx), math.floor (Player.thing.y + Player.sprite.offsy), 0,
	                     Player.sprite:getFlip (), 1, (Player.sprite:getFlip () == -1) and Player.sprite.w or 0)
	if Monster.visible
	then
		love.graphics.drawq (Monster.sprite.tex, Monster.sprite.quad,
	    	                 math.floor (Monster.thing.x + Monster.sprite.offsx), math.floor (Monster.thing.y + Monster.sprite.offsy), 0,
	        	             Monster.sprite:getFlip (), 1, (Monster.sprite:getFlip () == -1) and Monster.sprite.w or 0)
	end

	if curlevel.bridge
	then
		love.graphics.drawq (curlevel.bridge.tex, curlevel.bridge.quad,
		                     curlevel.bridge.offsx, curlevel.bridge.offsy)
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

	-- draw items in HUD
	local j = 0
	for i in pairs (Player.inv)
	do
		if Player.inv [i]
		then
			love.graphics.drawq (Player.inv [i].tex, Player.inv [i].quad, 180 - j, 84)
		end
		j = j + 10
	end

	-- do static and/or fade
	local tdist = 160 - (math.abs (Player.thing.x - Monster.thing.x) * 1.5)

	love.graphics.setColorMode ("modulate")
	love.graphics.setBlendMode ("subtractive")
	distance = (Monster.visible and tdist > distance) and tdist or distance - 0.75
	love.graphics.setColor (255, 255, 255, math.floor (distance > 160 and 160 or (distance > 0 and distance or 0)))
	love.graphics.draw (static [math.floor (staticIndx / 4) + 1], 0, 0)
	staticIndx = (staticIndx + 1) % (#static * 4)

	love.graphics.setColor (0, 0, 0, math.abs (fadeAmount))
	love.graphics.rectangle ("fill", 0, 0, 192, 96)

	if fadeEnable
	then
		fadeAmount = fadeAmount + (255 / 32)

		if math.floor (fadeAmount) == 255
		then
			fadeAmount = -255
			if newlevel and newx and newy
			then
				curlevel = newlevel
				newlevel = nil
				Player.thing.x = newx
				Player.thing.y = newy
				doorFrames = 40
				Monster:trySpawn ()
			end
		elseif math.floor (fadeAmount) == 0
		then
			fadeAmount = 0
			fadeEnable = false
		end
	end
	
	love.graphics.setColorMode ("replace")
	love.graphics.setBlendMode ("alpha")

	love.graphics.setCanvas () -- reset to full resolution
	love.graphics.draw (screen, 0, 0, 0, 4, 4)
	love.graphics.draw (overlay, 0, 0)
	love.graphics.print (Player.thing.x .. ", " .. Player.thing.y, 2, 2)
end
