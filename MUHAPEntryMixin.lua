
AuctionHouseSellFrameAlignedControlMixin = {};

function AuctionHouseSellFrameAlignedControlMixin:OnLoad()
	self:SetLabel(self.labelText);
end

function AuctionHouseSellFrameAlignedControlMixin:SetLabel(text)
	self.Label:SetText(text or "");
	self.LabelTitle:SetText(text or "");
end

function AuctionHouseSellFrameAlignedControlMixin:SetSubtext(text)
	self.Subtext:SetText(text);

	local hasSubtext = text ~= nil;
	self.Label:SetShown(not hasSubtext);
	self.LabelTitle:SetShown(hasSubtext);
	self.Subtext:SetShown(hasSubtext);
end

function AuctionHouseSellFrameAlignedControlMixin:SetLabelColor(color)
	self.Label:SetTextColor(color:GetRGB());
	self.LabelTitle:SetTextColor(color:GetRGB());
end






AuctionHousePriceErrorFrameMixin = {};

function AuctionHousePriceErrorFrameMixin:OnEnter()
	if self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local wrap = true;
		GameTooltip_AddColoredLine(GameTooltip, self.tooltip, RED_FONT_COLOR, wrap);
		GameTooltip:Show();
	end
end

function AuctionHousePriceErrorFrameMixin:OnLeave()
	GameTooltip_Hide();
end

function AuctionHousePriceErrorFrameMixin:SetTooltip(tooltip)
	self.tooltip = tooltip;
end






MUHAPPriceInputFrameMixin = {};

function MUHAPPriceInputFrameMixin:OnLoad()
	AuctionHouseSellFrameAlignedControlMixin.OnLoad(self);
end

function MUHAPPriceInputFrameMixin:SetNextEditBox(nextEditBox)
	self.MoneyInputFrame:SetNextEditBox(nextEditBox);
end

function MUHAPPriceInputFrameMixin:Clear()
	self.MoneyInputFrame:Clear();
end

function MUHAPPriceInputFrameMixin:SetAmount(amount)
	if amount == 0 then
		self.MoneyInputFrame:Clear();
	else
		self.MoneyInputFrame:SetAmount(amount);
	end
end

function MUHAPPriceInputFrameMixin:GetAmount()
	return self.MoneyInputFrame:GetAmount();
end

function MUHAPPriceInputFrameMixin:SetOnValueChangedCallback(callback)
	return self.MoneyInputFrame:SetOnValueChangedCallback(callback);
end

function MUHAPPriceInputFrameMixin:SetErrorTooltip(tooltip)
	self.PriceError:SetTooltip(tooltip);
end

function MUHAPPriceInputFrameMixin:SetErrorShown(shown)
	self.PriceError:SetShown(shown);
end





AuctionHouseAlignedQuantityInputFrameMixin = {};

function AuctionHouseAlignedQuantityInputFrameMixin:GetQuantity()
	return self.InputBox:GetNumber();
end

function AuctionHouseAlignedQuantityInputFrameMixin:SetQuantity(quantity)
	self.InputBox:SetNumber(quantity);
end

function AuctionHouseAlignedQuantityInputFrameMixin:SetInputChangedCallback(callback)
	self.InputBox:SetInputChangedCallback(callback);
end

function AuctionHouseAlignedQuantityInputFrameMixin:Reset()
	self.InputBox:Reset();
end

function AuctionHouseAlignedQuantityInputFrameMixin:SetNextEditBox(nextEditBox)
	self.InputBox:SetNextEditBox(nextEditBox);
end







AuctionHouseSellFrameAlignedControlMixin = {};

function AuctionHouseSellFrameAlignedControlMixin:OnLoad()
	self:SetLabel(self.labelText);
end

function AuctionHouseSellFrameAlignedControlMixin:SetLabel(text)
	self.Label:SetText(text or "");
	self.LabelTitle:SetText(text or "");
end

function AuctionHouseSellFrameAlignedControlMixin:SetSubtext(text)
	self.Subtext:SetText(text);

	local hasSubtext = text ~= nil;
	self.Label:SetShown(not hasSubtext);
	self.LabelTitle:SetShown(hasSubtext);
	self.Subtext:SetShown(hasSubtext);
end

function AuctionHouseSellFrameAlignedControlMixin:SetLabelColor(color)
	self.Label:SetTextColor(color:GetRGB());
	self.LabelTitle:SetTextColor(color:GetRGB());
end





AuctionHouseDurationDropDownMixin = {};

function AuctionHouseDurationDropDownMixin:OnLoad()
	UIDropDownMenu_SetWidth(self, 80, 40);

	self.Text:SetFontObject(Number12Font);
end

function AuctionHouseDurationDropDownMixin:OnShow()
	UIDropDownMenu_Initialize(self, AuctionHouseDurationDropDownMixin.Initialize);

	if self.durationValue == nil then
		self:SetDuration(tonumber(GetCVar("auctionHouseDurationDropdown")));
	end
end



function AuctionHouseDurationDropDownMixin:Initialize()
	local function AuctionHouseDurationDropDownButton_OnClick(button)
		self:SetDuration(button.value);
		SetCVar("auctionHouseDurationDropdown", button.value);
	end

	for i, durationText in ipairs(AUCTION_DURATIONS) do
		local info = UIDropDownMenu_CreateInfo();
		info.fontObject = Number12Font;
		info.text = durationText;
		info.minWidth = 108;
		info.value = i;
		info.checked = nil;
		info.func = AuctionHouseDurationDropDownButton_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function AuctionHouseDurationDropDownMixin:SetDuration(durationValue)
	self.durationValue = durationValue;
	UIDropDownMenu_SetSelectedValue(self, durationValue);
	self:GetParent():OnDurationUpdated();
end

function AuctionHouseDurationDropDownMixin:GetDuration()
	return self.durationValue or tonumber(GetCVar("auctionHouseDurationDropdown"));
end




























MUHAPEntryMixin = {}

function MUHAPEntryMixin:SetItem(entry)
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

function MUHAPEntryMixin:InitItem()

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


function MUHAPEntryMixin:SetNeedAction(state)
	self.entry.needAction =  state or false
	if self.entry.needAction  then 
		self.actionBackground:Show()
	else
		self.actionBackground:Hide()
	end
end


function MUHAPEntryMixin:SetId(id)
	--print("id", id)
	self.entry.id = id
	self.itemKey = C_AuctionHouse.MakeItemKey(self.entry.id)
	self.itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(self.itemKey);
	SetItemButtonTexture(self.ItemButton, self.itemKeyInfo.iconFileID);
	self.Name:SetText(AuctionHouseUtil.GetItemDisplayTextFromItemKey(self.itemKey, self.itemKeyInfo));

	self:InitItem()
end

function MUHAPEntryMixin:SetQuantity()
	self.TextQty:SetValue(self.entry.qty)
end


function MUHAPEntryMixin:SetMinPrice()
	self.MoneyMin:SetValue(self.entry.minPrice)
end



function MUHAPEntryMixin:SetAvailable()
	local findinBag = function(itemID)
        for i = 0, NUM_BAG_SLOTS do
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
	else
		local amount = C_AuctionHouse.GetAvailablePostCount(ItemLocation:CreateFromBagAndSlot(bagId, slotId))
		self.TextAvailable:SetValue(amount)
	end
	
   

end


function MUHAPEntryMixin:SetDuration()
	self.TextDuration:SetValue(AUCTION_DURATIONS[self.entry.duration])
end


function MUHAPEntryMixin:UpdateEnabled()
	
end


function MUHAPEntryMixin:OnEnter()
	self.Highlight:Show()
end

function MUHAPEntryMixin:OnLeave()
	self.Highlight:Hide()
end


function MUHAPEntryMixin:OnLoad()
   -- print("OnLoad")
end


function MUHAPEntryMixin:OnEvent(event, itemKey)
    if event == "ITEM_SEARCH_RESULTS_UPDATED" then
        if self.entry.id == itemKey.itemID then 
			self:UnregisterEvent("ITEM_SEARCH_RESULTS_UPDATED")


            local needUpdate = function(result)
				local _, realm =  UnitName("player")
				local formattedName = MUHAP:formatPlayerName(result.owners[1], realm )
				local match = true
				if result.owners[1] == "player" or AuctionsPosterDB.activeChars[formattedName] or AuctionsPosterDB.activeChars[result.owners[1]] then 
					match = false
				end

                return match
            end

            local result = C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1)

			if result then 
				self.entry.needAction = needUpdate(result)
				self.entry.buyoutAmount = result.buyoutAmount
			else
				self.entry.needAction = false
				self.entry.buyoutAmount = 0
			end

			self.entry.lastChecked = time()


			self:InitItem()

			AuctionHouseFrame.MUHAPFrame:UpdateList()

        end
	elseif event == "AUCTION_HOUSE_AUCTION_CREATED" then 
		
		if self.lastAuctionTimer then
			self.lastAuctionTimer:Cancel()
		end
		

		self.lastAuctionTimer = C_Timer.NewTimer(3, function() 
			print("all auctions created")
			AuctionHouseFrame.MUHAPFrame:FilterList()
			AuctionHouseFrame.MUHAPFrame:UpdateList()

			self:UnregisterEvent("AUCTION_HOUSE_AUCTION_CREATED")
		end)
	end
end




function MUHAPEntryMixin:runCheck()
    if not self.entry.enabled or not self.entry.id then 
        return 
    end

	if (self.entry.lastChecked + 5) > time() then 
		print("runCheck too fast", self.entry.id)
		return 
	end

	print("runCheck ", self.entry.id)

	self:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")



	C_AuctionHouse.SendSearchQuery(self.itemKey, {
		{sortOrder = Enum.AuctionHouseSortOrder.Buyout, reverseSort = false},
	}, true)
end


function MUHAPEntryMixin:PostItem()

    local findinBag = function(itemID)
        for i = 0, NUM_BAG_SLOTS do
            for z = 1, C_Container.GetContainerNumSlots(i) do
                if C_Container.GetContainerItemID(i, z) == itemID then
                    return i, z
                end
            end
        end
    end

    local bagId, slotId = findinBag(self.entry.id)
	local ILocation = ItemLocation:CreateFromBagAndSlot(bagId, slotId)
	local itemsAvaible = C_AuctionHouse.GetAvailablePostCount(ILocation)
	local qty = (itemsAvaible < self.entry.qty) and itemsAvaible or self.entry.qty

	
	self:SetNeedAction(false)

	self:RegisterEvent("AUCTION_HOUSE_AUCTION_CREATED")

    C_AuctionHouse.PostItem(ILocation, self.entry.duration, qty, nil, self.entry.buyoutAmount)


	
end



function MUHAPEntryMixin:ShowSettings()
	self.Settings:Show()
end


function MUHAPEntryMixin:HideSettings()
	self.Settings:Hide()
end





MUHAPEntryPostButtonMixin = {};

function MUHAPEntryPostButtonMixin:OnClick()
	self:GetParent():PostItem();
	PlaySound(SOUNDKIT.LOOT_WINDOW_COIN_SOUND);
end


MUHAPEntryCreateButtonMixin = {};

function MUHAPEntryCreateButtonMixin:OnClick()
	self:GetParent():createNewItem();
	PlaySound(SOUNDKIT.LOOT_WINDOW_COIN_SOUND);
end


MUHAPEntryDeleteButtonMixin = {};

function MUHAPEntryDeleteButtonMixin:OnClick()
	self:GetParent():delete();
	PlaySound(SOUNDKIT.LOOT_WINDOW_COIN_SOUND);
end







MUHAPEntrySettingsButtonMixin = {}

function MUHAPEntrySettingsButtonMixin:open()
	self:GetParent():ShowSettings();
end

function MUHAPEntrySettingsButtonMixin:close()
	self:GetParent():HideSettings();
end


function MUHAPEntrySettingsButtonMixin:reload()
	self:GetParent():runCheck()
end



MUHAPEntrySettingsMixin = {}


function MUHAPEntrySettingsMixin:OnLoad()


	self.QuantityInput:SetInputChangedCallback(function()
		self.entry.qty = self.QuantityInput:GetQuantity();
		self:GetParent():SetQuantity()
	end);

	self.PriceInput:SetOnValueChangedCallback(function()
		--print(self.PriceInput:GetAmount())
		self.entry.minPrice = self.PriceInput:GetAmount();
		self:GetParent():SetMinPrice()
	end);

	--self.PriceInput:SetAmount(self.entry.minPrice)

end

function MUHAPEntrySettingsMixin:ToggleDeleteButton(state)
	if state then 
		self.DeleteButton:Hide()
	else 
		self.DeleteButton:Show()
	end

end

function MUHAPEntrySettingsMixin:OnShow()
	--print("show")
	self.entry = self:GetParent().entry
	self.itemKey = self:GetParent().itemKey
	self.itemKeyInfo = self:GetParent().itemKeyInfo


	if self.entry then 
		if self.entry.id then
			self.DurationDropDown:SetDuration(self.entry.duration)
		
			self.EnabledCheckbox:SetState(self.entry.enabled)
			self:ToggleDeleteButton(self.entry.enabled)
			SetItemButtonTexture(self.ItemDisplay.ItemButton, self.itemKeyInfo.iconFileID);
			self.CreateButton:Hide()
		else
			self.entry.duration = 1
			self.entry.minPrice = 100000
			self.entry.qty = 1
			self.EnabledCheckbox:Hide()
			self:ToggleDeleteButton(true)
			self.SettingsButton:Hide()
		end

		self.DurationDropDown:SetDuration(self.entry.duration)
		self.QuantityInput:SetQuantity(self.entry.qty)
		self.PriceInput:SetAmount(self.entry.minPrice)

		self.ItemDisplay:SetOnItemChangedCallback(function(itemLocation)
	
			if C_AuctionHouse.IsSellItemValid(itemLocation) == false or  AuctionHouseFrame.MUHAPFrame:checkIfExits(self.ItemDisplay:GetItemID()) then 
				C_Item.UnlockItem(itemLocation);
				self.ItemDisplay:Reset()
			end
		end)
	end


end

function MUHAPEntrySettingsMixin:createNewItem()
	local newId = self.ItemDisplay:GetItemID()
	if newId then 
		if not AuctionHouseFrame.MUHAPFrame:checkIfExits(newId) then 
			print("createNewItem")
			self.entry.id = newId
			self:Hide()
			AuctionHouseFrame.MUHAPFrame:AddItem(self.entry)
		end
	end
end


function MUHAPEntrySettingsMixin:delete()

	local id = self.entry.id
	if id then 
		if AuctionHouseFrame.MUHAPFrame:checkIfExits(id) then 
			AuctionHouseFrame.MUHAPFrame:DeleteItem(id)
		end
	end
end

function MUHAPEntrySettingsMixin:OnHide()
	--print("hide")
end

function MUHAPEntrySettingsMixin:HideSettings()
	self:Hide()
end



function MUHAPEntrySettingsMixin:OnDurationUpdated()
	if self.entry then 
		--print("OnDurationUpdated", self.DurationDropDown:GetDuration())

		self.entry.duration = self.DurationDropDown:GetDuration()
		self:GetParent():SetDuration()
	end
end

function MUHAPEntrySettingsMixin:UpdateEnabled(state)
	self.entry.enabled = state
	--self:ToggleDeleteButton(state)
	self:GetParent():UpdateEnabled()
end








MUHAPEntryTextMixin = {};

function MUHAPEntryTextMixin:OnLoad()
	self.value = value;
	if self.type == nil then
		error("type mising");
		return;
	end

	self.Key:SetText(self.type .. ":")

	self:UpdateType();
end

function MUHAPEntryTextMixin:SetType(type)
	self.type = type;
	self:UpdateType();
end

function MUHAPEntryTextMixin:UpdateType()
	--print(self.type)
end

function MUHAPEntryTextMixin:SetValue(value)
	self.value = value;

	self.Value:SetText(self.value);
end


function MUHAPEntryTextMixin:SetColor(r,g,b,a)
	self.Key:SetTextColor(r,g,b,a);
	self.Value:SetTextColor(r,g,b,a);
	if self.Money then 
		self.Money:SetTextColor(r,g,b,a);
	end
end



MUHAPEntryMoneyMixin = CreateFromMixins(MUHAPEntryTextMixin);

function MUHAPEntryMoneyMixin:SetValue(value)
	self.value = value;

	self.Money:SetAmount(self.value);
end





MUHAPDurationDropDownMixin = {};

function MUHAPDurationDropDownMixin:OnDurationUpdated()
	self:GetParent():OnDurationUpdated();
end

function MUHAPDurationDropDownMixin:GetDuration()
	return self.DropDown:GetDuration();
end


function MUHAPDurationDropDownMixin:SetDuration(duration)
	return self.DropDown:SetDuration(duration);
end


MUHAPCheckButtonMixin = {};

function MUHAPCheckButtonMixin:OnClick()
	self:GetParent():UpdateState(self:GetChecked())
end


MUHAPEnabledMixin = {};


function MUHAPEnabledMixin:UpdateState(state)
	self:GetParent():UpdateEnabled(state)
end

function MUHAPEnabledMixin:SetState(state)

	self.CheckButton:SetChecked(state);
	--print("UpdateState", state)
end









MUHAPItemDisplayMixin = {};

function MUHAPItemDisplayMixin:OnLoad()
	AuctionHouseInteractableItemDisplayMixin.OnLoad(self);

	self.NineSlice:Hide();
end





MUHAPFooterMixin = {};

function MUHAPFooterMixin:OnLoad()

end


MUHAPFooterCheckButtonMixin = {};
function MUHAPFooterCheckButtonMixin:OnClick()
	AuctionHouseFrame.MUHAPFrame:triggerAllChecks()
end



MUHAPFooterPostButtonMixin = {};
function MUHAPFooterPostButtonMixin:OnClick()
	AuctionHouseFrame.MUHAPFrame:triggerAllPostAuctions()
end



