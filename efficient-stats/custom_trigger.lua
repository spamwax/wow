function (event, unit, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, ...)
  if event == "COMBAT_LOG_EVENT_UNFILTERED" and destGUID ~= UnitGUID("player") then
    return
  end
  
  if event == "UNIT_POWER_FREQUENT" then
    return
  end
  if event == "UNIT_SPELLCAST_SENT" and ((unit and unit ~= "player")) then
    return
  end
  
  aura_env.primaryStat, aura_env.primaryToken = aura_env.calcPrimaryStat()
  
  -- Update trigger when WASpeedStatCheck is received. Needed for client delays's updating player's speed
  if event == "WASpeedStatCheck" then
    aura_env.timerActive = false
    aura_env.speed = aura_env.calcSpeed()
    return true
  end
  
  -- If player dis/mounted or its aura changed start a short timer after which we update player's speed.
  -- "UNIT_AURA" is needed for speed related buff such as Paladin's Crusader's Aura
  if (
    event == "PLAYER_MOUNT_DISPLAY_CHANGED" or
    (event == "UNIT_AURA" and unit == "player")-- or
  ) then
    if not aura_env.timerActive then
      aura_env.timerActive = true
      C_Timer.After(
        aura_env.mount_delay,
        function()
          WeakAuras.ScanEvents("WASpeedStatCheck")
        end
      )
    end
    
  end
  
  -- local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
  -- local versDmg = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
  -- local versDR  = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
  -- local _, armor = UnitArmor("player")
  
  
  -- aura_env.haste = not aura_env.config.rawvalues["haste"] and GetHaste() or GetCombatRating(CR_HASTE_MELEE); -- CR_HASTE_MELEE
  aura_env.haste = aura_env.GetHaste()
  aura_env.dodge = GetDodgeChance(); -- no raw rating! -- CR_DODGE
  -- aura_env.mastery = not aura_env.config.rawvalues["mastery"] and GetMasteryEffect() or GetCombatRating(CR_MASTERY); -- CR_MASTERY
  aura_env.mastery = aura_env.GetMastery()
  -- aura_env.crit = not aura_env.config.rawvalues["crit"] and GetSpellCritChance(2) or GetCombatRating(CR_CRIT_MELEE); -- CR_CRIT_MELEE
  aura_env.crit = aura_env.GetCrit()
  -- aura_env.leech = not aura_env.config.rawvalues["leech"] and GetLifesteal() or GetCombatRating(CR_LIFESTEAL) -- CR_LIFESTEAL
  aura_env.leech = aura_env.GetLeech()
  -- if not aura_env.config.rawvalues["vers"] then
  --   aura_env.versDmgBonus = versDmg
  --   aura_env.versDR = versDR
  -- else
  --   aura_env.versDmgBonus = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE) -- CR_VERSATILITY_DAMAGE_DONE
  -- end
  aura_env.vers = aura_env.GetVers()
  
  aura_env.speed = aura_env.calcSpeed()
  aura_env.block = GetBlockChance()
  aura_env.armor = aura_env.GetArmor()
  -- aura_env.avoidance = not aura_env.config.rawvalues["avoidance"] and GetCombatRatingBonus(CR_AVOIDANCE) or GetCombatRating(CR_AVOIDANCE) -- CR_AVOIDANCE
  aura_env.avoidance = aura_env.GetAvoidance()
  -- aura_env.parry = not aura_env.config.rawvalues["parry"] and GetParryChance() or GetCombatRating(CR_PARRY) -- CR_PARRY
  aura_env.parry = aura_env.GetParry()
  
  return true
  
end
