local skynet = require "skynet"

local max_client = 64



skynet.start(function()
	print("Server start")
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",1989)
	skynet.newservice("simpledb")
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		nodelay = true,
	})
	print("Watchdog listen on ", 8888)
    local game = skynet.newservice("game_main")
    skynet.send(".game","lua","start")
	skynet.exit()
end)
