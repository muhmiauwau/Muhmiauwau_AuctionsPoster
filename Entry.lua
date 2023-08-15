local MUHAP = LibStub("AceAddon-3.0"):GetAddon("MUHAP")

MUHAP.Entry = {}



function MUHAP.Entry:get(id)

end


function MUHAP.Entry:add(entry)
	if not entry.id then return end

	local height = 100
	local frameName = "MUHAPEntryFrame" .. entry.id

	local Item = CreateFrame("Frame", frameName, MUHAPScrollListItemsHolder, "MUHAPEntryTemplate")
    Item:SetPoint("TOPLEFT", 0, 0)
    Item:SetPoint("TOPRIGHT", 0, 0)
    Item:SetHeight(height) 

	Item:SetItem(entry)

    return Item
end





