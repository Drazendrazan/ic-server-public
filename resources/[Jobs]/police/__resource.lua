-- Manifest

resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'


-- General
client_scripts {
  '@np-remotecalls/client/cl_main.lua',
  'client.lua',
  'client_trunk.lua',
  'evidence.lua',
  'cl_spikes.lua'
}

server_scripts {
  'server.lua',
  '@np-remotecalls/server/sv_main.lua'
}

exports {
	'getIsInService',
	'getIsCop',
	'getIsCuffed'
} 