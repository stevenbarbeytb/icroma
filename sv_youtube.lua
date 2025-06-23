ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Sauvegarder l'historique
RegisterServerEvent('redlife_youtube:saveHistory')
AddEventHandler('redlife_youtube:saveHistory', function(videoId, videoTitle)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer then
        MySQL.Async.execute('INSERT INTO redlife_youtube_history (identifier, video_id, video_title) VALUES (@identifier, @video_id, @video_title)', {
            ['@identifier'] = xPlayer.identifier,
            ['@video_id'] = videoId,
            ['@video_title'] = videoTitle
        })
    end
end)

-- Récupérer les paramètres
ESX.RegisterServerCallback('redlife_youtube:getSettings', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchAll('SELECT volume, theme_color FROM redlife_youtube_settings WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            cb(result[1])
        else
            cb({volume = 50, theme_color = '#ff0000'}) -- Default Redlife theme
        end
    end)
end)

-- Sauvegarder le volume
RegisterServerEvent('redlife_youtube:saveVolume')
AddEventHandler('redlife_youtube:saveVolume', function(volume)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.execute('INSERT INTO redlife_youtube_settings (identifier, volume) VALUES (@identifier, @volume) ON DUPLICATE KEY UPDATE volume = @volume', {
        ['@identifier'] = xPlayer.identifier,
        ['@volume'] = volume
    })
end)

-- Récupérer l'historique
ESX.RegisterServerCallback('redlife_youtube:getHistory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchAll('SELECT video_id, video_title, watched_at FROM redlife_youtube_history WHERE identifier = @identifier ORDER BY watched_at DESC LIMIT 10', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        cb(result)
    end)
end)