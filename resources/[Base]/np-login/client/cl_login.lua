local menuOpen = false
local setDate = 0


local function sendMessage(data)
    SendNUIMessage(data)
end

local function openMenu()
    menuOpen = true
    sendMessage({open = true})
    SetNuiFocus(true, true)
    TriggerEvent("resetinhouse")
    Citizen.CreateThread(function()
        while menuOpen do
            Citizen.Wait(0)
            HideHudAndRadarThisFrame()
            DisableAllControlActions(0)
            TaskSetBlockingOfNonTemporaryEvents(PlayerPedId(), true)
            Citizen.Wait(4000)
            TriggerEvent("loading:disableLoading")
        end
    end)
end

local function closeMenu()
    menuOpen = false
    EnableAllControlActions(0)
    TaskSetBlockingOfNonTemporaryEvents(PlayerPedId(), false)
    SetNuiFocus(false, false)
end

local function disconnect()
    TriggerServerEvent("np-login:disconnectPlayer")
end

local function nuiCallBack(data)
    Citizen.Wait(60)
    local events = exports["np-fw"]:getModule("Events")

    if data.close then closeMenu() end
    if data.disconnect then disconnect() end
    if data.showcursor or data.showcursor == false then SetNuiFocus(true, data.showcursor) end
    if data.setcursorloc then SetCursorLocation(data.setcursorloc.x, data.setcursorloc.y) end
    
    if data.fetchdata then
        events:Trigger("np-fw:loginPlayer", nil, function(data)
            if type(data) == "table" and data.err then
                sendMessage({err = data})
                return
            end

            sendMessage({playerdata = data})
        end)
    end

    if data.newchar then
        if not data.chardata then return end

        events:Trigger("np-fw:createCharacter", data.chardata, function(created)
            if not created then
                created = {
                    err = true,
                    msg = "There was an error while creating your character, value returned nil or false. Contact an administrator if this persists."
                }

                sendMessage({err = created})
                return
            end

            if type(created) == "table" and created.err then
                sendMessage({err = created})
                return
            end

            local firstname = data.chardata.firstname
            local lastname = data.chardata.lastname
            local dob = data.chardata.dob


            local gender = data.chardata.gender

            if gender == 0 then 
                gender = 'Male'
            else
                gender = 'Female'
            end

            TriggerServerEvent('np-fw:charactercreate', firstname, lastname, dob, gender)

            sendMessage({createCharacter = created})
        end)
    end

    if data.fetchcharacters then
        events:Trigger("np-fw:fetchPlayerCharacters", nil, function(data)
            if data.err then
                sendMessage({err = data})
                return
            end

            -- why the fuck do I have to do this???
            for k,v in ipairs(data) do
                data["char" .. k] = data[k]
                data[k] = nil
            end

            sendMessage({playercharacters = data})
           
        end)
    end

    if data.deletecharacter then
        if not data.deletecharacter then return end

        events:Trigger("np-fw:deleteCharacter", data.deletecharacter, function(deleted)
            sendMessage({reload = true})
        end)
    end

    if data.selectcharacter then
        events:Trigger("np-fw:selectCharacter", data.selectcharacter, function(data)
           
            if not data.loggedin or not data.chardata then sendMessage({err = {err = true, msg = "There was a problem logging in as that character, if the problem persists, contact an administrator <br/> Cid: " .. tostring(data.selectcharacter)}}) return end

            local LocalPlayer = exports["np-fw"]:getModule("LocalPlayer")
            LocalPlayer:setCurrentCharacter(data.chardata)
            local cid = LocalPlayer:getCurrentCharacter().id
            TriggerEvent('updatecid', cid)
            
            sendMessage({close = true})

            
            SetPlayerInvincible(PlayerPedId(), true)


            TriggerEvent("np-fw:firstSpawn")
            closeMenu()
            Citizen.Wait(5000)
            TriggerEvent("Relog")
            SetNuiFocus(false, false)
            Citizen.Wait(1000)
            SetPlayerInvincible(PlayerPedId(), false)
        end)
    end
end

RegisterNUICallback("nuiMessage", nuiCallBack)

RegisterNetEvent("np-fw:spawnInitialized")
AddEventHandler("np-fw:spawnInitialized", function()
    openMenu()
end)

RegisterNetEvent("updateTimeReturn")
AddEventHandler("updateTimeReturn", function()
    setDate = "" .. 0 .. ""
    sendMessage({date = setDate})
end)

RegisterNetEvent("character:finishedLoadingChar", function(pIsNew)

    if pIsNew then
        TriggerServerEvent('np-doors:requestlatest')
        TriggerEvent("np-weathersync:spawned")
        TriggerEvent("fx:clear")
        TriggerEvent("loadedinafk")
        TriggerEvent("np-hud:EnableHud")
        TriggerServerEvent("commands:player:login")
        TriggerServerEvent('np-scoreboard:AddPlayer')
        TriggerServerEvent('np-adminmenu:AddPlayer')
        TriggerEvent("np-fw:PolyZoneUpdate")
        TriggerServerEvent("server:currentpasses")
        TriggerServerEvent("trucker:returnCurrentJobs")

        TriggerEvent("reviveFunction")	
    else
        -- Main events leave alone 
        TriggerEvent("np-fw:playerSpawned")
        TriggerServerEvent('character:loadspawns')
        TriggerEvent("loadedinafk")
        TriggerEvent("playerSpawned")
        TriggerEvent("np-weathersync:spawned")

        TriggerEvent("fx:clear")
        TriggerServerEvent('tattoos:retrieve')
        TriggerServerEvent('Blemishes:retrieve')
        TriggerServerEvent("currentconvictions")
        TriggerServerEvent("banking-loaded-in")
        TriggerServerEvent('np-doors:requestlatest')
        TriggerServerEvent("np-weapons:getAmmo")
        
        -- Events
        TriggerServerEvent("police:SetMeta")
        TriggerServerEvent("police:getEmoteData")
        TriggerServerEvent("server:currentpasses")
        TriggerServerEvent("commands:player:login")
        TriggerServerEvent("retreive:licenes:server")


        -- Jail
        TriggerServerEvent("retreive:jail",exports["np_handler"]:isPed("cid"))

        -- shit
        TriggerServerEvent("asset_portals:get:coords")
        TriggerServerEvent('np-scoreboard:AddPlayer')
        TriggerServerEvent('np-adminmenu:AddPlayer')
        TriggerServerEvent("police:getAnimData")
        TriggerServerEvent("trucker:returnCurrentJobs")
        TriggerEvent("np-fw:PolyZoneUpdate")
        TriggerEvent("reviveFunction")
        TriggerServerEvent("login:get:keys", exports["np_handler"]:isPed("cid"))
        TriggerEvent('np-hud:getPercentages')
    end
end)



RegisterNetEvent("np-login:finishedClothing")
AddEventHandler("np-login:finishedClothing", function(endType)
    local src = source
    local playerped = PlayerPedId()
    local playerCoords = GetEntityCoords(playerped)
    local pos = vector3(-470.23648071289, -675.15026855469, 11.805932044983)
    local distance = #(playerCoords - pos)
    if distance <= 10 then
    	if endType == "Finished" then
            TriggerEvent("iciest :afk:update", false)
            TriggerEvent("np-clothingmenu:Spawning", false)
            DestroyAllCams(true)
            RenderScriptCams(false, true, 1, true, true)
            TriggerServerEvent("character:new:character", exports["np_handler"]:isPed("cid"))
    	else
    		TriggerEvent("np-fw:RefreshSpawn")
    	end
    end	
end)

RegisterCommand("login", function()
    --local rank = TriggerServerCallback('np-login:getPlayerRank')
    --print(rank)
    --if rank == "user" then return end
    TriggerEvent('fullspawnDisable', false)
    openMenu()
end)