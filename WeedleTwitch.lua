
    --Twitch by Weedle ^^ 
	local WeedleTwitch = MenuElement({type = MENU, id = "WeedleTwitch", name = "Twitch by Weedle"})
	WeedleTwitch:MenuElement({type = MENU, id = "Spells", name = "Spell Settings"})
	WeedleTwitch:MenuElement({type = MENU, id = "Items", name = "Items Settings"})
	WeedleTwitch:MenuElement({type = MENU, id = "Drawing", name = "Draw Settings"})
	WeedleTwitch:MenuElement({type = SPACE, name = "Version 0.5"})
	--Neccesarities
	local function Ready(spell)
		return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
	end


	local TEAM_ALLY = myHero.team
	local TEAM_JUNGLE = 300
	local TEAM_ENEMY = 300 - TEAM_ALLY
	local Orb = 3
	
	function TwitchTarget(range)
	local target = nil
		if Orb == 1 then
			target = EOW:GetTarget(range)
		elseif Orb == 2 then
			target = _G.SDK.TargetSelector:GetTarget(range)
		elseif Orb == 3 then
			target = GOS:GetTarget(range)
		end
		return target
	end

	local function BlockMovement()
		if Orb == "SDK" then
			_G.SDK.Orbwalker:SetMovement(false)
		elseif Orb == "NONE" then
			GOS.BlockMovement = true
		end
	end

	local function UnblockMovement()
		if Orb == "SDK" then
			_G.SDK.Orbwalker:SetMovement(true)
		elseif Orb == "NONE" then
			GOS.BlockMovement = false
		end
	end

--	function ForceTarget(unit)
--		if Orb == "SDK" then
--			target = _G.SDK.TargetSelector.ForceTarget(unit)
--		elseif Orb == "NONE" then
--			print("IT WORKS")
--			target = GOS.ForceTarget(unit)
--		end
--	end	

	local _EnemyHeroes
	local function GetEnemyHeroes()
		if _EnemyHeroes then return _EnemyHeroes end
		_EnemyHeroes = {}
		for i = 1, Game.HeroCount() do
			local unit = Game.Hero(i)
			if unit.isEnemy then
				table.insert(_EnemyHeroes, unit)
			end
		end
		return _EnemyHeroes
	end

	local function GetPercentHP(unit)
		if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
		return 100*unit.health/unit.maxHealth
	end

	local function GetPercentMP(unit)
		if type(unit) ~= "userdata" then error("{GetPercentMP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
		return 100*unit.mana/unit.maxMana
	end

	 function GetBuffs(unit)
		local t = {}
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff.count > 0 then
				table.insert(t, buff)
			end
		end
		return t
	end

	function HasBuff(unit, buffname)
		for K, Buff in pairs(GetBuffs(unit)) do
			if Buff.name:lower() == buffname:lower() and Buff.count > 0 and Game.Timer() < Buff.expireTime then
				return true
			end
		end
		return false
	end

	local function HaveTwitchBuff(unit)
   		for i = 0, unit.buffCount do
   		    local buff = unit:GetBuff(i)
   		    if buff and buff.name == "TwitchDeadlyVenom" and buff.count > 0 and Game.Timer() < buff.expireTime then
   		        return buff
   		    end
   		end
   		return false
	end

	local function GetDistanceSqr(p1, p2)
	    local dx = p1.x - p2.x
	    local dz = p1.z - p2.z
	    return (dx * dx + dz * dz)
	end
	
	local sqrt = math.sqrt  
	local function GetDistance(p1, p2)
		return sqrt(GetDistanceSqr(p1, p2))
	end

	local function GetDistance2D(p1,p2)
		return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
	end

	local function EnemyAround()
		for i = 1, Game.HeroCount() do 
		local Hero = Game.Hero(i) 
			if Hero.dead == false and Hero.team == TEAM_ENEMY and GetDistanceSqr(myHero.pos, Hero.pos) < 1440000 then
				return true
			end
		end
		return false
	end
	
	--function IsObjectOnLine(StartPos, EndPos, width, object)
	--    local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object.pos)
	--    return isOnSegment and GetDistanceSqr(pointSegment, object.pos) < width * width and GetDistanceSqr(StartPos, EndPos) > GetDistanceSqr(StartPos, object.pos)
	--end

	--function VectorPointProjectionOnLineSegment(v1, v2, v)
	--    assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	--    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	--    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	--    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	--    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	--    local isOnSegment = rS == rL
	--    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	--    return pointSegment, pointLine, isOnSegment
	--end	

	--local function ObjectOnLineSegment(StartPos, EndPos, width, objects, team)
	--    local object = nil 
	--    for i, object in pairs(objects) do
	--        if object ~= nil and object.valid and (not team or object.team == team) then
	--            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object.pos)
	--            local w = width
	--            if isOnSegment and GetDistance2D(pointSegment, object.pos) < w^2 and GetDistance2D(StartPos, EndPos) > GetDistance2D(StartPos, object.pos) then
	--            	print(Vector(pointSegment, object.pos))
	--                return object
	--            end
	--        end
	--    end
	--    return false
	--end

	local function GetEnemyCount(range, pos)
		local pos = pos or myHero.pos
    	local count = 0
    	for i = 1,Game.HeroCount() do
    	    local hero = Game.Hero(i)
    	    local Range = range * range
    	    if hero.team == TEAM_ENEMY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
    	        count = count + 1
    	    end
    	end
    	return count
	end

	local function GetMinionCount(range, pos)
		local pos = pos.pos
    	local count = 0
    	for i = 1,Game.MinionCount() do
    	    local hero = Game.Minion(i)
    	    local Range = range * range
    	    if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
    	        count = count + 1
    	    end
    	end
    	return count
	end

	local intToMode = {
   		[0] = "",
   		[1] = "Combo",
   		[2] = "Harass",
   		[3] = "LastHit",
   		[4] = "Clear"
	}

	function GetMode()
		if Orb == 1 then
			return intToMode[EOW.CurrentMode]
		elseif Orb == 2 then
			if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
				return "Combo"
			elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
				return "Harass"	
			elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
				return "Clear"
			elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
				return "LastHit"
			elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
				return "Flee"
			end
		else
			return GOS.GetMode()
		end
	end

	local function IsImmobileTarget(unit)
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
				return true
			end
		end
		return false	
	end

	local ItemHotKey = {
	    [ITEM_1] = HK_ITEM_1,
	    [ITEM_2] = HK_ITEM_2,
	    [ITEM_3] = HK_ITEM_3,
	    [ITEM_4] = HK_ITEM_4,
	    [ITEM_5] = HK_ITEM_5,
	    [ITEM_6] = HK_ITEM_6,
	}

	local function GetItemSlot(unit, id)
	  for i = ITEM_1, ITEM_7 do
	    if unit:GetItemData(i).itemID == id then
	      return i
	    end
	  end
	  return 0 
	end

	local function IsImmune(unit)
		if type(unit) ~= "userdata" then error("{IsImmune}: bad argument #1 (userdata expected, got "..type(unit)..")") end
		for i, buff in pairs(GetBuffs(unit)) do
			if (buff.name == "KindredRNoDeathBuff" or buff.name == "UndyingRage") and GetPercentHP(unit) <= 10 then
				return true
			end
			if buff.name == "VladimirSanguinePool" or buff.name == "JudicatorIntervention" then 
				return true
			end
		end
		return false
	end

	local function IsValidTarget(unit, range)
    	return unit and unit.team == TEAM_ENEMY and unit.dead == false and GetDistanceSqr(myHero.pos, unit.pos) <= (range + myHero.boundingRadius + unit.boundingRadius)^2 and unit.isTargetable and unit.isTargetableToTeam and unit.isImmortal == false and unit.visible
	end

	local function IsValidCreep(unit, range)
    	return unit and unit.team ~= TEAM_ALLY and unit.dead == false and GetDistanceSqr(myHero.pos, unit.pos) <= (range + myHero.boundingRadius + unit.boundingRadius)^2 and unit.isTargetable and unit.isTargetableToTeam and unit.isImmortal == false and unit.visible
	end

	local _OnVision = {}
	function OnVision(unit)
		if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
		if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
		if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
		return _OnVision[unit.networkID]
	end
	Callback.Add("Tick", function() OnVisionF() end)
	local visionTick = GetTickCount()
	function OnVisionF()
		if GetTickCount() - visionTick > 100 then
			for i,v in pairs(GetEnemyHeroes()) do
				OnVision(v)
			end
		end
	end

	local _OnWaypoint = {}
	function OnWaypoint(unit)
		if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
		if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
			-- print("OnWayPoint:"..unit.charName.." | "..math.floor(Game.Timer()))
			_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
				DelayAction(function()
					local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
					local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
					if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
						_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
						-- print("OnDash: "..unit.charName)
					end
				end,0.05)
		end
		return _OnWaypoint[unit.networkID]
	end

	local function GetPred(unit,speed,delay) --still Noddys pred
		local speed = speed or math.huge
		local delay = delay or 0.25
		local unitSpeed = unit.ms
		if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
		if OnVision(unit).state == false then
			local unitPos = unit.pos + Vector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)/1000 * unitSpeed)
			local predPos = unitPos + Vector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unitPos)/speed)))
			if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
			return predPos
		else
			if unitSpeed > unit.ms then
				local predPos = unit.pos + Vector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unit.pos)/speed)))
				if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
				return predPos
			elseif IsImmobileTarget(unit) then
				return unit.pos
			else
				return unit:GetPrediction(speed,delay)
			end
		end
	end

	local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}

	local function TwitchCast(spell,pos,delay)
		if pos == nil then return end
		if Orb == 1 or Orb == 2 then
			Control.CastSpell(spell, pos)
		elseif Orb == 3 then
			local ticker = GetTickCount()
			if castSpell.state == 0 and ticker - castSpell.casting > delay + Game.Latency() and pos:ToScreen().onScreen then
				castSpell.state = 1
				castSpell.mouse = mousePos
				castSpell.tick = ticker
			end
			if castSpell.state == 1 then
				if ticker - castSpell.tick < Game.Latency() then
					Control.SetCursorPos(pos)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					castSpell.casting = ticker + delay
					DelayAction(function()
						if castSpell.state == 1 then
							Control.SetCursorPos(castSpell.mouse)
							castSpell.state = 0
						end
					end, Game.Latency()/1000)
				end
				if ticker - castSpell.casting > Game.Latency() then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end
		end
	end

	--Deftsu
	require "DamageLib"
	require "2DGeometry"

	--Class start
	class "Twitch"

	local TwitchPoison = {}

	function Twitch:AddTable()
		for i = 1, Game.HeroCount() do
			local hero = Game.Hero(i)
			if hero and hero.team == TEAM_ENEMY then
				TwitchPoison[hero.networkID] = {}
				TwitchPoison[hero.networkID].count = 0
				TwitchPoison[hero.networkID].timer = 0			
			end
		end 
	end

	function Twitch:__init()
		Callback.Add("Tick", function() self:Tick() end)
		Callback.Add("Draw", function() self:Draw() end)	
		self:Menu() 
		if _G.EOWLoaded then
			Orb = 1
		elseif _G.SDK and _G.SDK.Orbwalker then
			Orb = 2
		end
		self:AddTable()
		QBuff = false
		print("Twitch by Weedle Loaded succesfully")	
	end

	function Twitch:Menu()
	WeedleTwitch.Spells:MenuElement({id = "QS", name = "Q Settings", type = MENU})
		WeedleTwitch.Spells.QS:MenuElement({id = "Combo", name = "Enable Q in Combo", value = true})
		WeedleTwitch.Spells.QS:MenuElement({id = "Q", name = "Enable Q in Flee/Recall", value = true})	
		WeedleTwitch.Spells.QS:MenuElement({id = "RK", name = "Stealth Recall Key", key = "N"})
		WeedleTwitch.Spells.QS:MenuElement({name = "Make sure that your default recall button is 'B'", type = SPACE})
	WeedleTwitch.Spells:MenuElement({id = "WS", name = "W Settings", type = MENU})
		WeedleTwitch.Spells.WS:MenuElement({id = "Combo", name = "Enable W in Combo", value = true})
		WeedleTwitch.Spells.WS:MenuElement({id = "Harass", name = "Enable W in Harass", value = true})
		WeedleTwitch.Spells.WS:MenuElement({id = "Clear", name = "Enable W in Clear", value = true})
		WeedleTwitch.Spells.WS:MenuElement({id = "CC", name = "Min amount of Minions to W in Clear", value = 3, min = 1, max = 7, step = 1})
		WeedleTwitch.Spells.WS:MenuElement({id = "Flee", name = "Enable W in Flee", value = true})	
		WeedleTwitch.Spells.WS:MenuElement({id = "Mana", name = "Min mana% to W", value = 10, min = 0, max = 100, step = 1})
	WeedleTwitch.Spells:MenuElement({id = "ES", name = "E Settings", type = MENU})
		WeedleTwitch.Spells.ES:MenuElement({id = "E", name = "Enable Auto E", value = true})
		WeedleTwitch.Spells.ES:MenuElement({id = "Mana", name = "Min mana% to E", value = 10, min = 0, max = 100, step = 1})
		WeedleTwitch.Spells.ES:MenuElement({id = "Count", name = "Min Stacks for Out of Range", value = 2, min = 1, max = 6, step = 1})	
		WeedleTwitch.Spells.ES:MenuElement({id = "ET", name = "Toggle Key", key = "T", toggle = true})			
		WeedleTwitch.Spells.ES:MenuElement({name = "Auto E: Killsteal and before dying", type = SPACE})	
		WeedleTwitch.Spells.ES:MenuElement({name = "Toggle Mode: Out of Range- and Last Second E", type = SPACE})		
	WeedleTwitch.Spells:MenuElement({id = "RS", name = "R Settings", type = MENU})
		WeedleTwitch.Spells.RS:MenuElement({id = "Combo", name = "Enable R in Combo", value = true})
		WeedleTwitch.Spells.RS:MenuElement({id = "Count", name = "Min amount of Enemies to R", value = 2, min = 1, max = 5, step = 1})
		WeedleTwitch.Spells.RS:MenuElement({id = "Mana", name = "Min mana% to R", value = 10, min = 0, max = 100, step = 1})

	WeedleTwitch.Items:MenuElement({id = "BC", name = "Bilgewater Cutlass", type = MENU, })
		WeedleTwitch.Items.BC:MenuElement({id = "Combo", name = "Enable in Combo", value = true})
		WeedleTwitch.Items.BC:MenuElement({id = "HP", name = "Max Enemy HP%", value = 50, min = 0, max = 100, step = 1})
	WeedleTwitch.Items:MenuElement({id = "BOTRK", name = "Blade of the Ruined King", type = MENU, })
		WeedleTwitch.Items.BOTRK:MenuElement({id = "Combo", name = "Enable in Combo", value = true})
		WeedleTwitch.Items.BOTRK:MenuElement({id = "HP", name = "Max Enemy HP%", value = 50, min = 0, max = 100, step = 1})
	WeedleTwitch.Items:MenuElement({id = "YG", name = "Youmuu's Ghostblade", type = MENU, })
		WeedleTwitch.Items.YG:MenuElement({id = "Combo", name = "Enable in Combo", value = true})
		WeedleTwitch.Items.YG:MenuElement({id = "R", name = "Min Enemy Distance", value = 1000, min = 0, max = 2000, step = 100})
		WeedleTwitch.Items.YG:MenuElement({id = "Draw", name = "Draw Settings", type = MENU})
			WeedleTwitch.Items.YG.Draw:MenuElement({id = "Enabled", name = "Enabled", value = false})
			WeedleTwitch.Items.YG.Draw:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
			WeedleTwitch.Items.YG.Draw:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})

	WeedleTwitch.Drawing:MenuElement({id = "Enabled", name = "Enable all Drawings", value = true})
	WeedleTwitch.Drawing:MenuElement({id = "DMG", name = "Draw Edmg", value = true})
	WeedleTwitch.Drawing:MenuElement({id = "Toggle", name = "Draw E Toggle Mode", value = true})
	WeedleTwitch.Drawing:MenuElement({id = "WD", name = "Draw W range", type = MENU})
	    WeedleTwitch.Drawing.WD:MenuElement({id = "Enabled", name = "Enabled", value = true})       
	    WeedleTwitch.Drawing.WD:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
	    WeedleTwitch.Drawing.WD:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
	WeedleTwitch.Drawing:MenuElement({id = "ED", name = "Draw E range", type = MENU})
	    WeedleTwitch.Drawing.ED:MenuElement({id = "Enabled", name = "Enabled", value = true})       
	    WeedleTwitch.Drawing.ED:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
	    WeedleTwitch.Drawing.ED:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
	WeedleTwitch.Drawing:MenuElement({id = "RD", name = "Draw R range", type = MENU})
	    WeedleTwitch.Drawing.RD:MenuElement({id = "Enabled", name = "Enabled", value = true})       
	    WeedleTwitch.Drawing.RD:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
	    WeedleTwitch.Drawing.RD:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)}) 
	end

	function Twitch:Tick()
		if myHero.dead then return end	
		if HasBuff(myHero, "TwitchHideInShadows") then
			QBuff = true
		else
			QBuff = false
		end
		local Mode = GetMode()
		if WeedleTwitch.Spells.QS.Q:Value() then
			if WeedleTwitch.Spells.QS.RK:Value() then
				self:StealthRecall()
			end
			if Mode == "Flee" then
				self:EscapeLogic_1()
			end
		end
		if mode == "Flee" then
			self:EscapeLogic_2()
		end
		if Mode == "Combo" then
			self:Combo()
		end
		if Mode == "Harass" then
			self:Harass()
		end
		if Mode == "Clear" then
			self:Clear()
		end
		Twitch:EStacks()
	end

	function Twitch:StealthRecall()
		if Ready(_Q) then
			BlockMovement()
			Control.CastSpell(HK_Q, mousePos)
			DelayAction(function() Control.KeyDown("B") end, 0.25)
			DelayAction(function() Control.KeyUp("B") end, 0.25)
			UnblockMovement()
		end
		DelayAction(function() Control.KeyDown("B") end, 0.25)
		DelayAction(function() Control.KeyUp("B") end, 0.25)	
	end

	local LastQ = 0 
	function Twitch:EscapeLogic_1()
		if Ready(_Q) and QBuff == false and Game.Timer() - LastQ > 2 then
			Control.CastSpell(HK_Q)
			LastQ = Game.Timer()
		end
	end

	function Twitch:EscapeLogic_2()
	local target = TwitchTarget(1050)
	if target == nil then return end
	local Dist = GetDistanceSqr(myHero.pos, target.pos)
		if WeedleTwitch.Spells.WS.Flee:Value() and Ready(_W) then
			if QBuff == false or Dist < 250000 then
				local pos = GetPred(target, 1400, 0.1 + (Game.Latency()/1000))
				TwitchCast(HK_W, pos, 100)
			end
		end
	end 

	function Twitch:ClearLogic()
	local WPos = nil 
	local Most = 0 
		for i = 1, Game.MinionCount() do
		local Minion = Game.Minion(i)
			if IsValidCreep(Minion, 950) then
				local Count = GetMinionCount(400, Minion)
				if Count > Most then
					Most = Count
					WPos = Minion.pos
				end
			end
		end
		return WPos, Most
	end 

	Force = false
	function Twitch:Combo()
		if myHero.range == 550 then
			Force = false
			if Orb == 1 then
				EOW:ForceTarget(nil)
			elseif Orb == 2 then
				_G.SDK.Orbwalker.ForceTarget = nil	
			elseif Orb == 3 then 
				GOS:ForceTarget(nil)
			end		
		elseif Force == false and myHero.range == 850 then
			if Orb == 1 then
				EOW:ForceTarget(nil)
			elseif Orb == 2 then
				_G.SDK.Orbwalker.ForceTarget = nil	
			elseif Orb == 3 then 
				GOS:ForceTarget(nil)
			end	
		end 
	local target = TwitchTarget(1300)	
	if target == nil then return end
	local Dist = GetDistanceSqr(myHero.pos, target.pos)
		if IsValidTarget(target, 1300) then
			if WeedleTwitch.Items.BC.Combo:Value() then
				local Item = GetItemSlot(myHero, 3144)
				if Item >= 1 and Ready(Item) and Dist < 302500 and target.health/target.maxHealth <= WeedleTwitch.Items.BC.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Item], target)
				end
			end
			if WeedleTwitch.Items.BOTRK.Combo:Value() then
				local Item = GetItemSlot(myHero, 3153)
				if Item >= 1 and Ready(Item) and Dist < 302500 and target.health/target.maxHealth <= WeedleTwitch.Items.BOTRK.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Item], target)
				end
			end		
			if WeedleTwitch.Items.YG.Combo:Value() then
			local Item = GetItemSlot(myHero, 3142)
				if Item >= 1 and Ready(Item) and Dist < WeedleTwitch.Items.YG.R:Value()^2 then
					Control.CastSpell(ItemHotKey[Item])
				end
			end
			if WeedleTwitch.Spells.QS.Combo:Value() and Ready(_Q) and EnemyAround() and Game.Timer() - LastQ > 2 and myHero.mana >= myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_E).mana then
				Control.CastSpell(HK_Q)
				LastQ = Game.Timer()
			end
			if WeedleTwitch.Spells.WS.Combo:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= WeedleTwitch.Spells.WS.Mana:Value()/100 and myHero.mana >= myHero:GetSpellData(_W).mana + myHero:GetSpellData(_E).mana then
			local pos = GetPred(target, 1400, 0.1 + (Game.Latency()/1000))
			local Dist2 = GetDistanceSqr(pos, myHero.pos)
				if Dist2 < 902500 then
					if QBuff == false then
						if myHero.attackData.state == STATE_WINDDOWN  then
							TwitchCast(HK_W, pos, 100)
						end
					elseif QBuff and Dist2 < 302500 then
							if myHero.attackData.state == STATE_WINDDOWN then
								TwitchCast(HK_W, pos, 100)
							end
					end
				end
			end
			if WeedleTwitch.Spells.RS.Combo:Value() then
				if myHero.range == 550 and Ready(_R) and myHero.mana/myHero.maxMana >= WeedleTwitch.Spells.RS.Mana:Value()/100 then
					if GetEnemyCount(1500) >= WeedleTwitch.Spells.RS.Count:Value() and Dist < 722500 then
						Control.CastSpell(HK_R)
					end
				end
				if myHero.range == 850 and Dist > 722500 then
					for i = 1, Game.MinionCount() do
					local Minion = Game.Minion(i)
	 					if IsValidCreep(Minion, 850) then --[[and IsObjectOnLine(myHero.pos,myHero.pos+(target.pos-myHero.pos):Normalized()*1000,100,Minion)]]
	 					local PredPos = GetPred(target, 1500, 0.2 + (Game.Latency()/1000))
	    				local LS = LineSegment(myHero.pos, myHero.pos+(PredPos-myHero.pos):Normalized()*850)
	    					if LS:__distance(Minion) <= 50 and GetDistance(Minion.pos, PredPos) < target.distance  then
	    					Force = true 
	    						if Force == true then
	    							if Orb == 1 then
	    								EOW:ForceTarget(Minion)
	    								break
	    							elseif Orb == 2 then
										_G.SDK.Orbwalker.ForceTarget = Minion
										break
									elseif Orb == 3 then
										GOS:ForceTarget(Minion)
										break
									end
	  							else
	  								Force = false	
	  								break
	  							end
	  						end
	  					end
					end			
				else 
					Force = false
				end
			end
		end
	end

	function Twitch:Clear()
		if WeedleTwitch.Spells.WS.Clear:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= WeedleTwitch.Spells.WS.Mana:Value()/100 then
		local WPos, Count = self:ClearLogic()
			if WPos == nil then return end
			if Count >= WeedleTwitch.Spells.WS.CC:Value() then
				Control.CastSpell(HK_W, WPos)
    		end
    	end
    end

	function Twitch:Harass()
	Force = false
	local target = TwitchTarget(1300)
	if target == nil then return end
		if WeedleTwitch.Spells.WS.Harass:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= WeedleTwitch.Spells.WS.Mana:Value()/100 and myHero.mana >= myHero:GetSpellData(_W).mana + myHero:GetSpellData(_E).mana then
		local pos = GetPred(target, 1400, 0.1 + (Game.Latency()/1000))
		local Dist = GetDistanceSqr(pos, myHero.pos)
			if Dist < 902500 and QBuff == false then
				if myHero.attackData.state == STATE_WINDDOWN  then
					TwitchCast(HK_W, pos, 100)
				end
			elseif QBuff and Dist < 302500 then
					if myHero.attackData.state == STATE_WINDDOWN  then
						TwitchCast(HK_W, pos, 100)
					end
			end
		end
	end	

	--[[
	function Twitch:AutoE()
		if WeedleTwitch.Spells.ES.E:Value() then --NOT TESTED YET, it was using TwitchTarget, but wanna try this, need to make it more efficient tho
			for i = 1, Game.HeroCount() do
			local target = Game.Hero(i)
				if IsValidTarget(target, 1300) and target.isEnemy and target.distance < 1200 then
					if Twitch:Edmg(target) + (Twitch:Pdmg(target) / 6)>= target.health then
						Control.CastSpell(HK_E)
					end
					if myHero.health/myHero.maxHealth <= 0.07 and GetEnemyCount(1300) >= 1 then
						Control.CastSpell(HK_E)
					end
					if WeedleTwitch.Spells.ES.ET:Value() then
						if target.distance >= 1100 and target.distance <= 1200 and TwitchPoison[target.networkID].count >= WeedleTwitch.Spells.ES.Count:Value() and Game.Timer() - LastE > 3 then
							Control.CastSpell(HK_E)
							LastE = Game.Timer()
						end
						local Poison = HaveTwitchBuff(target)
						if Poison and Poison.duration < 0.3 and target.distance > 575 and Game.Timer() - LastE > 3 then
							Control.CastSpell(HK_E)
						end
					end
				end
			end
		end
	end]]

	local LastE = 0 
	function Twitch:EStacks()
		for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
			if IsValidTarget(hero, 1250) then
			local Poison = HaveTwitchBuff(hero)
				if Poison then
					if Poison.duration > 5.75 and Game.Timer() - TwitchPoison[hero.networkID].timer > 0.35 then
						if TwitchPoison[hero.networkID].count ~= 6 then
							TwitchPoison[hero.networkID].count = TwitchPoison[hero.networkID].count + 1 
							TwitchPoison[hero.networkID].timer = Game.Timer() 
						else 
							TwitchPoison[hero.networkID].count = 6
						end
					end
				else
					TwitchPoison[hero.networkID].count = 0
				end
				if WeedleTwitch.Spells.ES.E:Value() and Ready(_E) then 
					if Twitch:Edmg(hero) + (Twitch:Pdmg(hero) / 6)>= hero.health then
						Control.CastSpell(HK_E)
					end
					if myHero.health/myHero.maxHealth <= 0.07 and Game.Timer() - LastE > 3 then
						Control.CastSpell(HK_E)
					end
					if WeedleTwitch.Spells.ES.ET:Value() then
					local Dist = GetDistanceSqr(myHero.pos, hero.pos)
						if Dist >= 1210000 and Dist <= 1440000 and TwitchPoison[hero.networkID].count >= WeedleTwitch.Spells.ES.Count:Value() and Game.Timer() - LastE > 3 then
							Control.CastSpell(HK_E)
							LastE = Game.Timer()
						end
						if Poison and Poison.duration < 0.3 and Dist > 330625 and Game.Timer() - LastE > 3 then
							Control.CastSpell(HK_E)
						end
					end	
				end
			end
		end
	end 

	function Twitch:Edmg(target)
	local lvl = myHero:GetSpellData(_E).level	
	if lvl == nil then return 0 end 
	local Count = TwitchPoison[target.networkID].count
	if Count == 0 then return 0 end 
	local AP = myHero.ap
	if AP == nil then return 0 end
	local ADdmg = CalcPhysicalDamage(myHero, target, (5 + 15 * lvl + ((5 * (2 + lvl) * Count) + (0.25 * math.floor(myHero.totalDamage - myHero.baseDamage) * Count))))
	local APdmg = CalcMagicalDamage(myHero, target, (0.2 * math.floor(AP) * Count))
		return ADdmg + APdmg 
	end  

	--function Twitch:Edmg(target)
	--local lvl = myHero:GetSpellData(_E).level	
	--if lvl == nil then return 0 end 
	--local Count = TwitchPoison[target.networkID].count
	--if Count == 0 then return 0 end 
	--local AP = myHero.ap
	--if AP == nil then return 0 end
	--local ADdmg = CalcPhysicalDamage(myHero, target, ({20, 35, 50, 65, 80})[lvl] + ((({15 , 20, 25, 30, 35})[lvl] * Count) + (0.25 * math.floor(myHero.totalDamage - myHero.baseDamage) * Count)))
	--local APdmg = CalcMagicalDamage(myHero, target, (0.2 * math.floor(AP) * Count))
	--return ADdmg + APdmg 
	--end  

	function Twitch:Pdmg(target)   
	local lvl = myHero.levelData.lvl
	local Count = TwitchPoison[target.networkID].count
	if Count == 0 then return 0 end 	
	local p = ({6, 6, 6, 6, 12, 12, 12, 12, 18, 18, 18, 18, 24, 24, 24, 24, 30, 30})[lvl] 
	local Pdmg = p * Count
		return Pdmg
	end

	function Twitch:Draw()
		if not myHero.dead then
			if WeedleTwitch.Drawing.Enabled:Value() then
			local textPos = myHero.pos:To2D()
				if WeedleTwitch.Drawing.Toggle:Value() then 
					if WeedleTwitch.Spells.ES.ET:Value() then
						Draw.Text("E Toggle ON", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 000, 255, 000))
					elseif not WeedleTwitch.Spells.ES.ET:Value() then
						Draw.Text("E Toggle OFF", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 000, 000)) 
					end
				end
				if WeedleTwitch.Drawing.WD.Enabled:Value() then
					Draw.Circle(myHero.pos, 950, WeedleTwitch.Drawing.WD.Width:Value(), WeedleTwitch.Drawing.WD.Color:Value())	
				end
				if WeedleTwitch.Drawing.ED.Enabled:Value() then
					Draw.Circle(myHero.pos, 1200, WeedleTwitch.Drawing.ED.Width:Value(), WeedleTwitch.Drawing.ED.Color:Value())	
				end
				if WeedleTwitch.Drawing.RD.Enabled:Value() then
					Draw.Circle(myHero.pos, 850, WeedleTwitch.Drawing.RD.Width:Value(), WeedleTwitch.Drawing.RD.Color:Value())	
				end
				if WeedleTwitch.Items.YG.Draw.Enabled:Value() then
					Draw.Circle(myHero.pos, WeedleTwitch.Items.YG.R:Value(), WeedleTwitch.Items.YG.Draw.Width:Value(), WeedleTwitch.Items.YG.Draw.Color:Value())	
				end
				if WeedleTwitch.Drawing.DMG:Value() then
				local target = TwitchTarget(1300)
				if target == nil then return end
				local Edmg = Twitch:Edmg(target)
				local Pdmg = Twitch:Pdmg(target)
					if Edmg > target.health then 
						Draw.Text("E Damage ".. target.charName .." :" .. tostring(math.floor(Edmg + (Pdmg/6))), 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
					end
					if Edmg + Pdmg > target.health and Edmg < target.health then
						Draw.Text("E Damage ".. target.charName .." :".. tostring(math.floor(Edmg + (Pdmg/6))), 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 000, 205))						
					end
					if Edmg + Pdmg < target.health then
						Draw.Text("E Damage ".. target.charName .." :" .. tostring(math.floor(Edmg + (Pdmg/6))), 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 255, 000, 000))
					end
				end				
			end
		end
	end

	function OnLoad()
 		if _G[myHero.charName] and myHero.charName == "Twitch" then 
 			_G[myHero.charName]()
 			print("Welcome back " .. myHero.name .. ", have a nice day!")
		end
	end
