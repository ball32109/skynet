
local skynet = require "skynet"
local sharedata = require "sharedata"
local util = require "util"
local config = require "config"
local mongo = require "mongolib"
local mc = mongo.init(".mongodb",skynet.call,skynet.send)

skynet.start(function()

	-- mc.u3d_0.package:makeindex({id=1},true)
	-- mc.u3d_0:sharecollection("package","id")
	-- mc.u3d_1.package:makeindex({id=1},true)
	-- mc.u3d_1:sharecollection("package","id")
	-- mc.u3d_2.package:makeindex({id=1},true)
	-- mc.u3d_2:sharecollection("package","id")

	-- for i = 0,10 do
	-- 	mc["u3d_"..i].package:makeindex({id=1},true)
	-- 	mc["u3d_"..i]:sharecollection("package","id")
	-- 	for j = 90000,100000 do
	-- 		mc["u3d_"..i].package:insert({id = j,gold = j,diamond = j+1})
	-- 	end
	-- end

	-- config.Scene:find()
	-- config.Scene.name:find()
	local csv = config.init()
	util.dump_table(csv.Scene)
	
	-- local r = mc.test.package:findBatch()
	-- print(#r)
	skynet.register(".world")
end)

skynet.dispatch("lua", function(session, address, cmd , ...)
	command[cmd](...)
end)

