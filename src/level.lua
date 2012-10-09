Level = { }
Level.__index = Level

-- { bg, tiles, left, right, up, down, { door1, spawnx, spawny }, { door2, spawnx, spawny }, { door2, spawnx, spawny } }
levels =
{
	cliff_bridge = { "res/bgs/cliff_bridge.png", "res/levels/cliff_bridge_level.png", nil, "cliff_bed", nil, "cliff_lower" },
	cliff_lower = { "res/bgs/cliff_lower.png", "res/levels/cliff_lower_level.png", nil, "cliff_tunnel", nil, nil },
	cliff_tunnel = { "res/bgs/cliff_tunnel.png", "res/levels/cliff_tunnel_level.png", "cliff_lower", nil, nil, nil,
	                { "outfor_ladder", 80, 36 } },
	cliff_bed = { "res/bgs/cliff_bed.png", "res/levels/cliff_bed_level.png", "cliff_bridge", "outfor_ladder" },
	outfor_ladder = { "res/bgs/outfor_ladder.png", "res/levels/outfor_ladder_level.png", "cliff_bed", "outfor_plats1", nil, nil,
	                 { "cliff_tunnel", 280, 20 } },
	outfor_plats1 = { "res/bgs/outfor_plats1.png", "res/levels/outfor_plats1_level.png", "outfor_ladder", "outfor_shed" },
	outfor_shed = { "res/bgs/outfor_shed.png", "res/levels/outfor_shed_level.png", "outfor_plats1", "outfor_plats2", nil, nil,
	               { "cabin_shed", 84, 68 } },
	outfor_plats2 = { "res/bgs/outfor_plats2.png", "res/levels/outfor_plats2_level.png", "outfor_shed", "outfor_cabin" },
	outfor_cabin = { "res/bgs/outfor_cabin.png", "res/levels/outfor_cabin_level.png", "outfor_plats2", nil, nil, nil,
	                { "cabin_main", 68, 68 } },
	cabin_shed = { "res/bgs/cabin_shed.png", "res/levels/cabin_shed_level.png", nil, nil, nil, nil,
	              { "outfor_shed", 100, 68 }, { "cave_ladder", 136, 12 } },
	cabin_main = { "res/bgs/cabin_main.png", "res/levels/cabin_main_level.png", nil, nil, nil, nil,
	              { "outfor_cabin", 140, 68 }, nil, { "cabin_upper", 56, 68 } },
	cabin_upper = { "res/bgs/cabin_upper.png", "res/levels/cabin_upper_level.png", nil, nil, nil, nil,
	               { "cabin_main", 20, 68 } },
	cave_ladder = { "res/bgs/cave_ladder.png", "res/levels/cave_ladder_level.png", nil, nil, nil, nil,
	               { "cabin_shed", 48, 68 } },
	infor_plats1 = { "res/bgs/infor_plats1.png", "res/levels/infor_plats1_level.png", nil, nil },
}

startlevel = "outfor_plats2"

function Level.new (idx)
	local info = levels [idx]
	local tmp = { }
	local tiles = love.image.newImageData (info [2])

	setmetatable (tmp, Level)
	tmp.bg = love.graphics.newImage (info [1])
	tmp.tiles = { }
	tmp.left = info [3]
	tmp.right = info [4]
	tmp.up = info [5]
	tmp.down = info [6]
	tmp.door1 = info [7]
	tmp.door2 = info [8]
	tmp.door3 = info [9]

	for y = 0, tiles:getHeight () - 1
	do
		tmp.tiles [y + 1] = { }
		for x = 0, tiles:getWidth () - 1
		do
			r, g, b, a = tiles:getPixel (x, y)
			if r == 0 and g == 0 and b == 0 -- solid
			then
				tmp.tiles [y + 1] [x + 1] = 1
			elseif r == 255 and g == 255 and b == 0 -- door 1
			then
				tmp.tiles [y + 1] [x + 1] = 2
			elseif r == 255 and g == 0 and b == 255 -- door 2
			then
				tmp.tiles [y + 1] [x + 1] = 3
			elseif r == 0 and g == 255 and b == 255 -- door 3
			then
				tmp.tiles [y + 1] [x + 1] = 4
			else
				tmp.tiles [y + 1] [x + 1] = 0
			end
		end
	end

	return tmp
end
