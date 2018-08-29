entitytooltip = class("entitytooltip")

local theight = 64
local twidth = 64
local descwidth = 0
twidth = twidth + descwidth*8

function entitytooltip:init(ent)
	self.ent = ent
end

function entitytooltip:update(dt)
	self.x = math.min(mouse.getX(), width*16*scale-(twidth+4)*scale)
	self.y = math.max(0, mouse.getY()-(theight+4)*scale)
end

function entitytooltip:draw(a)
	if tooltipimages[self.ent.i] then
		love.graphics.setColor(1, 1, 1, a)
		properprintbackground(self.ent.t, self.x, self.y, true)
		love.graphics.setColor(0, 0, 0, a)
		drawrectangle(self.x/scale, self.y/scale+8, (twidth+4), (theight+4))
		love.graphics.setColor(1, 1, 1, a)
		drawrectangle(self.x/scale+1, self.y/scale+9, 66, theight+2)
		
		local r, g, b = love.graphics.getBackgroundColor()
		love.graphics.setColor(r, g, b, a)
		love.graphics.rectangle("fill", self.x+2*scale, self.y+10*scale, 64*scale, 64*scale)
		love.graphics.setColor(1, 1, 1, a)
		love.graphics.draw(tooltipimages[self.ent.i], self.x+2*scale, self.y+10*scale, 0, scale, scale)
	end
end