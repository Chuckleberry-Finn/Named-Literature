require "namedLit -- Main"
local function modifyLitScript()
    for type,_ in pairs(namedLit.StackableTypes) do
        local bookScript = getScriptManager():getItem(type)
        if bookScript then
            bookScript:setUnhappyChange(0)
            bookScript:setStressChange(0)
            bookScript:setBoredomChange(0)
            bookScript:setDisappearOnUse(false)
            bookScript:setReplaceOnUse(nil)
        end
    end
end
Events.OnGameBoot.Add(modifyLitScript)