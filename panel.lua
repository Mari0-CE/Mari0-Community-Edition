panel = class("panel")

function panel:init(x, y, t)
	self.cox = x+1
	self.coy = y+1
	
	self.dir = "right"
	self.out = false
	self.input1state = "off"
	
	--Input list
	self.t = {unpack(t)}
	table.remove(self.t, 1)
	table.remove(self.t, 1)
	--Dir
	if #self.t > 0 then
		self.dir = self.t[1]
		table.remove(self.t, 1)
	end
	--Start white
	if #self.t > 0 then
		self.out = self.t[1] == "true"
		table.remove(self.t, 1)
	end
	
	if self.dir == "up" then
		self.dir = "top"
	elseif self.dir == "down" then
		self.dir = "bottom"
	end
	
	if self.dir == "left" then
		self.r = 0
	elseif self.dir == "top" then
		self.r = math.pi/2
	elseif self.dir == "right" then
		self.r = math.pi
	elseif self.dir == "bottom" then
		self.r = math.pi*1.5
	end
	
	self:link()
	self:updatestuff()
end

function panel:link()
	while #self.t > 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.t[3]) == v.cox and tonumber(self.t[4]) == v.coy then
					v:addoutput(self, self.t[2])
				end
			end
		end
		table.remove(self.t, 1)
		table.remove(self.t, 1)
		table.remove(self.t, 1)
		table.remove(self.t, 1)
	end
end

function panel:draw()
	local quad = 2
	if self.out then
		quad = 1
	end
	
	love.graphics.drawq(panelimg, panelquad[quad], math.floor((self.cox-1-xscroll+.5)*16*scale), math.floor((self.coy-1-yscroll)*16*scale), self.r, scale, scale, 8, 8)
end

function panel:input(t, input)
	if input == "power" then
		if t == "on" and self.input1state == "off" then
			self.out = true
		elseif t == "off" and self.input1state == "on" then
			self.out = false
		elseif t == "toggle" then
			self.out = not self.out
		end
		
		self.input1state = t
		
		self:updatestuff()
	end
end
	
function panel:updatestuff()
	map[self.cox][self.coy]["portaloverride"][self.dir] = self.out
	
	if self.out == false and tilequads[map[self.cox][self.coy][1]]:getproperty("portalable", self.cox, self.coy) == false then
		checkportalremove(self.cox, self.coy)
	end
end