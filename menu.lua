function menu_load()
	-- All of this stuff reaches outside of menu and so it needs to be moved
	-- to main.lua for encapsulation
	loadconfig()
	love.audio.stop()
	editormode = false
	coinanimation = 1
	gamestate = "menu"
	for i, v in pairs(guielements) do
		v.active = false
	end
	--load 1-1 as background
	loadbackgroundsafe("1-1.txt")
	mariolevel = 1
	marioworld = 1
	mariosublevel = 0
	mariolives = nil
	skipupdate = true

	-- menu
	playerselectimg = love.graphics.newImage("graphics/playerselectarrow.png")
	selection = 1
	love.graphics.setBackgroundColor(92 / 255, 148 / 255, 252 / 255)
	scrollsmoothrate = 4
	optionstab = 2
	optionsselection = 1
	skinningplayer = 1
	rgbselection = 1
	mappackselection = 1
	love.graphics.setBackgroundColor(backgroundcolor[1])
	continueavailable = false
	if love.filesystem.getInfo("suspend.txt") then
		continueavailable = true
	end

	menu_map_load()
	menu_map_dlc_load()
	menu_map_1_6_load()
	menu_controls_load()
	menu_skins_load()

--  This is the only place this appears. Is it used anywhere?
	portalcolors = {}
	for i = 1, players do
		portalcolors[i] = {}
	end

	-- This reaches outside of menu and so it needs to be moved
	-- to main.lua for encapsulation
	if (arcade or mkstation) and firstload then
		firstload = false
		if arcade then
			mappack = "smb"
		elseif mkstation then
		--	mappack = "portal"
		end
		game_load()
	end
end

function menu_draw()
	love.graphics.draw(titleimg, 40*scale, 24*scale, 0, scale, scale)

	if updatenotification then
		love.graphics.setColor(1, 0, 0)
		properprint("version outdated!|go to stabyourself.net|to download latest", 220*scale, 90*scale)
		love.graphics.setColor(1, 1, 1, 1)
	end

	if selection == 0 then
		love.graphics.draw(menuselectimg, 73*scale, (137+(selection-1)*16)*scale, 0, scale, scale)
	elseif selection == 1 then
		love.graphics.draw(menuselectimg, 73*scale, (137+(selection-1)*16)*scale, 0, scale, scale)
	elseif selection == 2 then
		love.graphics.draw(menuselectimg, 81*scale, (137+(selection-1)*16)*scale, 0, scale, scale)
	elseif selection == 3 then
		love.graphics.draw(menuselectimg, 73*scale, (137+(selection-1)*16)*scale, 0, scale, scale)
	elseif selection == 4 then
		love.graphics.draw(menuselectimg, 98*scale, (137+(selection-1)*16)*scale, 0, scale, scale)
	end

	if custombackground then
		if continueavailable then
			properprintbackground("continue game", 87*scale, 122*scale, true)
		end

		properprintbackground("player game", 103*scale, 138*scale, true)

		properprintbackground("level editor", 95*scale, 154*scale, true)

		properprintbackground("select mappack", 83*scale, 170*scale, true)

		properprintbackground("options", 111*scale, 186*scale, true)

		properprintbackground(players, 87*scale, 138*scale, true)
	else
		if continueavailable then
			properprint("continue game", 87*scale, 122*scale)
		end

		properprint("player game", 103*scale, 138*scale)

		properprint("level editor", 95*scale, 154*scale)

		properprint("select mappack", 83*scale, 170*scale)

		properprint("options", 111*scale, 186*scale)

		properprint(players, 87*scale, 138*scale)
	end

	if players > 1 then
		love.graphics.draw(playerselectimg, 82*scale, 138*scale, 0, scale, scale)
	end

	if players < 4 then
		love.graphics.draw(playerselectimg, 102*scale, 138*scale, 0, -scale, scale)
	end

	if selectworldopen then
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", 30*scale, 92*scale, 200*scale, 60*scale)
		love.graphics.setColor(1, 1, 1)
		drawrectangle(31, 93, 198, 58)
		properprint("select world", 83*scale, 105*scale)
		for i = 1, 8 do
			if selectworldcursor == i then
				love.graphics.setColor(1, 1, 1)
			elseif reachedworlds[mappack][i] then
				love.graphics.setColor(0.8, 0.8, 0.8)
			elseif selectworldexists[i] then
				love.graphics.setColor(0.2, 0.2, 0.2)
			else
				love.graphics.setColor(0, 0, 0)
			end

			properprint(i, (55+(i-1)*20)*scale, 130*scale)
			if i == selectworldcursor then
				properprint("v", (55+(i-1)*20)*scale, 120*scale)
			end
		end
	end
end

function loadbackgroundsafe(background)
	if loadbackground(background) == false then
		map = {}
		coinmap = {}
		mapwidth = width
		for x = 1, width do
			map[x] = {}
			coinmap[x] = {}
			for y = 1, 13 do
				map[x][y] = {1}
			end

			for y = 14, 15 do
				map[x][y] = {2}
			end
		end
		mapheight = 15
		startx = {3, 3, 3, 3, 3}
		starty = {13, 13, 13, 13, 13}
		custombackground = false
		backgroundi = 1
		love.graphics.setBackgroundColor(backgroundcolor[backgroundi])
		notice.new("Couldn't properly load|background " .. background .. "!", notice.red)

		xscroll = 0
		yscroll = 0

		smbspritebatch = love.graphics.newSpriteBatch( smbtilesimg, 10000 )
		smbspritebatchfront = love.graphics.newSpriteBatch( smbtilesimg, 10000 )
		portalspritebatch = love.graphics.newSpriteBatch( portaltilesimg, 10000 )
		portalspritebatchfront = love.graphics.newSpriteBatch( portaltilesimg, 10000 )
	end

	generatespritebatch()
end

function loadbackground(backgroundlevel)
	loadcustomimages("mappacks/" .. mappack .. "/graphics")
	loadcustomsounds("mappacks/" .. mappack .. "/sounds")
	loadcustombackgrounds()
	loadcustommusics()
	loadanimatedtiles()
	loadcustomtiles()
	loadmodcustomtiles()
	loadlevelscreens()

	blockbouncex = {}
	blockbouncey = {}

	marioscore = 0
	mariocoincount = 0
	marioworld = 1
	mariolevel = 1
	mariotime = ""
	levelfinished = false

	startx = {3, 3, 3, 3, 3}
	starty = {13, 13, 13, 13, 13}

	coinframe = 1

	itemanimations = {}
	textentities = {}

	if not love.filesystem.getInfo("mappacks/" .. mappack .. "/" .. backgroundlevel) then
		return false
	else
		loadmap(backgroundlevel:sub(1, -5))
	end

	--Adjust start X scroll
	xscroll = startx[1]-scrollingleftcomplete-2
	if xscroll > mapwidth - width then
		xscroll = mapwidth - width
	end

	if xscroll < 0 then
		xscroll = 0
	end

	--and Y too
	yscroll = starty[1]-height+downscrollborder
	if yscroll > mapheight - height - 1 then
		yscroll = mapheight - height - 1
	end

	if yscroll < 0 then
		yscroll = 0
	end

	love.graphics.setBackgroundColor(background)
end

function menu_keypressed(key)
	if selectworldopen then
		if (key == "right" or key == "d") then
			local target = selectworldcursor+1
			while target < 9 and not reachedworlds[mappack][target] do
				target = target + 1
			end
			if target < 9 then
				selectworldcursor = target
			end
		elseif (key == "left" or key == "a") then
			local target = selectworldcursor-1
			while target > 0 and not reachedworlds[mappack][target] do
				target = target - 1
			end
			if target > 0 then
				selectworldcursor = target
			end
		elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
			selectworldopen = false
			game_load(selectworldcursor)
		elseif key == "escape" then
			selectworldopen = false
		end
		return
	end
	if (key == "up" or key == "w") then
		if continueavailable then
			if selection > 0 then
				selection = selection - 1
			end
		else
			if selection > 1 then
				selection = selection - 1
			end
		end
	elseif (key == "down" or key == "s") then
		if selection < 4 then
			selection = selection + 1
		end
	elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
		if selection == 0 then
			game_load(true)
		elseif selection == 1 then
			selectworld()
		elseif selection == 2 then
			editormode = true
			players = 1
			game_load()
		elseif selection == 3 then
			gamestate = "mappackmenu"
			mappacks()
		elseif selection == 4 then
			gamestate = "options"
		end
	elseif key == "escape" then
		love.event.quit()
	elseif (key == "left" or key == "a") then
		if players > 1 then
			players = players - 1
		end
	elseif (key == "right" or key == "d") then
		players = players + 1
		if players > 4 then
			players = 4
		end
	end
end

function menu_onlinemenu_keypressed(key)
	if CLIENT == false and SERVER == false then
		if key == "c" then
			client_load()
		elseif key == "s" then
			server_load()
		end
	elseif SERVER then
		if (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
			server_start()
		end
	end
end

function menu_keyreleased(key)

end

function menu_mousepressed(x, y, button)

end

function menu_mousereleased(x, y, button)

end

function menu_joystickpressed(joystick, button)

end

function menu_joystickreleased(joystick, button)

end

function menu_joystickaxis(joystick, axis, value, stickmoved, shouldermoved)

end

function menu_joystickhat(joystick, hat, direction)

end

function keypromptenter(t, ...)
	arg = {...}
	if t == "key" and (arg[1] == ";" or arg[1] == "," or arg[1] == "," or arg[1] == "-") then
		return
	end
	buttonerror = false
	axiserror = false
	local buttononly = {"run", "jump", "reload", "use"}
	local axisonly = {"aimx", "aimy"}
	if t ~= "key" or arg[1] ~= "escape" then
		if t == "key" then
			if tablecontains(axisonly, controlstable[optionsselection-3]) then
				axiserror = true
			else
				controls[skinningplayer][controlstable[optionsselection-3]] = {arg[1]}
			end
		elseif t == "joybutton" then
			if tablecontains(axisonly, controlstable[optionsselection-3]) then
				axiserror = true
			else
				controls[skinningplayer][controlstable[optionsselection-3]] = {"joy", arg[1], "but", arg[2]}
			end
		elseif t == "joyhat" then
			if tablecontains(buttononly, controlstable[optionsselection-3]) then
				buttonerror = true
			elseif tablecontains(axisonly, controlstable[optionsselection-3]) then
				axiserror = true
			else
				controls[skinningplayer][controlstable[optionsselection-3]] = {"joy", arg[1], "hat", arg[2], arg[3]}
			end
		elseif t == "joyaxis" then
			if tablecontains(buttononly, controlstable[optionsselection-3]) then
				buttonerror = true
			else
				controls[skinningplayer][controlstable[optionsselection-3]] = {"joy", arg[1], "axe", arg[2], arg[3]}
			end
		end
	end

	if (not buttonerror and not axiserror) or arg[1] == "escape" then
		keyprompt = false
	end
end

function keypromptstart()
	keyprompt = true
	buttonerror = false
	axiserror = false

	--save number of stuff
	prompt = {}
	prompt.joystick = {}
	prompt.joysticks = love.joystick.getJoystickCount()

	for i, js in ipairs(love.joystick.getJoysticks()) do
		prompt.joystick[i] = {}
		prompt.joystick[i].hats = js:getHatCount()
		prompt.joystick[i].axes = js:getAxisCount()

		prompt.joystick[i].validhats = {}
		for j = 1, prompt.joystick[i].hats do
			if js:getHat(j) == "c" then
				table.insert(prompt.joystick[i].validhats, j)
			end
		end

		prompt.joystick[i].axisposition = {}
		for j = 1, prompt.joystick[i].axes do
			table.insert(prompt.joystick[i].axisposition, js:getAxis(j))
		end
	end
end

function resetconfig()
	defaultconfig()

	changescale(scale)
	love.audio.setVolume(volume)
	currentshaderi1 = 1
	currentshaderi2 = 1
	shaders:set(1, nil)
	shaders:set(2, nil)
	saveconfig()
	loadbackgroundsafe("1-1.txt")
end

function selectworld()
	if not reachedworlds[mappack] then
		game_load()
	end

	local noworlds = true
	for i = 2, 8 do
		if reachedworlds[mappack][i] then
			noworlds = false
			break
		end
	end

	if noworlds then
		game_load()
		return
	end

	selectworldopen = true
	selectworldcursor = 1

	selectworldexists = {}
	for i = 1, 8 do
		if love.filesystem.getInfo("mappacks/" .. mappack .. "/" .. i .. "-1.txt") then
			selectworldexists[i] = true
		end
	end
end
