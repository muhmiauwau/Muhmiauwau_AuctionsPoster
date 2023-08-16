local MUHAP = LibStub("AceAddon-3.0"):GetAddon("MUHAP")

local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()







MUHAP.Item = {}


function MUHAP.Item:exist(id, level)
	return self:get(id, level) and true or false
end


function MUHAP.Item:get(id, level)
    local find = _.find(MUHAP.items, function(v)
        if level then 
            return v.id == id and v.itemKey.itemLevel == level
        else 
            return v.id == id 
        end 
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
    if self:exist(entry.itemKey.itemID, entry.itemKey.itemLevel) then return end
    entry = self:addMissingInfo(entry)
    MUHAP.items[#MUHAP.items + 1] = entry
    MUHAP.Tabs:SetTab(2, true)
end


function MUHAP.Item:delete(itemKey)
	if not self:exist(itemKey.itemID, itemKey.itemLevel) then return end

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






