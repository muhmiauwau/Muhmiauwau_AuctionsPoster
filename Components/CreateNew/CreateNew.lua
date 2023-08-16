local CreateNew = {}

function CreateNew:OnLoad()
	self.itemLocation = nil
	self.id = nil
end



function CreateNew:CreateNew()
	if self.itemLocation then 
		local id = C_Item.GetItemID(self.itemLocation)
		local itemLevel = C_Item.GetCurrentItemLevel(self.itemLocation)

		if not MUHAP.Item:exist(id, itemLevel) then 
			local entry = {
				id = id,
				itemKey = C_AuctionHouse.MakeItemKey(id, itemLevel),
				minPrice = 0,
				lastChecked = time(),
				qty = 1,
				enabled = false,
				needAction = false,
				duration = 1,
				isCommodity =  (C_AuctionHouse.GetItemCommodityStatus(self.itemLocation) == 2 ) and true or false
			}


			MUHAP.Item:add(entry)
			self:Reset()
		end
	end
end


function CreateNew:SetItemLocation(itemLocation)
	self.itemLocation = itemLocation
	local state = (itemLocation ~= nil) 
	self.CreateButton:SetEnabled(state);
end

function CreateNew:Reset()
	--self:SetId(nil)
	self.ItemDisplay:Reset()
	C_Item.UnlockItem(self.itemLocation);
	self.itemLocation = nil
end


local ItemDisplay = {}

function ItemDisplay:OnLoad()
	AuctionHouseInteractableItemDisplayMixin.OnLoad(self);

	self.NineSlice:Hide();
	self:SetOnItemChangedCallback(function(itemLocation)
		local id = self:GetItemID()
		local itemLevel = C_Item.GetCurrentItemLevel(itemLocation)
		if C_AuctionHouse.IsSellItemValid(itemLocation) == false or MUHAP.Item:exist(id, itemLevel) then 
			self:Reset()
			C_Item.UnlockItem(itemLocation);
		else
			self:GetParent():SetItemLocation(itemLocation)
		end
	end)
end


local CreateButton = {}

function CreateButton:OnLoad()
	self:SetEnabled(false);
end

function CreateButton:OnClick()
    self.holder = _G["MUHAPScrollListItemsHolder"]

	self:GetParent():CreateNew()
end




-- bindings
MUHAPCreateNewMixin = CreateNew
MUHAPCreateNewItemDisplayMixin = ItemDisplay
MUHAPCreateNewButtonMixin = CreateButton