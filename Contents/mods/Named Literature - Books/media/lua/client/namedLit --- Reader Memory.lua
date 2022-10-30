require "namedLit -- Main"

namedLit.readerMemory = {}
---How many in-game 10 minute intervals to forget
namedLit.readerMemory.timeToForget = 26280 --6 months
namedLit.readerMemory.maxTimesReadable = 3

function namedLit.readerMemory.getTimeToForget()
    return SandboxVars.NamedLiterature.TimeToForget or namedLit.readerMemory.timeToForget
end

function namedLit.readerMemory.getMaxTimesReadable()
    return SandboxVars.NamedLiterature.MaxTimesReadable or namedLit.readerMemory.maxTimesReadable
end


---@param player IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
function namedLit.readerMemory.getOrSetReaderID(player)
    if not player then return end
    player:getModData()["namedLitReaderMemory"] = player:getModData()["namedLitReaderMemory"] or {}
    local playerNamedLitData = player:getModData()["namedLitReaderMemory"]
    playerNamedLitData.readerID = playerNamedLitData.readerID or getRandomUUID()..tostring(player:getSteamID())
    return playerNamedLitData.readerID
end


---@param literature Literature
---@param title string
---@param player IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
function namedLit.readerMemory.statsImpact(literature,title,player)
    if (not literature and not title) or not player then return end

    local currentTimeStampsLen = 0
    if title then
        local specificBook = namedLit.readerMemory.getSpecificBook(title,player)
        currentTimeStampsLen = math.min(namedLit.readerMemory.getMaxTimesReadable(), #specificBook.timesStampsWhenRead)
    else
        local bookNameLitInfo = literature:getModData()["namedLit"]
        local playerReaderID = namedLit.readerMemory.getOrSetReaderID(player)
        bookNameLitInfo.readers = bookNameLitInfo.readers or {}

        local readerMemory = bookNameLitInfo.readers[playerReaderID]
        -- readerMemory.totalTimesRead, #readerMemory.timesStampsWhenRead
        if readerMemory then
            local readTimes = readerMemory.timesStampsWhenRead
            if readTimes then
                namedLit.readerMemory.validateSpecificReadTimes(nil,readTimes,player)
                currentTimeStampsLen = math.min(namedLit.readerMemory.getMaxTimesReadable(),#readerMemory.timesStampsWhenRead)
            end
        end
    end

    local divisor = (2^currentTimeStampsLen)+currentTimeStampsLen
    local literatureStats = namedLit.Stats[literature:getType()]

    local UnhappyChange = 0
    local StressChange = 0
    local BoredomChange = 0

    local canRead = SandboxVars.NamedLiterature.CanReadPassedMax or (currentTimeStampsLen < namedLit.readerMemory.getMaxTimesReadable())

    if literatureStats and canRead then
        if literatureStats.UnhappyChange then
            UnhappyChange = math.floor(literatureStats.UnhappyChange/divisor)
        end
        if literatureStats.StressChange then
            StressChange = math.floor(literatureStats.StressChange/divisor)
        end
        if literatureStats.BoredomChange then
            BoredomChange = math.floor(literatureStats.BoredomChange/divisor)
        end
    end

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


function namedLit.readerMemory.getTotalTimesRead(book,title,player)
    if (not book and not title) or not player then return end

    if title then
        local specificBook = namedLit.readerMemory.getSpecificBook(title,player)
        return specificBook.totalTimesRead, #specificBook.timesStampsWhenRead
    else
        local bookNameLitInfo = book:getModData()["namedLit"]
        local playerReaderID = namedLit.readerMemory.getOrSetReaderID(player)
        bookNameLitInfo.readers = bookNameLitInfo.readers or {}
        local readerMemory = bookNameLitInfo.readers[playerReaderID]
        if not readerMemory then return 0, 0 end
        return readerMemory.totalTimesRead, #readerMemory.timesStampsWhenRead
    end
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
        if timeStamp+namedLit.readerMemory.getTimeToForget() < getGametimeTimestamp() then
            table.insert(validatedTimesRead, timeStamp)
        end
    end
    specificBookTimeStampsWhenRead = validatedTimesRead
end


function namedLit.readerMemory.addReadTime(book,title,player)
    if (not book and not title) or not player then return end

    local specificBookTSWR

    if title then
        local specificBook = namedLit.readerMemory.getSpecificBook(title,player)
        specificBookTSWR = specificBook.timesStampsWhenRead
        specificBook.totalTimesRead = (specificBook.totalTimesRead or 0)+1
    else
        local playerReaderID = namedLit.readerMemory.getOrSetReaderID(player)
        local bookNameLitInfo = book:getModData()["namedLit"]

        bookNameLitInfo.readers = bookNameLitInfo.readers or {}
        bookNameLitInfo.readers[playerReaderID] = bookNameLitInfo.readers[playerReaderID] or {}
        local readerMemory = bookNameLitInfo.readers[playerReaderID]
        readerMemory.timesStampsWhenRead = readerMemory.timesStampsWhenRead or {}
        specificBookTSWR = readerMemory.timesStampsWhenRead
        readerMemory.totalTimesRead = (readerMemory.totalTimesRead or 0)+1
    end

    table.insert(specificBookTSWR, getGametimeTimestamp())

    while #specificBookTSWR > namedLit.readerMemory.getMaxTimesReadable() do
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
