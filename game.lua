function game_load(suspended)
	checkpointx = {}
	checkpointy = {}
	checkpointsub = false
	
	scrollfactor = 0
	fscrollfactor = 0
	love.graphics.setBackgroundColor(backgroundcolor[1])

	
	--LINK STUFF
	mariocoincount = 0
	marioscore = 0
	
	--get mariolives
	mariolivecount = 3
	if love.filesystem.getInfo("mappacks/" .. mappack .. "/settings.txt") then
		local s = love.filesystem.read( "mappacks/" .. mappack .. "/settings.txt" )
		local s1 = s:split("\n")
		for j = 1, #s1 do
			local s2 = s1[j]:split("=")
			if s2[1] == "lives" then
				mariolivecount = tonumber(s2[2])
			end
		end
	end
	
	if mariolivecount == 0 then
		mariolivecount = false
	end
	
	mariolives = {}
	for i = 1, players do
		mariolives[i] = mariolivecount
	end
	
	mariosizes = {}
	for i = 1, players do
		mariosizes[i] = 1
	end
	
	autoscroll = true
	autoscrollx = true
	autoscrolly = true
	
	jumpitems = { "mushroom", "oneup" }
	
	marioworld = 1
	mariolevel = 1
	mariosublevel = 0
	respawnsublevel = 0
	
	objects = nil
	if suspended == true then
		continuegame()
	elseif suspended then
		marioworld = suspended
	end
	
	musicname = nil
	
	--FINALLY LOAD THE DAMN LEVEL
	levelscreen_load("initial")
end

function game_update(dt)
	if not objects then return end
	dt = dt * speed
	gdt = dt
	
	--------
	--GAME--
	--------
	
	--animationS
	animationsystem_update(dt)
	
	
	--earthquake reset
	if earthquake > 0 then
		earthquake = math.max(0, earthquake-dt*earthquake*2-0.001)
		sunrot = sunrot + dt
	end
	
	--pausemenu
	if pausemenuopen then
		return
	end
	
	--Animate animated tiles because I say so
	for i = 1, #animatedtiles do
		animatedtiles[i]:update(dt)
	end
	
	for i = 1, #animatedtimerlist do
		animatedtimerlist[i]:update(dt)
	end
	
	--coinanimation
	coinanimation = coinanimation + dt*6.75
	while coinanimation >= 6 do
		coinanimation = coinanimation - 5
	end	
	
	coinframe = math.max(1, math.floor(coinanimation))
	
	--SCROLLING SCORES
	local delete = {}
	
	for i, v in pairs(scrollingscores) do
		if scrollingscores[i]:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(scrollingscores, v) --remove
	end
	
	
	--SCROLLING TEXTS
	local delete = {}
	
	for i, v in pairs(scrollingtexts) do
		if scrollingtexts[i]:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(scrollingtexts, v) --remove
	end
	
	if replaysystem then
		for j = 1, #replaydata do
			if replaydata[j].data then
				replaytimer[j] = replaytimer[j] + dt
				while replaydata[j].data[replayi[j]].time < replaytimer[j] and replayi[j] < #replaydata[j].data do
					replayi[j] = replayi[j] + 1
				end
			end
		end
	end
	
	--If everyone's dead, just update the players and coinblock timer.
	if everyonedead then
		for i, v in pairs(objects["player"]) do
			v:update(dt)
		end
		
		return
	end
	
	--timer	
	if editormode == false then
		--get if any player has their controls disabled
		local notime = false
		for i = 1, players do
			if (objects["player"][i].controlsenabled == false and objects["player"][i].dead == false) then
				notime = true
			end
		end
		
		if notime == false and infinitetime == false and mariotime ~= 0 then
			mariotime = mariotime - 2.5*dt
			
			if mariotime > 0 and mariotime + 2.5*dt >= 99 and mariotime < 99 then
				love.audio.stop()
				playsound("lowtime")
			end
			
			if mariotime > 0 and mariotime + 2.5*dt >= 99-8 and mariotime < 99-8 then
				local star = false
				for i = 1, players do
					if objects["player"][i].starred then
						star = true
					end
				end
				
				if not star then
					playmusic()
				else
					music:play("starmusic.ogg")
				end
			end
			
			if mariotime <= 0 then
				mariotime = 0
				for i, v in pairs(objects["player"]) do
					v:die("time")
				end
			end
		end
	end
	
	--remove userects
	local delete = {}
	for i, v in pairs(userects) do
		if v.delete then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(userects, v)
	end
	
	--Portaldots
	portaldotstimer = portaldotstimer + dt
	while portaldotstimer > portaldotstime do
		portaldotstimer = portaldotstimer - portaldotstime
	end
	
	--portalgundelay
	for i = 1, players do
		if portaldelay[i] > 0 then
			portaldelay[i] = math.max(0, portaldelay[i] - dt/speed)
		end
	end
	
	--check if updates are blocked for whatever reason
	if noupdate then
		for i, v in pairs(objects["player"]) do --But update players anyway.
			v:update(dt)
		end
		return
	end
	
	--blockbounce
	local delete = {}
	
	for i, v in pairs(blockbouncetimer) do
		if blockbouncetimer[i] < blockbouncetime then
			blockbouncetimer[i] = blockbouncetimer[i] + dt
			if blockbouncetimer[i] > blockbouncetime then
				blockbouncetimer[i] = blockbouncetime
				if blockbouncecontent then
					item(blockbouncecontent[i], blockbouncex[i], blockbouncey[i], blockbouncecontent2[i])
				end
				table.insert(delete, i)
			end
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(blockbouncetimer, v)
		table.remove(blockbouncex, v)
		table.remove(blockbouncey, v)
		table.remove(blockbouncecontent, v)
		table.remove(blockbouncecontent2, v)
	end
	
	if #delete >= 1 then
		generatespritebatch()
	end
	
	--coinblocktimer things
	for i, v in pairs(coinblocktimers) do
		if v[3] > 0 then
			v[3] = v[3] - dt
		end
	end
	
	--gelcannon
	if objects["player"][mouseowner] and playertype == "gelcannon" and objects["player"][mouseowner].controlsenabled then
		if gelcannontimer > 0 then
			gelcannontimer = gelcannontimer - dt
			if gelcannontimer < 0 then
				gelcannontimer = 0
			end
		else
			if love.mouse.isDown("l") then
				gelcannontimer = gelcannondelay
				objects["player"][mouseowner]:shootgel(1)
			elseif love.mouse.isDown("r") then
				gelcannontimer = gelcannondelay
				objects["player"][mouseowner]:shootgel(2)
			end
		end
	end
	
	
	--UPDATE STUFFFFF
	
	local updatetable = {	pedestals, emancipationfizzles, emancipateanimations, dialogboxes, rocketlaunchers, emancipationgrills, fireworks, miniblocks, bubbles, platformspawners, seesaws, blockdebristable,
							userects, rainbooms, coinblockanimations, itemanimations}
							
	for i, v in pairs(objects) do
		if i ~= "tile" and i ~= "portalwall" and i ~= "screenboundary" then
			table.insert(updatetable, v)
		end
	end
	
	for i, v in pairs(updatetable) do
		delete = {}
		
		for j, w in pairs(v) do
			if w.update and w:update(dt) then
				table.insert(delete, j)
			elseif w.autodelete then
				if w.y > mapheight+5 or w.x > mapwidth+5 or w.x < -5 or w.y < -5 then
					if w.autodeleted then
						w:autodeleted()
					end
					table.insert(delete,j)
				end
			end
		end
		
		if #delete > 0 then
			table.sort(delete, function(a,b) return a>b end)
			
			for j, w in pairs(delete) do
				table.remove(v, w)
				
			end
		end
	end
	
	
	--PHYSICS
	physicsupdate(dt)
	
	
	--SCROLLING
	--HORIZONTAL
	local oldxscroll = xscroll
	local oldyscroll = yscroll
	
	if autoscroll and minimapdragging == false then
		--scrolling
		local i = 1
		while i <= players and (objects["player"][i].dead or objects["player"][i].remote) do
			i = i + 1
		end
		
		local fastestplayer = objects["player"][i]
		
		-- HORIZONTAL SCROLLING
		if fastestplayer then
			for i = 1, players do
				if not objects["player"][i].dead and not objects["player"][i].remote and objects["player"][i].x > fastestplayer.x then
					fastestplayer = objects["player"][i]
				end
			end
			local speedx = converttostandard(fastestplayer, fastestplayer.speedx, fastestplayer.speedy)
			
			if fastestplayer.dead then -- scrolling fix for online multiplayer if all local players suck. I mean, are dead.
				for i = 1, players do
					if not objects["player"][i].dead and objects["player"][i].x > fastestplayer.x then
						fastestplayer = objects["player"][i]
					end
				end
			end
			
			--LEFT
			if fastestplayer.x < xscroll + scrollingleftstart and xscroll > 0 then
				
				if fastestplayer.x < xscroll + scrollingleftstart and speedx < 0 then
					if speedx < -scrollrate then
						xscroll = xscroll - scrollrate*dt
					else
						xscroll = xscroll + speedx*dt
					end
				end
				
				if fastestplayer.x < xscroll + scrollingleftcomplete then
					if fastestplayer.x > xscroll + scrollingleftcomplete - 1/16 then
						xscroll = xscroll - scrollrate*dt
					else
						xscroll = xscroll - superscrollrate*dt
					end
				end
			end
			
			--RIGHT
			
			if fastestplayer.x > xscroll + width - scrollingstart and xscroll < mapwidth - width then
				if fastestplayer.x > xscroll + width - scrollingstart and speedx > 0.3 then
					if speedx > scrollrate then
						xscroll = xscroll + scrollrate*dt
					else
						xscroll = xscroll + speedx*dt
					end
				end
				
				if fastestplayer.x > xscroll + width - scrollingcomplete then
					if fastestplayer.x > xscroll + width - scrollingcomplete then
						xscroll = xscroll + scrollrate*dt
						if xscroll > fastestplayer.x - (width - scrollingcomplete) then
							xscroll = fastestplayer.x - (width - scrollingcomplete)
						end
					else
						xscroll = fastestplayer.x - (width - scrollingcomplete)
					end
				end
			end
			
			--just force that shit
			if not levelfinished then
				if fastestplayer.x > xscroll + width - scrollingcomplete then
					xscroll = xscroll + superscroll*dt
					if fastestplayer.x < xscroll + width - scrollingcomplete then
						xscroll = fastestplayer.x - width + scrollingcomplete
					end
					--xscroll = fastestplayer.x + width - scrollingcomplete - width
				end
			end
			
			if xscroll > mapwidth-width then
				xscroll = math.max(0, mapwidth-width)
				hitrightside()
			end
				
			if xscroll < 0 then
				xscroll = 0
			end
				
			if (axex and xscroll > axex-width and axex >= width) then
				xscroll = axex-width
				hitrightside()
			end
		end
	
		--VERTICAL SCROLLING
		for i = 1, players do
			local v = objects["player"][i]
			local old = ylookmodifier
			if downkey(i) then
				if v.looktimer < userscrolltime then
					v.looktimer = v.looktimer + dt
				else
					if ylookmodifier < math.min(userscrollrange, mapheight-(height+yscroll)) then
						ylookmodifier = ylookmodifier + dt*userscrollspeed
						if ylookmodifier > math.min(userscrollrange, mapheight-(height+yscroll)) then
							ylookmodifier = math.min(userscrollrange, mapheight-(height+yscroll))
						end
					end
				end
			elseif upkey(i) then
				if v.looktimer < userscrolltime then
					v.looktimer = v.looktimer + dt
				else
					if ylookmodifier > -math.min(userscrollrange, yscroll) then
						ylookmodifier = ylookmodifier - dt*userscrollspeed
						if ylookmodifier < -math.min(userscrollrange, yscroll) then
							ylookmodifier = -math.min(userscrollrange, yscroll)
						end
					end
				end
			else
				v.looktimer = 0
				if ylookmodifier > 0 then
					ylookmodifier = math.max(0, ylookmodifier - userscrollspeed*dt)
				elseif ylookmodifier < 0 then
					ylookmodifier = math.min(0, ylookmodifier + userscrollspeed*dt)
				end
			end
			
			yscroll = yscroll + (ylookmodifier-old)
		end
		
		local i = 1
		while i <= players and (objects["player"][i].dead or objects["player"][i].remote) do
			i = i + 1
		end
		local fastestplayer = objects["player"][i]
		if fastestplayer then
			for i = 1, players do
				if not objects["player"][i].dead and not objects["player"][i].remote and objects["player"][i].y > fastestplayer.y then
					fastestplayer = objects["player"][i]
				end
			end
			local dummy, speedy = converttostandard(fastestplayer, fastestplayer.speedx, fastestplayer.speedy)
			if fastestplayer.y-yscroll < upscrollborder then
				local minspeed = (fastestplayer.y-yscroll-upscrollborder)*yscrollingrate
				yscroll = yscroll+math.min(speedy, minspeed)*dt
			elseif fastestplayer.y-yscroll > height-downscrollborder then
				local minspeed = (fastestplayer.y-yscroll - (height-downscrollborder))*yscrollingrate
				yscroll = yscroll+math.max(speedy, minspeed)*dt
			end
		end
			
		if yscroll > mapheight-height-1 then
			yscroll = math.max(0, mapheight-height-1)
		end
		
		if yscroll < 0 then
			yscroll = 0
		end
	end
	
	if not autoscroll or not autoscrollx then
		xscroll = oldxscroll
	end
	
	if not autoscroll or not autoscrolly then
		yscroll = oldyscroll
	end
	
	if firstpersonview then
		xscroll = objects["player"][1].x-width/2+objects["player"][1].width/2
		yscroll = objects["player"][1].y-height/2+objects["player"][1].height/2-.5
	end
	
	if mapwidth > width then
		xscroll = math.min(xscroll, mapwidth-width)
	end
	
	--[[ Code I wrote for testing all levels for crashes.. doesn't properly change the levels anymore..
	for i = 1, 10 do
		mazesolved[i] = true
	end
	xscroll = xscroll + dt*100
	if xscroll >= mapwidth-width then
		while true do
			mariosublevel = mariosublevel + 1
			if mariosublevel > 5 then
				mariosublevel = 0
				mariolevel = mariolevel + 1
				if mariolevel > 4 then
					mariolevel = 1
					marioworld = marioworld + 1
				end
			end
			love.timer.sleep(0.1)
			if mariosublevel == 0 then
				print(marioworld .. "-" .. mariolevel .. ".txt")
				if love.filesystem.exists("mappacks/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. ".txt") then
					startlevel(marioworld .. "-" .. mariolevel)
					break
				end
			else
				print(marioworld .. "-" .. mariolevel .. "_" .. mariosublevel .. ".txt")
				if love.filesystem.exists("mappacks/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. "_" .. mariosublevel .. ".txt") then
					startlevel(marioworld .. "-" .. mariolevel .. "_" .. mariosublevel)
					break
				end
			end
		end
	end
	--]]
	
	
	--camera pan x
	if xpan then
		xpantimer = xpantimer + dt
		if xpantimer >= xpantime then
			xpan = false
			xpantimer = xpantime
		end
		
		local i = xpantimer/xpantime
		
		xscroll = xpanstart + xpandiff*i
	end
	
	--camera pan y
	if ypan then
		ypantimer = ypantimer + dt
		if ypantimer >= ypantime then
			ypan = false
			ypantimer = ypantime
		end
		
		local i = ypantimer/ypantime
		
		yscroll = ypanstart + ypandiff*i
	end
	
	--enemy spawning
	if not editormode then
		if round(xscroll) ~= round(oldxscroll) then
			local xstart, xend
			if xscroll > oldxscroll then
				xstart, xend = round(oldxscroll)+1+math.ceil(width), round(xscroll)+math.ceil(width)
			else
				xstart, xend = round(xscroll), round(oldxscroll)-1
			end
			
			for x = xstart, xend do
				for y = round(yscroll)-1, round(yscroll)+height+1 do
					spawnenemy(x, y)
				end
			end
		end
		
		if round(yscroll) ~= round(oldyscroll) then
			local ystart, yend
			if yscroll > oldyscroll then
				ystart, yend = round(oldyscroll)+1+math.ceil(height), round(yscroll)+math.ceil(height)
			else
				ystart, yend = round(yscroll), round(oldyscroll)-1
			end
			
			for y = ystart, yend do
				for x = round(xscroll)-1, round(xscroll)+width+1 do
					spawnenemy(x, y)
				end
			end
		end
	end
	
	--SPRITEBATCH UPDATE and CASTLEREPEATS
	if math.floor(xscroll) ~= spritebatchX[1] then
		if not editormode then
			for currentx = lastrepeat+1+width, math.floor(xscroll)+1+width do
				reachedx(currentx)
			end
		end
		
		generatespritebatch()
		spritebatchX[1] = math.floor(xscroll)
	elseif math.floor(yscroll) ~= spritebatchY[1] then
		generatespritebatch()
		spritebatchY[1] = math.floor(yscroll)
	end
	
	--portal update
	for i, v in pairs(portals) do
		v:update(dt)
	end
	
	--portal particles
	portalparticletimer = portalparticletimer + dt
	while portalparticletimer > portalparticletime do
		portalparticletimer = portalparticletimer - portalparticletime
		
		for i, v in pairs(portals) do
			if v.facing1 and v.x1 and v.y1 then
				local x1, y1
				
				if v.facing1 == "up" then
					x1 = v.x1 + math.random(1, 30)/16-1
					y1 = v.y1-1
				elseif v.facing1 == "down" then
					x1 = v.x1 + math.random(1, 30)/16-2
					y1 = v.y1
				elseif v.facing1 == "left" then
					x1 = v.x1-1
					y1 = v.y1 + math.random(1, 30)/16-2
				elseif v.facing1 == "right" then
					x1 = v.x1
					y1 = v.y1 + math.random(1, 30)/16-1
				end
				
				table.insert(portalparticles, portalparticle:new(x1, y1, v.portal1color, v.facing1))
			end
			
			if v.facing2 ~= nil and v.x2 and v.y2 then
				local x2, y2
				
				if v.facing2 == "up" then
					x2 = v.x2 + math.random(1, 30)/16-1
					y2 = v.y2-1
				elseif v.facing2 == "down" then
					x2 = v.x2 + math.random(1, 30)/16-2
					y2 = v.y2
				elseif v.facing2 == "left" then
					x2 = v.x2-1
					y2 = v.y2 + math.random(1, 30)/16-2
				elseif v.facing2 == "right" then
					x2 = v.x2
					y2 = v.y2 + math.random(1, 30)/16-1
				end
				
				table.insert(portalparticles, portalparticle:new(x2, y2, v.portal2color, v.facing2))
			end
		end
	end
	
	delete = {}
	
	for i, v in pairs(portalparticles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(portalparticles, v) --remove
	end
	
	--PORTAL PROJECTILES
	delete = {}
	
	for i, v in pairs(portalprojectiles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(portalprojectiles, v) --remove
	end
	
	--FIRE SPAWNING
	if not levelfinished and firestarted and (not objects["bowser"][1] or (objects["bowser"][1].backwards == false and objects["bowser"][1].shot == false and objects["bowser"][1].fall == false)) then
		firetimer = firetimer + dt
		while firetimer > firedelay do
			firetimer = firetimer - firedelay
			firedelay = math.random(4)
			local temp = enemy:new(xscroll + width, math.random(3)+7, "fire")
			table.insert(objects["enemy"], temp)
			
			
			if objects["bowser"][1] then --make bowser fire this
				temp.y = objects["bowser"][1].y+0.25
				temp.x = objects["bowser"][1].x-0.750
				
				--get goal Y
				temp.movement = "targety"
				temp.targetyspeed = 2
				temp.targety = objects["bowser"][1].starty-math.random(3)+2/16
			end
		end
	end
	
	--FLYING FISH
	if not levelfinished and flyingfishstarted then
		flyingfishtimer = flyingfishtimer + dt
		while flyingfishtimer > flyingfishdelay do
			flyingfishtimer = flyingfishtimer - flyingfishdelay
			flyingfishdelay = math.random(6, 20)/10
			
			local x, y = math.random(math.floor(xscroll), math.floor(xscroll)+width), mapheight
			local temp = enemy:new(x, y, "flyingfish")
			table.insert(objects["enemy"], temp)
			
			temp.speedx = objects["player"][1].speedx + math.random(10)-5
			
			if temp.speedx == 0 then
				temp.speedx = 1
			end
			
			if temp.speedx > 0 then
				temp.animationdirection = "left"
			else
				temp.animationdirection = "right"
			end
		end
	end
	
	--BULLET BILL
	if not levelfinished and bulletbillstarted then
		bulletbilltimer = bulletbilltimer + dt
		while bulletbilltimer > bulletbilldelay do
			bulletbilltimer = bulletbilltimer - bulletbilldelay
			bulletbilldelay = math.random(5, 40)/10
			table.insert(objects["enemy"], enemy:new(xscroll+width+2, math.random(4, 12), "bulletbill"))
		end
	end
	
	--Editor
	if editormode then
		editor_update(dt)
	end
	
	--Update pointing angle of players
	for i, v in pairs(objects.player) do
		if not v.disableaiming then
			v:updateangle()
		end
	end
end

function drawlevel()
	if incognito then
		return
	end
	love.graphics.setColor(love.graphics.getBackgroundColor())
	love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
	love.graphics.setColor(1, 1, 1, 1)
	local xtodraw
	if mapwidth < width+1 then
		xtodraw = math.ceil(mapwidth)
	else
		if mapwidth > width and xscroll < mapwidth-width then
			xtodraw = math.ceil(width+1)
		else
			xtodraw = math.ceil(width)
		end
	end
	
	local ytodraw
	if mapheight < height+1 then
		ytodraw = math.ceil(mapheight)
	else
		if mapheight > height and yscroll < mapheight-height then
			ytodraw = height+2
		else
			ytodraw = height
		end
	end
	
	--custom background
	if custombackground then
		if custombackground == true then
			local xscroll = xscroll / (scrollfactor + 1)
			if reversescrollfactor() == 1 then
				xscroll = 0
			end
			for y = 1, math.ceil(height/14)+1 do
				for x = 1, math.ceil(width)+1 do
					love.graphics.draw(portalbackgroundimg, math.floor((x-1)*16*scale) - math.floor(math.mod(xscroll, 1)*16*scale), math.floor(((y-1)*14)*16*scale) - math.floor(math.mod(yscroll, 14)*16*scale), 0, scale, scale)
				end
			end
		else
			if custombackgroundimg[custombackground] then
				for i = #custombackgroundimg[custombackground], 1, -1  do
					local xscroll = xscroll / (i * scrollfactor + 1)
					if reversescrollfactor() == 1 then
						xscroll = 0
					end
					
					local yscroll = yscroll / (i * scrollfactor + 1)
					if reversescrollfactor() == 1 then
						yscroll = 0
					end
					
					for y = 1, math.ceil(height/custombackgroundheight[custombackground][i])+1 do
						for x = 1, math.ceil(width/custombackgroundwidth[custombackground][i])+1 do
							love.graphics.draw(custombackgroundimg[custombackground][i], math.floor(((x-1)*custombackgroundwidth[custombackground][i])*16*scale) - math.floor(math.mod(xscroll, custombackgroundwidth[custombackground][i])*16*scale), math.floor(((y-1)*custombackgroundheight[custombackground][i])*16*scale) - math.floor(math.mod(yscroll, custombackgroundheight[custombackground][i])*16*scale), 0, scale, scale)
						end
					end
				end
			end
		end
	end
	
	--castleflag
	if levelfinished and levelfinishtype == "flag" and not custombackground then
		love.graphics.draw(castleflagimg, math.floor((flagx+6-xscroll)*16*scale), (flagy-7+10/16)*16*scale+(castleflagy-yscroll)*16*scale, 0, scale, scale)
	end
	
	--itemanimations
	for j, w in pairs(itemanimations) do
		w:draw()
	end
	
	--TILES
	love.graphics.draw(smbspritebatch, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
	love.graphics.draw(portalspritebatch, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
	if customtiles then
		love.graphics.draw(customspritebatch, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
	end
	
	local lmap = map
	
	local flooredxscroll
	if xscroll >= 0 then
		flooredxscroll = math.floor(xscroll)
	else
		flooredxscroll = math.ceil(xscroll)
	end
	
	local flooredyscroll
	if yscroll >= 0 then
		flooredyscroll = math.floor(yscroll)
	else
		flooredyscroll = math.ceil(yscroll)
	end
	
	for y = 1, ytodraw do
		for x = 1, xtodraw do
			if inmap(flooredxscroll+x, flooredyscroll+y) then
				local bounceyoffset = 0
				for i, v in pairs(blockbouncex) do
					if blockbouncex[i] == flooredxscroll+x and blockbouncey[i] == flooredyscroll+y then
						if blockbouncetimer[i] < blockbouncetime/2 then
							bounceyoffset = blockbouncetimer[i] / (blockbouncetime/2) * blockbounceheight
						else
							bounceyoffset = (2 - blockbouncetimer[i] / (blockbouncetime/2)) * blockbounceheight
						end
					end	
				end
				
				local cox, coy = flooredxscroll+x, flooredyscroll+y
				local t = lmap[flooredxscroll+x][flooredyscroll+y]
				
				local tilenumber = t[1]
				if tilequads[tilenumber]:getproperty("coinblock", cox, coy) and tilequads[tilenumber]:getproperty("invisible", cox, coy) == false then --coinblock
					love.graphics.drawq(coinblockimg, coinblockquads[spriteset][coinframe], math.floor((x-1-math.mod(xscroll, 1))*16*scale), math.floor(((y-1-math.mod(yscroll, 1)-bounceyoffset)*16-8)*scale), 0, scale, scale)
				elseif coinmap[cox][coy] then --coin
					love.graphics.drawq(coinimg, coinquads[spriteset][coinframe], math.floor((x-1-math.mod(xscroll, 1))*16*scale), math.floor(((y-1-math.mod(yscroll, 1)-bounceyoffset)*16-8)*scale), 0, scale, scale)
				elseif bounceyoffset ~= 0 or tilenumber > 10000 then
					if not tilequads[tilenumber]:getproperty("invisible", cox, coy) then
						love.graphics.drawq(tilequads[tilenumber].image, tilequads[tilenumber]:quad(flooredxscroll+x, flooredyscroll+y), math.floor((x-1-math.mod(xscroll, 1))*16*scale), math.floor(((y-1-math.mod(yscroll, 1)-bounceyoffset)*16-8)*scale), 0, scale, scale)
					end
				end
				
				--Gel overlays!
				if t["gels"] then
					for i = 1, 4 do
						local dir = "top"
						local r = 0
						if i == 2 then
							dir = "right"
							r = math.pi/2
						elseif i == 3 then
							dir = "bottom"
							r = math.pi
						elseif i == 4 then
							dir = "left"
							r = math.pi*1.5
						end
						
						for i = 1, 4 do
							if t["gels"][dir] == i then
								local img
								if i == 1 then
									img = gel1groundimg
								elseif i == 2 then
									img = gel2groundimg
								elseif i == 3 then
									img = gel3groundimg
								elseif i == 4 then
									img = gel4groundimg
								end
									
								love.graphics.draw(img, math.floor((x-.5-math.mod(xscroll, 1))*16*scale), math.floor((y-1-math.mod(yscroll, 1)-bounceyoffset)*16*scale), r, scale, scale, 8, 8)
							end
						end
					end
				end
				
				if editormode then
					if tilequads[t[1]]:getproperty("invisible", cox, coy) and t[1] ~= 1 then
						love.graphics.drawq(tilequads[t[1]].image, tilequads[t[1]]:quad(), math.floor((x-1-math.mod(xscroll, 1))*16*scale), ((y-1-math.mod(yscroll, 1))*16-8)*scale, 0, scale, scale)
					end
					
					if #t > 1 and t[2] ~= "link" then
						tilenumber = t[2]
						love.graphics.setColor(1, 1, 1, 0.6)
						if tablecontains(enemies, tilenumber) then --ENEMY PREVIEW THING
							local v = enemiesdata[tilenumber]
							local xoff, yoff = (((v.spawnoffsetx or 0)+v.width/2-.5)*16 - v.offsetX + v.quadcenterX)*scale, (((v.spawnoffsety or 0)-v.height+1)*16-v.offsetY - v.quadcenterY)*scale
							
							local mx, my = getMouseTile(mouse.getX(), mouse.getY()+8*scale)
							local alpha = 0.6
							if x == mx and y == my then
								alpha = 1
							end
							
							love.graphics.setColor(1, 0, 0, alpha)
							love.graphics.rectangle("fill", math.floor((x-1-math.mod(xscroll, 1))*16*scale), math.floor(((y-1-math.mod(yscroll, 1))*16-8)*scale), 16*scale, 16*scale)
							love.graphics.setColor(1, 1, 1, alpha)
							love.graphics.drawq(v.graphic, v.quad, math.floor((x-1-math.mod(xscroll, 1))*16*scale+xoff), math.floor(((y-1-math.mod(yscroll, 1))*16)*scale+yoff), 0, scale, scale)
						else
							love.graphics.drawq(entityquads[tilenumber].image, entityquads[tilenumber].quad, math.floor((x-1-math.mod(xscroll, 1))*16*scale), math.floor(((y-1-math.mod(yscroll, 1))*16-8)*scale), 0, scale, scale)
						end
						love.graphics.setColor(1, 1, 1, 1)
					end
					
					if entitylist[map[x][y][2]] and entitylist[map[x][y][2]].t == "platform" then
						local dir, dist
						if rightclickm and rightclickm.tx == x and rightclickm.ty == y then
							dir = rightclickm.variables[2].value
							dist = tonumber(rightclickm.t[6].value)
						else
							dir = map[x][y][3]
							dist = tonumber(map[x][y][5])
						end
						
						
						love.graphics.setColor(252 / 255, 152 / 255, 56 / 255, 0.6)
						if dir == "down" then
							love.graphics.line((x-xscroll-.5)*16*scale, (y-yscroll-1.2)*16*scale, (x-xscroll-.5)*16*scale, (y-yscroll-1.2+dist)*16*scale)
						elseif dir == "left" then
							love.graphics.line((x-xscroll-.5)*16*scale, (y-yscroll-1.2)*16*scale, (x-xscroll-.5-dist)*16*scale, (y-yscroll-1.2)*16*scale)
						end
						love.graphics.setColor(1, 1, 1, 1)
					end
				end
			end
		end
	end
	
	love.graphics.setColor(1, 1, 1)
	--textentities
	for j, w in pairs(textentities) do
		w:draw()
	end
end

function drawui(hidetime)
	local printfunction = properprint
	if custombackground then
		printfunction = properprintbackground
	end

	---UI
	love.graphics.setColor(1, 1, 1)
	love.graphics.translate(0, -yoffset*scale)
	if yoffset < 0 then
		love.graphics.translate(0, yoffset*scale)
	end
	
	if not characters[mariocharacter[1]] then
		mariocharacter[1] = "mario"
	end
	printfunction(characters[mariocharacter[1]].name, uispace*.5 - 24*scale, 8*scale)
	printfunction(addzeros(marioscore, 6), uispace*0.5-24*scale, 16*scale)
	
	printfunction("*", uispace*1.5-8*scale, 16*scale)
	
	love.graphics.drawq(coinanimationimg, coinanimationquads[spriteset][coinframe], uispace*1.5-16*scale, 16*scale, 0, scale, scale)
	printfunction(addzeros(mariocoincount, 2), uispace*1.5-0*scale, 16*scale)
	
	printfunction("world", uispace*2.5 - 20*scale, 8*scale)
	printfunction(marioworld .. "-" .. mariolevel, uispace*2.5 - 12*scale, 16*scale)
	
	printfunction("time", uispace*3.5 - 16*scale, 8*scale)
	if not hidetime then
		if editormode then
			if linktool then
				printfunction("link", uispace*3.5 - 16*scale, 16*scale)
			else
				printfunction("edit", uispace*3.5 - 16*scale, 16*scale)
			end
		else
			if type(mariotime) == "number" then
				printfunction(addzeros(math.ceil(mariotime), 3), uispace*3.5-8*scale, 16*scale)
			else
				printfunction(mariotime, uispace*3.5-8*scale, 16*scale)
			end
		end
	end
	
	if players > 1 and gamestate ~= "menu" then
		for i = 1, players do
			local x = (width*16)/players/2 + (width*16)/players*(i-1)
			if mariolivecount ~= false then
				printfunction("p" .. i .. " * " .. mariolives[i], (x-string.len("p" .. i .. " * " .. mariolives[i])*4+4)*scale, 25*scale)
				love.graphics.setColor(mariocolors[i][1] or {1, 1, 1})
				love.graphics.rectangle("fill", (x-string.len("p" .. i .. " * " .. mariolives[i])*4-3)*scale, 25*scale, 7*scale, 7*scale)
				love.graphics.setColor(1, 1, 1, 1)
			end
		end
	end
end

function drawforeground()
	--TILES FOREGROUND
	love.graphics.draw(smbspritebatchfront, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
	love.graphics.draw(portalspritebatchfront, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
	if customtiles then
		love.graphics.draw(customspritebatchfront, math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
	end
	
	
	--ANY NON STATIC BLOCKS AND STUFF.
	local lmap = map
	
	local xtodraw
	if mapwidth < width+1 then
		xtodraw = math.ceil(mapwidth)
	else
		if mapwidth > width and xscroll < mapwidth-width then
			xtodraw = math.ceil(width+1)
		else
			xtodraw = math.ceil(width)
		end
	end
	
	local ytodraw
	if mapheight < height+1 then
		ytodraw = math.ceil(mapheight)
	else
		if mapheight > height and yscroll < mapheight-height then
			ytodraw = height+1
		else
			ytodraw = height
		end
	end
	
	local flooredxscroll
	if xscroll >= 0 then
		flooredxscroll = math.floor(xscroll)
	else
		flooredxscroll = math.ceil(xscroll)
	end
	
	local flooredyscroll
	if yscroll >= 0 then
		flooredyscroll = math.floor(yscroll)
	else
		flooredyscroll = math.ceil(yscroll)
	end
	
	for y = 1, ytodraw do
		for x = 1, xtodraw do
			if inmap(flooredxscroll+x, flooredyscroll+y) then
				local cox, coy = flooredxscroll+x, flooredyscroll+y
				local t = lmap[cox][coy]
				
				local tilenumber = t[1]
				
				if tilequads[tilenumber]:getproperty("foreground", cox, coy) then
					if tilequads[tilenumber]:getproperty("coinblock", cox, coy) and not tilequads[tilenumber]:getproperty("invisible", cox, coy) then --coinblock
						love.graphics.drawq(coinblockimg, coinblockquads[spriteset][coinframe], math.floor((x-1-math.mod(xscroll, 1))*16*scale), math.floor(((y-1-math.mod(yscroll, 1))*16-8)*scale), 0, scale, scale)
					elseif coinmap[x][y] then --coin
						love.graphics.drawq(coinimg, coinquads[spriteset][coinframe], math.floor((x-1-xscroll)*16*scale), math.floor(((y-1-yscroll)*16-8)*scale), 0, scale, scale)
					elseif tilenumber > 10000 then
						if not tilequads[tilenumber]:getproperty("invisible", cox, coy) then
							love.graphics.drawq(tilequads[tilenumber].image, tilequads[tilenumber]:quad(flooredxscroll+x, flooredyscroll+y), math.floor((x-1-math.mod(xscroll, 1))*16*scale), math.floor(((y-1-math.mod(yscroll, 1))*16-8)*scale), 0, scale, scale)
						end
					end
					
					--Gel overlays!
					if t["gels"] then
						for i = 1, 4 do
							local dir = "top"
							local r = 0
							if i == 2 then
								dir = "right"
								r = math.pi/2
							elseif i == 3 then
								dir = "bottom"
								r = math.pi
							elseif i == 4 then
								dir = "left"
								r = math.pi*1.5
							end
							
							for i = 1, 4 do
								if t["gels"][dir] == i then
									local img
									if i == 1 then
										img = gel1groundimg
									elseif i == 2 then
										img = gel2groundimg
									elseif i == 3 then
										img = gel3groundimg
									elseif i == 4 then
										img = gel4groundimg
									end
										
									love.graphics.draw(img, math.floor((x-.5-math.mod(xscroll, 1))*16*scale), math.floor((y-1-math.mod(yscroll, 1))*16*scale), r, scale, scale, 8, 8)
								end
							end
						end
					end
				end
			end
		end
	end
	
	--custom foreground
	if customforeground then
		if customforeground == true then
			--None
		else
			if custombackgroundimg[customforeground] then
				for i = 1, #custombackgroundimg[customforeground]  do
				
					local xscroll = xscroll * (i * fscrollfactor + 1)
					if reversefscrollfactor() == 1 then
						xscroll = 0
					end
					
					local yscroll = yscroll / (i * fscrollfactor + 1)
					if reversefscrollfactor() == 1 then
						yscroll = 0
					end
					
					for y = 1, math.ceil(height/custombackgroundheight[customforeground][i])+1 do
						for x = 1, math.ceil(width/custombackgroundwidth[customforeground][i])+1 do
							love.graphics.draw(custombackgroundimg[customforeground][i], math.floor(((x-1)*custombackgroundwidth[customforeground][i])*16*scale) - math.floor(math.mod(xscroll, custombackgroundwidth[customforeground][i])*16*scale), math.floor(((y-1)*custombackgroundheight[customforeground][i])*16*scale) - math.floor(math.mod(yscroll, custombackgroundheight[customforeground][i])*16*scale), 0, scale, scale)
						end
					end
				end
			end
		end
	end
end

function game_draw()
	if not objects then return end
	if firstpersonview and firstpersonrotate then
		local xtranslate = width/2*16*scale
		local ytranslate = height/2*16*scale
		love.graphics.translate(xtranslate, ytranslate)
		love.graphics.rotate(-objects["player"][1].rotation/2)
		love.graphics.translate(-xtranslate, -ytranslate)
	end
	
	local ww, hh = love.window.getMode()
	currentscissor = {0, 0, ww, hh}
	--This is just silly
	if earthquake > 0 and #rainbooms > 0 then
		local colortable = {{242 / 255, 111 / 255, 51 / 255}, {251 / 255, 244 / 255, 174 / 255}, {95 / 255, 186 / 255, 76 / 255}, {29 / 255, 151 / 255, 212 / 255}, {101 / 255, 45 / 255, 135 / 255}, {238 / 255, 64 / 255, 68 / 255}}
		for i = 1, backgroundstripes do
			local r, g, b = unpack(colortable[math.mod(i-1, 6)+1])
			local a = earthquake/rainboomearthquake
			
			love.graphics.setColor(r, g, b, a)
			
			local alpha = math.rad((i/backgroundstripes + math.mod(sunrot/5, 1)) * 360)
			local point1 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}
			
			local alpha = math.rad(((i+1)/backgroundstripes + math.mod(sunrot/5, 1)) * 360)
			local point2 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}
			
			love.graphics.polygon("fill", width*8*scale, 112*scale, point1[1], point1[2], point2[1], point2[2])
		end
	end
	
	love.graphics.setColor(1, 1, 1, 1)
	--tremoooor!
	if earthquake > 0 then
		tremorx = (math.random()-.5)*2*earthquake
		tremory = (math.random()-.5)*2*earthquake
		
		love.graphics.translate(round(tremorx), round(tremory))
	end
	
	love.graphics.setColor(1, 1, 1, 1)
	
	--THIS IS WHERE MAP DRAWING AND SHIT BEGINS
	
	function scenedraw()
		drawlevel()
		
		if bdrawui then
			drawui()
		end
		
		love.graphics.setColor(1, 1, 1)
		--vines
		for j, w in pairs(objects["vine"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--warpzonetext
		if displaywarpzonetext then
			properprint("welcome to warp zone!", (mapwidth-14-1/16-xscroll)*16*scale, (5.5-yscroll)*16*scale)
			for i, v in pairs(warpzonenumbers) do
				properprint(v[3], math.floor((v[1]-xscroll-1-9/16)*16*scale), (v[2]-3-yscroll)*16*scale)
			end
		end
		
		love.graphics.setColor(1, 1, 1)
		--platforms
		for j, w in pairs(objects["platform"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--scaffolds
		for j, w in pairs(objects["scaffold"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--seesawplatforms
		for j, w in pairs(objects["seesawplatform"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--seesaws
		for j, w in pairs(seesaws) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--springs
		for j, w in pairs(objects["spring"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--flag
		if flagx then
			love.graphics.draw(flagimg, math.floor((flagimgx-1-xscroll)*16*scale), ((flagimgy-yscroll)*16-8)*scale, 0, scale, scale)
			if levelfinishtype == "flag" then
				properprint2(flagscore, math.floor((flagimgx+4/16-xscroll)*16*scale), ((14-flagimgy-yscroll+(flagy-13)*2)*16-8)*scale, 0, scale, scale)
			end
		end
		
		love.graphics.setColor(1, 1, 1)
		--axe
		if axex then
			love.graphics.drawq(axeimg, axequads[coinframe], math.floor((axex-1-xscroll)*16*scale), (axey-1.5-yscroll)*16*scale, 0, scale, scale)
		end
		
		love.graphics.setColor(1, 1, 1)
		--levelfinish text and toad
		if levelfinished and levelfinishtype == "castle" then
			if marioworld ~= 8 then
				love.graphics.draw(toadimg, math.floor((mapwidth-7-xscroll)*16*scale), (axey+2.0625-yscroll)*16*scale, 0, scale, scale)
			else
				print(math.floor((mapwidth-7-xscroll)*16*scale), (axey+2.0625-yscroll)*16*scale)
				love.graphics.draw(peachimg, math.floor((mapwidth-7-xscroll)*16*scale), (axey+2.0625-yscroll)*16*scale, 0, scale, scale)
			end
		
			if levelfinishedmisc2 == 1 then
				if levelfinishedmisc >= 1 then
					properprint("thank you " .. characters[mariocharacter[1]].name .. "!", math.floor(((mapwidth-12-xscroll)*16-1)*scale), (axey-4.5-yscroll)*16*scale)
				end
				if levelfinishedmisc == 2 then
					properprint("but our princess is in", math.floor(((mapwidth-13.5-xscroll)*16-1)*scale), (axey-2.5-yscroll)*16*scale) --say what
					properprint("another castle!", math.floor(((mapwidth-13.5-xscroll)*16-1)*scale), (axey-1.5-yscroll)*16*scale) --bummer.
				end
			else
				if levelfinishedmisc >= 1 then	
					properprint("thank you mario!", math.floor(((mapwidth-12-xscroll)*16-1)*scale), (axey-4.5-yscroll)*16*scale)
				end
				if levelfinishedmisc >= 2 then
					properprint("your quest is over.", math.floor(((mapwidth-12.5-xscroll)*16-1)*scale), (axey-3-yscroll)*16*scale)
				end
				
				--todo
				if levelfinishedmisc >= 3 then
					properprint("we present you a new quest.", math.floor(((mapwidth-14.5-xscroll)*16-1)*scale), (axey-2-yscroll)*16*scale)
				end
				if levelfinishedmisc >= 4 then
					properprint("push button b", math.floor(((mapwidth-11-xscroll)*16-1)*scale), (axey-.5-yscroll)*16*scale)
				end
				if levelfinishedmisc == 5 then
					properprint("to play as steve", math.floor(((mapwidth-12-xscroll)*16-1)*scale), (axey+.5-yscroll)*16*scale)
				end
			end
		end
		love.graphics.setColor(1, 1, 1)
		--Panels
		for j, w in pairs(objects["panel"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--Fireworks
		for j, w in pairs(fireworks) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--Buttons
		for j, w in pairs(objects["button"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--Pushbuttons
		for j, w in pairs(objects["pushbutton"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		
		--hardlight bridges
		for j, w in pairs(objects["lightbridgebody"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		
		--lightbridge
		for j, w in pairs(objects["lightbridge"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--laser
		for j, w in pairs(objects["laser"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--laserdetector
		for j, w in pairs(objects["laserdetector"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--Groundlights
		for j, w in pairs(objects["groundlight"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--Faithplates
		for j, w in pairs(objects["faithplate"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--Bubbles
		for j, w in pairs(bubbles) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--miniblocks
		for i, v in pairs(miniblocks) do
			v:draw()
		end
		
		--emancipateanimations
		for i, v in pairs(emancipateanimations) do
			v:draw()
		end
		
		--emancipationfizzles
		for i, v in pairs(emancipationfizzles) do
			v:draw()
		end
		
		--pedestals
		for i, v in pairs(pedestals) do
			v:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		
		--OBJECTS
		for j, w in pairs(objects) do	
			if j ~= "tile" then
				for i, v in pairs(w) do
					if v.drawable and v.graphic and v.quad then
						love.graphics.setScissor()
						love.graphics.setColor(1, 1, 1)
						local dirscale
						
						if j == "player" then
							if (v.portalsavailable[1] or v.portalsavailable[2]) then
								if (v.pointingangle+math.pi*2 > -v.rotation+math.pi*2 and (not (v.pointingangle > -v.rotation+math.pi))) or v.pointingangle < -v.rotation-math.pi then
									dirscale = -scale
								else
									dirscale = scale
								end
							else
								if v.animationdirection == "right" then
									dirscale = scale
								else
									dirscale = -scale
								end
							end
							
							if bigmario then
								dirscale = dirscale * scalefactor
							end
						else
							if v.animationdirection == "left" then
								dirscale = -scale
							else
								dirscale = scale
							end
						end
						
						if v.mirror then
							dirscale = -dirscale
						end
						
						local horscale = scale
						if v.shot or v.upsidedown then
							horscale = -scale
						end
						
						if j == "player" and bigmario then
							horscale = horscale * scalefactor
						end
						
						if v.customscale then
							horscale = horscale * v.customscale
							dirscale = dirscale * v.customscale
						end
						
						local portal, portaly = insideportal(v.x, v.y, v.width, v.height)
						local entryX, entryY, entryfacing, exitX, exitY, exitfacing
						
						--SCISSOR FOR ENTRY
						if v.customscissor and v.portalable ~= false then
							local t = "setStencil"
							if v.invertedscissor then
								t = "setInvertedStencil"
							end
							local action = nil
							local int = nil
							
							if loveVersion > 9 then
								t = "stencil"
								action = "replace"
								int = 1
							end
							love.graphics[t](function() love.graphics.rectangle("fill", math.floor((v.customscissor[1]-xscroll)*16*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*scale), v.customscissor[3]*16*scale, v.customscissor[4]*16*scale) end, action, int)
							
							if loveVersion > 9 then
								love.graphics.setStencilTest((v.invertedscissor and "equal" or "greater"), 0)
							end
						end
							
						if v.static == false and v.portalable ~= false then
							if not v.customscissor and portal ~= false and (v.active or v.portaloverride) then
								if portaly == 1 then
									entryX, entryY, entryfacing = portal.x1, portal.y1, portal.facing1
									exitX, exitY, exitfacing = portal.x2, portal.y2, portal.facing2
								else
									entryX, entryY, entryfacing = portal.x2, portal.y2, portal.facing2
									exitX, exitY, exitfacing = portal.x1, portal.y1, portal.facing1
								end
								
								if entryfacing == "right" then
									love.graphics.setScissor(math.floor((entryX-xscroll)*16*scale), math.floor(((entryY-3.5-yscroll)*16)*scale), 64*scale, 96*scale)
								elseif entryfacing == "left" then
									love.graphics.setScissor(math.floor((entryX-xscroll-5)*16*scale), math.floor(((entryY-4.5-yscroll)*16)*scale), 64*scale, 96*scale)
								elseif entryfacing == "up" then
									love.graphics.setScissor(math.floor((entryX-xscroll-3)*16*scale), math.floor(((entryY-5.5-yscroll)*16)*scale), 96*scale, 64*scale)
								elseif entryfacing == "down" then
									love.graphics.setScissor(math.floor((entryX-xscroll-4)*16*scale), math.floor(((entryY-0.5-yscroll)*16)*scale), 96*scale, 64*scale)
								end
							end
						end
						
						if type(v.graphic) == "table" then
							for k = 1, #v.graphic do
								if v.colors[k] then
									love.graphics.setColor(v.colors[k])
								else
									love.graphics.setColor(1, 1, 1)
								end
								love.graphics.drawq(v.graphic[k], v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
						else
							if v.graphic and v.quad then
								love.graphics.drawq(v.graphic, v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
						end
						
						--HATS
						if v.drawhat then
							local offsets = gethatoffset(v.char, v.graphic, v.animationstate, v.runframe, v.jumpframe, v.climbframe, v.swimframe, v.underwater, v.infunnel, v.fireanimationtimer, v.ducking)
							
							if offsets and #v.hats > 0 then
								local yadd = 0
								for i = 1, #v.hats do
									if v.hats[i] ~= 0 then
										if v.hats[i] == 1 then
											love.graphics.setColor(v.colors[1])
										else
											love.graphics.setColor(1, 1, 1)
										end
										if v.graphic == v.biggraphic or v.animationstate == "grow" then
											love.graphics.draw(bighat[v.hats[i]].graphic, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd)
											yadd = yadd + bighat[v.hats[i]].height
										else
											love.graphics.draw(hat[v.hats[i]].graphic, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - hat[v.hats[i]].x + offsets[1], v.quadcenterY - hat[v.hats[i]].y + offsets[2] + yadd)
											yadd = yadd + hat[v.hats[i]].height
										end
									end
								end
							end
							love.graphics.setColor(1, 1, 1)
						end
						
						if type(v.graphic) == "table" then
							if v.graphic[0] then
								love.graphics.setColor(1, 1, 1)
								love.graphics.drawq(v.graphic[0], v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
							if v.graphic.dot then
								love.graphics.setColor(unpack(v["portal" .. (v.lastportal or 1) .. "color"]))
								love.graphics.drawq(v.graphic["dot"], v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end	
						end
						
						--portal duplication
						if v.customscissor and v.portalable ~= false then
							local t = "setStencil"
							if v.invertedscissor then
								t = "setInvertedStencil"
							end
							local action = nil
							local int = nil
							
							if loveVersion > 9 then
								t = "stencil"
								action = "replace"
								int = 1
							end
							love.graphics[t](function() love.graphics.rectangle("fill", math.floor((v.customscissor[1]-xscroll)*16*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*scale), v.customscissor[3]*16*scale, v.customscissor[4]*16*scale) end, action, int)
							
							if loveVersion > 9 then
								love.graphics.setStencilTest((v.invertedscissor and "equal" or "greater"), 0)
							end
						end
						
						if v.static == false and (v.active or v.portaloverride) and v.portalable ~= false then
							if not v.customscissor and portal ~= false then
								love.graphics.setScissor(unpack(currentscissor))
								local px, py, pw, ph, pr, pad = v.x, v.y, v.width, v.height, v.rotation, v.animationdirection
								px, py, d, d, pr, pad = portalcoords(px, py, 0, 0, pw, ph, pr, pad, entryX, entryY, entryfacing, exitX, exitY, exitfacing)
								
								if pad ~= v.animationdirection then
									dirscale = -dirscale
								end
								
								horscale = scale
								if v.shot or v.upsidedown then
									horscale = -scale
								end
								
								if exitfacing == "right" then
									love.graphics.setScissor(math.floor((exitX-xscroll)*16*scale), math.floor(((exitY-yscroll-3.5)*16)*scale), 64*scale, 96*scale)
								elseif exitfacing == "left" then
									love.graphics.setScissor(math.floor((exitX-xscroll-5)*16*scale), math.floor(((exitY-yscroll-4.5)*16)*scale), 64*scale, 96*scale)
								elseif exitfacing == "up" then
									love.graphics.setScissor(math.floor((exitX-xscroll-3)*16*scale), math.floor(((exitY-yscroll-5.5)*16)*scale), 96*scale, 64*scale)
								elseif exitfacing == "down" then
									love.graphics.setScissor(math.floor((exitX-xscroll-4)*16*scale), math.floor(((exitY-yscroll-0.5)*16)*scale), 96*scale, 64*scale)
								end
								
								if type(v.graphic) == "table" then
									for k = 1, #v.graphic do
										if v.colors[k] then
											love.graphics.setColor(v.colors[k])
										else
											love.graphics.setColor(1, 1, 1)
										end
										love.graphics.drawq(v.graphic[k], v.quad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
									end
								else
									love.graphics.drawq(v.graphic, v.quad, math.ceil(((px-xscroll)*16+v.offsetX)*scale), math.ceil(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
								end
								
								--HAAAATS
								if v.drawhat then
									local offsets = gethatoffset(v.char, v.graphic, v.animationstate, v.runframe, v.jumpframe, v.climbframe, v.swimframe, v.underwater, v.infunnel, v.fireanimationtimer, v.ducking)
							
									if offsets and #v.hats > 0 then
										local yadd = 0
										for i = 1, #v.hats do
											if v.hats[i] ~= 0 then
												if v.hats[i] == 1 then
													love.graphics.setColor(v.colors[1])
												else
													love.graphics.setColor(1, 1, 1)
												end
												if v.graphic == v.biggraphic or v.animationstate == "grow" then
													love.graphics.draw(bighat[v.hats[i]].graphic, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd)
													yadd = yadd + bighat[v.hats[i]].height
												else
													love.graphics.draw(hat[v.hats[i]].graphic, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - hat[v.hats[i]].x + offsets[1], v.quadcenterY - hat[v.hats[i]].y + offsets[2] + yadd)
													yadd = yadd + hat[v.hats[i]].height
												end
											end
										end
									end
								end
								
								if type(v.graphic) == "table" then
									if v.graphic[0] then
										love.graphics.setColor(1, 1, 1)
										love.graphics.drawq(v.graphic[0], v.quad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
									end
									if v.graphic.dot and v.lastportal then
										love.graphics.setColor(unpack(v["portal" .. v.lastportal .. "color"]))
										love.graphics.drawq(v.graphic["dot"], v.quad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
									end
								end
							end
						end
						love.graphics.setScissor(unpack(currentscissor))
						if loveVersion > 9 then
							love.graphics.setStencilTest()
						else
							love.graphics.setStencil()
						end
					end
				end
			end
		end
		
		love.graphics.setColor(1, 1, 1)
		
		--bowser
		for j, w in pairs(objects["bowser"]) do
			w:draw()
		end
		
		--Geldispensers
		for j, w in pairs(objects["geldispenser"]) do
			w:draw()
		end
		
		--Cubedispensers
		for j, w in pairs(objects["cubedispenser"]) do
			w:draw()
		end
		
		--Funnels
		for j, w in pairs(objects["funnel"]) do
			w:draw()
		end
		
		--Emancipationgrills
		for j, w in pairs(emancipationgrills) do
			w:draw()
		end
		
		--Doors
		for j, w in pairs(objects["door"]) do
			w:draw()
		end
		
		--Wallindicators
		for j, w in pairs(objects["wallindicator"]) do
			w:draw()
		end
		
		--Tiletriggers
		for j, w in pairs(objects["animatedtiletrigger"]) do
			w:draw()
		end
		
		--Delayers
		for j, w in pairs(objects["delayer"]) do
			w:draw()
		end
		
		--Walltimers
		for j, w in pairs(objects["walltimer"]) do
			w:draw()
		end
		
		--Notgates
		for j, w in pairs(objects["notgate"]) do
			w:draw()
		end
		
		--RSFlipflops
		for j, w in pairs(objects["rsflipflop"]) do
			w:draw()
		end
		
		--Orgates
		for j, w in pairs(objects["orgate"]) do
			w:draw()
		end
		
		--Andgates
		for j, w in pairs(objects["andgate"]) do
			w:draw()
		end
		
		--Musicentities
		for j, w in pairs(objects["musicentity"]) do
			w:draw()
		end
		
		--Squarewaves
		for j, w in pairs(objects["squarewave"]) do
			w:draw()
		end
		
		--Squarewaves
		for j, w in pairs(objects["actionblock"]) do
			w:draw()
		end
		
		--particles
		for j, w in pairs(portalparticles) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		
		--portals
		for i, v in pairs(portals) do
			v:draw()
		end		
		
		love.graphics.setColor(1, 1, 1)
		
		--COINBLOCKanimation
		for i, v in pairs(coinblockanimations) do
			love.graphics.drawq(coinblockanimationimg, coinblockanimationquads[coinblockanimations[i].frame], math.floor((coinblockanimations[i].x - xscroll)*16*scale), math.floor(((coinblockanimations[i].y-yscroll)*16-8)*scale), 0, scale, scale, 4, 54)
		end
		
		--SCROLLING SCORE
		for i, v in pairs(scrollingscores) do
			if type(scrollingscores[i].i) == "number" then
				properprint2(scrollingscores[i].i, math.floor((scrollingscores[i].x-0.4)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale))
			elseif scrollingscores[i].i == "1up" then
				love.graphics.draw(oneuptextimage, math.floor((scrollingscores[i].x)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale), 0, scale, scale)
			end
		end
		
		--SCROLLING TEXT
		for i, v in pairs(scrollingtexts) do
			v:draw()
		end
		
		--BLOCK DEBRIS
		for i, v in pairs(blockdebristable) do
			v:draw()
		end
	
		local minex, miney, minecox, minecoy
		
		--PORTAL UI STUFF
		if levelfinished == false then
			for pl = 1, players do
				if objects["player"][pl].controlsenabled and objects["player"][pl].t == "portal" and objects["player"][pl].vine == false and (objects["player"][pl].portalsavailable[1] or objects["player"][pl].portalsavailable[2]) then
					local sourcex, sourcey = objects["player"][pl].x+6/16, objects["player"][pl].y+6/16
					local an = objects["player"][pl].pointingangle
					local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, an)
					local mirror = 1
					
					local portalpossible = true
					if cox == false then
						portalpossible = false
					else
						local _, _, m = getportalposition(1, cox, coy, side, tend, true)
						if m == "mirror" then
							portalpossible = false
							
							local sourcex, sourcey = objects["player"][pl].x+6/16, objects["player"][pl].y+6/16
							local an = objects["player"][pl].pointingangle
							local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, an)
							
							for a = 1, portalbouncethreshold do
								if cox then
									local _, _, m = getportalposition(1, cox, coy, side, tend, true)
									if m == "mirror" then
										mirror = mirror+1
										sourcex, sourcey = x, y
										if side == "up" or side == "down" then
											an = math.pi-an
											if an >= math.pi then an = an - math.pi*2 end
										else
											an = -an
										end
										cox, coy, side, tend, x, y = traceline(sourcex, sourcey, an)
										if a == portalbouncethreshold or not cox then
											portalpossible = false
											break
										end
									else
										portalpossible = getportalposition(1, cox, coy, side, tend, true)
										break
									end
								else
									portalpossible = false
									break
								end
							end
							
						elseif getportalposition(1, cox, coy, side, tend) == false then
							portalpossible = false
						end
					end
					
					love.graphics.setColor(1, 1, 1, 1)
					
					local dist = math.sqrt(((x-xscroll)*16*scale - (sourcex-xscroll)*16*scale)^2 + ((y-.5-yscroll)*16*scale - (sourcey-.5-yscroll)*16*scale)^2)/16/scale
					
					for a = 1, mirror do
						local pd = portaldotsdistance-- * (.5+.5*a/(mirror))
						for i = 1, dist/pd+1 do
							if ((i-1+portaldotstimer/portaldotstime)/(dist/pd)) < 1 then
								local xplus = ((x-xscroll)*16*scale - (sourcex-xscroll)*16*scale)*((i-1+portaldotstimer/portaldotstime)/(dist/pd))
								local yplus = ((y-.5-yscroll)*16*scale - (sourcey-.5-yscroll)*16*scale)*((i-1+portaldotstimer/portaldotstime)/(dist/pd))
							
								local dotx = (sourcex-xscroll)*16*scale + xplus
								local doty = (sourcey-.5-yscroll)*16*scale + yplus
							
								local radius = math.sqrt(xplus^2 + yplus^2)/scale
								
								local alpha = 1
								if radius < portaldotsouter and a == 1 then
									alpha = (radius-portaldotsinner) * (255/(portaldotsouter-portaldotsinner))
									if alpha < 0 then
										alpha = 0
									end
									alpha = alpha/255
								end
								
								
								if portalpossible == false then
									love.graphics.setColor(1, 0, 0, alpha)
								else
									love.graphics.setColor(0, 1, 0, alpha)
								end
							
								love.graphics.draw(portaldotimg, math.floor(dotx-0.25*scale), math.floor(doty-0.25*scale), 0, scale, scale)
							end
						end
						
						if cox then
							local _, _, m = getportalposition(1, cox, coy, side, tend, true)
							if m == "mirror" then
								sourcex, sourcey = x, y
								if side == "up" or side == "down" then
									an = math.pi-an
									if an >= math.pi then an = an - math.pi*2 end
								else
									an = -an
								end
								cox, coy, side, tend, x, y = traceline(sourcex, sourcey, an)
							end
						end
						dist = math.sqrt(((x-xscroll)*16*scale - (sourcex-xscroll)*16*scale)^2 + ((y-.5-yscroll)*16*scale - (sourcey-.5-yscroll)*16*scale)^2)/16/scale
					end
				
					love.graphics.setColor(1, 1, 1, 1)
					
					if cox ~= false then
						if portalpossible == false then
							love.graphics.setColor(1, 0, 0)
						else
							love.graphics.setColor(0, 1, 0)
						end
						
						local rotation = 0
						if side == "right" then
							rotation = math.pi/2
						elseif side == "down" then
							rotation = math.pi
						elseif side == "left" then
							rotation = math.pi/2*3
						end
						love.graphics.draw(portalcrosshairimg, math.floor((x-xscroll)*16*scale), math.floor((y-.5-yscroll)*16*scale), rotation, scale, scale, 4, 8)
					end
				end
			end
		end
		
		--Portal projectile
		for i, v in pairs(portalprojectiles) do
			v:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		
		--nothing to see here
		for i, v in pairs(rainbooms) do
			v:draw()
		end
		
		drawforeground()
	end --SCENE DRAW FUNCTION END
	
	if players == 1 and (loveVersion > 9 or love.graphics.isSupported("canvas")) and seethroughportals then
		if not scenecanvas then
			scenecanvas = love.graphics.newCanvas()
		end
		
		local pl = objects["player"][1]
		scenecanvas:clear()
		love.graphics.setCanvas{scenecanvas, stencil=true}
		scenedraw()
		love.graphics.setCanvas{completecanvas, stencil=true}
		love.graphics.draw(scenecanvas, 0, 0)
		
		if firstpersonview and firstpersonrotate then
			local xtranslate = width/2*16*scale
			local ytranslate = height/2*16*scale
			love.graphics.translate(xtranslate, ytranslate)
			love.graphics.rotate(-objects["player"][1].rotation/2)
			love.graphics.translate(-xtranslate, -ytranslate)
		end
		
		currentscissor = {0, 0,width*16*scale, height*16*scale}
		
		for k, v in pairs(portals) do
			if v.x1 and v.x2 then
				for i = 1, 2 do
					local otheri = 1
					if i == 1 then
						otheri = 2
					end
				
					local x, y, facing = v["x" .. i], v["y" .. i], v["facing" .. i]
					local x2, y2, facing2 = v["x" .. otheri], v["y" .. otheri], v["facing" .. otheri]
					local pass = false
					
					if facing == "up" then
						pass = pl.y+pl.height/2 < y-1
					elseif facing == "right" then
						pass = pl.x+pl.width/2 > x
					elseif facing == "down" then
						pass = pl.y+pl.height/2 > y
					elseif facing == "left" then
						pass = pl.x+pl.width/2 < x-1
					end
					
					if pass then
						local p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y
						if facing == "right" then
							p1x, p1y = (x-xscroll), (y-yscroll-1.5)
							p2x, p2y = p1x, p1y+2
						elseif facing == "down" then
							p1x, p1y = (x-xscroll-2), (y-yscroll-.5)
							p2x, p2y = p1x+2, p1y
						elseif facing == "left" then
							p1x, p1y = (x-xscroll-1), (y-yscroll-2.5)
							p2x, p2y = p1x, p1y+2
						elseif facing == "up" then
							p1x, p1y = (x-xscroll-1), (y-yscroll-1.5)
							p2x, p2y = p1x+2, p1y
						end
						
						local r1 = math.atan2((pl.x+pl.width/2-xscroll)-p1x, (pl.y+pl.height/2-yscroll-.5)-p1y)
						local r2 = math.atan2((pl.x+pl.width/2-xscroll)-p2x, (pl.y+pl.height/2-yscroll-.5)-p2y)
						
						local limit = (width+height)*100
						
						p3x = -math.sin(r1)*limit+p1x
						p3y = -math.cos(r1)*limit+p1y
						
						p4x = -math.sin(r2)*limit+p2x
						p4y = -math.cos(r2)*limit+p2y
						
						
						--Calculate the middle of the portals
						local tx, ty
						local r1
						if facing == "right" then
							tx, ty = (x-xscroll), (y-yscroll-.5)
							r1 = math.pi/2
						elseif facing == "down" then
							tx, ty = (x-xscroll-1), (y-yscroll-.5)
							r1 = math.pi
						elseif facing == "left" then
							tx, ty = (x-xscroll-1), (y-yscroll-1.5)
							r1 = math.pi*1.5
						elseif facing == "up" then
							tx, ty = (x-xscroll), (y-yscroll-1.5)
							r1 = 0
						end
						
						local ox, oy
						if facing2 == "right" then
							ox, oy = (x2-xscroll), (y2-yscroll-.5)
							r2 = math.pi/2
						elseif facing2 == "down" then
							ox, oy = (x2-xscroll-1), (y2-yscroll-.5)
							r2 = math.pi
						elseif facing2 == "left" then
							ox, oy = (x2-xscroll-1), (y2-yscroll-1.5)
							r2 = math.pi*1.5
						elseif facing2 == "up" then
							ox, oy = (x2-xscroll), (y2-yscroll-1.5)
							r2 = 0
						end
						
						local offx, offy = tx-ox, ty-oy
						
						local a = r2-r1
						
						local xscale, yscale = 1, 1
						
						if facing == facing2 then
							if facing == "left" or facing == "right" then
								xscale = -xscale
							else
								yscale = -yscale
							end
						end
						
						if (facing == "left" and facing2 == "right") or (facing == "right" and facing2 == "left") or (facing == "up" and facing2 == "down") or (facing == "down" and facing2 == "up") then
							a = a - math.pi
						end
						
						local t = "setStencil"
						local action = nil
						local int = nil
						if loveVersion > 9 then
							t = "stencil"
							action = "replace"
							int = 1
						end
						
						love.graphics[t](function()
							love.graphics.polygon("fill", p1x*16*scale, p1y*16*scale, p2x*16*scale, p2y*16*scale, p4x*16*scale, p4y*16*scale, p3x*16*scale, p3y*16*scale)
						end, action, int) --feels like javascript
							
						if loveVersion > 9 then
							love.graphics.setStencilTest("greater", 0)
						end
						
						love.graphics.setColor(unpack(background))
						love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
						
						
						love.graphics.setColor(1, 1, 1)
						love.graphics.draw(scenecanvas, (offx+ox)*16*scale, (offy+oy)*16*scale, a, xscale, yscale, ox*16*scale, oy*16*scale)
						
						local r, g, b = unpack(v["portal" .. i .. "color"])
						--love.graphics.setColor(r, g, b, 0.6)
						--love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
					
						if loveVersion > 9 then
							love.graphics.setStencilTest()
						else
							love.graphics.setStencil()
						end

						love.graphics.setColor(r, g, b)
						love.graphics.line(p1x*16*scale, p1y*16*scale, p3x*16*scale, p3y*16*scale)
						love.graphics.line(p2x*16*scale, p2y*16*scale, p4x*16*scale, p4y*16*scale)
					end
				end
			end
		end
	else
		scenedraw()
	end
	
	love.graphics.setColor(1, 1, 1, 1)
	
	--Player markers
	for i = 1, players do
		local v = objects["player"][i]
		if false and not v.dead and v.drawable and v.y < mapheight-.5 then
			--get if player offscreen
			local right, left, up, down = false, false, false, false
			if v.x > xscroll+width then
				right = true
			end
			
			if v.x+v.width < xscroll then
				left = true
			end
			
			if v.y > yscroll + .5 + height then
				down = true
			end
			
			if v.y+v.height < yscroll +.5 then
				up = true
			end
			
			if up or left or down or right then
				local x, y
				local angx, angy = 0, 0
				
				if right then
					x = width
					angx = 1
				elseif left then
					x = 0
					angx = -1
				end
				
				if up then
					y = 0
					angy = -1
				elseif down then
					y = height
					angy = 1
				end
				
				if not x then
					x = v.x-xscroll+v.width/2
				end
				
				if not y then
					y = v.y-yscroll-3/16
				end
				
				local r = -math.atan2(angx, angy)-math.pi/2
				
				--limit x or y if right angle
				if math.mod(r, math.pi/2) == 0 then
					if up or down then
						x = math.max(x, 15/16)
						x = math.min(x, width-15/16)
					else
						y = math.max(y, 15/16)
						y = math.min(y, height-15/16)
					end
				end
				
				love.graphics.setColor(background)
				love.graphics.draw(markbaseimg, math.floor(x*16*scale), math.floor(y*16*scale), r, scale, scale, 0, 15)
				
				local dist = 21.5
				
				local xadd = math.cos(r)*dist
				local yadd = math.sin(r)*dist
				
				love.graphics.setColor(1, 1, 1)
				
				local t = "setStencil"
				local action = nil
				local int = nil
				if loveVersion > 9 then
					t = "stencil"
					action = "replace"
					int = 1
				end
				love.graphics[t](function() love.graphics.circle("fill", math.floor((x*16+xadd)*scale), math.floor((y*16+yadd-.5)*scale), 13.5*scale) end, action, int)
				
				if loveVersion > 9 then
					love.graphics.setStencilTest("greater", 0)
				end
				
				local playerx, playery = x*16+xadd, y*16+yadd+3
				
				--draw map
				for x = math.floor(v.x), math.floor(v.x)+3 do
					for y = math.floor(v.y), math.floor(v.y)+3 do
						if inmap(x, y) then
							tilenumber = map[x][y][1]
							
							if tilenumber ~= 0 and not tilequads[tilenumber]:getproperty("invisible", x, y) then
								local img
								
								if tilenumber <= smbtilecount then
									img = smbtilesimg
								elseif tilenumber <= smbtilecount+portaltilecount then
									img = portaltilesimg
								elseif tilenumber <= smbtilecount+portaltilecount+customtilecount then
									img = customtilesimg
								end
								
								love.graphics.drawq(img, tilequads[tilenumber]:quad(), math.floor((x-1-v.x-6/16)*16*scale+playerx*scale), math.floor((y-1.5-v.y)*16*scale+playery*scale), 0, scale, scale)
							end
						end
					end
				end
				
				drawplayer(i, playerx, playery)
				if loveVersion > 9 then
					love.graphics.setStencilTest()
				else
					love.graphics.setStencil()
				end
				
				love.graphics.setColor(v.colors[1] or {1, 1, 1})
				love.graphics.draw(markoverlayimg, math.floor(x*16*scale), math.floor(y*16*scale), r, scale, scale, 0, 15)
			end
		end
	love.graphics.setScissor()
	end
	
	--Physics debug
	if physicsdebug or incognito then
		local lw = love.graphics.getLineWidth()
		love.graphics.setLineWidth(1)
		for i, v in pairs(objects) do
			for j, k in pairs(v) do
				if k.width then
					if xscroll >= k.x-width and k.x+k.width > xscroll then
						if k.active then
							love.graphics.setColor(1, 1, 1)
						else
							love.graphics.setColor(1, 0, 0)
						end
						if incognito then
							love.graphics.rectangle("fill", math.floor((k.x-xscroll)*16*scale)+.5, math.floor((k.y-yscroll-.5)*16*scale)+.5, k.width*16*scale-1, k.height*16*scale-1)
						else
							love.graphics.rectangle("line", math.floor((k.x-xscroll)*16*scale)+.5, math.floor((k.y-yscroll-.5)*16*scale)+.5, k.width*16*scale-1, k.height*16*scale-1)
						end
					end
				end
			end
		end
		love.graphics.setLineWidth(lw)
	end
	
	--Use region debug
	if userectdebug then
		love.graphics.setColor(1, 1, 1, 0.4)
		for i, k in pairs(userects) do
			love.graphics.rectangle("fill", (k.x-xscroll)*16*scale, (k.y-yscroll-.5)*16*scale, k.width*16*scale, k.height*16*scale)
		end
		love.graphics.setColor(1, 1, 1, 1)
	end
	
	
	--portalwalldebug
	if portalwalldebug then
		for j, v in pairs(portals) do
			for k = 1, 2 do
				for i = 1, 6 do
					if objects["portalwall"][v.number .. "-" .. k .. "-" .. i] then
						objects["portalwall"][v.number .. "-" .. k .. "-" .. i]:draw()
					end
				end
			end
		end
	end
	
	for i, v in pairs(dialogboxes) do
		v:draw()
	end
	
	if earthquake > 0 then
		love.graphics.translate(-round(tremorx), -round(tremory))
	end
	
	if editormode then
		editor_draw()
	end
	
	--speed gradient
	if bullettime and speed < 1 then
		love.graphics.setColor(1, 1, 1, 1-speed)
		love.graphics.draw(gradientimg, 0, 0, 0, scale, scale)
	end
	
	if yoffset < 0 then
		love.graphics.translate(0, -yoffset*scale)
	end
	love.graphics.translate(0, yoffset*scale)
	
	if testlevel then
		love.graphics.setColor(1, 0, 0)
		properprint("testing level - press esc to return to editor", 0, 0)
	end
	
	--pause menu
	if pausemenuopen then
		love.graphics.setColor(0, 0, 0, 0.4)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
		
		love.graphics.setColor(0, 0, 0)
		
		local menuwidth = 120
		local menuheight = 170
		love.graphics.rectangle("fill", (width*8*scale)-menuwidth/2*scale, (96*scale)-75*scale, menuwidth*scale, menuheight*scale)
		love.graphics.setColor(1, 1, 1)
		drawrectangle(width*8-(menuwidth/2)+1, 96-74, menuwidth-2, menuheight-2)
		
		for i = 1, #pausemenuoptions do
			love.graphics.setColor(0.4, 0.4, 0.4, 1)
			if pausemenuselected == i and not menuprompt and not desktopprompt then
				love.graphics.setColor(1, 1, 1, 1)
				properprint(">", (width*8*scale)-(menuwidth/2-5)*scale, (96*scale)-60*scale+(i-1)*25*scale)
			end
			properprint(pausemenuoptions[i], (width*8*scale)-(menuwidth/2-15)*scale, (96*scale)-60*scale+(i-1)*25*scale)
			properprint(pausemenuoptions2[i], (width*8*scale)-(menuwidth/2-15)*scale, (96*scale)-50*scale+(i-1)*25*scale)
			
			if pausemenuoptions[i] == "music volume" or pausemenuoptions[i] == "game volume" then
				drawrectangle((width*8)-42, 52+(i-1)*25, 74, 1)
				drawrectangle((width*8)-42, 49+(i-1)*25, 1, 7)
				drawrectangle((width*8)+32, 49+(i-1)*25, 1, 7)
				love.graphics.draw(volumesliderimg, math.floor(((width*8)-43+74*(pausemenuoptions[i] == "music volume" and volumemusic or volumesfx))*scale),
									(96*scale)-47*scale+(i-1)*25*scale, 0, scale, scale)
			end
		end
		
		if menuprompt then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(1, 1, 1, 1)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			properprint("quit to menu?", (width*8*scale)-string.len("quit to menu?")*4*scale, (112*scale)-10*scale)
			if pausemenuselected2 == 1 then
				properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale) 
			else
				properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
		
		if desktopprompt then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(1, 1, 1, 1)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			properprint("quit to desktop?", (width*8*scale)-string.len("quit to desktop?")*4*scale, (112*scale)-10*scale)
			if pausemenuselected2 == 1 then
				properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			else
				properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
		
		if suspendprompt then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(1, 1, 1, 1)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			properprint("suspend game? this can", (width*8*scale)-string.len("suspend game? this can")*4*scale, (112*scale)-20*scale)
			properprint("only be loaded once!", (width*8*scale)-string.len("only be loaded once!")*4*scale, (112*scale)-10*scale)
			if pausemenuselected2 == 1 then
				properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			else
				properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(0.4, 0.4, 0.4, 1)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
	end
end

function drawreplay(j, i)
	local self = replaydata[j].data[i]
	local angleframe = 1
	
	if not self.drawable then
		return
	end
	
	if self.level ~= mariolevel or self.world ~= marioworld or self.sublevel ~= mariosublevel then
		return
	end
	
	local char = replaychar[j]
	
	if j == 1 and firstreplayblue then
		replaychar[j] = characters.mario
	end
	
	if replaychar[j].nopointing then
		angleframe = 1
	else
		angleframe = getAngleFrame(self.pointingangle, self.rotation)
	end
	
	local animationstate = self.animationstate
	local size = self.size
	local quad
	
	if size == 1 then
		if self.infunnel then
			quad = replaychar[j].jump[angleframe][self.jumpframe]
		elseif self.underwater and (self.animationstate == "jumping" or self.animationstate == "falling") then
			quad = replaychar[j].swim[angleframe][self.swimframe]
		elseif animationstate == "running" or animationstate == "falling" then
			quad = replaychar[j].run[angleframe][self.runframe]
		elseif animationstate == "idle" then
			quad = replaychar[j].idle[angleframe]
		elseif animationstate == "sliding" then
			quad = replaychar[j].slide[angleframe]
		elseif animationstate == "jumping" then
			quad = replaychar[j].jump[angleframe][self.jumpframe]
		elseif animationstate == "climbing" then
			quad = replaychar[j].climb[angleframe][self.climbframe]
		elseif animationstate == "dead" then
			quad = replaychar[j].die[angleframe]
		elseif animationstate == "grow" then
			quad = replaychar[j].grow[angleframe]
		end
	elseif size > 1 then
		if self.infunnel then
			quad = replaychar[j].bigjump[angleframe][self.jumpframe]
		elseif self.underwater and (self.animationstate == "jumping" or self.animationstate == "falling") then
			quad = replaychar[j].bigswim[angleframe][self.swimframe]
		elseif self.ducking then
			quad = replaychar[j].bigduck[angleframe]
		elseif self.fireanimationtimer < fireanimationtime then
			quad = replaychar[j].bigfire[angleframe]
		else
			if animationstate == "running" or animationstate == "falling" then
				quad = replaychar[j].bigrun[angleframe][self.runframe]
			elseif animationstate == "idle" then
				quad = replaychar[j].bigidle[angleframe]
			elseif animationstate == "sliding" then
				quad = replaychar[j].bigslide[angleframe]
			elseif animationstate == "climbing" then
				quad = replaychar[j].bigclimb[angleframe][self.climbframe]
			elseif animationstate == "jumping" then
				quad = replaychar[j].bigjump[angleframe][self.jumpframe]
			end
		end
	end
	
	local graphic
	local biggraphic = replaychar[j].nogunbiganimations
	if self.size == 1 then
		graphic = replaychar[j].nogunanimations
	else
		graphic = replaychar[j].nogunbiganimations
	end
	
	if self.customscissor then
		love.graphics.setScissor(math.floor((self.customscissor[1]-xscroll)*16*scale), math.floor((self.customscissor[2]-.5-yscroll)*16*scale), self.customscissor[3]*16*scale, self.customscissor[4]*16*scale)
	end
	
	if true then
		self.pointingangle = -math.pi
		if self.animationdirection == "left" then
			self.pointingangle = math.pi
		end
	end
	
	drawplayer(nil, (self.x-xscroll+6/16)*16, self.y*16, scale, self.offsetX, self.offsetY, self.rotation, self.quadcenterX, self.quadcenterY, self.animationstate, self.underwater, self.ducking, self.hats, graphic, quad, self.pointingangle, self.shot, self.upsidedown, self.colors, self.lastportal, self.portal1color, self.portal2color, self.runframe, self.swimframe, self.climbframe, self.jumpframe, biggraphic, self.fireanimationtimer, replaychar[j])
	love.graphics.setScissor()
	replaychar[j] = char
end

function drawplayer(i, x, y, cscale,     offsetX, offsetY, rotation, quadcenterX, quadcenterY, animationstate, underwater, ducking, hats, graphic, quad, pointingangle, shot, upsidedown, colors, lastportal, portal1color, portal2color, runframe, swimframe, climbframe, jumpframe, biggraphic, fireanimationtimer, char)
	x = x-6

	local scale = scale
	if cscale then
		scale = cscale
	end
	
	local v
	
	if not offsetX then
		v = objects["player"][i]
	else
		v = {offsetX=offsetX, offsetY=offsetY, rotation=rotation, quadcenterX=quadcenterX, quadcenterY=quadcenterY, animationstate=animationstate, underwater=underwater, ducking=ducking, hats=hats, graphic=graphic, quad=quad, pointingangle=pointingangle, shot=shot, upsidedown=upsidedown, colors=colors, lastportal=lastportal, portal1color=portal1color, portal2color=portal2color, runframe=runframe, swimframe=swimframe, climbframe=climbframe, jumpframe=jumpframe, biggraphic=biggraphic, fireanimationtimer=fireanimationtimer, char=char}
		if v.char and v.graphic == v.char.biggraphic then
			v.size = 2
		else
			v.size = 1
		end
	end
	
	if (not objects or not objects["player"][i] or objects["player"][i].portalsavailable[1] or objects["player"][i].portalsavailable[2]) then
		if v.pointingangle > 0 then
			dirscale = -scale
		else
			dirscale = scale
		end
	else
		if objects["player"][i].animationdirection == "right" then
			dirscale = scale
		else
			dirscale = -scale
		end
	end
	
	local horscale = scale
	if v.shot or v.upsidedown then
		horscale = -scale
	end
	
	if type(v.graphic) == "table" then
		for k = 1, #v.graphic do
			if v.colors[k] then
				love.graphics.setColor(v.colors[k])
			else
				love.graphics.setColor(1, 1, 1)
			end
			love.graphics.drawq(v.graphic[k], v.quad, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
		end
	else
		if v.graphic and v.quad then
			love.graphics.setColor(1, 1, 1)
			love.graphics.drawq(v.graphic, v.quad, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
		end	
	end
	
	
	if v.drawhat ~= false then
		local offsets = gethatoffset(v.char, v.graphic, v.animationstate, v.runframe, v.jumpframe, v.climbframe, v.swimframe, v.underwater, v.infunnel, v.fireanimationtimer, v.ducking)
		
		if offsets and #v.hats > 0 then
			local yadd = 0
			for i = 1, #v.hats do
				if v.hats[i] ~= 0 then
					if v.hats[i] == 1 then
						love.graphics.setColor(v.colors[1])
					else
						love.graphics.setColor(1, 1, 1)
					end
					if v.graphic == v.biggraphic or v.animationstate == "grow" then
						love.graphics.draw(bighat[v.hats[i]].graphic, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd)
						yadd = yadd + bighat[v.hats[i]].height
					else
						local debugtable = {x, v.offsetX, y, v.offsetY, v.quadcenterX, hat[v.hats[i]].x, offsets[1], v.quadcenterY, hat[v.hats[i]].y, offsets[2], yadd}
						--TIMETRIAL
						for i, v in pairs(debugtable) do
							if type(v) == "table" then
								return
							end
						end
						
						love.graphics.draw(hat[v.hats[i]].graphic, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - hat[v.hats[i]].x + offsets[1], v.quadcenterY - hat[v.hats[i]].y + offsets[2] + yadd)
						yadd = yadd + hat[v.hats[i]].height
					end
				end
			end
		end
	end
	
	if type(v.graphic) == "table" then
		if v.graphic[0] then
			love.graphics.setColor(1, 1, 1)
			love.graphics.drawq(v.graphic[0], v.quad, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
		end
		if v.graphic.dot then
			love.graphics.setColor(unpack(v["portal" .. v.lastportal .. "color"]))
			love.graphics.drawq(v.graphic["dot"], v.quad, math.floor((x+v.offsetX)*scale), math.floor((y-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
		end	
	end
end

function reachedx(currentx)
	if not currentx or currentx <= lastrepeat+width then
		return
	end
	
	lastrepeat = math.floor(currentx)-width
	--castlerepeat?
	--get mazei
	local mazei = 0
	
	for j = 1, #mazeends do
		if mazeends[j] < currentx then
			mazei = j
		end
	end
	
	--check if maze was solved!
	for i = 1, players do
		if objects["player"][i].mazevar == mazegates[mazei] then
			local actualmaze = 0
			for j = 1, #mazestarts do
				if objects["player"][i].x > mazestarts[j] then
					actualmaze = j
				end
			end
			mazesolved[actualmaze] = true
			for j = 1, players do
				objects["player"][j].mazevar = 0
			end
			break
		end
	end
	
	if not mazesolved[mazei] or mazeinprogress then --get if inside maze
		if not mazesolved[mazei] then
			mazeinprogress = true
		end
		
		local x = math.ceil(currentx)
		
		if repeatX == 0 then
			repeatX = mazestarts[mazei]
		end
		
		table.insert(map, x, {{1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}})
		table.insert(coinmap, x, {})
		for y = 1, mapheight do
			for j = 1, #map[repeatX][y] do
				map[x][y][j] = map[repeatX][y][j]
				coinmap[x][y] = coinmap[repeatX][y]
			end
			map[x][y]["gels"] = {}
			map[x][y]["portaloverride"] = {}
			
			for cox = mapwidth, x, -1 do
				--move objects
				if objects["tile"][cox .. "-" .. y] then
					objects["tile"][cox + 1 .. "-" .. y] = tile:new(cox, y-1)
					objects["tile"][cox .. "-" .. y] = nil
				end
			end
			
			--create object for block
			if tilequads[map[repeatX][y][1]]:getproperty("collision", repeatX, y) then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
			end
		end
		mapwidth = mapwidth + 1
		repeatX = repeatX + 1
		if flagx then
			flagx = flagx + 1
			flagimgx = flagimgx + 1
			objects["screenboundary"]["flag"].x = objects["screenboundary"]["flag"].x + 1
		end
		
		if axex then
			axex = axex + 1
			objects["screenboundary"]["axe"].x = objects["screenboundary"]["axe"].x + 1
		end
		
		if firestartx then
			firestartx = firestartx + 1
		end
		
		objects["screenboundary"]["right"].x = objects["screenboundary"]["right"].x + 1
		
		--move mazestarts and ends
		for i = 1, #mazestarts do
			mazestarts[i] = mazestarts[i]+1
			mazeends[i] = mazeends[i]+1
		end
		
		--check for endblock
		local x = math.ceil(currentx)
		for y = 1, mapheight do
			if map[x][y][2] and entitylist[map[x][y][2]].t == "mazeend" then
				if mazesolved[mazei] then
					repeatX = mazestarts[mazei+1]
				end
				mazeinprogress = false
			end
		end
		
		--reset thingie
		
		local x = math.ceil(currentx)-1
		for y = 1, mapheight do
			if map[x][y][2] and entitylist[map[x][y][2]].t == "mazeend" then
				for j = 1, players do
					objects["player"][j].mazevar = 0
				end
			end
		end
	end
	
	--ENEMY STUFF
	--[[if editormode == false and currentx < mapwidth then
		for y = 1, mapheight do
			spawnenemy(currentx, y)
		end
		if goombaattack then
			local randomtable = {}
			for y = 1, mapheight do
				table.insert(randomtable, y)
			end
			while #randomtable > 0 do
				local rand = math.random(#randomtable)
				if tilequads[map[currentx][randomtable[rand] ][1] ]:getproperty("collision", currentx, randomtable[rand]) then
					table.remove(randomtable, rand)
				else
					table.insert(objects["goomba"], goomba:new(currentx-.5, math.random(13)))
					break
				end
			end
		end
	end--]]
end

function loadlevel(level)
	collectgarbage("collect")
	love.audio.stop()
	animationsystem_load()
	
	if replaysystem then
		for i = 1, #replaydata do
			replaytimer[i] = 0
			replayi[i] = 1
			replaychar[i] = characters.mario
		end
	end

	local sublevel = false
	if type(level) == "number" then
		sublevel = true
	end
	
	if sublevel then
		prevsublevel = mariosublevel
		mariosublevel = level
		if level ~= 0 then
			level = marioworld .. "-" .. mariolevel .. "_" .. level
		else
			level = marioworld .. "-" .. mariolevel
		end
	else
		local s = level:split("_")
		if s[2] then
			mariosublevel = tonumber(s[2])
		else
			mariosublevel = 0
		end
		prevsublevel = false
		mariotime = 400
		
		--check for checkpoint!
		if checkpointsub then
			mariosublevel = checkpointsub
			
			if checkpointsub ~= 0 then
				level = marioworld .. "-" .. mariolevel .. "_" .. checkpointsub
			else
				level = marioworld .. "-" .. mariolevel
			end
		end
	end
	
	--MISC VARS
	everyonedead = false
	levelfinished = false
	coinanimation = 1
	flagx = false
	levelfinishtype = nil
	firestartx = false
	firestarted = false
	firedelay = math.random(4)
	flyingfishdelay = 1
	flyingfishstarted = false
	flyingfishstartx = false
	flyingfishendx = false
	bulletbilldelay = 1
	bulletbillstarted = false
	bulletbillstartx = false
	bulletbillendx = false
	firetimer = firedelay
	flyingfishtimer = flyingfishdelay
	bulletbilltimer = bulletbilldelay
	axex = false
	axey = false
	lakitoendx = false
	lakitoend = false
	noupdate = false
	xscroll = 0
	repeatX = 0
	lastrepeat = 0
	ylookmodifier = 0
	displaywarpzonetext = false
	mazestarts = {}
	mazeends = {}
	mazesolved = {}
	mazesolved[0] = true
	mazeinprogress = false
	earthquake = 0
	sunrot = 0
	gelcannontimer = 0
	pausemenuselected = 1
	coinblocktimers = {}
	
	portaldelay = {}
	for i = 1, players do
		portaldelay[i] = 0
	end
	
	--class tables
	coinblockanimations = {}
	scrollingscores = {}
	scrollingtexts = {}
	portalparticles = {}
	portalprojectiles = {}
	emancipationgrills = {}
	platformspawners = {}
	rocketlaunchers = {}
	userects = {}
	blockdebristable = {}
	fireworks = {}
	seesaws = {}
	bubbles = {}
	rainbooms = {}
	emancipateanimations = {}
	emancipationfizzles = {}
	textentities = {}
	pedestals = {}
	dialogboxes = {}
	miniblocks = {}
	inventory = {}
	for i = 1, 9 do
		inventory[i] = {}
	end
	mccurrentblock = 1
	itemanimations = {}
	
	blockbouncetimer = {}
	blockbouncex = {}
	blockbouncey = {}
	blockbouncecontent = {}
	blockbouncecontent2 = {}
	warpzonenumbers = {}
	textentities = {}
	
	portals = {}
	
	objects = {}
	objects["player"] = {}
	objects["portalwall"] = {}
	objects["tile"] = {}
	objects["vine"] = {}
	objects["box"] = {}
	objects["door"] = {}
	objects["button"] = {}
	objects["groundlight"] = {}
	objects["wallindicator"] = {}
	objects["animatedtiletrigger"] = {}
	objects["delayer"] = {}
	objects["walltimer"] = {}
	objects["notgate"] = {}
	objects["rsflipflop"] = {}
	objects["orgate"] = {}
	objects["andgate"] = {}
	objects["musicentity"] = {}
	objects["enemyspawner"] = {}
	objects["squarewave"] = {}
	objects["lightbridge"] = {}
	objects["lightbridgebody"] = {}
	objects["faithplate"] = {}
	objects["laser"] = {}
	objects["laserdetector"] = {}
	objects["gel"] = {}
	objects["geldispenser"] = {}
	objects["cubedispenser"] = {}
	objects["pushbutton"] = {}
	objects["fireball"] = {}
	objects["platform"] = {}
	objects["platformspawner"] = {}
	objects["castlefire"] = {}
	objects["castlefirefire"] = {}
	objects["bowser"] = {}
	objects["spring"] = {}
	objects["seesawplatform"] = {}
	objects["ceilblocker"] = {}
	objects["funnel"] = {}
	objects["panel"] = {}
	objects["scaffold"] = {}
	objects["regiontrigger"] = {}
	objects["animationtrigger"] = {}
	objects["checkpoints"] = {}
	objects["portalent"] = {}
	objects["actionblock"] = {}
	
	--!
	objects["enemy"] = {}
	
	xscroll = 0
	yscroll = 0
	ylookmodifier = 0
	
	startx = {3, 3, 3, 3, 3}
	starty = {13, 13, 13, 13, 13}
	pipestartx = nil
	pipestarty = nil
	local animation = nil
	
	enemiesspawned = {}
	
	intermission = false
	haswarpzone = false
	underwater = false
	bonusstage = false
	custombackground = false
	customforeground = false
	mariotimelimit = 400
	spriteset = 1
	
	--LOAD THE MAP
	if loadmap(level, true) == false then --make one up
		mapwidth = width
		background = {unpack(backgroundcolor[1])}
		mapheight = 15
		portalsavailable = {true, true}
		musicname = "overworld.ogg"
		map = {}
		coinmap = {}
		for x = 1, width do
			map[x] = {}
			coinmap[x] = {}
			for y = 1, mapheight do
				if y > 13 then
					map[x][y] = {2}
					objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
					map[x][y]["gels"] = {}
					map[x][y]["portaloverride"] = {}
				else
					map[x][y] = {1}
					map[x][y]["gels"] = {}
					map[x][y]["portaloverride"] = {}
				end
			end
		end
		
		
		smbspritebatch = love.graphics.newSpriteBatch( smbtilesimg, 10000 )
		smbspritebatchfront = love.graphics.newSpriteBatch( smbtilesimg, 10000 )
		portalspritebatch = love.graphics.newSpriteBatch( portaltilesimg, 10000 )
		portalspritebatchfront = love.graphics.newSpriteBatch( portaltilesimg, 10000 )
		if customtiles then
			customspritebatch = love.graphics.newSpriteBatch( customtilesimg, 10000 )
			customspritebatchfront = love.graphics.newSpriteBatch( customtilesimg, 10000 )
		end
		spritebatchX = {}
		spritebatchY = {}
	end
	
	
	enemies_load()
	
	objects["screenboundary"] = {}
	objects["screenboundary"]["left"] = screenboundary:new(0)
	
	objects["screenboundary"]["right"] = screenboundary:new(mapwidth)
	
	if flagx then
		objects["screenboundary"]["flag"] = screenboundary:new(flagx+6/16)
	end
	
	if axex then
		objects["screenboundary"]["axe"] = screenboundary:new(axex)
	end
	
	if intermission then
		animation = "intermission"
	end
	
	if not sublevel then
		mariotime = mariotimelimit
	end
	
	--Maze setup
	--check every block between every start/end pair to see how many gates it contains
	if #mazestarts == #mazeends then
		mazegates = {}
		for i = 1, #mazestarts do
			local maxgate = 1
			for x = mazestarts[i], mazeends[i] do
				for y = 1, mapheight do
					if map[x][y][2] and entitylist[map[x][y][2]] and entitylist[map[x][y][2]].t == "mazegate" then
						if tonumber(map[x][y][3]) > maxgate then
							maxgate = tonumber(map[x][y][3])
						end
					end
				end
			end
			mazegates[i] = maxgate
		end
	else
		print("Mazenumber doesn't fit!")
	end
	
	--check if it's a bonusstage (boooooooonus!)
	if bonusstage then
		animation = "vinestart"
	end
		
	--set startx to pipestart
	if pipestartx then
		startx = {pipestartx-1, pipestartx-1, pipestartx-1, pipestartx-1, pipestartx-1}
		starty = {pipestarty, pipestarty, pipestarty, pipestarty, pipestarty}
		--check if startpos is a colliding block
		if tilequads[map[startx[1]][starty[1]][1]]:getproperty("collision", startx[1], starty[1]) then
			animation = "pipeup"
		end
	end
	
	--set starts to checkpoint
	if not sublevel and checkpointsub then
		for i = 1, 5 do
			if checkpointx[i] then
				startx[i] = checkpointx[i]
			end
			if checkpointy[i] then
				starty[i] = checkpointy[i]
			end
		end
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
	
	spawnrestrictions = {}
	
	--Clear spawn area from enemies
	for i = 1, #startx do
		if startx[i] == checkpointx[i] and starty[i] == checkpointy[i] then
			table.insert(spawnrestrictions, {startx[i], starty[i]})
		end
	end
	
	--add the players
	local mul = 0.5
	if mariosublevel ~= 0 or prevsublevel ~= false then
		mul = 2/16
	end
	
	objects["player"] = {}
	local spawns = {}
	for i = 1, players do
		local animation = animation
		
		local astartx, astarty
		if i > 4 then
			astartx = startx[5]
			astarty = starty[5]
		else
			astartx = startx[i]
			astarty = starty[i]
		end
		
		if astartx then
			local add = -6/16
			for j, v in pairs(spawns) do
				if v.x == astartx and v.y == astarty then
					add = add + mul
				end
			end
			
			table.insert(spawns, {x=astartx, y=astarty})
			
			objects["player"][i] = mario:new(astartx+add, astarty-1, i, animation, mariosizes[i], playertype)
		else
			objects["player"][i] = mario:new(1.5 + (i-1)*mul-6/16+1.5, 13, i, animation, mariosizes[i], playertype)
		end
	end
	
	--ADD ENEMIES ON START SCREEN
	if editormode == false then
		local xtodo = width+1
		if mapwidth < width+1 then
			xtodo = mapwidth
		end
		
		local ytodo = height+1
		if mapheight < height+1 then
			ytodo = mapheight
		end
			
		for x = math.floor(xscroll), math.floor(xscroll)+xtodo do
			for y = math.floor(yscroll), math.floor(yscroll)+ytodo do
				spawnenemy(x, y)
			end
		end
	end
	
	--load editor
	editor_load()
	
	updateranges()
	
	generatespritebatch()
end

function startlevel(levelstart)
	gamestate = "game"
	skipupdate = true
	
	--background
	love.graphics.setBackgroundColor(unpack(background))
	
	--PLAY BGM
	if intermission == false then
		playmusic()
	else
		playsound("intermission")
	end
	
	if replaysystem and levelstart then
		livereplaydata = {{}}
		livereplaydelay = {0}
		livereplaystored = {{}}
	end
end

function loadmap(filename, createobjects)
	print("**************************" .. string.rep("*", #(mappack .. filename)))
	print("* Loading mappacks/" .. mappack .. "/" .. filename .. ".txt *")
	if not love.filesystem.getInfo("mappacks/" .. mappack .. "/" .. filename .. ".txt") then
		print("mappacks/" .. mappack .. "/" .. filename .. ".txt not found!")
		return false
	end
	local s = love.filesystem.read( "mappacks/" .. mappack .. "/" .. filename .. ".txt" )
	
	local v = string.match(s, BLOCKDELIMITER[1]) and 1 or 2
	
	local blockdelimiter = BLOCKDELIMITER[v]
	local layerdelimiter = LAYERDELIMITER[v]
	local categorydelimiter = CATEGORYDELIMITER[v]
	local multipledelimiter = MULTIPLYDELIMITER[v]
	local equalsign = EQUALSIGN[v]
	
	local s2 = s:split(categorydelimiter)
	
	local t
	if string.find(s2[1], blockdelimiter) then
		mapheight = 15
		t = s2[1]:split(blockdelimiter)
	else
		mapheight = tonumber(s2[1])
		t = s2[2]:split(blockdelimiter)
	end
	
	map = {}
	unstatics = {}
	
	smbspritebatch = love.graphics.newSpriteBatch( smbtilesimg, 10000 )
	smbspritebatchfront = love.graphics.newSpriteBatch( smbtilesimg, 10000 )
	portalspritebatch = love.graphics.newSpriteBatch( portaltilesimg, 10000 )
	portalspritebatchfront = love.graphics.newSpriteBatch( portaltilesimg, 10000 )
	if customtiles then
		customspritebatch = love.graphics.newSpriteBatch( customtilesimg, 10000 )
		customspritebatchfront = love.graphics.newSpriteBatch( customtilesimg, 10000 )
	end
	spritebatchX = {}
	spritebatchY = {}
	
	--get mapwidth
	local entries = 0
	for i = 1, #t do
		local s = t[i]:split(multipledelimiter)
		if s[2] then
			entries = entries + tonumber(s[2])
		else
			entries = entries + 1
		end
	end
	
	mapheight = mapheight or 15
	if math.mod(entries, mapheight) ~= 0 then
		print("Incorrect number of entries: " .. #t)
		return false
	end
	
	mapwidth = entries/mapheight
	coinmap = {}
	
	for x = 1, mapwidth do
		map[x] = {}
		coinmap[x] = {}
		for y = 1, mapheight do
			map[x][y] = {}
			map[x][y]["gels"] = {}
			map[x][y]["portaloverride"] = {}
		end
	end
	
	local x, y = 1, 1
	for i = 1, #t do
		if string.find(t[i], multipledelimiter) then --new stuff!
			local r = tostring(t[i]):split(multipledelimiter)
			
			local coin = false
			if string.sub(r[1], -1) == "c" then
				r[1] = string.sub(r[1], 1, -2)
				coin = true
			end
			
			for j = 1, tonumber(r[2]) do
				if coin then
					coinmap[x][y] = true
				end
			
				if (tonumber(r[1]) > smbtilecount+portaltilecount+customtilecount and tonumber(r[1]) <= 10000) or tonumber(r[1]) > 10000+animatedtilecount then
					r[1] = 1
				end
				
				map[x][y][1] = tonumber(r[1])
				
			
				--create object for block
				if createobjects and tilequads[tonumber(r[1])]:getproperty("collision", x, y) == true then
					objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
				end
				
				x = x + 1
				if x > mapwidth then
					x = 1
					y = y + 1
				end
			end
			
		else --Old stuff.
			local r = tostring(t[i]):split(layerdelimiter)
			
			if string.sub(r[1], -1) == "c" then
				r[1] = string.sub(r[1], 1, -2)
				coinmap[x][y] = true
			end
			
			if (tonumber(r[1]) > smbtilecount+portaltilecount+customtilecount and tonumber(r[1]) <= 10000) or tonumber(r[1]) > 10000+animatedtilecount then
				r[1] = 1
			end
			
			for i = 1, #r do
				if tonumber(r[i]) then
					map[x][y][i] = tonumber(r[i])
				else
					map[x][y][i] = r[i]
				end
			end
			
			--create object for block
			if createobjects and tilequads[tonumber(r[1])]:getproperty("collision", x, y) == true then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
			end
			
			x = x + 1
			if x > mapwidth then
				x = 1
				y = y + 1
			end
		end
	end
	
	--ANIMATED TIMERS
	animatedtimers = {}
	for x = 1, mapwidth do
		animatedtimers[x] = {}
	end

	for i = 1, #animatedtiles do
		if animatedtiles[i].cache then
			animatedtiles[i].cache = {}
		end
	end
	
	for y = 1, mapheight do
		for x = 1, mapwidth do
			local r = map[x][y]
			
			if r[1] > 10000 then
				if tilequads[r[1]].triggered then
					animatedtimers[x][y] = animatedtimer:new(x, y, r[1])
				elseif tilequads[r[1]].cache then
					table.insert(tilequads[r[1]].cache, {x=x,y=y})
				end
			end
			
			if tilequads[r[1] ]:getproperty("coin", x, y) then
				coinmap[x][y] = true
			end
			
			if #r > 1 then 
				if entitylist[r[2]] then
					local t = entitylist[r[2]].t
					
					if t == "spawn" then
						local r2 = {unpack(r)}
						table.remove(r2, 1)
						table.remove(r2, 1)
						
						--compatibility for Mari0
						if #r2 == 0 then
							startx = {x, x, x, x, x}
							starty = {y, y, y, y, y}
						else
							if r2[1] == "true" then --all
								startx = {x, x, x, x, x}
								starty = {y, y, y, y, y}
							else
								for i = 1, 5 do
									if r2[i+1] == "true" then
										startx[i] = x
										starty[i] = y
									end
								end
							end
						end
						
					elseif t == "textentity" and not editormode then
						table.insert(textentities, textentity:new(x-1, y-1, r))
						
					elseif createobjects and not editormode then
						if t == "warppipe" then
							table.insert(warpzonenumbers, {x, y, r[3]})
							
						elseif t == "manycoins" then
							map[x][y][3] = 7
							
						elseif t == "flag" then
							flagx = x-1
							flagy = y
							
						elseif t == "firestart" then
							firestartx = x
							
						elseif t == "flyingfishstart" then
							flyingfishstartx = x
						elseif t == "flyingfishend" then
							flyingfishendx = x
							
						elseif t == "bulletbillstart" then
							bulletbillstartx = x
						elseif t == "bulletbillend" then
							bulletbillendx = x
							
						elseif t == "axe" then
							axex = x
							axey = y
						
						elseif t == "lakitoend" then
							lakitoendx = x
							
						elseif t == "pipespawn" and (prevsublevel == r[3]-1 or (mariosublevel == r[3]-1 and blacktime == sublevelscreentime)) then
							pipestartx = x
							pipestarty = y
							
						elseif t == "gel" then
							if tilequads[map[x][y][1]]:getproperty("collision", x, y) then
								if r[4] == "true" then
									map[x][y]["gels"]["left"] = r[3]
								end
								if r[5] == "true" then
									map[x][y]["gels"]["top"] = r[3]
								end
								if r[6] == "true" then
									map[x][y]["gels"]["right"] = r[3]
								end
								if r[7] == "true" then
									map[x][y]["gels"]["bottom"] = r[3]
								end
							end
							
						elseif t == "checkpoint" then
							table.insert(objects["checkpoints"], checkpoint:new(x, y, r))
						elseif t == "mazestart" then
							if not tablecontains(mazestarts, x) then
								table.insert(mazestarts, x)
							end
							
						elseif t == "mazeend" then
							if not tablecontains(mazeends, x) then
								table.insert(mazeends, x)
							end
							
						elseif t == "emance" then
							table.insert(emancipationgrills, emancipationgrill:new(x, y, r))
							
						elseif t == "door" then
							table.insert(objects["door"], door:new(x, y, r))
							
						elseif t == "button" then
							table.insert(objects["button"], button:new(x, y, r))
							
						elseif t == "pushbutton" then
							table.insert(objects["pushbutton"], pushbutton:new(x, y, r))
							
						elseif t == "wallindicator" then
							table.insert(objects["wallindicator"], wallindicator:new(x, y, r))
							
						elseif t == "groundlightver" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 1, r))
						elseif t == "groundlighthor" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 2, r))
						elseif t == "groundlightupright" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 3, r))
						elseif t == "groundlightrightdown" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 4, r))
						elseif t == "groundlightdownleft" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 5, r))
						elseif t == "groundlightleftup" then
							table.insert(objects["groundlight"], groundlight:new(x, y, 6, r))
							
						elseif t == "faithplate" then
							table.insert(objects["faithplate"], faithplate:new(x, y, r))
							
						elseif t == "laser" then
							table.insert(objects["laser"], laser:new(x, y, r))
							
						elseif t == "lightbridge" then
							table.insert(objects["lightbridge"], lightbridge:new(x, y, r))
							
						elseif t == "laserdetector" then
							table.insert(objects["laserdetector"], laserdetector:new(x, y, r))
							
						elseif t == "boxtube" then
							table.insert(objects["cubedispenser"], cubedispenser:new(x, y, r))
						
						elseif t == "walltimer" then
							table.insert(objects["walltimer"], walltimer:new(x, y, r))
							
						elseif t == "notgate" then
							table.insert(objects["notgate"], notgate:new(x, y, r))
							
						elseif t == "rsflipflop" then
							table.insert(objects["rsflipflop"], rsflipflop:new(x, y, r))
							
						elseif t == "orgate" then
							table.insert(objects["orgate"], orgate:new(x, y, r))
							
						elseif t == "andgate" then
							table.insert(objects["andgate"], andgate:new(x, y, r))
							
						elseif t == "musicentity" then
							table.insert(objects["musicentity"], musicentity:new(x, y, r))
							
						elseif t == "enemyspawner" then
							table.insert(objects["enemyspawner"], enemyspawner:new(x, y, r))
							
						elseif t == "squarewave" then
							table.insert(objects["squarewave"], squarewave:new(x, y, r))
							
						elseif t == "platformspawner" then
							table.insert(platformspawners, platformspawner:new(x, y, r))
							
						elseif t == "scaffold" then
							table.insert(objects["scaffold"], scaffold:new(x, y, r))
							
						elseif t == "box" then
							table.insert(objects["box"], box:new(x, y))
							
						elseif t == "portal1" then
							table.insert(objects["portalent"], portalent:new(x, y, 1, r))
							
						elseif t == "portal2" then
							table.insert(objects["portalent"], portalent:new(x, y, 2, r))
							
						elseif t == "spring" then
							table.insert(objects["spring"], spring:new(x, y))
							
						elseif t == "seesaw" then
							table.insert(seesaws, seesaw:new(x, y, r))
						
						elseif t == "ceilblocker" then
							table.insert(objects["ceilblocker"], ceilblocker:new(x))
							
						elseif t == "funnel" then
							table.insert(objects["funnel"], funnel:new(x, y, r))
							
						elseif t == "regiontrigger" then
							table.insert(objects["regiontrigger"], regiontrigger:new(x, y, r))
							
						elseif t == "animationtrigger" then
							table.insert(objects["animationtrigger"], animationtrigger:new(x, y, r))
							
						elseif t == "pedestal" then
							table.insert(pedestals, pedestal:new(x, y, r))
							
						elseif t == "actionblock" then
							table.insert(objects["actionblock"], actionblock:new(x, y, r))
							
						elseif t == "animatedtiletrigger" then
							table.insert(objects["animatedtiletrigger"], animatedtiletrigger:new(x, y, r))
							
						elseif t == "delayer" then
							table.insert(objects["delayer"], delayer:new(x, y, r))
							
						end
					end
				end
			end
		end
	end
	
	if createobjects then
		--Add links
		for i, v in pairs(objects) do
			for j, w in pairs(v) do
				if w.link then
					w:link()
				end
			end
		end
		
		--emancipation links
		for i, v in pairs(emancipationgrills) do
			v:link()
		end
		
		--textlinks
		for i, v in pairs(textentities) do
			v:link()
		end
	end
	
	if flagx then
		flagimgx = flagx+8/16
		flagimgy = flagy-10+1/16
	end
	
	for x = 0, -30, -1 do
		map[x] = {}
		for y = 1, mapheight-2 do
			map[x][y] = {1}
		end
		
		for y = mapheight-1, mapheight do
			map[x][y] = {2}
			if createobjects then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
			end
		end
	end
	
	--background
	background = {unpack(backgroundcolor[1])}
	custombackground = false
	
	--portalgun
	portalsavailable = {true, true}
	
	levelscreenback = nil
	levelscreenbackname = nil
	
	--MORE STUFF
	for i = 3, #s2 do
		s3 = s2[i]:split(equalsign)
		if s3[1] == "backgroundr" then
			background[1] = tonumber(s3[2]) / 255
		elseif s3[1] == "backgroundg" then
			background[2] = tonumber(s3[2]) / 255
		elseif s3[1] == "backgroundb" then
			background[3] = tonumber(s3[2]) / 255
		elseif s3[1] == "background" then
			background = {unpack(backgroundcolor[tonumber(s3[2])])}
		elseif s3[1] == "spriteset" then
			spriteset = tonumber(s3[2])
		elseif s3[1] == "intermission" then
			intermission = true
		elseif s3[1] == "haswarpzone" then
			haswarpzone = true
		elseif s3[1] == "underwater" then
			underwater = true
		elseif s3[1] == "music" then
			if tonumber(s3[2]) then
				local i = tonumber(s3[2])
				musicname = musiclist[i]
			else
				musicname = s3[2]
			end
		elseif s3[1] == "bonusstage" then
			bonusstage = true
		elseif s3[1] == "custombackground" or s3[1] == "portalbackground" then
			custombackground = true
			if s3[2] and custombackgroundimg[s3[2]] then
				custombackground = s3[2]
			end
		elseif s3[1] == "customforeground" then
			customforeground = true
			if s3[2] and custombackgroundimg[s3[2]] then
				customforeground = s3[2]
			end
		elseif s3[1] == "timelimit" then
			mariotimelimit = tonumber(s3[2])
		elseif s3[1] == "scrollfactor" then
			scrollfactor = tonumber(s3[2])
		elseif s3[1] == "fscrollfactor" then
			fscrollfactor = tonumber(s3[2])
		elseif s3[1] == "portalgun" then
			if s3[2] == "none" then
				portalsavailable = {false, false}
			elseif s3[2] == "blue" then
				portalsavailable = {true, false}
			elseif s3[2] == "orange" then
				portalsavailable = {false, true}
			end
		elseif s3[1] == "levelscreenback" then
			if love.filesystem.getInfo("mappacks/" .. mappack .. "/levelscreens/" .. s3[2] .. ".png") then
				levelscreenbackname = s3[2]
				levelscreenback = {}
				levelscreenback = love.graphics.newImage("mappacks/" .. mappack .. "/levelscreens/" .. s3[2] .. ".png")
			end
		end
	end
	
	print("* DONE!" .. string.rep(" ", #(mappack .. filename)+17) .. " *")
	print("**************************" .. string.rep("*", #(mappack .. filename)))
	return true
end

function changemapwidth(width)
	if width > mapwidth then
		for x = mapwidth+1, width do
			map[x] = {}
			for y = 1, mapheight-2 do
				map[x][y] = {1}
				map[x][y].gels = {}
				map[x][y].portaloverride = {}
				objects["tile"][x .. "-" .. y] = nil
			end
		
			for y = mapheight-1, mapheight do
				map[x][y] = {2}
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
				map[x][y].gels = {}
				map[x][y].portaloverride = {}
			end
		end
	end

	mapwidth = width
	objects["screenboundary"]["right"].x = mapwidth
	
	if objects["player"][1].x > mapwidth then
		objects["player"][1].x = mapwidth-1
	end
	
	generatespritebatch()
end

function changemapheight(height)
	if height > mapheight then
		for x = 1, mapwidth do
			for y = mapheight+1, height do
				map[x][y] = {currenttile}
				map[x][y].gels = {}
				map[x][y].portaloverride = {}
				
				if tilequads[currenttile]:getproperty("collision", x, y) then
					objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
				else
					objects["tile"][x .. "-" .. y] = nil
				end			
			end
		end
	end
	
	mapheight = height
	
	for i, v in pairs(objects["screenboundary"]) do
		v.height = 1000+mapheight
	end
	
	if objects["player"][1].y > mapheight then
		objects["player"][1].y = mapheight-1
	end
	
	generatespritebatch()
end

function generatespritebatch()
	smbspritebatch:clear()
	smbspritebatchfront:clear()
	if loveVersion <= 9 then
		smbspritebatch:bind()
		smbspritebatchfront:bind()
	end
	
	portalspritebatch:clear()
	portalspritebatchfront:clear()
	if loveVersion <= 9 then
		portalspritebatch:bind()
		portalspritebatchfront:bind()
	end
	
	if customtiles then
		customspritebatch:clear()
		customspritebatchfront:clear()
		if loveVersion <= 9 then
			customspritebatch:bind()
			customspritebatchfront:bind()
		end
	end
	
	
	local xtodraw
	if mapwidth < width+1 then
		xtodraw = math.ceil(mapwidth)
	else
		if mapwidth > width and xscroll < mapwidth-width then
			xtodraw = math.ceil(width+1)
		else
			xtodraw = math.ceil(width)
		end
	end
	
	local ytodraw
	if mapheight < height+1 then
		ytodraw = math.ceil(mapheight)
	else
		if mapheight > height and yscroll < mapheight-height then
			ytodraw = height+1
		else
			ytodraw = height
		end
	end
	
	local lmap = map
	
	local flooredxscroll
	if xscroll >= 0 then
		flooredxscroll = math.floor(xscroll)
	else
		flooredxscroll = math.ceil(xscroll)
	end
	
	local flooredyscroll
	if yscroll >= 0 then
		flooredyscroll = math.floor(yscroll)
	else
		flooredyscroll = math.ceil(yscroll)
	end
	
	for y = 0, ytodraw+1 do
		for x = 1, xtodraw do
			if inmap(flooredxscroll+x, math.min(flooredyscroll+y+1, mapheight)) then
				local bounceyoffset = 0
				
				local draw = true
				for i, v in pairs(blockbouncex) do
					if blockbouncex[i] == flooredxscroll+x and blockbouncey[i] == math.min(flooredyscroll+y+1, mapheight) then
						draw = false
					end
				end	
				if draw == true then
					local cox, coy = flooredxscroll+x, math.min(flooredyscroll+y+1, mapheight)
					local t = lmap[cox][coy]
					
					local tilenumber = t[1]
					
					if not tilequads[tilenumber]:getproperty("foreground", cox, coy) then
						if tilenumber ~= 0 and tilequads[tilenumber]:getproperty("invisible", cox, coy) == false and tilequads[tilenumber]:getproperty("coinblock", cox, coy) == false then
							if loveVersion < 9 then
								if tilenumber <= smbtilecount then
									smbspritebatch:addq( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								elseif tilenumber <= smbtilecount+portaltilecount then
									portalspritebatch:addq( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								elseif tilenumber <= smbtilecount+portaltilecount+customtilecount then
									customspritebatch:addq( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								end
							else
								if tilenumber <= smbtilecount then
									smbspritebatch:add( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								elseif tilenumber <= smbtilecount+portaltilecount then
									portalspritebatch:add( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								elseif tilenumber <= smbtilecount+portaltilecount+customtilecount then
									customspritebatch:add( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								end
							end
						end
					else
						if tilenumber ~= 0 and tilequads[tilenumber]:getproperty("invisible", cox, coy) == false and tilequads[tilenumber]:getproperty("coinblock", cox, coy) == false then
							if loveVersion < 9 then
								if tilenumber <= smbtilecount then
									smbspritebatchfront:addq( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								elseif tilenumber <= smbtilecount+portaltilecount then
									portalspritebatchfront:addq( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								elseif tilenumber <= smbtilecount+portaltilecount+customtilecount then
									customspritebatchfront:addq( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								end
							else
								if tilenumber <= smbtilecount then
									smbspritebatchfront:add( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								elseif tilenumber <= smbtilecount+portaltilecount then
									portalspritebatchfront:add( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								elseif tilenumber <= smbtilecount+portaltilecount+customtilecount then
									customspritebatchfront:add( tilequads[tilenumber]:quad(), (x-1)*16*scale, ((y)*16-8)*scale, 0, scale, scale )
								end
							end
						end
					end
				end
			end
		end
	end
	
	--Unbind spritebatches
	if loveVersion <= 9 then
		smbspritebatch:unbind()
		smbspritebatchfront:unbind()
		
		portalspritebatch:unbind()
		portalspritebatchfront:unbind()
		
		if customtiles then
			customspritebatch:unbind()
			customspritebatchfront:unbind()
		end
	end
end

function game_keypressed(key)
	if key == "return" then
		game_joystickpressed(1, 4)
	end
	
	if key == "f" and debugbinds then
		objects["player"][1]:grow()
	end

	if pausemenuopen then
		if menuprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					love.audio.stop()
					pausemenuopen = false
					saveconfig()
					menuprompt = false
					menu_load()
				else
					menuprompt = false
				end
			elseif key == "escape" then
				menuprompt = false
			end
			return
		elseif desktopprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					love.audio.stop()
					love.event.quit()
				else
					desktopprompt = false
				end
			elseif key == "escape" then
				desktopprompt = false
			end
			return
		elseif suspendprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					love.audio.stop()
					suspendgame()
					suspendprompt = false
					pausemenuopen = false
					saveconfig()
				else
					suspendprompt = false
				end
			elseif key == "escape" then
				suspendprompt = false
			end
			return
		end
		if (key == "down" or key == "s") then
			if pausemenuselected < #pausemenuoptions then
				pausemenuselected = pausemenuselected + 1
			end
		elseif (key == "up" or key == "w") then
			if pausemenuselected > 1 then
				pausemenuselected = pausemenuselected - 1
			end
		elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
			if pausemenuoptions[pausemenuselected] == "resume" then
				pausemenuopen = false
				saveconfig()
				if loveVersion >= 11 then
					love.audio.play(paused)
				else
					love.audio.resume()
				end
			elseif pausemenuoptions[pausemenuselected] == "suspend" then
				suspendprompt = true
				pausemenuselected2 = 1
			elseif pausemenuoptions2[pausemenuselected] == "menu" then
				menuprompt = true
				pausemenuselected2 = 1
			elseif pausemenuoptions2[pausemenuselected] == "desktop" then
				desktopprompt = true
				pausemenuselected2 = 1
			end
		elseif key == "escape" then
			pausemenuopen = false
			saveconfig()
			if loveVersion >= 11 then
				love.audio.play(paused)
			else
				love.audio.resume()
			end
		elseif (key == "right" or key == "d") then
			if pausemenuoptions[pausemenuselected] == "music volume" then
				volumemusic = math.min(1, volumemusic + 0.1)
				love.audio.setVolume( volumesfx )
				music:setVolume( volumemusic )
			elseif pausemenuoptions[pausemenuselected] == "game volume" then
				volumesfx = math.min(1, volumesfx + 0.1)
				love.audio.setVolume( volumesfx )
				music:setVolume( volumemusic )
				soundenabled = true
				playsound("coin")
			end
			
		elseif (key == "left" or key == "a") then
			if pausemenuoptions[pausemenuselected] == "music volume" then
				volumemusic = math.max(volumemusic - 0.1, 0)
				love.audio.setVolume( volumesfx )
				music:setVolume( volumemusic )
			elseif pausemenuoptions[pausemenuselected] == "game volume" then
				volumesfx = math.max(volumesfx - 0.1, 0)
				love.audio.setVolume( volumesfx )
				music:setVolume( volumemusic )
				if volumesfx == 0 then
					soundenabled = false
				end
				playsound("coin")
			end
		end
			
		return
	end
	
	if endpressbutton then
		endpressbutton = false
		endgame()
		return
	end

	for i = 1, players do
		if controls[i]["jump"][1] == key then
			objects["player"][i]:jump()
		elseif controls[i]["run"][1] == key then
			objects["player"][i]:fire()
		elseif controls[i]["reload"][1] == key then
			objects["player"][i]:removeportals()
		elseif controls[i]["use"][1] == key then
			objects["player"][i]:use()
		elseif controls[i]["left"][1] == key then
			objects["player"][i]:leftkey()
		elseif controls[i]["right"][1] == key then
			objects["player"][i]:rightkey()
		end
		
		if controls[i]["portal1"][i] == key then
			shootportal(i, 1, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
			return
		end
		
		if controls[i]["portal2"][i] == key then
			shootportal(i, 2, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
			return
		end
	end
	
	if key == "escape" then
		if not editormode and testlevel then
			checkpointsub = false
			marioworld = testlevelworld
			mariolevel = testlevellevel
			testlevel = false
			editormode = true
			xpan = false
			ypan = false
			
			if mariosublevel > 0 then
				loadlevel(marioworld .. "-" .. mariolevel .. "_" .. mariosublevel)
			else
				loadlevel(marioworld .. "-" .. mariolevel)
			end
			startlevel()
			return
		elseif not editormode and not everyonedead then
			pausemenuopen = true
			paused = love.audio.pause()
			playsound("pause")
		end
	end
	
	if key == "t" and editordebug then
		editormode = not editormode
	end
	
	if editormode then
		editor_keypressed(key)
	end
end

function game_keyreleased(key)
	for i = 1, players do
		if controls[i]["jump"][1] == key then
			objects["player"][i]:stopjump()
		end
	end
end

function game_textinput(text)
	if editormode and not testlevel then
		editor_textinput(text)
	end
end

function shootportal(plnumber, i, sourcex, sourcey, direction, mirrored, bounces)
	if objects["player"][plnumber].portalgundisabled then
		return
	end
	
	--check if available
	if not objects["player"][plnumber].portalsavailable[i] then
		return
	end
	
	--box
	if objects["player"][plnumber].pickup then
		return
	end
	--portalgun delay
	if portaldelay[plnumber] > 0 then
		return
	else
		portaldelay[plnumber] = portalgundelay
	end
	
	local otheri = 1
	local color = objects["player"][plnumber].portal2color
	if i == 1 then
		otheri = 2
		color = objects["player"][plnumber].portal1color
	end
	
	if not mirrored then
		objects["player"][plnumber].lastportal = i
	end
	local cox, coy, side, tendency, x, y = traceline(sourcex, sourcey, direction)
	
	local mirror = false
	if cox and tilequads[map[cox][coy][1]]:getproperty("mirror", cox, coy) then
		mirror = true
	end
	
	objects["player"][plnumber].lastportal = i
	
	table.insert(portalprojectiles, portalprojectile:new(sourcex, sourcey, x, y, color, true, {objects["player"][plnumber].portal, i, cox, coy, side, tendency, x, y}, mirror, mirrored, bounces))
end

function game_mousepressed(x, y, button)
	if pausemenuopen then
		return
	end
	
	if frameskip then
		if button == "wu" then
			frameskip = math.max(0, frameskip - 1)
			return
		elseif button == "wd" then
			frameskip = frameskip + 1
			return
		end
	end
	
	if editormode then
		editor_mousepressed(x, y, button)
	else
		if editormode then
			editor_mousepressed(x, y, button)
		end
		
		if not noupdate and objects["player"][mouseowner] and objects["player"][mouseowner].controlsenabled and objects["player"][mouseowner].vine == false then
		
			if button == "l" or button == "r" and objects["player"][mouseowner] then
				--knockback
				if portalknockback then
					local xadd = math.sin(objects["player"][mouseowner].pointingangle)*30
					local yadd = math.cos(objects["player"][mouseowner].pointingangle)*30
					objects["player"][mouseowner].speedx = objects["player"][mouseowner].speedx + xadd
					objects["player"][mouseowner].speedy = objects["player"][mouseowner].speedy + yadd
					objects["player"][mouseowner].falling = true
					objects["player"][mouseowner].animationstate = "falling"
					objects["player"][mouseowner]:setquad()
				end
			end
		
			if button == "l" then
				if playertype == "portal" then
					local sourcex = objects["player"][mouseowner].x+6/16
					local sourcey = objects["player"][mouseowner].y+6/16
					local direction = objects["player"][mouseowner].pointingangle
					
					shootportal(mouseowner, 1, sourcex, sourcey, direction)
					if mkstation then
						--objects["player"][1]:use()
					end
				end
				
			elseif button == "r" then
				if playertype == "portal" then
					local sourcex = objects["player"][mouseowner].x+6/16
					local sourcey = objects["player"][mouseowner].y+6/16
					local direction = objects["player"][mouseowner].pointingangle
					
					shootportal(mouseowner, 2, sourcex, sourcey, direction)
					if mkstation then
						--objects["player"][1]:use()
					end
				end
			end
		end
			
		if button == "wd" then
			if bullettime then
				speedtarget = speedtarget - 0.1
				if speedtarget < 0.1 then
					speedtarget = 0.1
				end
			elseif speeddebug then
				speed = math.max(0, speed/2)
			end
		elseif button == "wu" then
			if bullettime then
				speedtarget = speedtarget + 0.1
				if speedtarget > 1 then
					speedtarget = 1
				end
			elseif speeddebug then
				speed = math.min(1, speed*2)
			end
		end
	end
end

function modifyportalwalls()
	--Create and remove new stuff
	for a, b in pairs(portals) do
		for i = 1, 2 do
			if b["x" .. i] then
				if b["facing" .. i] == "up" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i], b["y" .. i], 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i]+1, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i]+1, b["y" .. i]-1, 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], 1, 0, portals[a], i, "remove")
				elseif b["facing" .. i] == "down" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i]-2, b["y" .. i]-1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i]-2, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i], b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i]-2, b["y" .. i], 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i], b["y" .. i], 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], -1, 0, portals[a], i, "remove")
				elseif b["facing" .. i] == "left" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i], b["y" .. i]-2, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i], b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-2, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-2, 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], 0, -1, portals[a], i, "remove")
				elseif b["facing" .. i] == "right" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i]-1, b["y" .. i]+1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i], b["y" .. i]-1, 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i], b["y" .. i]+1, 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], 0, 1, portals[a], i, "remove")
				end
			end
		end
	end
	
	--remove conflicting portalwalls (only exist when both portals exists!)
	for a, b in pairs(portals) do
		for j = 1, 2 do
			local otherj = 1
			if j == 1 then
				otherj = 2
			end
			for c, d in pairs(portals) do
				for i = 1, 2 do
					local otheri = 1
					if i == 1 then
						otheri = 2
					end
					--B.J PORTAL WILL REMOVE WALLS OF D.OTHERJ, SO B.OTHERJ MUST EXIST
					
					if b["x" .. j] and b["x" .. otherj] and d["x" .. i] then
						local conside, conx, cony = b["facing" .. j], b["x" .. j], b["y" .. j]
						
						for k = 1, 4 do
							local w = objects["portalwall"][c .. "-" .. i .. "-" .. k]
							if w then
								if conside == "right" then
									if w.x == conx and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx and w.y == cony and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								elseif conside == "left" then
									if w.x == conx-1 and w.y == cony-2 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony-1 and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								elseif conside == "up" then
									if w.x == conx-1 and w.y == cony-1 and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx and w.y == cony-1 and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								else
									if w.x == conx-2 and w.y == cony and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function modifyportaltiles(x, y, xplus, yplus, portal, i, mode)
	if not x or not y then
		return
	end
	if i == 1 then
		if portal.facing2 ~= false then
			if mode == "add" then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
				objects["tile"][x+xplus .. "-" .. y+yplus] = tile:new(x-1+xplus, y-1+yplus)
			else
				objects["tile"][x .. "-" .. y] = nil
				objects["tile"][x+xplus .. "-" .. y+yplus] = nil
			end
		end
	else
		if portal.facing1 ~= false then
			if mode == "add" then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
				objects["tile"][x+xplus .. "-" .. y+yplus] = tile:new(x-1+xplus, y-1+yplus)
			else
				objects["tile"][x .. "-" .. y] = nil
				objects["tile"][x+xplus .. "-" .. y+yplus] = nil
			end
		end
	end
end

function getportalposition(i, x, y, side, tendency, mirexc) --returns the "optimal" position according to the parsed arguments (or false if no possible position was found)
	local xplus, yplus = 0, 0
	if side == "up" then
		yplus = -1
	elseif side == "right" then
		xplus = 1
	elseif side == "down" then
		yplus = 1
	elseif side == "left" then
		xplus = -1
	end
	if mirexc and getTile(x, y, true, true, side, nil, nil, mirexc) == "mirror" then
		return x, y, "mirror"
	end
	if side == "up" or side == "down" then
		if tendency == -1 then
			if getTile(x-1, y, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x-1, y+yplus, nil, false, side, true) == false and getTile(x, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x-1, y
				else
					return x, y
				end
			elseif getTile(x, y, true, true, side) == true and getTile(x+1, y, true, true, side) == true and getTile(x, y+yplus, nil, false, side, true) == false and getTile(x+1, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x, y
				else
					return x+1, y
				end
			end
		else
			if getTile(x, y, true, true, side) == true and getTile(x+1, y, true, true, side) == true and getTile(x, y+yplus, nil, false, side, true) == false and getTile(x+1, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x, y
				else
					return x+1, y
				end
			elseif getTile(x-1, y, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x-1, y+yplus, nil, false, side, true) == false and getTile(x, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x-1, y
				else
					return x, y
				end
			end
		end
	else
		if tendency == -1 then
			if getTile(x, y-1, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x+xplus, y-1, nil, false, side, true) == false and getTile(x+xplus, y, nil, false, side, true) == false then
				if side == "right" then
					return x, y-1
				else
					return x, y
				end
			elseif getTile(x, y, true, true, side) == true and getTile(x, y+1, true, true, side) == true and getTile(x+xplus, y, nil, false, side, true) == false and getTile(x+xplus, y+1, nil, false, side, true) == false then
				if side == "right" then
					return x, y
				else
					return x, y+1
				end
			end
		else
			if getTile(x, y, true, true, side) == true and getTile(x, y+1, true, true, side) == true and getTile(x+xplus, y, nil, false, side, true) == false and getTile(x+xplus, y+1, nil, false, side, true) == false then
				if side == "right" then
					return x, y
				else
					return x, y+1
				end
			elseif getTile(x, y-1, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x+xplus, y-1, nil, false, side, true) == false and getTile(x+xplus, y, nil, false, side, true) == false then
				if side == "right" then
					return x, y-1
				else
					return x, y
				end
			end
		end
	end
	
	return false
end

function getTile(x, y, portalable, portalcheck, facing, ignoregrates, dir, mirexc) --returns masktable value of block (As well as the ID itself as second return parameter) also includes a portalcheck and returns false if a portal is on that spot.
	if portalcheck then
		for i, v in pairs(portals) do
			--Get the extra block of each portal
			local portal1xplus, portal1yplus, portal2xplus, portal2yplus = 0, 0, 0, 0
			if v.facing1 == "up" then
				portal1xplus = 1
			elseif v.facing1 == "right" then
				portal1yplus = 1
			elseif v.facing1 == "down" then
				portal1xplus = -1
			elseif v.facing1 == "left" then
				portal1yplus = -1
			end
			
			if v.facing2 == "up" then
				portal2xplus = 1
			elseif v.facing2 == "right" then
				portal2yplus = 1
			elseif v.facing2 == "down" then
				portal2xplus = -1
			elseif v.facing2 == "left" then
				portal2yplus = -1
			end
			
			if v.x1 ~= false then
				if (x == v.x1 or x == v.x1+portal1xplus) and (y == v.y1 or y == v.y1+portal1yplus) and (facing == nil or v.facing1 == facing) then
					return false
				end
			end
		
			if v.x2 ~= false then
				if (x == v.x2 or x == v.x2+portal2xplus) and (y == v.y2 or y == v.y2+portal2yplus) and (facing == nil or v.facing2 == facing) then
					return false
				end
			end
		end
	end
	
	--check for tubes
	for i, v in pairs(objects["geldispenser"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	for i, v in pairs(objects["cubedispenser"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	--bonusstage thing for keeping it from fucking up by allowing portals to be shot next to the vine in 4-2_2 for example
	if bonusstage then
		if y == mapheight and (x == 4 or x == 6) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	if x <= 0 or y <= 0 or y >= mapheight+1 or x > mapwidth then
		return false, 1
	end
	
	if tilequads[map[x][y][1]]:getproperty("invisible", x, y) then
		return false
	end
	
	if portalcheck then
		local side
		if facing == "up" then
			side = "top"
		elseif facing == "right" then
			side = "right"
		elseif facing == "down" then
			side = "bottom"
		elseif facing == "left" then
			side = "left"
		end
		
		--To stop people from portalling under the vine, which caused problems, but was fixed elsewhere (and betterer)
		--[[for i, v in pairs(objects["vine"]) do
			if x == v.cox and y == v.coy and side == "top" then
				return false, 1
			end
		end--]]
		
		if map[x][y]["portaloverride"] and map[x][y]["portaloverride"][side] then
			return true, map[x][y][1]
		end
		
		if map[x][y]["gels"] and map[x][y]["gels"][side] == 3 then
			return true, map[x][y][1]
		elseif tilequads[map[x][y][1]]:getproperty("mirror", x, y) and mirexc then
			return "mirror"
		else
			return tilequads[map[x][y][1]]:getproperty("collision", x, y) and tilequads[map[x][y][1]]:getproperty("portalable", x, y) and tilequads[map[x][y][1]]:getproperty("grate", x, y) == false and tilequads[map[x][y][1]]:getproperty("mirror", x, y) == false, map[x][y][1]
		end
	else
		if ignoregrates then
			return tilequads[map[x][y][1]]:getproperty("collision", x, y) and tilequads[map[x][y][1]]:getproperty("grate", x, y) == false, map[x][y][1]
		else
			return tilequads[map[x][y][1]]:getproperty("collision", x, y), map[x][y][1]
		end
	end
end

function getPortal(x, y, dir) --returns the block where you'd come out when you'd go in the argument's block
	for i, v in pairs(portals) do
		if v.x1 ~= false and v.x2 ~= false then
			--Get the extra block of each portal
			local portal1xplus, portal1yplus, portal2xplus, portal2yplus = 0, 0, 0, 0
			if v.facing1 == "up" then
				portal1xplus = 1
			elseif v.facing1 == "right" then
				portal1yplus = 1
			elseif v.facing1 == "down" then
				portal1xplus = -1
			elseif v.facing1 == "left" then
				portal1yplus = -1
			end
			
			if v.facing2 == "up" then
				portal2xplus = 1
			elseif v.facing2 == "right" then
				portal2yplus = 1
			elseif v.facing2 == "down" then
				portal2xplus = -1
			elseif v.facing2 == "left" then
				portal2yplus = -1
			end
			
			if v.x1 ~= false and (not dir or v.facing1 == dir) then
				if (x == v.x1 or x == v.x1+portal1xplus) and (y == v.y1 or y == v.y1+portal1yplus) and (facing == nil or v.facing1 == facing) then
					if v.facing1 ~= v.facing2 then
						local xplus, yplus = 0, 0
						if v.facing1 == "left" or v.facing1 == "right" then
							if y == v.y1 then
								if v.facing2 == "left" or v.facing2 == "right" then
									yplus = portal2yplus
								else
									xplus = portal2xplus
								end
							end
							
							return v.x2+xplus, v.y2+yplus, v.facing2, v.facing1, v.x2, v.y2, v.x1, v.y1
						else
							if x == v.x1 then
								if v.facing2 == "left" or v.facing2 == "right" then
									yplus = portal2yplus
								else
									xplus = portal2xplus
								end
							end
							
							return v.x2+xplus, v.y2+yplus, v.facing2, v.facing1, v.x2, v.y2, v.x1, v.y1
						end	
					else
						return v.x2+(x-v.x1), v.y2+(y-v.y1), v.facing2, v.facing1, v.x2, v.y2, v.x1, v.y1
					end
				end
			end
		
			if v.x2 ~= false and (not dir or v.facing2 == dir) then
				if (x == v.x2 or x == v.x2+portal2xplus) and (y == v.y2 or y == v.y2+portal2yplus) and (facing == nil or v.facing2 == facing) then
					if v.facing1 ~= v.facing2 then
						local xplus, yplus = 0, 0
						if v.facing2 == "left" or v.facing2 == "right" then
							if y == v.y2 then
								if v.facing1 == "left" or v.facing1 == "right" then
									yplus = portal1yplus
								else
									xplus = portal1xplus
								end
							end
							
							return v.x1+xplus, v.y1+yplus, v.facing1, v.facing2, v.x1, v.y1, v.x2, v.y2
						else
							if x == v.x2 then
								if v.facing1 == "left" or v.facing1 == "right" then
									yplus = portal1yplus
								else
									xplus = portal1xplus
								end
							end
							
							return v.x1+xplus, v.y1+yplus, v.facing1, v.facing2, v.x1, v.y1, v.x2, v.y2
						end	
					else
						return v.x1+(x-v.x2), v.y1+(y-v.y2), v.facing1, v.facing2, v.x1, v.y1, v.x2, v.y2
					end
				end
			end
		end
	end
	
	return false
end

function insideportal(x, y, width, height) --returns whether an object is in, and which, portal.
	if width == nil then
		width = 12/16
	end
	if height == nil then
		height = 12/16
	end
	for i, v in pairs(portals) do
		if v.x1 ~= false and v.x2 ~= false then
			for j = 1, 2 do				
				local portalx, portaly, portalfacing
				if j == 1 then
					portalx = v.x1
					portaly = v.y1
					portalfacing = v.facing1
				else
					portalx = v.x2
					portaly = v.y2
					portalfacing = v.facing2
				end
				
				if portalfacing == "up" then
					xplus = 1
				elseif portalfacing == "down" then
					xplus = -1
				elseif portalfacing == "left" then
					yplus = -1
				end
				
				if portalfacing == "right" then
					if (math.floor(y) == portaly or math.floor(y) == portaly-1) and inrange(x, portalx-width, portalx, false) then
						return portals[i], j
					end
				elseif portalfacing == "left" then
					if (math.floor(y) == portaly-1 or math.floor(y) == portaly-2) and inrange(x, portalx-1-width, portalx-1, false) then
						return portals[i], j
					end
				elseif portalfacing == "up" then
					if inrange(y, portaly-height-1, portaly-1, false) and inrange(x, portalx-1.5-.2, portalx+.5+.2, true) then
						return portals[i], j
					end	
				elseif portalfacing == "down" then
					if inrange(y, portaly-height, portaly, false) and inrange(x, portalx-2, portalx-.5, true) then
						return portals[i], j
					end	
				end
				
				--widen rect by 3 pixels?
				
			end
		end
	end
	
	return false
end

function moveoutportal() --pushes objects out of the portal i in.
	for i, v in pairs(objects) do
		if i ~= "tile" and i ~= "portalwall" then
			for j, w in pairs(v) do
				if w.active and w.static == false then
					local p1, p2 = insideportal(w.x, w.y, w.width, w.height)
					
					if p1 ~= false then
						local portalfacing, portalx, portaly
						if p2 == 1 then
							portalfacing = p1.facing1
							portalx = p1.x1
							portaly = p1.y1
						else
							portalfacing = p1.facing2
							portalx = p1.x2
							portaly = p1.y2
						end
						
						if portalfacing == "right" then
							w.x = portalx
						elseif portalfacing == "left" then
							w.x = portalx - 1 - w.width
						elseif portalfacing == "up" then
							w.y = portaly - 1 - w.height
						elseif portalfacing == "down" then
							w.y = portaly
						end
					end
				end
			end
		end
	end
end

function nextlevel()
	if not levelfinished then
		return
	end
	
	if testlevel then
		editormode = true
		testlevel = false
		loadlevel(marioworld .. "-" .. mariolevel .. (mariosublevel > 0 and ("_" .. mariosublevel) or ""))
		startlevel()
		return
	end
	
	love.audio.stop()
	
	mariolevel = mariolevel + 1
	if not love.filesystem.getInfo("mappacks/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. ".txt") then
		mariolevel = 1
		marioworld = marioworld + 1
	end
	mariosublevel = 0
	levelscreen_load("next")
end

function warpzone(w, l)	
	love.audio.stop()
	mariolevel = l
	marioworld = w
	mariosublevel = 0
	prevsublevel = false
	
	-- minus 1 world glitch just because I can.
	if not displaywarpzonetext and w == 4 and l == 1 and mappack == "smb" then
		marioworld = "M"
	end
	
	levelscreen_load("next")
end

function game_mousereleased(x, y, button)
	if editormode then
		editor_mousereleased(x, y, button)
	end
end

function getMouseTile(x, y)
	local xout = math.floor((x+xscroll*16*scale)/(16*scale))+1
	local yout = math.floor((y+yscroll*16*scale-yoffset*scale)/(16*scale))+1
	return xout, yout
end

function savemap(filename)
	local s = ""
	local v = 1
	
	--mapheight
	local s = s .. mapheight .. CATEGORYDELIMITER[v]
	
	local mul = 1
	local prev = nil
	
	for y = 1, mapheight do
		for x = 1, mapwidth do
			local current = map[x][y][1] .. (coinmap[x][y] and "c" or "")
			
			--check if previous is the same
			if #map[x][y] == 1 then
				if prev == current and (y ~= mapheight or x ~= mapwidth) then
					mul = mul + 1
				elseif prev == current and y == mapheight and x == mapwidth then
					mul = mul + 1
					s = s .. prev .. MULTIPLYDELIMITER[v] .. mul
				else
					if prev then
						if mul > 1 then
							s = s .. prev .. MULTIPLYDELIMITER[v] .. mul
						else
							s = s .. prev
						end
						
						if y ~= mapheight or x ~= mapwidth then
							s = s .. BLOCKDELIMITER[v]
						end
					end
					prev = current
					mul = 1
					if y == mapheight and x == mapwidth then
						if prev then
							s = s .. BLOCKDELIMITER[v]
						end
						s = s .. prev
					end
				end
			else
				if prev then
					if mul > 1 then
						s = s .. prev .. MULTIPLYDELIMITER[v] .. mul
					else
						s = s .. prev
					end
					
					s = s .. BLOCKDELIMITER[v]
				end
				prev = nil
				mul = 1
				
				for i = 1, #map[x][y] do
					if tonumber(map[x][y][i]) and tonumber(map[x][y][i]) < 0 then
						s = s .. "m" .. math.abs(tostring(map[x][y][i]))
					else
						s = s .. tostring(map[x][y][i])
					end
					
					if i == 1 and coinmap[x][y] then
						s = s .. "c"
					end
					
					if i ~= #map[x][y] then
						s = s .. LAYERDELIMITER[v]
					end
				end
				
				if y ~= mapheight or x ~= mapwidth then
					s = s .. BLOCKDELIMITER[v]
				end
			end
		end
	end
	
	--options
	s = s .. CATEGORYDELIMITER[v] .. "backgroundr" .. EQUALSIGN[v] ..  background[1] * 255
	s = s .. CATEGORYDELIMITER[v] .. "backgroundg" .. EQUALSIGN[v] ..  background[2] * 255
	s = s .. CATEGORYDELIMITER[v] .. "backgroundb" .. EQUALSIGN[v] ..  background[3] * 255
	s = s .. CATEGORYDELIMITER[v] .. "spriteset" .. EQUALSIGN[v] ..  spriteset
	if musicname then
		s = s .. CATEGORYDELIMITER[v] .. "music" .. EQUALSIGN[v] ..  musicname
	end
	if intermission then
		s = s .. CATEGORYDELIMITER[v] .. "intermission"
	end
	if bonusstage then
		s = s .. CATEGORYDELIMITER[v] .. "bonusstage"
	end
	if haswarpzone then
		s = s .. CATEGORYDELIMITER[v] .. "haswarpzone"
	end
	if underwater then
		s = s .. CATEGORYDELIMITER[v] .. "underwater"
	end
	if custombackground then
		if custombackground == true then
			s = s .. CATEGORYDELIMITER[v] .. "custombackground"
		else
			s = s .. CATEGORYDELIMITER[v] .. "custombackground" .. EQUALSIGN[v] ..  custombackground
		end
	end
	if customforeground then
		if customforeground == true then
			s = s .. CATEGORYDELIMITER[v] .. "customforeground"
		else
			s = s .. CATEGORYDELIMITER[v] .. "customforeground" .. EQUALSIGN[v] ..  customforeground
		end
	end
	s = s .. CATEGORYDELIMITER[v] .. "timelimit" .. EQUALSIGN[v] ..  mariotimelimit
	s = s .. CATEGORYDELIMITER[v] .. "scrollfactor" .. EQUALSIGN[v] ..  scrollfactor
	s = s .. CATEGORYDELIMITER[v] .. "fscrollfactor" .. EQUALSIGN[v] ..  fscrollfactor
	if not portalsavailable[1] or not portalsavailable[2] then
		local ptype = "none"
		if portalsavailable[1] then
			ptype = "blue"
		elseif portalsavailable[2] then
			ptype = "orange"
		end
		
		s = s .. CATEGORYDELIMITER[v] .. "portalgun" .. EQUALSIGN[v] ..  ptype
	end
	
	if levelscreenbackname then
		s = s .. CATEGORYDELIMITER[v] .. "levelscreenback" .. EQUALSIGN[v] ..  levelscreenbackname
	end
	
	--tileset
	
	love.filesystem.createDirectory( "mappacks" )
	love.filesystem.createDirectory( "mappacks/" .. mappack )
	
	love.filesystem.write("mappacks/" .. mappack .. "/" .. filename .. ".txt", s)
	
	--preview
	
	previewimg = renderpreview()
	if loveVersion > 9 then
		previewimg:encode("png", "mappacks/" .. mappack .. "/" .. filename .. ".png")
	else
		previewimg:encode("mappacks/" .. mappack .. "/" .. filename .. ".png")
	end
	
	print("Map saved as " .. "mappacks/" .. filename .. ".txt")
	notice.new("Map saved!", notice.white, 2)
end

function renderpreview()
	local out = love.image.newImageData(mapwidth, height+1)
	
	--find startpoint
	local startx, starty = 3, 13
	
	for x = 1, mapwidth do
		for y = 1, mapheight do
			if map[x][y][2] and entitylist[map[x][y][2]] and entitylist[map[x][y][2]].t == "spawn" then
				startx, starty = x, y
				break
			end
		end
	end
	
	yadd = math.max(0, math.min(mapheight-height-1, starty-math.floor(height/2)))
	
	for x = 1, mapwidth do --blocks
		for y = 1, 15 do
			local id = map[x][y+yadd][1]
			if id ~= nil and id ~= 0 and rgblist[id] and tilequads[id]:getproperty("invisible", x, y+yadd) == false then
				local r, g, b = unpack(rgblist[id])
				out:setPixel(x-1, y-1, r * COLORSPACE, g * COLORSPACE, b * COLORSPACE, COLORSPACE)
			else
				local r, g, b = unpack(background)
				out:setPixel(x-1, y-1, r * COLORSPACE, g * COLORSPACE, b * COLORSPACE, COLORSPACE)
			end
		end
	end
	
	return out
end

function savelevel()
	if mariosublevel == 0 then
		savemap(marioworld .. "-" .. mariolevel)
	else
		savemap(marioworld .. "-" .. mariolevel .. "_" .. mariosublevel)
	end
end

function traceline(sourcex, sourcey, radians, reportal)
	local currentblock = {}
	local x, y = sourcex, sourcey
	currentblock[1] = math.floor(x)
	currentblock[2] = math.floor(y+1)
		
	local emancecollide = false
	for i, v in pairs(emancipationgrills) do
		if v:getTileInvolved(currentblock[1]+1, currentblock[2]) then
			emancecollide = true
		end
	end
	
	local doorcollide = false
	for i, v in pairs(objects["door"]) do
		if v.dir == "hor" then
			if v.open == false and (v.cox == currentblock[1] or v.cox == currentblock[1]+1) and v.coy == currentblock[2] then
				doorcollide = true
			end
		else
			if v.open == false and v.cox == currentblock[1]+1 and (v.coy == currentblock[2] or v.coy == currentblock[2]+1) then
				doorcollide = true
			end
		end
	end
	
	if emancecollide or doorcollide then
		return false, false, false, false, x, y
	end
	
	local side
	
	while currentblock[1]+1 > 0 and currentblock[1]+1 <= mapwidth and (flagx == false or currentblock[1]+1 <= flagx or radians > 0) and (axex == false or currentblock[1]+1 <= axex) and (currentblock[2] > 0 or currentblock[2] >= math.floor(sourcey+0.5)) and currentblock[2] < mapheight+1 do --while in map range
		local oldy = y
		local oldx = x
		
		--calculate X and Y diff..
		local ydiff, xdiff
		local side1, side2
		
		if inrange(radians, -math.pi/2, math.pi/2, true) then --up
			ydiff = (y-(currentblock[2]-1)) / math.cos(radians)
			y = currentblock[2]-1
			side1 = "down"
		else
			ydiff = (y-(currentblock[2])) / math.cos(radians)
			y = currentblock[2]
			side1 = "up"
		end
		
		if inrange(radians, 0, math.pi, true) then --left
			xdiff = (x-(currentblock[1])) / math.sin(radians)
			x = currentblock[1]
			side2 = "right"
		else
			xdiff = (x-(currentblock[1]+1)) / math.sin(radians)
			x = currentblock[1]+1
			side2 = "left"
		end
		
		--smaller diff wins
		
		if xdiff < ydiff then
			y = oldy - math.cos(radians)*xdiff
			side = side2
		else
			x = oldx - math.sin(radians)*ydiff
			side = side1
		end
		
		if side == "down" then
			currentblock[2] = currentblock[2]-1
		elseif side == "up" then
			currentblock[2] = currentblock[2]+1
		elseif side == "left" then
			currentblock[1] = currentblock[1]+1
		elseif side == "right" then
			currentblock[1] = currentblock[1]-1
		end
		
		local collide, tileno = getTile(currentblock[1]+1, currentblock[2])
		local emancecollide = false
		for i, v in pairs(emancipationgrills) do
			if v:getTileInvolved(currentblock[1]+1, currentblock[2]) then
				emancecollide = true
			end
		end
		
		local doorcollide = false
		for i, v in pairs(objects["door"]) do
			if v.dir == "hor" then
				if v.open == false and (v.cox == currentblock[1] or v.cox == currentblock[1]+1) and v.coy == currentblock[2] then
					doorcollide = true
				end
			else
				if v.open == false and v.cox == currentblock[1]+1 and (v.coy == currentblock[2] or v.coy == currentblock[2]+1) then
					doorcollide = true
				end
			end
		end
		
		-- < 0 rechts
		
		--Check for ceilblocker
		if y < 0 then
			if entitylist[map[currentblock[1]][1][2]] and entitylist[map[currentblock[1]][1][2]].t == "ceilblocker" then
				return false, false, false, false, x, y
			end
		end
		
		if collide == true and tilequads[map[currentblock[1]+1][currentblock[2]][1]]:getproperty("grate", currentblock[1]+1, currentblock[2]) == false then
			break
		elseif emancecollide or doorcollide then
			return false, false, false, false, x, y
		elseif (radians <= 0 and x > xscroll + width) or (radians >= 0 and x < xscroll) then
			return false, false, false, false, x, y
		end
	end
	
	if currentblock[1]+1 > 0 and currentblock[1]+1 <= mapwidth and (currentblock[2] > 0 or currentblock[2] >= math.floor(sourcey+0.5))  and currentblock[2] < mapheight+1 and currentblock[1] ~= nil then
		local tendency
	
		--get tendency
		if side == "down" or side == "up" then
			if math.mod(x, 1) > 0.5 then
				tendency = 1
			else
				tendency = -1
			end
		elseif side == "left" or side == "right" then
			if math.mod(y, 1) > 0.5 then
				tendency = 1
			else
				tendency = -1
			end
		end
		
		return currentblock[1]+1, currentblock[2], side, tendency, x, y
	else
		return false, false, false, false, x, y
	end
end

function spawnenemy(x, y)
	if not inmap(x, y) then
		return
	end
	
	--don't spawn when on a coinblock or breakable block
	if tilequads[map[x][y][1] ]:getproperty("breakable", x, y) or tilequads[map[x][y][1] ]:getproperty("coinblock", x, y) then
		table.insert(enemiesspawned, {x, y})
		return
	end

	for i = 1, #enemiesspawned do
		if x == enemiesspawned[i][1] and y == enemiesspawned[i][2] then
			return
		end
	end
	
	--spawnrestriction
	allowenemy = true
	for i = 1, #spawnrestrictions do
		if x > spawnrestrictions[i][1]-6 and x < spawnrestrictions[i][1]+6 and y > spawnrestrictions[i][2]-6 and y < spawnrestrictions[i][2]+6 then
			allowenemy = false
		end
	end
	
	local r = map[x][y]
	if #r > 1 then 
		local wasenemy = false
		if allowenemy and tablecontains(enemies, r[2]) and not editormode then
			if not tilequads[map[x][y][1] ]:getproperty("breakable", x, y) and not tilequads[map[x][y][1] ]:getproperty("coinblock", x, y) then
				table.insert(objects["enemy"], enemy:new(x, y, r[2], r))
				wasenemy = true
			end
		elseif entitylist[r[2]] then
			local t = entitylist[r[2]].t
			if allowenemy and t == "cheepcheep" then
				if math.random(2) == 1 then
					table.insert(objects["enemy"], enemy:new(x, y, "cheepcheepwhite", r))
				else
					table.insert(objects["enemy"], enemy:new(x, y, "cheepcheepred", r))
				end
				wasenemy = true
			
			elseif t == "bowser" then
				objects["bowser"][1] = bowser:new(x, y-1/16)
				
			elseif t == "castlefire" then
				table.insert(objects["castlefire"], castlefire:new(x, y, r))
				
			elseif t == "platform" then
				table.insert(objects["platform"], platform:new(x, y, r)) --Platform
				
			elseif t == "platformfall" then
				table.insert(objects["platform"], platform:new(x, y, {0, 0, r[3]}, "fall")) --Platform fall
				
			elseif t == "platformbonus" then
				table.insert(objects["platform"], platform:new(x, y, {0, 0, 3}, "justright"))
			
			elseif t == "bulletbill" then
				table.insert(rocketlaunchers, rocketlauncher:new(x, y))
			
			elseif t == "geldispenser" then
				table.insert(objects["geldispenser"], geldispenser:new(x, y, r))
				
			elseif t == "upfire" then
				table.insert(objects["upfire"], upfire:new(x, y, r))
				
			elseif t == "panel" then
				table.insert(objects["panel"], panel:new(x-1, y-1, r))
			end
		end
		
		table.insert(enemiesspawned, {x, y})
		
		if wasenemy then
			--spawn enemies in 5x1 line so they spawn as a unit and not alone.
			spawnenemy(x-2, y)
			spawnenemy(x-1, y)
			spawnenemy(x+1, y)
			spawnenemy(x+2, y)
		end
	end
end

function item(i, x, y, size)
	if i == "powerup" then
		if size == 1 then
			table.insert(itemanimations, itemanimation:new(x, y, "mushroom"))
		else
			table.insert(itemanimations, itemanimation:new(x, y, "flower"))
		end
	elseif i == "vine" then
		table.insert(objects["vine"], vine:new(x, y))
	elseif enemiesdata[i] then
		table.insert(itemanimations, itemanimation:new(x, y, i))
	end
end

function givelive(id, t)
	if mariolivecount ~= false then
		for i = 1, players do
			mariolives[i] = mariolives[i]+1
			respawnplayers()
		end
	end
	t.destroy = true
	t.active = false
	table.insert(scrollingscores, scrollingscore:new("1up", t.x, t.y))
	playsound("oneup")
end	

function addpoints(i, x, y)
	if i > 0 then
		marioscore = marioscore + i
		if x and y then
			table.insert(scrollingscores, scrollingscore:new(i, x, y))
		end
	else
		table.insert(scrollingscores, scrollingscore:new(-i, x, y))
	end
end

function addzeros(s, i)
	for j = string.len(s)+1, i do
		s = "0" .. s
	end
	return s
end

function properprint2(s, x, y)
	for i = 1, string.len(tostring(s)) do
		if fontquads[string.sub(s, i, i)] then
			love.graphics.drawq(fontimage2, font2quads[string.sub(s, i, i)], x+((i-1)*4)*scale, y, 0, scale, scale)
		end
	end
end

function playsound(sound)
	if not soundlist[sound] then
		return
	end

	if soundenabled then
		if delaylist[sound] then
			local currenttime = love.timer.getTime()
			if currenttime-soundlist[sound].lastplayed > delaylist[sound] then
				soundlist[sound].lastplayed = currenttime
			else
				return
			end
		end
		
		soundlist[sound].source:stop()
		if loveVersion <= 8 then
			soundlist[sound].source:rewind()
		end
		soundlist[sound].source:seek(0)
		soundlist[sound].source:play()
	end
end

function runkey(i)
	local s = controls[i]["run"]
	return checkkey(s)
end

function rightkey(i)
	local s
	if objects["player"][i].gravitydirection > math.pi/4*1 and objects["player"][i].gravitydirection <= math.pi/4*3 then
		s = controls[i]["right"]
	elseif objects["player"][i].gravitydirection > math.pi/4*3 and objects["player"][i].gravitydirection <= math.pi/4*5 then
		s = controls[i]["down"]
	elseif objects["player"][i].gravitydirection > math.pi/4*5 and objects["player"][i].gravitydirection <= math.pi/4*7 then
		s = controls[i]["left"]
	else
		s = controls[i]["up"]
	end
	return checkkey(s)
end

function leftkey(i)
	local s
	if objects["player"][i].gravitydirection > math.pi/4*1 and objects["player"][i].gravitydirection <= math.pi/4*3 then
		s = controls[i]["left"]
	elseif objects["player"][i].gravitydirection > math.pi/4*3 and objects["player"][i].gravitydirection <= math.pi/4*5 then
		s = controls[i]["up"]
	elseif objects["player"][i].gravitydirection > math.pi/4*5 and objects["player"][i].gravitydirection <= math.pi/4*7 then
		s = controls[i]["right"]
	else
		s = controls[i]["down"]
	end
	return checkkey(s)
end

function downkey(i)
	local s
	if objects["player"][i].gravitydirection > math.pi/4*1 and objects["player"][i].gravitydirection <= math.pi/4*3 then
		s = controls[i]["down"]
	elseif objects["player"][i].gravitydirection > math.pi/4*3 and objects["player"][i].gravitydirection <= math.pi/4*5 then
		s = controls[i]["left"]
	elseif objects["player"][i].gravitydirection > math.pi/4*5 and objects["player"][i].gravitydirection <= math.pi/4*7 then
		s = controls[i]["up"]
	else
		s = controls[i]["right"]
	end
	return checkkey(s)
end

function upkey(i)
	local s
	if objects["player"][i].gravitydirection > math.pi/4*1 and objects["player"][i].gravitydirection <= math.pi/4*3 then
		s = controls[i]["up"]
	elseif objects["player"][i].gravitydirection > math.pi/4*3 and objects["player"][i].gravitydirection <= math.pi/4*5 then
		s = controls[i]["right"]
	elseif objects["player"][i].gravitydirection > math.pi/4*5 and objects["player"][i].gravitydirection <= math.pi/4*7 then
		s = controls[i]["down"]
	else
		s = controls[i]["left"]
	end
	return checkkey(s)
end

function checkkey(s)
	if s[1] == "joy" then
		local j = love.joystick:getJoysticks()[s[2]]
		if s[3] == "hat" then
			if string.match(j:getHat(s[4]), s[5]) then
				return true
			else
				return false
			end
		elseif s[3] == "but" then
			if j:sDown(s[4]) then
				return true
			else
				return false
			end
		elseif s[3] == "axe" then
			if s[5] == "pos" then
				if j:getAxis(s[4]) > joystickdeadzone then
					return true
				else
					return false
				end
			else
				if j:getAxis(s[4]) < -joystickdeadzone then
					return true
				else
					return false
				end
			end
		end
	elseif s[1] then
		if love.keyboard.isDown(s[1]) then
			return true
		else 
			return false
		end
	end
end

function game_joystickpressed( joystick, button )
	if pausemenuopen then
		return
	end
	if endpressbutton then
		endgame()
		return
	end
	
	for i = 1, players do
		if not noupdate and objects["player"][i].controlsenabled and not objects["player"][i].vine then
			local s1 = controls[i]["jump"]
			local s2 = controls[i]["run"]
			local s3 = controls[i]["reload"]
			local s4 = controls[i]["use"]
			local s5 = controls[i]["left"]
			local s6 = controls[i]["right"]
			if s1[1] == "joy" and joystick == tonumber(s1[2]) and s1[3] == "but" and button == tonumber(s1[4]) then
				objects["player"][i]:jump()
				return
			elseif s2[1] == "joy" and joystick == s2[2] and s2[3] == "but" and button == s2[4] then
				objects["player"][i]:fire()
				return
			elseif s3[1] == "joy" and joystick == s3[2] and s3[3] == "but" and button == s3[4] then
				objects["player"][i]:removeportals()
				return
			elseif s4[1] == "joy" and joystick == s4[2] and s4[3] == "but" and button == s4[4] then
				objects["player"][i]:use()
				return
			elseif s5[1] == "joy" and joystick == s5[2] and s5[3] == "but" and button == s5[4] then
				objects["player"][i]:leftkey()
				return
			elseif s6[1] == "joy" and joystick == s6[2] and s6[3] == "but" and button == s6[4] then
				objects["player"][i]:rightkey()
				return
			end
			
			if i ~= mouseowner then
				local s = controls[i]["portal1"]
				if s and s[1] == "joy" then
					if s[3] == "but" then
						if joystick == s[2] and button == s[4] then
							shootportal(i, 1, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
							return
						end
					end
				end
				
				local s = controls[i]["portal2"]
				if s and s[1] == "joy" then
					if s[3] == "but" then
						if joystick == tonumber(s[2]) and button == tonumber(s[4]) then
							shootportal(i, 2, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
							return
						end
					end
				end
			end
		end
	end
end

function game_joystickreleased( joystick, button )
	for i = 1, players do
		local s = controls[i]["jump"]
		if s[1] == "joy" then
			if s[3] == "but" then
				if joystick == tonumber(s[2]) and button == tonumber(s[4]) then
					objects["player"][i]:stopjump()
					return
				end
			end
		end
	end
end

function inrange(i, a, b, include)
	if a > b then
		b, a = a, b
	end
	
	if include then
		if i >= a and i <= b then
			return true
		else
			return false
		end
	else
		if i > a and i < b then
			return true
		else
			return false
		end
	end
end

function adduserect(x, y, width, height, callback)
	local t = {}
	t.x = x
	t.y = y
	t.width = width
	t.height = height
	t.callback = callback
	t.delete = false
	
	table.insert(userects, t)
	return t
end

function userect(x, y, width, height)
	local outtable = {}
	
	local j
	
	for i, v in pairs(userects) do
		if aabb(x, y, width, height, v.x, v.y, v.width, v.height) then
			table.insert(outtable, v.callback)
			if not j then
				j = i
			end
		end
	end
	
	return outtable, j
end

function drawrectangle(x, y, width, height)
	love.graphics.rectangle("fill", x*scale, y*scale, width*scale, scale)
	love.graphics.rectangle("fill", x*scale, y*scale, scale, height*scale)
	love.graphics.rectangle("fill", x*scale, (y+height-1)*scale, width*scale, scale)
	love.graphics.rectangle("fill", (x+width-1)*scale, y*scale, scale, height*scale)
end

function inmap(x, y)
	if not x or not y then
		return false
	end
	if x >= 1 and x <= mapwidth and y >= 1 and y <= mapheight then
		return true
	else
		return false
	end
end

function playmusic()
	if not editormode and musicname then
		if mariotime <= 99 and mariotime > 0 then
			music:play(musicname, true)
		else
			music:play(musicname)
		end
	end
end

function stopmusic()
	if musicname then
		if mariotime <= 99 and mariotime > 0 then
			music:stop(musicname, true)
		else
			music:stop(musicname)
		end
	end
end

function updatesizes()
	mariosizes = {}
	if not objects then
		for i = 1, players do
			mariosizes[i] = 1
		end
	else
		for i = 1, players do
			mariosizes[i] = objects["player"][i].size
		end
	end
end

function hitrightside()
	if haswarpzone then
		for i, v in pairs(objects["enemy"]) do
			if v.t == "plant" then	
				v.kill = true
			end
		end
		displaywarpzonetext = true
	end
end

function getclosestplayer(x)
	closestplayer = 1
	for i = 2, players do
		if math.abs(objects["player"][closestplayer].x+6/16-x) < math.abs(objects["player"][i].x+6/16-x) then
			closestplayer = i
		end
	end
	
	return closestplayer
end

function endgame()
	if testlevel then
		marioworld = testlevelworld
		mariolevel = testlevellevel
		testlevel = false
		editormode = true
		loadlevel(marioworld .. "-" .. mariolevel)
		startlevel()
	else
		love.audio.stop()
		gamefinished = true
		saveconfig()
		menu_load()
	end
end

function respawnplayers()
	if mariolivecount == false then
		return
	end
	for i = 1, players do
		if mariolives[i] == 1 and objects["player"].dead then
			objects["player"][i]:respawn()
		end
	end
end

function cameraxpan(target, t)
	xpan = true
	xpanstart = xscroll
	xpandiff = target-xpanstart
	xpantime = t
	xpantimer = 0
end

function cameraypan(target, t)
	ypan = true
	ypanstart = yscroll
	ypandiff = target-ypanstart
	ypantime = t
	ypantimer = 0
end

function updateranges()
	for i, v in pairs(objects["laser"]) do
		v:updaterange()
	end
	for i, v in pairs(objects["lightbridge"]) do
		v:updaterange()
	end
	for i, v in pairs(objects["funnel"]) do
		v:updaterange()
	end
end

function createdialogbox(text, speaker)
	dialogboxes = {}
	table.insert(dialogboxes, dialogbox:new(text, speaker))
end

function checkportalremove(x, y)
	for i, v in pairs(portals) do
		--Get the extra block of each portal
		local portal1xplus, portal1yplus, portal2xplus, portal2yplus = 0, 0, 0, 0
		if v.facing1 == "up" then
			portal1xplus = 1
		elseif v.facing1 == "right" then
			portal1yplus = 1
		elseif v.facing1 == "down" then
			portal1xplus = -1
		elseif v.facing1 == "left" then
			portal1yplus = -1
		end
		
		if v.facing2 == "up" then
			portal2xplus = 1
		elseif v.facing2 == "right" then
			portal2yplus = 1
		elseif v.facing2 == "down" then
			portal2xplus = -1
		elseif v.facing2 == "left" then
			portal2yplus = -1
		end
		
		if v.x1 ~= false then
			if (x == v.x1 or x == v.x1+portal1xplus) and (sy == v.y1 or y == v.y1+portal1yplus) then--and (facing == nil or v.facing1 == facing) then
				v:removeportal(1)
			end
		end
	
		if v.x2 ~= false then
			if (x == v.x2 or x == v.x2+portal2xplus) and (y == v.y2 or y == v.y2+portal2yplus) then--and (facing == nil or v.facing2 == facing) then
				v:removeportal(2)
			end
		end
	end
end
