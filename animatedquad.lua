animatedquad = class("animatedquad")

function animatedquad:init(imgpath, s, number)
	self.number = number
	self.image = love.graphics.newImage(imgpath)
	self.imagedata = love.image.newImageData(imgpath)
	self.quadlist = {}
	for x = 1, math.floor(self.image:getWidth()/17) do
		table.insert(self.quadlist, love.graphics.newQuad((x-1)*17, 0, 16, 16, self.image:getWidth(), self.image:getHeight()))
	end
	self.quadi = 1
	self.properties = {}
	for x = 1, #self.quadlist do
		self.properties[x] = getquadprops(self.imagedata, x, 1)
	end
	self.props = self.properties[self.quadi]
	self.delays = {}
	self.timer = 0
	self.spikes = {}
	
	self.delays = s:split(",")
	
	if self.delays[1] == "triggered" then
		self.triggered = true
		table.remove(self.delays, 1)
	end
	
	for i = 1, #self.delays do
		self.delays[i] = tonumber(self.delays[i])
	end
	
	local delaycount = #self.delays
	for j = #self.delays+1, #self.quadlist do
		self.delays[j] = self.delays[math.mod(j-1, delaycount)+1]
	end
	
end

function animatedquad:updateproperties()
	local oldcol = self.props.collision
	local oldportalable = self.props.portalable
	
	self.props = self.properties[self.quadi]
	
	if oldcol ~= self.props.collision then
		prof.push("collision check")
		for x = 1, mapwidth do
			for y = 1, mapheight do
				if map[x][y][1] == self.number then
					if self.props.collision then
						objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
					else
						objects["tile"][x .. "-" .. y] = nil
						checkportalremove(x, y)
					end
				end
			end
		end
		prof.pop("collision check")
	end
	
	if oldportalable ~= self.props.portalable then
		prof.push("portalable check")
		for x = 1, mapwidth do
			for y = 1, mapheight do
				if map[x][y][1] == self.number then
					if oldportalable ~= self.portalable then
						if not self.props.portalable then
							checkportalremove(x, y)
						end
					end
				end
			end
		end
		prof.pop("portalable check")
	end
end

function animatedquad:update(dt)
	self.timer = self.timer + dt
	while self.timer > self.delays[self.quadi] do
		self.timer = self.timer - self.delays[self.quadi]
		self.quadi = self.quadi + 1
		if self.quadi > #self.quadlist then
			self.quadi = 1
		end
		if objects and not self.triggered then
			prof.push("update properties")
			self:updateproperties()
			prof.pop("update properties")
		end
	end
end

function animatedquad:quad(x, y)
	if self.triggered and x and y and animatedtimers[x][y] then
		return self.quadlist[animatedtimers[x][y]:geti()]
	else
		return self.quadlist[self.quadi]
	end
end

function animatedquad:getproperty(s, x, y)
	if self.triggered and x and y and animatedtimers[x] and animatedtimers[x][y] then
		if self.properties[animatedtimers[x][y]:geti()] then
			return self.properties[animatedtimers[x][y]:geti()][s]
		end
	end
	return self.props[s]
end