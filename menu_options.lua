function menu_controls_load()
	controlstable = {"left", "right", "up", "down", "run", "jump", "reload", "use", "aimx", "aimy", "portal1", "portal2"}
end

function menu_skins_load()
	colorsetedit = 1
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
end

function menu_skins_update(dt)
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
end

function menu_options_draw()
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
end

function menu_options_keypressed(key)
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
