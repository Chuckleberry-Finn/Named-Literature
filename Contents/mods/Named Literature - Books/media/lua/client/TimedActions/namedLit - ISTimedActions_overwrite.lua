require "TimedActions/ISReadABook"
require "namedLit --- Reader Memory"
require "namedLit - ISUI_overwrite"

local ISReadABook_perform = ISReadABook.perform
function ISReadABook:perform()
    local bookNameLitInfo = self.item:getModData()["namedLit"]
    if bookNameLitInfo and self.stats then

        ---@type IsoPlayer|IsoGameCharacter
        local player = self.character
        local bodyDamage = player:getBodyDamage()
        local stats = player:getStats()
        local title = bookNameLitInfo["title"]
        local UnhappyChange, StressChange, BoredomChange = namedLit.readerMemory.statsImpact(self.item,title,player)

        stats:setStress(math.max(0,stats:getStress()+StressChange))
        bodyDamage:setUnhappynessLevel(math.max(0,bodyDamage:getUnhappynessLevel()+UnhappyChange))
        bodyDamage:setBoredomLevel(math.max(0,bodyDamage:getBoredomLevel()+BoredomChange))
        namedLit.readerMemory.addReadTime(title,self.character)
    end

    ISReadABook_perform(self)
end


local ISReadABook_update = ISReadABook.update
function ISReadABook:update()
    ISReadABook_update(self)

    local bookNameLitInfo = self.item:getModData()["namedLit"]
    if bookNameLitInfo and self.stats then

        local title = bookNameLitInfo["title"]
        if not title then return end

        local bodyDamage = self.character:getBodyDamage()
        local stats = self.character:getStats()
        local UnhappyChange, StressChange, BoredomChange = namedLit.readerMemory.statsImpact(self.item,bookNameLitInfo["title"],self.character)

        if (BoredomChange < 0.0) then
            if bodyDamage:getBoredomLevel() > self.stats.boredom then
                bodyDamage:setBoredomLevel(self.stats.boredom) end
        end
        if (UnhappyChange < 0.0) then
            if bodyDamage:getUnhappynessLevel() > self.stats.unhappyness then
                bodyDamage:setUnhappynessLevel(self.stats.unhappyness) end
        end
        if (StressChange < 0.0) then
            if stats:getStress() > self.stats.stress then
                stats:setStress(self.stats.stress) end
        end
    end
end