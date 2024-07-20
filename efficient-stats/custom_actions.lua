-- DO NOT EDIT ANYTHING HERE

--LoadAddOn("Blizzard_DebugTools")
aura_env.mount_delay = 0.35
aura_env.timerActive = false
aura_env.primaryStat, aura_env.primaryToken = 0, "Primary"
aura_env.level = UnitLevel("player")
aura_env.disp_order = {}

local format = string.format

aura_env.stat_names =
  { "primary", "haste", "crit", "mastery", "vers", "block", "dodge", "leech", "speed", "armor", "avoidance", "parry" }

local firstToUpper = function(str)
  return (str:gsub("^%l", string.upper))
end

for i, s in pairs(aura_env.stat_names) do
  local o = aura_env.config.order[s]
  if o and type(o) == "number" and o <= 12 and o >= 1 then aura_env.disp_order[o] = s end
end

aura_env.raw_stat_names = { "haste", "crit", "vers", "mastery", "leech", "avoidance", "parry", "armor" }

-- formatters to be used to show % and/or raw values
aura_env.formatters = {}

for _, value in ipairs(aura_env.raw_stat_names) do
  local r, p = aura_env.config.rawvalues[value][1], aura_env.config.rawvalues[value][2] -- index 1 is raw and 2 is percentage
  aura_env[value .. "_disp"] = { r = r, p = p }
  local name = firstToUpper(value)
  local is_verse = value == "vers"
  if r and p then
    aura_env.formatters[value] = name .. ": %d (%.2f%%)"
    if is_verse then aura_env.formatters[value] = name .. ": %d (%.2f%% / %.2f%%)" end
  elseif r then
    aura_env.formatters[value] = name .. ": %d"
  else
    aura_env.formatters[value] = name .. ": %.2f%%"
    if is_verse then aura_env.formatters[value] = name .. ": %.2f%% / %.2f%%" end
  end
end

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
    if effectiveStat == nil then effectiveStat = 0 end
    return effectiveStat, primaryToken
  end
end

for _, s in pairs(aura_env.stat_names) do
  aura_env[s .. "Color"] = format(
    "|c%.2x%.2x%.2x%.2x",
    aura_env.config.colors[s][4] * 255,
    aura_env.config.colors[s][1] * 255,
    aura_env.config.colors[s][2] * 255,
    aura_env.config.colors[s][3] * 255
  )
end

-- HASTE
local r, p = aura_env.haste_disp.r, aura_env.haste_disp.p
aura_env["GetHaste"] = function()
  local s
  local format_str = aura_env.hasteColor .. aura_env.formatters["haste"]
  if r and p then
    s = format(format_str, GetCombatRating(CR_HASTE_MELEE) or 0, GetHaste() or 0)
  elseif r then
    s = format(format_str, GetCombatRating(CR_HASTE_MELEE) or 0)
  else
    s = format(format_str, GetHaste() or 0)
  end
  return s
end
-- CRIT
local r, p = aura_env.crit_disp.r, aura_env.crit_disp.p
aura_env["GetCrit"] = function()
  local s
  local format_str = aura_env.critColor .. aura_env.formatters["crit"]
  if r and p then
    s = format(format_str, GetCombatRating(CR_CRIT_MELEE) or 0, GetSpellCritChance(2) or 0)
  elseif r then
    s = format(format_str, GetCombatRating(CR_CRIT_MELEE) or 0)
  else
    s = format(format_str, GetSpellCritChance(2) or 0)
  end
  return s
end
-- VERS
local r, p = aura_env.vers_disp.r, aura_env.vers_disp.p
aura_env["GetVers"] = function()
  local s
  local format_str = aura_env.versColor .. aura_env.formatters["vers"]
  local versDmg = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
  local versDR = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
  if r and p then
    s = format(format_str, GetCombatRating(CR_VERSATILITY_DAMAGE_DONE) or 0, versDmg, versDR)
  elseif r then
    s = format(format_str, GetCombatRating(CR_VERSATILITY_DAMAGE_DONE) or 0)
  else
    s = format(format_str, versDmg, versDR)
  end
  return s
end
-- MASTERY
local r, p = aura_env.mastery_disp.r, aura_env.mastery_disp.p
aura_env["GetMastery"] = function()
  local s
  local format_str = aura_env.masteryColor .. aura_env.formatters["mastery"]
  if r and p then
    s = format(format_str, GetCombatRating(CR_MASTERY) or 0, GetMasteryEffect() or 0)
  elseif r then
    s = format(format_str, GetCombatRating(CR_MASTERY) or 0)
  else
    s = format(format_str, GetMasteryEffect() or 0)
  end
  return s
end
-- LEECH
local r, p = aura_env.leech_disp.r, aura_env.leech_disp.p
aura_env["GetLeech"] = function()
  local s
  local format_str = aura_env.leechColor .. aura_env.formatters["leech"]
  if r and p then
    s = format(format_str, GetCombatRating(CR_LIFESTEAL) or 0, GetLifesteal() or 0)
  elseif r then
    s = format(format_str, GetCombatRating(CR_LIFESTEAL) or 0)
  else
    s = format(format_str, GetLifesteal() or 0)
  end
  return s
end
-- AVOIDANCE
local r, p = aura_env.avoidance_disp.r, aura_env.avoidance_disp.p
aura_env["GetAvoidance"] = function()
  local s
  local format_str = aura_env.avoidanceColor .. aura_env.formatters["avoidance"]
  if r and p then
    s = format(format_str, GetCombatRating(CR_AVOIDANCE) or 0, GetCombatRatingBonus(CR_AVOIDANCE) or 0)
  elseif r then
    s = format(format_str, GetCombatRating(CR_AVOIDANCE) or 0)
  else
    s = format(format_str, GetCombatRatingBonus(CR_AVOIDANCE) or 0)
  end
  return s
end
-- parry
local r, p = aura_env.parry_disp.r, aura_env.parry_disp.p
aura_env["GetParry"] = function()
  local s
  local format_str = aura_env.parryColor .. aura_env.formatters["parry"]
  if r and p then
    s = format(format_str, GetCombatRating(CR_PARRY) or 0, GetParryChance() or 0)
  elseif r then
    s = format(format_str, GetCombatRating(CR_PARRY) or 0)
  else
    s = format(format_str, GetParryChance() or 0)
  end
  return s
end
-- armor
local r, p = aura_env.armor_disp.r, aura_env.armor_disp.p
aura_env["GetArmor"] = function()
  local s, armor_perc
  local _, armor = UnitArmor("player")
  if UnitName("target") then
    armor_perc = (C_PaperDollInfo.GetArmorEffectivenessAgainstTarget(armor) or 0) * 100
  else
    armor_perc = (C_PaperDollInfo.GetArmorEffectiveness(armor, aura_env.level) or 0) * 100
  end
  local format_str = aura_env.armorColor .. aura_env.formatters["armor"]
  if r and p then
    s = format(format_str, armor or 0, armor_perc or 0)
  elseif r then
    s = format(format_str, armor or 0)
  else
    s = format(format_str, armor_perc or 0)
  end
  return s
end
--[[ aura_env.formatters = {
    haste = not aura_env.config.rawvalues["haste"] and "Haste: %.2f%%" or "Haste: %d",
    crit = not aura_env.config.rawvalues["crit"] and "Crit: %.2f%%" or "Crit: %d",
    vers = not aura_env.config.rawvalues["vers"] and "Vers: %.2f%% / %.2f%%" or "Vers: %d",
    mastery = not aura_env.config.rawvalues["mastery"] and "Mastery: %.2f%%" or "Mastery: %d",
    leech = not aura_env.config.rawvalues["leech"] and "Leech: %.2f%%" or "Leech: %d",
    avoidance = not aura_env.config.rawvalues["avoidance"] and "Avoidance: %.2f%%" or "Avoidance: %d",
    parry = not aura_env.config.rawvalues["parry"] and "Parry: %.2f%%" or "Parry: %d",
}
 ]]
