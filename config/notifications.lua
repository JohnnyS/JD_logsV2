Notify = {}

Notify.Success = function(target, text) --You should probably change this to what you need it to be
    TriggerClientEvent('ox_lib:notify', target, { 
       type = 'success', 
       position = 'top',
       duration = 5000, 
       description = text,
    })
end

Notify.Error = function(target, text)
    TriggerClientEvent('ox_lib:notify', target, { 
        type = 'error', 
        position = 'top',
        duration = 5000, 
        description = text,
     })
end

Notify.Custom = function(target, title, text)
    TriggerClientEvent('ox_lib:notify', target, { 
        type = 'inform', 
        position = 'top',
        duration = 5000,
        title = title,
        description = text,
     })
end