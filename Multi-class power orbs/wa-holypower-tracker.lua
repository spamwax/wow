function(allstates, event, arg1, arg2, arg3, arg4)
  local powerType, powerToken = -1, ""
  local total, power, unit = 0, 0, ""
  --[[local cost_ = GetSpellPowerCost("Word of Glory")
    if cost_ ~= nil and (cost_[1].minCost == 2 or cost_[1].minCost == 0) then
        print("SEAL OF CLARITY is working", cost_[1].minCost)
    end]]
  
  --[[
    -- Non-mana/energy Power Update events
    ]]
  if event == "UNIT_POWER_UPDATE" and arg1 == "player" then
    if not (
      arg2 == "HOLY_POWER" or arg2 == "SOUL_SHARDS" or arg2 == "CHI" or arg2 == "COMBO_POINTS"
    ) then
      return
    end
    unit = arg1
    powerToken = arg2
    powerType =  aura_env.power_types_id[powerToken]
    power = UnitPower(unit, powerType)
    total = UnitPowerMax(unit, powerType)
  end
  
  --[[
    -- Turn off simple orbs since the glow is active. This solves the bug where simiple circles would
    -- appear on top of yellow glows!!!
    ]]
  if event == "GlowActivated" and arg1 ~= nil and arg2 ~= nil then
    unit = "player"
    powerType = arg2
    power = UnitPower(unit, powerType)
    total = UnitPowerMax(unit, powerType)
    if arg1 == true then -- Glows are active
      aura_env.glows_activated = true
      for i=1,total do
        if allstates["p"..i] and allstates["p"..i].show == true then
          allstates["p"..i].show = false
          allstates["p"..i].changed = true
        end
      end
    else
      aura_env.glows_activated = false
    end
  end
  
  
  
  
  -- Paladin specific
  local _, _, classIdx = UnitClass("player")
  if classIdx == 2 then
    
    --[[
        -- Gaining Divine Purpose buff will make next spender free, show 3 orbs to indicate this
        ]]
    if aura_env.config.hpaly["show_divine_purpose"] == true then
      if event == "UNIT_AURA" and arg1 == "player" then
        unit = arg1
        local cost = GetSpellPowerCost("Word of Glory")
        if cost ~= nil then
          powerType = Enum.PowerType.HolyPower -- Only holy paladin has Divine Purpose/Shining Righteousness
          if cost[1].minCost == 0 then
            if not aura_env.divine_purpose_detected then
              aura_env.divine_purpose_detected = true
              aura_env.divine_purpose_duration = 12
              aura_env.divine_purpose_expirationTime = 12 + GetTime()
              if WA_GetUnitBuff("player", 414445) then -- Change duration for Shining Righteousness buff
                aura_env.divine_purpose_duration = 30
                aura_env.divine_purpose_expirationTime = 30 + GetTime()
              end
            end
          else
            aura_env.divine_purpose_detected = false
            aura_env.divine_purpose_expirationTime = 0
          end
        end
      end
    end
    
    
    --[[
        -- Bestow Faith cast success event 
        BESTOW FAITH WAS REMOVED IN 10.2.7
        ]]
    --[[
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
      if arg1 and arg3 and arg1 == "player" and arg3 == 223306 then -- (Besto Faith)
        unit = arg1
        local spellID = arg3
        powerType = Enum.PowerType.HolyPower -- Only holy paladin can cast this
        power = UnitPower(unit, powerType)
        
        allstates["BF"] = {
          show = true,
          changed = true,
          progressType = "timed", -- "static" or "timed"
          duration = 4.9, -- for "timed" Using 4.9 instead of 5.0 to work around a bug where HP gain from BF and BF's timer clone both are active at the same time
          expirationTime = 4.9 + GetTime(), -- for "timed"
          -- Set these if user chooses to not show progress on cast, just a cirlce.
          --value = total, -- for "static"
          --total = total, -- for "static"
          name = GetSpellInfo(spellID), -- "Bestow Faith",
          -- icon = icon,
          -- caster = sourceName,
          autoHide = true,
        }
      end    
    end
    --]]
    
    --[[
        -- Holy paladin casting Holy Light with Tower of Radiance or having Infusion of Light Buff
        ]]
    if event == "UNIT_SPELLCAST_SENT" then
      if arg1 and arg2 and arg4 and arg1 == "player" and (arg4 == 19750 --[[Flash of Light]] or arg4 == 82326 --[[Holy Light]]) then
        local target, spellID = arg2, arg4
        local beacon_name, source, buffSpellID
        
        local _spell, _, _, castTime, _, _ = GetSpellInfo(spellID)
        aura_env.finishTime = castTime/1000
        if (spellID == 82326) and WA_GetUnitBuff("player", 54149) then -- 54149 Infusion of Light
          -- Holy Light creates 2 Holy Power under Infusion of Light
          allstates["INFUSION"] = {
            show = true,
            changed = true,
            name = _spell,
            autoHide = true,
          }
          allstates["INFUSION2"] = {
            show = true,
            changed = true,
            name = _spell,
            autoHide = true,
          }
          if aura_env.config.hpaly["show_casting"] == true then
            allstates["INFUSION"].progressType = "timed"
            allstates["INFUSION"].duration = aura_env.finishTime -- for "timed"
            allstates["INFUSION"].expirationTime = aura_env.finishTime + GetTime() -- for "timed"
            -- 
            allstates["INFUSION2"].progressType = "timed"
            allstates["INFUSION2"].duration = aura_env.finishTime -- for "timed"
            allstates["INFUSION2"].expirationTime = aura_env.finishTime + GetTime() -- for "timed"
          else
            allstates["INFUSION"].progressType = "static"
            allstates["INFUSION"].total = 1
            allstates["INFUSION"].value = 1
            --
            allstates["INFUSION2"].progressType = "static"
            allstates["INFUSION2"].total = 1
            allstates["INFUSION2"].value = 1
          end
          aura_env.casting = true
          unit = arg1;
          powerType = Enum.PowerType.HolyPower -- Only holy paladin can cast this
          power = UnitPower(unit, powerType)
        end
         
        local hasTowerOfRadiance = IsPlayerSpell(231642)
        -- Casting FoL or Holy Light generates a holy power when Tower of Radiance talent is selected
        if hasTowerOfRadiance then
          aura_env.casting = true
          allstates["CASTING"] = {
            show = true,
            changed = true,
            name = _spell,
            autoHide = true,
          }
          if aura_env.config.hpaly["show_casting"] == true then
            allstates["CASTING"].progressType = "timed"
            allstates["CASTING"].duration = aura_env.finishTime -- for "timed"
            allstates["CASTING"].expirationTime = aura_env.finishTime + GetTime() -- for "timed"
          else
            allstates["CASTING"].progressType = "static"
            allstates["CASTING"].total = 1
            allstates["CASTING"].value = 1
          end
          unit = arg1;
          powerType = Enum.PowerType.HolyPower -- Only holy paladin can cast this
          power = UnitPower(unit, powerType)
        end
        -- print("hasTower", hasTowerOfRadiance)
      else
        return
      end
    end
    
    --[[
        -- Holy paladin stopping a Holy Light or Flash of Light cast on a beaconed target.
        ]]
    if (
      event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" or
      event == "UNIT_SPELLCAST_FAILED" -- or event == "UNIT_SPELLCAST_SUCCEEDED"
    ) then
      if arg1 == "player" and aura_env.casting then
        local spellID = arg3
        if not spellID or ((spellID ~= 19750) and (spellID ~= 82326)) then
          return
        end
        unit = arg1
        powerType = Enum.PowerType.HolyPower -- Only holy paladin can stop casting FoL or Holy Light this
        power = UnitPower(unit, powerType)
        aura_env.casting = false
        if allstates["CASTING"] then
          allstates["CASTING"] = {
            changed = true,
            show = false,
          }
        end
        if allstates["INFUSION"] then
          allstates["INFUSION"] = {
            changed = true,
            show = false,
          }
        end
        if allstates["INFUSION2"] then
          allstates["INFUSION2"] = {
            changed = true,
            show = false,
          }
        end
      else
        return
      end
    end
  end
  
  if event == "OPTIONS" or event == "ZONE_CHANGED_NEW_AREA" or event == "MINIMAP_ZONE_CHANGED" then
    unit = "player"
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
  end
  
  
  --[[
    -- Show orbs based on 'power' value and adjust the special orbs and cast clones if they are visible
    ]]
  if unit == "player" then -- quick nil check
    if powerType == -1 then return end -- No relevant event was received so we couldn't detect power type.
    power = UnitPower(unit, powerType)
    total = UnitPowerMax(unit, powerType)
    powerToken = aura_env.power_tokens[powerType] 
    
    local loc = power
    if allstates["CASTING"] and allstates["CASTING"].show then
      loc = loc + 1
      allstates["CASTING"].orbs = loc;
      allstates["CASTING"].loc = loc
      allstates["CASTING"].orb_type = "casting_orb"
    end
    if allstates["INFUSION"] and allstates["INFUSION"].show then
      loc = loc + 1
      allstates["INFUSION"].orbs = loc;
      allstates["INFUSION"].loc = loc
      allstates["INFUSION"].orb_type = "casting_orb"
    end
    if allstates["INFUSION2"] and allstates["INFUSION2"].show then
      loc = loc + 1
      allstates["INFUSION2"].orbs = loc;
      allstates["INFUSION2"].loc = loc;
      allstates["INFUSION2"].orb_type = "casting_orb"
    end
    
    if not aura_env.glows_activated then
      for i=1,total do
        if not allstates["p"..i] then
          if i <= power then
            -- print("Turn ON loc:", i)
            allstates["p"..i] = {
              show = true,
              changed = true,
              loc = i,
              orbs = i,
              progressType = "static",
              value = total,
              total = total,
              name = powerToken,
              autoHide = true,
              mpower = power,
              orb_type = "simple"
            }
          end
        else
          if i<=power then
            if not allstates["p"..i].show then
              -- print("Toggle on loc::", i)
              allstates["p"..i].show = true
              allstates["p"..i].changed = true
            end
          else
            if allstates["p"..i].show then
              -- print("Toggle off loc::", i)
              allstates["p"..i].show = false
              allstates["p"..i].changed = true
            end
          end
        end
        
      end
    end
    
    if aura_env.config.hpaly["show_divine_purpose"] == true then
      for i=1,3 do
        if aura_env.divine_purpose_detected then
          loc = loc + 1
          allstates["f"..i] = {
            show = true,
            changed = true,
            loc = loc,
            orbs = 0,
            progressType = "timed",
            duration = aura_env.divine_purpose_duration,
            expirationTime = aura_env.divine_purpose_expirationTime,
            name = powerToken,
            autoHide = true,
            mpower = 0,
            orb_type = "divine"
          }
          if aura_env.config.hpaly["show_casting"] == false then
            allstates["f"..i].progressType = "static"
            allstates["f"..i].value = 1
            allstates["f"..i].total = 1
          end
        else
          if allstates["f"..i] then
            allstates["f"..i].show = false
            allstates["f"..i].changed = true
          end
        end
      end
    end
    return true
  end
end

