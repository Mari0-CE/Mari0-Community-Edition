quad = class("quad")

--COLLIDE?
--INVISIBLE?
--BREAKABLE?
--COINBLOCK?
--COIN?
--_NOT_ PORTALABLE?
--LEFT SLANT?
--RIGHT SLANT?
--MIRROR?
--GRATE?
--PLATFORM TYPE?
--WATER TILE?
--BRIDGE?
--SPIKES?
--FOREGROUND?
function quad:init(img, imgdata, x, y, width, height)
	--get if empty?

	self.image = img
	self.quadobj = love.graphics.newQuad((x-1)*17, (y-1)*17, 16, 16, width, height)
	
	self.props = getquadprops(imgdata, x, y)
end

function quad:getproperty(s)
	return self.props[s]
end

function quad:quad()
	return self.quadobj
end

function getquadprops(imgdata, x, y)
	local self = {}
	
	--get collision
	self.collision = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17)
	if a > 0.5*COLORSPACE then
		self.collision = true
	end
	
	--get invisible
	self.invisible = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+1)
	if a > 0.5*COLORSPACE then
		self.invisible = true
	end
	
	--get breakable
	self.breakable = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+2)
	if a > 0.5*COLORSPACE then
		self.breakable = true
	end
	
	--get coinblock
	self.coinblock = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+3)
	if a > 0.5*COLORSPACE then
		self.coinblock = true
	end
	
	--get coin
	self.coin = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+4)
	if a > 0.5*COLORSPACE then
		self.coin = true
	end
	
	--get not portalable
	self.portalable = true
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+5)
	if a > 0.5*COLORSPACE then
		self.portalable = false
	end
	
	--get left slant
	self.slantupleft = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+6)
	if a > 0.5*COLORSPACE then
		self.slantupleft = true
	end
	
	--get right slant
	self.slantupright = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+7)
	if a > 0.5*COLORSPACE then
		self.slantupright = true
	end
	
	--get mirror
	self.mirror = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+8)
	if a > 0.5*COLORSPACE then
		self.mirror = true
	end
	
	--get grate
	self.grate = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+9)
	if a > 0.5*COLORSPACE then
		self.grate = true
	end
	
	--get platform
	self.platform = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+10)
	if a > 0.5*COLORSPACE then
		self.platform = true
	end
	
	--get watertile
	self.water = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+11)
	if a > 0.5*COLORSPACE then
		self.water = true
	end
	
	--get bridge
	self.bridge = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+12)
	if a > 0.5*COLORSPACE then
		self.bridge = true
	end
	
	--get spikes
	local t = {"left", "top", "right", "bottom"}
	for i = 1, #t do
		local v = t[i]
		self["spikes" .. v] = false
		local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+12+i)
		if a > 0.5*COLORSPACE then
			self["spikes" .. v] = true
		end
	end
	
	--get foreground
	self.foreground = false
	local r, g, b, a = imgdata:getPixel(x*17-2, (y-1)*17+16)
	if a > 0.5 then
		self.foreground = true
	end
	
	return self
end