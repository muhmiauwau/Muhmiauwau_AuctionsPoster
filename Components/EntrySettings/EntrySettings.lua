
















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
	end


end


function MUHAPEntrySettingsMixin:delete()

	local id = self.entry.id
	if id then 
		if AuctionHouseFrame.MUHAP.ScrollFrame:checkIfExits(id) then 
			AuctionHouseFrame.MUHAP.ScrollFrame:DeleteItem(id)
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











