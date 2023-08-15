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


