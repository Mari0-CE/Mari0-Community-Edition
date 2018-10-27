zginttrigger = class("zginttrigger")

function zginttrigger:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	
	self.condition = false
	self.outtable = {}
	self.id = false
	self.value = 0
	--Input list
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	self.checktable = false
	self.conditions = {"greater","less","equal"}
	--TRIGGER ON PLAYER?
	if #self.r > 0 and self.r[1] ~= "link" then
		self.condition = self.conditions[self.r[1]]
		table.remove(self.r, 1)
	end
	
	--TRIGGER ON ENEMY?
	if #self.r > 0 and self.r[1] ~= "link" then
		self.value = self.r[1]	
		table.remove(self.r, 1)
	end
	
	--REGION
	if #self.r > 0 and self.r[1] ~= "link" then
		self.id = self.r[1]
		table.remove(self.r, 1)
	end
	
	self.out = "off"
end

function zginttrigger:update(dt)
	local col = globintCH(self.id, self.condition, self.value) 
	
	if self.out == "off" and col then
		self.out = "on"
		for i = 1, #self.outtable do
			if self.outtable[i][1].input then
				self.outtable[i][1]:input(self.out, self.outtable[i][2])
			end
		end
	elseif self.out == "on" and not col then
		self.out = "off"
		for i = 1, #self.outtable do
			if self.outtable[i][1].input then
				self.outtable[i][1]:input(self.out, self.outtable[i][2])
			end
		end
	end
end

function zginttrigger:draw()

end

function zginttrigger:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end