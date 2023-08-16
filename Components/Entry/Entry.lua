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
		self.entry.enabled = false
	else
		local amount = C_AuctionHouse.GetAvailablePostCount(ILocation)
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
		
		if 
		(
			event == "ITEM_SEARCH_RESULTS_UPDATED"
			and
			self.entry.itemKey.itemID == itemKey.itemID
			and 
			self.entry.itemKey.itemLevel == itemKey.itemLevel
		)
		or
		(
			event == "COMMODITY_SEARCH_RESULTS_UPDATED"
			and
			self.entry.itemKey.itemID == itemKey
		)
		then 
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
				result = C_AuctionHouse.GetCommoditySearchResultInfo(self.entry.itemKey.itemID, 1)
			else 
				result = C_AuctionHouse.GetItemSearchResultInfo(self.entry.itemKey, 1)
			end


			if result then 
				self:SetNeedAction(needUpdate(result))
				self:SetBuyoutAmount(result[priceKey])
			else
				self:SetNeedAction(false)
				self:SetBuyoutAmount(0)
			end


			self.entry.lastChecked = time()

			print("check end", self.entry.itemKey.itemID)
			--MUHAP.List:update()

        end
	elseif event == "AUCTION_HOUSE_AUCTION_CREATED" then 
		
		if self.lastAuctionTimer then
			self.lastAuctionTimer:Cancel()
		end

		self:SetNeedAction(false)
		

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

	print("runCheck ", self.entry.id )

	if self.entry.isCommodity then 
		self:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
		C_AuctionHouse.SendSearchQuery(self.entry.itemKey, {
			{sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false},
		}, true)
	else
		self:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")

		C_AuctionHouse.SendSearchQuery(self.entry.itemKey, {
			{sortOrder = Enum.AuctionHouseSortOrder.Buyout, reverseSort = false},
		}, true)
	end

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