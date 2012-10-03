require 'thing'

testMap =
{
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 },
	{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1 },
	{ 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
	{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1 },
	{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
}

function love.load ()
	ret = love.graphics.setMode (192, 96, false, false, 0)
	love.graphics.setCaption ("october")
	if ret == 0
	then
		error ("couldn't set screen mode")
	end

	player = Thing.new (32, 12, 8, 12)
end

local frametime = 1.0 / 60
local nextframe = 0
local curtime = 0

jumpFrames = 10
function love.update (dt)
	-- skip if we're running ahead
	if nextframe == 0
	then
		nextframe = dt
	end

	curtime = curtime + dt
	if curtime < nextframe
	then
		return
	end
	nextframe = nextframe + frametime

	-- accelerate upwards for 10 frames at most
	if love.keyboard.isDown ("up") and jumpFrames > 0
	then
		player.momy = 1.2
		jumpFrames = jumpFrames - 1
	elseif player.onground == true
	then
		jumpFrames = 10
	else
		jumpFrames = 0
	end

	local direction = 0
	if love.keyboard.isDown ("left")
	then
		direction = -1
	end

	if love.keyboard.isDown ("right")
	then
		direction = 1
	end

	-- move left/right
	if direction
	then
		-- on ground? Accelerate immediately and don't worry about switching directions
		if player.onground == true
		then
			player.momx = 0.6 * direction
		else
			-- same direction
			if (player.momx < 0 and direction < 0) or (player.momx > 0 and direction > 0) or player.momx == 0
			then
				player.momx = 0.5 * direction
			else
				player.momx = player.momx * -0.3
			end
		end
	elseif player.onground == true
	then
		player.momx = 0
	end

	player:doPhysics ()
end

function love.draw ()
	love.graphics.setColor (0xff, 0xff, 0xff, 0xff)
	love.graphics.rectangle ("fill", player.x, player.y, player.w, player.h)
	love.graphics.setColor (0xff, 0xa5, 0x00, 0xff)
	for i = 1, #testMap [1]
	do
		for j = 1, #testMap
		do
			if testMap [j] [i] == 1
			then
				love.graphics.rectangle ("fill", (i - 1) * 8, (j - 1) * 8, 8, 8)
			end
		end
	end
end
