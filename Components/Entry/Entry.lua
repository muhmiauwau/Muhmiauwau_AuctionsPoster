local Entry = {}



function Entry:SetItem(entry)
    self.entry = entry

    self.Highlight:Hide()

    self.actionBackground:Hide()


	if self.entry.id then
		self:SetId(self.entry.id)
	else
		self:ShowSettings()
	end
	return self

end

function Entry:InitItem()

	self.PostButton:SetEnabled(false);


	if self.entry.buyoutAmount then 
		self.MoneyBuyout:Show()
		self.MoneyBuyout:SetValue(self.entry.buyoutAmount)
		self.PostButton:SetEnabled(self.entry.needAction and self.entry.enabled and (self.entry.buyoutAmount > self.entry.minPrice))
	else 
		self.MoneyBuyout:Hide()
	end


	self:SetNeedAction(self.entry.needAction)


	self:SetMinPrice()
	self:SetQuantity()
	self:SetAvailable()


	self:SetDuration()

	self.lastChecked:SetColor(1, 1, 1, 0.5)	
	self.lastChecked:SetValue(date("%d.%m.%y %H:%M:%S", self.entry.lastChecked ))


end


function Entry:SetNeedAction(state)
	self.entry.needAction =  state or false
	if self.entry.needAction  then 
		self.actionBackground:Show()
	else
		self.actionBackground:Hide()
	end
end


function Entry:SetId(id)
	--print("id", id)
	self.entry.id = id
	self.itemKey = C_AuctionHouse.MakeItemKey(self.entry.id)
	self.itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(self.itemKey);
	SetItemButtonTexture(self.ItemButton, self.itemKeyInfo.iconFileID);
	self.Name:SetText(AuctionHouseUtil.GetItemDisplayTextFromItemKey(self.itemKey, self.itemKeyInfo));



	if not self.entry.isCommodity then 
		local ILocation = self:getItemLocation()
		if ILocation then 
			self.entry.isCommodity = (C_AuctionHouse.GetItemCommodityStatus(ILocation) == 2 ) and true or false
		end
	end

	self:InitItem()
end

function Entry:SetQuantity()
	self.TextQty:SetValue(self.entry.qty)
end


function Entry:SetMinPrice()
	self.MoneyMin:SetValue(self.entry.minPrice)
end



function Entry:SetAvailable()
	local findinBag = function(itemID)
        for i = 0, (NUM_BAG_SLOTS + NUM_REAGENTBAG_SLOTS) do
            for z = 1, C_Container.GetContainerNumSlots(i) do
                if C_Container.GetContainerItemID(i, z) == itemID then
                    return i, z
                end
            end
        end

		return false
    end


	local bagId, slotId = findinBag(self.entry.id)

	if bagId == false then
		self.TextAvailable:SetValue(0)
		self.entry.enabled = false
	else
		local amount = C_AuctionHouse.GetAvailablePostCount(ItemLocation:CreateFromBagAndSlot(bagId, slotId))
		self.TextAvailable:SetValue(amount)
	end
	
   

end


function Entry:SetDuration()
	self.TextDuration:SetValue(AUCTION_DURATIONS[self.entry.duration])
end


function Entry:UpdateEnabled()
	
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


function Entry:OnEvent(event, itemKey)

	if event == "ITEM_SEARCH_RESULTS_UPDATED" or event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
		local itemID = itemKey

		if event == "ITEM_SEARCH_RESULTS_UPDATED" then
			itemID = itemKey.itemID
		end

		if self.entry.id == itemID then 
			self:UnregisterEvent(event)

			

			local priceKey = "buyoutAmount"
			if self.entry.isCommodity then 
				priceKey = "unitPrice"
			end


            local needUpdate = function(result)
				local match = true
				
				if #result.owners > 0 then 
					local _, realm =  UnitName("player")
					local formattedName = MUHAP:formatPlayerName(result.owners[1], realm )
					if result.owners[1] == "player" or AuctionsPosterDB.activeChars[formattedName] or AuctionsPosterDB.activeChars[result.owners[1]] then 
						match = false
					end
				else
					match = false
				end

				if self.entry.minPrice > result[priceKey] then 
					match = false
				end

                return match
            end

			local result = nil
			
			if self.entry.isCommodity then 
				result = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, 1)
			else 
				result = C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1)
			end
			

			if result then 
				self.entry.needAction = needUpdate(result)
				self.entry.buyoutAmount = result[priceKey]
			else
				self.entry.needAction = false
				self.entry.buyoutAmount = 0
			end

			--print("ok?")
			self.entry.lastChecked = time()


			self:InitItem()

			AuctionHouseFrame.MUHAP.ScrollFrame:UpdateList()

        end
	elseif event == "AUCTION_HOUSE_AUCTION_CREATED" then 
		
		if self.lastAuctionTimer then
			self.lastAuctionTimer:Cancel()
		end
		

		self.lastAuctionTimer = C_Timer.NewTimer(3, function() 
			print("all auctions created")
			self.PostButton:SetEnabled(false)

			MUHAP.List:reload()

			self:UnregisterEvent("AUCTION_HOUSE_AUCTION_CREATED")
		end)
	end
end



function Entry:runCheck()
    if not self.entry.enabled or not self.entry.id then 
        return 
    end

	if (self.entry.lastChecked + 5) > time() then 
		print("runCheck too fast", self.entry.id)
		return 
	end

	print("runCheck ", self.entry.id)

	if self.entry.isCommodity then 
		--print("COMMODITY")
		self:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
		C_AuctionHouse.SendSearchQuery(self.itemKey, {
			{sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false},
		}, true)
	else
		--print("item")
		self:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")

		C_AuctionHouse.SendSearchQuery(self.itemKey, {
			{sortOrder = Enum.AuctionHouseSortOrder.Buyout, reverseSort = false},
		}, true)
	end

end

function Entry:getItemLocation()

	local findinBag = function(itemID)
        for i = 0, (NUM_BAG_SLOTS + NUM_REAGENTBAG_SLOTS) do
            for z = 1, C_Container.GetContainerNumSlots(i) do
                if C_Container.GetContainerItemID(i, z) == itemID then
                    return i, z
                end
            end
        end
    end

    local bagId, slotId = findinBag(self.entry.id)
	--(self.entry.id, bagId, slotId )
	return ItemLocation:CreateFromBagAndSlot(bagId, slotId)

end


function Entry:PostItem()
	local ILocation = self:getItemLocation()
	local itemsAvaible = C_AuctionHouse.GetAvailablePostCount(ILocation)
	local qty = (itemsAvaible < self.entry.qty) and itemsAvaible or self.entry.qty

	
	self:SetNeedAction(false)
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