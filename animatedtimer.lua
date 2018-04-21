animatedtimer = class("animatedtimer")
animatedtimerlist = {}

function animatedtimer:init(x, y, tileno)
	self.x = x
	self.y = y
	self.quadi = 1
	self.timer = 0
	self.quadobj = tilequads[tileno]
	self.delays = self.quadobj.delays
	self.frametimes = {}
	self.length = 0
	for i = 1, #self.delays do
		self.length = self.length + self.delays[i]
		self.frametimes[i] = self.length
	end
	self.dir = 0
	
	table.insert(animatedtimerlist, self)
end

function animatedtimer:update(dt)
	local oldi = self:geti()
	self.timer = self.timer + dt*self.dir
	
	if self.timer > self.length then
		self.timer = self.length
		self.dir = 0
	elseif self.timer < 0 then
		self.timer = 0
		self.dir = 0
	end
	local newi = self:geti()
	
	if oldi ~= newi then
		local oldcol = self.quadobj.properties[oldi].collision
		local oldportalable = self.quadobj.properties[oldi].portalable
		
		local props = self.quadobj.properties[newi]
		
		if oldcol ~= props.collision then
			if props.collision then
				objects["tile"][self.x .. "-" .. self.y] = tile:new(self.x-1, self.y-1)
			else
				objects["tile"][self.x .. "-" .. self.y] = nil
				checkportalremove(self.x, self.y)
			end
		end
		
		if oldportalable ~= props.portalable then
			if not props.portalable then
				checkportalremove(self.x, self.y)
			end
		end
	end
end

function animatedtimer:input(t)
	if t == "on" then
		self.dir = 1
	elseif t == "off" then
		self.dir = -1
	elseif t == "toggle" then
		self.dir = -self.dir
		
		if self.dir == 0 then
			if self.timer == 0 then
				self.dir = 1
			else
				self.dir = -1
			end
		end
	end
end

function animatedtimer:geti()
	for i = 2, #self.frametimes do
		if self.timer > self.frametimes[i-1] and self.timer <= self.frametimes[i] then
			return i
		end
	end
	
	return 1
end