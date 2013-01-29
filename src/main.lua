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

local scale = 5

function genOverlay (w, h)
	if scale < 3
	then
		return nil
	end

	local data = love.image.newImageData (w, h)

	for x = 0, w - 1
	do
		for y = 0, h - 1
		do
			if x % scale == 0 or y % scale == 0
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

function genParticle (r, g, b)
	local data = love.image.newImageData (1, 1)

	data:setPixel (0, 0, r, g, b, 255)
	return love.graphics.newImage (data)
end

psystems = { }
function spawnPuff (x, y, amount)
	system = love.graphics.newParticleSystem (particle, amount)
	table.insert (psystems, system)

	system:setDirection (math.pi * 1.5)
	system:setEmissionRate (amount)
	system:setGravity (15, 20)
	system:setLifetime (0.06)
	system:setParticleLife (0.08, 0.12)
	system:setPosition (x, y)
	system:setRadialAcceleration (0)
	system:setSizes (1)
	system:setSpeed (75, 80)
	system:setSpin (0)
	system:setSpread (math.pi)
	system:start ()

	system = nil
end

function resetGame ()
	newPlayer = true
	newlevel = Level.new (startlevel)
	newx = 100
	newy = 72
	fadeEnable = true
	Monster.visible = false

	levels ["cliff_bridge"] = bridgebak
	bridgebak = { }
end

static = { }
function love.load ()
	ret = love.graphics.setMode (192 * scale, 96 * scale, false, false, 0)
	love.graphics.setCaption ("dawning")
	love.graphics.setColorMode ("replace")
	if ret == 0
	then
		error ("couldn't set screen mode")
	end

	screen = love.graphics.newCanvas (256, 128)
	screen:setFilter ("nearest", "nearest")

	overlay = genOverlay (192 * scale, 96 * scale)

	stepsounds = { grass = love.audio.newSource ("res/sound/step_grass.ogg", "static"),
	               dirt = love.audio.newSource ("res/sound/step_dirt.ogg", "static"),
	               stone = love.audio.newSource ("res/sound/step_stone.ogg", "static"),
	               wood = love.audio.newSource ("res/sound/step_wood.ogg", "static"),
	               water = love.audio.newSource ("res/sound/step_water.ogg", "static") }

	landsounds = { grass = love.audio.newSource ("res/sound/land_grass.ogg", "static"),
	               dirt = love.audio.newSource ("res/sound/land_dirt.ogg", "static"),
	               stone = love.audio.newSource ("res/sound/land_stone.ogg", "static"),
	               wood = love.audio.newSource ("res/sound/land_wood.ogg", "static"),
	               water = love.audio.newSource ("res/sound/land_water.ogg", "static") }

	for _, s in pairs (stepsounds)
	do
		s:setVolume (0.4)
	end

	for _, s in pairs (landsounds)
	do
		s:setVolume (0.4)
	end

	crawlsound = love.audio.newSource ("res/sound/crawl.ogg", "static")
	crawlsound:setVolume (0.4)

	itemsound = love.audio.newSource ("res/sound/item.ogg", "static")
	itemsound:setVolume (0.4)

	nopesound = love.audio.newSource ("res/sound/nope.ogg", "static")
	nopesound:setVolume (0.4)

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
distance = 0
function doFades ()
	if fadeEnable
	then
		fadeAmount = fadeAmount + (newPlayer and 1 or (255 / 16))
	
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
					Player.sortedInv = { }
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
			end
		elseif math.floor (fadeAmount) == 0
		then
			fadeAmount = 0
			fadeEnable = false
		end
	end

	if endFade
	then
		distance = distance + 0.085
	elseif not Monster.visible
	then
		distance = distance < 0 and 0 or distance - 1
	end
end

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

		for i, s in ipairs (psystems)
		do
			if s:isEmpty () and not s:isActive ()
			then
				table.remove (psystems, i)
			else
				s:update (0.006)
			end
		end
	else
	end

	doFades ()
end

drawDebug = false
staticIndx = 0
function love.draw ()
	screen:setFilter ("nearest", "nearest")
	love.graphics.setCanvas (screen) -- draw to original resolution
	love.graphics.push ()

	-- camera
	local camshift = (Player.thing.x + Player.thing.w / 2) - 96
	camshift = camshift > 192 and 192 or camshift
	camshift = camshift < 0 and 0 or camshift

	if curlevel.bg [2] and curlevel.bg [3] -- render parallax
	then
		love.graphics.draw (curlevel.bg [3], -math.floor (48 * (camshift / 192)), 0)
		love.graphics.draw (curlevel.bg [2], -math.floor (96 * (camshift / 192)), 0)
	end

	if curlevel.bg [1]:getWidth () > 192
	then
			love.graphics.translate (-math.floor (camshift), 0)
	end

	love.graphics.draw (curlevel.bg [1], 0, 0)

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

	-- draw particle systems
	for _, s in pairs (psystems)
	do
		love.graphics.draw (s)
	end

	if curlevel.fg
	then
		love.graphics.draw (curlevel.fg, 0, 0)
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
				if not (curlevel.tiles [j] [i].type == 0) and drawDebug
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
	for i in ipairs (Player.sortedInv)
	do
		if Player.sortedInv [i] and not (Player.state == "ending")
		then
			love.graphics.drawq (Player.sortedInv [i].tex, Player.sortedInv [i].quad, 180 - j, 84)
		end
		j = j + 10
	end

	love.graphics.setColorMode ("modulate")
	love.graphics.setColor (255, 255, 255, 128)
	for k, v in pairs (keyhud)
	do
		if v and curlevel.itemspr [k]
		then
			for l, w in pairs (curlevel.itemspr [k])
			do
				if not Player.inv [w.name]
				then
					love.graphics.drawq (w.sprite.tex, w.sprite.quad, 180 - j, 84)
					j = j + 10
				end
			end
		end
	end
	love.graphics.setColor (255, 255, 255, 255)

	-- do static and/or fade
	local tdist = 160 - (math.abs (Player.thing.x - Monster.thing.x) * 1.5)
	local maxstatic = endFade and 255 or 160

	love.graphics.setBlendMode ("subtractive")

	if Monster.visible
	then
		distance = tdist
	end

	love.graphics.setColor (255, 255, 255, math.floor (distance > maxstatic and maxstatic or (distance > 0 and distance or 0)))
	love.graphics.draw (static [math.floor (staticIndx / 4) + 1], 0, 0)
	staticIndx = (staticIndx + 1) % (#static * 4)
	monstersound:setVolume ((distance > maxstatic and maxstatic or (distance > 0 and distance or 0)) / 120)
	local avol = 0.6 - monstersound:getVolume ()
	if ambience.source
	then
		ambience.source:setVolume ((avol > 0) and avol or 0)
	end

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

	love.graphics.setBlendMode ("alpha")
	love.graphics.setColorMode ("replace")

	love.graphics.setCanvas () -- reset to full resolution
	love.graphics.draw (screen, 0, 0, 0, scale, scale)
	if overlay
	then
		love.graphics.draw (overlay, 0, 0)
	end
--	love.graphics.print (Player.thing.x .. ", " .. Player.thing.y, 2, 2)
end
