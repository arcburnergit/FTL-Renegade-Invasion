local version = {major = 1, minor = 23}
if not (Hyperspace.version and Hyperspace.version.major == version.major and Hyperspace.version.minor >= version.minor) then
	error("Incorrect Hyperspace version detected! The Renegade Invasion requires Hyperspace "..version.major.."."..version.minor.."+")
end
mods.ri = {}
local time_increment = mods.multiverse.time_increment
local vter = mods.multiverse.vter
local userdata_table = mods.multiverse.userdata_table

function mods.ri.offset_point_in_direction(position, angle, offset_forward, offset_left)
    local alpha = math.rad(angle)
    
    local fx = math.cos(alpha)
    local fy = math.sin(alpha)
    
    local lx = fy
    local ly = -fx
    
    local newX = position.x + (offset_forward * fx) + (offset_left * lx)
    local newY = position.y + (offset_forward * fy) + (offset_left * ly)
    
    return Hyperspace.Pointf(newX, newY)
end
local offset_point_in_direction = mods.ri.offset_point_in_direction

function mods.ri.get_distance(point1, point2)
	return math.sqrt(((point2.x - point1.x)^ 2)+((point2.y - point1.y) ^ 2))
end
local get_distance = mods.ri.get_distance