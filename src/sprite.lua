--[[
     Copyright (c) 2012 - 2013, Kyle Davis
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
		if self.anims [self.curframe] [5]
		then
			self.anims [self.curframe] [5] ()
		end
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
