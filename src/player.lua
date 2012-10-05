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
	elseif self.thing.onground == true
	then
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
			self.thing.momx = 0.6 * direction
			if self.state == "standing" or self.state == "jumping"
			then
				self.sprite:setFrame ("walk1")
				self.state = "walking"
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
		self.sprite:setFrame ("standing")
		self.state = "standing"
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
