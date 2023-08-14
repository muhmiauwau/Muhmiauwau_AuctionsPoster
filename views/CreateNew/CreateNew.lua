local CreateNew = {}

function CreateNew:OnLoad()
	self.itemLocation = nil
	self.id = nil
end

function CreateNew:CreateNew()
	if self.id then 
		if not AuctionHouseFrame.MUHAP.ScrollFrame:checkIfExits(self.id) then 
			local entry = {
				id = self.id,
				minPrice = 0,
				lastChecked = time(),
				qty = 1,
				enabled = false,
				needAction = false,
				duration = 1
			}

			AuctionHouseFrame.MUHAP.ScrollFrame:AddItem(entry)
			AuctionHouseFrame.MUHAP.Tabs:SetTab(2)
			self:Reset()
		end
	end
end

function CreateNew:SetId(id)
	self.id = id
	local state = (self.id ~= nil) 
	self.CreateButton:SetEnabled(state);
end


function CreateNew:SetItemLocation(itemLocation)
	self.itemLocation = itemLocation
end

function CreateNew:Reset()
	self:SetId(nil)
	self.ItemDisplay:Reset()
	C_Item.UnlockItem(self.itemLocation);
	self.itemLocation = nil
end


local ItemDisplay = {}

function ItemDisplay:OnLoad()
	AuctionHouseInteractableItemDisplayMixin.OnLoad(self);

	self.NineSlice:Hide();

	self:SetOnItemChangedCallback(function(itemLocation)
		self:GetParent():SetItemLocation(itemLocation)
		local id = self:GetItemID()
		if C_AuctionHouse.IsSellItemValid(itemLocation) == false or AuctionHouseFrame.MUHAP.ScrollFrame:checkIfExits(id) then 
			self:Reset()
			C_Item.UnlockItem(itemLocation);
		else
			self:GetParent():SetId(id)
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