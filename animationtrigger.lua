animationtrigger = class("animationtrigger")

function animationtrigger:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	
	--Input list
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	--IDENTIFIER
	if #self.r > 0 and self.r[1] ~= "link" then
		self.id = tostring(self.r[1])
		table.remove(self.r, 1)
	end
end

function animationtrigger:link()
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

function animationtrigger:input(t, input)
	if input == "in" then
		if t == "on" or t == "toggle" then
			if not animationtriggerfuncs[self.id] then
				return
			end
			
			for i = 1, #animationtriggerfuncs[self.id] do
				animationtriggerfuncs[self.id][i]:trigger()
			end
		end
	end
end