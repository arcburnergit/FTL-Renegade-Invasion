
local time_increment = mods.multiverse.time_increment
local vter = mods.multiverse.vter
local userdata_table = mods.multiverse.userdata_table
local is_first_shot = mods.multiverse.is_first_shot

script.on_internal_event(Defines.InternalEvents.POWER_REQ, function(power, req, state)
	--if power.def.name == "ri_minor_crew_fed_4_cheat" then print("state:"..tostring(state)) end
	if power.def.name == "ri_minor_crew_fed_4_cheat" and not power.crew:OutOfGame() and state == 20 then
		local crewmem = power.crew
		if crewmem.health.first <= 0 or crewmem.bDead then
			state = 1
		end
	end
	--if power.def.name == "ri_minor_crew_fed_4_cheat" then print("end state:"..tostring(state)) end
	return Defines.Chain.CONTINUE, state
end)

script.on_internal_event(Defines.InternalEvents.CREW_LOOP, function(crewmem)
	if crewmem.type == "ri_minor_fed_4" then
		for power in vter(crewmem.extend.crewPowers) do
			local state = power:PowerReady()
			if power.def.name == "ri_minor_crew_fed_4_cheat" and state == 1 then
				print("trigger")
				power:ActivatePower()
				power.powerCharges.first = 0
				print("after trigger")
				--power:ActivateTemporaryPower()
			end
		end
	end
end)

script.on_internal_event(Defines.InternalEvents.ACTIVATE_POWER, function(power, ship)
	if power.def.name == "ri_minor_crew_fed_4_cheat" then 
		print("activate") 
		local crewmem = power.crew
		print(crewmem.health.first)
		print(crewmem.bDead)
		if crewmem.health.first <= 0 or crewmem.bDead then
			crewmem.health.first = 1
			crewmem.bDead = false
			power:ActivateTemporaryPower()
		end
	end
	return Defines.Chain.CONTINUE
end)