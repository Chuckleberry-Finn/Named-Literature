require "namedLit -- Main"

namedLit.COMICS = {}

namedLit.showType.Comic = true

function namedLit.getLitInfoComic()
    local title = namedLit.COMICS[ZombRand(#namedLit.COMICS)+1]
    return title
end

namedLit.COMICS_iconIDs = {}
for _,title in pairs(namedLit.COMICS) do
    namedLit.COMICS_iconIDs[title] = namedLit.stringToIconID(title)
end

--[[
---@param literature IsoObject|InventoryItem|Literature
function namedLit.applyTextureComic(literature, title)
    --[DEBUG] print("DEBUG: namedLit: applyTextureMagazine: "..title)
    local titleTextureID = namedLit.MAGAZINE_iconIDs[title]
    if titleTextureID then
        --[DEBUG] print("-- titleTextureID:"..titleTextureID)
        local itemTexture = getTexture("media/textures/item/namedLitMagazine"..titleTextureID..".png")
        if itemTexture then
            --[DEBUG] print("-- itemTexture:"..tostring(itemTexture))
            literature:setTexture(itemTexture)
        end
    end
end
--]]