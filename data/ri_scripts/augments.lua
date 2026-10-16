
local time_increment = mods.multiverse.time_increment
local vter = mods.multiverse.vter
local userdata_table = mods.multiverse.userdata_table
local is_first_shot = mods.multiverse.is_first_shot

local laser_weapon_lists = {}
laser_weapon_lists["LASER_BURST_3"] = true
laser_weapon_lists["LASER_BURST_5"] = true
laser_weapon_lists["LASER_BURST_8"] = true
laser_weapon_lists["LASER_HULL_2"] = true
laser_weapon_lists["LASER_HULL_3"] = true
laser_weapon_lists["LASER_HULL_3_PLAYER"] = true
laser_weapon_lists["LASER_PIERCE"] = true
laser_weapon_lists["LASER_PIERCE_2"] = true
laser_weapon_lists["LASER_CHAINGUN_DAMAGE"] = true
laser_weapon_lists["LASER_FIRE"] = true
laser_weapon_lists["LASER_FROST_1"] = true
laser_weapon_lists["LASER_FROST_2"] = true
laser_weapon_lists["LASER_FROST_2_PLAYER"] = true


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	local shipManager = Hyperspace.ships(weapon.iShipId)
	if shipManager:HasAugmentation("RI_MINOR_FED_1") > 0 and laser_weapon_lists[weapon.blueprint.name] and is_first_shot(weapon, true) and not weapon.table.ri_minor_fed_skip_next_check then
		local spaceManager = Hyperspace.App.world.space
		local projectileNew = spaceManager:CreateLaserBlast(
			weapon.blueprint,
			projectile.position,
			projectile.currentSpace,
			projectile.ownerId,
			projectile.target,
			projectile.destinationSpace,
			projectile.heading
			)
		spaceManager.projectiles:pop_back()
		projectileNew.entryAngle = projectile.entryAngle
		weapon.queuedProjectiles:push_back(projectileNew)
		weapon.table.ri_minor_fed_skip_next_check = true
	elseif weapon.table.ri_minor_fed_skip_next_check then
		weapon.table.ri_minor_fed_skip_next_check = false
	end
end)