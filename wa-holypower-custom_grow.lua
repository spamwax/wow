function(newPositions, activeRegions)
  if WeakAuras.IsOptionsOpen() then return end
  local idx, xOffset, total = 1, 0, 0
  local spacing = 28.4
  local debug = false
  
  for i, rdata in ipairs(activeRegions) do
    if rdata.id and rdata.cloneId and rdata.dataIndex then
      if rdata.id == "Orbs-TSU-Based" and rdata.region.state.show then
        idx = rdata.region.state.loc - 1
        xOffset = idx * spacing
        newPositions[i] = { xOffset, rdata.region.yOffset, true}
      elseif  rdata.id == "GlowOrb" or rdata.id == "GlowOrbCapped" then --and rdata.region.state.currentPower < 5 then
        --print("glow", rdata.cloneId, rdata.dataIndex, rdata.region.state.currentPower)
        idx = tonumber(rdata.cloneId) or 0
        newPositions[i] = { (idx-1)*spacing, rdata.region.yOffset, true}
      end
      -- This is just for debugging
      if string.match(rdata.cloneId, "p%d") then
        if rdata.region.state.mpower > total then
          total = rdata.region.state.mpower
        end
      end
    end
  end
  if debug then
    if UnitPower("player", 9) ~= total then
      print(string.format("|cFFff0000MISMATCH HP~=total %d, %d (activeRegions: %d)", UnitPower("player", 9), total, nregions))
    end
  end
end


--[[
                local _ss = string.format(
                    "|cFF00b7b7id: %s, cloneId: %s, dataIndex: %s\n|cFFfabf00orbs: %d, power: %d, index: %d",rdata.id, rdata.cloneId, tostring(rdata.dataIndex), rdata.region.state.orbs, rdata.region.state.mpower, rdata.region.state.index
                )
                print(_ss)
]]
--print("|cFFffff00Calculating offsets: nregions, total", #activeRegions, total)
