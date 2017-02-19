--
--  Auto-unload for Round-baler
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2016-11-xx
--

RegistrationHelper_AutoUnload_RB = {};
RegistrationHelper_AutoUnload_RB.isLoaded = false;

if SpecializationUtil.specializations['BalerAutoUnload'] == nil then
    SpecializationUtil.registerSpecialization('BalerAutoUnload', 'BalerAutoUnload', g_currentModDirectory .. 'BalerAutoUnload.lua')
    RegistrationHelper_AutoUnload_RB.isLoaded = false;
end

function RegistrationHelper_AutoUnload_RB:loadMap(name)
    if not g_currentMission.RegistrationHelper_AutoUnload_RB_isLoaded then
        if not RegistrationHelper_AutoUnload_RB.isLoaded then
            self:register();
        end
        g_currentMission.RegistrationHelper_AutoUnload_RB_isLoaded = true
    else
        print("Error: BalerAutoUnload has been loaded already!");
    end
end

function RegistrationHelper_AutoUnload_RB:deleteMap()
    g_currentMission.RegistrationHelper_AutoUnload_RB_isLoaded = nil
end

function RegistrationHelper_AutoUnload_RB:keyEvent(unicode, sym, modifier, isDown)
end

function RegistrationHelper_AutoUnload_RB:mouseEvent(posX, posY, isDown, isUp, button)
end

function RegistrationHelper_AutoUnload_RB:update(dt)
end

function RegistrationHelper_AutoUnload_RB:draw()
end

function RegistrationHelper_AutoUnload_RB:register()
    for _, vehicle in pairs(VehicleTypeUtil.vehicleTypes) do
        if vehicle ~= nil 
        and (  SpecializationUtil.hasSpecialization(Baler, vehicle.specializations)
            or SpecializationUtil.hasSpecialization(BaleWrapper, vehicle.specializations)
            )
        then
            table.insert(vehicle.specializations, SpecializationUtil.getSpecialization("BalerAutoUnload"))
        end
    end
    RegistrationHelper_AutoUnload_RB.isLoaded = true
end

addModEventListener(RegistrationHelper_AutoUnload_RB)