local namedLit = {}
namedLit.literatureTypes = {
    ["Base.Book"]="Book",
    ["Base.Paperback"]="Book",

    ["Base.Magazine"]="Magazine",
    ["Base.Magazine_New"]="Magazine",

    ["Base.ComicBook"]="ComicBook",
    ["Base.ComicBook_Retail"]="ComicBook",

    ["Base.HottieZ"]="HottieZ",
    ["Base.HottieZ_New"]="HottieZ",
}


namedLit.titlePools = {
    ComicBook = {modIDs="COMICS_iconIDs", registry="COMIC_BOOK"},
    HottieZ = {modIDs="NUDIEMAGS_iconIDs", vanillaCount=2},
}


namedLit.modTitleChance = {}
---@param literature Literature | InventoryItem
function namedLit.getModTitleChance(literature, litType)
    local key, modCount, vanillaCount = litType, nil, nil
    local poolFunc = namedLit["getTitlePool"..litType]
    if poolFunc then key, modCount, vanillaCount = poolFunc(literature) end

    if namedLit.modTitleChance[key] then return namedLit.modTitleChance[key] end

    if not modCount then
        local pool = namedLit.titlePools[litType]
        if not pool then return 1 end

        modCount = 0
        for _,_ in pairs(namedLit[pool.modIDs] or {}) do modCount = modCount+1 end

        vanillaCount = pool.vanillaCount or 0
        local registry = pool.registry and Registries[pool.registry]
        if registry then vanillaCount = registry:values():size() end
    end

    local chance = 1
    if modCount+vanillaCount > 0 then chance = modCount/(modCount+vanillaCount) end
    namedLit.modTitleChance[key] = chance

    print(" -- namedLit title pool: "..key.."  mod:"..modCount.."  vanilla:"..vanillaCount.."  modChance:"..chance)
    return chance
end


function namedLit.useVanillaTitle(literature)
    if not SandboxVars.NamedLiterature or not SandboxVars.NamedLiterature.VanillaTitles then return false end
    local litType = namedLit.literatureTypes[literature:getFullType()]
    if not litType then return false end
    return ZombRandFloat(0, 1) >= namedLit.getModTitleChance(literature, litType)
end


namedLit.vanillaCreateTypes = {
    ["ItemCodeOnCreate.onCreateSubjectBook"]="Book",
    ["ItemCodeOnCreate.onCreateSubjectMagazine"]="Magazine",
    ["ItemCodeOnCreate.onCreateComicBook"]="ComicBook",
    ["ItemCodeOnCreate.onCreateComicBookRetail"]="ComicBook",
    ["ItemCodeOnCreate.onCreateHottieZ"]="HottieZ",
}


namedLit.vanillaOnCreate = {}
function namedLit.hookOnCreate()
    local allItems = getScriptManager():getAllItems()
    for i=0, allItems:size()-1 do
        local litScript = allItems:get(i)
        local litType = namedLit.vanillaCreateTypes[litScript:getLuaCreate()]
        if litType then
            namedLit.literatureTypes[litScript:getFullName()] = litType
        end
    end

    for type,_ in pairs(namedLit.literatureTypes) do
        local litScript = getScriptManager():getItem(type)
        if litScript then
            local luaCreate = litScript:getLuaCreate()
            if luaCreate ~= "namedLiteratureOnCreate" then
                namedLit.vanillaOnCreate[type] = luaCreate
                litScript:setLuaCreate("namedLiteratureOnCreate")
                print(" -- Applying namedLit OnCreate to: "..type.."  vanilla:"..tostring(luaCreate))
            end
        end
    end
end
Events.OnGameBoot.Add(namedLit.hookOnCreate)


function namedLit.getFunction(path)
    local func = _G
    for key in string.gmatch(path, "[^%.]+") do
        if type(func) ~= "table" then return end
        func = func[key]
    end
    return func
end


---@param literature Literature | InventoryItem
function namedLit.onCreate(literature)
    local vanillaOnCreate = namedLit.vanillaOnCreate[literature:getFullType()]
    local func = vanillaOnCreate and namedLit.getFunction(vanillaOnCreate)
    if func then func(literature) end
    if namedLit.useVanillaTitle(literature) then return end
    namedLit.applyTitle(literature)
end
namedLiteratureOnCreate = namedLit.onCreate


function namedLit.stringToHash(str)
    local hash = 0
    for i=1, string.len(str) do
        hash = (hash*31+string.byte(str, i)) % 2147483647
    end
    return hash
end


function namedLit.stringToIconID(str,sets)
    return (namedLit.stringToHash(str) % (9*((sets or 0)+1)))+1
end


---@param literature Literature | InventoryItem
function namedLit.getVanillaIssue(literature)
    local vanillaTitle = literature:getModData()["literatureTitle"]
    if not vanillaTitle then return end
    local month, year = string.match(vanillaTitle, "_(%d+)_(%d+)$")
    return month, year
end


---@param literature Literature | InventoryItem
function namedLit.applyTexture(literature, litType, title)
    local icons = literature:getIconsForTexture()
    if icons and icons:size() > 1 then
        literature:setModelIndex(namedLit.stringToHash(title) % icons:size())
        return
    end

    local func = namedLit["applyTexture"..litType]
    if func then
        func(literature, title)
    end
end


---@param literature Literature | InventoryItem
function namedLit.applyTitle(literature)
    local litType = namedLit.literatureTypes[literature:getFullType()]
    if not litType or literature:getModData()["namedLit"] then return end

    local infoFunc = namedLit["getLitInfo"..litType]
    if not infoFunc then return end

    local title, author, year, month = infoFunc(literature)
    if not title then return end

    literature:getModData()["namedLit"] = {}
    local litNameLitInfo = literature:getModData()["namedLit"]
    litNameLitInfo["title"] = title
    if author then litNameLitInfo["author"] = author end
    if year then litNameLitInfo["year"] = year end
    if month then litNameLitInfo["month"] = month end

    local typeName = literature:getScriptItem():getDisplayName()
    local titleText = title
    if author then titleText = getText("IGUI_namedLit_TITLE_AUTHOR", title, author) end

    if month and year then
        literature:setName(getText("IGUI_namedLit_ISSUE", typeName, titleText, getText("Sandbox_StartMonth_option"..month), year))
    else
        literature:setName(getText("IGUI_MagazineNameNoIssue", typeName, titleText))
        if year then literature:setTooltip(getText("IGUI_namedLit_PUBLISHED", year)) end
    end

    literature:getModData()["literatureTitle"] = "namedLit_"..title..(year and "_"..year or "")..(month and "_"..month or "")

    namedLit.applyTexture(literature, litType, title)
end


return namedLit
