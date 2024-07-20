function ()
  local s = {}
  s.primary = string.format(aura_env.primaryColor .. "%s: %d", aura_env.primaryToken or "Primary", aura_env.primaryStat or 0)
  -- s.haste = string.format(aura_env.hasteColor .. aura_env.formatters["haste"], aura_env.haste or 0)
  s.haste = aura_env.haste
  s.dodge = string.format(aura_env.dodgeColor .. "Dodge: %.2f%%", aura_env.dodge or 0)
  
  
  -- s.mastery = string.format(aura_env.masteryColor .. aura_env.formatters["mastery"], aura_env.mastery or 0)
  s.mastery = aura_env.mastery
  -- s.crit = string.format(aura_env.critColor .. aura_env.formatters["crit"], aura_env.crit or 0)
  s.crit = aura_env.crit
  
  -- if not aura_env.config.rawvalues["vers"] then
  --   s.vers = string.format(aura_env.versatilityColor .. aura_env.formatters["vers"], aura_env.versDmgBonus or 0, aura_env.versDR or 0)
  -- else
  --   s.vers = string.format(aura_env.versatilityColor .. aura_env.formatters["vers"], aura_env.versDmgBonus or 0)
  -- end
  s.vers = aura_env.vers
  
  s.speed = string.format(aura_env.speedColor .. "Speed: %.2f%%", aura_env.speed or 0)
  -- s.leech = string.format(aura_env.leechColor .. aura_env.formatters["leech"], aura_env.leech or 0)
  s.leech = aura_env.leech
  s.block = string.format(aura_env.blockColor .. "Block: %.2f%%", aura_env.block or 0)
  s.armor = string.format(aura_env.armorColor .. "Armor: %d", aura_env.armor or 0)
  -- s.avoidance = string.format(aura_env.avoidanceColor .. aura_env.formatters["avoidance"], aura_env.avoidance or 0)
  s.avoidance = aura_env.avoidance
  -- s.parry = string.format(aura_env.parryColor .. aura_env.formatters["parry"], aura_env.parry or 0)
  s.parry = aura_env.parry
  
  local r = ""
  for k, v in pairs(aura_env.disp_order) do
    if aura_env.config.toggles[v] then
      if s[v] ~= nil then
        r =  string.format("%s%s\n", r, s[v])
      end
    end
  end
  
  return r
  
end
