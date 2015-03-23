local version = "0.2"
local AUTO_UPDATE = true
local UPDATE_SCRIPT_NAME = "Show me your hidden objects"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/SunnyTiTi/BoL/master/Show%20me%20your%20hidden%20objects.lua"
local UPDATE_FILE_PATH = SCRIPT_PATH .. "Show me your hidden objects.lua"
local UPDATE_URL = "https://" .. UPDATE_HOST .. UPDATE_PATH

local ServerData
if AUTO_UPDATE then
	GetAsyncWebResult(UPDATE_HOST, UPDATE_PATH, function(d) ServerData = d end)
	function update()
		if ServerData ~= nil then
			local ServerVersion
			local send, tmp, sstart = nil, string.find(ServerData, "local version = \"")
			if sstart then
				send, tmp = string.find(ServerData, "\"", sstart+1)
			end
			if send then
				ServerVersion = tonumber(string.sub(ServerData, sstart+1, send-1))
			end

			if ServerVersion ~= nil and tonumber(ServerVersion) ~= nil and tonumber(ServerVersion) > tonumber(version) then
				DownloadFile(UPDATE_URL.."?nocache"..myHero.charName..os.clock(), UPDATE_FILE_PATH, function () print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> successfully updated. Reload (double F9) Please. ("..version.." => "..ServerVersion..")</font>") end)     
			elseif ServerVersion then
				print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> You have got the latest version: <u><b>"..ServerVersion.."</b></u></font>")
			end		
			ServerData = nil
		end
	end
	AddTickCallback(update)
end

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