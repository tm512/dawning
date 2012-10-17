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
			self.thing.x = math.random (self.thing.w * 3, curlevel.bg:getWidth () - self.thing.w * 4)
		elseif Player.thing.x == 0
		then
			self.thing.x = curlevel.bg:getWidth () - self.thing.w * 2
		else
			self.thing.x = self.thing.w
		end

		while (not isBlocked (self.thing.x, self.thing:bottom (), 1)) and self.thing:bottom () < curlevel.bg:getHeight ()
		do
			self.thing.y = self.thing.y + 8
		end

		if not (self.thing:bottom () == curlevel.bg:getHeight ())
		and not isBlocked (self.thing.x, self.thing.y, 1) and not isBlocked (self.thing:right (), self.thing.y, 1)
		and math.abs ((Player.thing.x + Player.thing.w / 2) - (self.thing.x + self.thing.w / 2)) > 16
		then
			self.visible = true
			self.lifetime = (type (x) == "nil") and math.random (420, 1020) or math.random (60, 300)
		end
	end
end
