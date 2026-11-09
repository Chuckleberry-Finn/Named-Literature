local namedLit = require "namedLit - Main"

namedLit.MAGAZINES = {
    "America", "American Artist", "American Craft", "American Heritage",
    "Art in America", "ARTNews", "Astronomy", "Atlantic Monthly", "Audubon",
    "Better Homes and Gardens", "Black Enterprise", "Bloomberg Business Week", "Broadcasting & Cable",
    "Chatelaine", "Commentary", "Consumer Reports", "Crisis", "Current History",
    "Dance Magazine",  "Ebony", "Economist", "Esquire",  "Forbes", "Fortune",  "Good Housekeeping",
    "Harper's", "Harper's Bazaar", "Harper's Weekly", "High Fidelity & Musical America",  "Ladies’ Home Journal", "Life",
    "Mademoiselle", "Money", "Ms.", "Musical America", "Musical Quarterly",
    "National Geographic", "National Review", "National Wildlife", "Natural History", "New Republic", "New York", "New Yorker", "Newsweek",
    "Opera News", "Outdoor Indiana",
    "Parents Magazine", "Parks and Recreation", "Physics Today", "Poetry", "Popular Photography", "Popular Science", "Popular Science Monthly",
    "Redbook", "Rolling Stone",
    "Saturday Evening Post", "Science News", "Scientific American", "Sky & Telescope", "Smithsonian", "Society", "Sports Illustrated",
    "Technology Review", "Theatre Arts", "Time",  "U.S. News and World Report",  "Vogue",  "Women’s sports & fitness",
}

namedLit.MAGAZINES_SUBJECTS = {
    ["America"] = {"popular"},
    ["American Artist"] = {"art", "hobby"},
    ["American Craft"] = {"art", "hobby"},
    ["American Heritage"] = {"popular"},
    ["Art in America"] = {"art"},
    ["ARTNews"] = {"art"},
    ["Astronomy"] = {"science", "hobby"},
    ["Atlantic Monthly"] = {"popular", "rich"},
    ["Audubon"] = {"outdoors", "science"},
    ["Better Homes and Gardens"] = {"popular", "hobby"},
    ["Black Enterprise"] = {"business"},
    ["Bloomberg Business Week"] = {"business"},
    ["Broadcasting & Cable"] = {"business", "tech"},
    ["Chatelaine"] = {"popular", "fashion"},
    ["Commentary"] = {"rich"},
    ["Consumer Reports"] = {"popular", "tech", "cars"},
    ["Crisis"] = {"popular"},
    ["Current History"] = {"rich"},
    ["Dance Magazine"] = {"art", "music"},
    ["Ebony"] = {"popular"},
    ["Economist"] = {"business", "rich"},
    ["Esquire"] = {"popular", "fashion"},
    ["Forbes"] = {"business", "rich"},
    ["Fortune"] = {"business", "rich"},
    ["Good Housekeeping"] = {"popular"},
    ["Harper's"] = {"rich"},
    ["Harper's Bazaar"] = {"fashion", "rich"},
    ["Harper's Weekly"] = {"popular"},
    ["High Fidelity & Musical America"] = {"music", "tech"},
    ["Ladies’ Home Journal"] = {"popular"},
    ["Life"] = {"popular"},
    ["Mademoiselle"] = {"fashion"},
    ["Money"] = {"business"},
    ["Ms."] = {"popular"},
    ["Musical America"] = {"music"},
    ["Musical Quarterly"] = {"music", "rich"},
    ["National Geographic"] = {"popular", "science", "outdoors"},
    ["National Review"] = {"rich"},
    ["National Wildlife"] = {"outdoors"},
    ["Natural History"] = {"science", "outdoors"},
    ["New Republic"] = {"rich"},
    ["New York"] = {"popular", "rich"},
    ["New Yorker"] = {"rich", "popular"},
    ["Newsweek"] = {"popular"},
    ["Opera News"] = {"music", "rich"},
    ["Outdoor Indiana"] = {"outdoors"},
    ["Parents Magazine"] = {"popular", "health"},
    ["Parks and Recreation"] = {"outdoors", "sports"},
    ["Physics Today"] = {"science"},
    ["Poetry"] = {"art"},
    ["Popular Photography"] = {"hobby", "art", "tech"},
    ["Popular Science"] = {"science", "tech", "popular"},
    ["Popular Science Monthly"] = {"science", "tech"},
    ["Redbook"] = {"popular"},
    ["Rolling Stone"] = {"music", "popular"},
    ["Saturday Evening Post"] = {"popular"},
    ["Science News"] = {"science"},
    ["Scientific American"] = {"science"},
    ["Sky & Telescope"] = {"science", "hobby"},
    ["Smithsonian"] = {"popular", "science"},
    ["Society"] = {"rich"},
    ["Sports Illustrated"] = {"sports", "popular"},
    ["Technology Review"] = {"tech", "science"},
    ["Theatre Arts"] = {"art", "cinema"},
    ["Time"] = {"popular"},
    ["U.S. News and World Report"] = {"popular"},
    ["Vogue"] = {"fashion", "rich"},
    ["Women’s sports & fitness"] = {"sports", "health"},
}

namedLit.VANILLA_MAGAZINE_SUBJECT_COUNTS = {
    ["art"]=4,
    ["business"]=9,
    ["cars"]=9,
    ["childs"]=7,
    ["cinema"]=4,
    ["crime"]=6,
    ["fashion"]=6,
    ["firearm"]=4,
    ["gaming"]=5,
    ["golf"]=3,
    ["health"]=6,
    ["hobby"]=13,
    ["horror"]=6,
    ["humor"]=4,
    ["military"]=7,
    ["music"]=7,
    ["outdoors"]=9,
    ["police"]=5,
    ["popular"]=18,
    ["rich"]=10,
    ["science"]=6,
    ["sports"]=13,
    ["tech"]=7,
    ["teens"]=11,
}


---@param literature Literature | InventoryItem
function namedLit.getMagazineSubjectKey(literature)
    local ids = {}
    local subjects = literature:getMagazineSubjects()
    for i=0, subjects:size()-1 do
        local location = Registries.MAGAZINE_SUBJECT:getLocation(subjects:get(i))
        if location then table.insert(ids, location:getPath()) end
    end
    table.sort(ids)
    return "Magazine:"..table.concat(ids, ","), ids
end


namedLit.MAGAZINES_pools = {}
---@param literature Literature | InventoryItem
function namedLit.getMagazinePool(literature)
    local key, ids = namedLit.getMagazineSubjectKey(literature)
    if namedLit.MAGAZINES_pools[key] then return namedLit.MAGAZINES_pools[key] end

    local wanted = {}
    for _,id in pairs(ids) do wanted[id] = true end

    local pool = {key=key, titles={}, vanillaCount=0}
    for _,title in pairs(namedLit.MAGAZINES) do
        local match = #ids == 0
        for _,subject in pairs(namedLit.MAGAZINES_SUBJECTS[title] or {"popular"}) do
            if wanted[subject] then match = true end
        end
        if match then table.insert(pool.titles, title) end
    end

    if #ids == 0 then
        pool.vanillaCount = Registries.MAGAZINE:values():size()
    else
        for _,id in pairs(ids) do pool.vanillaCount = pool.vanillaCount+(namedLit.VANILLA_MAGAZINE_SUBJECT_COUNTS[id] or 0) end
    end

    namedLit.MAGAZINES_pools[key] = pool
    return pool
end


---@param literature Literature | InventoryItem
function namedLit.getTitlePoolMagazine(literature)
    local pool = namedLit.getMagazinePool(literature)
    return pool.key, #pool.titles, pool.vanillaCount
end


---@param literature Literature | InventoryItem
function namedLit.getLitInfoMagazine(literature)
    local pool = namedLit.getMagazinePool(literature)
    if #pool.titles < 1 then return end
    local title = pool.titles[ZombRand(#pool.titles)+1]
    local month, year = namedLit.getVanillaIssue(literature)
    return title, nil, year, month
end

namedLit.MAGAZINE_iconIDs = {}
for _,title in pairs(namedLit.MAGAZINES) do
    namedLit.MAGAZINE_iconIDs[title] = namedLit.stringToIconID(title)
end


---@param literature IsoObject|InventoryItem|Literature
function namedLit.applyTextureMagazine(literature, title)
    --[DEBUG]] print("DEBUG: namedLit: applyTextureMagazine: "..title)
    local titleTextureID = namedLit.MAGAZINE_iconIDs[title]
    if titleTextureID then
        --[DEBUG]] print("-- titleTextureID:"..titleTextureID)
        local itemTexture = getTexture("media/textures/item/namedLitMagazine"..titleTextureID..".png")
        if itemTexture then
            --[DEBUG]] print("-- itemTexture:"..tostring(itemTexture))
            literature:setTexture(itemTexture)
        end
    end

end
