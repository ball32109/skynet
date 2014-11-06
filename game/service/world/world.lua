
local skynet = require "skynet"
local util = require "util"
local mongo = require "mongolib"
local mc = mongo.init(".mongodb",skynet.call,skynet.send)

skynet.start(function()
	local r = mc.u3d.role:findAll()
	util.dump_table(r)
	skynet.register(".world")
end)

skynet.dispatch("lua", function(session, address, cmd , ...)
	command[cmd](...)
end)

