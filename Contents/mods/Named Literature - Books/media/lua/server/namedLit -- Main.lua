Events.OnGameBoot.Add(print("Named Literature: ver:0.0.1-JUN19"))

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

---@param book HandWeapon | InventoryItem | IsoObject
function namedLit.applyTitle(book)
    if not book then return end

    local bookNameLitInfo = book:getModData()["namedLit"]

    if bookNameLitInfo then
        print("ERR: namedLit: bookNameLitInfo doesn't need to be created")
        return
    end

    book:getModData()["namedLit"] = {}
    bookNameLitInfo = book:getModData()["namedLit"]

    --if title already found then return
    if bookNameLitInfo["title"] then return end

    --store title and author
    local title, author, year = namedLit.getTitleAuthor()

    if title then
        bookNameLitInfo["title"] = title
    end
    if author then
        bookNameLitInfo["author"] =  author
    end
    if year then
        bookNameLitInfo["year"] =  year
    end

    --set item name to title
    book:setName(bookNameLitInfo["title"])
end


---@param ItemContainer ItemContainer
function namedLiteratureOnFillContainer(a, b, ItemContainer)
    local items = ItemContainer:getItems()
    for iteration=0, items:size()-1 do
        ---@type InventoryItem
        local item = items:get(iteration)
        if item and item:getFullType()=="Base.Book" then
            namedLit.applyTitle(item)
            --[DEBUG]] print("--n:"..item:getName().."  dn:"..item:getDisplayName().."  t:"..item:getType().."  ft:"..item:getFullType().."  c:"..item:getCategory())
        end
    end
end
Events.OnFillContainer.Add(namedLiteratureOnFillContainer)