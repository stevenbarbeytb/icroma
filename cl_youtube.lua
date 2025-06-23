local isOpen = false
local currentVideo = ""
local browser = nil
local isPlaying = false
local currentVolume = 50
local history = {}
local themeColor = '#ff0000' -- Couleur Redlide par défaut

-- Commandes
RegisterCommand("youtube", function()
    if not isOpen then
        OpenYouTube()
    else
        CloseYouTube()
    end
end, false)

RegisterKeyMapping('yt_playpause', 'Play/Pause YouTube', 'keyboard', 'space')
RegisterCommand('yt_playpause', function()
    if isOpen then TogglePlayPause() end
end)

RegisterKeyMapping('yt_volup', 'Volume + YouTube', 'keyboard', 'NUMPAD+')
RegisterCommand('yt_volup', function()
    if isOpen then AdjustVolume(5) end
end)

RegisterKeyMapping('yt_voldown', 'Volume - YouTube', 'keyboard', 'NUMPAD-')
RegisterCommand('yt_voldown', function()
    if isOpen then AdjustVolume(-5) end
end)

-- Fonction principale
function OpenYouTube()
    ESX.TriggerServerCallback('redlife_youtube:getSettings', function(settings)
        currentVolume = settings.volume
        themeColor = settings.theme_color or '#ff0000'
        
        ESX.TriggerServerCallback('redlife_youtube:getHistory', function(hist)
            history = hist
            isOpen = true
            
            -- Création du browser
            browser = CreateDui("https://www.youtube.com/embed/", 800, 600)
            local dui = GetDuiHandle(browser)
            local txd = CreateRuntimeTxd("youtube")
            CreateRuntimeTextureFromDuiHandle(txd, "yt", dui)
            
            -- Envoyer les données à l'UI
            SendNUIMessage({
                type = "open",
                volume = currentVolume,
                themeColor = themeColor,
                history = history
            })
            
            SetNuiFocus(true, true)
            SetDuiVolume(browser, currentVolume / 100)
            
            -- Création du téléviseur (à adapter)
            local tv = CreateObject(GetHashKey("prop_tv_flat_01"), 0.0, 0.0, 0.0, true, true, true)
            SetEntityCoords(tv, -1104.0, -282.0, 37.0)
            FreezeEntityPosition(tv, true)
        end)
    end)
end

-- Fonctions de contrôle
function TogglePlayPause()
    isPlaying = not isPlaying
    SendDuiMessage(browser, json.encode({
        type = "control",
        action = isPlaying and "play" or "pause"
    }))
    SendNUIMessage({
        type = "playState",
        playing = isPlaying
    })
end

function AdjustVolume(change)
    currentVolume = math.max(0, math.min(100, currentVolume + change))
    SetDuiVolume(browser, currentVolume / 100)
    SendNUIMessage({
        type = "volumeChange",
        volume = currentVolume
    })
    TriggerServerEvent('redlife_youtube:saveVolume', currentVolume)
end

function CloseYouTube()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({type = "close"})
    
    if browser then
        DestroyDui(browser)
        browser = nil
    end
end

-- NUI Callbacks
RegisterNUICallback("loadVideo", function(data, cb)
    currentVideo = data.videoId
    local url = "https://www.youtube.com/embed/"..currentVideo.."?enablejsapi=1"
    SetDuiUrl(browser, url)
    isPlaying = true
    
    -- Sauvegarder dans l'historique
    TriggerServerEvent('redlife_youtube:saveHistory', currentVideo, data.videoTitle)
    
    -- Mettre à jour l'historique local
    table.insert(history, 1, {
        video_id = currentVideo,
        video_title = data.videoTitle,
        watched_at = os.date("%Y-%m-%d %H:%M:%S")
    })
    if #history > 10 then table.remove(history, 11) end
    
    cb({})
end)

RegisterNUICallback("control", function(data, cb)
    if data.action == "playpause" then
        TogglePlayPause()
    elseif data.action == "volup" then
        AdjustVolume(5)
    elseif data.action == "voldown" then
        AdjustVolume(-5)
    end
    cb({})
end)

RegisterNUICallback("close", function(data, cb)
    CloseYouTube()
    cb({})
end)