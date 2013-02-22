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

Monster = { }

manims =
{
	stand1 = { 0, 0, 60, "glitch1" },
	glitch1 = { 2, 0, 9, "glitch2" },
	glitch2 = { 0, 1, 7, "glitch3" },
	glitch3 = { 1, 1, 6, "stand2" },
	stand2 = { 1, 0, 20, "stand3" },
	stand3 = { 0, 0, 80, "glitch4" },
	glitch4 = { 2, 2, 40, "glitch5" },
	glitch5 = { 1, 2, 6, "glitch6" },
	glitch6 = { 0, 2, 15, "glitch7" },
	glitch7 = { 2, 1, 6, "stand1" }
}

wmanims =
{
	still = { 0, 0, -1, nil },
	start = { 0, 0, 0, "stand1" },
	stand1 = { 1, 0, 90, "stand2", function ()
		-- block off the exit now
		for y = 0, #curlevel.tiles - 1
		do
			curlevel.tiles [y + 1] [1].type = 1
		end
	end },
	stand2 = { 2, 0, 45, "stand3" },
	stand3 = { 0, 1, 7, "stand4" },
	stand4 = { 1, 1, 7, "stand5" },
	stand5 = { 2, 1, 7, "stand6" },
	stand6 = { 0, 2, 7, "stand7" },
	stand7 = { 1, 2, 7, "stand8" },
	stand8 = { 2, 2, 60, "ending" },
	ending = { 2, 2, -1, nil, function ()
		Player.state = "ending"
		newlevel = Level.new ("bedroom")
		newx = 43
		newy = 64
		fadeEnable = true -- eh, have to explicitly enable it here...
	end }
}

Monster.thing = Thing.new (128, 16, 8, 24)
Monster.sprite = Sprite.new ("res/objects/npc/monster.png", 32, 32, -12, -8, manims)
Monster.sprite:setFrame ("stand1")
Monster.visible = false
Monster.jumping = false
Monster.lifetime = 0
Monster.bounds = { lower = 24, upper = 64 }
Monster.spawned = false

function Monster:logic ()
	if not curlevel.srate and not curlevel.bridge
	then
		return
	end

	if curlevel.bridge and not newlevel
	then
		if Player.thing.x <= 150 and not self.visible
		then
			self:trySpawn (90)
		end
	end

	if curlevel.fmspawn and not newlevel and not self.spawned
	then
		if Player.thing.x >= self.spawnx
		then
			self:trySpawn (Player.thing.x + 32)
			self.spawned = true
		end
	end

	if not self.spawned
	then
		return
	end

	if not self.visible and not curlevel.bridge
	and (self.jumping or (not (Player.thing.momx == 0) and math.random (1, curlevel.srate) == curlevel.srate)) -- try to spawn randomly
	then
		local spot = (Player.thing.x + Player.thing.w / 2)
		local offset = math.random (math.floor (self.bounds.lower), math.floor (self.bounds.upper))
		if (self.jumping and math.random (1, 2) == 1) or ((not self.jumping) and Player.thing.momx < 0)
		then
			spot = spot - offset
		else
			spot = spot + offset
		end

		if self.jumping and math.random (1, 3) < 3
		then
			self.jumping = false
		end

		if self:trySpawn (spot)
		then
			self.bounds.lower = self.bounds.lower > 16 and self.bounds.lower - 0.25 or self.bounds.lower
			self.bounds.upper = self.bounds.upper > 24 and self.bounds.upper - 1 or self.bounds.upper
		end
	end

	if not self.visible
	then
		return
	end

	self.lifetime = self.lifetime - 1
	if self.lifetime <= 0 and not curlevel.bridge
	then
		self.visible = false
	end

	if Player.thing.x < self.thing.x
	then
		self.sprite:setFlip ("left")
	else
		self.sprite:setFlip ("right")
	end

	self.thing:doPhysics ()
	self.sprite:advFrame ()
end

function Monster:trySpawn (x)
	self.visible = false
	
	if curlevel.srate or curlevel.bridge
	then
		self.thing.x = x
		self.thing.y = 0
		self.thing.momy = 0

		while ((not isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom (), 1))
		or isBlocked (self.thing.x + self.thing.w / 2, self.thing.y, 1)) and self.thing:bottom () < curlevel.bg [1]:getHeight ()
		do
			self.thing.y = self.thing.y + 8
		end

		if not (self.thing:bottom () == curlevel.bg [1]:getHeight ())
		and not isBlocked (self.thing.x, self.thing.y, 1) and not isBlocked (self.thing:right (), self.thing.y, 1)
		then
			self.visible = true
			self.lifetime = math.random (60, 360)
			if math.random (1, 3) == 3
			then
				self.jumping = true
				self.lifetime = self.lifetime / 2
			end
			return true
		end
	end

	return false
end
