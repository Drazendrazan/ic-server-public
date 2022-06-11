

RegisterServerEvent("NetworkNos")
AddEventHandler("NetworkNos", function()
    local pSrc = source
    TriggerClientEvent("NetworkNos", tonumber(pSrc))
end)


RegisterServerEvent("vehicleMod:applyHarness")
AddEventHandler("vehicleMod:applyHarness", function(pPlate, pDurability)
    local pSrc = source
    if pPlate and pDurability ~= nil then
        exports.ghmattimysql:execute('SELECT * FROM __vehiclemods WHERE license_plate = ?', {pPlate}, function(result) 
            if result[1] ~= nil then
                TriggerClientEvent("DoLongHudText", pSrc, "This vehicle already has a harness installed already", 2)
            else
                local cols = 'license_plate, durability'
                local val = '@license_plate, @durability'
                exports.ghmattimysql:execute('INSERT INTO __vehiclemods ( '..cols..' ) VALUES ( '..val..' )',{
                    ['@license_plate'] = pPlate,
                    ['@durability'] = pDurability
                })
                TriggerClientEvent("vehicleMod:setHarness", pSrc, pDurability, true)
                TriggerClientEvent("DoLongHudText", pSrc, "Harness Installed", 1)
                TriggerClientEvent("inventory:removeItem", pSrc, "harness", 1)
            end
        end)
    else
        return
    end
end)


RegisterServerEvent("vehicleMod:getHarness")
AddEventHandler("vehicleMod:getHarness", function(pPlate)
    local pSrc = source
    if pPlate ~= nil then
        exports.ghmattimysql:execute('SELECT * FROM __vehiclemods WHERE license_plate = ?', {pPlate}, function(result) 
            if result[1] ~= nil then
                TriggerClientEvent("vehicleMod:setHarness", pSrc, result[1].durability, false)
                TriggerClientEvent("harness:dir", pSrc, result[1].durability)
            else
                return
            end
        end)
    end
end)


RegisterServerEvent("vehicleMod:updateHarness")
AddEventHandler("vehicleMod:updateHarness", function(pPlate, pDurability)
    local pSrc = source
    if pPlate ~= nil then
        exports.ghmattimysql:execute('SELECT * FROM __vehiclemods WHERE license_plate = ?', {pPlate}, function(result) 
            if result[1] ~= nil then
                TriggerClientEvent("harness:dir", pSrc, pDurability)
                exports.ghmattimysql:execute('UPDATE __vehiclemods SET durability = ? WHERE license_plate = ?', {pDurability, pPlate})
                Citizen.Wait(100)
                exports.ghmattimysql:execute('SELECT * FROM __vehiclemods WHERE license_plate = ?', {pPlate}, function(pAfterData) 
                    if pAfterData[1].durability == 0.0 then
                        exports.ghmattimysql:execute('DELETE FROM __vehiclemods WHERE license_plate = ?', {pPlate})
                    end
                end)
            else
                return
            end
        end)
    end
end)