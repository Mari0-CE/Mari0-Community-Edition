function menu_map_load()
	mappackhorscroll = 0
	mappackhorscrollsmooth = 0
end

function menu_map_1_6_load()
	toconvertmappackselection = 1
end

function menu_map_dlc_load()
	onlinemappackselection = 1
end

function menu_map_update(dt)
	if mappackscroll then
		mappackscrollsmooth, mappackscroll = smooth_scroll(mappackscrollsmooth, mappackscroll, 0.1, dt)
	end
	if mappackhorscroll then
		mappackhorscrollsmooth, mappackhorscroll = smooth_scroll(mappackhorscrollsmooth, mappackhorscroll, 0.03, dt)
	end
end

function menu_map_dlc_update(dt)
	if onlinemappackscroll then
		onlinemappackscrollsmooth, onlinemappackscroll = smooth_scroll(onlinemappackscrollsmooth, onlinemappackscroll, 0.1, dt)
	end
end

function menu_map_1_6_update(dt)
	if toconvertmappackscroll then
		toconvertmappackscrollsmooth, toconvertmappackscroll = smooth_scroll(toconvertmappackscrollsmooth, toconvertmappackscroll, 0.1, dt)
	end
end

function smooth_scroll( scrollsmooth, scroll, speed, dt)
	if scrollsmooth > scroll then
		scrollsmooth = scrollsmooth - (scrollsmooth-scroll)*dt*5-speed*dt
		if scrollsmooth < scroll then
			scrollsmooth = scroll
		end
	elseif scrollsmooth < scroll then
		scrollsmooth = scrollsmooth - (scrollsmooth-scroll)*dt*5+speed*dt
		if scrollsmooth > scroll then
			scrollsmooth = scroll
		end
	end
	return scrollsmooth, scroll
end

function menu_map_draw()
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

function menu_map_keypressed(key)
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
