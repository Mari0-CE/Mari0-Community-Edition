entitylistitem = class("entitylistitem")

function entitylistitem:init(t, i)
	self.x = x
	self.y = y
	self.t = t
	self.i = i
end

function entitylistitem:gethighlight(x, y)
	x = x/scale-5
	y = y/scale-38+tilesoffset/scale
	
	return x >= self.x and x < self.x+16 and y >= self.y and y < self.y+16
end

function getentityhighlight(x, y)
	for i, v in ipairs(entitylistitems) do
		for j, k in ipairs(v.entries) do
			if k:gethighlight(mouse.getX(), mouse.getY()) then
				return k
			end
		end
	end
end