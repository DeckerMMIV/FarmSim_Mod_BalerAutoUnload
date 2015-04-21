--
--  Auto-unload for Round-baler
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2015-04-xx
--

BalerAutoUnload = {}

local modItem = ModsUtil.findModItemByModName(g_currentModName);
BalerAutoUnload.version = (modItem and modItem.version) and modItem.version or "?.?.?";

BalerAutoUnload.updateTick = function(self,dt)
    if self.isServer then
        if self.balerUnloadingState == Baler.UNLOADING_CLOSED then
            if self.fillLevel >= self.capacity then
                if (table.getn(self.bales) > 0) and self:isUnloadingAllowed() then
                    -- Activate the bale unloading (server-side only!)
                    self:setIsUnloadingBale(true);
                end
            end
        elseif self.balerUnloadingState == Baler.UNLOADING_OPEN then
            -- Activate closing (server-side only!)
            self:setIsUnloadingBale(false);
        end
    end
end

Baler.updateTick = Utils.appendedFunction(Baler.updateTick, BalerAutoUnload.updateTick)

--
print(string.format("Script loaded: BalerAutoUnload.lua (v%s)", BalerAutoUnload.version));
