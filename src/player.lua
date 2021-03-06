--[[
     Copyright (c) 2012 - 2013, Kyle Davis
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
require 'monster'

Player = { }

local function footsound (snd)
	if Player.thing:right () >= curlevel.bg [1]:getWidth () or Player.thing.x <= 0
	then
		return
	end

	local t = curlevel.tiles [math.floor (Player.thing:bottom () / 8) + 1] [math.floor ((Player.thing.x + Player.thing.w / 2) / 8) + 1].sound
	       or curlevel.tiles [math.floor (Player.thing:bottom () / 8) + 1] [math.floor (Player.thing.x / 8) + 1].sound
	       or curlevel.tiles [math.floor (Player.thing:bottom () / 8) + 1] [math.floor (Player.thing:right () / 8) + 1].sound

	if snd [t]
	then
		snd [t]:play ()
	end
end

panims =
{
	wake1 = { 5, 0, 180, "wake2" },
	wake2 = { 5, 1, 7, "wake3" },
	wake3 = { 5, 2, 7, "wake4" },
	wake4 = { 5, 3, 7, "wake5" },
	wake5 = { 5, 4, 7, "wake6" },
	wake6 = { 5, 5, 120, "wake7" },
	wake7 = { 6, 0, 7, "wake8" },
	wake8 = { 6, 1, 7, "wake9" },
	wake9 = { 6, 2, 7, "standing" },
	endwake1 = { 5, 0, 240, "endwake2" },
	endwake2 = { 5, 1, 7, "endwake3" },
	endwake3 = { 5, 2, 7, "endwake4" },
	endwake4 = { 5, 3, 7, "endwake5" },
	endwake5 = { 5, 4, 7, "endwake6" },
	endwake6 = { 5, 5, 270, "endwake7" },
	endwake7 = { 5, 5, -1, nil, function () resetGame () end },
	standing = { 0, 0, -1, nil },
	touching = { 0, 2, -1, nil },
	walk1 = { 1, 0, 7, "walk2" },
	walk2 = { 1, 1, 7, "walk3" },
	walk3 = { 1, 2, 7, "walk4", function () footsound (stepsounds) end },
	walk4 = { 1, 3, 7, "walk5" },
	walk5 = { 1, 4, 7, "walk6" },
	walk6 = { 1, 5, 7, "walk1", function () footsound (stepsounds) end },
	waterwalk1 = { 1, 0, 12, "waterwalk2" },
	waterwalk2 = { 1, 1, 12, "waterwalk3" },
	waterwalk3 = { 1, 2, 12, "waterwalk4", function ()
		spawnPuff (Player.thing.x + Player.thing.w / 2, math.floor (Player.thing:bottom () / 8 - 1) * 8 + 1, 96)
		stepsounds ["water"]:play ()
	end },
	waterwalk4 = { 1, 3, 12, "waterwalk5" },
	waterwalk5 = { 1, 4, 12, "waterwalk6" },
	waterwalk6 = { 1, 5, 12, "waterwalk1", function ()
		spawnPuff (Player.thing.x + Player.thing.w / 2, math.floor (Player.thing:bottom () / 8 - 1) * 8 + 1, 96)
		stepsounds ["water"]:play ()
	end },
	jump1 = { 4, 0, 6, "jump2" },
	jump2 = { 4, 1, 6, "jump3" },
	jump3 = { 4, 2, -1, nil },
	crouch1 = { 2, 0, 7, "crouch2" },
	crouch2 = { 2, 1, 7, "crouch3" },
	crouch3 = { 2, 2, 7, "crouch4" },
	crouch4 = { 2, 3, -1, nil },
	uncrouch1 = { 2, 3, 7, "uncrouch2" },
	uncrouch2 = { 2, 2, 7, "uncrouch3" },
	uncrouch3 = { 2, 1, 7, "uncrouch4" },
	uncrouch4 = { 2, 0, 7, "uncrouch5" },
	uncrouch5 = { 0, 0, -1, nil, function ()
		Player.state = "standing"
	end },
	crawl0 = { 3, 0, -1, nil },
	crawl1 = { 3, 0, 13, "crawl2", function () crawlsound:play () end },
	crawl2 = { 3, 1, 13, "crawl3" },
	crawl3 = { 3, 0, 13, "crawl4", function () crawlsound:play () end },
	crawl4 = { 3, 2, 13, "crawl1" },
}

Player.thing = Thing.new (100, 72, 6, 12)
Player.state = "waking"
Player.headless = "no"
Player.inv = { }
Player.sortedInv = { }

keyhud = { door1 = false, door2 = false, door3 = false, lockbox = false }

nopeframes = 0 -- lol
function Player:hasInv (item, playsnd)
	if type (item) == "string"
	then
		item = { item }
	end

	for i in pairs (item)
	do
		if not self.inv [item [i]]
		then
			if playsnd and nopeframes == 0
			then
				nopesound:play ()
				nopeframes = 60
			end

			return false
		end
	end

	return true
end

function Player:giveInv (item)
	if item and not self:hasInv (item, false)
	then
		self.inv [item] = Sprite.new ("res/objects/items/" .. (item:find ("head") and "head" or item) .. ".png", 8, 8, 0, 0, nil)
		table.insert (self.sortedInv, self.inv [item])
		curlevel.items [item] = nil
		itemsound:play ()
	end
end

-- remove an item from the sorted inventory. This just hides it, doesn't remove it from the actual inventory.
function Player:remInv (items)
	for _, item in pairs (items)
	do
		for i, j in ipairs (self.sortedInv)
		do
			if j == self.inv [item]
			then
				table.remove (self.sortedInv, i)
			end
		end
	end
end

function Player:doDoor (door)
	if not curlevel [door] [4] or self:hasInv (curlevel [door] [4], true)
	then
		-- if we have the key in our visible inventory, remove it
		if curlevel [door] [4] and not (curlevel [door] [4] == "hammer")
		then
			local items = type (curlevel [door] [4]) == "string" and { curlevel [door] [4] } or curlevel [door] [4]
			self:remInv (items)
		end

		switchsound = curlevel [door] [5]
		-- preserve X when going through the bridge "door" (cough, hack, cough)
		newx = curlevel [door] [5] and curlevel [door] [2] or Player.thing.x
		newy = curlevel [door] [3]
		newlevel = Level.new (curlevel [door] [1])
	end
end

jumpFrames = 0
doorFrames = 0
prevInWater = false
standLock = false
function Player:logic ()
	if (self.state == "waking" or self.state == "ending") and not (self.sprite.curframe == "standing")
	then
		self.sprite:advFrame ()
		if self.sprite.curframe == "wake7" or self.sprite.curframe == "wake8" or self.sprite.curframe == "wake9"
		then
			self.thing.y = self.thing.y - 1.7 / 7
		end

		return
	end

	local inWater = isBlocked (self.thing.x, self.thing:bottom () - 1, 7)

	-- accelerate upwards for 10 frames at most
	if love.keyboard.isDown ("up", "w") and jumpFrames > 0
	then
		if not (self.state == "crouching") and not (self.state == "uncrouching")
		then
			self.thing.momy = 1.2
			jumpFrames = jumpFrames - 1
		end
	elseif self.thing.onground == true and not (self.state == "crawling")
	then
		if jumpFrames < 10 and not (self.state == "crouching") and not inWater
		then
			footsound (landsounds)
			spawnPuff (self.thing.x + self.thing.w / 2, self.thing:bottom (), 64)
		end

		jumpFrames = 10
	else
		jumpFrames = 0
	end

	if not (inWater == prevInWater) and jumpFrames < 10
	then
		spawnPuff (self.thing.x + self.thing.w / 2, math.floor (self.thing:bottom () / 8) * 8 + 1, 160)
		landsounds ["water"]:play ()
	end
	prevInWater = inWater

	if not (math.abs (self.thing.momy) < 0.1)
	and not (self.state == "jumping")
	then
		self.sprite:setFrame ("jump1")
		self.state = "jumping"
	end

	if doorFrames > 0
	then
		doorFrames = doorFrames - 1
	end

	nopeframes = nopeframes > 0 and nopeframes - 1 or 0

	if love.keyboard.isDown ("down", "s", " ") and not (self.state == "crouching") and not (self.state == "crawling")
	and not love.keyboard.isDown ("left", "a") and not love.keyboard.isDown ("right", "d")
	and self.thing.onground and doorFrames == 0 and not inWater
	then
		switchsound = nil
		if isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 2)
		then
			self:doDoor ("door1")
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 3)
		then
			self:doDoor ("door2")
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 4)
		then
			self:doDoor ("door3")
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 5)
		then
			local curtile = curlevel.tiles [math.floor ((self.thing:bottom () - 3) / 8) + 1] [math.floor ((self.thing.x + self.thing.w / 2) / 8) + 1]
			self:giveInv (curtile.item)
			curtile.type = 0
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing.y, 5)
		then
			local curtile = curlevel.tiles [math.floor (self.thing.y / 8) + 1] [math.floor ((self.thing.x + self.thing.w / 2) / 8) + 1]
			self:giveInv (curtile.item)
			curtile.type = 0
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing.y, 6)
		then
			if self:hasInv ("crowbar", true)
			then
				self:giveInv (curlevel.lockbox.item)
				curlevel.lockbox.sprite:setFrame ("opened")
				curlevel.tiles [math.floor (self.thing.y / 8) + 1] [math.floor ((self.thing.x + self.thing.w / 2) / 8) + 1].type = 0
			end
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 8)
		then
			if self:hasInv ("box")
			then
				curlevel.wmonster:setFrame ("start")
				curlevel.tiles [math.floor ((self.thing:bottom () - 3) / 8) + 1] [math.floor ((self.thing.x + self.thing.w / 2) / 8) + 1].type = 0
				self:remInv ( { "box" } )
			end
		end

		if newlevel and not (newlevel == curlevel)
		then
			fadeEnable = true
			if switchsound == "door"
			then
				doorsound:play ()
			elseif switchsound == "ladder"
			then
				laddersound:play ()
			end

			return
		end
	elseif not love.keyboard.isDown ("down", "s")
	then
		standLock = false
	end

	-- reset the above, if needed
	if not (self.state == "crouching" or self.state == "crawling") and self.thing.h == 6 and self.thing.onground
	then
		self.thing.h = 12
		self.thing.y = self.thing.y - 6
		self.sprite.offsy = -4
	end

	-- set whether we're standing over certain doors. We need to display the items necessary to open them if so
	if isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 2)
	then
		keyhud ["door1"] = true
	else
		keyhud ["door1"] = false
	end

	if isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 3)
	then
		keyhud ["door2"] = true
	else
		keyhud ["door2"] = false
	end

	if isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 4)
	then
		keyhud ["door3"] = true
	else
		keyhud ["door3"] = false
	end

	if isBlocked (self.thing.x + self.thing.w / 2, self.thing.y, 6)
	then
		keyhud ["lockbox"] = true
	else
		keyhud ["lockbox"] = false
	end

	local direction = 0
	if love.keyboard.isDown ("left", "a")
	then
		direction = -1
		self.sprite:setFlip ("left")
	end

	if love.keyboard.isDown ("right", "d")
	then
		direction = 1
		self.sprite:setFlip ("right")
	end

	-- move left/right
	if not (direction == 0)
	then
		-- on ground? Accelerate immediately and don't worry about switching directions
		if self.thing.onground == true
		then
			if not (self.state == "walking" or self.state == "crouching" or self.state == "crawling" or self.state == "uncrouching")
			then
				self.sprite:setFrame (inWater and "waterwalk1" or "walk1")
				self.state = "walking"
			elseif self.state == "crouching" and (self.sprite.curframe == "crouch4" or self.sprite.curframe == "crawl0")
			then
				self.sprite:setFrame ("crawl2")
				self.state = "crawling"
				jumpFrames = 0 -- eeeeeeeeeeehhhhg
			end

			if not (self.state == "crouching" and not (self.sprite.curframe == "crouch4" or self.sprite.curframe == "crawl0"))
			and not (self.state == "uncrouching")
			then
				self.thing.momx = (self.state == "walking" and 0.6 or 0.3) * direction
			end
		else
			-- same direction
			if (self.thing.momx < 0 and direction < 0) or (self.thing.momx > 0 and direction > 0) or self.thing.momx == 0
			then
				self.thing.momx = 0.5 * direction
			else
				self.thing.momx = self.thing.momx * -0.3
			end
		end
	elseif self.thing.onground == true
	then
		self.thing.momx = 0
		if self.sprite.curframe == "standing"
		or (not (self.state == "crouching") and not (self.state == "crawling") and not (self.state == "uncrouching"))
		then
			self.sprite:setFrame ("standing")
			self.state = "standing"
		elseif self.state == "crawling"
		then
			self.sprite:setFrame ("crawl0")
			self.state = "crouching" -- wat
		end
	end

	self.thing:doPhysics ()
	self.sprite:advFrame ()

	if not (direction == 0) and self.thing.momx == 0 and self.thing.onground
	then
		if self.state == "walking"
		then
			local side = direction == -1 and self.thing.x - 2 or self.thing:right () + 2
			local topblock = isBlocked (side, self.thing.y, 1)
			local botblock = isBlocked (side, self.thing:bottom () - 3, 1)

			if not botblock and not inWater and not love.keyboard.isDown ("up", "w")
			then	
				self.sprite:setFrame ("crouch1")
				self.state = "crouching"
				self.thing.h = 6
				self.thing.y = self.thing.y + 6
				self.sprite.offsy = -10
				crouchlock = direction
			elseif not topblock
			then
				self.sprite:setFrame ("standing")
				self.state = "standing"
			else
				self.sprite:setFrame ("touching")
				self.state = "standing"
			end
		else
		end
	end

	if self.state == "crawling"
	then
		if isBlocked (self.thing.x, self.thing.y - 6, 1) or isBlocked (self.thing:right (), self.thing.y - 6, 1)
		or isBlocked (self.thing.x + self.thing.w / 2, self.thing.y - 6, 1) or crouchlock == -direction
		then
			crouchlock = 0
		elseif crouchlock == 0
		then
			self.sprite:setFrame ("uncrouch1")
			self.state = "uncrouching"
		end
	end

	-- check for monster collision
	if Monster.visible
	then
		local xinter = (self.thing:left () < Monster.thing:right () and self.thing:right () > Monster.thing:left ())
		local yinter = (self.thing:top () < Monster.thing:bottom () and self.thing:bottom () > Monster.thing:top ())

		if xinter and yinter
		then
			glitchsound:play ()
			self.headless = "set"
			spawnbed = curlevel.name
			newlevel = Level.new (curlevel.name)
			newx = newlevel.bedx
			newy = newlevel.bedy
			if not (newlevel.bedx and newlevel.bedy)
			then
				newlevel = Level.new (startlevel)
				newx = 100
				newy = 72
			end
		end
	end

	if self.thing:left () < 0 and not (type (curlevel.left) == "nil") -- exit left
	then
		newlevel = Level.new (curlevel.left)
		newx = newlevel.bg [1]:getWidth () - self.thing.w
		newy = self.thing.y
	elseif self.thing:right () > curlevel.bg [1]:getWidth () and not (type (curlevel.right) == "nil") -- exit right
	then
		newlevel = Level.new (curlevel.right)
		newx = 0
		newy = self.thing.y
	elseif self.thing:top () < 0 and not (type (curlevel.up) == "nil") -- exit up
	then
		newlevel = Level.new (curlevel.up)
		newx = self.thing.x
		newy = newlevel.bg [1]:getHeight () - self.thing.h
	elseif self.thing:bottom () > curlevel.bg [1]:getHeight () and not (type (curlevel.down) == "nil") -- exit down
	then
		newlevel = Level.new (curlevel.down)
		newx = self.thing.x + (curlevel.longhack and 192 or 0)
		newy = 0
	end

	if newlevel and not (newlevel == curlevel)
	then
		fadeEnable = true
	end
end
