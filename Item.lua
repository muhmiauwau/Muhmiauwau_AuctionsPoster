local MUHAP = LibStub("AceAddon-3.0"):GetAddon("MUHAP")

local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()







MUHAP.Item = {}


function MUHAP.Item:exist(id)
	return self:get(id) and true or false
end


function MUHAP.Item:get(id)
    return _.find(MUHAP.items, function(v)
        return v.id == id
    end)
end


function MUHAP.Item:addMissingInfo(entry)
 
    if entry.id then  -- fill in missings informations
        local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
        itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
        expacID, setID, isCraftingReagent = GetItemInfo(entry.id)


       
        function getItemLocation(id)

            local findinBag = function(itemID)
                for i = 0, (NUM_BAG_SLOTS + NUM_REAGENTBAG_SLOTS) do
                    for z = 1, C_Container.GetContainerNumSlots(i) do
                        if C_Container.GetContainerItemID(i, z) == itemID then
                            return i, z
                        end
                    end
                end
            end
        
            local bagId, slotId = findinBag(id)
            --(self.entry.id, bagId, slotId )
            return ItemLocation:CreateFromBagAndSlot(bagId, slotId)
        
        end


        if not entry.isCommodity then 
            local ILocation = getItemLocation(entry.id)
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
    if self:exist(entry.id) then return end
    entry = self:addMissingInfo(entry)
    MUHAP.items[#MUHAP.items + 1] = entry
    MUHAP.Tabs:SetTab(2, true)
end


function MUHAP.Item:delete(id)
	if not self:exist(id) then return end

    _.remove(MUHAP.items, function(value)
        return value.id == id
    end)

	MUHAP.List:reload()
end



function MUHAP.Item:getItemLocation(itemID)
    for containerIndex = Enum.BagIndex.Backpack, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slotIndex = 1, C_Container.GetContainerNumSlots(containerIndex) do
            if C_Container.GetContainerItemID(containerIndex, slotIndex) == itemID then
                return ItemLocation:CreateFromBagAndSlot(containerIndex, slotIndex)
            end
        end
    end
    return false;
end






