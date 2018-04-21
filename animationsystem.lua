function animationsystem_load()
	animationtriggerfuncs = {}
	animations = {}
	
	local dir = love.filesystem.getDirectoryItems("mappacks/" .. mappack .. "/animations")
	
	for i = 1, #dir do
		if string.sub(dir[i], -4) == "json" then
			table.insert(animations, animation:new("mappacks/" .. mappack .. "/animations/" .. dir[i], dir[i]))
		end
	end
end

function animationsystem_update(dt)
	if not editormode then
		for i, v in pairs(animations) do
			v:update(dt)
		end
	end
end

function animationsystem_draw()
	if not editormode then
		for i, v in pairs(animations) do
			v:draw()
		end
	end
end