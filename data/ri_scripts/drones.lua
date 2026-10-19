local time_increment = mods.multiverse.time_increment
local vter = mods.multiverse.vter
local userdata_table = mods.multiverse.userdata_table
local is_first_shot = mods.multiverse.is_first_shot
local spawn_temp_drone = mods.multiverse.spawn_temp_drone

local offset_point_in_direction = mods.ri.offset_point_in_direction
local get_distance = mods.ri.get_distance
local get_adjacent_rooms = mods.ri.get_adjacent_rooms
local get_room_at_location = mods.ri.get_room_at_location

local dynasty_jump_beams = {}
dynasty_jump_beams["DRONE_FIREBEAM_RI_MINOR_DYNASTY_1"] = Hyperspace.Blueprints:GetWeaponBlueprint("DRONE_FIREBEAM_RI_MINOR_DYNASTY_1_JUMP")
dynasty_jump_beams["DRONE_HULLBEAM_RI_MINOR_DYNASTY_1"] = Hyperspace.Blueprints:GetWeaponBlueprint("DRONE_HULLBEAM_RI_MINOR_DYNASTY_1_JUMP")

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(shipManager, projectile, location, damage, realNewTile, beamHitType)
	if beamHitType == Defines.BeamHit.NEW_ROOM and dynasty_jump_beams[projectile.extend.name] and math.random() >= 0.5 then
		local ad_rooms = get_adjacent_rooms(shipManager.iShipId, get_room_at_location(shipManager, location, false), false)
		local random_room_list = {}
		for roomId, roomPos in pairs(ad_rooms) do
			table.insert(random_room_list, roomPos)
		end
		if #random_room_list > 0 then
			local random_room_loc = random_room_list[math.random(#random_room_list)]
			local spaceManager = Hyperspace.App.world.space
			local beam = spaceManager:CreateBeam(
				dynasty_jump_beams[projectile.extend.name], 
				projectile.target, 
				projectile.destinationSpace, 
				projectile.ownerId, 
				Hyperspace.Pointf(random_room_loc.x, random_room_loc.y - 5), 
				Hyperspace.Pointf(random_room_loc.x, random_room_loc.y + 5), 
				projectile.destinationSpace, 
				10, 
				-0.1)
		end
	end
	return Defines.Chain.CONTINUE, beamHitType
end)

script.on_internal_event(Defines.InternalEvents.POWER_REQ, function(power, req, state)
	if power.def.name == "ri_minor_crew_engi_1_defend_power" and not power.crew:OutOfGame() and state ~= 0 then
		state = 1
		local crewmem = power.crew
		local shipManager = Hyperspace.ships(crewmem.currentShipId)
		for crew in vter(shipManager.vCrewList) do
			if crew.iShipId ~= crewmem.iShipId and crew.iRoomId == crewmem.iRoomId then
				state = 5
				break
			end
		end
	end
	return Defines.Chain.CONTINUE, state
end)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
	if shipManager:HasSystem(4) then
		for drone in vter(shipManager.droneSystem.drones) do
			--print(drone.pause)
			--print(drone.additionalPause)
			if (not drone:GetDeployed() or drone.bDead) and drone.table.ri_minor_dynasty_timer then
				drone.table.ri_minor_dynasty_timer = nil
			end
			if drone.blueprint.name == "RI_MINOR_DYNASTY_2" and drone.pause <= 0 and drone.additionalPause <= 0 and drone:GetDeployed() and not drone.bDead then
				if not drone.table.ri_minor_dynasty_timer then
					drone.table.ri_minor_dynasty_timer = 0
				end
				drone.table.ri_minor_dynasty_timer = drone.table.ri_minor_dynasty_timer + time_increment(true)
				if drone.table.ri_minor_dynasty_timer >= 5 then
					for i = 1, math.floor(math.min(20, drone.table.ri_minor_dynasty_timer)) do
						drone:OnLoop()
					end
				end
			end
		end
	end
end)
script.on_internal_event(Defines.InternalEvents.ON_TICK, function()
	local spaceManager = Hyperspace.App.world.space
	for drone in vter(spaceManager.drones) do
		if drone.blueprint.name == "RI_MINOR_ENGINEER_1_SUBDRONE" and (not drone.bDead) and not drone.table.ri_minor_engineer_is_subdrone then
			drone:BlowUp(false)
		end
	end
end)

local subBlueprint = Hyperspace.Blueprints:GetDroneBlueprint("RI_MINOR_ENGINEER_1_SUBDRONE")
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
	if shipManager:HasSystem(4) then
		for drone in vter(shipManager.droneSystem.drones) do
			if (not drone:GetDeployed() or drone.bDead) and drone.table.ri_minor_engineer_subdrone then
				drone.table.ri_minor_engineer_subdrone:BlowUp(false)
				drone.table.ri_minor_engineer_subdrone.table.ri_minor_engineer_parentdrone = nil
				drone.table.ri_minor_engineer_subdrone.table.ri_minor_engineer_is_subdrone = false
				drone.table.ri_minor_engineer_subdrone = nil
			end
			if drone.table.ri_minor_engineer_subdrone and (not drone.table.ri_minor_engineer_subdrone:GetDeployed() or drone.table.ri_minor_engineer_subdrone.bDead) then
				drone.table.ri_minor_engineer_subdrone:BlowUp(false)
				drone.table.ri_minor_engineer_subdrone.table.ri_minor_engineer_parentdrone = nil
				drone.table.ri_minor_engineer_subdrone.table.ri_minor_engineer_is_subdrone = false
				drone.table.ri_minor_engineer_subdrone = nil
				drone:BlowUp(false)
			end
			if drone.table.ri_minor_engineer_subdrone then
				drone.table.ri_minor_engineer_subdrone.powered = drone.powered
			end
			if drone.blueprint.name == "RI_MINOR_ENGINEER_1" and drone:GetDeployed() and not drone.bDead then
				if not drone.table.ri_minor_engineer_subdrone then
					local temp = spawn_temp_drone(subBlueprint, shipManager, Hyperspace.ships(1-shipManager.iShipId), nil, 999, drone.position)
					drone.table.ri_minor_engineer_subdrone = temp
					drone.table.ri_minor_engineer_subdrone.table.ri_minor_engineer_parentdrone = drone
					drone.table.ri_minor_engineer_subdrone.table.ri_minor_engineer_is_subdrone = true
				end
			end
		end
	end
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(shipManager, projectile, location, damage, realNewTile, beamHitType)
	if beamHitType == Defines.BeamHit.NEW_ROOM then
		local room = get_room_at_location(shipManager, location, true)
		if projectile.table.ri_minor_engineer_reset_beam then
			projectile.table.ri_minor_engineer_reset_beam = nil
			damage.iDamage = damage.iDamage / 2
			damage.iSystemDamage = damage.iSystemDamage / 2
			damage.iIonDamage = damage.iIonDamage / 2
		end
		for crewmem in vter(shipManager.vCrewList) do
			if not (crewmem:OutOfGame() or crewmem.bDead) and crewmem.type == "ri_minor_crew_engineer_2" and crewmem.iRoomId == room then
				damage.iDamage = damage.iDamage * 2
				damage.iSystemDamage = damage.iSystemDamage * 2
				damage.iIonDamage = damage.iIonDamage * 2
				projectile.table.ri_minor_engineer_reset_beam = true
			end
		end
	end
	return Defines.Chain.CONTINUE, beamHitType
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, function(shipManager, projectile, location, damage, forceHit, shipFriendlyFire)
	local room = get_room_at_location(shipManager, location, true)
	for crewmem in vter(shipManager.vCrewList) do
		if not (crewmem:OutOfGame() or crewmem.bDead) and crewmem.type == "ri_minor_crew_engineer_2" and crewmem.iRoomId == room then
			damage.iDamage = damage.iDamage * 2
			damage.iSystemDamage = damage.iSystemDamage * 2
			damage.iIonDamage = damage.iIonDamage * 2
		end
	end
	return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
end)

local drone_laser = Hyperspace.Blueprints:GetWeaponBlueprint("DRONE_LASER_COMBAT")
script.on_internal_event(Defines.InternalEvents.DRONE_FIRE, function(projectile, drone)
	if projectile.extend.name == "DRONE_BEAM_RI_MINOR_FED_3" then
		local spaceManager = Hyperspace.App.world.space
		local projectileNew = spaceManager:CreateLaserBlast(
			drone_laser,
			projectile.position,
			projectile.currentSpace,
			projectile.ownerId,
			projectile.target2,
			projectile.destinationSpace,
			projectile.heading
			)
		projectileNew:ComputeHeading()
		Hyperspace.Sounds:PlaySoundMix("lightLaser1", -1, false)
	end
end)