function menu_load()
	loadconfig()
	love.audio.stop()
	editormode = false
	gamestate = "menu"

	for i, v in pairs(guielements) do
		v.active = false
	end

	selection = 1
	coinanimation = 1
	love.graphics.setBackgroundColor(92 / 255, 148 / 255, 252 / 255)
	scrollsmoothrate = 4
	optionstab = 2
	optionsselection = 1
	skinningplayer = 1
	rgbselection = 1
	mappackselection = 1
	onlinemappackselection = 1
	toconvertmappackselection = 1
	mappackhorscroll = 0
	mappackhorscrollsmooth = 0
	colorsetedit = 1
	love.graphics.setBackgroundColor(backgroundcolor[1])

	controlstable = {"left", "right", "up", "down", "run", "jump", "reload", "use", "aimx", "aimy", "portal1", "portal2"}

	portalanimation = 1
	portalanimationtimer = 0
	portalanimationdelay = 0.08

	infmarioY = 0
	infmarioR = 0

	infmarioYspeed = 200
	infmarioRspeed = 4

	RGBchangespeed = 0.8
	huechangespeed = 0.5
	spriteset = 1

	portalcolors = {}
	for i = 1, players do
		portalcolors[i] = {}
	end

	continueavailable = false
	if love.filesystem.getInfo("suspend.txt") then
		continueavailable = true
	end

	mariolevel = 1
	marioworld = 1
	mariosublevel = 0

	mariolives = nil

	--load 1-1 as background
	loadbackgroundsafe("1-1.txt")

	skipupdate = true

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

function menu_update(dt)
	--coinanimation
	coinanimation = coinanimation + dt*6.75
	while coinanimation >= 6 do
		coinanimation = coinanimation - 5
	end
	coinframe = math.max(1, math.floor(coinanimation))

	--Animate animated tiles because I say so
	for i = 1, #animatedtiles do
		animatedtiles[i]:update(dt)
	end

	if mappackscroll then
		--smooth the scroll
		if mappackscrollsmooth > mappackscroll then
			mappackscrollsmooth = mappackscrollsmooth - (mappackscrollsmooth-mappackscroll)*dt*5-0.1*dt
			if mappackscrollsmooth < mappackscroll then
				mappackscrollsmooth = mappackscroll
			end
		elseif mappackscrollsmooth < mappackscroll then
			mappackscrollsmooth = mappackscrollsmooth - (mappackscrollsmooth-mappackscroll)*dt*5+0.1*dt
			if mappackscrollsmooth > mappackscroll then
				mappackscrollsmooth = mappackscroll
			end
		end
	end

	if onlinemappackscroll then
		--smooth the scroll
		if onlinemappackscrollsmooth > onlinemappackscroll then
			onlinemappackscrollsmooth = onlinemappackscrollsmooth - (onlinemappackscrollsmooth-onlinemappackscroll)*dt*5-0.1*dt
			if onlinemappackscrollsmooth < onlinemappackscroll then
				onlinemappackscrollsmooth = onlinemappackscroll
			end
		elseif onlinemappackscrollsmooth < onlinemappackscroll then
			onlinemappackscrollsmooth = onlinemappackscrollsmooth - (onlinemappackscrollsmooth-onlinemappackscroll)*dt*5+0.1*dt
			if onlinemappackscrollsmooth > onlinemappackscroll then
				onlinemappackscrollsmooth = onlinemappackscroll
			end
		end
	end

	if toconvertmappackscroll then
		--smooth the scroll
		if toconvertmappackscrollsmooth > toconvertmappackscroll then
			toconvertmappackscrollsmooth = toconvertmappackscrollsmooth - (toconvertmappackscrollsmooth-toconvertmappackscroll)*dt*5-0.1*dt
			if toconvertmappackscrollsmooth < toconvertmappackscroll then
				toconvertmappackscrollsmooth = toconvertmappackscroll
			end
		elseif toconvertmappackscrollsmooth < toconvertmappackscroll then
			toconvertmappackscrollsmooth = toconvertmappackscrollsmooth - (toconvertmappackscrollsmooth-toconvertmappackscroll)*dt*5+0.1*dt
			if toconvertmappackscrollsmooth > toconvertmappackscroll then
				toconvertmappackscrollsmooth = toconvertmappackscroll
			end
		end
	end

	if mappackhorscroll then
		if mappackhorscrollsmooth > mappackhorscroll then
			mappackhorscrollsmooth = mappackhorscrollsmooth - (mappackhorscrollsmooth-mappackhorscroll)*dt*5-0.03*dt
			if mappackhorscrollsmooth < mappackhorscroll then
				mappackhorscrollsmooth = mappackhorscroll
			end
		elseif mappackhorscrollsmooth < mappackhorscroll then
			mappackhorscrollsmooth = mappackhorscrollsmooth - (mappackhorscrollsmooth-mappackhorscroll)*dt*5+0.03*dt
			if mappackhorscrollsmooth > mappackhorscroll then
				mappackhorscrollsmooth = mappackhorscroll
			end
		end
	end

	if gamestate == "options" and optionstab == 2 then
		portalanimationtimer = portalanimationtimer + dt
		while portalanimationtimer > portalanimationdelay do
			portalanimation = portalanimation + 1
			if portalanimation > 6 then
				portalanimation = 1
			end
			portalanimationtimer = portalanimationtimer - portalanimationdelay
		end

		infmarioY = infmarioY + infmarioYspeed*dt
		while infmarioY > 64 do
			infmarioY = infmarioY - 64
		end

		infmarioR = infmarioR + infmarioRspeed*dt
		while infmarioR > math.pi*2 do
			infmarioR = infmarioR - math.pi*2
		end

		if characters[mariocharacter[skinningplayer]].colorables and optionsselection > 5 and optionsselection < 9 then
			local colorRGB = optionsselection-5

			if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and mariocolors[skinningplayer][colorsetedit][colorRGB] < 1 then
				mariocolors[skinningplayer][colorsetedit][colorRGB] = mariocolors[skinningplayer][colorsetedit][colorRGB] + RGBchangespeed*dt
				if mariocolors[skinningplayer][colorsetedit][colorRGB] > 1 then
					mariocolors[skinningplayer][colorsetedit][colorRGB] = 1
				end
			elseif (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and mariocolors[skinningplayer][colorsetedit][colorRGB] > 0 then
				mariocolors[skinningplayer][colorsetedit][colorRGB] = mariocolors[skinningplayer][colorsetedit][colorRGB] - RGBchangespeed*dt
				if mariocolors[skinningplayer][colorsetedit][colorRGB] < 0 then
					mariocolors[skinningplayer][colorsetedit][colorRGB] = 0
				end
			end

		elseif (characters[mariocharacter[skinningplayer]].colorables and optionsselection == 9) or (not characters[mariocharacter[skinningplayer]].colorables and optionsselection == 4) then
			if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and portalhues[skinningplayer][1] < 1 then
				portalhues[skinningplayer][1] = portalhues[skinningplayer][1] + huechangespeed*dt
				if portalhues[skinningplayer][1] > 1 then
					portalhues[skinningplayer][1] = 1
				end
				portalcolor[skinningplayer][1] = getrainbowcolor(portalhues[skinningplayer][1])

			elseif (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and portalhues[skinningplayer][1] > 0 then
				portalhues[skinningplayer][1] = portalhues[skinningplayer][1] - huechangespeed*dt
				if portalhues[skinningplayer][1] < 0 then
					portalhues[skinningplayer][1] = 0
				end
				portalcolor[skinningplayer][1] = getrainbowcolor(portalhues[skinningplayer][1])
			end

		elseif (characters[mariocharacter[skinningplayer]].colorables and optionsselection == 10) or (not characters[mariocharacter[skinningplayer]].colorables and optionsselection == 5) then
			if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and portalhues[skinningplayer][2] < 1 then
				portalhues[skinningplayer][2] = portalhues[skinningplayer][2] + huechangespeed*dt
				if portalhues[skinningplayer][2] > 1 then
					portalhues[skinningplayer][2] = 1
				end
				portalcolor[skinningplayer][2] = getrainbowcolor(portalhues[skinningplayer][2])

			elseif (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and portalhues[skinningplayer][2] > 0 then
				portalhues[skinningplayer][2] = portalhues[skinningplayer][2] - huechangespeed*dt
				if portalhues[skinningplayer][2] < 0 then
					portalhues[skinningplayer][2] = 0
				end
				portalcolor[skinningplayer][2] = getrainbowcolor(portalhues[skinningplayer][2])
			end
		end
	elseif gamestate == "onlinemenu" then
		onlinemenu_update(dt)
	elseif gamestate == "lobby" then
		lobby_update(dt)
	end
end

function menu_draw()
	--GUI LIBRARY?! Never heard of that.
	--I'm not proud of this at all; But I'm even lazier than not proud. Seriously, don't take this as an example of what to do.

	drawlevel()
	drawui()

	for j = 1, players do
		local v = characters[mariocharacter[j]]
		local angle = 3
		if v.nopointing then
			angle = 1
		end

		local pid = j
		if pid > 4 then
			pid = 5
		end

		local portalcolor1, portalcolor2 = portalcolor[j][1], portalcolor[j][2]

		if players == 1 then
			portalcolor1, portalcolor2 = {60 / 255, 188 / 255, 252 / 255}, {232 / 255, 130 / 255, 30 / 255}
		end

		drawplayer(nil, ((startx[pid]-xscroll)*16)+8*(j-1), ((starty[pid]-yscroll)*16-12), scale,     v.smalloffsetX, v.smalloffsetY, 0, v.smallquadcenterX, v.smallquadcenterY, "idle", false, false, mariohats[j], v.animations, v.idle[angle], 0, false, false, mariocolors[j], 1, portalcolor1, portalcolor2, nil, nil, nil, nil, nil, nil, characters[mariocharacter[j]])
	end

	love.graphics.setColor(1, 1, 1, 1)
	drawforeground()

	if gamestate == "menu" then
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

	elseif gamestate == "mappackmenu" then
		--background
		love.graphics.setColor(0, 0, 0, 0.4)
		love.graphics.rectangle("fill", 21*scale, 16*scale, 218*scale, 200*scale)
		love.graphics.setColor(1, 1, 1, 1)

		--set scissor
		love.graphics.setScissor(21*scale, 16*scale, 218*scale, 200*scale)

		if loadingonlinemappacks then
			love.graphics.setColor(0, 0, 0, 0.8)
			love.graphics.rectangle("fill", 21*scale, 16*scale, 218*scale, 200*scale)
			love.graphics.setColor(1, 1, 1, 1)
			properprint("a little patience..|downloading " .. currentdownload .. " of " .. downloadcount, 50*scale, 30*scale)
			drawrectangle(50, 55, 152, 10)
			love.graphics.rectangle("fill", 50*scale, 55*scale, 152*((currentfiledownload-1)/(filecount-1))*scale, 10*scale)
		else
			love.graphics.translate(-round(mappackhorscrollsmooth*scale*mappackhorscrollrange), 0)

			if mappackhorscrollsmooth < 1 then
				--draw each butten (even if all you do, is press ONE. BUTTEN.)
				--scrollbar offset
				love.graphics.translate(0, -round(mappackscrollsmooth*60*scale))

				love.graphics.setScissor(240*scale, 16*scale, 200*scale, 200*scale)
				love.graphics.setColor(0, 0, 0, 0.8)
				love.graphics.rectangle("fill", 240*scale, 81*scale, 115*scale, 61*scale)
				love.graphics.setColor(1, 1, 1)
				if not savefolderfailed then
					properprint("press right to|access the dlc||press m to|open your|mappack folder", 241*scale, 83*scale)
				else
					properprint("press right to|access the dlc||could not|open your|mappack folder", 241*scale, 83*scale)
				end
				love.graphics.setScissor(21*scale, 16*scale, 218*scale, 200*scale)

				for i = 1, #mappacklist do
					--back
					love.graphics.draw(mappackback, 25*scale, (20+(i-1)*60)*scale, 0, scale, scale)

					--icon
					if mappackicon[i] ~= nil then
						local scale2w = scale*50 / math.max(1, mappackicon[i]:getWidth())
						local scale2h = scale*50 / math.max(1, mappackicon[i]:getHeight())
						love.graphics.draw(mappackicon[i], 29*scale, (24+(i-1)*60)*scale, 0, scale2w, scale2h)
					else
						love.graphics.draw(mappacknoicon, 29*scale, (24+(i-1)*60)*scale, 0, scale, scale)
					end
					love.graphics.draw(mappackoverlay, 29*scale, (24+(i-1)*60)*scale, 0, scale, scale)

					--name
					love.graphics.setColor(0.8, 0.8, 0.8)
					if mappackselection == i then
						love.graphics.setColor(1, 1, 1)
					end

					properprint(string.sub(mappackname[i]:lower(), 1, 17), 83*scale, (26+(i-1)*60)*scale)

					--author
					love.graphics.setColor(0.4, 0.4, 0.4)
					if mappackselection == i then
						love.graphics.setColor(0.4, 0.4, 0.4)
					end

					if mappackauthor[i] then
						properprint(string.sub("by " .. mappackauthor[i]:lower(), 1, 16), 91*scale, (35+(i-1)*60)*scale)
					end

					--description
					love.graphics.setColor(0.5, 0.5, 0.5)
					if mappackselection == i then
						love.graphics.setColor(0.7, 0.7, 0.7)
					end

					if mappackdescription[i] then
						properprint( string.sub(mappackdescription[i]:lower(), 1, 17), 83*scale, (47+(i-1)*60)*scale)

						if mappackdescription[i]:len() > 17 then
							properprint( string.sub(mappackdescription[i]:lower(), 18, 34), 83*scale, (56+(i-1)*60)*scale)
						end

						if mappackdescription[i]:len() > 34 then
							properprint( string.sub(mappackdescription[i]:lower(), 35, 51), 83*scale, (65+(i-1)*60)*scale)
						end
					end

					love.graphics.setColor(1, 1, 1)

					--highlight
					if i == mappackselection then
						love.graphics.draw(mappackhighlight, 25*scale, (20+(i-1)*60)*scale, 0, scale, scale)
					end
				end

				love.graphics.translate(0, round(mappackscrollsmooth*60*scale))

				local i = mappackscrollsmooth / (#mappacklist-3.233)

				love.graphics.draw(mappackscrollbar, 227*scale, (20+i*160)*scale, 0, scale, scale)

			end

			love.graphics.translate(round(mappackhorscrollsmooth*scale*mappackhorscrollrange), 0)
			----------
			--ONLINE--
			----------

			love.graphics.translate(round(mappackhorscrollrange*scale - mappackhorscrollsmooth*scale*mappackhorscrollrange), 0)

			if mappackhorscrollsmooth > 0 and mappackhorscrollsmooth < 2 then
				if #onlinemappacklist == 0 then
					properprint("something went wrong||      sorry d:||maybe your internet|does not work right?", 40*scale, 80*scale)
				end

				love.graphics.setScissor(240*scale, 16*scale, 200*scale, 200*scale)
				love.graphics.setColor(0, 0, 0, 0.8)
				love.graphics.rectangle("fill", 241*scale, 16*scale, 150*scale, 200*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprint("wanna contribute?|make a mappack and|send an email to|mappack at|stabyourself.net!||include your map-|pack! you can find|it in your appdata|love/mari0 dir.", 244*scale, 19*scale)
				if outdated then
					love.graphics.setColor(1, 0, 0, 1)
					properprint("version outdated!|you have an old|version of mari0!|mappacks could not|be downloaded.|go to|stabyourself.net|to download latest", 244*scale, 130*scale)
					love.graphics.setColor(1, 1, 1, 1)
				elseif downloaderror then
					love.graphics.setColor(1, 0, 0, 1)
					properprint("download error!|something went|wrong while|downloading|mappacks.|press left and|right to try|again.  sorry.", 244*scale, 130*scale)
					love.graphics.setColor(1, 1, 1, 1)
				end

				love.graphics.setScissor(21*scale, 16*scale, 218*scale, 200*scale)

				--scrollbar offset
				love.graphics.translate(0, -round(onlinemappackscrollsmooth*60*scale))
				for i = 1, #onlinemappacklist do
					--back
					love.graphics.draw(mappackback, 25*scale, (20+(i-1)*60)*scale, 0, scale, scale)

					--icon
					if onlinemappackicon[i] ~= nil then
						love.graphics.draw(onlinemappackicon[i], 29*scale, (24+(i-1)*60)*scale, 0, scale, scale)
					else
						love.graphics.draw(mappacknoicon, 29*scale, (24+(i-1)*60)*scale, 0, scale, scale)
					end
					love.graphics.draw(mappackoverlay, 29*scale, (24+(i-1)*60)*scale, 0, scale, scale)

					--name
					love.graphics.setColor(0.8, 0.8, 0.8)
					if onlinemappackselection == i then
						love.graphics.setColor(1, 1, 1)
					end

					properprint(string.sub(onlinemappackname[i]:lower(), 1, 17), 83*scale, (26+(i-1)*60)*scale)

					--author
					love.graphics.setColor(0.4, 0.4, 0.4)
					if onlinemappackselection == i then
						love.graphics.setColor(0.4, 0.4, 0.4)
					end

					if onlinemappackauthor[i] then
						properprint(string.sub("by " .. onlinemappackauthor[i]:lower(), 1, 16), 91*scale, (35+(i-1)*60)*scale)
					end

					--description
					love.graphics.setColor(0.5, 0.5, 0.5)
					if onlinemappackselection == i then
						love.graphics.setColor(0.7, 0.7, 0.7)
					end

					if onlinemappackdescription[i] then
						properprint( string.sub(onlinemappackdescription[i]:lower(), 1, 17), 83*scale, (47+(i-1)*60)*scale)

						if onlinemappackdescription[i]:len() > 17 then
							properprint( string.sub(onlinemappackdescription[i]:lower(), 18, 34), 83*scale, (56+(i-1)*60)*scale)
						end

						if onlinemappackdescription[i]:len() > 34 then
							properprint( string.sub(onlinemappackdescription[i]:lower(), 35, 51), 83*scale, (65+(i-1)*60)*scale)
						end
					end

					love.graphics.setColor(1, 1, 1)

					--highlight
					if i == onlinemappackselection then
						love.graphics.draw(mappackhighlight, 25*scale, (20+(i-1)*60)*scale, 0, scale, scale)
					end
				end

				love.graphics.translate(0, round(onlinemappackscrollsmooth*60*scale))

				local i = onlinemappackscrollsmooth / (#onlinemappacklist-3.233)

				love.graphics.draw(mappackscrollbar, 227*scale, (20+i*160)*scale, 0, scale, scale)
			end

			love.graphics.translate(- round(mappackhorscrollrange*scale - mappackhorscrollsmooth*scale*mappackhorscrollrange), 0)
			----------------
			--OLD MAPPACKS--
			----------------

			love.graphics.translate(round(mappackhorscrollrange*scale*2 - mappackhorscrollsmooth*scale*mappackhorscrollrange), 0)

			if mappackhorscrollsmooth > 1 then
				love.graphics.setScissor(240*scale, 16*scale, 200*scale, 200*scale)
				love.graphics.setColor(0, 0, 0, 0.8)
				love.graphics.rectangle("fill", 240*scale, 81*scale, 150*scale, 61*scale)
				love.graphics.setColor(1, 1, 1)
				properprint("use this menu to|convert a mappack|from the old 1.6|format to the ce|one. may take some|time!", 244*scale, 83*scale)
				love.graphics.setScissor(21*scale, 16*scale, 218*scale, 200*scale)
				love.graphics.setColor(1,1,1)
				love.graphics.translate(0, -round(toconvertmappackscrollsmooth*60*scale))

				for i = 1, #toconvertmappacklist do
					--back
					love.graphics.draw(mappackback, 25*scale, (20+(i-1)*60)*scale, 0, scale, scale)

					--icon
					if toconvertmappackicon[i] ~= nil then
						local scale2w = scale*50 / math.max(1, toconvertmappackicon[i]:getWidth())
						local scale2h = scale*50 / math.max(1, toconvertmappackicon[i]:getHeight())
						love.graphics.draw(toconvertmappackicon[i], 29*scale, (24+(i-1)*60)*scale, 0, scale2w, scale2h)
					else
						love.graphics.draw(mappacknoicon, 29*scale, (24+(i-1)*60)*scale, 0, scale, scale)
					end
					love.graphics.draw(mappackoverlay, 29*scale, (24+(i-1)*60)*scale, 0, scale, scale)

					--name
					love.graphics.setColor(0.8, 0.8, 0.8)
					if mappackselection == i then
						love.graphics.setColor(1, 1, 1)
					end

					properprint(string.sub(toconvertmappackname[i]:lower(), 1, 17), 83*scale, (26+(i-1)*60)*scale)

					--author
					love.graphics.setColor(0.4, 0.4, 0.4)
					if toconvertmappackselection == i then
						love.graphics.setColor(0.4, 0.4, 0.4)
					end

					if toconvertmappackauthor[i] then
						properprint(string.sub("by " .. toconvertmappackauthor[i]:lower(), 1, 16), 91*scale, (35+(i-1)*60)*scale)
					end

					--description
					love.graphics.setColor(0.5, 0.5, 0.5)
					if toconvertmappackselection == i then
						love.graphics.setColor(0.7, 0.7, 0.7)
					end

					if toconvertmappackdescription[i] then
						properprint( string.sub(toconvertmappackdescription[i]:lower(), 1, 17), 83*scale, (47+(i-1)*60)*scale)

						if toconvertmappackdescription[i]:len() > 17 then
							properprint( string.sub(toconvertmappackdescription[i]:lower(), 18, 34), 83*scale, (56+(i-1)*60)*scale)
						end

						if toconvertmappackdescription[i]:len() > 34 then
							properprint( string.sub(toconvertmappackdescription[i]:lower(), 35, 51), 83*scale, (65+(i-1)*60)*scale)
						end
					end

					love.graphics.setColor(1, 1, 1)

					--highlight
					if i == toconvertmappackselection then
						love.graphics.draw(mappackhighlight, 25*scale, (20+(i-1)*60)*scale, 0, scale, scale)
					end
				end

				love.graphics.translate(0, round(toconvertmappackscrollsmooth*60*scale))
				local i = toconvertmappackscrollsmooth / (#toconvertmappacklist-3.233)

				love.graphics.draw(mappackscrollbar, 227*scale, (20+i*160)*scale, 0, scale, scale)
				love.graphics.setScissor()
			end

			love.graphics.translate(- round(mappackhorscrollrange*scale*2 - mappackhorscrollsmooth*scale*mappackhorscrollrange), 0)
		end

		love.graphics.setScissor()

		if mappackhorscroll == 0 then
			love.graphics.setColor(1, 1, 1)
			love.graphics.rectangle("fill", 22*scale, 3*scale, 44*scale, 13*scale)
			love.graphics.setColor(0, 0, 0)
			properprint("local", 23*scale, 6*scale)
			drawrectangle(22, 3, 44, 13)
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle("fill", 70*scale, 3*scale, 29*scale, 13*scale)
			love.graphics.rectangle("fill", 103*scale, 3*scale, 29*scale, 13*scale)
			love.graphics.setColor(1, 1, 1)
			properprint("dlc", 72*scale, 6*scale)
			properprint("1.6", 105*scale, 6*scale)
		elseif mappackhorscroll == 1 then
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle("fill", 22*scale, 3*scale, 44*scale, 13*scale)
			love.graphics.rectangle("fill", 103*scale, 3*scale, 29*scale, 13*scale)
			love.graphics.setColor(1, 1, 1)
			properprint("local", 23*scale, 6*scale)
			properprint("1.6", 105*scale, 6*scale)
			love.graphics.setColor(1, 1, 1)
			love.graphics.rectangle("fill", 70*scale, 3*scale, 29*scale, 13*scale)
			love.graphics.setColor(0, 0, 0)
			properprint("dlc", 72*scale, 6*scale)
			drawrectangle(70, 3, 29, 13)
		elseif mappackhorscroll == 2 then
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle("fill", 22*scale, 3*scale, 44*scale, 13*scale)
			love.graphics.rectangle("fill", 70*scale, 3*scale, 29*scale, 13*scale)
			love.graphics.setColor(1, 1, 1)
			properprint("local", 23*scale, 6*scale)
			properprint("dlc", 72*scale, 6*scale)
			love.graphics.setColor(1, 1, 1)
			love.graphics.rectangle("fill", 103*scale, 3*scale, 29*scale, 13*scale)
			love.graphics.setColor(0, 0, 0)
			properprint("1.6", 105*scale, 6*scale)
			drawrectangle(103, 3, 29, 13)
		end
	elseif gamestate == "options" then
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle("fill", 21*scale, 16*scale, 218*scale, 200*scale)

		--Controls tab head
		if optionstab == 1 then
			love.graphics.setColor(0.4, 0.4, 0.4, 0.4)
			love.graphics.rectangle("fill", 25*scale, 20*scale, 67*scale, 11*scale)
		end

		if optionstab == 1 and optionsselection == 1 then
			love.graphics.setColor(1, 1, 1, 1)
		else
			love.graphics.setColor(0.4, 0.4, 0.4, 1)
		end
		properprint("controls", 26*scale, 22*scale)

		--Skins tab head
		if optionstab == 2 then
			love.graphics.setColor(0.4, 0.4, 0.4, 0.4)
			love.graphics.rectangle("fill", 96*scale, 20*scale, 43*scale, 11*scale)
		end


		if optionstab == 2 and optionsselection == 1 then
			love.graphics.setColor(1, 1, 1, 1)
		else
			love.graphics.setColor(0.4, 0.4, 0.4, 1)
		end
		properprint("skins", 97*scale, 22*scale)

		--Miscellaneous tab head
		if optionstab == 3 then
			love.graphics.setColor(0.4, 0.4, 0.4, 0.4)
			love.graphics.rectangle("fill", 145*scale, 20*scale, 39*scale, 11*scale)
		end

		if optionstab == 3 and optionsselection == 1 then
			love.graphics.setColor(1, 1, 1, 1)
		else
			love.graphics.setColor(0.4, 0.4, 0.4, 1)
		end
		properprint("misc.", 146*scale, 22*scale)

		--Cheat tab head
		if optionstab == 4 then
			love.graphics.setColor(0.4, 0.4, 0.4, 0.4)
			love.graphics.rectangle("fill", 190*scale, 20*scale, 43*scale, 11*scale)
		end

		if optionstab == 4 and optionsselection == 1 then
			love.graphics.setColor(1, 1, 1, 1)
		else
			love.graphics.setColor(0.4, 0.4, 0.4, 1)
		end
		properprint("cheat", 191*scale, 22*scale)

		love.graphics.setColor(1, 1, 1, 1)

		if optionstab == 1 then
			--CONTROLS
			if optionsselection == 2 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("edit player:" .. skinningplayer, 74*scale, 40*scale)

			if optionsselection == 3 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			if mouseowner == skinningplayer then
				properprint("uses the mouse: yes", 46*scale, 52*scale)
			else
				properprint("uses the mouse: no", 46*scale, 52*scale)
			end

			for i = 1, #controlstable do
				if mouseowner ~= skinningplayer or i <= 8 then
					if optionsselection == 3+i then
						love.graphics.setColor(1, 1, 1, 1)
					else
						love.graphics.setColor(0.4, 0.4, 0.4, 1)
					end

					properprint(controlstable[i], 30*scale, (70+(i-1)*12)*scale)

					local s = ""

					if controls[skinningplayer][controlstable[i]] then
						for j = 1, #controls[skinningplayer][controlstable[i]] do
							s = s .. controls[skinningplayer][controlstable[i]][j]
						end
					end
					if s == " " then
						s = "space"
					end
					properprint(s, 120*scale, (70+(i-1)*12)*scale)
				end
			end

			if keyprompt then
				love.graphics.setColor(0, 0, 0, 1)
				love.graphics.rectangle("fill", 30*scale, 100*scale, 200*scale, 60*scale)
				love.graphics.setColor(1, 1, 1, 1)
				drawrectangle(30, 100, 200, 60)
				if controlstable[optionsselection-3] == "aimx" then
					properprint("move stick right", 40*scale, 110*scale)
				elseif controlstable[optionsselection-3] == "aimy" then
					properprint("move stick down", 40*scale, 110*scale)
				else
					properprint("press key for \"" .. controlstable[optionsselection-3] .. "\"", 40*scale, 110*scale)
				end
				properprint("press \"esc\" to cancel", 40*scale, 140*scale)

				if buttonerror then
					love.graphics.setColor(0.8, 0, 0)
					properprint("you can only set", 40*scale, 120*scale)
					properprint("buttons for this", 40*scale, 130*scale)
				elseif axiserror then
					love.graphics.setColor(0.8, 0, 0)
					properprint("you can only set", 40*scale, 120*scale)
					properprint("axes for this", 40*scale, 130*scale)
				end
			end
		elseif optionstab == 2 then
			--SKINS
			if optionsselection == 2 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("edit player:" .. skinningplayer, 74*scale, 32*scale)

			--PREVIEW MARIO IN BIG. WITH BIG LETTERS
			local v = characters[mariocharacter[skinningplayer]]
			local angle = 3
			if v.nopointing then
				angle = 1
			end
			drawplayer(nil, 46, 32, scale*2,     v.smalloffsetX, v.smalloffsetY, 0, v.smallquadcenterX, v.smallquadcenterY, "idle", false, false, mariohats[skinningplayer], v.animations, v.idle[angle], 0, false, false, mariocolors[skinningplayer], 1, portalcolor[skinningplayer][1], portalcolor[skinningplayer][2], nil, nil, nil, nil, nil, nil, characters[mariocharacter[skinningplayer]])


			--PREVIEW PORTALS WITH FALLING MARIO BECAUSE I CAN AND IT LOOKS RAD
			love.graphics.setScissor(142*scale, 42*scale, 32*scale, 32*scale)

			for j = 1, 3 do
				--158*scale, (2+((j-1)*32)+infmarioY)*scale
				local v = characters[mariocharacter[skinningplayer]]
				local angle = 3
				if v.nopointing then
					angle = 1
				end
				drawplayer(nil, 158, ((j-1)*32)+infmarioY+2, scale,     v.smalloffsetX, v.smalloffsetY, infmarioR, v.smallquadcenterX, v.smallquadcenterY, "jumping", false, false, mariohats[skinningplayer], v.animations, v.jump[angle][1], 0, false, false, mariocolors[skinningplayer], 1, portalcolor[skinningplayer][1], portalcolor[skinningplayer][2], nil, nil, nil, 1, nil, nil, characters[mariocharacter[skinningplayer]])
			end

			local portalframe = portalanimation

			love.graphics.setColor(1, 1, 1, (80 - math.abs(portalframe-3)*10)/255)
			love.graphics.draw(portalglowimg, 174*scale, 59*scale, math.pi, scale, scale)
			love.graphics.draw(portalglowimg, 142*scale, 57*scale, 0, scale, scale)

			love.graphics.setColor(unpack(portalcolor[skinningplayer][1]))
			love.graphics.draw(portalimg, portalquad[portalframe], 174*scale, 46*scale, math.pi, scale, scale)
			love.graphics.setColor(unpack(portalcolor[skinningplayer][2]))
			love.graphics.draw(portalimg, portalquad[portalframe], 142*scale, 70*scale, 0, scale, scale)

			love.graphics.setScissor()

			--Character change
			if optionsselection == 3 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("{", 65*scale, 54*scale)
			properprint("}", 110*scale, 54*scale)
			properprint(characters[mariocharacter[skinningplayer]].name, (118-#characters[mariocharacter[skinningplayer]].name*4)*scale, 80*scale)

			if v.colorables then
				--HAT
				if optionsselection == 4 then
					love.graphics.setColor(1, 1, 1, 1)
				else
					love.graphics.setColor(0.4, 0.4, 0.4, 1)
				end
				if mariohats[skinningplayer][1] == 0 then
					properprint("hat: none", (83)*scale, 90*scale)
				else
					properprint("hat: " .. mariohats[skinningplayer][1], (99-string.len(mariohats[skinningplayer][1])*4)*scale, 90*scale)
				end

				if optionsselection == 5 then
					love.graphics.setColor(1, 1, 1, 1)
				else
					love.graphics.setColor(0.4, 0.4, 0.4, 1)
				end

				--NEW SKIN CUSTOMIZATION
				local v = characters[mariocharacter[skinningplayer]]
				properprint("{ " .. v.colorables[colorsetedit] .. " }", 120*scale-string.len("{ " .. v.colorables[colorsetedit] .. " }")*4*scale, 105*scale)

				if optionsselection > 5 and optionsselection < 9 then
					love.graphics.setColor(1, 1, 1, 1)
					love.graphics.rectangle("fill", 39*scale, 114*scale + (optionsselection-6)*10*scale, 142*scale, 10*scale)
				end

				love.graphics.setColor(0.4, 0, 0)
				properprint("r", 40*scale, (116)*scale)
				love.graphics.setColor(1, 0, 0)
				properprint("r", 39*scale, (115)*scale)

				love.graphics.setColor(0, 0.4, 0)
				properprint("g", 40*scale, (126)*scale)
				love.graphics.setColor(0, 1, 0)
				properprint("g", 39*scale, (125)*scale)

				love.graphics.setColor(0, 0, 0.4)
				properprint("b", 40*scale, (136)*scale)
				love.graphics.setColor(0, 0, 1)
				properprint("b", 39*scale, (135)*scale)

				love.graphics.setColor(0.4, 0, 0)
				love.graphics.rectangle("fill", 51*scale, (116)*scale, math.floor(129*scale * mariocolors[skinningplayer][colorsetedit][1]), 7*scale)
				love.graphics.setColor(1, 0, 0)
				love.graphics.rectangle("fill", 50*scale, (115)*scale, math.floor(129*scale * mariocolors[skinningplayer][colorsetedit][1]), 7*scale)

				love.graphics.setColor(0.4, 0.4, 0.4)
				local s = math.floor(mariocolors[skinningplayer][colorsetedit][1] * 255)
				properprint(s, 200*scale-string.len(s)*4*scale, 116*scale)

				love.graphics.setColor(0, 0.4, 0)
				love.graphics.rectangle("fill", 51*scale, (126)*scale, math.floor(129*scale * mariocolors[skinningplayer][colorsetedit][2]), 7*scale)
				love.graphics.setColor(0, 1, 0)
				love.graphics.rectangle("fill", 50*scale, (125)*scale, math.floor(129*scale * mariocolors[skinningplayer][colorsetedit][2]), 7*scale)

				love.graphics.setColor(0.4, 0.4, 0.4)
				local s = math.floor(mariocolors[skinningplayer][colorsetedit][2] * 255)
				properprint(s, 200*scale-string.len(s)*4*scale, 126*scale)

				love.graphics.setColor(0, 0, 0.4)
				love.graphics.rectangle("fill", 51*scale, (136)*scale, math.floor(129*scale * mariocolors[skinningplayer][colorsetedit][3]), 7*scale)
				love.graphics.setColor(0, 0, 1)
				love.graphics.rectangle("fill", 50*scale, (135)*scale, math.floor(129*scale * mariocolors[skinningplayer][colorsetedit][3]), 7*scale)

				love.graphics.setColor(0.4, 0.4, 0.4)
				local s = math.floor(mariocolors[skinningplayer][colorsetedit][3] * 255)
				properprint(s, 200*scale-string.len(s)*4*scale, 136*scale)
			end

			--Portalhuehues
			--hue
			local alpha = 0.4

			if characters[mariocharacter[skinningplayer]].colorables then
				if optionsselection == 9 then
					alpha = 1
				end
			else
				if optionsselection == 4 then
					alpha = 1
				end
			end

			love.graphics.setColor(1, 1, 1, alpha)

			properprint("coop portal 1 color:", 31*scale, 150*scale)

			love.graphics.draw(huebarimg, 32*scale, 170*scale, 0, scale, scale)

			--marker
			love.graphics.setColor(unpack(portalcolor[skinningplayer][1]))
			love.graphics.rectangle("fill", math.floor(29 + (portalhues[skinningplayer][1])*178)*scale, 161*scale, 7*scale, 6*scale)
			love.graphics.setColor(alpha, alpha, alpha)
			love.graphics.draw(huebarmarkerimg, math.floor(28 + (portalhues[skinningplayer][1])*178)*scale, 160*scale, 0, scale, scale)

			alpha = 0.4
			if characters[mariocharacter[skinningplayer]].colorables then
				if optionsselection == 10 then
					alpha = 1
				end
			else
				if optionsselection == 5 then
					alpha = 1
				end
			end

			love.graphics.setColor(1, 1, 1, alpha)

			properprint("coop portal 2 color:", 31*scale, 180*scale)

			love.graphics.draw(huebarimg, 32*scale, 200*scale, 0, scale, scale)

			--marker
			love.graphics.setColor(unpack(portalcolor[skinningplayer][2]))
			love.graphics.rectangle("fill", math.floor(29 + (portalhues[skinningplayer][2])*178)*scale, 191*scale, 7*scale, 6*scale)
			love.graphics.setColor(alpha, alpha, alpha)
			love.graphics.draw(huebarmarkerimg, math.floor(28 + (portalhues[skinningplayer][2])*178)*scale, 190*scale, 0, scale, scale)
		elseif optionstab == 3 then
			if optionsselection == 2 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end
			properprint("size:", 30*scale, 40*scale)
			if fullscreen then
				if fullscreenmode == "touchfrominside" then
					properprint("letterbox", (180-string.len("letterbox")*8)*scale, 40*scale)
				else
					properprint("fullscreen", (180-string.len("fullscreen")*8)*scale, 40*scale)
				end
			else
				properprint("*" .. scale, (180-(string.len(scale)+1)*8)*scale, 40*scale)
			end


			if optionsselection == 3 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("shader1:", 30*scale, 55*scale)
			if shaderssupported == false then
				properprint("unsupported", (180-string.len("unsupported")*8)*scale, 55*scale)
			else
				properprint(string.lower(shaderlist[currentshaderi1]), (180-string.len(shaderlist[currentshaderi1])*8)*scale, 55*scale)
			end

			if optionsselection == 4 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end
			properprint("shader2:", 30*scale, 65*scale)
			if shaderssupported == false then
				properprint("unsupported", (180-string.len("unsupported")*8)*scale, 65*scale)
			else
				properprint(string.lower(shaderlist[currentshaderi2]), (180-string.len(shaderlist[currentshaderi2])*8)*scale, 65*scale)
			end

			love.graphics.setColor(0.4, 0.4, 0.4, 1)
			properprint("shaders will really", 30*scale, 80*scale)
			properprint("reduce performance!", 30*scale, 90*scale)

			if optionsselection == 5 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end
			properprint("game volume:", 30*scale, 105*scale)
			drawrectangle(138, 108, 90, 1)
			drawrectangle(138, 105, 1, 7)
			drawrectangle(227, 105, 1, 7)
			love.graphics.draw(volumesliderimg, math.floor((137+89*volumesfx)*scale), 105*scale, 0, scale, scale)

			if optionsselection == 6 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end
			properprint("music volume:", 30*scale, 120*scale)
			drawrectangle(138, 123, 90, 1)
			drawrectangle(138, 120, 1, 7)
			drawrectangle(227, 120, 1, 7)
			love.graphics.draw(volumesliderimg, math.floor((137+89*volumemusic)*scale), 120*scale, 0, scale, scale)

			if optionsselection == 7 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("reset game mappacks", 30*scale, 135*scale)

			if optionsselection == 8 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("reset all settings", 30*scale, 150*scale)

			if optionsselection == 9 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("vsync:", 30*scale, 165*scale)
			if vsync then
				properprint("on", (180-16)*scale, 165*scale)
			else
				properprint("off", (180-24)*scale, 165*scale)
			end

			love.graphics.setColor(0.4, 0.4, 0.4, 1)
			properprint("you can lock the|mouse with f12", 30*scale, 180*scale)

			love.graphics.setColor(1, 1, 1, 1)
			properprint(versionstring, 134*scale, 207*scale)
		elseif optionstab == 4 then
			love.graphics.setColor(1, 1, 1, 1)
			if not gamefinished then
				properprint("unlock this by completing", 30*scale, 40*scale)
				properprint("the original levels pack!", 30*scale, 50*scale)
			else
				properprint("have fun with these!", 30*scale, 45*scale)
			end

			if optionsselection == 2 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("mode:", 30*scale, 65*scale)
			properprint("{" .. playertype .. "}", (180-(string.len(playertype)+2)*8)*scale, 65*scale)

			if optionsselection == 3 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("knockback:", 30*scale, 80*scale)
			if portalknockback then
				properprint("on", (180-16)*scale, 80*scale)
			else
				properprint("off", (180-24)*scale, 80*scale)
			end

			if optionsselection == 4 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("bullettime:", 30*scale, 95*scale)
			properprint("use mousewheel", 30*scale, 105*scale)
			if bullettime then
				properprint("on", (180-16)*scale, 95*scale)
			else
				properprint("off", (180-24)*scale, 95*scale)
			end

			if optionsselection == 5 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("huge mario:", 30*scale, 120*scale)
			if bigmario then
				properprint("on", (180-16)*scale, 120*scale)
			else
				properprint("off", (180-24)*scale, 120*scale)
			end

			if optionsselection == 6 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("goomba attack:", 30*scale, 135*scale)
			if goombaattack then
				properprint("on", (180-16)*scale, 135*scale)
			else
				properprint("off", (180-24)*scale, 135*scale)
			end

			if optionsselection == 7 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("sonic rainboom:", 30*scale, 150*scale)
			if sonicrainboom then
				properprint("on", (180-16)*scale, 150*scale)
			else
				properprint("off", (180-24)*scale, 150*scale)
			end

			if optionsselection == 8 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("playercollision:", 30*scale, 165*scale)
			if playercollisions then
				properprint("on", (180-16)*scale, 165*scale)
			else
				properprint("off", (180-24)*scale, 165*scale)
			end

			if optionsselection == 9 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("infinite time:", 30*scale, 180*scale)
			if infinitetime then
				properprint("on", (180-16)*scale, 180*scale)
			else
				properprint("off", (180-24)*scale, 180*scale)
			end

			if optionsselection == 10 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
			end

			properprint("infinite lives:", 30*scale, 195*scale)
			if infinitelives then
				properprint("on", (180-16)*scale, 195*scale)
			else
				properprint("off", (180-24)*scale, 195*scale)
			end
		end
	elseif gamestate == "onlinemenu" then
		onlinemenu_draw()
	elseif gamestate == "lobby" then
		lobby_draw()
	end
	love.graphics.translate(0, yoffset*scale)
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

function updatescroll()
	--check if current focus is completely onscreen
	if inrange(mappackselection, 1+mappackscroll, 3+mappackscroll, true) == false then
		if mappackselection < 1+mappackscroll then --above window
			mappackscroll = mappackselection-1
		else
			mappackscroll = mappackselection-3.233
		end
	end
end

function onlineupdatescroll()
	--check if current focus is completely onscreen
	if inrange(onlinemappackselection, 1+onlinemappackscroll, 3+onlinemappackscroll, true) == false then
		if onlinemappackselection < 1+onlinemappackscroll then --above window
			onlinemappackscroll = onlinemappackselection-1
		else
			onlinemappackscroll = onlinemappackselection-3.233
		end
	end
end

function toconvertupdatescroll()
	--check if current focus is completely onscreen
	if inrange(toconvertmappackselection, 1+toconvertmappackscroll, 3+toconvertmappackscroll, true) == false then
		if toconvertmappackselection < 1+toconvertmappackscroll then --above window
			toconvertmappackscroll = toconvertmappackselection-1
		else
			toconvertmappackscroll = toconvertmappackselection-3.233
		end
	end
end

function mappacks()
	if mappackhorscroll == 0 then
		loadmappacks()
	elseif mappackhorscroll == 1 then
		loadonlinemappacks()
	elseif mappackhorscroll == 2 then
		loadtoconvertmappacks()
	end
end

function loadmappacks()
	mappacktype = "local"
	mappacklist = love.filesystem.getDirectoryItems( "mappacks" )

	local delete = {}
	for i = 1, #mappacklist do
		if love.filesystem.getInfo( "mappacks/" .. mappacklist[i] .. "/version.txt") or not love.filesystem.getInfo( "mappacks/" .. mappacklist[i] .. "/settings.txt") then
			table.insert(delete, i)
		end
	end

	table.sort(delete, function(a,b) return a>b end)

	for i, v in pairs(delete) do
		table.remove(mappacklist, v) --remove
	end

	mappackicon = {}

	--get info
	mappackname = {}
	mappackauthor = {}
	mappackdescription = {}
	mappackbackground = {}

	for i = 1, #mappacklist do
		if love.filesystem.getInfo( "mappacks/" .. mappacklist[i] .. "/icon.png" ) then
			mappackicon[i] = love.graphics.newImage("mappacks/" .. mappacklist[i] .. "/icon.png")
		else
			mappackicon[i] = nil
		end

		mappackauthor[i] = ""
		mappackdescription[i] = ""
		if love.filesystem.getInfo( "mappacks/" .. mappacklist[i] .. "/settings.txt" ) then
			local s = love.filesystem.read( "mappacks/" .. mappacklist[i] .. "/settings.txt" )
			local s1 = s:split("\n")
			for j = 1, #s1 do
				local s2 = s1[j]:split("=")
				if s2[1] == "name" then
					mappackname[i] = s2[2]
				elseif s2[1] == "author" then
					mappackauthor[i] = s2[2]
				elseif s2[1] == "description" then
					mappackdescription[i] = s2[2]
				end
			end
		else
			mappackname[i] = mappacklist[i]
		end
	end

	table.insert(mappacklist, "custom_mappack")
	table.insert(mappackname, "{new mappack}")
	table.insert(mappackauthor, "you")
	table.insert(mappackdescription, "create a mappack from scratch withthis!")

	--get the current cursorposition
	for i = 1, #mappacklist do
		if mappacklist[i] == mappack then
			mappackselection = i
		end
	end

	mappack = mappacklist[mappackselection]

	--load background
	--loadbackground("1-1.txt")

	mappackscroll = 0
	updatescroll()
	mappackscrollsmooth = mappackscroll
end

function loadonlinemappacks()
	mappacktype = "online"
	downloadmappacks()
	onlinemappacklist = love.filesystem.getDirectoryItems( "mappacks" )

	local delete = {}
	for i = 1, #onlinemappacklist do
		if not love.filesystem.getInfo( "mappacks/" .. onlinemappacklist[i] .. "/version.txt") or not love.filesystem.getInfo( "mappacks/" .. onlinemappacklist[i] .. "/settings.txt") then
			table.insert(delete, i)
		end
	end

	table.sort(delete, function(a,b) return a>b end)

	for i, v in pairs(delete) do
		table.remove(onlinemappacklist, v) --remove
	end

	onlinemappackicon = {}

	--get info
	onlinemappackname = {}
	onlinemappackauthor = {}
	onlinemappackdescription = {}
	onlinemappackbackground = {}

	for i = 1, #onlinemappacklist do
		if love.filesystem.getInfo( "mappacks/" .. onlinemappacklist[i] .. "/icon.png" ) then
			onlinemappackicon[i] = love.graphics.newImage("mappacks/" .. onlinemappacklist[i] .. "/icon.png")
		else
			onlinemappackicon[i] = nil
		end

		onlinemappackauthor[i] = nil
		onlinemappackdescription[i] = nil
		if love.filesystem.getInfo( "mappacks/" .. onlinemappacklist[i] .. "/settings.txt" ) then
			local s = love.filesystem.read( "mappacks/" .. onlinemappacklist[i] .. "/settings.txt" )
			local s1 = s:split("\n")
			for j = 1, #s1 do
				local s2 = s1[j]:split("=")
				if s2[1] == "name" then
					onlinemappackname[i] = s2[2]
				elseif s2[1] == "author" then
					onlinemappackauthor[i] = s2[2]
				elseif s2[1] == "description" then
					onlinemappackdescription[i] = s2[2]
				end
			end
		else
			onlinemappackname[i] = onlinemappacklist[i]
		end
	end

	--get the current cursorposition
	for i = 1, #onlinemappacklist do
		if onlinemappacklist[i] == mappack then
			onlinemappackselection = i
		end
	end

	if #onlinemappacklist >= 1 then
		mappack = onlinemappacklist[onlinemappackselection]
	end

	--load background
	--loadbackground("1-1.txt")

	onlinemappackscroll = 0
	onlineupdatescroll()
	onlinemappackscrollsmooth = onlinemappackscroll
end

function loadtoconvertmappacks()
	mappacktype = "toconvert"
	toconvertmappacklist = love.filesystem.getDirectoryItems( "toconvert" )

	local delete = {}
	for i, v in pairs(toconvertmappacklist) do
		if tablecontains(mappacklist, v) then
			table.insert(delete, 1, i)
		end
	end

	for _, v in pairs(delete) do
		table.remove(toconvertmappacklist, v)
	end

	toconvertmappackicon = {}

	--get info
	toconvertmappackname = {}
	toconvertmappackauthor = {}
	toconvertmappackdescription = {}
	toconvertmappackbackground = {}

	for i = 1, #toconvertmappacklist do
		if love.filesystem.getInfo( "toconvert/" .. toconvertmappacklist[i] .. "/icon.png" ) then
			toconvertmappackicon[i] = love.graphics.newImage("toconvert/" .. toconvertmappacklist[i] .. "/icon.png")
		else
			toconvertmappackicon[i] = nil
		end

		toconvertmappackauthor[i] = ""
		toconvertmappackdescription[i] = ""
		if love.filesystem.getInfo( "toconvert/" .. toconvertmappacklist[i] .. "/settings.txt" ) then
			local s = love.filesystem.read( "toconvert/" .. toconvertmappacklist[i] .. "/settings.txt" )
			local s1 = s:split("\n")
			for j = 1, #s1 do
				local s2 = s1[j]:split("=")
				if s2[1] == "name" then
					toconvertmappackname[i] = s2[2]
				elseif s2[1] == "author" then
					toconvertmappackauthor[i] = s2[2]
				elseif s2[1] == "description" then
					toconvertmappackdescription[i] = s2[2]
				end
			end
		else
			toconvertmappackname[i] = toconvertmappacklist[i]
		end
	end

	--mappack = mappacklist[mappackselection]

	--load background
	--loadbackground("1-1.txt")

	toconvertmappackscroll = 0
	toconvertupdatescroll()
	toconvertmappackscrollsmooth = toconvertmappackscroll
end

function downloadmappacks()
	downloaderror = false
	local onlinedata, code = http.request("http://server.stabyourself.net/mari0/index2.php?mode=mappacks")

	if code ~= 200 then
		downloaderror = true
		return false
	elseif not onlinedata then
		downloaderror = true
		return false
	end

	local maplist = {}
	local versionlist = {}
	local latestversion = marioversion

	local split1 = onlinedata:split("<")
	for i = 2, #split1 do
		local split2 = split1[i]:split(">")
		if split2[1] == "latestversion" then
			latestversion = tonumber(split2[2])
		elseif split2[1] == "mapfile" then
			table.insert(maplist, split2[2])
		elseif split2[1] == "version" then
			table.insert(versionlist, tonumber(split2[2]))
		end
	end

	if latestversion > marioversion then
		outdated = true
		return false
	end

	success = true

	--download all mappacks
	for i = 1, #maplist do
		--check if current version is equal or newer
		local version = 0
		if love.filesystem.getInfo("mappacks/" .. maplist[i] .. "/version.txt") then
			local data = love.filesystem.read("mappacks/" .. maplist[i] .. "/version.txt")
			if data then
				version = tonumber(data)
			end
		end

		if version < versionlist[i] then
			print("DOWNLOADING MAPPACK: " .. maplist[i])

			--draw
			currentdownload = i
			downloadcount = #maplist

			if love.filesystem.getInfo("mappacks/" .. maplist[i] .. "/") then
				love.filesystem.remove("mappacks/" .. maplist[i] .. "/")
			end

			love.filesystem.createDirectory("mappacks/" .. maplist[i])
			local onlinedata, code = http.request("http://server.stabyourself.net/mari0/index2.php?mode=getmap&get=" .. maplist[i])

			if code == 200 then
				filecount = 0
				local checksums = {}

				local split1 = onlinedata:split("<")
				for j = 2, #split1 do
					local split2 = split1[j]:split(">")
					if split2[1] == "asset" then
						filecount = filecount + 1
					elseif split2[1] == "checksum" then
						table.insert(checksums, split2[2])
					end
				end

				currentfiledownload = 1

				local split1 = onlinedata:split("<")
				for j = 2, #split1 do
					local split2 = split1[j]:split(">")
					if split2[1] == "asset" then
						loadingonlinemappacks = true
						love.graphics.clear()
						love.draw()
						love.graphics.present()
						loadingonlinemappacks = false

						local target = "mappacks/" .. maplist[i] .. "/" .. split2[2]:match("([^/]-)$")

						local tries = 0
						success = false
						while not success and tries < 3 do
							success = downloadfile(split2[2], target, checksums[currentfiledownload])
							tries = tries + 1
						end

						if not success then
							break
						end
						currentfiledownload = currentfiledownload + 1
					end
				end
				if success then
					love.filesystem.write( "mappacks/" .. maplist[i] .. "/version.txt", versionlist[i])
				end
			else
				success = false
			end
		end

		--Delete stuff and stuff.
		if not success then
			if love.filesystem.getInfo("mappacks/" .. maplist[i] .. "/") then
				local list = love.filesystem.getDirectoryItems("mappacks/" .. maplist[i] .. "/")
				for j = 1, #list do
					love.filesystem.remove("mappacks/" .. maplist[i] .. "/" .. list[j])
				end

				love.filesystem.remove("mappacks/" .. maplist[i] .. "/")
			end
			downloaderror = true
			break
		else
			print("Download successful.")
		end
	end

	return true
end

function menu_keypressed(key)
	if gamestate == "menu" then --PLEASE don't use this menu system as an example. It's fucking awful. But you knew that.
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
	elseif gamestate == "mappackmenu" then
		if (key == "up" or key == "w") then
			if mappacktype == "local" then
				if mappackselection > 1 then
					mappackselection = mappackselection - 1
					mappack = mappacklist[mappackselection]

					updatescroll()
				end
			elseif mappacktype == "online" then
				if onlinemappackselection > 1 then
					onlinemappackselection = onlinemappackselection - 1
					mappack = onlinemappacklist[onlinemappackselection]

					onlineupdatescroll()
				end
			elseif mappacktype == "toconvert" then
				if toconvertmappackselection > 1 then
					toconvertmappackselection = toconvertmappackselection - 1
					--mappack = onlinemappacklist[onlinemappackselection]

					toconvertupdatescroll()
				end
			end
		elseif (key == "down" or key == "s") then
			if mappacktype == "local" then
				if mappackselection < #mappacklist then
					mappackselection = mappackselection + 1
					mappack = mappacklist[mappackselection]

					updatescroll()
				end
			elseif mappacktype == "online" then
				if onlinemappackselection < #onlinemappacklist then
					onlinemappackselection = onlinemappackselection + 1
					mappack = onlinemappacklist[onlinemappackselection]

					onlineupdatescroll()
				end
			elseif mappacktype == "toconvert" then
				if toconvertmappackselection < #toconvertmappacklist then
					toconvertmappackselection = toconvertmappackselection + 1
					--mappack = onlinemappacklist[onlinemappackselection]

					toconvertupdatescroll()
				end
			end
		elseif key == "escape" or (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
			if mappacktype == "toconvert" then
				local toconvert = toconvertmappacklist[toconvertmappackselection]
				convertmappack(toconvert)
				mappack = toconvert
				gamestate = "menu"
				saveconfig()
				loadbackgroundsafe("1-1.txt")
			else
				gamestate = "menu"
				saveconfig()
				if mappack == "custom_mappack" then
					createmappack()
				end

				--load background
				loadbackgroundsafe("1-1.txt")
			end
		elseif (key == "right" or key == "d") then
			if mappackhorscroll == 0 then
				loadonlinemappacks()
				mappackhorscroll = 1
			elseif mappackhorscroll == 1 then
				loadtoconvertmappacks()
				mappackhorscroll = 2
			end
		elseif (key == "left" or key == "a") then
			if mappackhorscroll == 1 then
				loadmappacks()
				mappackhorscroll = 0
			elseif mappackhorscroll == 2 then
				loadonlinemappacks()
				mappackhorscroll = 1
			end
		elseif key == "m" then
			if not openSaveFolder("mappacks") then
				savefolderfailed = true
			end
		end
	elseif gamestate == "onlinemenu" then
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
	elseif gamestate == "options" then
		if optionsselection == 1 then
			if (key == "left" or key == "a") then
				if optionstab > 1 then
					optionstab = optionstab - 1
				end
			elseif (key == "right" or key == "d") then
				if optionstab < 4 then
					optionstab = optionstab + 1
				end
			end
		elseif optionsselection == 2 then
			if (key == "left" or key == "a") then
				if optionstab == 2 or optionstab == 1 then
					if skinningplayer > 1 then
						skinningplayer = skinningplayer - 1
					end
				end
			elseif (key == "right" or key == "d") then
				if optionstab == 2 or optionstab == 1 then
					if skinningplayer < 4 then
						skinningplayer = skinningplayer + 1
						if players > #controls then
							loadconfig()
						end
					end
				end
			end
		end

		if (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
			if optionstab == 1 then
				if optionsselection == 3 then
					if mouseowner == skinningplayer then
						mouseowner = 0
					else
						mouseowner = skinningplayer
					end
				elseif optionsselection > 3 then
					keypromptstart()
				end
			elseif optionstab == 3 then
				if optionsselection == 7 then
					reset_mappacks()
				elseif optionsselection == 8 then
					resetconfig()
				end
			end
		elseif (key == "down" or key == "s") then
			if optionstab == 1 then
				if skinningplayer ~= mouseowner then
					if optionsselection < 15 then
						optionsselection = optionsselection + 1
					else
						optionsselection = 1
					end
				else
					if optionsselection < 11 then
						optionsselection = optionsselection + 1
					else
						optionsselection = 1
					end
				end
			elseif optionstab == 2 then
				local limit = 5
				if characters[mariocharacter[skinningplayer]].colorables then
					limit = 10
				end

				if optionsselection < limit then
					optionsselection = optionsselection + 1
				else
					optionsselection = 1
				end
			elseif optionstab == 3 then
				if optionsselection < 9 then
					optionsselection = optionsselection + 1
				else
					optionsselection = 1
				end
			elseif optionstab == 4 and gamefinished then
				if optionsselection < 10 then
					optionsselection = optionsselection + 1
				else
					optionsselection = 1
				end
			end
		elseif (key == "up" or key == "w") then
			if optionsselection > 1 then
				optionsselection = optionsselection - 1
			else
				if optionstab == 1 then
					if skinningplayer ~= mouseowner then
						optionsselection = 15
					else
						optionsselection = 11
					end
				elseif optionstab == 2 then
					local limit = 5
					if characters[mariocharacter[skinningplayer]].colorables then
						limit = 10
					end
					optionsselection = limit
				elseif optionstab == 3 then
					optionsselection = 9
				elseif optionstab == 4 and gamefinished then
					optionsselection = 10
				end
			end
		elseif (key == "right" or key == "d") then
			if optionstab == 2 then
				if optionsselection == 3 then
					nextcharacter()
				elseif characters[mariocharacter[skinningplayer]].colorables and optionsselection == 4 then
					if mariohats[skinningplayer][1] < #hat then
						mariohats[skinningplayer][1] = mariohats[skinningplayer][1] + 1
					end
				elseif characters[mariocharacter[skinningplayer]].colorables and optionsselection == 5 then
					--next color set
					colorsetedit = colorsetedit + 1
					if colorsetedit > #characters[mariocharacter[skinningplayer]].colorables then
						colorsetedit = 1
					end
				end
			elseif optionstab == 3 then
				if optionsselection == 2 then
					if scale < 5 then
						changescale(scale+1)
					end
				elseif optionsselection == 3 then
					currentshaderi1 = currentshaderi1 + 1
					if currentshaderi1 > #shaderlist then
						currentshaderi1 = 1
					end
					if shaderlist[currentshaderi1] == "none" then
						shaders:set(1, nil)
					else
						shaders:set(1, shaderlist[currentshaderi1])
					end

				elseif optionsselection == 4 then
					currentshaderi2 = currentshaderi2 + 1
					if currentshaderi2 > #shaderlist then
						currentshaderi2 = 1
					end
					if shaderlist[currentshaderi2] == "none" then
						shaders:set(2, nil)
					else
						shaders:set(2, shaderlist[currentshaderi2])
					end

				elseif optionsselection == 5 then
					volumesfx = math.min(1, volumesfx + 0.1)
					love.audio.setVolume( volumesfx )
					music:setVolume( volumemusic )
					playsound("coin")
					soundenabled = true
				elseif optionsselection == 6 then
					volumemusic = math.min(1, volumemusic + 0.1)
					love.audio.setVolume( volumesfx )
					music:setVolume( volumemusic )
				elseif optionsselection == 9 then
					vsync = not vsync
					changescale(scale)
				end
			elseif optionstab == 4 then
				if optionsselection == 2 then
					playertypei = playertypei + 1
					if playertypei > #playertypelist then
						playertypei = 1
					end
					playertype = playertypelist[playertypei]
					if playertype == "gelcannon" then
						sonicrainboom = false
					end
				elseif optionsselection == 3 then
					portalknockback = not portalknockback
				elseif optionsselection == 4 then
					bullettime = not bullettime
				elseif optionsselection == 5 then
					bigmario = not bigmario
				elseif optionsselection == 6 then
					goombaattack = not goombaattack
				elseif optionsselection == 7 then
					sonicrainboom = not sonicrainboom
					playertype = "portal"
					playertypei = 1
				elseif optionsselection == 8 then
					playercollisions = not playercollisions
				elseif optionsselection == 9 then
					infinitetime = not infinitetime
				elseif optionsselection == 10 then
					infinitelives = not infinitelives
				end
			end
		elseif (key == "left" or key == "a") then
			if optionstab == 2 then
				if optionsselection == 3 then
					previouscharacter()
				elseif characters[mariocharacter[skinningplayer]].colorables and optionsselection == 4 then
					if mariohats[skinningplayer][1] > 0 then
						mariohats[skinningplayer][1] = mariohats[skinningplayer][1] - 1
					end
				elseif characters[mariocharacter[skinningplayer]].colorables and optionsselection == 5 then
					--previous color set
					colorsetedit = colorsetedit - 1
					if colorsetedit < 1 then
						colorsetedit = #characters[mariocharacter[skinningplayer]].colorables
					end
				end
			elseif optionstab == 3 then
				if optionsselection == 2 then
					if scale > 1 then
						changescale(scale-1)
					end
				elseif optionsselection == 3 then
					currentshaderi1 = currentshaderi1 - 1
					if currentshaderi1 < 1 then
						currentshaderi1 = #shaderlist
					end

					if shaderlist[currentshaderi1] == "none" then
						shaders:set(1, nil)
					else
						shaders:set(1, shaderlist[currentshaderi1])
					end
				elseif optionsselection == 4 then
					currentshaderi2 = currentshaderi2 - 1
					if currentshaderi2 < 1 then
						currentshaderi2 = #shaderlist
					end

					if shaderlist[currentshaderi2] == "none" then
						shaders:set(2, nil)
					else
						shaders:set(2, shaderlist[currentshaderi2])
					end

				elseif optionsselection == 5 then
					volumesfx = math.max(0, volumesfx - 0.1)
					if volume == 0 then
						soundenabled = false
					end
					love.audio.setVolume( volumesfx )
					music:setVolume( volumemusic )
					playsound("coin")
				elseif optionsselection == 6 then
					volumemusic = math.max(0, volumemusic - 0.1)
					love.audio.setVolume( volumesfx )
					music:setVolume( volumemusic )
				elseif optionsselection == 9 then
					vsync = not vsync
					changescale(scale)
				end
			elseif optionstab == 4 then
				if optionsselection == 2 then
					playertypei = playertypei - 1
					if playertypei < 1 then
						playertypei = #playertypelist
					end
					playertype = playertypelist[playertypei]
					if playertype == "gelcannon" then
						sonicrainboom = false
					end
				elseif optionsselection == 3 then
					portalknockback = not portalknockback
				elseif optionsselection == 4 then
					bullettime = not bullettime
				elseif optionsselection == 5 then
					bigmario = not bigmario
				elseif optionsselection == 6 then
					goombaattack = not goombaattack
				elseif optionsselection == 7 then
					sonicrainboom = not sonicrainboom
					playertype = "portal"
					playertypei = 1
				elseif optionsselection == 8 then
					playercollisions = not playercollisions
				elseif optionsselection == 9 then
					infinitetime = not infinitetime
				elseif optionsselection == 10 then
					infinitelives = not infinitelives
				end
			end
		elseif key == "escape" then
			gamestate = "menu"
			saveconfig()
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

function downloadfile(url, target, checksum)
	local data, code = http.request(url)

	if code ~= 200 then
		return false
	end

	if checksum ~= sha1(data) then
		print("Checksum doesn't match!")
		return false
	end

	if data then
		love.filesystem.write(target, data)
		return true
	else
		return false
	end
end

function reset_mappacks()
	delete_mappack("smb")
	delete_mappack("portal")

	loadbackgroundsafe("1-1.txt")

	playsound("oneup")
end

function delete_mappack(pack)
	if not love.filesystem.getInfo("mappacks/" .. pack .. "/") then
		return false
	end

	local list = love.filesystem.getDirectoryItems("mappacks/" .. pack .. "/")
	for i = 1, #list do
		love.filesystem.remove("mappacks/" .. pack .. "/" .. list[i])
	end

	love.filesystem.remove("mappacks/" .. pack .. "/")
end

function createmappack()
	local i = 1
	while love.filesystem.getInfo("mappacks/custom_mappack_" .. i .. "/") do
		i = i + 1
	end

	mappack = "custom_mappack_" .. i

	love.filesystem.createDirectory("mappacks/" .. mappack .. "/")

	local s = ""
	s = s .. "name=new mappack" .. "\n"
	s = s .. "author=you" .. "\n"
	s = s .. "description=the newest best  mappack?" .. "\n"

	love.filesystem.write("mappacks/" .. mappack .. "/settings.txt", s)

	--Create folders for all sorts of stuff.
	local folderlist = {"animated", "animations", "backgrounds", "enemies", "graphics", "levelscreens", "music", "sounds"}

	for i, v in pairs(folderlist) do
		love.filesystem.createDirectory("mappacks/" .. mappack .. "/" .. v .. "/")
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

function previouscharacter()
	--get current character
	local char
	for i = 1, #characterlist do
		if characterlist[i] == mariocharacter[skinningplayer] then
			char = i
			break
		end
	end

	if not char then return end

	if char > 1 then
		changecharacter(char - 1)
	else
		changecharacter(#characterlist)
	end
end

function nextcharacter()
	--get current character
	local char
	for i = 1, #characterlist do
		if characterlist[i] == mariocharacter[skinningplayer] then
			char = i
			break
		end
	end

	if not char then return end

	if char < #characterlist then
		changecharacter(char + 1)
	else
		changecharacter(1)
	end
end

function changecharacter(i)
	mariocharacter[skinningplayer] = characterlist[i]

	--change colors
	mariocolors[skinningplayer] = {}
	if characters[characterlist[i]].defaultcolors then
		if characters[characterlist[i]].defaultcolors[skinningplayer] then
			for j = 1, #characters[characterlist[i]].defaultcolors[skinningplayer] do
				mariocolors[skinningplayer][j] = {characters[characterlist[i]].defaultcolors[skinningplayer][j][1], characters[characterlist[i]].defaultcolors[skinningplayer][j][2], characters[characterlist[i]].defaultcolors[skinningplayer][j][3]}
			end
		end
	end

	if characters[characterlist[i]].defaulthat then
		mariohats[skinningplayer] = { characters[characterlist[i]].defaulthat}
	end

	colorsetedit = 1
end

function convertmappack(name)
	local oldmappackpath = "toconvert/" .. name .. "/"
	local newmappackpath = "mappacks/" .. name .. "/"
	mappack = name

	local cw = 1
	local cl = 1
	local cs = 0

	mapheight = 15

	love.filesystem.createDirectory(newmappackpath)
	for i, v in pairs({"animated/", "animations/", "backgrounds/", "enemies/", "graphics/", "levelscreens/", "music/"}) do
		love.filesystem.createDirectory(newmappackpath .. v)
	end

	local function cpy(from, to)
		local parentTo = to:split("/")
		table.remove(parentTo, #parentTo)
		local parent = table.concat(parentTo, "/")
		if parent ~= "" and not love.filesystem.getInfo(parent, "directory") then
			love.filesystem.createDirectory(parent)
		end
		if love.filesystem.getInfo(from, "file") then
			love.filesystem.write(to, love.filesystem.read(from))
			return true
		end
		return false
	end

	cpy(oldmappackpath .. "settings.txt", newmappackpath .. "settings.txt")
	cpy(oldmappackpath .. "icon.png", newmappackpath .. "icon.png")
	local custommusicname = ""
	for _, ext in pairs({"mp3", "ogg"}) do
		if cpy(oldmappackpath .. "music." .. ext, newmappackpath .. "music/custom." .. ext) then
			custommusicname = "custom." .. ext
		end
	end

	-- copy "default" bg
	local defbg = false
	local bgi = 1
	while love.filesystem.getInfo(oldmappackpath .. "background" .. bgi .. ".png", "file") do
		cpy(oldmappackpath .. "background" .. bgi .. ".png", newmappackpath .. "backgrounds/default" .. bgi .. ".png")
		bgi = bgi + 1
		defbg = true
	end

	local customstart = smbtilecount + portaltilecount + 1
	for i = customstart, #tilequads do
		tilequads[i] = nil
		rgblist[i] = nil
	end
	if cpy(oldmappackpath .. "tiles.png", newmappackpath .. "tiles.png") then
		customtiles = true
		customtilesimg = love.graphics.newImage(newmappackpath .. "tiles.png")
		local imgwidth, imgheight = customtilesimg:getWidth(), customtilesimg:getHeight()
		local width = math.floor(imgwidth/17)
		local height = math.floor(imgheight/17)
		local imgdata = love.image.newImageData(newmappackpath .. "tiles.png")

		for y = 1, height do
			for x = 1, width do
				table.insert(tilequads, quad:new(customtilesimg, imgdata, x, y, imgwidth, imgheight))
				local r, g, b = getaveragecolor(imgdata, x, y)
				table.insert(rgblist, {r / COLORSPACE, g / COLORSPACE, b / COLORSPACE})
			end
		end
		customtilecount = width*height
		customspritebatch = love.graphics.newSpriteBatch( customtilesimg, 10000 )
		customspritebatchfront = love.graphics.newSpriteBatch( customtilesimg, 10000 )
	else
		customtiles = false
		customtilesimg = nil
	end

	for i, v in pairs(love.filesystem.getDirectoryItems(oldmappackpath)) do
		if v:find("^%d+%-%d+.txt$") or v:find("^%d+%-%d+_%d+.txt$") then -- file is in format world-level.txt or world-level_sub.txt
			if loadmapold(oldmappackpath .. v) then
				bgi = 1
				while love.filesystem.getInfo(oldmappackpath .. v:sub(1, -5) .. "background" .. bgi .. ".png", "file") do
					cpy(oldmappackpath .. v:sub(1, -5) .. "background" .. bgi .. ".png", newmappackpath .. "backgrounds/" .. v:sub(1, -5) .. bgi .. ".png")
					if custombackground == true then
						custombackground = v:sub(1, -5)
					end
					bgi = bgi + 1
				end
				if custombackground == true and defbg then
					custombackground = "default"
				end
				if musicname == "custom.ext" then
					musicname = custommusicname
				end
				savemap(v:sub(1, -5), true)
			end
		end
	end

	notice.new("mappack converted successfully")
end

function loadmapold(path)
	if love.filesystem.getInfo(path, "file") then
		-- start to fill important info
		map = {}
		coinmap = {}
		mariotimelimit = 400
		background = backgroundcolor[1]
		musicname = "overworld.ogg"
		spriteset = 1
		custombackground = false
		customforeground = false
		intermission = false
		bonusstage = false
		haswarpzone = false
		underwater = false
		scrollfactor = 0
		fscrollfactor = 0
		portalsavailable = {true, true}
		levelscreenbackname = false
		mapwidth = 25

		local data = love.filesystem.read(path):split(";")
		for i, v in pairs(data) do
			local spl = v:split("=")
			if spl[1] == "timelimit" then
				mariotimelimit = tonumber(spl[2])
			elseif spl[1] == "background" then
				background = backgroundcolor[tonumber(spl[2])]
			elseif spl[1] == "music" then
				local musici = tonumber(spl[2])
				if musici == 7 then
					musicname = "custom.ext"
				else
					musicname = musiclist[tonumber(spl[2])]
				end
			elseif spl[1] == "spriteset" then
				spriteset = tonumber(spl[2])
			elseif spl[1] == "scrollfactor" then
				scrollfactor = tonumber(spl[2])
			elseif v == "portalbackground" or v == "custombackground" then
				custombackground = true -- todo, make it so curr background is saved
			elseif v == "intermission" then
				intermission = true
			elseif v == "bonusstage" then
				bonusstage = true
			elseif v == "haswarpzone" then
				haswarpzone = true
			elseif v == "underwater" then
				underwater = true
			elseif i == 1 then
				local mapsplit = v:split(",")
				if #mapsplit%15 ~= 0 then
					print("Level isn't 15 tiles tall!!!")
					return false
				end
				mapwidth = math.floor(#mapsplit/15)
				local x = 0
				local y = 1
				for j, w in pairs(mapsplit) do
					local spl2 = w:split("-")
					x = x + 1
					if x == mapwidth + 1 then
						x = 1
						y = y + 1
					end
					if not map[x] then
						map[x] = {}
						coinmap[x] = {}
					end

					local tileid = tonumber(spl2[1])
					local entity = {}
					if #spl2 >= 2 then
						for subent = 2, #spl2 do
							table.insert(entity, tonumber(spl2[subent]) or spl2[subent])
						end
					end
					entity = convertentity(entity)

					local shouldbecoin = false
					if tilequads[tileid] and tilequads[tileid]:getproperty("coin") then
						shouldbecoin = true
						tileid = 1
					end

					map[x][y] = {tileid}
					for subent = 1, #entity do
						table.insert(map[x][y], entity[subent])
					end
					coinmap[x][y] = shouldbecoin
				end
			end
		end
		return true
	end
end

-- Converts an entity from the 1.6 system to the CE one
-- Most cases, was enemy or multiple entities merged into one
function convertentity(entity)
	local newent = {}
	if #entity >= 1 then
		local entid = entity[1] -- will never be 1 since it's no entity (and this doesn't get saved)

		if entid == 3 then -- 1up
			newent = {"oneup"}
		elseif entid == 4 then -- star
			newent = {"star"}
		elseif entid == 6 then -- goomba
			newent = {"goomba"}
		elseif entid == 7 then -- koopa
			newent = {"koopa"}
		elseif entid == 8 then -- mario spawn
			newent = {8, "true", "false", "false", "false", "false"}
		elseif entid == 9 then -- goomba half
			newent = {"goombahalf"}
		elseif entid == 10 then -- koopa half
			newent = {"koopahalf"}
		elseif entid == 12 then -- koopa red
			newent = {"koopared"}
		elseif entid == 13 then -- koopa red half
			newent = {"kooparedhalf"}
		elseif entid == 15 then -- hammerbros
			newent = {"hammerbros"}
		elseif entid == 16 or entid == 17 then -- cheepcheep
			newent = {3}
		elseif entid == 18 or entid == 19 then -- platforms
			newent = {18, entity[2], entid == 18 and 0 or 3.31, entid == 19 and 0 or 3.31, 4}
		elseif entid == 14 or entid == 21 or entid == 31 then -- pipe enter/exit / vine
			newent = {entid, entity[2]+1}
		elseif entid == 22 then -- lakitu
			newent = {"lakito"}
		elseif entid == 26 or entid == 27 then -- emance grid
			newent = {26, entid == 26 and "hor" or "ver", "false"}
		elseif entid == 28 or entid == 29 then -- door
			newent = {28, entid == 29 and "hor" or "ver", "false", "false"}
		elseif entid >= 36 and entid <= 39 then -- light bridges
			local dirs = {"right", "left", "down", "up"}
			newent = {36, dirs[entid - 35], tostring(tablecontains(entity, "link"))}
		elseif entid == 41 or entid == 42 then -- infinite platforms
			newent = {41, entid == 41 and "down" or "up", entity[2], 3.5, 2.18}
		elseif entid >= 49 and entid <= 51 then -- faithplate
			local speeds = {{0, 40}, {30, 30}, {-30, 30}}
			newent = {49, speeds[entid - 48][1], speeds[entid - 48][2], "false"}
		elseif entid >= 52 and entid <= 55 then -- laser
			local dirs = {"right", "down", "left", "up"}
			newent = {52, dirs[entid - 51], tostring(tablecontains(entity, "link"))}
		elseif entid >= 56 and entid <= 59 then -- laser detector
			local dirs = {"right", "down", "left", "up"}
			newent = {56, dirs[entid - 55], "false"}
		elseif (entid >= 61 and entid <= 66) or (entid >= 71 and entid <= 73) then -- gel dispensers
			local dirs = {"down", "right", "left"}
			local dirid = (entid < 71 and ((entid - 61)%3)+1) or entid - 70
			local gelid = (entid < 64 and 1) or (entid < 71 and 2) or 3
			newent = {61, dirs[dirid], gelid, "false"}
		elseif entid == 68 or entid == 69 then -- push button
			newent = {68, entid == 68 and "left" or "right", "down"}
		elseif entid == 70 then -- plant
			newent = {"plant"}
		elseif entid == 75 then -- beetle
			newent = {"beetle"}
		elseif entid == 76 then -- beetle half
			newent = {"beetlehalf"}
		elseif entid == 77 then -- parakoopa red
			newent = {"kooparedflying"}
		elseif entid == 78 then -- parakoopa
			newent = {"koopaflying"}
		elseif entid == 79 or entid == 82 then -- fire sticks
			newent = {79, 6, 0.11, tostring(entid == 79)}
		elseif entid == 80 then -- seesaw
			-- line below copied from 1.6 src
			local seesaws = {{7,4,6,3}, {4,2,6,3}, {7,3,6,3}, {8,3,7,3}, {5,3,7,3}, {6,3,7,3}, {4,3,7,1.5}, {3,3,7,1.5}, {3,4,7,1.5}}
			local seesawtype = seesaws[entity[2]]
			newent = {80, seesawtype[1], seesawtype[2], seesawtype[3], seesawtype[4]}
		elseif entid == 84 then -- not gate
			newent = {84, "true"}
		elseif entid >= 85 and entid <= 88 then -- gels
			newent = {85, entity[2], entid == 86, entid == 85, entid == 88, entid == 87}
		elseif entid == 94 then -- squid
			newent = {"squid"}
		elseif entid == 97 then -- upfire
			newent = {"upfire"}
		elseif entid == 98 then -- spiney
			newent = {"spikey"}
		elseif entid == 99 then -- spiney half
			newent = {"spikeyhalf"}
		elseif entid == 100 then -- checkpoint
			newent = {100, "true", "false", "false", "false", "false", "false", "false", "region:0:m15:1:30"}
		else -- every other entity
			local i = 1
			while entity[i] ~= "link" and i <= #entity do
				newent[i] = entity[i]
				i = i + 1
			end
		end

		local linkcount = 0
		if newent[1] and entitylist[newent[1]] then
			local rcmenu = rightclickmenues[entitylist[newent[1]].t]
			if rcmenu then
				for i = 1, #entity do
					if entity[i] == "link" then
						local linktype = ""
						local toskip = linkcount
						for j, v in pairs(rcmenu) do
							if v.t == "linkbutton" then
								if toskip == 0 then
									linktype = v.link
								else
									toskip = toskip - 1
								end
							end
						end
						table.insert(newent, "link")
						table.insert(newent, linktype)
						table.insert(newent, entity[i+1])
						table.insert(newent, entity[i+2])
						linkcount = linkcount + 1
					end
				end
			end
		end
	end

	return newent
end