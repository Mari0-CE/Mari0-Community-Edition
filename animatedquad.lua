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
	else
		for i, v in ipairs(self.properties) do
			if self.props.collision ~= v.collision or self.props.portalable ~= v.portalable then
				self.cache = {}
				break
			end
		end
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
	
	if self.cache then
		if oldcol ~= self.props.collision then
			for i, v in ipairs(self.cache) do
				local x = v.x
				local y = v.y
				if self.props.collision then
					objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
				else
					objects["tile"][x .. "-" .. y] = nil
					checkportalremove(x, y)
				end
			end
		end
		
		if oldportalable ~= self.props.portalable then
			for i, v in ipairs(self.cache) do
				local x = v.x
				local y = v.y
				if oldportalable ~= self.portalable then
					if not self.props.portalable then
						checkportalremove(x, y)
					end
				end
			end
		end
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
			self:updateproperties()
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