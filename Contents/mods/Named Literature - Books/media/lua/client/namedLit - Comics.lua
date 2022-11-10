require "namedLit -- Main"

namedLit.COMICS_YEARS = { ["1993"]=50,["1992"]=45,["1991"]=40,["1990"]=35,["1989"]=30,["1988"]=25,["1987"]=20,["1986"]=25,["1985"]=20,["1984"]=15 }

namedLit.COMICS_YEARS_weighted = false
if not namedLit.COMICS_YEARS_weighted then
    namedLit.COMICS_YEARS_weighted = {}
    for year,weight in pairs(namedLit.COMICS_YEARS) do
        for i=1, weight do
            table.insert(namedLit.COMICS_YEARS_weighted,year)
        end
    end
end

namedLit.COMICS = {

    ["1993"] = {"Action Comics", "Adventures of Superman", "Superman", "Superman: The Man of Steel", "Turok: Dinosaur Hunter", "Batman", "Darker Image",
                "Deatblow", "Deatmate Prologue", "Stormwatch", "Maxx", "Spawn", "Uncanny X-Men", "Youngblood: Strike File", "Cable", "Amazing Spider-Man",
                "Spider-Man Unlimited", "Cyberforce", "Magnus: Robot Fighter", "X-Men 2099", "Tribe", "Spectacular Spider-Man", "Pitt", "Brigade: The Series",
                "Shadowhawk II: The Secret Revealed", "X-Men", "WildC.A.T.S. Trilogy", "Shadowhawk II", "X-O Manowar", "Bloodstrike", "Web of Spider-Man", "Venom",
                "Rai & The Future Force", "Sabretooth", "Shadowhawk", "1963: Mystery, Inc.", "Savage Dragon", "Wildstar: Sky Zero", "Union", "Deathmate Yellow",
                "Deathmate Black", "Deathmate Blue", "X-Factor", "Plasm", "Secret Weapons", "Wolverine", "X-Men Unlimited", "X-Force", "Venom: Funeral Pyre", "Brigade",
                "Secret Defenders", "Shaman's Tears", "The Maxx", "Youngblood Yearbook", "Deathmate Epilogue", "Infinity Crusade", "Gambit", "Prophet", "Hellstorm",
                "Youngblood: Battlezone", "Second Life of Doctor Mirage", "Uncanny X_Men", "Ninjak", "Fantastic Four", "Deadpool", "Thunderstrike", "Deathblow",
                "Team Youngblood", "Detective Comics", "Image Swimsuit Special", "Supreme", "WildC.A.T.S.", "Legacy of Superman", "Catwoman", "Punisher 2099",
                "Spider-Man 2099", "2099 Unlimited", "Venom: The Madness", "Youngblood : Strike File", "Uncanny X-Men Annual", "1963: The Fury", "Spider-Man",
                "Silver Surfer/Warlock: Ressurection", "Superpatriot", "Bloodshot", "WildC.A.T.S. Sourcebook", "Aliens vs. Predator: Deadlies of the Species",
                "Avengers", "Trencher", "Iron Man", "Death: High Cost of Living", "Showcase 93", "H.A.R.D. Corps", "Arcadia Week One: X", "Solar, Man of the Atom",
                "Robin", "Harbinger", "X-Men Annual", "Vanguard", "Shadowhawk III", "Darkhawk", "Wild Thing", "Eternal Warrior", "Superman: The Man of Steel Annual",
                "Doom 2099", "Amazing Spider-Man Annual", "Excalibur", "Shadowman", "Namor the Sub-Mariner", "Savage Dragon vs. Savage Megaton Man", "Image Plus",},

    ["1992"] = { "Superman", "WildC.A.T.S.", "Venom", "Spider-Man 2099", "Spawn", "Spider-Man", "Punisher 2099", "Pitt", "Uncanny X-Men", "X-Men", "Wetworks",
                 "Bloodshot", "Amazing Spider-Man", "Cable", "X-Force", "Punisher War Zone", "Doom 2099", "Green Lantern", "Ravage 2099", "X-Factor", "Brigade",
                 "Ghost Rider/Blaze: Spirits of Vengeance", "Infinity War", "Youngblood", "Incredible Hulk", "Cyberforce", "Supreme", "Morbius", "X-Men Annual",
                 "Batman: Shadow of the Bat", "Ghost Rider", "Nightstalkers", "Shadowhawk", "Silver Surfer", "Youngblood: Battlezone", "Silver Sable",
                 "X-Men: The Animated Series", "Uncanny X-Men Annual", "Savage Dragon", "X-Force Annual", "Cage", "Stryfe's Strike File", "Death's Head II",
                 "Operation: Urban Storm", "Web of Spider-Man", "Superman: The Man of Steel", "Lobo's Back", "Predator vs. Magnus Robot Fighter",
                 "Ghost Rider: Spirits of Vengeance", "Darkhold", "Spectacular Spider-Man", "Robin III", "Eclipso: The Darkness Within", "Wolverine", "X-Factor Annual",
                 "Savage Dragon vs. the Savage Megaton Man", "Superman: Man of Steel", "Ghost Rider & Blaze: Spirits", "Adventures of Superman", "Punisher",
                 "Marvel Comics Presents", "Action Comics", "Lobo: Infanticide", "Warlock & The Infinity Watch", "Amazing Spider-Man Anniversary", "X-Facotr",
                 "Death's Head II vs. Killpower: Battle Tide", "Batman: Gotham Nights", "Doctor Strange", "Lobo: Blazing Chain of Love",
                 "Green Lantern & Blaze: Spirits of Vengeance", "Nomad", "Punisher War Journal", "Next Men", "Batman: Sword of Azrael", "Robocop vs. Terminator",
                 "New Warriors", "Shadow Riders", "Fantastic Four", "Unity", "Batman vs. Predator", "Night Thrasher: Four Control", "H.A.R.D. Corps", "Deathlok",
                 "Iron Man", "Batman Adventures", "Captain America", "Archer & Armstrong: Eternal Warrior", "Dracula", "X-Men Adventures", "Guardians of the Galaxy",
                 "Web of Spider-Man Annual", "Spectacular Spider-Man Annual", "Splitting Image", "Darkhawk", "X-O Manowar", },

    ["1991"] = { "X-Men", "Uncanny X-Men", "X-Force", "X-Factor", "Spider-Man", "Infinity Gauntlet", "Ghost Rider", "Wolverine", "Armageddon 2001", "Amazing Spider-Man",
                 "Deathlok", "Silver Surfer", "Punisher", "Excalibur", "NFL Superpro", "War of the Gods", "Batman: Legends of the Dark Knight", "Detective Comics Annual",
                 "Wonder Man", "Marvel Comics Presents", "Batman", "Incredible Hulk", "Adventures of Superman Annual", "Justice League Europe Annual", "New Warriors",
                 "Punisher War Journal", "Daredevil", "Deathstroke: The Terminator", "Darkhawk", "Sleepwalker", "Punisher: Family Affair", "Detective Comics", "Avengers",
                 "Spectacular Spider-Man", "Guardians of the Galaxy", "Web of Spider-Man", "Superman: The Man of Steel", "Batman: Holy Terror",
                 "Terminator: Secondary Objectives", "Fantastic Four", "Ragman", "Original Ghost Rider Rides Again", "Doctor Strange Sorceror Supreme", "Giant Size X-Men",
                 "Quasar", "Namor the Sub-Mariner", "Thor", "Captain America", "Avengers West Coast", "Action Comics", "Iron Man", "Avengers West Coast Annual",
                 "Green Lantern", "Punisher POV", "Superman", "What If", "Justice League Europe", "Nick Fury Agent of S.H.I.E.L.D.", "Justice League America",
                 "Adventures of Superman", "Spider-Man Saga", "Terminator 2", "Death's Head", "Adventures of Captain America", "Flash", "Web", "New Titans",
                 "Sensational She-Hulk", "Legion of Super-Heroes", "Alpha Flight", "Sandman", "Star Trek: The Next Generation - The Modala Imperative", "Captain Planet",
                 "L.E.G.I.O.N. '91", "Star Trek", "Magnus Robot Fighter", "Queen of the Damned", "Fly", "Justice Society of America", "Comet", "Legend of the Shield",
                 "Marvel Super-Heroes", "Demon", "Hawkworld", "Wonder Woman", "Teenage Mutant Ninja Turtles", "Bill and Ted's Comic Book", "Star Trek: The Next Generation",
                 "Marc Spector Moon Knight", "X-Men Classic", "Green Arrow", "Jaguar", },

    ["1990"] = { "Legends of the Dark Knight", "Batman", "Spider-Man", },
    ["1989"] = { "Uncanny X-Men", "Batman", "Legends of the Dark Knight", },
    ["1988"] = { "Uncanny X-Men", "Batman: The Killing Joke", "Marvel Comics Presents", "Excalibur", "Wolverine", },
    ["1987"] = { "Uncanny X-Men", "Punisher", "Amazing Spider-Man Annual", },
    ["1986"] = { "X-Factor", "Uncanny X-Men", "Classic X-Men", "The Man of Steel", "Superman Vol. 2", },
    ["1985"] = { "Uncanny X-Men", "Secret Wars II", "X-Factor", },
    ["1984"] = { "Marvel Super Heroes Secret Wars", },
}

namedLit.showType.ComicBook = true

namedLit.COMICS_weighted = false

namedLit.COMICS_iconIDs = {}

if not namedLit.COMICS_weighted then
    namedLit.COMICS_weighted = {}
    --[DEBUG]] local debugText, totalTitles = "\nDEBUG: namedLit:", 0
    for year,titles in pairs(namedLit.COMICS) do
        namedLit.COMICS_weighted[year] = {}
        --[DEBUG]] debugText, totalTitles = debugText.."\n"..year.."  n of titles:"..(#titles/2), totalTitles+(#titles/2)
        for i=1, #titles, 1 do
            local title = titles[i]
            namedLit.COMICS_iconIDs[title] = namedLit.stringToIconID(title)

            local weight = 0
            for ii=1, (#titles-(i-1)) do
                weight = weight+1
                table.insert(namedLit.COMICS_weighted[year],title)
            end
            --[DEBUG]] print("---- "..title.." - "..namedLit.BOOKS_keyedToAuthor[title].." -weight:"..weight.." ColorID:"..namedLit.BOOKS_iconIDs[title])
        end
    end
    --[DEBUG]] print(debugText.."\nTOTAL: "..totalTitles)
end


function namedLit.getLitInfoComicBook()
    local title
    local author
    local year

    --namedLit.BOOKS_YEARS_weighted not set properly
    if type(namedLit.COMICS_YEARS_weighted) ~= "table" then
        print("ERR: namedLit: namedLit.COMICS_YEARS_weighted not initialized")
        return
    end

    local randomYearFromWeighted = namedLit.COMICS_YEARS_weighted[ZombRand(#namedLit.COMICS_YEARS_weighted)+1]
    local titlesToChooseFrom = namedLit.COMICS_weighted[randomYearFromWeighted]

    title = titlesToChooseFrom[ZombRand(#titlesToChooseFrom)+1]
    --author = namedLit.BOOKS_keyedToAuthor[title]
    year = randomYearFromWeighted

    return title, author, year
end



---@param literature IsoObject|InventoryItem|Literature
function namedLit.applyTextureComicBook(literature, title)
    --[DEBUG] print("DEBUG: namedLit: applyTextureComicBook: "..title)
    local titleTextureID = namedLit.COMICS_iconIDs[title]
    if titleTextureID then
        --[DEBUG] print("-- titleTextureID:"..titleTextureID)
        local itemTexture = getTexture("media/textures/item/namedLitComicBook"..titleTextureID..".png")
        if itemTexture then
            --[DEBUG] print("-- itemTexture:"..tostring(itemTexture))
            literature:setTexture(itemTexture)
        end
    end
end
