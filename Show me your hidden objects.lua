local version = "0.21"
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
				DownloadFile(UPDATE_URL .. "?nocache" .. myHero.charName .. os.clock(), UPDATE_FILE_PATH, function () print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> successfully updated. Please reload (double F9). (" .. version .. " => " .. ServerVersion .. ")</font>") end)     
			elseif ServerVersion then
				-- print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> You have got the latest version: <u><b>"..ServerVersion.."</b></u></font>")
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
	--[[
	if (name ~= "missile") and (name ~= "empty.troy") and (string.sub(name, 0, 6) ~= "minion") and (string.sub(name, 0, 3) ~= "sru") and (string.sub(name, 0, 4) ~= "draw") then
		PrintChat("CREATE " .. name)
	end
	]]
	if ((name == "sightward") or (name == "visionward") or (name == "noxious trap") or (name == "jack in the box")) and (obj.team ~= myHero.team) and (obj.mana > 0) then
		local ward = {x = obj.x, y = obj.y, z = obj.z, mana = obj.mana, time = GetGameTimer()}
		table.insert(wards, ward);
	end
end

function OnDeleteObj(obj)
	local name = obj.name:lower()
	if ((name == "sightward") or (name == "visionward") or (name == "noxious trap") or (name == "jack in the box")) and (obj.team ~= myHero.team) then
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
			currentMana = math.floor(ward.mana - (GetGameTimer() - ward.time))
			LagFreeDrawCircle(ward.x, ward.y, ward.z, 100, RGBA(127, 255, 0, 255))
			DrawText3D(tostring(currentMana), ward.x, ward.y, ward.z, 20, RGBA(127, 255, 0, 255), true)
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

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end
function round(num) 
	if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end
function LagFreeDrawCircle(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 100) 
    end
end