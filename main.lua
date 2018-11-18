--[[
	STEAL MY SHIT AND I'LL FUCK YOU UP
	PRETTY MUCH EVERYTHING BY MAURICE GUÉGAN AND IF SOMETHING ISN'T BY ME THEN IT SHOULD BE OBVIOUS OR NOBODY CARES

	Please keep in mind that for obvious reasons, I do not hold the rights to artwork, audio or trademarked elements of the game.
	This license only applies to the code and original other assets. Obviously. Duh.
	Anyway, enjoy.
	
	
	
	DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
              Version 2, December 2004

	Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

	Everyone is permitted to copy and distribute verbatim or modified
	copies of this license document, and changing it is allowed as long
	as the name is changed.

			DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
	TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

	0. You just DO WHAT THE FUCK YOU WANT TO.
]]

function love.run()
	--I can't believe I had to write this function in the first place
	local function updateVersion()
		if love.getVersion then
			local major, minor, revision, codename = love.getVersion()
			if major > 0 then
				return major
			else
				return minor
			end
		else
			return love._version_minor
		end
	end

	loveVersion = updateVersion()

	COLORSPACE = loveVersion < 11 and 255 or 1
	COLORCONVERT = loveVersion < 11 and 1 or 255

	MUSICFIX = loveVersion < 11 and "static" or "stream"

	love.math.setRandomSeed(os.time())
	for i=1, 2 do 
		love.math.random() 
	end
	
	love.load(arg)

	-- Main loop time.
	while true do
		-- Process events.
		love.event.pump()
		for e,a,b,c,d in love.event.poll() do
			if e == "quit" then
				if not love.quit() then
					love.audio.stop()
					return
				end
			end
			love.handlers[e](a,b,c,d)
		end

        -- Update dt, as we'll be passing it to update
		love.timer.step()
		local dt = love.timer.getDelta()

        -- Call update and draw
        love.update(dt) -- will pass 0 if love.timer is disabled
		love.graphics.clear()
		love.graphics.origin()
		--Fullscreen hack
		if not mkstation and fullscreen and gamestate ~= "intro" then
			if loveVersion <= 9 then
				completecanvas:clear()
			else
				love.graphics.setCanvas{completecanvas, stencil=true}
				love.graphics.clear()
			end
			love.graphics.setScissor()
			-- Can't use Canvas:renderTo() anymore since 11.1 requires setting the stencil flag to use stencils
			love.graphics.setCanvas{completecanvas, stencil=true}
			love.draw()
			love.graphics.setCanvas()

			love.graphics.setScissor()
			if loveVersion > 9 then
				love.graphics.setCanvas()
			end
			if fullscreenmode == "full" then
				love.graphics.draw(completecanvas, 0, 0, 0, desktopsize.width/(width*16*scale), desktopsize.height/(height*16*scale))
			else
				love.graphics.draw(completecanvas, 0, touchfrominsidemissing/2, 0, touchfrominsidescaling/scale, touchfrominsidescaling/scale)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", 0, 0, desktopsize.width, touchfrominsidemissing/2)
				love.graphics.rectangle("fill", 0, desktopsize.height-touchfrominsidemissing/2, desktopsize.width, touchfrominsidemissing/2)
				love.graphics.setColor(1, 1, 1, 1)
			end
		else
			love.graphics.setScissor()
			love.draw()
		end
		
		love.graphics.present()
		love.timer.sleep(0.001)
	end
end

function love.errhand(msg)
	msg = tostring(msg)
	
	local trace = debug.traceback()

	local err = {}

	table.insert(err, "FLAGRANT SYSTEM ERROR\n")
	table.insert(err, "Mari0 Over.")
	table.insert(err, "Crash = Very Yes.\n\n")
	if not versionerror then
		table.insert(err, "Tell us what happened at github.com/HugoBDesigner/Mari0-Community-Edition/issues, that'd be swell.\nAlso send us a screenshot.\n")
	end
	table.insert(err, "Mari0 " .. (marioversion or "UNKNOWN") .. ", LOVE " .. (love._version or "UNKNOWN") .. " running on " .. (love._os or "UNKNOWN") .. "\n")
	if love.graphics.getRendererInfo then
		local info = {love.graphics.getRendererInfo()}
		err[#err] = err[#err].."Graphics: "..info[1].." "..info[2].." ("..info[4]..", "..info[3]..")\n"
	end
	table.insert(err, msg.."\n\n")

	if not versionerror then
		for l in string.gmatch(trace, "(.-)\n") do
			if not string.match(l, "boot.lua") then
				l = string.gsub(l, "stack traceback:", "Traceback\n")
				table.insert(err, l)
			end
		end
	end

	for m,p in pairs(err) do
		print(p)
	end
	--error_printer(msg, 2)

	if versionerror then
		-- The rest of this code will only run on 0.9.0+.
		return
	end

	if not love.graphics.isCreated() or (loveVersion > 8 and not love.window.isOpen()) then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	local scale = scale or 2

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
	if love.joystick and love.joystick.getJoysticks then -- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	love.graphics.setBackgroundColor(89 / 255, 157 / 255, 220 / 255)
	local font = love.graphics.setNewFont(scale*7)

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.origin()
	--love.graphics.clear()

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	local function draw()
		--love.graphics.clear()
		love.graphics.setColor(0, 0, 0, 0.6)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(0, 0, 0)
		love.graphics.printf(p, 35*scale, 15*scale-1, love.graphics.getWidth() - 35*scale)
		love.graphics.printf(p, 35*scale+1, 15*scale, love.graphics.getWidth() - 35*scale)
		love.graphics.printf(p, 35*scale-1, 15*scale, love.graphics.getWidth() - 35*scale)
		love.graphics.printf(p, 35*scale, 15*scale+1, love.graphics.getWidth() - 35*scale)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(p, 35*scale, 15*scale, love.graphics.getWidth() - 35*scale)
		love.graphics.present()
	end
	
	draw()

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			end
			if e == "keypressed" and a == "escape" then
				return
			end
		end

		--love.graphics.present()

		if love.timer then
			love.timer.sleep(0.03)
		end
	end
end

function add(desc)
	print((desc or "") .. "\n" .. round((love.timer.getTime()-starttime)*1000) .. "ms\tlines " .. lastline+1 .. " - " .. debug.getinfo(2).currentline-1 .. "\n")
	lastline = debug.getinfo(2).currentline
	totaltime = totaltime + round((love.timer.getTime()-starttime)*1000)
	starttime = love.timer.getTime()
end

function love.load(arg)
	marioversion = 1107
	versionstring = "version 1.0se"

	math.mod = math.fmod
	math.random = love.math.random
	
	print("Loading Mari0 SE!")
	print("=======================")
	lastline = debug.getinfo(1).currentline
	starttime = love.timer.getTime()
	totaltime = 0
	JSON = require "JSON"
	require "notice"
	--Get biggest screen size
	
	local sizes = love.window.getFullscreenModes()
	desktopsize = sizes[1]
	
	for i = 2, #sizes do
		if sizes[i].width > desktopsize.width or sizes[i].height > desktopsize.height then
			desktopsize = sizes[i]
		end
	end
	
	recordtarget = 1/40
	recordskip = 1
	recordframe = 1
	
	magicdns_session_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	magicdns_session = ""
	for i = 1, 8 do
		rand = math.random(string.len(magicdns_session_chars))
		magicdns_session = magicdns_session .. string.sub(magicdns_session_chars, rand, rand)
	end
	--use love.filesystem.getIdentity() when it works
	magicdns_identity = love.filesystem.getSaveDirectory():split("/")
	magicdns_identity = string.upper(magicdns_identity[#magicdns_identity])

	
	shaderlist = love.filesystem.getDirectoryItems( "shaders/" )
	local rem
	for i, v in pairs(shaderlist) do
		if v == "init.lua" then
			rem = i
		else
			shaderlist[i] = string.sub(v, 1, string.len(v)-5)
		end
	end
	
	table.remove(shaderlist, rem)
	table.insert(shaderlist, 1, "none")
	
	--=================--
	-- VERSION CONTROL --
	--=================--
	
	if loveVersion > 9 then
		lkisDown = love.keyboard.isDown
		lmisDown = love.mouse.isDown
		function love.keyboard.isDown(key)
			if key == " " then key = "space" end
			return lkisDown(key)
		end
		function love.mouse.isDown(button)
			if button == "l" then button = 1
			elseif button == "r" then button = 2
			elseif button == "m" then button = 3 end
			return lmisDown(button)
		end
	end
	if loveVersion < 11 then
		lgsetColor = love.graphics.setColor
		function love.graphics.setColor(...)
			local args = {...}
			local newColors = {}
			if type(args[1]) == "table" then
				args = args[1]
			end
			for i=1, #args do
				table.insert(newColors, args[i] * 255)
			end
			return lgsetColor(unpack(newColors))
		end
		lgsetBackgroundColor = love.graphics.setBackgroundColor
		function love.graphics.setBackgroundColor(...)
			local args = {...}
			local newColors = {}
			if type(args[1]) == "table" then
				args = args[1]
			end
			for i=1, #args do
				table.insert(newColors, args[i] * 255)
			end
			return lgsetBackgroundColor(unpack(newColors))
		end
		lggetBackgroundColor = love.graphics.getBackgroundColor
		function love.graphics.getBackgroundColor()
			local rgba = {lggetBackgroundColor()}
			for i=1, #rgba do
				rgba[i] = rgba[i] / 255
			end
			return unpack(rgba)
		end
		function love.filesystem.getInfo(path, mode)
			if not mode then
				return love.filesystem.exists(path)
			elseif mode == "directory" then
				return love.filesystem.isDirectory(path)
			else
				return love.filesystem.isFile(path)
			end
		end
	end
	
	iconimg = love.image.newImageData("graphics/icon.png")
	love.window.setIcon(iconimg)
	
	love.graphics.setDefaultFilter("nearest", "nearest")

	axisDeadZones = {}
	joysticks = love.joystick.getJoysticks()
	if #joysticks > 0 then
		for i, v in ipairs(joysticks) do
			axisDeadZones[i] = {}
			for j=1, v:getAxisCount() do
				axisDeadZones[i][j] = {}
				axisDeadZones[i][j]["stick"] = true
				axisDeadZones[i][j]["shoulder"] = true
			end
			for _, j in pairs({"leftx", "lefty", "rightx", "righty", "triggerleft", "triggerright"}) do
				axisDeadZones[i][j] = {}
				axisDeadZones[i][j]["stick"] = true
				axisDeadZones[i][j]["shoulder"] = true
			end
		end
	end

	add("Variables, shaderlist")
	
	local suc, err = pcall(loadconfig)
	if not suc then
		players = 1
		defaultconfig()
		print("== FAILED TO LOAD CONFIG ==")
		print(err)
	end
	
	physicsdebug = false
	incognito = false
	portalwalldebug = false
	userectdebug = false
	speeddebug = false
	
	DEBUG = false
	
	editordebug = DEBUG
	skipintro = DEBUG
	skiplevelscreen = DEBUG
	debugbinds = DEBUG
	frameskip = false -- false/0     true is not valid, so stop accidentally writing that.
	
	replaysystem = false
	drawreplays = false
	drawalllinks = false
	bdrawui = true
	skippedframes = 0
	
	width = 25	--! default 25
	height = 14
	fsaa = 0
	
	steptimer = 0
	targetdt = 1/60
	
	--Calculate relative scaling factor
	touchfrominsidescaling = math.min(desktopsize.width/(width*16), desktopsize.height/(height*16))
	touchfrominsidemissing = desktopsize.height-height*16*touchfrominsidescaling
	
	add("Variables")
	changescale(scale, true)
	add("Resolution change")
	require "characterloader"
	add("Characterloader")
	
	dlclist = {}
	hatcount = #love.filesystem.getDirectoryItems("graphics/standardhats")
	saveconfig()
	love.window.setTitle( "Mari0: Community Edition" )
	
	love.graphics.setBackgroundColor(0, 0, 0)
	
	fontimage = love.graphics.newImage("graphics/font.png")
	fontimageback = love.graphics.newImage("graphics/fontback.png")
	fontglyphs = "0123456789abcdefghijklmnopqrstuvwxyz.:/,\"C-_A* !{}?'()+=><#%"
	fontquads = {}
	for i = 1, string.len(fontglyphs) do
		fontquads[string.sub(fontglyphs, i, i)] = love.graphics.newQuad((i-1)*8, 0, 7, 8, fontimage:getWidth(), fontimage:getHeight())
	end
	fontquadsback = {}
	for i = 1, string.len(fontglyphs) do
		fontquadsback[string.sub(fontglyphs, i, i)] = love.graphics.newQuad((i-1)*10, 0, 10, 10, fontimageback:getWidth(), fontimageback:getHeight())
	end
	
	love.graphics.clear()
	love.graphics.setColor(0.4, 0.4, 0.4)
	loadingtexts = {"reticulating splines", "rendering important stuff", "01110000011011110110111001111001", "sometimes, i dream about cheese",
					"baking cake", "happy explosion day", "raising coolness by a fifth", "yay facepunch", "stabbing myself", "sharpening knives",
					"tanaka, thai kick", "slime will find you", "becoming self-aware", "it's a secret to everybody", "there is no minus world", 
					"oh my god, jc, a bomb", "silly loading message here", "motivational art by jorichi", "love.graphics.print(\"loading..\", 200, 120)",
					"you're my favorite deputy", "licensed under wtfpl", "banned in australia", "loading anti-piracy module", "watch out there's a sni",
					"attack while its tail's up!", "what a horrible night to have a curse", "han shot first", "establishing connection to nsa servers..",
					"how do i programm", "making palette inaccurate..", "y cant mario crawl?"}
	
	loadingtext = loadingtexts[math.random(#loadingtexts)]
	
	if mariocharacter[1] == "rainbow dash-unfinished" then -- /)^3^(\
		logo = love.graphics.newImage("graphics/stabyourselfdash.png")
		logoblood = love.graphics.newImage("graphics/stabyourselfblooddash.png")
	else
		logo = love.graphics.newImage("graphics/stabyourself.png")
		logoblood = love.graphics.newImage("graphics/stabyourselfblood.png")
	end
	
	local logoscale = scale
	if logoscale <= 1 then
		logoscale = 0.5
	else
		logoscale = 1
	end
	
	love.graphics.setColor(1, 1, 1)
	
	love.graphics.draw(logo, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, logoscale, logoscale, 142, 150)
	love.graphics.setColor(0.6, 0.6, 0.6)
	properprint("loading mari0 ce..", love.graphics.getWidth()/2-string.len("loading mari0 ce..")*4*scale, love.graphics.getHeight()/2-170*logoscale-7*scale)
	love.graphics.setColor(0.2, 0.2, 0.2)
	properprint(loadingtext, love.graphics.getWidth()/2-string.len(loadingtext)*4*scale, love.graphics.getHeight()/2+165*logoscale)
	love.graphics.present()
	
	add("Variables")
	
	--require ALL the files!
	--require "netplay"
	--require "client"
	--require "server"
	--require "lobby"
	--require "onlinemenu"
	
	require "shaders"
	require "variables"
	require "sha1"
	class = require "middleclass"
	require "camera"
	
	require "animatedquad"
	require "intro"
	require "menu"
	require "levelscreen"
	require "game"
	require "editor"
	require "animationguiline"
	require "physics"
	require "quad"
	require "entity"
	require "portalwall"
	require "tile"
	require "mario"
	require "hatconfigs"
	require "bighatconfigs"
	require "customhats"
	require "coinblockanimation"
	require "scrollingscore"
	require "scrollingtext"
	require "platform"
	require "platformspawner"
	require "portalparticle"
	require "portalprojectile"
	require "box"
	require "emancipationgrill"
	require "door"
	require "button"
	require "groundlight"
	require "wallindicator"
	require "walltimer"
	require "lightbridge"
	require "faithplate"
	require "laser"
	require "laserdetector"
	require "gel"
	require "geldispenser"
	require "cubedispenser"
	require "pushbutton"
	require "screenboundary"
	require "bulletbill"
	require "fireball"
	require "gui"
	require "blockdebris"
	require "firework"
	require "castlefire"
	require "fire"
	require "bowser"
	require "vine"
	require "spring"
	require "seesaw"
	require "seesawplatform"
	require "bubble"
	require "rainboom"
	require "miniblock"
	require "notgate"
	require "rsflipflop"
	require "andgate"
	require "orgate"
	require "musicentity"
	require "enemyspawner"
	require "musicloader"
	require "magic"
	require "ceilblocker"
	require "funnel"
	require "panel"
	require "rightclickmenu"
	require "emancipateanimation"
	require "emancipationfizzle"
	require "textentity"
	require "squarewave"
	require "scaffold"
	require "animation"
	require "animationsystem"
	require "regiondrag"
	require "regiontrigger"
	require "zgbooltrigger"
	require "zginttrigger"
	require "checkpoint"
	require "portal"
	require "portalent"
	require "pedestal"
	require "actionblock"
	require "animationtrigger"
	require "dialogbox"
	require "itemanimation"
	require "animatedtimer"
	require "animatedbooltimer"
	require "animatedtiletrigger"
	require "delayer"
	require "entitylistitem"
	require "entitytooltip"
	
	require "enemy"
	require "enemies"
	add("Requires")
	
	http = require("socket.http")
	http.PORT = 55555
	http.TIMEOUT = 1
	
	updatenotification = false
	if getupdate() then
		updatenotification = true
	end
	http.TIMEOUT = 4
	
	playertypei = 1
	playertype = playertypelist[playertypei] --portal, gelcannon
	
	if volumesfx == 0 then
		soundenabled = false
	else
		soundenabled = true
	end
	love.filesystem.createDirectory( "mappacks" )
	love.filesystem.createDirectory( "toconvert" )
	editormode = false
	yoffset = 0
	love.graphics.setPointSize(3*scale)
	love.graphics.setLineWidth(2*scale)
	
	uispace = math.floor(width*16*scale/4)
	guielements = {}
	
	--limit hats
	for playerno = 1, players do
		for i = 1, #mariohats[playerno] do
			if mariohats[playerno][i] > hatcount then
				mariohats[playerno][i] = hatcount
			end
		end
	end
	
	--Backgroundcolors
	backgroundcolor = {
						{92 / 255,	148 / 255,	252 / 255},
						{0 / 255,	0 / 255,	0 / 255},
						{32 / 255,	56 / 255,	236 / 255},
						{158 / 255,	219 / 255,	248 / 255},
						{210 / 255,	159 / 255,	229 / 255},
						{237 / 255,	241 / 255,	243 / 255},
						{244 / 255,	178 / 255,	92 / 255},
						{253 / 255,	246 / 255,	175 / 255},
						{249 / 255,	183 / 255,	206 / 255},
					}
	add("Update Check, variables")
	
	--IMAGES--
	overwrittenimages = {}
	imagelist = {"blockdebris", "coinblockanimation", "coinanimation", "coinblock", "coin", "axe", "spring", "toad", "peach", "platform", 
	"platformbonus", "scaffold", "seesaw", "vine", "bowser", "decoys", "box", "flag", "castleflag", "bubble", "fizzle", "emanceparticle", "emanceside", "doorpiece", "doorcenter", 
	"button", "pushbutton", "wallindicator", "walltimer", "lightbridge", "lightbridgeglow", "lightbridgeside", "laser", "laserside", "excursionbase", "excursionfunnel", "excursionfunnel2", "excursionfunnelend", 
	"excursionfunnelend2", "faithplateplate", "laserdetector", "gel1", "gel2", "gel3", "gel4", "gel5", "gel1ground", "gel2ground", "gel3ground", "gel4ground", "geldispenser", "cubedispenser", "panel", "pedestalbase",
	"pedestalgun", "actionblock", "portal", "markbase", "markoverlay", "andgate", "notgate", "orgate", "squarewave", "rsflipflop", "portalglow", "fireball", "musicentity", "smbtiles", "portaltiles",
	"animatedtiletrigger", "delayer", "title", "menuselect"}
	
	for i, v in pairs(imagelist) do
		_G["default" .. v .. "img"] = love.graphics.newImage("graphics/DEFAULT/" .. v .. ".png")
		_G[v .. "img"] = _G["default" .. v .. "img"]
	end
	
	mappackback = love.graphics.newImage("graphics/mappackback.png")
	mappacknoicon = love.graphics.newImage("graphics/mappacknoicon.png")
	mappackoverlay = love.graphics.newImage("graphics/mappackoverlay.png")
	mappackhighlight = love.graphics.newImage("graphics/mappackhighlight.png")
	
	mappackscrollbar = love.graphics.newImage("graphics/mappackscrollbar.png")
	
	--tiles
	tilequads = {}
	rgblist = {}
	
	--add smb tiles
	local imgwidth, imgheight = smbtilesimg:getWidth(), smbtilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("graphics/DEFAULT/smbtiles.png")
	
	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(smbtilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r / COLORSPACE, g / COLORSPACE, b / COLORSPACE})
		end
	end
	smbtilecount = width*height
	
	--add portal tiles
	local imgwidth, imgheight = portaltilesimg:getWidth(), portaltilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("graphics/DEFAULT/portaltiles.png")
	
	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(portaltilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r / COLORSPACE, g / COLORSPACE, b / COLORSPACE})
		end
	end
	portaltilecount = width*height
	
	--add entities
	entitiesimg = love.graphics.newImage("graphics/entities.png")
	entityquads = {}
	local imgwidth, imgheight = entitiesimg:getWidth(), entitiesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("graphics/entities.png")
	
	for y = 1, height do
		for x = 1, width do
			table.insert(entityquads, entity:new(entitiesimg, x, y, imgwidth, imgheight))
			entityquads[#entityquads]:sett(#entityquads)
		end
	end
	entitiescount = width*height
	
	fontimage2 = love.graphics.newImage("graphics/smallfont.png")
	numberglyphs = "012458"
	font2quads = {}
	for i = 1, 6 do
		font2quads[string.sub(numberglyphs, i, i)] = love.graphics.newQuad((i-1)*4, 0, 4, 8, 24, 8)
	end
	
	oneuptextimage = love.graphics.newImage("graphics/oneuptext.png")
	
	linktoolpointerimg = love.graphics.newImage("graphics/linktoolpointer.png")
	
	blockdebrisquads = {}
	for y = 1, 4 do
		blockdebrisquads[y] = {}
		for x = 1, 2 do
			blockdebrisquads[y][x] = love.graphics.newQuad((x-1)*8, (y-1)*8, 8, 8, 16, 32)
		end
	end
	
	coinblockanimationquads = {}
	for i = 1, 30 do
		coinblockanimationquads[i] = love.graphics.newQuad((i-1)*8, 0, 8, 52, 256, 64)
	end
	
	coinanimationquads = {}
	for j = 1, 4 do
		coinanimationquads[j] = {}
		for i = 1, 5 do
			coinanimationquads[j][i] = love.graphics.newQuad((i-1)*5, (j-1)*8, 5, 8, 25, 32)
		end
	end
	
	--coinblock
	coinblockquads = {}
	for j = 1, 4 do
		coinblockquads[j] = {}
		for i = 1, 5 do
			coinblockquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 80, 64)
		end
	end
	
	--coin
	coinquads = {}
	for j = 1, 4 do
		coinquads[j] = {}
		for i = 1, 5 do
			coinquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 80, 64)
		end
	end
	
	--axe
	axequads = {}
	for i = 1, 5 do
		axequads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 80, 16)
	end
	
	--spring
	springquads = {}
	for i = 1, 4 do
		springquads[i] = {}
		for j = 1, 3 do
			springquads[i][j] = love.graphics.newQuad((j-1)*16, (i-1)*31, 16, 31, 48, 124)
		end
	end
	
	seesawquad = {}
	for i = 1, 4 do
		seesawquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
	
	playerselectimg = love.graphics.newImage("graphics/playerselectarrow.png")
	
	starquad = {}
	for i = 1, 4 do
		starquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
	
	flowerquad = {}
	for i = 1, 4 do
		flowerquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
	
	fireballquad = {}
	for i = 1, 4 do
		fireballquad[i] = love.graphics.newQuad((i-1)*8, 0, 8, 8, 80, 16)
	end
	
	for i = 5, 7 do
		fireballquad[i] = love.graphics.newQuad((i-5)*16+32, 0, 16, 16, 80, 16)
	end
	
	vinequad = {}
	for i = 1, 4 do
		vinequad[i] = {}
		for j = 1, 2 do
			vinequad[i][j] = love.graphics.newQuad((j-1)*16, (i-1)*16, 16, 16, 32, 64) 
		end
	end
	
	--enemies
	goombaquad = {}
	
	for y = 1, 4 do
		goombaquad[y] = {}
		for x = 1, 2 do
			goombaquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 64)
		end
	end
		
	spikeyquad = {}
	for y = 1, 4 do
		spikeyquad[y] = {}
		for x = 1, 4 do
			spikeyquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 64, 64)
		end
	end
	
	lakitoquad = {}
	for y = 1, 4 do
		lakitoquad[y] = {}
		for x = 1, 2 do
			lakitoquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*24, 16, 24, 32, 96)
		end
	end
	
	koopaquad = {}
	
	for y = 1, 4 do
		koopaquad[y] = {}
		for x = 1, 5 do
			koopaquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*24, 16, 24, 80, 96)
		end
	end
	cheepcheepquad = {}
	
	cheepcheepquad[1] = {}
	cheepcheepquad[1][1] = love.graphics.newQuad(0, 0, 16, 16, 32, 32)
	cheepcheepquad[1][2] = love.graphics.newQuad(16, 0, 16, 16, 32, 32)
	
	cheepcheepquad[2] = {}
	cheepcheepquad[2][1] = love.graphics.newQuad(0, 16, 16, 16, 32, 32)
	cheepcheepquad[2][2] = love.graphics.newQuad(16, 16, 16, 16, 32, 32)
	
	squidquad = {}
	for x = 1, 2 do
		squidquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 24, 32, 24)
	end
	
	bulletbillquad = {}
	
	for y = 1, 4 do
		bulletbillquad[y] = love.graphics.newQuad(0, (y-1)*16, 16, 16, 16, 64)
	end
	
	hammerbrosquad = {}
	for y = 1, 4 do
		hammerbrosquad[y] = {}
		for x = 1, 4 do
			hammerbrosquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*34, 16, 34, 64, 136)
		end
	end	
	
	hammerquad = {}
	for j = 1, 4 do
		hammerquad[j] = {}
		for i = 1, 4 do
			hammerquad[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 64, 64)
		end
	end
	
	plantquads = {}
	for j = 1, 4 do
		plantquads[j] = {}
		for i = 1, 2 do
			plantquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*23, 16, 23, 32, 92)
		end
	end
	
	firequad = {love.graphics.newQuad(0, 0, 24, 8, 48, 8), love.graphics.newQuad(24, 0, 24, 8, 48, 8)}
	
	
	bowserquad = {}
	bowserquad[1] = {love.graphics.newQuad(0, 0, 32, 32, 64, 64), love.graphics.newQuad(32, 0, 32, 32, 64, 64)}
	bowserquad[2] = {love.graphics.newQuad(0, 32, 32, 32, 64, 64), love.graphics.newQuad(32, 32, 32, 32, 64, 64)}
	
	decoysquad = {}
	for y = 1, 7 do
		decoysquad[y] = love.graphics.newQuad(0, (y-1)*32, 32, 32, 64, 256)
	end
	
	boxquad = {love.graphics.newQuad(0, 0, 12, 12, 32, 16), love.graphics.newQuad(16, 0, 12, 12, 32, 16)}
	
	--eh
	rainboomimg = love.graphics.newImage("graphics/rainboom.png")
	rainboomquad = {}
	for x = 1, 7 do
		for y = 1, 7 do
			rainboomquad[x+(y-1)*7] = love.graphics.newQuad((x-1)*204, (y-1)*182, 204, 182, 1428, 1274)
		end
	end
	
	--magic!
	magicimg = love.graphics.newImage("graphics/magic.png")
	magicquad = {}
	for x = 1, 6 do
		magicquad[x] = love.graphics.newQuad((x-1)*9, 0, 9, 9, 54, 9)
	end
	
	--GUI
	checkboximg = love.graphics.newImage("graphics/checkbox.png")
	checkboxquad = {{love.graphics.newQuad(0, 0, 9, 9, 18, 18), love.graphics.newQuad(9, 0, 9, 9, 18, 18)}, {love.graphics.newQuad(0, 9, 9, 9, 18, 18), love.graphics.newQuad(9, 9, 9, 9, 18, 18)}}
	
	dropdownarrowimg = love.graphics.newImage("graphics/dropdownarrow.png")
	
	--portals
	portalquad = {}
	for i = 0, 7 do
		portalquad[i] = love.graphics.newQuad(0, i*4, 32, 4, 32, 28)
	end
	
	portalparticleimg = love.graphics.newImage("graphics/portalparticle.png")
	portalcrosshairimg = love.graphics.newImage("graphics/portalcrosshair.png")
	portaldotimg = love.graphics.newImage("graphics/portaldot.png")
	portalprojectileimg = love.graphics.newImage("graphics/portalprojectile.png")
	portalprojectileparticleimg = love.graphics.newImage("graphics/portalprojectileparticle.png")
	portalbackgroundimg = love.graphics.newImage("graphics/portalbackground.png")
	
	--Menu shit
	huebarimg = love.graphics.newImage("graphics/huehuehuebar.png")
	huebarmarkerimg = love.graphics.newImage("graphics/huebarmarker.png")
	volumesliderimg = love.graphics.newImage("graphics/volumeslider.png")
	
	--Portal props	
	buttonquad = {love.graphics.newQuad(0, 0, 32, 5, 64, 5), love.graphics.newQuad(32, 0, 32, 5, 64, 5)}
	
	pushbuttonquad = {love.graphics.newQuad(0, 0, 16, 16, 32, 16), love.graphics.newQuad(16, 0, 16, 16, 32, 16)}
	
	wallindicatorquad = {love.graphics.newQuad(0, 0, 16, 16, 32, 16), love.graphics.newQuad(16, 0, 16, 16, 32, 16)}
	
	walltimerquad = {}
	for i = 1, 10 do
		walltimerquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 160, 16)
	end
	
	directionsimg = love.graphics.newImage("graphics/directions.png")
	directionsquad = {}
	for x = 1, 6 do
		directionsquad[x] = love.graphics.newQuad((x-1)*7, 0, 7, 7, 42, 7)
	end
	
	excursionquad = {}
	for x = 1, 8 do
		excursionquad[x] = love.graphics.newQuad((x-1)*8, 0, 8, 32, 64, 32)
	end
	
	faithplatequad = {love.graphics.newQuad(0, 0, 32, 16, 32, 32), love.graphics.newQuad(0, 16, 32, 16, 32, 32)}
	
	gelquad = {love.graphics.newQuad(0, 0, 12, 12, 36, 12), love.graphics.newQuad(12, 0, 12, 12, 36, 12), love.graphics.newQuad(24, 0, 12, 12, 36, 12)}
	
	gradientimg = love.graphics.newImage("graphics/gradient.png");gradientimg:setFilter("linear", "linear")
	
	panelquad = {}
	for x = 1, 2 do
		panelquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 16, 32, 16)
	end
	
	add("Images, quads")
	
	--AUDIO--
	--sounds
	soundstoload = {"jump", "jumpbig", "stomp", "shot", "blockhit", "blockbreak", "coin", "pipe", "boom", "mushroomappear", "mushroomeat", "shrink", "death", "gameover", "fireball",
					"oneup", "levelend", "castleend", "scorering", "intermission", "fire", "bridgebreak", "bowserfall", "vine", "swim", "rainboom", "konami", "pause", "bulletbill",
					"lowtime", "tailwag", "planemode", "stab", "portal1open", "portal2open", "portalenter", "portalfizzle", "pushbutton"}

	defaultsoundslist = {}
	overwrittensounds = {}	
	soundlist = {}
	
	for i, v in pairs(soundstoload) do
		local src = love.audio.newSource("sounds/" .. v .. ".ogg", MUSICFIX)
		soundlist[v] = {}
		soundlist[v].source = src
		soundlist[v].lastplayed = 0
		defaultsoundslist[v] = src
	end
	
	soundlist["scorering"].source:setLooping(true)
	soundlist["planemode"].source:setLooping(true)
	soundlist["portal1open"].source:setVolume(0.3)
	soundlist["portal2open"].source:setVolume(0.3)
	soundlist["portalenter"].source:setVolume(0.3)
	soundlist["portalfizzle"].source:setVolume(0.3)
	
	delaylist = {}
	delaylist["blockhit"] = 0.2
	
	musicname = "overworld.ogg"
	
	add("Sounds")
	shaders:init()
	add("Shaders init")
	
	for i, v in pairs(dlclist) do
		delete_mappack(v)
	end
	
	firstload = true
	
	if skipintro then
		menu_load()
	else
		intro_load()
	end
	add("Intro Load")
	print("=======================\nDONE!")
	print("TOTAL: " .. totaltime .. "ms")
	
	mycamera = camera:new()
	mycamera:zoomTo(0.4)
end

function love.update(dt)
	if music then
		music:update()
	end
	realdt = dt
	dt = math.min(0.5, dt) --ignore any dt higher than half a second
	
	if recording then
		dt = recordtarget
	end
	
	steptimer = steptimer + dt
	dt = targetdt
	
	if skipupdate then
		steptimer = 0
		skipupdate = false
		return
	end
	
	--speed
	if bullettime and speed ~= speedtarget then
		if speed > speedtarget then
			speed = math.max(speedtarget, speed+(speedtarget-speed)*dt*5)
		elseif speed < speedtarget then
			speed = math.min(speedtarget, speed+(speedtarget-speed)*dt*5)
		end
		
		if math.abs(speed-speedtarget) < 0.02 then
			speed = speedtarget
		end
		
		if speed > 0 then
			for i, v in pairs(soundlist) do
				v.source:setPitch( speed )
			end
			music.pitch = speed
			love.audio.setVolume(volumesfx)
			music:setVolume(volumemusic)
		else	
			love.audio.setVolume(0)
			music:setVolume(0)
		end
	end
	
	while steptimer >= targetdt do
		steptimer = steptimer - targetdt
		
		if frameskip then
			if frameskip > skippedframes then
				skippedframes = skippedframes + 1
				return
			else
				skippedframes = 0
			end
		end
		
		keyprompt_update()
		
		if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" or gamestate == "lobby" then
			menu_update(dt)
		elseif gamestate == "levelscreen" or gamestate == "gameover" or gamestate == "sublevelscreen" or gamestate == "mappackfinished" then
			levelscreen_update(dt)
		elseif gamestate == "game" then
			game_update(dt)	
		elseif gamestate == "intro" then
			intro_update(dt)	
		end
		
		for i, v in pairs(guielements) do
			v:update(dt)
		end
		
		--netplay_update(dt)
		
		notice.update(dt)
		
		--No longer needed
		--love.window.setTitle("FPS:" .. love.timer.getFPS() .. " - Send feedback/issues to crash@stabyourself.net")
	end
end

function love.draw()
	shaders:predraw()
	
	--mycamera:attach()
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" or gamestate == "lobby" then
		menu_draw()
	elseif gamestate == "levelscreen" or gamestate == "gameover" or gamestate == "mappackfinished" then
		levelscreen_draw()
	elseif gamestate == "game" then
		game_draw()
	elseif gamestate == "intro" then
		intro_draw()
	end
	
	notice.draw()
	
	--mycamera:detach()
	
	shaders:postdraw()
		
	love.graphics.setColor(1, 1, 1)
	
	if recording then
		screenshotimagedata = love.graphics.newScreenshot( )
		screenshotimagedata:encode("recording/" .. recordframe .. ".png")
		recordframe = recordframe + 1
		screenshotimagedata = nil
		
		if recordframe%100 == 0 then
			collectgarbage("collect")
		end
	end
end

function saveconfig()
	if CLIENT or SERVER then
		return
	end
	
	local s = ""
	for i = 1, #controls do
		s = s .. "playercontrols:" .. i .. ":"
		local count = 0
		for j, k in pairs(controls[i]) do
			local c = ""
			for l = 1, #controls[i][j] do
				c = c .. controls[i][j][l]
				if l ~= #controls[i][j] then
					c = c ..  "-"
				end
			end
			s = s .. j .. "-" .. c
			count = count + 1
			if count == 12 then
				s = s .. ";"
			else
				s = s .. ","
			end
		end
	end	
	
	for i = 1, #mariocolors do --players
		s = s .. "playercolors:" .. i .. ":"
		if #mariocolors[i] > 0 then
			for j = 1, #mariocolors[i] do --colorsets (dynamic)
				for k = 1, 3 do --R, G or B values
					s = s .. mariocolors[i][j][k] * 255
					if j == #mariocolors[i] and k == 3 then
						s = s .. ";"
					else
						s = s .. ","
					end
				end
			end
		else
			s = s .. ";"
		end
	end
	
	for i = 1, #mariocharacter do
		s = s .. "mariocharacter:" .. i .. ":"
		s = s .. mariocharacter[i]
		s = s .. ";"
	end
	
	for i = 1, #portalhues do
		s = s .. "portalhues:" .. i .. ":"
		s = s .. round(portalhues[i][1], 4) .. "," .. round(portalhues[i][2], 4) .. ";"
	end
	
	for i = 1, #mariohats do
		s = s .. "mariohats:" .. i
		if #mariohats[i] > 0 then
			s = s .. ":"
		end
		for j = 1, #mariohats[i] do
			s = s .. mariohats[i][j]
			if j == #mariohats[i] then
				s = s .. ";"
			else
				s = s .. ","
			end
		end
		
		if #mariohats[i] == 0 then
			s = s .. ";"
		end
	end
	
	s = s .. "scale:" .. scale .. ";"
	
	s = s .. "shader1:" .. shaderlist[currentshaderi1] .. ";"
	s = s .. "shader2:" .. shaderlist[currentshaderi2] .. ";"
	
	s = s .. "volume:" .. volumesfx .. ";"
	s = s .. "musicvolume:" .. volumemusic .. ";"
	s = s .. "mouseowner:" .. mouseowner .. ";"
	
	s = s .. "mappack:" .. mappack .. ";"
	
	if vsync then
		s = s .. "vsync;"
	end
	
	if gamefinished then
		s = s .. "gamefinished;"
	end
	
	s = s .. "fullscreen:" .. tostring(fullscreen) .. ";"
	s = s .. "fullscreenmode:" .. fullscreenmode .. ";"
	
	--reached worlds
	for i, v in pairs(reachedworlds) do
		s = s .. "reachedworlds:" .. i .. ":"
		for j = 1, 8 do
			if v[j] then
				s = s .. 1
			else
				s = s .. 0
			end
			
			if j == 8 then
				s = s .. ";"
			else
				s = s .. ","
			end
		end
	end
	
	love.filesystem.write("options.txt", s)
end

function loadconfig()
	players = 1
	defaultconfig()
	
	if not love.filesystem.getInfo("options.txt") then
		return
	end
	
	local s = love.filesystem.read("options.txt")
	s1 = s:split(";")
	
	for i = 1, #s1-1 do
		s2 = s1[i]:split(":")
		if s2[1] == "playercontrols" then
			if controls[tonumber(s2[2])] == nil then
				controls[tonumber(s2[2])] = {}
			end
			
			s3 = s2[3]:split(",")
			for j = 1, #s3 do
				s4 = s3[j]:split("-")
				controls[tonumber(s2[2])][s4[1]] = {}
				for k = 2, #s4 do
					if tonumber(s4[k]) ~= nil then
						controls[tonumber(s2[2])][s4[1]][k-1] = tonumber(s4[k])
					else
						controls[tonumber(s2[2])][s4[1]][k-1] = s4[k]
					end
				end
			end
			players = math.max(players, tonumber(s2[2]))
			
		elseif s2[1] == "playercolors" then
			if mariocolors[tonumber(s2[2])] == nil then
				mariocolors[tonumber(s2[2])] = {}
			end
			s3 = s2[3]:split(",")
			mariocolors[tonumber(s2[2])] = {}
			for i = 1, #s3/3 do
				mariocolors[tonumber(s2[2])][i] = {tonumber(s3[1+(i-1)*3]) / 255, tonumber(s3[2+(i-1)*3]) / 255, tonumber(s3[3+(i-1)*3]) / 255}
			end
		elseif s2[1] == "portalhues" then
			if portalhues[tonumber(s2[2])] == nil then
				portalhues[tonumber(s2[2])] = {}
			end
			s3 = s2[3]:split(",")
			portalhues[tonumber(s2[2])] = {tonumber(s3[1]), tonumber(s3[2])}
		
		elseif s2[1] == "mariohats" then
			local playerno = tonumber(s2[2])
			mariohats[playerno] = {}
			
			if s2[3] == "mariohats" then --SAVING WENT WRONG OMG
			
			elseif s2[3] then
				s3 = s2[3]:split(",")
				for i = 1, #s3 do
					local hatno = tonumber(s3[i])
					mariohats[playerno][i] = hatno
				end
			end
			
		elseif s2[1] == "scale" then
			scale = tonumber(s2[2])
			
		elseif s2[1] == "shader1" then
			for i = 1, #shaderlist do
				if shaderlist[i] == s2[2] then
					currentshaderi1 = i
				end
			end
		elseif s2[1] == "shader2" then
			for i = 1, #shaderlist do
				if shaderlist[i] == s2[2] then
					currentshaderi2 = i
				end
			end
		elseif s2[1] == "volume" then
			volumesfx = tonumber(s2[2])
			love.audio.setVolume( volumesfx )
		elseif s2[1] == "musicvolume" then
			volumemusic = tonumber(s2[2])
		elseif s2[1] == "mouseowner" then
			mouseowner = tonumber(s2[2])
		elseif s2[1] == "mappack" then
			if love.filesystem.getInfo("mappacks/" .. s2[2] .. "/settings.txt") then
				mappack = s2[2]
			end
		elseif s2[1] == "gamefinished" then
			gamefinished = true
		elseif s2[1] == "vsync" then
			vsync = true
		elseif s2[1] == "reachedworlds" then
			reachedworlds[s2[2]] = {}
			local s3 = s2[3]:split(",")
			for i = 1, #s3 do
				if tonumber(s3[i]) == 1 then
					reachedworlds[s2[2]][i] = true
				end
			end
		elseif s2[1] == "mariocharacter" then
			mariocharacter[tonumber(s2[2])] = s2[3]
		elseif s2[1] == "fullscreen" then
			fullscreen = s2[2] == "true"
		elseif s2[1] == "fullscreenmode" then
			fullscreenmode = s2[2]
		end
	end
	
	for i = 1, math.max(4, players) do
		portalcolor[i] = {getrainbowcolor(portalhues[i][1]), getrainbowcolor(portalhues[i][2])}
	end
	
	players = 1
end

function defaultconfig()
	--------------
	-- CONTORLS --
	--------------
	
	-- Joystick stuff:
	-- joy, #, hat, #, direction (r, u, ru, etc)
	-- joy, #, axe, #, pos/neg
	-- joy, #, but, #
	-- You cannot set Hats and Axes as the jump button. Bummer.
	
	mouseowner = 1
	
	controls = {}
	
	local i = 1
	controls[i] = {}
	controls[i]["right"] = {"d"}
	controls[i]["left"] = {"a"}
	controls[i]["down"] = {"s"}
	controls[i]["up"] = {"w"}
	controls[i]["run"] = {"lshift"}
	controls[i]["jump"] = {" "}
	controls[i]["aimx"] = {""} --mouse aiming, so no need
	controls[i]["aimy"] = {""}
	controls[i]["portal1"] = {""}
	controls[i]["portal2"] = {""}
	controls[i]["reload"] = {"r"}
	controls[i]["use"] = {"e"}
	
	for i = 2, 4 do
		controls[i] = {}		
		controls[i]["right"] = {"joy", i-1, "hat", 1, "r"}
		controls[i]["left"] = {"joy", i-1, "hat", 1, "l"}
		controls[i]["down"] = {"joy", i-1, "hat", 1, "d"}
		controls[i]["up"] = {"joy", i-1, "hat", 1, "u"}
		controls[i]["run"] = {"joy", i-1, "but", 3}
		controls[i]["jump"] = {"joy", i-1, "but", 1}
		controls[i]["aimx"] = {"joy", i-1, "axe", 5, "neg"}
		controls[i]["aimy"] = {"joy", i-1, "axe", 4, "neg"}
		controls[i]["portal1"] = {"joy", i-1, "but", 5}
		controls[i]["portal2"] = {"joy", i-1, "but", 6}
		controls[i]["reload"] = {"joy", i-1, "but", 4}
		controls[i]["use"] = {"joy", i-1, "but", 2}
	end
	-------------------
	-- PORTAL COLORS --
	-------------------
	
	portalhues = {}
	portalcolor = {}
	for i = 1, 4 do
		local players = 4
		portalhues[i] = {(i-1)*(1/players), (i-1)*(1/players)+0.5/players}
		portalcolor[i] = {getrainbowcolor(portalhues[i][1]), getrainbowcolor(portalhues[i][2])}
	end
	
	--hats.
	mariohats = {}
	for i = 1, 4 do
		mariohats[i] = {1}
	end
	
	------------------
	-- MARIO COLORS --
	------------------
	--1: hat, pants (red)
	--2: shirt, shoes (brown-green)
	--3: skin (yellow-orange)
	
	mariocolors = {}
	mariocolors[1] = {{224 / 255,  32 / 255,   0 / 255}, {136 / 255, 112 / 255,   0 / 255}, {252 / 255, 152 / 255,  56 / 255}}
	mariocolors[2] = {{255 / 255, 255 / 255, 255 / 255}, {  0 / 255, 160 / 255,   0 / 255}, {252 / 255, 152 / 255,  56 / 255}}
	mariocolors[3] = {{  0 / 255,   0 / 255,   0 / 255}, {200 / 255,  76 / 255,  12 / 255}, {252 / 255, 188 / 255, 176 / 255}}
	mariocolors[4] = {{ 32 / 255,  56 / 255, 236 / 255}, {  0 / 255, 128 / 255, 136 / 255}, {252 / 255, 152 / 255,  56 / 255}}
	for i = 5, players do
		mariocolors[i] = mariocolors[math.random(4)]
	end
	
	--STARCOLORS
	starcolors = {}
	starcolors[1] = {{  0 / 255,   0 / 255,   0 / 255}, {200 / 255,  76 / 255,  12 / 255}, {252 / 255, 188 / 255, 176 / 255}}
	starcolors[2] = {{  0 / 255, 168 / 255,   0 / 255}, {252 / 255, 152 / 255,  56 / 255}, {252 / 255, 252 / 255, 252 / 255}}
	starcolors[3] = {{252 / 255, 216 / 255, 168 / 255}, {216 / 255,  40 / 255,   0 / 255}, {252 / 255, 152 / 255,  56 / 255}}
	starcolors[4] = {{216 / 255,  40 / 255,   0 / 255}, {252 / 255, 152 / 255,  56 / 255}, {252 / 255, 252 / 255, 252 / 255}}
	
	flowercolor = {{252 / 255, 216 / 255, 168 / 255}, {216 / 255,  40 / 255,   0 / 255}, {252 / 255, 152 / 255,  56 / 255}}
	
	--CHARACTERS
	mariocharacter = {"mario", "mario", "mario", "mario"}
	
	--options
	scale = 2
	volumesfx = 1
	volumemusic = 1
	mappack = "smb"
	vsync = false
	currentshaderi1 = 1
	currentshaderi2 = 1
	firstpersonview = false
	firstpersonrotate = false
	seethroughportals = false
	fullscreen = false
	fullscreenmode = "letterbox"
	
	reachedworlds = {}
end

function loadcustomimages(path)
	for i = 1, #overwrittenimages do
		local s = overwrittenimages[i]
		_G[s .. "img"] = _G["default" .. s .. "img"]
	end
	overwrittenimages = {}

	local fl = love.filesystem.getDirectoryItems(path)
	for i = 1, #fl do
		local v = fl[i]
		if love.filesystem.getInfo(path .. "/" .. v, "file") then
			local s = string.sub(v, 1, -5)
			if tablecontains(imagelist, s) then
				_G[s .. "img"] = love.graphics.newImage(path .. "/" .. v)
				table.insert(overwrittenimages, s)
			end
		end
	end
	
	--tiles
	tilequads = {}
	rgblist = {}
	
	--add smb tiles
	local imgwidth, imgheight = smbtilesimg:getWidth(), smbtilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata
	if love.filesystem.getInfo(path .. "/smbtiles.png") then
		imgdata = love.image.newImageData(path .. "/smbtiles.png")
	else
		imgdata = love.image.newImageData("graphics/DEFAULT/smbtiles.png")
	end
	
	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(smbtilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r / COLORSPACE, g / COLORSPACE, b / COLORSPACE})
		end
	end
	smbtilecount = width*height
	
	--add portal tiles
	local imgwidth, imgheight = portaltilesimg:getWidth(), portaltilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata
	if love.filesystem.getInfo(path .. "/portaltiles.png") then
		imgdata = love.image.newImageData(path .. "/portaltiles.png")
	else
		imgdata = love.image.newImageData("graphics/DEFAULT/portaltiles.png")
	end
	
	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(portaltilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r / COLORSPACE, g / COLORSPACE, b / COLORSPACE})
		end
	end
	portaltilecount = width*height
end

function loadcustomsounds(path)
	for _, v in pairs(overwrittensounds) do
		soundlist[v].source = defaultsoundslist[v]
	end
	overwrittensounds = {}
	
	local fl = love.filesystem.getDirectoryItems(path)
	for i = 1, #fl do
		local v = fl[i]
		if love.filesystem.getInfo(path .. "/" .. v, "file") then
			local s = string.sub(v, 1, -5)
			if soundlist[s] then
				soundlist[s].source = love.audio.newSource(path .. "/" .. v, MUSICFIX)
				table.insert(overwrittensounds, s)
			else
				soundlist[s] = {}
				soundlist[s].source = love.audio.newSource(path .. "/" .. v, MUSICFIX)
				soundlist[s].lastplayed = 0
			end
		end
	end
end

function suspendgame()
	local s = ""
	if marioworld == "M" then
		marioworld = 1
		mariolevel = 3
	end
	s = s .. "a/" .. marioworld .. "|"
	s = s .. "b/" .. mariolevel .. "|"
	s = s .. "c/" .. mariocoincount .. "|"
	s = s .. "d/" .. marioscore .. "|"
	s = s .. "e/" .. players .. "|"
	for i = 1, players do
		if mariolivecount ~= false then
			s = s .. "f/" .. i .. "/" .. mariolives[i] .. "|"
		end
		if objects["player"][i] then
			s = s .. "g/" .. i .. "/" .. objects["player"][i].size .. "|"
		else
			s = s .. "g/" .. i .."/1|"
		end
	end
	s = s .. "h/" .. mappack
	
	love.filesystem.write("suspend.txt", s)
	
	love.audio.stop()
	menu_load()
end

function continuegame()
	if not love.filesystem.getInfo("suspend.txt") then
		return
	end
	
	local s = love.filesystem.read("suspend.txt")
	
	mariosizes = {}
	mariolives = {}
	
	local split = s:split("|")
	for i = 1, #split do
		local split2 = split[i]:split("/")
		if split2[1] == "a" then
			marioworld = tonumber(split2[2])
		elseif split2[1] == "b" then
			mariolevel = tonumber(split2[2])
		elseif split2[1] == "c" then
			mariocoincount = tonumber(split2[2])
		elseif split2[1] == "d" then
			marioscore = tonumber(split2[2])
		elseif split2[1] == "e" then
			players = tonumber(split2[2])
		elseif split2[1] == "f" and mariolivecount ~= false then
			mariolives[tonumber(split2[2])] = tonumber(split2[3])
		elseif split2[1] == "g" then
			mariosizes[tonumber(split2[2])] = tonumber(split2[3])
		elseif split2[1] == "h" then
			mappack = split2[2]
		end
	end
	
	love.filesystem.remove("suspend.txt")
end

function changescale(s, init)
	scale = s
	
	if not init then
		if width*16*scale > desktopsize.width then
			if fullscreen and fullscreenmode == "full" then
				scale = scale - 1
				return
			end
			
			if fullscreen and fullscreenmode == "touchfrominside" then
				fullscreenmode = "full"
				scale = scale - 1
				return
			end
			
			if loveVersion >= 10 or love.graphics.isSupported("canvas") then
				fullscreen = true
			end
			
			scale = scale - 1
			fullscreenmode = "touchfrominside"
			
		elseif fullscreen then
			if fullscreenmode == "full" then
				fullscreenmode = "touchfrominside"
				scale = scale + 1
				return
			else
				fullscreen = false
			end
			scale = scale + 1
			fullscreenmode = "full"
			
		end
	end
	
	if fullscreen then
		love.window.setMode(desktopsize.width, desktopsize.height, {fullscreen=fullscreen, vsync=vsync--[[, fsaa=fsaa]]})
	else
		uispace = math.floor(width*16*scale/4)
		love.window.setMode(width*16*scale, height*16*scale, {fullscreen=fullscreen, vsync=vsync--[[, fsaa=fsaa]]}) --25x14 blocks (15 blocks actual height)
	end

	if loveVersion > 9 or love.graphics.isSupported("canvas") then
		completecanvas = love.graphics.newCanvas()
		completecanvas:setFilter("linear", "linear")
	end
	
	gamewidth, gameheight = love.window.getMode()
	if shaders then
		shaders:refresh()
	end
	
	if generatespritebatch then
		generatespritebatch()
	end
end

function love.keypressed(key, isrepeat)
	if key == "space" and loveVersion > 9 then key = " " end
	if key == "k" then
		savelevel()
	end

	if key == "y" and debugbinds then
		if love.keyboard.isDown("lalt") then
			recording = not recording
		end
	end
	
	if key == "lctrl" and debugbinds then
		debug.debug()
		return
	end
	
	if replaysystem then
		if key == "k" then
			objects["player"][1]:savereplaydata()
		end
	end
	
	if keyprompt then
		keypromptenter("key", key)
		return
	end

	for i, v in pairs(guielements) do
		if v:keypress(string.lower(key)) then
			return
		end
	end
	
	if key == "f12" then
		love.mouse.setGrabbed(not love.mouse.isGrabbed())
	end
	
	if gamestate == "lobby" or gamestate == "onlinemenu" then
		if key == "escape" then
			net_quit()
			return
		end
	end
	
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
		table.insert(konamitable, key)
		table.remove(konamitable, 1)
		local s = ""
		for i = 1, #konamitable do
			s = s .. konamitable[i]
		end
		
		if sha1(s) == konamihash then --Before you wonder how dumb this is; This used to be a different code than konami because I thought it'd be fun to make people figure it out before they can tell others how to easily unlock cheats (without editing files). It wasn't, really.
			playsound("konami")
			gamefinished = true
			saveconfig()
			notice.new("Cheats unlocked!")
		end
		menu_keypressed(key)
	elseif gamestate == "game" then
		game_keypressed(key)
	elseif gamestate == "intro" then
		intro_keypressed()
	end
end

function love.keyreleased(key)
	if key == "space" and loveVersion > 9 then key = " " end
	if gamestate == "menu" or gamestate == "options" then
		menu_keyreleased(key)
	elseif gamestate == "game" then
		game_keyreleased(key)
	end
end

function love.textinput(text)
	if _G[gamestate .. "_textinput"] and type(_G[gamestate .. "_textinput"]) == "function" then
		local success, err = pcall(function() _G[gamestate .. "_textinput"](text) end) -- I don't wanna cause a crash
		if not success then print(err) end
	end
	
	if guielements then
		for _, v in pairs(guielements) do
			v:textinput(text)
		end
	end
end

function love.wheelmoved(x, y)
	if y > 0 then
		love.mousepressed(love.mouse.getX(), love.mouse.getY(), "wu")
	elseif y < 0 then
		love.mousepressed(love.mouse.getX(), love.mouse.getY(), "wd")
	end
end

function love.mousepressed(x, y, button)
	if loveVersion > 9 then
		if button == 1 then button = "l"
		elseif button == 2 then button = "r"
		elseif button == 3 then button = "m"
		end
	end
	if fullscreen then
		if fullscreenmode == "full" then
			x, y = x/(desktopsize.width/(width*16*scale)), y/(desktopsize.height/(height*16*scale))
		else
			x, y = x/(touchfrominsidescaling/scale), y/(touchfrominsidescaling/scale)-touchfrominsidemissing/2
		end
	end
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
		menu_mousepressed(x, y, button)
	elseif gamestate == "game" then
		game_mousepressed(x, y, button)
	elseif gamestate == "intro" then
		intro_mousepressed()
	end
	
	if animationguilines and editormenuopen and not changemapwidthmenu and not guielements["animationselectdrop"].extended then
		local b = false
		for i, v in pairs(animationguilines) do
			for k, w in pairs(v) do
				if w:haspriority() then
					w:click(x, y, button)
					return
				end
			end
		end
		
		if x >= animationguiarea[1]*scale and y >= animationguiarea[2]*scale and x < animationguiarea[3]*scale and y < animationguiarea[4]*scale then
			addanimationtriggerbutton:click(x, y, button)
			addanimationconditionbutton:click(x, y, button)
			addanimationactionbutton:click(x, y, button)
			
			for i, v in pairs(animationguilines) do
				for k, w in pairs(v) do						
					if w:click(x, y, button) then
						return
					end
				end
			end
		end
	end
	
	for i, v in pairs(guielements) do
		if v.priority then
			if v:click(x, y, button) then
				return
			end
		end
	end
	
	for i, v in pairs(guielements) do
		if not v.priority then
			if v:click(x, y, button) then
				return
			end
		end
	end
end

function love.mousereleased(x, y, button)
	if loveVersion > 9 then
		if button == 1 then button = "l"
		elseif button == 2 then button = "r"
		elseif button == 3 then button = "m"
		end
	end
	x, y = desktopsize.width/(width*16*scale)*x, desktopsize.height/(height*16*scale)*y
	if gamestate == "menu" or gamestate == "options" then
		menu_mousereleased(x, y, button)
	elseif gamestate == "game" then
		game_mousereleased(x, y, button)
	end
	
	for i, v in pairs(guielements) do
		v:unclick(x, y, button)
	end
end

function love.joystickpressed(joystick, button)
	local joysticks,found = love.joystick.getJoysticks(),false
	for i,v in ipairs(joysticks) do
		if v:getID() == joystick:getID() then
			joystick,found = i,true
			break
		end
	end
	
	if found then
		if keyprompt then
			keypromptenter("joybutton", joystick, button)
		elseif gamestate == "menu" or gamestate == "options" then
			menu_joystickpressed(joystick, button)
		elseif gamestate == "game" then
			game_joystickpressed(joystick, button)
		end
	end
end

function love.joystickreleased(joystick, button)
	local joysticks,found = love.joystick.getJoysticks(),false
	for i,v in ipairs(joysticks) do
		if v:getID() == joystick:getID() then
			joystick,found = i,true
			break
		end
	end
	
	if found then
		if gamestate == "menu" or gamestate == "options" then
			menu_joystickreleased(joystick, button)
		elseif gamestate == "game" then
			game_joystickreleased(joystick, button)
		end
	end
end

function love.joystickaxis(joystick, axis, value)
	local joysticks,found = love.joystick.getJoysticks(),false
	for i,v in ipairs(joysticks) do
		if v:getID() == joystick:getID() then
			joystick,found = i,true
			break
		end
	end
	
	if found then
		local stickmoved = false
		local shouldermoved = false
		
		--If this axis is a stick, get whether it just moved out of its deadzone
		if math.abs(value) > joystickaimdeadzone and axisDeadZones[joystick][axis]["stick"] then
			stickmoved = true
			axisDeadZones[joystick][axis]["stick"] = false
		elseif math.abs(value) < joystickaimdeadzone and not axisDeadZones[joystick][axis]["stick"] then
			axisDeadZones[joystick][axis]["stick"] = true
		end

		--If this axis is a shoulder, get whether it just moved out of its deadzone
		if value > 0 and axisDeadZones[joystick][axis]["shoulder"] then
			shouldermoved = true
			axisDeadZones[joystick][axis]["shoulder"] = false
		elseif value < 0 and not axisDeadZones[joystick][axis]["shoulder"] then
			axisDeadZones[joystick][axis]["shoulder"] = true
		end

		if gamestate == "menu" or gamestate == "options" then
			menu_joystickaxis(joystick, axis, value, stickmoved, shouldermoved)
		elseif gamestate == "game" then
			game_joystickaxis(joystick, axis, value, stickmoved, shouldermoved)
		end
	end
end

function love.joystickhat(joystick, hat, direction)
	local joysticks,found = love.joystick.getJoysticks(),false
	for i,v in ipairs(joysticks) do
		if v:getID() == joystick:getID() then
			joystick,found = i,true
			break
		end
	end
	
	if found then
		if gamestate == "menu" or gamestate == "options" then
			menu_joystickhat(joystick, hat, direction)
		elseif gamestate == "game" then
			game_joystickhat(joystick, hat, direction)
		end
	end
end

-- love.gamepadpressed = love.joystickpressed
-- love.gamepadreleased = love.joystickreleased
-- love.gamepadaxis = love.joystickaxis

function round(num, idp) --Not by me
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function getrainbowcolor(i)
	local r, g, b
	if i < 1/6 then
		r = 1
		g = i*6
		b = 0
	elseif i >= 1/6 and i < 2/6 then
		r = (1/6-(i-1/6))*6
		g = 1
		b = 0
	elseif i >= 2/6 and i < 3/6 then
		r = 0
		g = 1
		b = (i-2/6)*6
	elseif i >= 3/6 and i < 4/6 then
		r = 0
		g = (1/6-(i-3/6))*6
		b = 1
	elseif i >= 4/6 and i < 5/6 then
		r = (i-4/6)*6
		g = 0
		b = 1
	else
		r = 1
		g = 0
		b = (1/6-(i-5/6))*6
	end
	
	return {r, g, b, 1}
end

function newRecoloredImage(path, tablein, tableout)
	local imagedata = love.image.newImageData( path )
	local width, height = imagedata:getWidth(), imagedata:getHeight()
	
	for y = 0, height-1 do
		for x = 0, width-1 do
			local oldr, oldg, oldb, olda = imagedata:getPixel(x, y)
			
			if olda > 0.5*COLORSPACE then
				for i = 1, #tablein do
					if oldr == tablein[i][1] and oldg == tablein[i][2] and oldb == tablein[i][3] then
						local r, g, b = unpack(tableout[i])
						imagedata:setPixel(x, y, r * COLORSPACE, g * COLORSPACE, b * COLORSPACE, olda)
					end
				end
			end
		end
	end
	
	return love.graphics.newImage(imagedata)
end

function string:split(delimiter) --Not by me
	local result = {}
	local from  = 1
	local delim_from, delim_to = string.find( self, delimiter, from  )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from  )
	end
	table.insert( result, string.sub( self, from  ) )
	return result
end

function tablecontains(t, entry)
	for i, v in pairs(t) do
		if v == entry then
			return true
		end
	end
	return false
end

function getaveragecolor(imgdata, cox, coy)	
	local xstart = (cox-1)*17
	local ystart = (coy-1)*17
	
	local r, g, b = 0, 0, 0
	
	local count = 0
	
	for x = xstart, xstart+15 do
		for y = ystart, ystart+15 do
			local pr, pg, pb, a = imgdata:getPixel(x, y)
			if a > 0.5*COLORSPACE then
				r, g, b = r+pr, g+pg, b+pb
				count = count + 1
			end
		end
	end
	
	r, g, b = r/count, g/count, b/count
	
	return r, g, b
end

function keyprompt_update()
	if keyprompt then
		local js = love.joystick.getJoysticks()
		for i = 1, prompt.joysticks do
			for j = 1, #prompt.joystick[i].validhats do
				local dir = js[i]:getHat(prompt.joystick[i].validhats[j])
				if dir ~= "c" then
					keypromptenter("joyhat", i, prompt.joystick[i].validhats[j], dir)
					return
				end
			end
			
			for j = 1, prompt.joystick[i].axes do
				local value = js[i]:getAxis(j)
				if value > prompt.joystick[i].axisposition[j] + joystickdeadzone then
					keypromptenter("joyaxis", i, j, "pos")
					return
				elseif value < prompt.joystick[i].axisposition[j] - joystickdeadzone then
					keypromptenter("joyaxis", i, j, "neg")
					return
				end
			end
		end
	end
end

function print_r (t, indent) --Not by me
	local indent=indent or ''
	for key,value in pairs(t) do
		io.write(indent,'[',tostring(key),']') 
		if type(value)=="table" then io.write(':\n') print_r(value,indent..'\t')
		else io.write(' = ',tostring(value),'\n') end
	end
end

function love.focus(f)
	--[[if not f and gamestate == "game"and not editormode and not levelfinished and not everyonedead  then
		pausemenuopen = true
		paused = love.audio.pause()
	end--]]
end

function openSaveFolder(subfolder) --By Slime
	local path = love.filesystem.getSaveDirectory()
	path = subfolder and path.."/"..subfolder or path
	
	local cmdstr
	local successval = 0
	
	if os.getenv("WINDIR") then -- lolwindows
		--cmdstr = "Explorer /root,%s"
		if path:match("LOVE") then --hardcoded to fix ISO characters in usernames and made sure release mode doesn't mess anything up -saso
			cmdstr = "Explorer %%appdata%%\\LOVE\\mari0_se"
		else
			cmdstr = "Explorer %%appdata%%\\mari0_se"
		end
		path = path:gsub("/", "\\")
		successval = 1
	elseif os.getenv("HOME") then
		if path:match("/Library/Application Support") then -- OSX
			cmdstr = "open \"%s\""
		else -- linux?
			cmdstr = "xdg-open \"%s\""
		end
	end
	
	-- returns true if successfully opened folder
	return cmdstr and os.execute(cmdstr:format(path)) == successval
end

function getupdate()
	local onlinedata, code = http.request("http://server.stabyourself.net/mari0/?mode=mappacks")
	if code ~= 200 then
		return false
	elseif not onlinedata then
		return false
	end
	
	local latestversion
	
	local split1 = onlinedata:split("<")
	for i = 2, #split1 do
		local split2 = split1[i]:split(">")
		if split2[1] == "latestversion" then
			latestversion = tonumber(split2[2])
		end
	end
	
	if latestversion and latestversion > marioversion then
		return true
	end
	return false
end

function properprint(s, x, y, sc)
	local scale = sc or scale
	local startx = x
	local skip = 0
	for i = 1, string.len(tostring(s)) do
		if skip > 0 then
			skip = skip - 1
		else
			local char = string.sub(s, i, i)
			if string.sub(s, i, i+3) == "_dir" and tonumber(string.sub(s, i+4, i+4)) then
				love.graphics.draw(directionsimg, directionsquad[tonumber(string.sub(s, i+4, i+4))], x+((i-1)*8+1)*scale, y, 0, scale, scale)
				skip = 4
			elseif char == "|" then
				x = startx-((i)*8)*scale
				y = y + 10*scale
			elseif fontquads[char] then
				love.graphics.draw(fontimage, fontquads[char], x+((i-1)*8+1)*scale, y, 0, scale, scale)
			end
		end
	end
end

function properprintbackground(s, x, y, include, color, sc)
	local scale = sc or scale
	local startx = x
	local skip = 0
	for i = 1, string.len(tostring(s)) do
		if skip > 0 then
			skip = skip - 1
		else
			local char = string.sub(s, i, i)
			if char == "|" then
				x = startx-((i)*8)*scale
				y = y + 10*scale
			elseif fontquadsback[char] then
				love.graphics.draw(fontimageback, fontquadsback[char], x+((i-1)*8)*scale, y-1*scale, 0, scale, scale)
			end
		end
	end
	
	if include ~= false then
		properprint(s, x, y, scale)
	end
end

function loadcustombackgrounds()
	custombackgrounds = {}

	custombackgroundimg = {}
	custombackgroundwidth = {}
	custombackgroundheight = {}
	local fl = love.filesystem.getDirectoryItems("mappacks/" .. mappack .. "/backgrounds")
	
	for i = 1, #fl do
		local v = "mappacks/" .. mappack .. "/backgrounds/" .. fl[i]
		
		if love.filesystem.getInfo(v, "file") and v ~= ".DS_STORE" and v ~= ".DS_S" then
			if string.sub(v, -5, -5) == "1" then
				local name = string.sub(fl[i], 1, -6)
				local bg = string.sub(v, 1, -6)
				local i = 1
				
				custombackgroundimg[name] = {}
				custombackgroundwidth[name] = {}
				custombackgroundheight[name] = {}
					
				while love.filesystem.getInfo(bg .. i .. ".png") do
					custombackgroundimg[name][i] = love.graphics.newImage(bg .. i .. ".png")
					custombackgroundwidth[name][i] = custombackgroundimg[name][i]:getWidth()/16
					custombackgroundheight[name][i] = custombackgroundimg[name][i]:getHeight()/16
					i = i + 1
				end
				table.insert(custombackgrounds, name)
			else
				local name = string.sub(fl[i], 1, -5)
				local bg = string.sub(v, 1, -5)
				
				custombackgroundimg[name] = {love.graphics.newImage(bg .. ".png")}
				custombackgroundwidth[name] = {custombackgroundimg[name][1]:getWidth()/16}
				custombackgroundheight[name] = {custombackgroundimg[name][1]:getHeight()/16}
				
				table.insert(custombackgrounds, name)
			end
		end
	end
end

function loadlevelscreens()
	levelscreens = {}
	
	local fl = love.filesystem.getDirectoryItems("mappacks/" .. mappack .. "/levelscreens")
	
	for i = 1, #fl do
		local v = "mappacks/" .. mappack .. "/levelscreens/" .. fl[i]
		if love.filesystem.getInfo(v, "file") then
			table.insert(levelscreens, string.lower(string.sub(fl[i], 1, -5)))
		end
	end
end

function loadcustommusics()
	musiclist = {"none.ogg", "overworld.ogg", "underground.ogg", "castle.ogg", "underwater.ogg", "starmusic.ogg"}
	local fl = love.filesystem.getDirectoryItems("mappacks/" .. mappack .. "/music")
	custommusics = {}
	
	for i = 1, #fl do
		local v = fl[i]
		if (v:match(".ogg") or v:match(".mp3") or v:match(".mod")) and v:sub(-9, -5) ~= "-fast" then
			table.insert(musiclist, v)
			--music:load(v) --Sometimes I come back to code and wonder why things are commented out. This is one of those cases. But it works so eh.
		end
	end
end

function loadanimatedtiles()
	if animatedtilecount then
		for i = 1, animatedtilecount do
			tilequads[i + 10000] = nil
		end
	end
	
	local function loadfolder(folder)
		local i = 1
		while love.filesystem.getInfo(folder .. "/" .. i .. ".png") do
			local v = folder .. "/" .. i .. ".png"
			if love.filesystem.getInfo(v, "file") and string.sub(v, -4) == ".png" then
				if love.filesystem.getInfo(string.sub(v, 1, -5) .. ".txt", "file") then
					animatedtilecount = animatedtilecount + 1
					local number = animatedtilecount+10000
					local t = animatedquad:new(v, love.filesystem.read(string.sub(v, 1, -5) .. ".txt"), number)
					tilequads[number] = t
					table.insert(animatedtiles, t)
				end
			end
			i = i + 1
		end
	end
	
	animatedtilecount = 0
	animatedtiles = {}
	loadfolder("graphics/animated")
	loadfolder("mappacks/" .. mappack .. "/animated")
end

function loadcustomtiles()
	if love.filesystem.getInfo("mappacks/" .. mappack .. "/tiles.png") then
		customtiles = true
		customtilesimg = love.graphics.newImage("mappacks/" .. mappack .. "/tiles.png")
		local imgwidth, imgheight = customtilesimg:getWidth(), customtilesimg:getHeight()
		local width = math.floor(imgwidth/17)
		local height = math.floor(imgheight/17)
		local imgdata = love.image.newImageData("mappacks/" .. mappack .. "/tiles.png")
		
		for y = 1, height do
			for x = 1, width do
				table.insert(tilequads, quad:new(customtilesimg, imgdata, x, y, imgwidth, imgheight))
				local r, g, b = getaveragecolor(imgdata, x, y)
				table.insert(rgblist, {r / COLORSPACE, g / COLORSPACE, b / COLORSPACE})
			end
		end
		customtilecount = width*height
	else
		customtiles = false
		customtilecount = 0
	end
end

function loadmodcustomtiles()
	local files = love.filesystem.getDirectoryItems("mappacks/" .. mappack .. "/tiles")
	for i,j in pairs(files) do
		print(i,j)
		if string.sub(j, -4) ~= ".png" then
			table.remove(files, i)
			print(true)
		end
	end
	if files ~= nil then
		modcustomtiles = #files
		modcustomtilesimg = {}
		modcustomtilecount = {}
		for i = 1, modcustomtiles do
			modcustomtilesimg[i] = love.graphics.newImage("mappacks/" .. mappack .. "/tiles/" .. files[i])
			local imgwidth, imgheight = modcustomtilesimg[i]:getWidth(), modcustomtilesimg[i]:getHeight()
			local width = math.floor(imgwidth/17)
			local height = math.floor(imgheight/17)
			local imgdata = love.image.newImageData("mappacks/" .. mappack .. "/tiles/" .. files[i])
			
			for y = 1, height do
				for x = 1, width do
					table.insert(tilequads, quad:new(modcustomtilesimg[i], imgdata, x, y, imgwidth, imgheight))
					local r, g, b = getaveragecolor(imgdata, x, y)
					table.insert(rgblist, {r, g, b})
				end
			end
			modcustomtilecount[i] = (modcustomtilecount[i-1] or 0) + width*height
		end
	else
		modcustomtiles = false
		modcustomtilecount = {0}
	end
end

function love.quit()
	
end

function savestate(i)
	serializetable(_G)
end

function serializetable(t)
	tablestodo = {t}
	tableindex = {}
	repeat
		nexttablestodo = {}
		for i, v in pairs(tablestodo) do
			if type(v) == "table" then
				local tableexists = false
				for j, k in pairs(tableindex) do
					if k == v then
						tableexists = true
					end
				end
				
				if tableexists then
					
				else
					table.insert(nexttablestodo, v)
					table.insert(tableindex, v)
				end
			end
		end
		tablestodo = nexttablestodo
	until #tablestodo == 0
end

mouse = {}

function mouse.getPosition()
	if fullscreen then
		if fullscreenmode == "full" then
			return love.mouse.getX()/(desktopsize.width/(width*16*scale)), love.mouse.getY()/(desktopsize.height/(height*16*scale))
		else
			return love.mouse.getX()/(touchfrominsidescaling/scale), love.mouse.getY()/(touchfrominsidescaling/scale)-touchfrominsidemissing/2
		end
	else
		return love.mouse.getPosition()
	end
end

function mouse.getX()
	if fullscreen then
		if fullscreenmode == "full" then
			return love.mouse.getX()/(desktopsize.width/(width*16*scale))
		else
			return love.mouse.getX()/(touchfrominsidescaling/scale)
		end
	else
		return love.mouse.getX()
	end
end

function mouse.getY()
	if fullscreen then
		if fullscreenmode == "full" then
			return love.mouse.getY()/(desktopsize.height/(height*16*scale))
		else
			return love.mouse.getY()/(touchfrominsidescaling/scale)-touchfrominsidemissing/2
		end
	else
		return love.mouse.getY()
	end
end

function dbprint(x) --debugprint, can easily comment out the "print" thing
	print(x)
end