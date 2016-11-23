--
--  Auto-unload for Round-baler
--
-- @author  Decker_MMIV (DCK)
-- @contact fs-uk.com, modcentral.co.uk, forum.farming-simulator.com
-- @date    2016-11-xx
--

BalerAutoUnload = {}

local modItem = ModsUtil.findModItemByModName(g_currentModName);
BalerAutoUnload.version = (modItem and modItem.version) and modItem.version or "?.?.?";


BalerAutoUnload.prerequisitesPresent = function(specializations)
    return SpecializationUtil.hasSpecialization(Baler, specializations);
end

BalerAutoUnload.delete      = function(self) end
BalerAutoUnload.mouseEvent  = function(self, posX, posY, isDown, isUp, button) end
BalerAutoUnload.keyEvent    = function(self, unicode, sym, modifier, isDown) end

BalerAutoUnload.load = function(self, savegame)
    self.setAutoUnloadDelay = BalerAutoUnload.setAutoUnloadDelay
    self.modAutoUnloadDelay = 0 -- off

    if savegame ~= nil and not savegame.resetVehicles then
        self:setAutoUnloadDelay(getXMLInt(savegame.xmlFile, savegame.key .. "#autoUnloadDelay"), true)
    end;
end

BalerAutoUnload.getSaveAttributesAndNodes = function(self, nodeIdent)
    local attributes, nodes
    if self.modAutoUnloadDelay > 0 then
        attributes = ('autoUnloadDelay="%d"'):format(self.modAutoUnloadDelay)
    end
    return attributes, nodes
end;

BalerAutoUnload.setAutoUnloadDelay = function(self, newValue, noEventSend)
    self.modAutoUnloadDelay = Utils.getNoNil(newValue, 0) % 6
    self.modAutoUnloadTimeout = nil
    
    if noEventSend ~= true then
        if g_server ~= nil then
            g_server:broadcastEvent(BalerAutoUnloadEvent:new(self, self.modAutoUnloadDelay));
        else
            g_client:getServerConnection():sendEvent(BalerAutoUnloadEvent:new(self, self.modAutoUnloadDelay));
        end
    end
end

BalerAutoUnload.update = function(self,dt)
    if self.isClient and self.baler ~= nil and self.baler.baleUnloadAnimationName ~= nil then
        if InputBinding.hasEvent(InputBinding.IMPLEMENT_EXTRA4) and self:getIsActiveForInput() then
            self:setAutoUnloadDelay(Utils.getNoNil(self.modAutoUnloadDelay, 0) - 1)
        end
    end
end

BalerAutoUnload.updateTick = function(self,dt)
    if self.isServer and self.modAutoUnloadDelay ~= nil and self.modAutoUnloadDelay > 0 and self:getIsTurnedOn() then
        if self.baler ~= nil then
            if self.baler.unloadingState == Baler.UNLOADING_CLOSED then
                if self:getUnitFillLevel(self.baler.fillUnitIndex) >= self:getUnitCapacity(self.baler.fillUnitIndex) then
                    if (table.getn(self.baler.bales) > 0) and self:isUnloadingAllowed() then
                        if self.modAutoUnloadTimeout == nil then
                            self.modAutoUnloadTimeout = g_currentMission.time + (self.modAutoUnloadDelay * 1000)
                        elseif self.modAutoUnloadTimeout < g_currentMission.time then
                            self:setIsUnloadingBale(true);
                        end
                    end
                end
            elseif self.baler.unloadingState == Baler.UNLOADING_OPEN then
                if self.modAutoUnloadTimeout ~= nil then
                    self.modAutoUnloadTimeout = nil
                    self:setIsUnloadingBale(false);
                end
            end
        end
    end
end

BalerAutoUnload.draw = function(self)
    if self.isClient and self.baler ~= nil and self.baler.baleUnloadAnimationName ~= nil then
        if self.modAutoUnloadDelay ~= nil and self.modAutoUnloadDelay > 0 then
            g_currentMission:addHelpButtonText(g_i18n:getText("ChangeAutoUnloadDelay"):format(g_i18n:getText("DelaySeconds"):format(self.modAutoUnloadDelay)), InputBinding.IMPLEMENT_EXTRA4, nil, GS_PRIO_NORMAL);
        else
            g_currentMission:addHelpButtonText(g_i18n:getText("ChangeAutoUnloadDelay"):format(g_i18n:getText("DelayOff")), InputBinding.IMPLEMENT_EXTRA4, nil, GS_PRIO_NORMAL);
        end
    end
end

---
---

BalerAutoUnloadEvent = {};
BalerAutoUnloadEvent_mt = Class(BalerAutoUnloadEvent, Event);

InitEventClass(BalerAutoUnloadEvent, "BalerAutoUnloadEvent");

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
    writeNetworkNodeObject(streamId, self.object);
    streamWriteUIntN(      streamId, self.autoUnloadDelay, 4);

end;

function BalerAutoUnloadEvent:readStream(streamId, connection)
    self.object          = readNetworkNodeObject(streamId);
    self.autoUnloadDelay = streamReadUIntN(      streamId, 4);
    self:run(connection);
end;

function BalerAutoUnloadEvent:run(connection)
    if self.object ~= nil then
        self.object:setAutoUnloadDelay(self.autoUnloadDelay, connection:getIsServer());
    end
end;

--
print(string.format("Script loaded: BalerAutoUnload.lua (v%s)", BalerAutoUnload.version));
