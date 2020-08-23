zgbooltrigger = class("zgbooltrigger")

function zgbooltrigger:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y

	self.inverted = false
	self.outtable = {}
	self.id = false
	self.invisible = false
	--Input list
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)

	self.checktable = false

	--TRIGGER ON PLAYER?
	if #self.r > 0 and self.r[1] ~= "link" then
		if self.r[1] == "true" then
			self.inverted = true
		end
		table.remove(self.r, 1)
	end

	--TRIGGER ON ENEMY?
	if #self.r > 0 and self.r[1] ~= "link" then
		self.id = self.r[1]
		table.remove(self.r, 1)
	end

	--REGION
	if #self.r > 0 and self.r[1] ~= "link" then
		if self.r[1] == "true" then
			self.invisible = true
		end
		table.remove(self.r, 1)
	end

	self.out = "off"
end

function zgbooltrigger:update(dt)
	local col = globoolSH(self.id, "check")

	if self.inverted then
		col = not col
	end

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

function zgbooltrigger:draw()
	love.graphics.setColor(255, 255, 255)
	local quad = 1
	if self.out=="on" then
		quad = 2
	end

	if not self.invisible then
		love.graphics.drawq(zgbooltriggerimg, zgbooltriggerquad[quad], math.floor((self.x-1-xscroll)*16*scale), ((self.y-yscroll-1)*16-8)*scale, 0, scale, scale)
	end
end

function zgbooltrigger:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end