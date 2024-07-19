-- DO NOT EDIT ANYTHING HERE

--LoadAddOn("Blizzard_DebugTools")
aura_env.mount_delay = 0.35
aura_env.timerActive = false
aura_env.primaryStat, aura_env.primaryToken = 0, "Primary"

aura_env.disp_order = {}

aura_env.stat_names =
	{ "primary", "haste", "crit", "mastery", "vers", "block", "dodge", "leech", "speed", "armor", "avoidance", "parry" }

for i, s in pairs(aura_env.stat_names) do
	local o = aura_env.config.order[s]
	if o and type(o) == "number" and o <= 12 and o >= 1 then
		aura_env.disp_order[o] = s
	end
end

-- formatters to be used to show % vs raw values
aura_env.formatters = {
	haste = not aura_env.config.rawvalues["haste"] and "Haste: %.2f%%" or "Haste: %d",
	crit = not aura_env.config.rawvalues["crit"] and "Crit: %.2f%%" or "Crit: %d",
	vers = not aura_env.config.rawvalues["vers"] and "Vers: %.2f%% / %.2f%%" or "Vers: %d",
	mastery = not aura_env.config.rawvalues["mastery"] and "Mastery: %.2f%%" or "Mastery: %d",
	leech = not aura_env.config.rawvalues["leech"] and "Leech: %.2f%%" or "Leech: %d",
	avoidance = not aura_env.config.rawvalues["avoidance"] and "Avoidance: %.2f%%" or "Avoidance: %d",
	parry = not aura_env.config.rawvalues["parry"] and "Parry: %.2f%%" or "Parry: %d",
}

aura_env.calcSpeed = function()
	local stolenShadehound = 1
	local cur, run, fly, swim = GetUnitSpeed("player")
	local s

	-- In The Maw, the Stolen Shadehound is not considered "mount" so this hack is added to account for speed increase
	if GetAreaText() == "The Maw" then
		local name, _, _, _, _, _, source, _, _, buffSpellID = WA_GetUnitBuff("player", 338659)
		if name ~= nil and buffSpellID ~= nil then
			stolenShadehound = 2 -- 100% speed buff
		end
	end

	if cur ~= 0 then
		s = cur
	else
		if IsFlying() then
			s = fly
		elseif IsSwimming() then
			s = swim
		else
			s = run
		end
	end
	if s then
		return s / 7 * 100 * stolenShadehound
	else
		return 0
	end
end

aura_env.calcPrimaryStat = function()
	local currentSpec = GetSpecialization()
	local primaryToken = aura_env.primaryToken
	local mainStatID, roleToken

	if currentSpec then
		local id, _
		id, _, _, _, _, mainStatID = GetSpecializationInfo(currentSpec)
		if id then
			roleToken = GetSpecializationRoleByID(id)

			if mainStatID == 1 then
				primaryToken = "Strength"
			elseif mainStatID == 2 then
				primaryToken = "Agility"
			elseif mainStatID == 4 then
				primaryToken = "Intellect"
			end
		end
	end

	if roleToken ~= nil then
		local stat, effectiveStat, _, _ = UnitStat("player", mainStatID)
		if effectiveStat == nil then
			effectiveStat = 0
		end
		return effectiveStat, primaryToken
	end
end

aura_env.primaryColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["primary"][4] * 255,
	aura_env.config.colors["primary"][1] * 255,
	aura_env.config.colors["primary"][2] * 255,
	aura_env.config.colors["primary"][3] * 255
)

aura_env.hasteColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["haste"][4] * 255,
	aura_env.config.colors["haste"][1] * 255,
	aura_env.config.colors["haste"][2] * 255,
	aura_env.config.colors["haste"][3] * 255
)

aura_env.dodgeColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["dodge"][4] * 255,
	aura_env.config.colors["dodge"][1] * 255,
	aura_env.config.colors["dodge"][2] * 255,
	aura_env.config.colors["dodge"][3] * 255
)

aura_env.masteryColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["mastery"][4] * 255,
	aura_env.config.colors["mastery"][1] * 255,
	aura_env.config.colors["mastery"][2] * 255,
	aura_env.config.colors["mastery"][3] * 255
)

aura_env.critColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["crit"][4] * 255,
	aura_env.config.colors["crit"][1] * 255,
	aura_env.config.colors["crit"][2] * 255,
	aura_env.config.colors["crit"][3] * 255
)

aura_env.versatilityColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["versatility"][4] * 255,
	aura_env.config.colors["versatility"][1] * 255,
	aura_env.config.colors["versatility"][2] * 255,
	aura_env.config.colors["versatility"][3] * 255
)

aura_env.speedColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["speed"][4] * 255,
	aura_env.config.colors["speed"][1] * 255,
	aura_env.config.colors["speed"][2] * 255,
	aura_env.config.colors["speed"][3] * 255
)

aura_env.leechColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["leech"][4] * 255,
	aura_env.config.colors["leech"][1] * 255,
	aura_env.config.colors["leech"][2] * 255,
	aura_env.config.colors["leech"][3] * 255
)

aura_env.blockColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["block"][4] * 255,
	aura_env.config.colors["block"][1] * 255,
	aura_env.config.colors["block"][2] * 255,
	aura_env.config.colors["block"][3] * 255
)

aura_env.armorColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["armor"][4] * 255,
	aura_env.config.colors["armor"][1] * 255,
	aura_env.config.colors["armor"][2] * 255,
	aura_env.config.colors["armor"][3] * 255
)

aura_env.avoidanceColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["avoidance"][4] * 255,
	aura_env.config.colors["avoidance"][1] * 255,
	aura_env.config.colors["avoidance"][2] * 255,
	aura_env.config.colors["avoidance"][3] * 255
)

aura_env.parryColor = string.format(
	"|c%.2x%.2x%.2x%.2x",
	aura_env.config.colors["parry"][4] * 255,
	aura_env.config.colors["parry"][1] * 255,
	aura_env.config.colors["parry"][2] * 255,
	aura_env.config.colors["parry"][3] * 255
)
