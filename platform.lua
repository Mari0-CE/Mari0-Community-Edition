platform = class("platform")

function platform:init(x, y, r, diroverride)
	self.size = 2
	self.dir = diroverride or "normal" --(normal, Justup, Justdown, justright(bonus stage), fall)
	self.speed = platformjustspeed
	self.xdistance = 0
	self.ydistance = 0

	--Input list
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)

	--SIZE
	if #self.r > 0 then
		self.size = tonumber(self.r[1])
		table.remove(self.r, 1)
	end

	--X Distance
	if #self.r > 0 then
		if string.sub(self.r[1], 1, 1) == "m" then
			self.xdistance = -tonumber(string.sub(self.r[1], 2))
		else
			self.xdistance = tonumber(self.r[1])
		end
		table.remove(self.r, 1)
	end


	--X Distance
	if #self.r > 0 then
		if string.sub(self.r[1], 1, 1) == "m" then
			self.ydistance = -tonumber(string.sub(self.r[1], 2))
		else
			self.ydistance = tonumber(self.r[1])
		end
		table.remove(self.r, 1)
	end

	--Time
	if #self.r > 0 then
		self.time = tonumber(self.r[1])
		table.remove(self.r, 1)
	end

	--PHYSICS STUFF
	if (self.size ~= math.floor(self.size)) then
		self.x = x-1.25
	else
		self.x = x-1
	end
	self.y = y-15/16
	self.startx = self.x
	self.starty = self.y
	self.speedx = 0 --!
	self.speedy = 0
	self.width = self.size
	self.height = 8/16
	self.static = true
	self.active = true
	self.category = 15
	self.mask = {true}
	self.gravity = 0

	--IMAGE STUFF
	self.drawable = false

	self.rotation = 0

	self.timer = 0

	if self.dir == "justup" then
		self.speedy = -self.speed
	elseif self.dir == "justdown" then
		self.speedy = self.speed
	end
end

function platform:func(i) --0-1 in please
	return (-math.cos(i*math.pi*2)+1)/2
end

function platform:update(dt)
	if dt > 0 then --Debug fix when dividing by dt
		if self.dir == "normal" then
			self.timer = self.timer + dt

			while self.timer > self.time do
				self.timer = self.timer - self.time
			end

			local newx = (self.startx) + self:func(self.timer/self.time)*self.xdistance
			local newy = (self.starty) + self:func(self.timer/self.time)*self.ydistance

			self.speedx = (newx-self.x)/dt
			self.speedy = (newy-self.y)/dt

		elseif self.dir == "justup" and self.y < -1 then
			return true
		elseif (self.dir == "justdown" or self.dir == "fall") and self.y > mapheight then
			return true
		end
	end

	local checktable = {"player", "enemy", "box"}

	local numberofobjects = 0

	--GET FALL SPEED

	if self.dir == "fall" then
		for i, v in pairs(checktable) do
			for j, w in pairs(objects[v]) do
				if inrange(w.x, self.x-w.width, self.x+self.width) and inrange(w.y + w.height, self.y - 0.1, self.y + 0.1) then
					numberofobjects = numberofobjects + 1
				end
			end
		end

		self.speedy = numberofobjects*4
	end

	local nextx, nexty = self.x + self.speedx*dt, self.y + self.speedy*dt

	for i, v in pairs(checktable) do
		for j, w in pairs(objects[v]) do
			if inrange(w.x, self.x-w.width, self.x+self.width) and inrange(w.y + w.height, self.y - 0.1, self.y + 0.1) then
				checkforemances(dt, w, self.speedx, self.speedy)
				local newx = w.x + self.speedx*dt
				local newy = nexty - w.height
				if #checkrect(newx, newy, w.width, w.height, {"exclude", w, self}, true) == 0 then
					w.x = newx
					w.y = newy

					blay = newy+w.height
				end
			end
		end
	end

	self.x = nextx
	self.y = nexty

	return false
end

function platform:draw()
	for i = 1, self.size do
		if self.dir ~= "justright" then
			love.graphics.draw(platformimg, math.floor((self.x+i-1-xscroll)*16*scale), math.floor((self.y-yscroll-8/16)*16*scale), 0, scale, scale)
		else
			love.graphics.draw(platformbonusimg, math.floor((self.x+i-1-xscroll)*16*scale), math.floor((self.y-yscroll-8/16)*16*scale), 0, scale, scale)
		end
	end

	if math.ceil(self.size) ~= self.size then --draw 1 more on the rightest
		love.graphics.draw(platformimg, math.floor((self.x+self.size-1-xscroll)*16*scale), math.floor((self.y-yscroll-8/16)*16*scale), 0, scale, scale)
	end
end

function platform:rightcollide(a, b)
	return false
end

function platform:leftcollide(a, b)
	return false
end

function platform:ceilcollide(a, b)
	if self.dir == "justright" then
		self.speedx = platformbonusspeed
	end
	return false
end

function platform:floorcollide(a, b)
	return false
end

function platform:passivecollide(a, b)
	return false
end