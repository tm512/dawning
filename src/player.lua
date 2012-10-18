require 'thing'
require 'sprite'
require 'monster'

Player = { }

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
	standing = { 0, 0, -1, nil },
	walk1 = { 1, 0, 7, "walk2" },
	walk2 = { 1, 1, 7, "walk3" },
	walk3 = { 1, 2, 7, "walk4", function () stepsound:play () end },
	walk4 = { 1, 3, 7, "walk5" },
	walk5 = { 1, 4, 7, "walk6" },
	walk6 = { 1, 5, 7, "walk1", function () stepsound:play () end },
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
	uncrouch4 = { 2, 0, 7,  "standing" },
	crawl0 = { 3, 0, -1, nil },
	crawl1 = { 3, 0, 13, "crawl2", function () crawlsound:play () end },
	crawl2 = { 3, 1, 13, "crawl3" },
	crawl3 = { 3, 0, 13, "crawl4", function () crawlsound:play () end },
	crawl4 = { 3, 2, 13, "crawl1" },
}

Player.thing = Thing.new (100, 72, 6, 12)
Player.sprite = Sprite.new ("res/objects/player/player.png", 16, 16, -5, -4, panims)
Player.sprite:setFrame ("wake1")
Player.state = "waking"
Player.inv = { }
Player.cheaty = true

function Player:hasInv (lock)
	if self.cheaty
	then
		return true
	end

	for i in pairs (lock)
	do
		if not self.inv [lock [i]]
		then
			return false
		end
	end

	return true
end

jumpFrames = 10
doorFrames = 0
function Player:logic ()
	if self.state == "waking" and not (self.sprite.curframe == "standing")
	then
		self.sprite:advFrame ()
		if self.sprite.curframe == "wake7" or self.sprite.curframe == "wake8" or self.sprite.curframe == "wake9"
		then
			self.thing.y = self.thing.y - 1.7 / 7
		end

		return
	end

	-- accelerate upwards for 10 frames at most
	if love.keyboard.isDown ("up") and jumpFrames > 0
	then
		if not (self.state == "crouching") and not (self.state == "uncrouching")
		then
			self.thing.momy = 1.2
			jumpFrames = jumpFrames - 1
		elseif not (self.state == "uncrouching") and not isBlocked (self.thing.x, self.thing.y - 6, 1)
		and not isBlocked (self.thing:right (), self.thing.y - 6, 1)
		then
			self.sprite:setFrame (self.state == "crouch4" and "uncrouch2" or "uncrouch1")
			self.state = "uncrouching"
		end
	elseif self.thing.onground == true and not (self.state == "crawling")
	then
		if jumpFrames < 10 and not (self.state == "crouching")
		then
			landsound:play ()
		end

		jumpFrames = 10
	else
		jumpFrames = 0
	end

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

	if love.keyboard.isDown ("down") and not (self.state == "crouching")
	and self.thing.onground and self.thing.momx == 0 and doorFrames == 0
	then
		if isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 2)
		and (not curlevel.door1 [4] or self:hasInv (curlevel.door1 [4])) -- door1
		then
			newx = curlevel.door1 [2]
			newy = curlevel.door1 [3]
			newlevel = Level.new (curlevel.door1 [1])
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 3)
		and (not curlevel.door2 [4] or self:hasInv (curlevel.door2 [4])) -- door2
		then
			newx = curlevel.door2 [2]
			newy = curlevel.door2 [3]
			newlevel = Level.new (curlevel.door2 [1])
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 4)
		and (not curlevel.door3 [4] or self:hasInv (curlevel.door3 [4])) -- door3
		then
			newx = curlevel.door3 [2]
			newy = curlevel.door3 [3]
			newlevel = Level.new (curlevel.door3 [1])
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 5)
		then
			if not self.inv ["key_cabin"]
			then
				self.inv ["key_cabin"] = Sprite.new ("res/objects/items/key_cabin.png", 8, 8, 0, 0, nil)
				curlevel.items ["key_cabin"] = nil
			end
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing.y, 6)
		then
			if not self.inv ["key_shed"]
			then
				self.inv ["key_shed"] = Sprite.new ("res/objects/items/key_shed.png", 8, 8, 0, 0, nil)
				curlevel.items ["key_shed"] = nil
			end
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing.y, 7)
		then
			if not self.inv ["key_gate"] and self.inv ["crowbar"]
			then
				self.inv ["key_gate"] = Sprite.new ("res/objects/items/key_gate.png", 8, 8, 0, 0, nil)
				curlevel.lockbox.sprite:setFrame ("opened")
			end
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 8)
		then
			if not self.inv ["planks"]
			then
				self.inv ["planks"] = Sprite.new ("res/objects/items/planks.png", 8, 8, 0, 0, nil)
				curlevel.items ["planks"] = nil
			end
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing.y, 9)
		then
			if not self.inv ["nails"] and self.inv ["crowbar"]
			then
				self.inv ["nails"] = Sprite.new ("res/objects/items/nails.png", 8, 8, 0, 0, nil)
				curlevel.lockbox.sprite:setFrame ("opened")
			end
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing:bottom () - 3, 10)
		then
			if not self.inv ["crowbar"]
			then
				self.inv ["crowbar"] = Sprite.new ("res/objects/items/crowbar.png", 8, 8, 0, 0, nil)
				curlevel.items ["crowbar"] = nil
			end
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing.y - 3, 11)
		then
			if not self.inv ["hammer"]
			then
				self.inv ["hammer"] = Sprite.new ("res/objects/items/hammer.png", 8, 8, 0, 0, nil)
				curlevel.items ["hammer"] = nil
			end
		elseif isBlocked (self.thing.x + self.thing.w / 2, self.thing.y - 3, 12)
		then
			if not self.inv ["head"]
			then
				self.inv ["head"] = Sprite.new ("res/objects/items/head.png", 8, 8, 0, 0, nil)
				curlevel.items ["head"] = nil
			end
		else
			self.sprite:setFrame ("crouch1")
			self.state = "crouching"
			self.thing.h = 6
			self.thing.y = self.thing.y + 6
			self.sprite.offsy = -10
		end

		if newlevel and not (newlevel == curlevel)
		then
			fadeEnable = true
			return
		end
	end

	-- reset the above, if needed
	if not (self.state == "crouching" or self.state == "crawling") and self.thing.h == 6 and self.thing.onground
	then
		self.thing.h = 12
		self.thing.y = self.thing.y - 6
		self.sprite.offsy = -4
	end

	local direction = 0
	if love.keyboard.isDown ("left")
	then
		direction = -1
		self.sprite:setFlip ("left")
	end

	if love.keyboard.isDown ("right")
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
			if not (self.state == "walking") and not (self.state == "crouching") and not (self.state == "crawling")
			then
				self.sprite:setFrame ("walk1")
				self.state = "walking"
			elseif self.state == "crouching" and (self.sprite.curframe == "crouch4" or self.sprite.curframe == "crawl0")
			then
				self.sprite:setFrame ("crawl2")
				self.state = "crawling"
				jumpFrames = 0 -- eeeeeeeeeeehhhhg
			end

			if not (self.state == "crouching" and not (self.sprite.curframe == "crouch4" or self.sprite.curframe == "crawl0"))
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

	if self.thing:left () < 0 and not (type (curlevel.left) == "nil") -- exit left
	then
		newlevel = Level.new (curlevel.left)
		newx = newlevel.bg:getWidth () - self.thing.w
		newy = self.thing.y
	elseif self.thing:right () > curlevel.bg:getWidth () and not (type (curlevel.right) == "nil") -- exit right
	then
		newlevel = Level.new (curlevel.right)
		newx = 0
		newy = self.thing.y
	elseif self.thing:top () < 0 and not (type (curlevel.up) == "nil") -- exit up
	then
		newlevel = Level.new (curlevel.up)
		newx = self.thing.x
		newy = newlevel.bg:getHeight () - self.thing.h
	elseif self.thing:bottom () > curlevel.bg:getHeight () and not (type (curlevel.down) == "nil") -- exit down
	then
		newlevel = Level.new (curlevel.down)
		newx = self.thing.x
		newy = 0
	end

	if newlevel and not (newlevel == curlevel)
	then
		fadeEnable = true
	end
end
