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

Monster.thing = Thing.new (128, 16, 8, 24)
Monster.sprite = Sprite.new ("res/objects/npc/monster.png", 32, 32, -12, -8, manims)
Monster.sprite:setFrame ("stand1")
Monster.visible = false
Monster.lifetime = 0

function Monster:logic ()
	if not curlevel.srate
	then
		return
	end

	if not (Player.thing.momx == 0) and math.random (1, curlevel.srate) == curlevel.srate and not self.visible -- try to spawn randomly
	then
		local spot = (Player.thing.x + Player.thing.w / 2)
		if Player.thing.momx < 0
		then
			spot = spot - math.random (24, 64)
		else
			spot = spot + math.random (24, 64)
		end

		self:trySpawn (spot)
	end

	if not self.visible
	then
		return
	end

	self.lifetime = self.lifetime - 1
	if self.lifetime == 0
	then
		self.visible = false
		return
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
	
	if (math.random (1, 6) == 6 or x) and curlevel.srate
	then
		self.thing.y = 0
		self.thing.momy = 0
		if x
		then
			self.thing.x = x
		elseif math.random (1, 3) == 3
		then
			self.thing.x = math.random (self.thing.w * 3, curlevel.bg [1]:getWidth () - self.thing.w * 4)
		elseif Player.thing.x == 0
		then
			self.thing.x = curlevel.bg [1]:getWidth () - self.thing.w * 2
		else
			self.thing.x = self.thing.w
		end

		while (not isBlocked (self.thing.x, self.thing:bottom (), 1)) and self.thing:bottom () < curlevel.bg [1]:getHeight ()
		do
			self.thing.y = self.thing.y + 8
		end

		if not (self.thing:bottom () == curlevel.bg [1]:getHeight ())
		and not isBlocked (self.thing.x, self.thing.y, 1) and not isBlocked (self.thing:right (), self.thing.y, 1)
		and math.abs ((Player.thing.x + Player.thing.w / 2) - (self.thing.x + self.thing.w / 2)) > 16
		then
			self.visible = true
			self.lifetime = (type (x) == "nil") and math.random (420, 1020) or math.random (60, 300)
		end
	end
end
