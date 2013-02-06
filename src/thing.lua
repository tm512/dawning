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

Thing = { }
Thing.__index = Thing

local gravity = 0.996
local friction = 0.8
local termvel = 15 -- TODO

function Thing.new (x, y, w, h)
	local tmp = { }

	setmetatable (tmp, Thing)
	tmp.x = x
	tmp.y = y
	tmp.w = w
	tmp.h = h
	tmp.momx = 0
	tmp.momy = 0
	tmp.onground = false

	return tmp
end

function Thing:top ()
	return self.y
end

function Thing:bottom ()
	return self.y + self.h
end

function Thing:left ()
	return self.x
end

function Thing:right ()
	return self.x + self.w
end

function Thing:setXY (x, y)
	-- print ("setting " .. x .. ", " .. y)
	self.x = x
	self.y = y
end

function isBlocked (x, y, targ)
	if x < 0 or x >= #curlevel.tiles [1] * 8 or y < 0 or y >= #curlevel.tiles * 8
	then
		return false -- for screen transitions
	end

	if curlevel.tiles [math.floor (y / 8) + 1] [math.floor (x / 8) + 1].type == targ
	then
		return true
	else
		return false
	end
end

function Thing:doPhysics ()
	-- assume that we aren't on ground
	self.onground = false

	x, y = 0, 0

	-- vertical movement
	x = self:left ()
	while x <= self:right ()
	do
		if self.momy > 0 -- moving up
		then
			y = self:top () - self.momy

			if isBlocked (x, y, 1)
			then
				local blockx = math.floor (x / 8) * 8
				local blocky = math.floor (y / 8) * 8

				-- test actual collision, correct Y
				if not (blockx >= math.floor (self:right ()) or blockx + 8 <= math.floor (self:left ()))
				then
					self:setXY (self.x, blocky + 8)
					self.momy = 0
					break
				end
			end
		elseif self.momy < 0 -- moving down
		then
			y = self:bottom () - self.momy

			if isBlocked (x, y, 1)
			then
				local blockx = math.floor (x / 8) * 8
				local blocky = math.floor (y / 8) * 8

				if not (blockx >= math.floor (self:right ()) or blockx + 8 <= math.floor (self:left ()))
				then
					self:setXY (self.x, blocky - self.h)
					self.onground = true
					self.momy = 0
					break
				end
			end
		end

		if x == self:right ()
		then
			break
		end
		x = x + (self:right () - x >= 8 and 8 or self:right () - x)
	end

	-- horizontal movement
	y = self:top ()
	while y <= self:bottom ()
	do
		if self.momx > 0 -- moving right
		then
			x = self:right () + self.momx

			if isBlocked (x, y, 1)
			then
				local blockx = math.floor (x / 8) * 8
				local blocky = math.floor (y / 8) * 8

				-- test collision, correct X
				if not (blocky >= math.floor (self:bottom ()) or blocky + 8 <= math.floor (self:top ()))
				then
					self:setXY (blockx - self.w, self.y)
					self.momx = 0
					break
				end
			end
		elseif self.momx < 0
		then
			x = self:left () + self.momx

			if isBlocked (x, y, 1)
			then
				local blockx = math.floor (x / 8) * 8
				local blocky = math.floor (y / 8) * 8

				if not (blocky >= math.floor (self:bottom ()) or blocky + 8 <= math.floor (self:top ()))
				then
					self:setXY (blockx + 8, self.y)
					self.momx = 0
					break
				end
			end
		end

		if y == self:bottom ()
		then
			break
		end
		y = y + (self:bottom () - y >= 8 and 8 or self:bottom () - y)
	end

	-- water physics
	local waterx = 1.0
	local watery = 1.0
	if isBlocked (self.x, self:bottom () - 1, 7)
	then
		waterx = 0.5
		if self.momy > 0
		then
			watery = 0.775
		elseif self.momy < 0
		then
			watery = 0.84
		end
	end

	self.momx = (self.momx * waterx) * friction
	self.momy = ((self.momy * watery) + termvel) * gravity - termvel
	self:setXY (self.x + self.momx, self.y - self.momy)
end
