fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
 
author 'riversafe'
description 'pause Menu script'
version '1.0.0'
lua54 'yes'

client_scripts {
    'Config.lua',
    'Client/*.lua'
}
 
server_scripts {
    'Config.lua',
    'Server/*.lua'
}

ui_page {
    'html/index.html', 
}

files {
    'html/logo.png',
    'html/pausebook.png',
    'html/index.html',
} 