

local _SQRT = math.sqrt
local _EXP = math.exp

local vector2 = {}

function vector2.scale(vt,sl)
	return {x = vt.x * sl,y = vt.y * sl}
end

function vector2.dot(vt1,vt2)
	-- body
end

function vector2.angle(vt1,vt2)
	-- body
end

function vector2.magnitude(vt)
	return _SQRT(_EXP(vt.x,2) + _EXP(vt.y,2))
end

function vector2.normalized(vt)
	local mg = vector2.magnitude(vt)
	return {x = vt.x / mg,y = vt.y / mg}
end

function vector2.distance(vt1,vt2)
	return _SQRT(_EXP(vt1.x - vt2.x,2) + _EXP(vt1.y - vt2.y,2))
end

function vector2.movetowards(vt1,vt2,max_distance)
	local distance = vector2.distance(vt1,vt2)
	if distance <= max_distance then
		return {x = vt2.x,y = vt2.y}
	end

	local x = vt2.x - (vt2.x - vt1.x) * ((distance - max_distance) / distance)
	local y = vt2.y - (vt2.y - vt1.y) * ((distance - max_distance) / distance)

	return {x = x,y = y}
end

return vector2