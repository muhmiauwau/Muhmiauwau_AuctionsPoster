local Entry = {}



function Entry:Init(entry)
	if not entry or  not entry.id then return end
    self.entry = entry


	if self.entry.itemKey then 
		self.itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(self.entry.itemKey);
		SetItemButtonTexture(self.ItemButton, self.itemKeyInfo.iconFileID);
		self.Name:SetText(AuctionHouseUtil.GetItemDisplayTextFromItemKey(self.entry.itemKey, self.itemKeyInfo));
	end

	self:SetBuyoutAmount(self.entry.buyoutAmount)
	self:SetNeedAction(self.entry.needAction)


	self:SetMinPrice()
	self:SetQuantity()
	self:SetAvailable()

	self:SetEnabled(self.entry.enabled)


	self:SetDuration()

	self.lastChecked:SetColor(1, 1, 1, 0.5)
	self.lastChecked:SetValue(date("%d.%m.%y %H:%M:%S", self.entry.lastChecked ))

	return self
end



function Entry:SetBuyoutAmount(buyoutAmount)
	self.entry.buyoutAmount = buyoutAmount
	if self.entry.buyoutAmount then 
		self.MoneyBuyout:Show()
		self.MoneyBuyout:SetValue(self.entry.buyoutAmount)
	else 
		self.MoneyBuyout:Hide()
	end
end



function Entry:SetNeedAction(state)
	self.entry.needAction =  state or false
	if self.entry.needAction then 
		self.actionBackground:Show()
		if self.entry.buyoutAmount and self.entry.minPrice then 
			self.PostButton:SetEnabled(self.entry.needAction and self.entry.enabled and (self.entry.buyoutAmount > self.entry.minPrice))
		end
	else
		self.actionBackground:Hide()
		self.PostButton:SetEnabled(false);
	end
end

function Entry:SetQuantity()
	self.TextQty:SetValue(self.entry.qty)
end


function Entry:SetMinPrice()
	self.MoneyMin:SetValue(self.entry.minPrice)
end



function Entry:SetAvailable()
	local ILocation = MUHAP.Item:getItemLocation(self.entry.id)

	if not ILocation then
		self.TextAvailable:SetValue(0)
		self:SetEnabled(false)
	else
		local amount = C_AuctionHouse.GetAvailablePostCount(ILocation)
		self.TextAvailable:SetValue(amount)
	end
end


function Entry:SetDuration()
	self.TextDuration:SetValue(AUCTION_DURATIONS[self.entry.duration])
end


function Entry:SetEnabled(state)
	self.entry.enabled = state

	if state then
		self.ReloadButton:Show()
	else 
		self.ReloadButton:Hide()
	end
end


function Entry:OnEnter()
	self.Highlight:Show()
end

function Entry:OnLeave()
	self.Highlight:Hide()
end


function Entry:OnLoad()
   -- print("OnLoad")
end


function Entry:runCheck()
	MUHAP.Queue:add({
		type = "check",
		itemKey = self.entry.itemKey
	})
end


function Entry:PostItem()
	local ILocation = MUHAP.Item:getItemLocation(self.entry.id)
	local itemsAvaible = C_AuctionHouse.GetAvailablePostCount(ILocation)
	local qty = (itemsAvaible < self.entry.qty) and itemsAvaible or self.entry.qty

	
	
	self:RegisterEvent("AUCTION_HOUSE_AUCTION_CREATED")

	if self.entry.isCommodity then 
		C_AuctionHouse.PostCommodity(ILocation, self.entry.duration, qty, self.entry.buyoutAmount)
	else 
		C_AuctionHouse.PostItem(ILocation, self.entry.duration, qty, nil, self.entry.buyoutAmount)
	end
end



function Entry:OpenSettings()

	local settingsFrame = _G["MUHAPEntrySettings"]
	if settingsFrame then 
		settingsFrame:Hide()
        settingsFrame:SetParent(self)
		settingsFrame:SetAllPoints(self)
		settingsFrame:SetFrameLevel(500)
		settingsFrame:Show()
    end
end

function Entry:CloseSettings()

	local parent =  _G["MUHAPScrollListItemsHolder"]
	local settingsFrame = _G["MUHAPEntrySettings"]
	if settingsFrame then 
        settingsFrame:SetParent(parent)
		settingsFrame:SetAllPoints(parent)
		settingsFrame:Hide()
    end
end


local EntryClick = {}

function EntryClick:clickSettings() -- bind SettingsButton button
	self:GetParent():OpenSettings()
end

function EntryClick:clickReload() -- bind ReloadButton button
	self:GetParent():runCheck()
end

function EntryClick:clickPost() -- bind PostButton button
	self:GetParent():PostItem();
end







MUHAPEntryMixin = Entry
MUHAPEntryMixinClick = EntryClick