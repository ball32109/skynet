

local mongo = {}

local mongo_client = {}
local client_meta = {
	__index = function(self, key)
		return rawget(mongo_client, key) or self:getdb(key)
	end,
}

function mongo.init(service,call,send)
	local client = setmetatable({},client_meta)
	client.service = service
	client.call = call
	client.send = send
	return client
end


local mongo_db = {}
local db_meta = {
	__index = function (self, key)
		return rawget(mongo_db, key) or self:getcollection(key)
	end,
	__tostring = function (self)
		return "[mongo db : " .. self.name .. "]"
	end
}

function mongo_client:getdb(dbname)
	local db = {
		service = self.service,
		call = self.call,
		send = self.send,
		database = dbname
	}
	return setmetatable(db, db_meta)
end

local mongo_collection = {}
local collection_meta = {
	__index = function(self, key)
		return rawget(mongo_collection, key) or self:getcollection(key)
	end ,
	__tostring = function (self)
		return "[mongo collection : " .. self.full_name .. "]"
	end
}

function mongo_db:getcollection(collection)
	local col = {
		service = self.service,
		call = self.call,
		send = self.send,
		database = self.database,
		collection = collection
	}
	self[collection] = setmetatable(col,collection_meta)
	return col
end

function mongo_db:sharecollection(collection,key)
	self.send(self.service,"lua","sharecollection",{database = self.database,collection = collection,key = key})
end

function mongo_collection:insert(doc)
	self.send(self.service,"lua","insert",{database = self.database,collection = self.collection,doc = doc})
end

function mongo_collection:update(doc)
	self.send(self.service,"lua","update",{collection = self.full_name,selector = selector,update = update,upsert = upsert,multi = multi})
end

function mongo_collection:delete(doc)
	self.send(self.service,"lua","delete",{collection = self.full_name,selector = selector,single = single})
end

function mongo_collection:findOne(doc)
	return self.call(self.service,"lua","findOne",{collection = self.full_name,query = query,selector = selector})
end

function mongo_collection:findAll(query,selector,limit, skip)
	return self.call(self.service,"lua","findAll",{database = self.database,collection = self.collection,query = query,selector= selector,limit = limit,skip = skip})
end

function mongo_collection:findBatch(query,selector,limit, skip)
	local result = {}
	local donext = true

	local r = self.call(self.service,"lua","findBatch",{database = self.database,collection = self.collection,query = query,selector= selector,limit = limit or 1000,skip = skip})
	donext = r.next

	for _,doc in pairs(r.result) do
		table.insert(result,doc)
	end

	while donext do
		local r = self.call(self.service,"lua","nextBatch",{index = r.index})
		donext = r.next
		for _,doc in pairs(r.result) do
			table.insert(result,doc)
		end
	end
	return result
end

function mongo_collection:makeindex(field,is_unique)
	local name
	for k,v in pairs(field) do
		name = "i_"..k
	end
	local indexes_tb = {
		key = field,
		ns = self.database.."."..self.collection,
		name = name
	}
	if is_unique then
		indexes_tb["unique"] = 1
	end
	self.send(self.service,"lua","insert",{database = self.database,collection = "system.indexes",doc = indexes_tb})
end


return mongo
