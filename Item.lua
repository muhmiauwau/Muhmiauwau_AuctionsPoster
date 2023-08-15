local MUHAP = LibStub("AceAddon-3.0"):GetAddon("MUHAP")

local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()







MUHAP.Item = {}


function MUHAP.Item:exist(id)
	return self:get(id) and true or false
end


function MUHAP.Item:get(id)
    local find = _.findIndex(MUHAP.items, function(v)
        return v.id == id
    end)

    return MUHAP.items[find]
end


function MUHAP.Item:add(entry)

    if not entry.Category and entry.id then  -- fill in missings informations
        local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
        itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
        expacID, setID, isCraftingReagent = GetItemInfo(entry.id)


        if classID == 3 then --gems
            classID = 4
        elseif  classID == 1 then --container
            classID = 3 
        end

        entry.Category = classID
        entry.SubCategory = subclassID
        entry.SubSubCategory = nil
    end

    MUHAP.items[#MUHAP.items + 1] = entry
    MUHAP.Entry:add(entry)
    MUHAP.Tabs:SetTab(2, true)

end


function MUHAP.Item:delete(id)
    print("MUHAP.Item:delete", self:exist(id) )
	if not self:exist(id) then return end
    print("MUHAP.Item:delete")

    _.remove(MUHAP.items, function(value)
        return value.id == id
    end)

	MUHAP.ScrollFrame:FilterList()
    MUHAP.ScrollFrame:UpdateList()
end


