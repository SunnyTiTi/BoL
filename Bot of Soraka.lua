if myHero.charName ~= "Soraka" then return end

local UPDATE_SCRIPT_NAME = "Bot of Soraka"

require 'SxOrbWalk'
require "vPrediction"

local VP
local VPDelay = 0.7
local ADC
local ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 800)
local tsAA = TargetSelector(TARGET_LOW_HP_PRIORITY, 500)
local Turrets
local enemyMinions = minionManager(MINION_ENEMY, 500, myHero, MINION_SORT_HEALTH_ASC)
local enemyTp = minionManager(MINION_ENEMY, 800, myHero, MINION_SORT_HEALTH_ASC)
local x_fountain = 396
local z_fountain = 462
local returning_fountain = false
local curItem = 1
local sequence = {1, 2, 1, 2, 1, 4, 1, 3, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3}
local LastLevel = 0;
local LastBuy = 0;

local items = {
	{350, 0x0039, 0x00F9},
	{125, 0x0088, 0x00A8},
	{375, 0x00FE, 0x00F9},
	{400, 0x0041, 0x0041},
	{950, 0x00F8, 0x0068},
	{300, 0x0060, 0x00A8},
	{400, 0x0041, 0x0041},
	{450, 0x0077, 0x0041},
	{650, 0x007A, 0x00F9},
	{400, 0x0041, 0x0041},
	{600, 0x0097, 0x00F9},
	{500, 0x0074, 0x00F9},
	{350, 0x00A8, 0x0041},
	{300, 0x0032, 0x0041},
	{350, 0x0018, 0x00C4},
	{1350, 0x00C8, 0x00C4},
	{550, 0x00E1, 0x00F9},
	{850, 0x0093, 0x00F9},
	{800, 0x0028, 0x0042},
	{1250, 0x004E, 0x0041},
	{2550, 0x009A, 0x00F9}
}

function OnLoad()
	PrintChat(">> " .. UPDATE_SCRIPT_NAME .. " ... LOADED")
	
	UpdateWindow()
	VP = VPrediction()
	Turrets = GetTurrets()
	
	Menu = scriptConfig(UPDATE_SCRIPT_NAME, UPDATE_SCRIPT_NAME)
	Menu:addParam("Follow", "Follow", SCRIPT_PARAM_LIST, 2, { "None", "Nearest Ally", "Richest Ally"})
	Menu:addParam("UseSkills", "Use Skills", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("AttackMinions", "Attack Minions", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("BuyItems", "Buy Items", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("AutoLevelUp", "Level Spells", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("Debug", "Debug", SCRIPT_PARAM_ONKEYTOGGLE, false, 219)
	Menu:addParam("Test", "Test", SCRIPT_PARAM_ONKEYTOGGLE, false, 221)
	
	if SxOrb then SxOrb:LoadToMenu(nil) end
	
	if myHero.team == 200 then
		x_fountain = 14200
		z_fountain = 14200
	end
end

function OnTick()
	-- PrintChat(tostring(myHero:CanUseSpell(_E)) .. " " .. tostring(myHero.mana))
	if Menu.Test then
		print(myHero:GetInt('GOLD_EARNED') .. " - " .. myHero.x .. " " .. myHero.z)	
		Menu.Test  = false
	end
	
	if Menu.AutoLevelUp and LastLevel < myHero.level then
		LevelSpell(sequence[myHero.level])
		LastLevel = myHero.level;
	end
	
	if Menu.BuyItems and (myHero.x < 800 and myHero.z < 800) or (myHero.x > 13700 and myHero.z > 13700)  or myHero.dead then
		BuyItems()
	end
	
	if myHero.dead then
		return
	end
	
	if myHero.health == myHero.maxHealth and myHero.mana == myHero.maxMana then
		returning_fountain = false
	end
	
	if Menu.Follow == 2 then
		ADC = FindNearestAlly()
	elseif Menu.Follow == 3 then
		ADC = FindRichestAlly()
	end

	if returning_fountain or myHero.health * 4 < myHero.maxHealth or myHero.mana * 10 < myHero.maxMana then
		returning_fountain = true
		CastRecall()
	else
		local isMoving = false
		if Menu.Follow > 1 then
			if MoveToHero(ADC) then
				isMoving = true
			end
		end
		
		
		if Menu.UseSkills and not isMoving then Combo() end
		if Menu.AttackMinions and not isMoving then LaneClear() end
		-- if SxOrb:CanAttack() then player:MoveTo(nearestAlly.x, nearestAlly.z) end
	end
end

function BuyItems()
	if myHero.gold > items[curItem][1] and items[curItem] ~= nil and GetInGameTimer() - LastBuy > 0.2 then
		Testbuy(items[curItem])
		curItem = curItem + 1
		LastBuy = GetInGameTimer()
	end
end

function MoveToHero(hero)
	vectorMyHero = Vector(myHero.x, myHero.z)
	vectorADC = Vector(hero.x, hero.z)
	if InTurretsRange() or GetDistance(vectorMyHero, vectorADC) > 500 then
		local desc_x = (hero.x * 50 + x_fountain) / 51
		local desc_z = (hero.z * 50 + z_fountain) / 51
		
		if (desc_x < 1000 and desc_z < 1000) or (desc_x > 13500 and desc_z > 13500) then
			CastRecall()
			return true
		end
		
		vectorMyHero = Vector(myHero.x, myHero.z)
		vectorMyHeroDesc = Vector(myHero.endPath.x, myHero.endPath.z)
		vectorDesc = Vector(desc_x, desc_z)
		if GetDistance(vectorMyHero, vectorDesc) > 200 and GetDistance(vectorMyHeroDesc, vectorDesc) > 200 then
			myHero:MoveTo(desc_x, desc_z)
		end
		return true
	end
	return false
end

function Combo()
	if (myHero:CanUseSpell(_W) == READY) and (ADC.health * 1.5 < ADC.maxHealth) then
		CastSpell(_W, ADC)
		return true
	end
	
	if (myHero:CanUseSpell(_R) == READY) then
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team and hero.health * 3 < hero.maxHealth and not hero.dead then
				CastSpell(_R)
			end
		end
		return true
	end
	
	ts:update()
	
	if (ts.target ~= nil) then
		position = VP:GetPredictedPos(ts.target, VPDelay)
		
		if (myHero:CanUseSpell(_Q) == READY) then
			CastSpell(_Q, position.x, position.z)
			return true
		end
		
		if (myHero:CanUseSpell(_E) == READY) then
			CastSpell(_E, position.x, position.z)
			return true
		end
	end
	
	if SxOrb:CanAttack() then
		tsAA:update()
		if tsAA.target ~= nil then
			myHero:Attack(tsAA.target)
			return true
		end
	end
	
	return false
end

function LaneClear()
	ts:update()
	if ts.target ~= nil then
		return
	end
	
	enemyMinions:update()
	for i, minion in pairs(enemyMinions.objects) do
		minHealth = 99999
		if ValidTarget(minion) and minion ~= nil and minion.health > 120 and minion.health < minHealth then
			minHealth = minion.health
			target = minion
			vectorMyHero = Vector(myHero.x, myHero.z)
			vectorHero = Vector(target.x, target.z)
			distance = GetDistance(vectorMyHero, vectorHero)
			if distance > 500 then
				--myHero:MoveTo(target.x, target.z)
			elseif SxOrb:CanAttack() then
				SxOrb:Attack(minion)
			end
		end
	end
end

function FindNearestAlly()
	minDistance = 99999
	nearestAlly = heroManager:GetHero(2)
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero ~= nil and hero.team == myHero.team and hero.health > 0 and (hero.x > 1000 or hero.z > 1000) and (hero.x < 13500 or hero.z < 13500) then
			--PrintChat(hero.name)
			vectorMyHero = Vector(myHero.x, myHero.z)
			vectorHero = Vector(hero.x, hero.z)
			distance = GetDistance(vectorMyHero, vectorHero)
			if distance ~= 0 and distance < minDistance then
				minDistance = distance
				--PrintChat(tostring(minDistance))
				nearestAlly = hero
			end
		end
	end
	return nearestAlly
end

function FindRichestAlly()
	maxGold = 0
	richestAlly = heroManager:GetHero(1)
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		-- PrintChat(hero.charName .. " - " .. tostring(hero.damage * hero.attackSpeed))
		if hero ~= nil and hero.team == myHero.team and not hero.isMe and hero.health > 0 and (hero.x > 1000 or hero.z > 1000) and (hero.x < 13500 or hero.z < 13500) and hero.damage * hero.attackSpeed > maxGold then
			maxGold = hero.damage * hero.attackSpeed
			richestAlly = hero
		end
	end
	return richestAlly
end

function CastRecall()
	enemyTp:update()
	ts:update()
	if ts.target == nil then
		local count = 0
		for i, minion in pairs(enemyMinions.objects) do
			count = count + 1
		end
		if count == 0 then
			vectorMyHero = Vector(myHero.x, myHero.z)
			vectorFountain = Vector(x_fountain, z_fountain)
			if GetDistance(vectorMyHero, vectorFountain) > 2400 then
				CastSpell(RECALL)
			end
		end
	else
		myHero:MoveTo(x_fountain, z_fountain)
	end
end

function InTurretsRange()
	for name, tower in pairs(Turrets) do
		if tower.object ~= nil then
			if tower.object.team ~= myHero.team then
				vectorMyHero = Vector(myHero.x, myHero.z)
				vectorHero = Vector(tower.object.x, tower.object.z)
				distance = GetDistance(vectorMyHero, vectorHero)
				if distance < 800 then
					return true
				end
			end
		end
	end
end

function LevelSpell(spell)
	local offsets = { 
		[1] = 0x1E,
		[2] = 0xD3,
		[3] = 0x3A,
		[4] = 0xA8,
	}
	local p = CLoLPacket(0x00B6)
	p.vTable = 0xFE3124
	p:EncodeF(myHero.networkID)
	p:Encode1(0xC1)
	p:Encode1(offsets[spell])
	for i = 1, 4 do p:Encode1(0x63) end
	for i = 1, 4 do p:Encode1(0xC5) end
	for i = 1, 4 do p:Encode1(0x6A) end
	for i = 1, 4 do p:Encode1(0x00) end
	SendPacket(p)
end

function Testbuy(Item)
	local p = CLoLPacket(0x00D1)
	p.vTable = 0xE97ABC
	p:EncodeF(myHero.networkID)
	p:Encode1(Item[2])--Item Specific
	p:Encode1(Item[3])--Item Specific
	for i = 1, 2 do p:Encode1(0x1E) end
	for i = 1, 4 do p:Encode1(0x00) end
	SendPacket(p)
end
--[[
function OnSendPacket(p)
	if p.header == 0x00D1 then
	    register(p)
	end
end

function register(p)
	if p:DecodeF() == myHero.networkID then
		p.pos = 6
		local file = io.open(SCRIPT_PATH.."\\".."pcap.txt", "a")
		file:write(toHex(p:Decode1()).." ")
		file:write(toHex(p:Decode1()).." ")
		file:write("===========================\n")
		file:close()
	end
end

function toHex(num)
    local hexstr = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = math.fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
    if s == '' then s = '0' end
    return s
end
]]--
