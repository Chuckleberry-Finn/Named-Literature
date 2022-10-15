require "namedLit -- Main"

namedLitStats = {}
local function modifyLitScript()
    for type,_ in pairs(namedLit.StackableTypes) do
        local bookScript = getScriptManager():getItem(type)
        if bookScript then

            local justType = bookScript:getName()
            namedLitStats[justType] = {}
            local litStats = namedLitStats[justType]

            litStats.UnhappyChange = bookScript:getUnhappyChange()
            litStats.StressChange = bookScript:getStressChange()
            litStats.BoredomChange = bookScript:getBoredomChange()

            print(" -- Applying namedLit Changes to: "..justType.."  u:"..litStats.UnhappyChange..", s:"..litStats.StressChange..", b:"..litStats.BoredomChange)

            bookScript:setUnhappyChange(0)
            bookScript:setStressChange(0)
            bookScript:setBoredomChange(0)

            bookScript:setDisappearOnUse(false)
            bookScript:setReplaceOnUse(nil)
        end
    end
end
Events.OnGameBoot.Add(modifyLitScript)