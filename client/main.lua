local RSGCore = exports['rsg-core']:GetCoreObject()

local function drawText(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    Citizen.InvokeNative(0xADA9255D, 10);
    DisplayText(str, x, y)
end

local function rotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

local function rayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = rotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local _, hit, endCoords, _, entityHit = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return hit, endCoords, entityHit
end

local function visualizePlacement(modelName, maxDistance)
    local objectHandle = nil
    local startingCoords = nil
    local placementMode = true
    local objectRotation = 0.0
    local rotationSpeed = 0.25 -- Adjust this value to change the rotation speed

    maxDistance = maxDistance or Config.DefaultMaxDistance
    local maxExistenceDistance = Config.MaxExistenceDistance

    local playerPed = PlayerPedId()
    local hit, coords, entity = rayCastGamePlayCamera(1000.0)

    if hit then
        RequestModel(modelName)
        while not HasModelLoaded(modelName) do
            Citizen.Wait(0)
        end
        objectHandle = CreateObject(GetHashKey(modelName), coords.x, coords.y, coords.z, true, false, false)
        SetEntityAsMissionEntity(objectHandle, true, true)
        SetEntityAlpha(objectHandle, 128, false)
        startingCoords = GetEntityCoords(playerPed)
    else
        RSGCore.Functions.Notify("No valid surface found to place the object", "error")
        return
    end

    while placementMode do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(playerPed)
        local hit, coords, entity = rayCastGamePlayCamera(1000.0)
        if hit and objectHandle then
            local distance = #(coords - startingCoords)
            local distanceFromPlayer = #(playerCoords - coords)

            drawText(Config.PlacementModeText, 0.5, 0.9, 0.5, 0.5, true, 255, 255, 255, 255, true)

            if distance > maxDistance then
                SetEntityAlpha(objectHandle, 0, false)
            else
                if distanceFromPlayer <= maxDistance then
                    SetEntityCoords(objectHandle, coords.x, coords.y, coords.z, false, false, false, false)
                    SetEntityCollision(objectHandle, false, false)
                    FreezeEntityPosition(objectHandle, true)
                    SetEntityRotation(objectHandle, 0.0, 0.0, objectRotation, 2, true)
                    SetEntityAlpha(objectHandle, 128, false)
                else
                    SetEntityAlpha(objectHandle, 0, false)
                end

                if distanceFromPlayer > maxExistenceDistance then
                    DeleteEntity(objectHandle)
                    objectHandle = nil
                    placementMode = false
                    RSGCore.Functions.Notify("The object is too far away and has been deleted", "error")
                    return
                end

                if IsControlPressed(0, Config.Keybinds.RotateLeft) then -- Left arrow key
                    objectRotation = objectRotation - (11.25 * rotationSpeed)
                    if objectRotation < 0.0 then
                        objectRotation = objectRotation + 360.0
                    end
                elseif IsControlPressed(0, Config.Keybinds.RotateRight) then -- Right arrow key
                    objectRotation = objectRotation + (11.25 * rotationSpeed)
                    if objectRotation >= 360.0 then
                        objectRotation = objectRotation - 360.0
                    end
                end

                if IsControlJustPressed(0, Config.Keybinds.Cancel) then -- F Key
                    DeleteEntity(objectHandle)
                    objectHandle = nil
                    placementMode = false
                    RSGCore.Functions.Notify("Object placement cancelled", "error")
                    return
                end

                if IsControlJustPressed(0, Config.Keybinds.Place) then -- Left Shift key
                    if distance <= maxDistance then
                        local entityCoords = GetEntityCoords(objectHandle)
                        local entityRotation = GetEntityRotation(objectHandle)
                        DeleteEntity(objectHandle)
                        objectHandle = nil
                        placementMode = false
                        return entityCoords, entityRotation
                    else
                        RSGCore.Functions.Notify("The object is too far away to be placed", "error")
                    end
                end
            end
        end
    end
end

exports('visualizePlacement', visualizePlacement)

-- RegisterCommand('testviz', function(source, args)
--     local modelName = args[1]
--     local maxDistance = tonumber(args[2])

--     if not modelName then
--         RSGCore.Functions.Notify("Please provide a model name", "error")
--         return
--     end

--     local coords, rotation = exports.wd_propviz:visualizePlacement(modelName, maxDistance)

--     if coords and rotation then
--         print(string.format('Object placed at coordinates: vector3(%f, %f, %f)', coords.x, coords.y, coords.z))
--         print(string.format('Object rotation: %f, %f, %f', rotation.x, rotation.y, rotation.z))
--     else
--         print("Object placement cancelled or failed")
--     end
-- end, false)