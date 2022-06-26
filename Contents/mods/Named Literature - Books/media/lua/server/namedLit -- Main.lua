Events.OnGameBoot.Add(print("Named Literature: ver:0.0.2-JUN22"))

namedLitStackableTypes = {["Base.Book"]=true}
namedLit = namedLit or {}

function namedLit.getTitleAuthor()
    local title
    local author
    local year

    --namedLit.YEARS_weighted not set properly
    if type(namedLit.YEARS_weighted) ~= "table" then
        print("ERR: namedLit: namedLit.YEARS_weighted not initialized")
        return
    end

    local randomYearFromWeighted = namedLit.YEARS_weighted[ZombRand(#namedLit.YEARS_weighted)+1]
    local titlesToChooseFrom = namedLit.TITLES_weighted[randomYearFromWeighted]

    title = titlesToChooseFrom[ZombRand(#titlesToChooseFrom)+1]
    author = namedLit.TITLES_keyedToAuthor[title]
    year = randomYearFromWeighted

    return title, author, year
end

--[DEBUG]] for i=0, 10 do local t, a, y = namedLit.getTitleAuthor() print("-DEBUG: namedLit:  t:"..t.."  a:"..a.."  y:"..y) end

namedLit.setBooks = {}
---@param book HandWeapon | InventoryItem | IsoObject
function namedLit.applyTitle(book)
    if not book then return end

    local title, author, year
    local bookNameLitInfo = book:getModData()["namedLit"]
    if not bookNameLitInfo then
        book:getModData()["namedLit"] = {}
        bookNameLitInfo = book:getModData()["namedLit"]

        title, author, year = namedLit.getTitleAuthor()
        if title then bookNameLitInfo["title"] = title end
        if author then bookNameLitInfo["author"] =  author end
        if year then bookNameLitInfo["year"] =  year end
    end

    if bookNameLitInfo then
        title = bookNameLitInfo["title"]
        book:setName(title)
    end
    namedLit.setBooks[book] = true
end


---@param ItemContainer ItemContainer
function namedLiteratureContainerScan(ItemContainer)
    if not ItemContainer then return end
    local items = ItemContainer:getItems()
    for iteration=0, items:size()-1 do
        ---@type InventoryItem
        local item = items:get(iteration)

        if item and namedLitStackableTypes[item:getFullType()] and (not namedLit.setBooks[item]) then
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