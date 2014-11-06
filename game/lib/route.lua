
local route = {}

local req = {}
local rsp = {}
local client_fd

function route.init(client_fd)
	client_fd = client_fd
end

function route.register_req(type,route_table)
	-- body
end

function route.register_rsp( ... )
	-- body
end


function route.dispatch(session,address,type,id_or_cmd,message)
	-- body
end

function route.send( ... )
	-- body
end

function route.broadcast( ... )
	-- body
end


return route
