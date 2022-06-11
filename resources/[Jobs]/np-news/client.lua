-- Settings

local serverstockvaluesdeficits = {
  [1] = { ["value"] = 0.00 },
  [2] = { ["value"] = 0.00 },
  [3] = { ["value"] = 0.00 },
  [4] = { ["value"] = 0.00 },
  [5] = { ["value"] = 0.00 },
  [6] = { ["value"] = 0.00 },
}

local guiEnabled = false
local hasOpened = false

local endloop = false
-- Open Gui and Focus NUI


recentconvictions = {}


function openGui()
  SetPlayerControl(PlayerId(), 0, 0)
  guiEnabled = true
  SetNuiFocus(true)
  SendNUIMessage({openWarrants = true})

  -- If this is the first time we've opened the phone, load all warrants
  if hasOpened == false then
    lstContacts = {}
    hasOpened = true
  end
end

-- Close Gui and disable NUI
function closeGui()
  endloop = true
  SetNuiFocus(false)
  SendNUIMessage({openSection = "close"})
  guiEnabled = false
  SetPlayerControl(PlayerId(), 1, 0)
end

-- NUI Callback Methods
RegisterNUICallback('close', function(data, cb)
  closeGui()
  cb('ok')
end)

RegisterNetEvent('news:close')
AddEventHandler('news:close', function()
  closeGui()
end)


RegisterNetEvent('lastconvictionlist')
AddEventHandler('lastconvictionlist', function(newconv)
    recentconvictions = newconv
end)


RegisterNetEvent('news:stocks')
AddEventHandler('news:stocks', function()
  closeGui()
end)

RegisterNetEvent('NewsStandCheckFinish')
AddEventHandler('NewsStandCheckFinish', function(newsArray1,newsArray2)
  openGui()
  guiEnabled = true
  SendNUIMessage({openSection = "newsUpdate", string = newsArray1, string2 = newsArray2})

  TriggerEvent("attachItem","newspaper01")
  endloop = false
  local plycoords = GetEntityCoords(PlayerPedId())
  while not endloop do

    local adist = math.ceil(#(plycoords - GetEntityCoords(PlayerPedId())))

    if not IsEntityPlayingAnim(PlayerPedId(), "amb@world_human_tourist_map@female@base", "base", 3) then
        RequestAnimDict('amb@world_human_tourist_map@female@base')
      while not HasAnimDictLoaded("amb@world_human_tourist_map@female@base") do
        Citizen.Wait(0)
      end
      TaskPlayAnim(PlayerPedId(), "amb@world_human_tourist_map@female@base", "base", 8.0, -8, -1, 49, 0, 0, 0, 0)
    end
    if adist > 2 then
      endloop = true
    end
    Citizen.Wait(1)
  end
  TriggerEvent("destroyProp")
  TriggerEvent("news:close")
  ClearPedTasksImmediately(PlayerPedId())

end)


RegisterNetEvent('stringGangGlobalReputations')
AddEventHandler('stringGangGlobalReputations', function()

  local strg = "<font size='5'>Daily Crime Statistics</font> <br><br> <br> <b> Crack epidemic around Santa Ave"

    count = #recentconvictions
    strg = strg .. " <br><br><br><br><font size='5'>Recent Incarcerations</font>" 
            
    while count > 0 do
        strg = strg .. "<br><br>" .. recentconvictions[count] 
        count = count - 1
    end

    
    TriggerServerEvent("NewsStandCheckFinish", strg)

end)





local newsStands = {
	[1] = 1211559620,
	[2] = -1186769817,
	[3] = -756152956,
  [4] = 720581693, 
  [5] = -838860344,
}

--205
RegisterNetEvent('NewsStandCheck')
AddEventHandler('NewsStandCheck', function()
	if checkForNewsStand() then
		runNewsStand()
	else
		TriggerEvent("notification","You are not near a News Stand.",2)
	end
end)

function checkForNewsStand()
	for i = 1, #newsStands do
		local objFound = GetClosestObjectOfType( GetEntityCoords(PlayerPedId()), 3.0, newsStands[i], 0, 0, 0)
		if DoesEntityExist(objFound) then
			Citizen.Trace("News Stand Found")
			return true
		end
	end
	return false
end

function runNewsStand()
    TriggerServerEvent("stringGangGlobalReputations")
end