fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

author 'Wartype'
description 'A tool for visualizing prop placement'
version '0.1'


shared_scripts {
    'config.lua'
}
exports {
    'visualizePlacement'
}
client_scripts {
    'client/*.lua'
}

dependency 'rsg-core'

lua54 'yes'
