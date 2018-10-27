dialogbox = class("dialogbox")

function dialogbox:init(text, speaker)
	self.text = string.lower(text)
	self.textsplit = self.text:split(" ")
	self.speaker = string.lower(speaker)
	self.timer = 0
	self.curchar = 0
	self.chartimer = 0
	
	self.lifetime = 5
	self.chardelay = 0.05
	--initialize prefixes
	self.hasaprefix = false
	for n, i in pairs(self.textsplit) do
		local prefix = string.sub(i,1,3)
		if  prefix == "db:" then
			print(i)
			self.textsplit[n] = string.sub(i,4)
			self.hasaprefix = true
		elseif prefix == "gb:" then
			print(i, "bool")
			self.textsplit[n] = globoolSH(string.sub(i,4), "check")
			self.hasaprefix = true
		elseif prefix == "gi:" then
			print(i, "int")
			self.textsplit[n] = globints[string.sub(i,4)] or "uninit"
			self.hasaprefix = true
		elseif prefix == "bi:" then
			print(i, "g_")
			self.textsplit[n] = _G[string.sub(i,4)] or "typo"
			self.hasaprefix = true
		elseif prefix == "bb:" then
			local splitup = string.sub(i,4)
			splitup = splitup:split("/")
				if globoolSH(splitup[1], "check") then
					self.textsplit[n] = splitup[2]
				else
					self.textsplit[n] = splitup[2]
				end
			self.hasaprefix = true
		end
	end
	if self.hasaprefix then
	self.text = table.concat(self.textsplit, " ")
	end
	
	--initialize colors
	local curcolor = {255, 255, 255}
	local i = 1
	self.textcolors = {}
	while i <= #self.text do
		if string.sub(self.text, i, i) == "%" then
			local j = i
			repeat
				j = j + 1
			until string.sub(self.text, j, j) == "%" or j > #self.text
			
			curcolor = string.sub(self.text, i+1, j-1):split(",")
			
			--take out that string
			self.text = string.sub(self.text, 1, i-1) .. string.sub(self.text, j+1)
		else
			self.textcolors[i] = {tonumber(curcolor[1]) / COLORCONVERT, tonumber(curcolor[2]) / COLORCONVERT, tonumber(curcolor[3]) / COLORCONVERT}
			i = i + 1
		end
		
		
	end
end

function dialogbox:update(dt)
	if self.curchar < #self.text then
		self.chartimer = self.chartimer + dt
		while self.chartimer > self.chardelay do
			self.curchar = self.curchar + 1
			self.chartimer = self.chartimer - self.chardelay
		end
	else
		self.timer = self.timer + dt
		if self.timer > self.lifetime then
			return true
		end
	end
end

function dialogbox:draw()
	local boxheight = 45
	local margin = 4
	local lineheight = 10
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", scale*margin, (height*16-boxheight-margin)*scale, (width*16-margin*2)*scale, boxheight*scale)
	love.graphics.setColor(1, 1, 1)
	drawrectangle(5, (height*16-margin-boxheight+1), (width*16-margin*2-2), boxheight-2)
	
	local availablepixelsx = width*16-margin*2-6
	local availablepixelsy = boxheight-5
	
	local charsx = math.floor(availablepixelsx / 8)
	local charsy = math.floor(availablepixelsy / lineheight)
	
	for i = 1, self.curchar do
		local x = math.mod(i-1, charsx)+1
		local y = math.ceil(i/charsx)
		
		if y <= charsy then
			love.graphics.setColor(self.textcolors[i])
			properprint(string.sub(self.text, i, i), (7+(x-1)*8)*scale, (height*16-boxheight-margin+4+(y-1)*lineheight)*scale)
		else
			--abort!
			self.curchar = #self.text
		end
	end
	
	if self.speaker then
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle("fill", scale*margin, (height*16-boxheight-margin-10)*scale, (5+#self.speaker*8)*scale, 10*scale)
		
		--love.graphics.setColor(1, 1, 1)
		--drawrectangle(5, (height*16-margin-boxheight+1-10), (3+#self.speaker*8), 11)
		
		love.graphics.setColor(self.color or {232/255, 130/255, 30/255})
		properprint(self.speaker, (margin+2)*scale, (height*16-margin-boxheight+1-9)*scale)
	end
end