
local skynet = require "skynet"
local sharedata = require "sharedata"
local csv2table = require "csv2table"
local util = require "util"
local config = require "config"

local command = {}

function command.start()
    print("game start")
    sharedata.new("Scene",{Scene = csv2table.load("Scene.csv")})
    local cfg = config.load({Scene = csv2table.load("Scene.csv")})
    -- util.dump_table(cfg["Scene"]["2000"])
    for k,v in pairs(cfg["Scene"]["2000"]["born"]) do
        print(type(k),type(v))
        print(k)
        if type(v) == "table" then
            util.dump_table(v)
        end
    end
    -- config.Scene:find()
    -- assert(skynet.newservice("db/mongodb","127.0.0.1:10009"))
    assert(skynet.newservice("world/world"))

end

function command.stop( ... )
    -- body
end

skynet.start(function()
    skynet.dispatch("lua", function(session, address, cmd , ...)
        command[cmd](...)
    end)
    skynet.register(".game")
end)
