namedLit = {}

namedLit.StackableTypes = {["Base.Book"]=true,["Base.Magazine"]=true,["Base.HottieZ"]=true}
namedLit.setLiterature = {}

function namedLit.stringToIconID(str,sets)
    if string.len(str)<6 then
        local stretch = 6-string.len(str)
        for i=1, stretch do
            str = str..str
            if string.len(str)>=6 then
                break
            end
        end
    end

    local stringy = (str:gsub('.', function (c) return string.format('%02X', string.byte(c)) end))
    stringy = stringy:gsub("%D+", "")
    stringy = stringy:gsub('0', '')
    --only 1-9, no alpha no 0

    local newID = tonumber(stringy:sub(-1))

    if sets then
        for i=1, sets do
            if (stringy:sub(i,i) % 2 == 0) then
                newID = newID+9
            end
        end
    end

    return newID
end

---@param literature Literature | InventoryItem | IsoObject
function namedLit.applyTexture(literature, title)
    if not literature then return end
    local func = namedLit["applyTexture"..literature:getType()]
    if func then
        func(literature, title)
    end
end

---@param literature Literature | InventoryItem | IsoObject
function namedLit.applyTitle(literature)
    if not literature then return end

    local title, author, year
    local litNameLitInfo = literature:getModData()["namedLit"]
    if not litNameLitInfo then
        literature:getModData()["namedLit"] = {}
        litNameLitInfo = literature:getModData()["namedLit"]

        local infoFunc = namedLit["getLitInfo"..literature:getType()]
        if infoFunc then
            title, author, year = infoFunc()
            if title then litNameLitInfo["title"] = title end
            if author then litNameLitInfo["author"] =  author end
            if year then litNameLitInfo["year"] =  year end
        end
    end

    if litNameLitInfo then
        title = litNameLitInfo["title"]
        literature:setName(title)
        namedLit.applyTexture(literature, title)
    end
    namedLit.setLiterature[literature] = true
end


---@param ItemContainer ItemContainer
function namedLiteratureContainerScan(ItemContainer)
    if not ItemContainer then return end
    local items = ItemContainer:getItems()
    for iteration=0, items:size()-1 do
        ---@type InventoryItem
        local item = items:get(iteration)

        if item and namedLit.StackableTypes[item:getFullType()] and (not namedLit.setLiterature[item]) then
            namedLit.applyTitle(item)
            --[DEBUG]] print("--n:"..item:getName().."  dn:"..item:getDisplayName().."  t:"..item:getType().."  ft:"..item:getFullType().."  c:"..item:getCategory())
        end
    end
end

---@param ItemContainer ItemContainer
function namedLiteratureOnFillContainer(a, b, ItemContainer)
    namedLiteratureContainerScan(ItemContainer)
end
Events.OnFillContainer.Add(namedLiteratureOnFillContainer)