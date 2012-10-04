-- animated sprite/quad
Sprite = { }
Sprite.__index = Sprite

function Sprite.new (path, w, h, offsx, offsy, anims)
	local tmp = { }

	setmetatable (tmp, Sprite)
	tmp.tex = love.graphics.newImage (path)
	tmp.w = w
	tmp.h = h
	tmp.offsx = offsx
	tmp.offsy = offsy
	tmp.quad = love.graphics.newQuad (0, 0, w, h, tmp.tex:getWidth (), tmp.tex:getHeight ())
	tmp.flip = "left"
	tmp.anims = anims
	tmp.frames = 0
	tmp.curframe = ""

	return tmp
end

function Sprite:setFrame (frame)
	self.curframe = frame
	self.frames = self.anims [frame] [3]
	self.quad:setViewport (self.anims [frame] [1] * self.w, self.anims [frame] [2] * self.h, self.w, self.h)
end

function Sprite:advFrame ()
	if self.frames > 0
	then
		self.frames = self.frames - 1
	elseif self.frames == 0
	then
		self:setFrame (self.anims [self.curframe] [4])
	end
end

function Sprite:getFlip ()
	return self.flip == "left" and 1 or -1
end

function Sprite:setFlip (f)
	if not (self.flip == f)
	then
		self.flip = f
	end
end
