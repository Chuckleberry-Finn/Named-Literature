local function generateBookModels()
    local iterations = 27
    for n=1, iterations do
        local script = "model namedLitBook"..n.."Ground {mesh = WorldItems/BookClosed,texture = modelTexture/namedLitBookTexture"..n..",scale = 0.4,}"
        --"namedLitBook"..n.."Ground"
        --[[DEBUG]] print("DEBUG: namedLit: script generated: "..script)
        getScriptManager():ParseScript(script)
    end
end
Events.OnGameBoot.Add(generateBookModels)


local function modifyBookScript()
    ---@type Item
    local bookScript = getScriptManager():getItem("Base.Book")
    bookScript:setUnhappyChange(0)
    bookScript:setStressChange(0)
    bookScript:setBoredomChange(0)
    bookScript:setDisappearOnUse(false)
end
Events.OnGameBoot.Add(modifyBookScript)