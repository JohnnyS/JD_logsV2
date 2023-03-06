fx_version 'cerulean'
lua54 'yes'
game 'gta5'

version '2.1.7.12b'
author 'Prefech'
description 'FXServer logs to Discord (https://prefech.com/)'
repository 'https://github.com/prefech/JD_logs'

-- Server Scripts
server_scripts {
    'server/server.lua',
    'server/functions.lua',
    'server/explotions.lua',
    'server/serverAC.lua',
    'config/notifications.lua'
}

--Client Scripts
client_scripts {
    'client/client.lua',
    'client/functions.lua',
    'client/weapons.lua',
    'client/clientAC.lua'
}

files {
    'config/eventLogs.json',
    'config/config.json',
    'locals/*.json'
}