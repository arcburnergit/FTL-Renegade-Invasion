
local time_increment = mods.multiverse.time_increment
local vter = mods.multiverse.vter
local userdata_table = mods.multiverse.userdata_table
local is_first_shot = mods.multiverse.is_first_shot

local offset_point_in_direction = mods.ri.offset_point_in_direction
local get_distance = mods.ri.get_distance

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	local shipManager = Hyperspace.ships(weapon.iShipId)
	local i = 0
	local found = false
	local weaponList = shipManager:GetWeaponList()
	for w in vter(weaponList) do
		if tostring(w) == tostring(weapon) then
			found = true
			break
		end
		i = i + 1
	end

	if i > 0 and weaponList[i - 1].blueprint.name == "RI_MINOR_CRYSTAL_1" then
		if shipManager:HasSystem(10) and shipManager.cloakSystem.bTurnedOn and shipManager:HasAugmentation("CLOAK_FIRE") == 0 and is_first_shot(weapon, true) then
			local timer = shipManager.cloakSystem.timer
			timer.currTime = timer.currTime - timer.currGoal/5
		end
	end
end)

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, function(shipManager, projectile, damage, responce)
	if projectile.extend.name == "RI_MINOR_CRYSTAL_2" then
		projectile.damage.iDamage = projectile.damage.iDamage + 1
	end
	return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	if weapon.blueprint.name == "RI_MINOR_ENGI_3" then
		if weapon.boostLevel >= 3 then
			weapon.boostLevel = 0
			projectile.damage.iIonDamage = projectile.damage.iIonDamage * 2
		else
			weapon.boostLevel = weapon.boostLevel + 1
		end
	end
end)

script.on_internal_event(Defines.InternalEvents.WEAPON_RENDERBOX, function(weapon, cooldown, maxCooldown, firstLine, secondLine, thirdLine)
	if weapon.blueprint.name == "RI_MINOR_ENGI_3" then
		if weapon.boostLevel >= 3 then
			secondLine = "6"
		end
	end
	return Defines.Chain.CONTINUE, firstLine, secondLine, thirdLine
end)

local fed_phantom_dist = 100
script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	if weapon.blueprint.name == "RI_MINOR_FED_2" then
		projectile.table.ri_minor_fed_phantom = {}
		projectile.table.ri_minor_fed_phantom.x = projectile.position.x
		projectile.table.ri_minor_fed_phantom.y = projectile.position.y
		projectile.table.ri_minor_fed_phantom.space = projectile.currentSpace
		projectile.table.ri_minor_fed_phantom.count = 5
	end
end)

	local fed_phantom_shard_blueprint = Hyperspace.Blueprints:GetWeaponBlueprint("RI_MINOR_FED_2_PHANTOM")
	script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, function(shipManager, projectile, location, damage, forceHit, shipFriendlyFire)
		if projectile and (projectile.extend.name == "RI_MINOR_FED_2" or projectile.extend.name == "RI_MINOR_FED_2_PHANTOM") and projectile.table.ri_minor_fed_phantom then
			local spaceManager = Hyperspace.App.world.space
			local projectileNew = spaceManager:CreateLaserBlast(
				fed_phantom_shard_blueprint,
				Hyperspace.Pointf(projectile.table.ri_minor_fed_phantom.x + math.random(-50, 50), projectile.table.ri_minor_fed_phantom.y + math.random(-50, 50)),
				projectile.table.ri_minor_fed_phantom.space,
				projectile.ownerId,
				shipManager:GetRandomRoomCenter(),
				projectile.destinationSpace,
				0
				)
			projectile.table.ri_minor_fed_phantom.count = projectile.table.ri_minor_fed_phantom.count - 1
			if projectile.table.ri_minor_fed_phantom.count >= 1 then
				projectileNew.table.ri_minor_fed_phantom = projectile.table.ri_minor_fed_phantom
			end
		end
		return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
	end)
