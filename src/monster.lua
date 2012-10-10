require 'thing'
require 'sprite'

Monster = { }

manims =
{
	standing = { 0, 0, -1, nil }
}

Monster.thing = Thing.new (128, 16, 8, 24)
Monster.sprite = Sprite.new ("res/objects/npc/monster.png", 32, 32, -12, -8, manims)
Monster.sprite:setFrame ("standing")
Monster.visible = false

function Monster:logic ()
	if not self.visible
	then
		return
	end

	if Player.thing.x < self.thing.x
	then
		self.sprite:setFlip ("left")
	else
		self.sprite:setFlip ("right")
	end

	self.thing:doPhysics ()
end

function Monster:trySpawn ()
	self.visible = false
	
	if math.random (1, 6) == 6
	then
		self.thing.y = 0
		self.thing.momy = 0
		if Player.thing.x == 0
		then
			self.thing.x = curlevel.bg:getWidth () - self.thing.w * 2
		else
			self.thing.x = self.thing.w
		end

		while (not isBlocked (self.thing.x, self.thing:bottom (), 1)) and self.thing:bottom () < curlevel.bg:getHeight ()
		do
			self.thing.y = self.thing.y + 8
			print ("trying " .. self.thing:bottom ())
		end

		if not (self.thing:bottom () == curlevel.bg:getHeight ()) and not isBlocked (self.thing.x, self.thing.y, 1)
		then
			self.visible = true
		end
	end
end
