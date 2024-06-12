function(allstates, event, arg1, arg2, arg3, arg4)
  local min_glow = aura_env.config["nshow_glow"] or 3
  local show_glow = min_glow > 0 -- not aura_env.config["no_glow"]
  if not show_glow then return end
  
  if event == "GlowOrbCappedToggled" then
    aura_env.show_warn_glow = arg1
  end
  
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
      if power < min_glow then
        WeakAuras.ScanEvents("GlowActivated", false, powerType)
      end
      
    end
  elseif event == "OPTIONS"  or event == "ZONE_CHANGED_NEW_AREA" or event == "MINIMAP_ZONE_CHANGED" then
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
    if power == total and aura_env.show_warn_glow == true then -- turn all glows off since we will show a different model
      for i=1,total do
        if allstates[i] and allstates[i].show then
          allstates[i].show = false
          allstates[i].changed = true
        end
      end
      WeakAuras.ScanEvents("GlowActivated", true, powerType)
      return true
    end
    local eventSent = false
    local flag = true
    
    
    for i=1,total do
      if false then print(i, power) end
      
      if not allstates[i] then
        if i <= power and power >= min_glow and show_glow then
          allstates[i] = {
            show = true,
            changed = true,
            stacks = i,
            progressType = "static", -- "static" or "timed"
            -- index = i,
            value = 1, -- for "static"
            total = 1, -- for "static"
            currentPower = power,
            name = powerToken,
            autoHide = true,
          }
          if eventSent == false then
            WeakAuras.ScanEvents("GlowActivated", true, powerType)
            eventSent = true
          end
        end
      else
        if i <= power and power >= min_glow and show_glow then
          if not allstates[i].show then
            allstates[i].show = true
            allstates[i].changed = true
            if eventSent == false then
              WeakAuras.ScanEvents("GlowActivated", true, powerType)
              eventSent = true
            end
          end
        else
          if allstates[i].show then
            allstates[i].show = false
            allstates[i].changed = true
            --if eventSent == false then
            -- WeakAuras.ScanEvents("GlowActivated", false, powerType)
            --eventSent = true
            --end
          end
        end
      end
    end
    return true
  end
end
