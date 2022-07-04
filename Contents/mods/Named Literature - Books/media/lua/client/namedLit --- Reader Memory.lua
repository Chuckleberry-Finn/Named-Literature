require "namedLit - Books"

namedLit.readerMemory = {}
---How many in-game 10 minute intervals to forget
namedLit.readerMemory.timeToForget = 26280 --6 months


function namedLit.readerMemory.statsImpact(title,player)
    if not title or not player then return end
    local specificBook = namedLit.readerMemory.getSpecificBook(title,player)
    local currentTimeStampsLen = #specificBook.timesStampsWhenRead
    local UnhappyChange = math.floor(namedLit.bookStats.UnhappyChange/(currentTimeStampsLen+1))
    local StressChange = math.floor(namedLit.bookStats.StressChange/(currentTimeStampsLen+1))
    local BoredomChange = math.floor(namedLit.bookStats.BoredomChange/(currentTimeStampsLen+1))

    return UnhappyChange, StressChange, BoredomChange
end


function namedLit.readerMemory.getSpecificBook(title,player)
    if not title or not player then return end
    local memory = namedLit.readerMemory.getSpecificReaderMemory(player)
    ---Careful not to empty these if they already exist
    memory.titles[title] = memory.titles[title] or {}
    memory.titles[title].timesStampsWhenRead = memory.titles[title].timesStampsWhenRead or {}

    return memory.titles[title]
end


function namedLit.readerMemory.getTotalTimesRead(title,player)
    if not title or not player then return end
    local specificBook = namedLit.readerMemory.getSpecificBook(title,player)
    return specificBook.totalTimesRead, #specificBook.timesStampsWhenRead
end


function namedLit.readerMemory.validateAllReadTimes(player)
    if not player then return end
    local readerMemory = namedLit.readerMemory.getSpecificReaderMemory(player)
    for _,title in pairs(readerMemory.titles) do
        namedLit.readerMemory.validateSpecificReadTimes(nil,title.timesStampsWhenRead,player)
    end
end
Events.OnPlayerUpdate.Add(namedLit.readerMemory.validateAllReadTimes)


function namedLit.readerMemory.validateSpecificReadTimes(title,directTimesRead,player)
    if (not title and not directTimesRead) or not player then return end

    local specificBookTimeStampsWhenRead = directTimesRead
    if not specificBookTimeStampsWhenRead then
        local specificBook = namedLit.readerMemory.getSpecificBook(title,player)
        specificBookTimeStampsWhenRead = specificBook.timesStampsWhenRead
    end

    local validatedTimesRead = {}
    for _,timeStamp in pairs(specificBookTimeStampsWhenRead) do
        if timeStamp+namedLit.readerMemory.timeToForget < getGametimeTimestamp() then
            table.insert(validatedTimesRead, timeStamp)
        end
    end
    specificBookTimeStampsWhenRead = validatedTimesRead
end


function namedLit.readerMemory.addReadTime(title,player)
    if not title or not player then return end
    local specificBook = namedLit.readerMemory.getSpecificBook(title,player)
    local specificBookTSWR = specificBook.timesStampsWhenRead

    table.insert(specificBookTSWR, getGametimeTimestamp())
    specificBook.totalTimesRead = specificBook.totalTimesRead or 0
    specificBook.totalTimesRead = specificBook.totalTimesRead+1

    if #specificBookTSWR > 10 then
        table.remove(specificBookTSWR, 1)
    end
end


---@param player IsoObject|IsoGameCharacter|IsoMovingObject|IsoPlayer
function namedLit.readerMemory.getSpecificReaderMemory(player)
    if not player then return end
    local memory = player:getModData()["namedLitReaderMemory"]
    if not memory then
        player:getModData()["namedLitReaderMemory"] = {}
        memory = player:getModData()["namedLitReaderMemory"]

        memory.titles = {}
    end

    return memory
end
