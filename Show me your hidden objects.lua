local wards = {}

function OnLoad()
	PrintChat(">> Show me your hidden objects ... LOADED")

	Menu = scriptConfig("Show me your hidden objects", "Show me your hidden objects")
	Menu:addParam("Enable", "Enable", SCRIPT_PARAM_ONOFF, true)
end


function OnCreateObj(obj)
	local name = obj.name:lower()
	if (name ~= "missile") and (string.sub(name, 0, 6) ~= "minion") then
		PrintChat(name)
	end
	if ((name == "sightward") or (name == "noxious trap") or (name == "jack in the box")) and (obj.team ~= myHero.team) then
		local ward = {x = obj.x, y = obj.y, z = obj.z, mana = obj.mana, time = GetGameTimer()}
		table.insert(wards, ward);
		--print(name .. " at " .. GetGameTimer() .. " : " .. obj.x .. " - ".. obj.y .. " - " .. obj.z)
		--print(obj.team)
	end
end

function OnDeleteObj(obj)
	local name = obj.name:lower()
	if ((name == "sightward") or (name == "noxious trap") or (name == "jack in the box")) and (obj.team ~= myHero.team) then
		for key, ward in pairs(wards) do
			if (obj.x == ward.x) and (obj.x == ward.x) and (obj.x == ward.x) then
				table.remove(wards, key)
			end
		end
	end
end
 
function OnDraw()
	if Menu.Enable then
		for key, ward in pairs(wards) do
			-- currentMana = ward.mana - (GetGameTimer() - ward.time)
			local color = RGBA(127, 196, 0, 255)
			DrawCircle(ward.x, ward.y, ward.z, 100, color)
		end
	end
end

function OnTick()
	if Menu.Enable then
		for key, ward in pairs(wards) do
			if (GetGameTimer() - ward.time > ward.mana) and (ward.vision == false) then
				table.remove(wards, key)
			end
		end
	end
end