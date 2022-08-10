require "namedLit -- Main"

namedLit.showType.HottieZ = true

namedLit.NUDIEMAGS = {
    F = { "Adam Film World", "Adam Film World Guide", "Barely Legal", "Hustler Magazine", "Beaver Hunt", "Celebrity Skin",
              "Chic", "Gallery", "Genesis", "Gent", "High Society", "Hustler", "Juggs", "Leg Show", "Modern Man", "Oui",
              "Penthouse Forum", "Perfect 10", "Playboy", "Score", "SCREW", "Swank", --hetMal

              "On Our Backs",--homFem
    },
    M = { "Playgirl", "Viva", --hetFem
              "Black Inches", "Blueboy", "Bound & Gagged", "Drum", "Freshmen", "Honcho", "Mandate", "Manshots", "Playguy", --homMal
    },
}

function namedLit.getLitInfoHottieZ()
    local poolLength = (#namedLit.NUDIEMAGS.F)+(#namedLit.NUDIEMAGS.M)
    local pick = ZombRand(poolLength)+1
    local list = namedLit.NUDIEMAGS.F
    if pick > #namedLit.NUDIEMAGS.F then
        pick = pick-#namedLit.NUDIEMAGS.F
        list = namedLit.NUDIEMAGS.M
    end

    return list[pick]
end

namedLit.NUDIEMAGS_iconIDs = {}
for _,title in pairs(namedLit.NUDIEMAGS.F) do
    namedLit.NUDIEMAGS_iconIDs[title] = namedLit.stringToIconID(title)
end
for _,title in pairs(namedLit.NUDIEMAGS.M) do
    if title == "Black Inches" then
        namedLit.NUDIEMAGS_iconIDs[title] = "M2"
    elseif title == "Bound & Gagged" then
        namedLit.NUDIEMAGS_iconIDs[title] = "bdsm"
    else
        namedLit.NUDIEMAGS_iconIDs[title] = "M"..(namedLit.stringToIconID(title)/3)
    end
end


---@param literature IsoObject|InventoryItem|Literature
function namedLit.applyTextureHottieZ(literature, title)
    --[DEBUG]] print("DEBUG: namedLit: applyTextureMagazine: "..title)
    local titleTextureID = namedLit.NUDIEMAGS_iconIDs[title]
    if titleTextureID then
        --[DEBUG]] print("-- titleTextureID:"..titleTextureID)
        local itemTexture = getTexture("media/textures/item/namedLitNudeMag"..titleTextureID..".png")
        if itemTexture then
            --[DEBUG]] print("-- itemTexture:"..tostring(itemTexture))
            literature:setTexture(itemTexture)
        end
    end

end