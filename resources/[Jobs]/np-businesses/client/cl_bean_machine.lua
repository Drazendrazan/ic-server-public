RegisterNetEvent("bean:register")
AddEventHandler("bean:register", function(registerID)
    local myJob = exports["np_handler"]:isPed("myJob")
    if myJob == "bean_machine" then
        local order = exports["np-keyboard"]:KeyboardInput({
            header = "Create Receipt",
            rows = {
                {
                    id = 0,
                    txt = "Amount"
                },
                {
                    id = 1,
                    txt = "Comment"
                }
            }
        })
        if order then
            TriggerServerEvent("bean:OrderComplete", registerID, order[1].input, order[2].input)
        end
    else
        TriggerEvent("DoLongHudText", "You cant use this", 2)
    end
end)

RegisterNetEvent("bean:get:receipt")
AddEventHandler("bean:get:receipt", function(registerid)
    TriggerServerEvent('bean:retreive:receipt', registerid)
end)