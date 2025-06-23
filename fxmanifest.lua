fx_version 'cerulean'
game 'gta5'

author 'Redlife'
description 'Système YouTube avec historique et thème Redlife'
version '1.1.0'

ui_page 'ui.html'

client_scripts {
    '@es_extended/locale.lua',
    'cl_youtube.lua'
}

server_scripts {
    '@es_extended/locale.lua',
    '@mysql-async/lib/MySQL.lua',
    'sv_youtube.lua'
}

files {
    'ui.html',
    'ui.css',
    'redlife-logo.png'
}

dependencies {
    'es_extended',
    'mysql-async'
}