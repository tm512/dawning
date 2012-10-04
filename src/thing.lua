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

function isBlocked (x, y)
	if x < 0 or y < 0 or y >= #testMap * 8 or x >= #testMap [1] * 8
	then
		return true -- Don't blow up if we try going off the map
	end

	if testMap [math.floor (y / 8) + 1] [math.floor (x / 8) + 1] == 1
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

			if isBlocked (x, y)
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

			if isBlocked (x, y)
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

			if isBlocked (x, y)
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

			if isBlocked (x, y)
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

	-- don't let us get stuck
	--if self.momy == 0
	--then
	--	self.momy = -0.01
	--end

	--print (self.momy)
	self.momy = (self.momy + termvel) * gravity - termvel
	self.momx = self.momx * friction
	self:setXY (self.x + self.momx, self.y - self.momy)
end
