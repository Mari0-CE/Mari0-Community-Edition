intro = {}

function intro:init(app_loop_functions)
	gamestate = "intro"
	self.duration = 2.5
	self.blackafterintro = 0.3
	self.fadetime = 0.5
	self.progress = 0
	self.allowskip = false
	self.finished = function() end
end

function intro:update(dt)
	self.allowskip = true
	if self.progress < self.duration+self.blackafterintro then
		self.progress = self.progress + dt
		if self.progress > self.duration+self.blackafterintro then
			self.progress = self.duration+self.blackafterintro
		end
		
		if self.progress > 0.5 and playedwilhelm == nil then
			playsound("stab")
			
			playedwilhelm = true
		end
		
		if self.progress == self.duration + self.blackafterintro then
			self.finished()
			shaders:set(1, shaderlist[currentshaderi1])
			shaders:set(2, shaderlist[currentshaderi2])
		end
	end
end

function intro:draw()
	local logoscale = scale
	if logoscale <= 1 then
		logoscale = 0.5
	else
		logoscale = 1
	end
	
	if self.progress >= 0 and self.progress < self.duration then
		local a = 1
		if self.progress < self.fadetime then
			a = self.progress/self.fadetime
		elseif self.progress >= self.duration-self.fadetime then
			a = (1-(self.progress-(self.duration-self.fadetime))/self.fadetime)
		end
		
		love.graphics.setColor(1, 1, 1, a)
		
		if self.progress > self.fadetime+0.3 and self.progress < self.duration - self.fadetime then
			local y = (self.progress-0.2-self.fadetime) / (self.duration-2*self.fadetime) * 206 * 5
			love.graphics.draw(logo, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, logoscale, logoscale, 142, 150)
			love.graphics.setScissor(0, love.graphics.getHeight()/2+150*logoscale - y, love.graphics.getWidth(), y)
			love.graphics.draw(logoblood, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, logoscale, logoscale, 142, 150)
			love.graphics.setScissor()
			
		elseif self.progress >= self.duration - self.fadetime then
			love.graphics.draw(logoblood, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, logoscale, logoscale, 142, 150)
		else
			love.graphics.draw(logo, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, logoscale, logoscale, 142, 150)
		end
		
		local a2 = math.max(0, (1-(self.progress-.5)/0.3))
		love.graphics.setColor(0.6, 0.6, 0.6, a2)
		properprint("loading mari0 ce..", love.graphics.getWidth()/2-string.len("loading mari0 ce..")*4*scale, love.graphics.getHeight()/2-170*logoscale-7*scale)
		love.graphics.setColor(0.2, 0.2, 0.2, a2)
		properprint(loadingtext, love.graphics.getWidth()/2-string.len(loadingtext)*4*scale, love.graphics.getHeight()/2+165*logoscale)
	end
end

function intro:mousepressed()
	if not self.allowskip then
		return
	end
	soundlist["stab"].source:stop()
	soundlist["stab"].source:seek(0)
	self.finished()
	shaders:set(1, shaderlist[currentshaderi1])
	shaders:set(2, shaderlist[currentshaderi2])
end

function intro:keypressed()
	if not self.allowskip then
		return
	end
	soundlist["stab"].source:stop()
	soundlist["stab"].source:seek(0)
	self.finished()
	shaders:set(1, shaderlist[currentshaderi1])
	shaders:set(2, shaderlist[currentshaderi2])
end
