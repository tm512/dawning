require 'sprite'
require 'player'

Level = { }
Level.__index = Level

-- { bg, tiles, ambience, srate, left, right, up, down, { door1, spawnx, spawny }, { door2, spawnx, spawny }, { door2, spawnx, spawny } }
levels =
{
	bridge = { "res/bgs/bridge.png", "res/levels/bridge_level.png", "res/sound/ambient_cliffs.ogg", nil, nil, "cliff_bridge", nil, nil },
	cliff_bridge = { "res/bgs/cliff_bridge.png", "res/levels/cliff_bridge_level.png", "res/sound/ambient_cliffs.ogg", nil,
	                nil, "cliff_bed", nil, "cliff_lower", { "cliff_bridgefix", 96, 68, { "hammer", "nails", "planks" } } },
	cliff_bridgefix = { "res/bgs/cliff_bridge.png", "res/levels/cliff_bridgefix_level.png", "res/sound/ambient_cliffs.ogg", nil,
	                   "bridge", "cliff_bed", nil, "cliff_lower" },
	cliff_lower = { "res/bgs/cliff_lower.png", "res/levels/cliff_lower_level.png", "res/sound/ambient_cliffs.ogg", nil,
	               nil, "cliff_tunnel", nil, nil },
	cliff_tunnel = { "res/bgs/cliff_tunnel.png", "res/levels/cliff_tunnel_level.png", "res/sound/ambient_cave.ogg", 2400,
	                "cliff_lower", nil, nil, nil, { "outfor_ladder", 80, 36, nil, "ladder" } },
	cliff_bed = { "res/bgs/cliff_bed.png", "res/levels/cliff_bed_level.png", "res/sound/ambient_outfor.ogg", nil,
	             "cliff_bridge", "outfor_ladder" },
	outfor_ladder = { "res/bgs/outfor_ladder.png", "res/levels/outfor_ladder_level.png", "res/sound/ambient_outfor.ogg", 1200,
	                 "cliff_bed", "outfor_plats1", nil, nil, { "cliff_tunnel", 280, 20, nil, "ladder" } },
	outfor_plats1 = { "res/bgs/outfor_plats1.png", "res/levels/outfor_plats1_level.png", "res/sound/ambient_outfor.ogg", 1200,
	                 "outfor_ladder", "outfor_shed" },
	outfor_shed = { "res/bgs/outfor_shed.png", "res/levels/outfor_shed_level.png", "res/sound/ambient_outfor.ogg", 1200,
	               "outfor_plats1", "outfor_plats2", nil, nil, { "cabin_shed", 84, 68, "key_shed", "door" } },
	outfor_plats2 = { "res/bgs/outfor_plats2.png", "res/levels/outfor_plats2_level.png", "res/sound/ambient_outfor.ogg", 1200,
	                 "outfor_shed", "outfor_cabin" },
	outfor_cabin = { "res/bgs/outfor_cabin.png", "res/levels/outfor_cabin_level.png", "res/sound/ambient_outfor.ogg", 1200,
	                "outfor_plats2", "outfor_gate", nil, nil, { "cabin_main", 68, 68, "key_cabin", "door" } },
	outfor_gate = { "res/bgs/outfor_gate.png", "res/levels/outfor_gate_level.png", "res/sound/ambient_outfor.ogg", 1200,
	               "outfor_cabin", "infor_plats1", nil, nil, { "outfor_gate", 114, 68, "key_gate", "door" },
	               { "outfor_gate", 70, 68, nil, "door" } },
	cabin_shed = { "res/bgs/cabin_shed.png", "res/levels/cabin_shed_level.png", nil, 600,
	              nil, nil, nil, nil, { "outfor_shed", 100, 68, nil, "door" }, { "cave_ladder", 136, 12, nil, "ladder" } },
	cabin_main = { "res/bgs/cabin_main.png", "res/levels/cabin_main_level.png", "res/sound/ambient_cabin.ogg", 600,
	              nil, nil, nil, nil, { "outfor_cabin", 140, 68, nil, "door" }, { "cabin_cellar", 144, 52, nil, "ladder" },
	              { "cabin_upper", 56, 68, nil, "ladder" } },
	cabin_upper = { "res/bgs/cabin_upper.png", "res/levels/cabin_upper_level.png", nil, 600,
	               nil, nil, nil, nil, { "cabin_main", 20, 68, nil, "ladder" } },
	cabin_cellar = { "res/bgs/cabin_cellar.png", "res/levels/cabin_cellar_level.png", nil, 600,
	                nil, nil, nil, nil, { "cabin_main", 144, 68, nil, "ladder" }, { "room_heads", 20, 52, nil, "door" } },
	cave_ladder = { "res/bgs/cave_ladder.png", "res/levels/cave_ladder_level.png", "res/sound/ambient_cave.ogg", 1080,
	               "cave_plats1", nil, nil, nil, { "cabin_shed", 48, 68, nil, "ladder" } },
	cave_plats1 = { "res/bgs/cave_plats1.png", "res/levels/cave_plats1_level.png", "res/sound/ambient_cave.ogg", 1080,
	               nil, "cave_ladder", nil, nil, { "cave_plats2", 24, 44, nil, "ladder" } },
	cave_plats2 = { "res/bgs/cave_plats2.png", "res/levels/cave_plats2_level.png", "res/sound/ambient_cave.ogg", 1080,
	               "room_beds", nil, nil, nil, { "cave_plats1", 24, 36, nil, "ladder" }, { "cave_end", 160, 60, nil, "ladder" } },
	cave_end = { "res/bgs/cave_end.png", "res/levels/cave_end_level.png", "res/sound/ambient_cave.ogg", 1080,
	            nil, nil, nil, nil, { "cave_plats2", 352, 52, nil, "ladder" } },
	infor_plats1 = { "res/bgs/infor_plats1.png", "res/levels/infor_plats1_level.png", "res/sound/ambient_infor.ogg", 900,
	                "outfor_gate", "infor_plats2", nil, nil, { "room_cell", 153, 28, nil, "ladder" } },
	infor_plats2 = { "res/bgs/infor_plats2.png", "res/levels/infor_plats2_level.png", "res/sound/ambient_infor.ogg", 900,
	                "infor_plats1", "infor_wall" },
	infor_wall = { "res/bgs/infor_wall.png", "res/levels/infor_wall_level.png", "res/sound/ambient_infor.ogg", 900,
	              "infor_plats2", nil },
	room_heads = { "res/bgs/room_heads.png", "res/levels/room_heads_level.png", nil, nil, nil, nil, nil, nil,
	              { "cabin_cellar", 164, 52, nil, "door" } },
	room_beds = { "res/bgs/room_beds.png", "res/levels/room_beds_level.png", nil, nil, nil, "cave_plats2" },
	room_cell = { "res/bgs/room_cell.png", "res/levels/room_cell_level.png", nil, nil, nil, nil, nil, nil,
	             { "infor_plats1", 298, 60, nil, "ladder" } },
}

startlevel = "cliff_bed"

lanims =
{
	closed = { 0, 0, -1, nil },
	opened = { 1, 0, -1, nil }
}

banims =
{
	broken = { 0, 1, -1, nil },
	fixed = { 0, 0, -1, nil }
}

function Level.new (idx)
	local info = levels [idx]
	local tmp = { }
	local tiles = love.image.newImageData (info [2])

	setmetatable (tmp, Level)
	tmp.bg = love.graphics.newImage (info [1])
	tmp.tiles = { }
	tmp.items = { }
	tmp.srate = info [4]
	tmp.left = info [5]
	tmp.right = info [6]
	tmp.up = info [7]
	tmp.down = info [8]
	tmp.door1 = info [9]
	tmp.door2 = info [10]
	tmp.door3 = info [11]

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
			elseif r == 0 and g == 255 and b == 0 -- cabin key
			then
				tmp.tiles [y + 1] [x + 1] = 5
				if not Player.inv ["key_cabin"]
				then
					tmp.items ["key_cabin"] = Sprite.new ("res/objects/items/item.png", 8, 8, x * 8, y * 8)
				end
			elseif r == 0 and g == 200 and b == 0 -- shed key
			then
				tmp.tiles [y + 1] [x + 1] = 6
				if not Player.inv ["key_shed"]
				then
					tmp.items ["key_shed"] = Sprite.new ("res/objects/items/item.png", 8, 8, x * 8, y * 8)
				end
			elseif r == 0 and g == 150 and b == 0 -- gate key (locked)
			then
				tmp.tiles [y + 1] [x + 1] = 7
				tmp.lockbox = { }
				tmp.lockbox.sprite = Sprite.new ("res/objects/items/lockbox.png", 8, 8, x * 8, y * 8, lanims)
				tmp.lockbox.item = "key_gate"
				if not Player.inv ["key_gate"]
				then
					tmp.lockbox.sprite:setFrame ("closed")
				else
					tmp.lockbox.sprite:setFrame ("opened")
				end
			elseif r == 255 and g == 0 and b == 0 -- planks
			then
				tmp.tiles [y + 1] [x + 1] = 8
				if not Player.inv ["planks"]
				then
					tmp.items ["planks"] = Sprite.new ("res/objects/items/item.png", 8, 8, x * 8, y * 8)
				end
			elseif r == 200 and g == 0 and b == 0 -- nails (locked)
			then
				tmp.tiles [y + 1] [x + 1] = 9
				tmp.lockbox = { }
				tmp.lockbox.sprite = Sprite.new ("res/objects/items/lockbox.png", 8, 8, x * 8, y * 8, lanims)
				tmp.lockbox.item = "nails"
				if not Player.inv ["nails"]
				then
					tmp.lockbox.sprite:setFrame ("closed")
				else
					tmp.lockbox.sprite:setFrame ("opened")
				end
			elseif r == 150 and g == 0 and b == 0 -- crowbar
			then
				tmp.tiles [y + 1] [x + 1] = 10
				if not Player.inv ["crowbar"]
				then
					tmp.items ["crowbar"] = Sprite.new ("res/objects/items/item.png", 8, 8, x * 8, y * 8)
				end
			elseif r == 100 and g == 0 and b == 0 -- hammer
			then
				tmp.tiles [y + 1] [x + 1] = 11
				if not Player.inv ["hammer"]
				then
					tmp.items ["hammer"] = Sprite.new ("res/objects/items/item.png", 8, 8, x * 8, y * 8)
				end
			elseif r == 50 and g == 0 and b == 0 -- head (secret)
			then
				tmp.tiles [y + 1] [x + 1] = 12
				if not Player.inv ["head"]
				then
					tmp.items ["head"] = Sprite.new ("res/objects/items/item_head.png", 8, 8, x * 8, y * 8)
				end
			else
				tmp.tiles [y + 1] [x + 1] = 0
			end
		end
	end

	-- spawn the bridge if we need to
	-- swap out bridge levels
	if levels [idx] [2] == "res/levels/cliff_bridge_level.png" or levels [idx] [2] == "res/levels/cliff_bridgefix_level.png"
	then
		tmp.bridge = Sprite.new ("res/objects/items/bridge_short.png", 102, 16, 0, 66, banims)
		if levels [idx] [2] == "res/levels/cliff_bridge_level.png"
		then
			tmp.bridge:setFrame ("broken")
		else
			tmp.bridge:setFrame ("fixed")
			levels ["cliff_bridge"] = levels ["cliff_bridgefix"]
		end
	end

	if levels [idx] [2] == "res/levels/bridge_level.png"
	then
		tmp.bridge = Sprite.new ("res/objects/items/bridge_long.png", 192, 16, 0, 66)
	end

	-- switch music if we need to
	if not (ambience.name == info [3])
	then
		if ambience.source
		then
			ambience.source:stop ()
		end

		if info [3]
		then
			ambience.source = love.audio.newSource (info [3])
			ambience.source:setLooping (true)
			ambience.source:setVolume (0.6)
			ambience.source:play ()
		end

		ambience.name = info [3]
	end

	return tmp
end
