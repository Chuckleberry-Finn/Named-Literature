require "ISUI/ISToolTipInv"
require "ISUI/ISInventoryPane"
require "namedLit -- Main"
require "namedLit --- Reader Memory"

local ISToolTipInv_setItem = ISToolTipInv.setItem
function ISToolTipInv:setItem(book)
    ISToolTipInv_setItem(self, book)
    if namedLit.StackableTypes[book:getFullType()] then
        local bookNameLitInfo = book:getModData()["namedLit"]
        if bookNameLitInfo then

            local tooltipAddition = ""
            local title, author, year = bookNameLitInfo["title"], bookNameLitInfo["author"], bookNameLitInfo["year"]

            if author then
                tooltipAddition = tooltipAddition.."\nBy "..author
            end
            if year then
                tooltipAddition = tooltipAddition.."\nPublished in "..year.."."
            end

            local player = self.tooltip:getCharacter()
            local totalTimesRead = namedLit.readerMemory.getTotalTimesRead(title,player)
            if totalTimesRead then
                tooltipAddition = tooltipAddition.."\n\nI've read this "..totalTimesRead.." time"
                if totalTimesRead > 1 then tooltipAddition = tooltipAddition.."s." else tooltipAddition = tooltipAddition.."." end
            end

            local UnhappyChange, StressChange, BoredomChange = namedLit.readerMemory.statsImpact(title,player)
            if BoredomChange or StressChange or UnhappyChange then tooltipAddition = tooltipAddition.."\n" end

            if BoredomChange ~= 0 then
                tooltipAddition = tooltipAddition.."\n"..getText("Tooltip_literature_Boredom_Reduction")..": "..BoredomChange
            end

            if StressChange ~= 0 then
                tooltipAddition = tooltipAddition.."\n"..getText("Tooltip_literature_Stress_Reduction")..": "..StressChange
            end

            if UnhappyChange ~= 0 then
                tooltipAddition = tooltipAddition.."\n"..getText("Tooltip_food_Unhappiness")..": "..UnhappyChange
            end

            if tooltipAddition ~= "" then
                book:setTooltip(tooltipAddition)
            end
        end
    end
end


function ISInventoryPane:refreshContainer()
    self.itemslist = {}
    self.itemindex = {}

    if self.collapsed == nil then
        self.collapsed = {}
    end
    if self.selected == nil then
        self.selected = {}
    end

    local selected = self:saveSelection({})
    table.wipe(self.selected)

    local playerObj = getSpecificPlayer(self.player)

    if not self.hotbar then
        self.hotbar = getPlayerHotbar(self.player);
    end

    local isEquipped = {}
    local isInHotbar = {}
    if self.parent.onCharacter then
        local wornItems = playerObj:getWornItems()
        for i=1,wornItems:size() do
            local wornItem = wornItems:get(i-1)
            isEquipped[wornItem:getItem()] = true
        end
        local item = playerObj:getPrimaryHandItem()
        if item then
            isEquipped[item] = true
        end
        item = playerObj:getSecondaryHandItem()
        if item then
            isEquipped[item] = true
        end
        if self.hotbar and self.hotbar.attachedItems then
            for _,item in pairs(self.hotbar.attachedItems) do
                isInHotbar[item] = true
            end
        end
    end

    local it = self.inventory:getItems();
    for i = 0, it:size()-1 do
        ---@type InventoryItem
        local item = it:get(i);
        local add = true;
        -- don't add the ZedDmg category, they are just equipped models
        if item:isHidden() then
            add = false;
        end
        if add then
            local itemName = item:getName()

            if namedLit.StackableTypes[item:getFullType()] then
                if not namedLit.setBooks[item] then
                    namedLit.applyTitle(item)
                end
                itemName = item:getScriptItem():getDisplayName()
            end

            if item:IsFood() and item:getHerbalistType() and item:getHerbalistType() ~= "" then
                if playerObj:isRecipeKnown("Herbalist") then
                    if item:getHerbalistType() == "Berry" then
                        itemName = (item:getPoisonPower() > 0) and getText("IGUI_PoisonousBerry") or getText("IGUI_Berry")
                    end
                    if item:getHerbalistType() == "Mushroom" then
                        itemName = (item:getPoisonPower() > 0) and getText("IGUI_PoisonousMushroom") or getText("IGUI_Mushroom")
                    end
                else
                    if item:getHerbalistType() == "Berry"  then
                        itemName = getText("IGUI_UnknownBerry")
                    end
                    if item:getHerbalistType() == "Mushroom" then
                        itemName = getText("IGUI_UnknownMushroom")
                    end
                end
                if itemName ~= item:getDisplayName() then
                    item:setName(itemName);
                end
                itemName = item:getName()
            end
            local equipped = false
            local inHotbar = false
            if self.parent.onCharacter then
                if isEquipped[item] then
                    itemName = "equipped:"..itemName
                    equipped = true
                elseif item:getType() == "KeyRing" and playerObj:getInventory():contains(item) then
                    itemName = "keyring:"..itemName
                    equipped = true
                end
                if self.hotbar then
                    inHotbar = isInHotbar[item];
                    if inHotbar and not equipped then
                        itemName = "hotbar:"..itemName
                    end
                end
            end
            if self.itemindex[itemName] == nil then
                self.itemindex[itemName] = {};
                self.itemindex[itemName].items = {}
                self.itemindex[itemName].count = 0
            end
            local ind = self.itemindex[itemName];
            ind.equipped = equipped
            ind.inHotbar = inHotbar;

            ind.count = ind.count + 1
            ind.items[ind.count] = item;
        end
    end

    for k, v in pairs(self.itemindex) do

        if v ~= nil then
            table.insert(self.itemslist, v);
            local count = 1;
            local weight = 0;
            for k2, v2 in ipairs(v.items) do
                if v2 == nil then
                    table.remove(v.items, k2);
                else
                    count = count + 1;
                    weight = weight + v2:getUnequippedWeight();
                end
            end
            v.count = count;
            v.invPanel = self;
            v.name = k -- v.items[1]:getName();
            v.cat = v.items[1]:getDisplayCategory() or v.items[1]:getCategory();
            v.weight = weight;
            if self.collapsed[v.name] == nil then
                self.collapsed[v.name] = true;
            end
        end
    end


    --print("Preparing to sort inv items");
    table.sort(self.itemslist, self.itemSortFunc );

    -- Adding the first item in list additionally at front as a dummy at the start, to be used in the details view as a header.
    for k, v in ipairs(self.itemslist) do
        local item = v.items[1];
        table.insert(v.items, 1, item);
    end

    self:restoreSelection(selected);
    table.wipe(selected);

    self:updateScrollbars();
    self.inventory:setDrawDirty(false);

    -- Update the buttons
    if self:isMouseOver() then
        self:onMouseMove(0, 0)
    end
end


function ISInventoryPane:renderdetails(doDragged)

    self:updateScrollbars();

    if doDragged == false then
        table.wipe(self.items)

        if self.inventory:isDrawDirty() then
            self:refreshContainer()
        end
    end

    local player = getSpecificPlayer(self.player)

    local checkDraggedItems = false
    if doDragged and self.dragging ~= nil and self.dragStarted then
        self.draggedItems:update()
        checkDraggedItems = true
    end

    if not doDragged then
        -- background of item icon
        self:drawRectStatic(0, 0, self.column2, self.height, 0.6, 0, 0, 0);
    end
    local y = 0;
    local alt = false;
    if self.itemslist == nil then
        self:refreshContainer();
    end
    local MOUSEX = self:getMouseX()
    local MOUSEY = self:getMouseY()
    local YSCROLL = self:getYScroll()
    local HEIGHT = self:getHeight()
    local equippedLine = false
    local all3D = true;
    --    self.inventoryPage.render3DItems = {};
    -- Go through all the stacks of items.
    for k, v in ipairs(self.itemslist) do
        local count = 1;
        -- Go through each item in stack..
        for k2, v2 in ipairs(v.items) do
            -- print("trace:a");
            local item = v2;
            local doIt = true;
            local xoff = 0;
            local yoff = 0;
            if doDragged == false then
                -- if it's the first item, then store the category, otherwise the item
                if count == 1 then
                    table.insert(self.items, v);
                else
                    table.insert(self.items, item);
                end

                if instanceof(item, 'InventoryItem') then
                    item:updateAge()
                end
                if instanceof(item, 'Clothing') then
                    item:updateWetness()
                end
            end
            -- print("trace:b");
            local isDragging = false
            if self.dragging ~= nil and self.selected[y+1] ~= nil and self.dragStarted then
                xoff = MOUSEX - self.draggingX;
                yoff = MOUSEY - self.draggingY;
                if not doDragged then
                    doIt = false;
                else
                    self:suspendStencil();
                    isDragging = true
                    -- if dragging and item with a 3D model outside of inventory, ready to render it
                    --                    if not item:getWorldStaticItem() and not instanceof(item, "HandWeapon") and not instanceof(item, "Clothing") then
                    --                        all3D = false;
                    --                    end
                    --                    if all3D and instanceof(item, "Clothing") then
                    --                        all3D = item:canBe3DRender();
                    --                    end
                    --                    if all3D and not self.inventoryPage.mouseOver and not getPlayerLoot(self.player).mouseOver and not getPlayerInventory(self.player).mouseOver then
                    --                        if xoff > self.width or xoff < 0 or yoff < 0 or yoff > self.height then
                    --                            doIt = false;
                    -- multiple selection of a single item, first is dummy
                    --                            if self.selected[y+1].items and #self.selected[y+1].items > 2 then
                    --                                for i,v in ipairs(self.selected[y+1].items) do
                    --                                    if i > 1 then
                    --                                        local add = true;
                    --                                        for x,testItem in ipairs(self.inventoryPage.render3DItems) do
                    --                                            if testItem == v then
                    --                                                add = false;
                    --                                                break;
                    --                                            end
                    --                                        end
                    --                                        if add and self.inventory:getType() ~= "floor" then
                    --                                            table.insert(self.inventoryPage.render3DItems, v)
                    --                                        end
                    --                                        print("add multiple table item ", v, #self.inventoryPage.render3DItems)
                    --                                    end
                    --                                end
                    --                            elseif(self.inventory:getType() ~= "floor") then
                    --                                print("add single item table", item)
                    --                                table.insert(self.inventoryPage.render3DItems, item)
                    --                            end
                    --                            self.inventoryPage.render3DItem = item;
                    --                        else
                    --                            self.inventoryPage.render3DItems = {};
                    --                        end
                    --                    else
                    --                        self.inventoryPage.render3DItems = {};
                    --                    end
                end
            else
                if doDragged then
                    doIt = false;
                end
            end
            local topOfItem = y * self.itemHgt + YSCROLL
            if not isDragging and ((topOfItem + self.itemHgt < 0) or (topOfItem > HEIGHT)) then
                doIt = false
            end
            -- print("trace:c");
            if doIt == true then
                -- print("trace:cc");
                --        print(count);
                if count == 1 then
                    -- rect over the whole item line
                    --                    self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth(), 1, 0.3, 0.0, 0.0, 0.0);
                end
                -- print("trace:d");

                -- do controller selection.
                if self.joyselection ~= nil and self.doController then
                    --                    if self.joyselection < 0 then self.joyselection = (#self.itemslist) - 1; end
                    --                    if self.joyselection >= #self.itemslist then self.joyselection = 0; end
                    if self.joyselection == y then
                        self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth()-1, self.itemHgt, 0.2, 0.2, 1.0, 1.0);
                    end
                end
                -- print("trace:e");

                -- only do icon if header or dragging sub items without header.
                local tex = item:getTex();
                if tex ~= nil then
                    local texDY = 1
                    local texWH = math.min(self.itemHgt-2,32)
                    local auxDXY = math.ceil(20 * self.texScale)
                    if count == 1  then
                        self:drawTextureScaledAspect(tex, 10+xoff, (y*self.itemHgt)+self.headerHgt+texDY+yoff, texWH, texWH, 1, item:getR(), item:getG(), item:getB());
                        if player:isEquipped(item) then
                            self:drawTexture(self.equippedItemIcon, (10+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY+yoff, 1, 1, 1, 1);
                        end
                        if not self.hotbar then
                            self.hotbar = getPlayerHotbar(self.player);
                        end
                        if not player:isEquipped(item) and self.hotbar and self.hotbar:isInHotbar(item) then
                            self:drawTexture(self.equippedInHotbar, (10+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY+yoff, 1, 1, 1, 1);
                        end
                        if item:isBroken() then
                            self:drawTexture(self.brokenItemIcon, (10+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                        end
                        if instanceof(item, "Food") and item:isFrozen() then
                            self:drawTexture(self.frozenItemIcon, (10+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                        end
                        if item:isTaintedWater() or player:isKnownPoison(item) then
                            self:drawTexture(self.poisonIcon, (10+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                        end
                        if item:isFavorite() then
                            self:drawTexture(self.favoriteStar, (13+auxDXY+xoff), (y*self.itemHgt)+self.headerHgt-1+yoff, 1, 1, 1, 1);
                        end
                    elseif v.count > 2 or (doDragged and count > 1 and self.selected[(y+1) - (count-1)] == nil) then
                        self:drawTextureScaledAspect(tex, 10+16+xoff, (y*self.itemHgt)+self.headerHgt+texDY+yoff, texWH, texWH, 0.3, item:getR(), item:getG(), item:getB());
                        if player:isEquipped(item) then
                            self:drawTexture(self.equippedItemIcon, (10+auxDXY+16+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY+yoff, 1, 1, 1, 1);
                        end
                        if item:isBroken() then
                            self:drawTexture(self.brokenItemIcon, (10+auxDXY+16+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                        end
                        if instanceof(item, "Food") and item:isFrozen() then
                            self:drawTexture(self.frozenItemIcon, (10+auxDXY+16+xoff), (y*self.itemHgt)+self.headerHgt+auxDXY-1+yoff, 1, 1, 1, 1);
                        end
                        if item:isFavorite() then
                            self:drawTexture(self.favoriteStar, (13+auxDXY+16+xoff), (y*self.itemHgt)+self.headerHgt-1+yoff, 1, 1, 1, 1);
                        end
                    end
                end
                -- print("trace:f");
                if count == 1 then
                    if not doDragged then
                        if not self.collapsed[v.name] then
                            self:drawTexture( self.treeexpicon, 2, (y*self.itemHgt)+self.headerHgt+5+yoff, 1, 1, 1, 0.8);
                            --                     self:drawText("+", 2, (y*18)+16+1+yoff, 0.7, 0.7, 0.7, 0.5);
                        else
                            self:drawTexture( self.treecolicon, 2, (y*self.itemHgt)+self.headerHgt+5+yoff, 1, 1, 1, 0.8);
                        end
                    end
                end
                -- print("trace:g");

                if self.selected[y+1] ~= nil and not self.highlightItem then -- clicked/dragged item
                    if checkDraggedItems and self.draggedItems:cannotDropItem(item) then
                        self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth()-1, self.itemHgt, 0.20, 1.0, 0.0, 0.0);
                    elseif false and (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() ~= 1) or item:getItemHeat() ~= 1) then
                        if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() > 1) or item:getItemHeat() > 1) then
                            self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.5, math.abs(item:getInvHeat()), 0.0, 0.0);
                        else
                            self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.5, 0.0, 0.0, math.abs(item:getInvHeat()));
                        end
                    else
                        self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth()-1, self.itemHgt, 0.20, 1.0, 1.0, 1.0);
                    end
                elseif self.mouseOverOption == y+1 and not self.highlightItem then -- called when you mose over an element
                    if(((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() ~= 1) or item:getItemHeat() ~= 1) then
                        if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() > 1) or item:getItemHeat() > 1) then
                            self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.3, math.abs(item:getInvHeat()), 0.0, 0.0);
                        else
                            self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.3, 0.0, 0.0, math.abs(item:getInvHeat()));
                        end
                    else
                        self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self:getWidth()-1, self.itemHgt, 0.05, 1.0, 1.0, 1.0);
                    end
                else
                    if count == 1 then -- normal background (no selected, no dragging..)
                        -- background of item line
                        if self.highlightItem and self.highlightItem == item:getType() then
                            if not self.blinkAlpha then self.blinkAlpha = 0.5; end
                            self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  self.blinkAlpha, 1, 1, 1);
                            if not self.blinkAlphaIncrease then
                                self.blinkAlpha = self.blinkAlpha - 0.05 * (UIManager.getMillisSinceLastRender() / 33.3);
                                if self.blinkAlpha < 0 then
                                    self.blinkAlpha = 0;
                                    self.blinkAlphaIncrease = true;
                                end
                            else
                                self.blinkAlpha = self.blinkAlpha + 0.05 * (UIManager.getMillisSinceLastRender() / 33.3);
                                if self.blinkAlpha > 0.5 then
                                    self.blinkAlpha = 0.5;
                                    self.blinkAlphaIncrease = false;
                                end
                            end
                        else
                            if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() ~= 1) or item:getItemHeat() ~= 1) then
                                if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() > 1) or item:getItemHeat() > 1) then
                                    if alt then
                                        self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.15, math.abs(item:getInvHeat()), 0.0, 0.0);
                                    else
                                        self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.2, math.abs(item:getInvHeat()), 0.0, 0.0);
                                    end
                                else
                                    if alt then
                                        self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.15, 0.0, 0.0, math.abs(item:getInvHeat()));
                                    else
                                        self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.2, 0.0, 0.0, math.abs(item:getInvHeat()));
                                    end
                                end
                            else
                                if alt then
                                    self:drawRect(self.column2+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt, 0.02, 1.0, 1.0, 1.0);
                                else
                                    self:drawRect(self.column2+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt, 0.2, 0.0, 0.0, 0.0);
                                end
                            end
                        end
                    else
                        if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() ~= 1) or item:getItemHeat() ~= 1) then
                            if (((instanceof(item,"Food") or instanceof(item,"DrainableComboItem")) and item:getHeat() > 1) or item:getItemHeat() > 1) then
                                self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.2, math.abs(item:getInvHeat()), 0.0, 0.0);
                            else
                                self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.2, 0.0, 0.0, math.abs(item:getInvHeat()));
                            end
                        else
                            self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, self.column4, self.itemHgt,  0.4, 0.0, 0.0, 0.0);
                        end
                    end
                end
                -- print("trace:h");

                -- divider between equipped and unequipped items
                if v.equipped then
                    if not doDragged and not equippedLine and y > 0 then
                        self:drawRect(1, ((y+1)*self.itemHgt)+self.headerHgt-1-self.itemHgt, self.column4, 1, 0.2, 1, 1, 1);
                    end
                    equippedLine = true
                end

                if item:getJobDelta() > 0 and (count > 1 or self.collapsed[v.name]) then
                    local scrollBarWid = self:isVScrollBarVisible() and 13 or 0
                    local displayWid = self.column4 - scrollBarWid
                    self:drawRect(1+xoff, (y*self.itemHgt)+self.headerHgt+yoff, displayWid * item:getJobDelta(), self.itemHgt, 0.2, 0.4, 1.0, 0.3);
                end
                -- print("trace:i");

                local textDY = (self.itemHgt - self.fontHgt) / 2
                --~ 				local redDetail = false;
                local itemName = item:getName()
                local itemNameForStacks = itemName
                if namedLit.StackableTypes[item:getFullType()] then
                    itemNameForStacks = item:getScriptItem():getDisplayName()
                end

                if count == 1 then

                    -- if we're dragging something and want to put it in a container wich is full
                    if doDragged and ISMouseDrag.dragging and #ISMouseDrag.dragging > 0 then
                        local red = false;
                        if red then
                            if v.count > 2 then
                                self:drawText(itemNameForStacks.." ("..(v.count-1)..")", self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.0, 0.0, 1.0, self.font);
                            else
                                self:drawText(itemName, self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.0, 0.0, 1.0, self.font);
                            end
                        else
                            if v.count > 2 then
                                self:drawText(itemNameForStacks.." ("..(v.count-1)..")", self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.7, 0.7, 1.0, self.font);
                            else
                                self:drawText(itemName, self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.7, 0.7, 1.0, self.font);
                            end
                        end
                    else
                        local clipX = math.max(0, self.column2+xoff)
                        local clipY = math.max(0, (y*self.itemHgt)+self.headerHgt+yoff+self:getYScroll())
                        local clipX2 = math.min(clipX + self.column3-self.column2, self.width)
                        local clipY2 = math.min(clipY + self.itemHgt, self.height)
                        if clipX < clipX2 and clipY < clipY2 then
                            self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
                            if v.count > 2 then
                                self:drawText(itemNameForStacks.." ("..(v.count-1)..")", self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.7, 0.7, 1.0, self.font);
                            else
                                self:drawText(itemName, self.column2+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.7, 0.7, 1.0, self.font);
                            end
                            self:clearStencilRect()
                            self:repaintStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
                        end
                    end
                end
                -- print("trace:j");

                --~ 				if self.mouseOverOption == y+1 and self.dragging and not self.parent:canPutIn(item) then
                --~ 							self:drawText(item:getName(), self.column2+8+xoff, (y*18)+16+1+yoff, 0.7, 0.0, 0.0, 1.0);
                --~ 						else

                if item:getJobDelta() > 0  then
                    if  (count > 1 or self.collapsed[v.name]) then
                        if self.dragging == count then
                            self:drawText(item:getJobType(), self.column3+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.0, 0.0, 1.0, self.font);
                        else
                            self:drawText(item:getJobType(), self.column3+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.7, 0.7, 0.7, 1.0, self.font);
                        end
                    end

                else
                    if count == 1 then
                        if doDragged then
                            -- Don't draw the category when dragging
                        elseif item:getDisplayCategory() then -- display the custom category set in items.txt
                            self:drawText(getText("IGUI_ItemCat_" .. item:getDisplayCategory()), self.column3+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.6, 0.6, 0.8, 1.0, self.font);
                        else
                            self:drawText(getText("IGUI_ItemCat_" .. item:getCategory()), self.column3+8+xoff, (y*self.itemHgt)+self.headerHgt+textDY+yoff, 0.6, 0.6, 0.8, 1.0, self.font);
                        end
                    else
                        local redDetail = false;
                        self:drawItemDetails(item, y, xoff, yoff, redDetail);
                    end

                end
                if self.selected ~= nil and self.selected[y+1] ~= nil then
                    self:resumeStencil();
                end

            end
            if count == 1 then
                if alt == nil then alt = false; end
                alt = not alt;
            end

            y = y + 1;

            if count == 1 and self.collapsed ~= nil and v.name ~= nil and self.collapsed[v.name] then
                if instanceof(item, "Food") then
                    -- Update all food items in a collapsed stack so they separate when freshness changes.
                    for k3,v3 in ipairs(v.items) do
                        v3:updateAge()
                    end
                end
                break
            end
            if count == 51 then
                break
            end
            count = count + 1;
            -- print("trace:zz");
        end
    end

    self:setScrollHeight((y+1)*self.itemHgt);
    self:setScrollWidth(0);

    if self.draggingMarquis then
        local w = self:getMouseX() - self.draggingMarquisX;
        local h = self:getMouseY() - self.draggingMarquisY;
        self:drawRectBorder(self.draggingMarquisX, self.draggingMarquisY, w, h, 0.4, 0.9, 0.9, 1);
    end


    if not doDragged then
        self:drawRectStatic(1, 0, self.width-2, self.headerHgt, 1, 0, 0, 0);
    end

end