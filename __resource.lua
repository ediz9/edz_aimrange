resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

server_script {
	'@mysql-async/lib/MySQL.lua',
	'server.lua'
}

client_script {
	'client.lua'
}

shared_script {
    'config.lua'
}
