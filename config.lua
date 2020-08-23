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