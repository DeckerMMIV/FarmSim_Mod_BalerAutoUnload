--
--  Auto-unload for Round-baler
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2015-04-xx
--

BalerAutoUnload = {}

local modItem = ModsUtil.findModItemByModName(g_currentModName);
BalerAutoUnload.version = (modItem and modItem.version) and modItem.version or "?.?.?";


BalerAutoUnload.load = function(self, xmlFile)
    self.setAutoUnloadDelay = BalerAutoUnload.setAutoUnloadDelay
    self.modAutoUnloadDelay = 0 -- off
end

BalerAutoUnload.setAutoUnloadDelay = function(self, newValue, noEventSend)
    self.modAutoUnloadDelay = (newValue % 6)
    self.modAutoUnloadTimeout = nil
    
    if g_server ~= nil then
         g_server:broadcastEvent(BalerAutoUnloadEvent:new(self, self.modAutoUnloadDelay));
    elseif noEventSend ~= true then
        g_client:getServerConnection():sendEvent(BalerAutoUnloadEvent:new(self, self.modAutoUnloadDelay));
    end
end

BalerAutoUnload.update = function(self,dt)
    if self.isClient and self.baleUnloadAnimationName ~= nil then
        if self:getIsActiveForInput() then
            if InputBinding.hasEvent(InputBinding.IMPLEMENT_EXTRA3) then
                self:setAutoUnloadDelay(self.modAutoUnloadDelay - 1)
            end
        end
    end
end

BalerAutoUnload.updateTick = function(self,dt)
    if self.isServer and self.modAutoUnloadDelay > 0 then
        if self.balerUnloadingState == Baler.UNLOADING_CLOSED then
            if self.fillLevel >= self.capacity then
                if (table.getn(self.bales) > 0) and self:isUnloadingAllowed() then
                    if self.modAutoUnloadTimeout == nil then
                        self.modAutoUnloadTimeout = g_currentMission.time + (self.modAutoUnloadDelay * 1000)
                    elseif self.modAutoUnloadTimeout < g_currentMission.time then
                        self:setIsUnloadingBale(true);
                    end
                end
            end
        elseif self.balerUnloadingState == Baler.UNLOADING_OPEN then
            if self.modAutoUnloadTimeout ~= nil then
                self.modAutoUnloadTimeout = nil
                self:setIsUnloadingBale(false);
            end
        end
    end
end

BalerAutoUnload.draw = function(self)
    if self.isClient and self.baleUnloadAnimationName ~= nil then
        if self.modAutoUnloadDelay > 0 then
            g_currentMission:addHelpButtonText(g_i18n:getText("ChangeAutoUnloadDelay"):format(g_i18n:getText("DelaySeconds"):format(self.modAutoUnloadDelay)), InputBinding.IMPLEMENT_EXTRA3);
        else
            g_currentMission:addHelpButtonText(g_i18n:getText("ChangeAutoUnloadDelay"):format(g_i18n:getText("DelayOff")), InputBinding.IMPLEMENT_EXTRA3);
        end
    end
end


Baler.load       = Utils.appendedFunction(Baler.load,       BalerAutoUnload.load      )
Baler.update     = Utils.appendedFunction(Baler.update,     BalerAutoUnload.update    )
Baler.updateTick = Utils.appendedFunction(Baler.updateTick, BalerAutoUnload.updateTick)
Baler.draw       = Utils.appendedFunction(Baler.draw,       BalerAutoUnload.draw      )

---
---


BalerAutoUnloadEvent = {};
BalerAutoUnloadEvent_mt = Class(BalerAutoUnloadEvent, Event);

function  BalerAutoUnloadEvent:emptyNew()
    local self = Event:new(BalerAutoUnloadEvent_mt);
    return self;
end;

function BalerAutoUnloadEvent:new(object, autoUnloadDelay)
    local self = BalerAutoUnloadEvent:emptyNew()
    self.object = object;
    self.autoUnloadDelay = autoUnloadDelay
    return self;
end;

function BalerAutoUnloadEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, networkGetObjectId(self.object));
    streamWriteUIntN(streamId, self.autoUnloadDelay, 4);

end;

function BalerAutoUnloadEvent:readStream(streamId, connection)
    self.object = networkGetObject(streamReadInt32(streamId));
    self.autoUnloadDelay = streamReadUIntN(streamId, 4);
    self:run(connection);
end;

function BalerAutoUnloadEvent:run(connection)
    if self.object ~= nil then
        self.object:setAutoUnloadDelay(autoUnloadDelay, true);
    end
end;

--
print(string.format("Script loaded: BalerAutoUnload.lua (v%s)", BalerAutoUnload.version));
