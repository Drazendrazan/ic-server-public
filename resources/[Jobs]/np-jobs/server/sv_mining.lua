
RegisterServerEvent("mining-sell:items", function(pAmount, pItem)
  local pSrc = source
  local user = exports["np-fw"]:getModule("Player"):GetUser(pSrc)

  if pAmount <= 0 then
    TriggerClientEvent("DoLongHudText", pSrc, "You dont have anything to sell", 2)
    return
  end

  if pItem == "goldbar" then
    Payment = math.random(35, 45)
  elseif pItem == "silverbar" then
    Payment = math.random(35, 45)
  elseif pItem == "copperbar" then
    Payment = math.random(35, 45)
  elseif pItem == "ironbar" then
    Payment = math.random(35, 45)
  end

  if Payment then
    TriggerClientEvent("inventory:removeItem", pSrc, pItem, pAmount)
    Citizen.Wait(100)
    user:addMoney(pAmount*Payment)
  end
end)