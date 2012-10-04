Level = { }
Level.__index = Level

function Level.new (bg, tiles)
	local tmp = { }
	local tiles = love.image.newImageData (tiles)

	setmetatable (tmp, Level)
	tmp.bg = love.graphics.newImage (bg)
	tmp.tiles = { }

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
