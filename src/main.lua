--[[
     Copyright (c) 2012, Kyle Davis
     All rights reserved.
     
     Redistribution and use in source and binary forms, with or without
     modification, are permitted provided that the following conditions are met:
         * Redistributions of source code must retain the above copyright
           notice, this list of conditions and the following disclaimer.
         * Redistributions in binary form must reproduce the above copyright
           notice, this list of conditions and the following disclaimer in the
           documentation and/or other materials provided with the distribution.
         * Neither the name of the <organization> nor the
           names of its contributors may be used to endorse or promote products
           derived from this software without specific prior written permission.
     
     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
     ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
     DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
     DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
     (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
     ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
     (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
     SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]--

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

function resetGame ()
	newPlayer = true
	newlevel = Level.new (startlevel)
	newx = 100
	newy = 72
	fadeEnable = true
	title.alpha = 0
	title.enabled = true

	levels ["cliff_bridge"] = bridgebak
end

static = { }
function love.load ()
	ret = love.graphics.setMode (768, 386, false, false, 0)
	love.graphics.setCaption ("dawning")
	love.graphics.setColorMode ("replace")
	if ret == 0
	then
		error ("couldn't set screen mode")
	end

	screen = love.graphics.newCanvas (256, 128)
	screen:setFilter ("nearest", "nearest")

	overlay = genOverlay (768, 386)
	stepsound = love.audio.newSource ("res/sound/footstep.ogg", "static")
	stepsound:setVolume (0.4)

	landsound = love.audio.newSource ("res/sound/landing.ogg", "static")
	landsound:setVolume (0.4)

	crawlsound = love.audio.newSource ("res/sound/crawl.ogg", "static")
	crawlsound:setVolume (0.4)

	itemsound = love.audio.newSource ("res/sound/item.ogg", "static")
	itemsound:setVolume (0.4)

	doorsound = love.audio.newSource ("res/sound/door.ogg", "static")
	doorsound:setVolume (0.4)

	laddersound = love.audio.newSource ("res/sound/ladder.ogg", "static")
	laddersound:setVolume (0.4)

	glitchsound = love.audio.newSource ("res/sound/glitch.ogg", "static")
	glitchsound:setVolume (0.4)

	monstersound = love.audio.newSource ("res/sound/monster.ogg", "static")
	monstersound:setLooping (true)
	monstersound:setVolume (0.0)
	monstersound:play ()

	title = { title = love.graphics.newImage ("res/objects/title/title.png"),
	          copyr = love.graphics.newImage ("res/objects//title/text.png"),
	          alpha = 0,
	          enabled = true }

	ambience = { name = ":D", source = nil }

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
		if Player.inv [i] and not (Player.state == "ending")
		then
			love.graphics.drawq (Player.inv [i].tex, Player.inv [i].quad, 180 - j, 84)
		end
		j = j + 10
	end

	-- do static and/or fade
	local tdist = 160 - (math.abs (Player.thing.x - Monster.thing.x) * 1.5)
	local maxstatic = endFade and 255 or 160

	love.graphics.setColorMode ("modulate")
	love.graphics.setBlendMode ("subtractive")

	if endFade
	then
		distance = distance + 0.0425
	else
		distance = (Monster.visible and tdist > distance) and tdist or (distance < 0 and 0 or distance - 0.5)
	end

	love.graphics.setColor (255, 255, 255, math.floor (distance > maxstatic and maxstatic or (distance > 0 and distance or 0)))
	love.graphics.draw (static [math.floor (staticIndx / 4) + 1], 0, 0)
	staticIndx = (staticIndx + 1) % (#static * 4)
	monstersound:setVolume ((distance > maxstatic and maxstatic or (distance > 0 and distance or 0)) / 120)

	-- start the actual ending of the game if we need to
	if distance > 255
	then
		Player.sprite:setFlip ("left")
		if Player.headless == "no" -- good ending
		then
			Player.sprite:setFrame ("endwake1")
			Player.state = "ending"
			newlevel = Level.new ("bedroom")
			newx = 43
			newy = 64
		else -- bad ending
			Player.sprite = Sprite.new ("res/objects/player/player_box.png", 16, 16, -5, -4, panims)
			Player.sprite:setFrame ("endwake1")
			Player.state = "ending"
			newlevel = Level.new ("room_cellclosed")
			newx = 159
			newy = 72
		end
		fadeEnable = true
	end
		

	love.graphics.setColor (0, 0, 0, math.abs (fadeAmount))
	love.graphics.rectangle ("fill", 0, 0, 192, 96)

	if fadeEnable
	then
		fadeAmount = fadeAmount + (newPlayer and 1 or (255 / 32))

		if math.floor (fadeAmount) == 255
		then
			fadeAmount = -255
			if newlevel and newx and newy
			then
				curlevel = newlevel
				newlevel = nil

				if Player.headless == "set"
				then
					Player.sprite = Sprite.new ("res/objects/player/player_head.png", 16, 16, -5, -4, panims)
					Player.sprite:setFrame ("wake1")
					Player.state = "waking"
					Player.headless = "yes"
					Player.thing.momx = 0
					Player.thing.momy = 0
				end

				if endFade and Player.state == "ending"
				then
					distance = 0
					endFade = false
				end

				if newPlayer
				then
					Player.inv = { }
					Player.headless = "no"
					Player.sprite = Sprite.new ("res/objects/player/player.png", 16, 16, -5, -4, panims)
					Player.sprite:setFrame ("wake1")
					Player.state = "waking"
					Player.thing.momx = 0
					Player.thing.momy = 0
					newPlayer = false
				end

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
	
	love.graphics.setBlendMode ("alpha")
	if title.enabled and not fadeEnable
	then
		love.graphics.setColor (255, 255, 255, title.alpha)
		love.graphics.draw (title.title, 67, 0)
		love.graphics.draw (title.copyr, 99, 87)
		if title.alpha < 255
		then
			title.alpha = title.alpha + 1
		end
	end
	love.graphics.setColorMode ("replace")

	love.graphics.setCanvas () -- reset to full resolution
	love.graphics.draw (screen, 0, 0, 0, 4, 4)
	love.graphics.draw (overlay, 0, 0)
--	love.graphics.print (Player.thing.x .. ", " .. Player.thing.y, 2, 2)
end
