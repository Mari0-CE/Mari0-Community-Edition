animatedtiletrigger = class("animatedtiletrigger")

function animatedtiletrigger:init(x, y, r)
	self.x = x
	self.y = y
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	self.visible = true
	
	--VISIBLE
	if #self.r > 0 and self.r[1] ~= "link" then
		self.visible = (self.r[1] == "true")
		table.remove(	self.r, 1)
	end
	
	--REGION
	if #self.r > 0 then
		local s = self.r[1]:split(":")
		self.regionX, self.regionY, self.regionwidth, self.regionheight = s[2], s[3], tonumber(s[4]), tonumber(s[5])
		if string.sub(self.regionX, 1, 1) == "m" then
			self.regionX = -tonumber(string.sub(self.regionX, 2))
		end
		if string.sub(self.regionY, 1, 1) == "m" then
			self.regionY = -tonumber(string.sub(self.regionY, 2))
		end
		
		self.regionX = tonumber(self.regionX) + self.x - 1
		self.regionY = tonumber(self.regionY) + self.y - 1
		table.remove(self.r, 1)
	end
end

function animatedtiletrigger:link()
	while #self.r > 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[3]) == v.cox and tonumber(self.r[4]) == v.coy then
					v:addoutput(self, self.r[2])
				end
			end
		end
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function animatedtiletrigger:update()

end

function animatedtiletrigger:draw()	
	if self.visible then
		love.graphics.draw(animatedtiletriggerimg, math.floor((self.x-1-xscroll)*16*scale), ((self.y-yscroll-1)*16-8)*scale, 0, scale, scale)
	end
end

function animatedtiletrigger:input(t, input)
	for x = self.regionX+1, self.regionX + self.regionwidth do
		for y = self.regionY+1, self.regionY + self.regionheight do
			if animatedtimers[x] and animatedtimers[x][y] then
				animatedtimers[x][y]:input(t)
			end
		end
	end
end