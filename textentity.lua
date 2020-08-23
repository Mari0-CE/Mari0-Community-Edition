textentity = class("textentity")

function textentity:init(x, y, r)
	self.x = x
	self.y = y
	self.power = true
	self.text = ""

	self.red = 1
	self.green = 1
	self.blue = 1

	--Input list
	self.input1state = "off"
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	--TEXT
	if #self.r > 0 and self.r[1] ~= "link" then
		self.text = tostring(self.r[1])
		self.textsplit = self.text:split(" ") or 0
		table.remove(self.r, 1)
		--prefixes!!
		self.hasaprefix = false
		self.boolcache = {}
		self.glintcache = {}
		self.builtincache = {}
		self.boolbincache = {}
		if globools then --don't try to index a nonexistent table
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
				self.boolcache[string.sub(i,4)] = {globoolSH(string.sub(i,4), "check"), n}
			elseif prefix == "gi:" then
				print(i, "int")
				self.textsplit[n] = globints[string.sub(i,4)] or "uninit"
				self.hasaprefix = true
				self.glintcache[string.sub(i,4)] = {globints[string.sub(i,4)], n}
			elseif prefix == "bi:" then
				print(i, "g_")
				self.textsplit[n] = _G[string.sub(i,4)] or "typo"
				self.hasaprefix = true
				self.builtincache[string.sub(i,4)] = {_G[string.sub(i,4)], n}
			elseif prefix == "bb:" then
				local splitup = string.sub(i,4)
				splitup = splitup:split("/")
				if globoolSH(splitup[1], "check") then
					self.textsplit[n] = splitup[2]
				else
					self.textsplit[n] = splitup[3]
				end
				self.hasaprefix = true
				self.boolbincache[splitup[1]] = {splitup[2], splitup[3], globoolSH(splitup[1], "check"), n}

			end
			print(n,i)
		end
		for h, k in pairs(self.textsplit) do
			print(h,k)
		end
	end
	if self.hasaprefix then
	self.text = table.concat(self.textsplit, " ")
	end

	end

	--POWER
	if #self.r > 0 and self.r[1] ~= "link" then
		self.power = not (self.r[1] == "true")
		table.remove(self.r, 1)
	end
	--Red
	if #self.r > 0 and self.r[1] ~= "link" then
		self.red = tonumber(self.r[1])
		table.remove(self.r, 1)
	end
	--Green
	if #self.r > 0 and self.r[1] ~= "link" then
		self.green = tonumber(self.r[1])
		table.remove(self.r, 1)
	end
	--Blue
	if #self.r > 0 and self.r[1] ~= "link" then
		self.blue = tonumber(self.r[1])
		table.remove(self.r, 1)
	end
end

function textentity:link()
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

function textentity:input(t, input)
	if input == "power" then
		if t == "on" and self.input1state == "off" then
			self.power = not self.power
		elseif t == "off" and self.input1state == "on" then
			self.power = not self.power
		elseif t == "toggle" then
			self.power = not self.power
		end

		self.input1state = t
	end
end

function textentity:update(dt)
	self.pass = true
	if self.hasaprefix then
		for i, j in pairs(self.boolcache) do
			if globoolSH(j[1], "check") ~= j[1] then
				self.textsplit[j[2]] = globoolSH(i, "check")
				self.boolcache[i][1] = self.textsplit[j[2]]
				self.pass = false
			end
		end
		for i, j in pairs(self.boolbincache) do
			if globoolSH(i, "check") ~= j[3] then
				if globoolSH(i, "check") then
					self.textsplit[j[4]] = j[1]
				else
					self.textsplit[j[4]] = j[2]
				end
				self.pass = false
				self.boolbincache[i] = {j[1], globoolSH(i, "check"), n}
			end
		end
		for i, j in pairs(self.glintcache) do
			if globints[i] ~= j[1] then
				self.textsplit[j[2]] = globints[i]
				self.glintcache[i][1] = self.textsplit[j[2]]
				self.pass = false
			end
		end
		for i, j in pairs(self.builtincache) do
			if _G[i] ~= j[1] then
				self.textsplit[j[2]] = _G[i]
				self.builtincache[i][1] = self.textsplit[j[2]]
				self.pass = false
			end
		end
		if not self.pass then
		self.text = table.concat(self.textsplit, " ")
		end
	end
end

function textentity:draw()
	self:update(0)
	if self.power then
		love.graphics.setColor(self.red / COLORCONVERT, self.green / COLORCONVERT, self.blue / COLORCONVERT)
		properprint(self.text, math.floor((self.x-xscroll)*16*scale), math.floor((self.y-yscroll-.5+0.25)*16*scale))
	end
end