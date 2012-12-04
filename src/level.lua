--[[
     Copyright (c) 2012, Kyle Davis
     All rights reserved.
     
     Redistribution and use in source and binary forms, with or without
     modification, are permitted provided that the following conditions are met:
         * Redistributions of source code must retain the above copyright
           notice, this list of conditions and the following disclaimer.
         * Redistributions in binary form must reproduce the above copyright
           notice, this list of conditions and the following disclaimer in the
           documentation and/or other materials provided with the distribution.
         * Neither the name of the <organization> nor the
           names of its contributors may be used to endorse or promote products
           derived from this software without specific prior written permission.
     
     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
     ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
     DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
     DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
     (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
     ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
     (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
     SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]--

require 'sprite'
require 'player'

Level = { }
Level.__index = Level

bridgebak = { } -- use to back up broken bridge

areas =
{
	cliff = { "res/sound/ambient_cliffs.ogg", 0x14, 0x0d, 0x00 },
	cliff2 = { "res/sound/ambient_outfor.ogg", 0x14, 0x0d, 0x00 },
	outfor = { "res/sound/ambient_outfor.ogg", 0x03, 0x0d, 0x03 },
	indoor = { nil, 0x3b, 0x3b, 0x00 },
	cabin = { "res/sound/ambient_cabin.ogg", 0x3b, 0x3b, 0x00 },
	cave = { "res/sound/ambient_cave.ogg", 0x20, 0x16, 0x0a },
	infor = { "res/sound/ambient_infor.ogg", 0x00, 0x00, 0x15 },
	pond = { nil, 0x07, 0x21, 0x33 },
	secret = { nil, 0x34, 0x09, 0x09 }
}

-- { name, area, srate, left, right, up, down, { door1, spawnx, spawny }, { door2, spawnx, spawny }, { door2, spawnx, spawny } }
levels =
{
	bridge = { "bridge", "cliff", nil, "bridge", "bridge" },
	bedroom = { "bedroom" },
	cliff_bridge = { "cliff_bridge", "cliff", nil, nil, "cliff_bed", nil, "cliff_lower",
	                { "cliff_bridgefix", 96, 68, { "hammer", "nails", "planks" } } },
	cliff_bridgefix = { "cliff_bridgefix", "cliff", nil, "bridge", "cliff_bed", nil, "cliff_lower" },
	cliff_lower = { "cliff_lower", "cliff", nil, nil, "cliff_tunnel", nil, nil },
	cliff_tunnel = { "cliff_tunnel", "cave", 2400, "cliff_lower", nil, nil, nil, { "outfor_ladder", 80, 36, nil, "ladder" } },
	cliff_bed = { "cliff_bed", "cliff2", nil, "cliff_bridge", "outfor_ladder" },
	outfor_ladder = { "outfor_ladder", "outfor", 1200,
	                 "cliff_bed", "outfor_plats1", nil, nil, { "cliff_tunnel", 280, 20, nil, "ladder" } },
	outfor_plats1 = { "outfor_plats1", "outfor", 1200, "outfor_ladder", "outfor_shed" },
	outfor_shed = { "outfor_shed", "outfor", 1200,
	               "outfor_plats1", "outfor_plats2", nil, nil, { "cabin_shed", 84, 68, "key_shed", "door" } },
	outfor_plats2 = { "outfor_plats2", "outfor", 1200, "outfor_shed", "outfor_cabin" },
	outfor_cabin = { "outfor_cabin", "outfor", 1200,
	                "outfor_plats2", "outfor_store", nil, nil, { "cabin_main", 68, 68, "key_cabin", "door" } },
	outfor_store = { "outfor_store", "outfor", 1200, "outfor_cabin", nil, nil, nil, { "storeroom", 37, 68, nil, "door" } },
	storeroom = { "storeroom", "indoor", nil, nil, nil, nil, nil,
	             { "outfor_store", 141, 68, nil, "door" }, { "infor_store", 44, 68, nil, "door" },
	             { "outfor_store", 141, 68, nil, "door" } },
	cabin_shed = { "cabin_shed", "indoor", 600,
	              nil, nil, nil, nil, { "outfor_shed", 100, 68, nil, "door" }, { "cave_ladder", 136, 12, nil, "ladder" } },
	cabin_main = { "cabin_main", "cabin", 600,
	              nil, nil, nil, nil, { "outfor_cabin", 140, 68, nil, "door" }, { "cabin_cellar", 144, 52, nil, "ladder" },
	              { "cabin_upper", 56, 68, nil, "ladder" } },
	cabin_upper = { "cabin_upper", "indoor", 600, nil, nil, nil, nil, { "cabin_main", 20, 68, nil, "ladder" } },
	cabin_cellar = { "cabin_cellar", "indoor", 600,
	                nil, nil, nil, nil, { "cabin_main", 144, 68, nil, "ladder" }, { "room_heads", 20, 52, nil, "door" } },
	cave_ladder = { "cave_ladder", "cave", 1080, "cave_plats1", nil, nil, nil, { "cabin_shed", 48, 68, nil, "ladder" } },
	cave_plats1 = { "cave_plats1", "cave", 1080, nil, "cave_ladder", nil, nil, { "cave_plats2", 24, 44, nil, "ladder" } },
	cave_plats2 = { "cave_plats2", "cave", 1080,
	               "room_beds", nil, nil, nil, { "cave_plats1", 24, 36, nil, "ladder" }, { "cave_end", 160, 60, nil, "ladder" } },
	cave_end = { "cave_end", "cave", 1080, nil, nil, nil, nil, { "cave_plats2", 352, 52, nil, "ladder" } },
	infor_store = { "infor_store", "infor", 900, nil, "infor_plats1", nil, nil, { "storeroom", 149, 68, nil, "door" } },
	infor_plats1 = { "infor_plats1", "infor", 900, "infor_store", "infor_plats2", nil, nil, { "room_cell", 153, 28, nil, "ladder" } },
	infor_plats2 = { "infor_plats2", "infor", 900, "infor_plats1", "infor_wall" },
	infor_wall = { "infor_wall", "infor", 900, "infor_plats2", nil },
	mines_carts = { "mines_carts", "cave", 900, nil, "mines_plats1" },
	mines_plats1 = { "mines_plats1", "cave", 900, "mines_carts", "mines_plats2" },
	pond_mine = { "pond_mine", "pond", nil, nil, "pond_plats1" },
	pond_plats1 = { "pond_plats1", "pond", nil, "pond_mine", "pond_plats2" },
	pond_plats2 = { "pond_plats2", "pond", nil, "pond_plats1", "pond_hut" },
	pond_hut = { "pond_hut", "pond", nil, "pond_plats2", nil, nil, nil, { "pond_inside", 132, 68, nil, "door" } },
	pond_inside = { "pond_inside", "indoor", nil, nil, nil, nil, nil, { "pond_hut", 68, 52, nil, "door" } },
	room_heads = { "room_heads", "secret", nil, nil, nil, nil, nil, { "cabin_cellar", 164, 52, nil, "door" } },
	room_beds = { "room_beds", "secret", nil, nil, "cave_plats2" },
	room_cell = { "room_cell", "secret", nil, nil, nil, nil, nil, { "infor_plats1", 298, 60, nil, "ladder" } },
	room_cellclosed = { "room_cellclosed" }
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

function newItem (level, item, x, y, head)
	if not Player.inv [item]
	then
		level.items [item] = Sprite.new ("res/objects/items/" .. (head and "item_head.png" or "item.png"), 8, 8, x * 8, y * 8)
		level.tiles [y + 1] [x + 1].item = item
	end
end

function newLockbox (lockbox, item, x, y)
	lockbox.sprite = Sprite.new ("res/objects/items/lockbox.png", 8, 8, x * 8, y * 8, lanims)
	lockbox.item = item
	if not Player.inv [item]
	then
		lockbox.sprite:setFrame ("closed")
	else
		lockbox.sprite:setFrame ("opened")
	end
end

function Level.new (idx)
	local info = levels [idx]
	local tmp = { }
	local tiles = love.image.newImageData ("res/levels/" .. info [1] .. "_level.png")

	setmetatable (tmp, Level)
	tmp.bg = { }
	tmp.tiles = { }
	tmp.items = { }
	tmp.srate = info [3]
	tmp.left = info [4]
	tmp.right = info [5]
	tmp.up = info [6]
	tmp.down = info [7]
	tmp.door1 = info [8]
	tmp.door2 = info [9]
	tmp.door3 = info [10]
	tmp.itemspr = { }

	if love.filesystem.exists ("res/bgs/" .. info [1] .. "_0.png") -- foreground layer
	then
		tmp.fg = love.graphics.newImage ("res/bgs/" .. info [1] .. "_0.png")
	end

	if love.filesystem.exists ("res/bgs/" .. info [1] .. "_1.png") -- parallax
	then
		table.insert (tmp.bg, love.graphics.newImage ("res/bgs/" .. info [1] .. "_1.png"))
		table.insert (tmp.bg, love.graphics.newImage ("res/bgs/" .. info [1] .. "_2.png"))
		table.insert (tmp.bg, love.graphics.newImage ("res/bgs/" .. info [1] .. "_3.png"))
	else
		table.insert (tmp.bg, love.graphics.newImage ("res/bgs/" .. info [1] .. ".png"))
	end

	for y = 0, tiles:getHeight () - 1
	do
		tmp.tiles [y + 1] = { }
		for x = 0, tiles:getWidth () - 1
		do
			tmp.tiles [y + 1] [x + 1] = { }
			r, g, b, a = tiles:getPixel (x, y)
			if r == 0 and g == 0 and b == 0 -- solid
			then
				tmp.tiles [y + 1] [x + 1].type = 1
			elseif r == 255 and g == 255 and b == 0 -- door 1
			then
				tmp.tiles [y + 1] [x + 1].type = 2
			elseif r == 255 and g == 0 and b == 255 -- door 2
			then
				tmp.tiles [y + 1] [x + 1].type = 3
			elseif r == 0 and g == 255 and b == 255 -- door 3
			then
				tmp.tiles [y + 1] [x + 1].type = 4
			elseif r == 0 and g == 255 and b == 0 -- cabin key
			then
				tmp.tiles [y + 1] [x + 1].type = 5
				newItem (tmp, "key_cabin", x, y)
			elseif r == 0 and g == 200 and b == 0 -- shed key
			then
				tmp.tiles [y + 1] [x + 1].type = 5
				newItem (tmp, "key_shed", x, y)
			elseif r == 0 and g == 150 and b == 0 -- gate key (locked)
			then
				tmp.tiles [y + 1] [x + 1].type = 6
				tmp.lockbox = { }
				newLockbox (tmp.lockbox, "key_gate", x, y)
			elseif r == 255 and g == 0 and b == 0 -- planks
			then
				tmp.tiles [y + 1] [x + 1].type = 5
				newItem (tmp, "planks", x, y)
			elseif r == 200 and g == 0 and b == 0 -- nails (locked)
			then
				tmp.tiles [y + 1] [x + 1].type = 6
				tmp.lockbox = { }
				newLockbox (tmp.lockbox, "nails", x, y)
			elseif r == 150 and g == 0 and b == 0 -- crowbar
			then
				tmp.tiles [y + 1] [x + 1].type = 5
				newItem (tmp, "crowbar", x, y)
			elseif r == 100 and g == 0 and b == 0 -- hammer
			then
				tmp.tiles [y + 1] [x + 1].type = 5
				newItem (tmp, "hammer", x, y)
			elseif r == 50 and g == 0 and b == 0 -- head (secret)
			then
				tmp.tiles [y + 1] [x + 1].type = 5
				newItem (tmp, "head", x, y, true)
			elseif r == 0 and g == 0 and b == 255 -- water
			then
				tmp.tiles [y + 1] [x + 1].type = 6
			else
				tmp.tiles [y + 1] [x + 1].type = 0
			end
		end
	end

	-- give item overlays above locked items/doors
	local function keyspr (door, name)
		tmpitems = nil
		if door and door [4]
		then
			tmpitems = { }
			if type (door [4]) == "string"
			then
				tmpitems = { { name = door [4], sprite = Sprite.new ("res/objects/items/" .. door [4] .. ".png", 8, 8, 0, 0, nil) } }
			else
				for i in ipairs (door [4])
				do
					table.insert (tmpitems, { name = door [4] [i], sprite = Sprite.new ("res/objects/items/" .. door [4] [i] .. ".png", 8, 8, 0, 0, nil) })
				end
			end
		end
		tmp.itemspr [name] = tmpitems
	end

	keyspr (tmp.door1, "door1")
	keyspr (tmp.door2, "door2")
	keyspr (tmp.door3, "door3")

	if tmp.lockbox
	then
		tmp.itemspr ["lockbox"] = { { name = "crowbar", sprite = Sprite.new ("res/objects/items/crowbar.png", 8, 8, 0, 0, nil) } }
	end

	-- spawn the bridge if we need to
	-- swap out bridge levels
	if levels [idx] [1] == "cliff_bridge" or levels [idx] [1] == "cliff_bridgefix"
	then
		tmp.bridge = Sprite.new ("res/objects/items/bridge_short.png", 102, 16, 0, 66, banims)
		if levels [idx] [1] == "cliff_bridge"
		then
			tmp.bridge:setFrame ("broken")
		else
			tmp.bridge:setFrame ("fixed")
			bridgebak = levels ["cliff_bridge"]
			levels ["cliff_bridge"] = levels ["cliff_bridgefix"]
		end
	end

	if levels [idx] [1] == "bridge"
	then
		tmp.bridge = Sprite.new ("res/objects/items/bridge_long.png", 192, 16, 0, 66)
	end

	local areadef = areas [info [2]]
	-- switch music if we need to
	if not (ambience.name == areadef [1])
	then
		if ambience.source
		then
			ambience.source:stop ()
		end

		if areadef [1]
		then
			ambience.source = love.audio.newSource (areadef [1])
			ambience.source:setLooping (true)
			ambience.source:setVolume (0.6)
			ambience.source:play ()
		end

		ambience.name = areadef [1]
	end

	-- set particle color to match area
	particle = genParticle (areadef [2], areadef [3], areadef [4])

	-- toggle the start of the ending
	if idx == "bridge"
	then
		endFade = true
	end

	-- remove all particle systems
	psystems = { }

	return tmp
end
