function(allstates, event, arg1, arg2, arg3, arg4)
  local show_warn_glow = aura_env.config["showWarningGlows"]
  if event == "OPTIONS" then
    WeakAuras.ScanEvents("GlowOrbCappedToggled", show_warn_glow)
  end
  if not show_warn_glow then return end
  
  local powerType, powerToken = 9, "" -- 9 for holy power as default
  local total, power, unit = 0, 0, ""
  
  
  if event == "UNIT_POWER_UPDATE" and arg1 == "player" then
    if not (
      arg2 == "HOLY_POWER" or arg2 == "SOUL_SHARDS" or arg2 == "CHI" or arg2 == "COMBO_POINTS"
    ) then
      return
    else
      unit = arg1
      powerToken = arg2
      powerType =  aura_env.power_types_id[powerToken]
      power = UnitPower(unit, powerType)
      total = UnitPowerMax(unit, powerType)
    end
  elseif event == "OPTIONS" or event == "ZONE_CHANGED_NEW_AREA" or event == "MINIMAP_ZONE_CHANGED OPTIONS" then
    unit = "player"
    local _, _, classIdx = UnitClass(unit)
    if classIdx == 2 then -- paladin
      powerType = Enum.PowerType.HolyPower
    elseif classIdx == 4 then -- rogue
      powerType = Enum.PowerType.ComboPoints
    elseif classIdx == 9 then -- warlock
      powerType = Enum.PowerType.SoulShards
    elseif classIdx == 10 then -- monk
      powerType = Enum.PowerType.Chi
    elseif classIdx == 11 then-- druid
      powerType = Enum.PowerType.ComboPoints
    else
      return
    end
    powerToken = aura_env.power_tokens[powerType]
    power = UnitPower(unit, powerType)
    total = UnitPowerMax(unit, powerType)
  else
    return
  end
  
  if unit == "player" then -- quick nil check
    for i=1,total do
      if power == total then
        if not allstates[i] then
          allstates[i] = {
            show = true,
            changed = true,
            stacks = i,
            progressType = "static", -- "static" or "timed"
            index = i,
            value = 1, -- for "static"
            total = 1, -- for "static"
            currentPower = power,
            name = powerToken,
            autoHide = true,
          }
        else
          allstates[i].show = true
          allstates[i].changed = true
        end
      else
        if allstates[i] and allstates[i].show then
          allstates[i].show = false
          allstates[i].changed = true
        end
      end
    end
    
    return true
  end
end
