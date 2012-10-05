Level = { }
Level.__index = Level

levels =
{
	cliff_bridge = { "res/bgs/cliff_bridge.png", "res/levels/cliff_bridge_level.png", nil, "cliff_bed" },
	cliff_bed = { "res/bgs/cliff_bed.png", "res/levels/cliff_bed_level.png", "cliff_bridge", "outfor_ladder" },
	outfor_ladder = { "res/bgs/outfor_ladder.png", "res/levels/outfor_ladder_level.png", "cliff_bed", "outfor_plats1" },
	outfor_plats1 = { "res/bgs/outfor_plats1.png", "res/levels/outfor_plats1_level.png", "outfor_ladder", nil },
}

startlevel = "outfor_plats1"

function Level.new (idx)
	local info = levels [idx]
	local tmp = { }
	local tiles = love.image.newImageData (info [2])

	setmetatable (tmp, Level)
	tmp.bg = love.graphics.newImage (info [1])
	tmp.tiles = { }
	tmp.left = info [3]
	tmp.right = info [4]

	for y = 0, tiles:getHeight () - 1
	do
		tmp.tiles [y + 1] = { }
		for x = 0, tiles:getWidth () - 1
		do
			r, g, b, a = tiles:getPixel (x, y)
			if r == 0 and g == 0 and b == 0
			then
				tmp.tiles [y + 1] [x + 1] = 1
			else
				tmp.tiles [y + 1] [x + 1] = 0
			end
		end
	end

	return tmp
end
