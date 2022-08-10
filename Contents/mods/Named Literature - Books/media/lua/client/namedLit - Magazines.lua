require "namedLit -- Main"

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

namedLit.showType.Magazine = true

function namedLit.getLitInfoMagazine()
    local title = namedLit.MAGAZINES[ZombRand(#namedLit.MAGAZINES)+1]
    return title
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
