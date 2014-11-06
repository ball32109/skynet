local mongo = require "mongo"
local skynet = require "skynet"

local args = ...
local host,port = string.match(args,"(%w+.%w+.%w+.%w+):(%d+)")
local client
local db
local command = {}

function connect(host,port)
	client = mongo.client({host = host , port = port})
	db = client:getDB("u3d")
end

function command.findOne(args)
	
	local c = db:getCollection(args.collection)
	local result = c:findOne(args.query,args.selector)
	skynet.ret(skynet.pack(result))
end

function command.findAll(args)
	local db = client:getDB(args.database)
	local c = db:getCollection(args.collection)
	local result = {}
	local documents = c:find(args.query, args.selector)
	while documents:hasNext(args.limit,args.skip) do
		local document = documents:next()
		document._id = nil
		table.insert(result,document)
	end	
	documents:close()
	if #result == 0 then
		skynet.ret(skynet.pack(nil))
	else
		skynet.ret(skynet.pack(result))
	end
end

local batch_ctx = {}
local batch_index = 0
function command.findBatch(args)
	batch_index = batch_index + 1

	local db = client:getDB(args.database)
	local c = db:getCollection(args.collection)

	local result = {}
	local count = 0

	local documents = c:find(args.query, args.selector)
	while documents:hasNext(args.limit,args.skip) do
		local document = documents:next()
		document._id = nil
		table.insert(result,document)

		count = count + 1

		if count == args.limit then
			skynet.ret(skynet.pack({result = result,next = true,index = batch_index}))
			batch_ctx[batch_index] = {doc = documents,limit = args.limit,skip = args.skip}
			return
		end
	end	
	documents:close()

	skynet.ret(skynet.pack({result = result,next = false,index = batch_index}))
	batch_ctx[batch_index] = nil
end

function command.nextBatch(args)
	local result = {}
	local count = 0

	local batch = batch_ctx[args.index]
	while batch.doc:hasNext(batch.limit,batch.skip) do
		local document = batch.doc:next()
		document._id = nil
		table.insert(result,document)

		count = count + 1
		
		if count == batch.limit then
			skynet.ret(skynet.pack({result = result,next = true,index = batch.index}))
			return
		end
	end	
	batch.doc:close()

	skynet.ret(skynet.pack({result = result,next = false,index = batch.index}))
	batch_ctx[args.index] = nil
end

function command.findLimit(args)
	local d,collection = string.match(args.collection,"(%w+).(.*)")
	local c = db:getCollection(collection)
	local result = {}
	local documents = c:find(args.query, args.selector)
	while documents:hasNext(args.limit,args.skip) do
		local document = documents:next()
		document._id = nil
		table.insert(result,document)
		if #result >= args.limit then
			break
		end
	end	
	documents:close()
	if #result == 0 then
		skynet.ret(skynet.pack(nil))
	else
		skynet.ret(skynet.pack(result))
	end
end

function command.save(args)

end

function command.update(args)
	local d,collection = string.match(args.collection,"(%w+).(.*)")
	local c = db:getCollection(collection)
	c:update(args.selector,args.update,args.upsert,args.multi)
end

function command.insert(args)
	local d,collection = string.match(args.collection,"(%w+).(.*)")
	local c = db:getCollection(collection)
	c:insert(args.doc)
end

function command.delete(args)
	local d,collection = string.match(args.collection,"(%w+).(.*)")
	local c = db:getCollection(collection)
	c:delete(args.selector, args.single)
end

function command.runCommand(args)
	local result = db:runCommand(args)
	skynet.ret(skynet.pack(result))
end

function command.clearMem()
	local admin = client:getDB("admin")
	local r = admin:runCommand({{closeAllDatabases = 1}})
	print("closeAllDatabases:")
	global.dump_table(r)
end

function command.stop()
	print("mongodb ready to stop")
	while true do
		print("mongodb mqlen:"..skynet.mqlen())
		if skynet.mqlen() == 0 then
			client:disconnect()
			print("mongodb has stop")
			break
		end
		skynet.sleep(10)
	end
	skynet.ret(skynet.pack(true))
end

skynet.start(function()
	skynet.dispatch("lua",function(session,address,cmd,message)
		local f = command[cmd]
		if f then
			f(message)
		else
			error(string.format("[mongodb] Unknown command : %s",cmd))
		end

	end)
	connect(host,port)
	skynet.register(".mongodb")
end)
