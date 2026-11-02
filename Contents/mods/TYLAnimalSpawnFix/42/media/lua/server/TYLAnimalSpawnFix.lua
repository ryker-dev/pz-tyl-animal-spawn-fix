-- 10 Years Later Animal Spawn Fix
-- TYL spawns animals without checking for water. On water, vanilla adds the animal
-- to the world before aborting its setup, leaving an uninitialized animal that
-- crashes IsoAnimal.update ("this.adef is null"). This blocks addAnimal on water.

if isClient() then return end

local TAG = "[TYLAnimalSpawnFix] "
local LOG_LIMIT = 20
local LOG_EVERY = 100
local logged, blocked, removed = 0, 0, 0

local function try(fn, ...)
    local ok, result = pcall(fn, ...)
    if ok then return result end
    return nil
end

local function callerFrames()
    if not (getCurrentCoroutine and getCallframeTop and getCoroutineCallframeStack) then return "unknown" end
    local co = try(getCurrentCoroutine)
    if not co then return "unknown" end
    local frames = {}
    for i = (try(getCallframeTop, co) or 0) - 1, 0, -1 do
        local frame = try(getCoroutineCallframeStack, co, i)
        local text = frame and try(KahluaUtil.rawTostring2, frame)
        if text and text:find(".lua", 1, true) and not text:find("TYLAnimalSpawnFix", 1, true) then
            frames[#frames + 1] = text
            if #frames >= 3 then break end
        end
    end
    return #frames > 0 and table.concat(frames, " <- ") or "unknown"
end

local function isWater(x, y, z)
    local square = getCell():getGridSquare(math.floor(x), math.floor(y), math.floor(z or 0))
    return square ~= nil and square:isWaterSquare() == true
end

local function isUninitialized(animal)
    local okAdef, adef = pcall(animal.getAdef, animal)
    local okData, data = pcall(animal.getData, animal)
    return (okAdef and adef == nil) or (okData and data == nil)
end

local function report(kind, animalType, x, y, z)
    if logged < LOG_LIMIT then
        logged = logged + 1
        print(TAG .. string.format("%s type=%s at=%s,%s,%s caller: %s",
            kind, tostring(animalType), tostring(x), tostring(y), tostring(z), callerFrames()))
    elseif (blocked + removed) % LOG_EVERY == 0 then
        print(TAG .. string.format("so far: blocked=%d removed=%d", blocked, removed))
    end
end

local originalAddAnimal = addAnimal
if type(originalAddAnimal) ~= "function" then
    print(TAG .. "global addAnimal not found - fix inactive")
    return
end

addAnimal = function(cell, x, y, z, animalType, breed, ...)
    local okWater, water = pcall(isWater, x, y, z)
    if okWater and water then
        blocked = blocked + 1
        report("blocked spawn on water", animalType, x, y, z)
        return nil
    end

    local animal
    if select("#", ...) == 0 then
        animal = originalAddAnimal(cell, x, y, z, animalType, breed)
    else
        animal = originalAddAnimal(cell, x, y, z, animalType, breed, (select(1, ...)))
    end
    if animal and isUninitialized(animal) then
        removed = removed + 1
        pcall(animal.removeFromWorld, animal)
        report("removed uninitialized animal", animalType, x, y, z)
        return nil
    end
    return animal
end

print(TAG .. "addAnimal water check active")
