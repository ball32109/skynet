
local skynet = require "skynet"


skynet.start(function()
	print("game start")

	assert(skynet.newservice("db/mongodb","127.0.0.1:10005"))
	assert(skynet.newservice("world/world"))
end)
