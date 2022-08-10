--[[
local function generateBookModels()
    local iterations = 27
    for n=1, iterations do
        local script = "model namedLitBook"..n.."Ground {mesh = WorldItems/BookClosed,texture = modelTexture/namedLitBookTexture"..n..",scale = 0.4,}"
        --"namedLitBook"..n.."Ground"
        print("DEBUG: namedLit: script generated: "..script)
        getScriptManager():ParseScript(script)
    end
end
Events.OnGameBoot.Add(generateBookModels)
--]]
