vine = class("vine")

function vine:init(x, y, t)
	self.cox = x
	self.coy = y
	self.t = t

	if self.t == "start" then
		self.limit = mapheight-5-15/16
	else
		self.limit = -1
		for y = self.coy-1, 1, -1 do
			if map[self.cox][y][2] and entitylist[map[self.cox][y][2]] and entitylist[map[self.cox][y][2]].t == "vinestop" then
				self.limit = y-1
				if tilequads[map[self.cox][y][1]]:getproperty("collision", self.cox, y) then
					self.hidetop = true
					self.limit = self.limit + 0.5
				end
				break
			end
		end
	end

	self.timer = 0

	self.width = 10/16
	self.height = 0

	self.x = x-0.5-self.width/2
	self.y = y-1

	self.static = true
	self.active = true

	self.category = 18

	self.mask = {true}

	testtimer = love.timer.getTime()

	--IMAGE STUFF
	self.drawable = false
end

function vine:update(dt)
	if self.y > self.limit then
		self.y = self.y - vinespeed*dt
		if self.y <= self.limit then
			self.y = self.limit
		end
		self.height = math.max(0, self.coy-1-self.y)
	end
end

function vine:draw()
	local top = (self.limit-yscroll)*16*scale
	if not self.hidetop then
		top = (top) - 16*scale
	end
	local bottom = math.floor((self.coy-1.5-yscroll)*16*scale)

	if bottom > top then
		love.graphics.setScissor(0, top, width*16*scale, bottom-top)

		love.graphics.draw(vineimg, vinequad[spriteset][1], math.floor((self.x-xscroll-1/16-((1-self.width)/2))*16*scale), (self.y-yscroll-0.5-2/16)*16*scale, 0, scale, scale)
		for i = 1, math.ceil(self.height-14/16+.7) do
			love.graphics.draw(vineimg, vinequad[spriteset][2], math.floor((self.x-xscroll-1/16-((1-self.width)/2))*16*scale), (self.y-yscroll-0.5-2/16+i)*16*scale, 0, scale, scale)
		end


		love.graphics.setScissor()
	end
end