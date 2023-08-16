local MUHAP = LibStub("AceAddon-3.0"):GetAddon("MUHAP")

local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()







MUHAP.Item = {}


function MUHAP.Item:exist(itemKey)
	return self:get(itemKey) and true or false
end


function MUHAP.Item:get(itemKey)
    assert(_.table(itemKey), "itemKey is not table")
    local find = _.find(MUHAP.items, function(v)
        return v.itemKey.itemID == itemKey.itemID  and v.itemKey.itemLevel == itemKey.itemLevel
    end)

    return find
end


function MUHAP.Item:addMissingInfo(entry)
 
    if entry.id then  -- fill in missings informations
        local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
        itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
        expacID, setID, isCraftingReagent = GetItemInfo(entry.id)


     
        if not entry.itemKey then 
            local ILocation = self:getItemLocation(entry.id)
            if  ILocation then
                local itemLevel = C_Item.GetCurrentItemLevel(ILocation)
                entry.itemKey = C_AuctionHouse.MakeItemKey(entry.id, itemLevel)  
            else
                entry.itemKey = C_AuctionHouse.MakeItemKey(entry.id)  
            end
        end

        if not entry.isCommodity then 
            local ILocation = self:getItemLocation(entry.id)
            if ILocation then 
                entry.isCommodity = (C_AuctionHouse.GetItemCommodityStatus(ILocation) == 2 ) and true or false
            end
        end

        entry.Name = itemName

        if not entry.Category then 
            if classID == 3 then --gems
                classID = 4
            elseif  classID == 1 then --container
                classID = 3 
            end

            entry.Category = classID
            entry.SubCategory = (subclassID == 0) and 1 or subclassID
            entry.SubSubCategory = nil
            
            print( classID, subclassID)
        end
    end

    return entry
end

function MUHAP.Item:add(entry)
    if self:exist(entry.itemKey) then return end
    entry = self:addMissingInfo(entry)
    MUHAP.items[#MUHAP.items + 1] = entry
    MUHAP.Tabs:SetTab(2, true)
end


function MUHAP.Item:delete(itemKey)
	if not self:exist(itemKey) then return end

    _.remove(MUHAP.items, function(value)
        return value.itemKey.itemID == itemKey.itemID and  value.itemKey.itemLevel == itemKey.itemLevel
    end)

	MUHAP.List:reload()
end



function MUHAP.Item:getItemLocation(itemID)

    local newItemLocation = false
    _.forEach(_.range(0, NUM_TOTAL_EQUIPPED_BAG_SLOTS), function(containerIndex)
        _.forEach(_.range(1, C_Container.GetContainerNumSlots(containerIndex)), function(slotIndex)
            if C_Container.GetContainerItemID(containerIndex, slotIndex) == itemID then
                newItemLocation = ItemLocation:CreateFromBagAndSlot(containerIndex, slotIndex)
            end
        end)
    
    end)

    return newItemLocation;
end




function MUHAP.Item:runCheck(itemKey)
    if not itemKey then return end 

    local item = self:get(itemKey)
    if not item.enabled then return end

	if (item.lastChecked + 5) > time() then 
		print("runCheck too fast", item.id)
		return
	end

    local sortOrder = (item.isCommodity) and  Enum.AuctionHouseSortOrder.Price or Enum.AuctionHouseSortOrder.Buyout

    C_AuctionHouse.SendSearchQuery(item.itemKey, {
        {sortOrder = sortOrder, reverseSort = false},
    }, true)

end





