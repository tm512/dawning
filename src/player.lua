require 'thing'
require 'sprite'

Player = { }

panims =
{
	standing = { 0, 0, -1, nil },
	walk1 = { 1, 0, 7, "walk2" },
	walk2 = { 1, 1, 7, "walk3" },
	walk3 = { 1, 2, 7, "walk4" },
	walk4 = { 1, 3, 7, "walk5" },
	walk5 = { 1, 4, 7, "walk6" },
	walk6 = { 1, 5, 7, "walk1" },
	jump1 = { 4, 0, 6, "jump2" },
	jump2 = { 4, 1, 6, "jump3" },
	jump3 = { 4, 2, -1, nil },
	crouch1 = { 2, 0, 7, "crouch2" },
	crouch2 = { 2, 1, 7, "crouch3" },
	crouch3 = { 2, 2, 7, "crouch4" },
	crouch4 = { 2, 3, -1, nil },
	crawl0 = { 3, 0, -1, nil },
	crawl1 = { 3, 0, 13, "crawl2" },
	crawl2 = { 3, 1, 13, "crawl3" },
	crawl3 = { 3, 0, 13, "crawl4" },
	crawl4 = { 3, 2, 13, "crawl1" },
}

Player.thing = Thing.new (32, 12, 8, 12)
Player.sprite = Sprite.new ("res/objects/player/player.png", 16, 16, -4, -4, panims)
Player.sprite:setFrame ("standing")
Player.state = "standing"

jumpFrames = 10
function Player:logic ()
	-- accelerate upwards for 10 frames at most
	if love.keyboard.isDown ("up") and jumpFrames > 0
	then
		self.thing.momy = 1.2
		jumpFrames = jumpFrames - 1
	elseif self.thing.onground == true and not (self.state == "crawling")
	then
		jumpFrames = self.state == "crouching" and 2 or 10
	else
		jumpFrames = 0
	end

	if not (math.abs (self.thing.momy) < 0.1)
	and not (self.state == "jumping")
	then
		self.sprite:setFrame ("jump1")
		self.state = "jumping"
	end

	if love.keyboard.isDown ("down") and not (self.state == "crouching") and self.thing.onground and self.thing.momx == 0
	then
		self.sprite:setFrame ("crouch1")
		self.state = "crouching"
		self.thing.h = 6
		self.thing.y = self.thing.y + 6
		self.sprite.offsy = -10
	end

	-- reset the above, if needed
	if not (self.state == "crouching" or self.state == "crawling") and self.thing.h == 6
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
			elseif self.state == "crouching"
			then
				self.sprite:setFrame ("crawl2")
				self.state = "crawling"
				jumpFrames = 0 -- eeeeeeeeeeehhhhg
			end

			self.thing.momx = (self.state == "walking" and 0.6 or 0.3) * direction
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
		if not (self.state == "crouching") and not (self.state == "crawling")
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

	-- TODO: level widths can be variable, magic numbers here = bad
	if self.thing.x < 0 and not (type (curlevel.left) == "nil") -- exit left
	then
		curlevel = Level.new (curlevel.left)
		self.thing.x = 192 - self.thing.w
	elseif self.thing.x + self.thing.w > 192 and not (type (curlevel.right) == "nil") -- exit right
	then
		curlevel = Level.new (curlevel.right)
		self.thing.x = 0
	end
end
