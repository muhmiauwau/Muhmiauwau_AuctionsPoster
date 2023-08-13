AuctionHouseSystemMixin = {};

function AuctionHouseSystemMixin:GetAuctionHouseFrame()
	return self:GetParent();
end




AuctionHouseCategoriesListMixin = CreateFromMixins(AuctionHouseSystemMixin);

function AuctionHouseCategoriesListMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("AuctionCategoryButtonTemplate", function(button, elementData)
		AuctionHouseFilterButton_SetUp(button, elementData);
		button:SetScript("OnClick", function(button, buttonName)
			self:OnFilterClicked(button, buttonName);
		end);
	end);
	local leftPad = 3;
	local spacing = 0;
	view:SetPadding(0,0,leftPad,0,spacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function AuctionHouseCategoriesListMixin:OnFilterClicked(button, buttonName)
	local selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex = self:GetSelectedCategory();
	if ( button.type == "category" ) then
		local wasToken = AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", selectedCategoryIndex);
		if ( selectedCategoryIndex == button.categoryIndex ) then
			selectedCategoryIndex = nil;
		else
			selectedCategoryIndex = button.categoryIndex;
		end
		selectedSubCategoryIndex = nil;
		selectedSubSubCategoryIndex = nil;
	elseif ( button.type == "subCategory" ) then
		if ( selectedSubCategoryIndex == button.subCategoryIndex ) then
			selectedSubCategoryIndex = nil;
			selectedSubSubCategoryIndex = nil;
		else
			selectedSubCategoryIndex = button.subCategoryIndex;
			selectedSubSubCategoryIndex = nil;
		end
	elseif ( button.type == "subSubCategory" ) then
		if ( selectedSubSubCategoryIndex == button.subSubCategoryIndex ) then
			selectedSubSubCategoryIndex = nil;
		else
			selectedSubSubCategoryIndex = button.subSubCategoryIndex;
		end
	end

	self:SetSelectedCategory(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex);
	AuctionFrameFilters_Update(self, true);
end

function AuctionHouseCategoriesListMixin:OnShow()
	AuctionFrameFilters_Update(self);
end

function AuctionHouseCategoriesListMixin:IsWoWTokenCategorySelected()
	local categoryInfo = AuctionHouseCategory_FindDeepest(self.selectedCategoryIndex, self.selectedSubCategoryIndex, self.selectedSubSubCategoryIndex);
	return categoryInfo and categoryInfo:HasFlag("WOW_TOKEN_FLAG");
end

function AuctionHouseCategoriesListMixin:SetSelectedCategory(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)
	self.selectedCategoryIndex = selectedCategoryIndex;
	self.selectedSubCategoryIndex = selectedSubCategoryIndex;
	self.selectedSubSubCategoryIndex = selectedSubSubCategoryIndex;

	self:GetAuctionHouseFrame():TriggerEvent(AuctionHouseFrameMixin.Event.CategorySelected, selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex);
	
	local displayMode = self:GetAuctionHouseFrame():GetDisplayMode();
	if self:IsWoWTokenCategorySelected() and displayMode ~= AuctionHouseFrameDisplayMode.WoWTokenBuy then
		self:GetAuctionHouseFrame():SetDisplayMode(AuctionHouseFrameDisplayMode.WoWTokenBuy);
	elseif displayMode ~= AuctionHouseFrameDisplayMode.Buy and displayMode ~= AuctionHouseFrameDisplayMode.ItemBuy and displayMode ~= AuctionHouseFrameDisplayMode.CommoditiesBuy then
		self:GetAuctionHouseFrame():SetDisplayMode(AuctionHouseFrameDisplayMode.Buy);
	end

	AuctionFrameFilters_Update(self);
end

function AuctionHouseCategoriesListMixin:GetSelectedCategory()
	return self.selectedCategoryIndex, self.selectedSubCategoryIndex, self.selectedSubSubCategoryIndex;
end

function AuctionHouseCategoriesListMixin:GetCategoryData()
	local selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex = self:GetSelectedCategory();
	if selectedCategoryIndex and selectedSubCategoryIndex and selectedSubSubCategoryIndex then
		return AuctionCategories[selectedCategoryIndex].subCategories[selectedSubCategoryIndex].subCategories[selectedSubSubCategoryIndex];
	elseif selectedCategoryIndex and selectedSubCategoryIndex then
		return AuctionCategories[selectedCategoryIndex].subCategories[selectedSubCategoryIndex];
	elseif selectedCategoryIndex then
		return AuctionCategories[selectedCategoryIndex];
	end
end

function AuctionHouseCategoriesListMixin:GetCategoryFilterData()
	local categoryData = self:GetCategoryData();
	if categoryData == nil then
		return nil, nil;
	end

	return categoryData.filters, categoryData.implicitFilter;
end











function tableFindAll(table, value, key, key2)
	local ntable = {}

	for k, entry in ipairs(table) do 
		local item = nil
		if entry[key] then 
			if key2 and entry[key][key2] then 
				item = entry[key][key2]
			else 
				item = entry[key]
			end
		end

		if item and item == value then 
			ntable[#ntable + 1] = value
		end
	end

	return ntable
end









local EntryInterface = {
    id =  Settings.VarType.Number,
    Category = Settings.VarType.Number,
    SubCategory = Settings.VarType.Number,
    SubSubCategory = Settings.VarType.Number,
    minPrice = Settings.VarType.Number,
    qty = Settings.VarType.Number,
    lastChecked = "date",
    enabled = Settings.VarType.Boolean,
    needAction = Settings.VarType.Boolean
}



MUHAPScrollFrameMixin = {}


function MUHAPScrollFrameMixin:OnLoad()

	self.showDisabled = false

	self.ticker = nil

	self.selectedCategoryIndex = nil;
	self.selectedSubCategoryIndex = nil;
	self.selectedSubSubCategoryIndex = nil;

	self.items = AuctionsPosterCharDB.items
	self.filterdItems = {}


    self.list = self.scrollFrame.ScrollBox
	self.list:SetWidth(self.scrollFrame:GetWidth() -  8)
	self.list:SetHeight(1) 

	self:generateListFrames()

	for _, entry in pairs(self.items) do 
		self:addEntry(entry)
	end
end



function MUHAPScrollFrameMixin:AddItem(entry)

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

	
	self.items[#self.items + 1] = entry
	self:addEntry(entry)

	self:FilterList()
	self:UpdateList()
	

end

function MUHAPScrollFrameMixin:DeleteItem(id)
	for i, entry in ipairs(self.items) do 
		if entry.id == id then 
			tremove(self.items, i)
		end
	end

	self:FilterList()
    self:UpdateList()
end

function MUHAPScrollFrameMixin:OnCategorySelected(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)
    self.selectedCategoryIndex = selectedCategoryIndex;
	self.selectedSubCategoryIndex = selectedSubCategoryIndex;
	self.selectedSubSubCategoryIndex = selectedSubSubCategoryIndex;

	print(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)

	self:FilterList()
    self:UpdateList()
end

function MUHAPScrollFrameMixin:FilterList()
	--print("FilterList", self.selectedCategoryIndex, self.selectedSubCategoryIndex, self.selectedSubSubCategoryIndex)
	local filterdItems = {}

	for _, entry in pairs(self.items) do 

		local item = nil

		local Category = entry.Category
		local SubCategory = entry.SubCategory
		local SubSubCategory = entry.SubSubCategory

		if self.selectedCategoryIndex == nil  then
			item = entry
		elseif self.selectedSubCategoryIndex == nil then
			if self.selectedCategoryIndex == Category then 
				item = entry
			end
		elseif self.selectedSubSubCategoryIndex == nil then
			if self.selectedCategoryIndex == Category and self.selectedSubCategoryIndex == SubCategory then 
				item= entry
			end
		else
			if self.selectedCategoryIndex == Category  and self.selectedSubCategoryIndex == SubCategory and self.selectedSubSubCategoryIndex == SubSubCategory then 
				item = entry
			end
		end

		if item ~= nil then
			--print("in filter", self.showDisabled, item.enabled, item.id)
			if not self.showDisabled and not item.enabled then 
				item = nil
			elseif self.showDisabled and item.enabled then  
				item = nil
			end

			item = self:checkStatus(item)
			filterdItems[#filterdItems + 1] = item
		end
	end


	self.filterdItems = filterdItems
end



function MUHAPScrollFrameMixin:checkStatus(entry)
	if not entry then return end
	if not entry.enabled then return entry end

	entry.status = entry.status or {auction = false, check = false}

	entry.status.check = (entry.lastChecked + 60) < time()
	entry.status.auction = entry.needAction

	return entry
end

function MUHAPScrollFrameMixin:SortList()

	table.sort(self.filterdItems, function(a,b)

		return
			a.needAction and not b.needAction or
            (a.needAction == b.needAction and a.lastChecked > b.lastChecked)
	end)

end

function MUHAPScrollFrameMixin:OnShow()
	if self.ticker then
		self.ticker:Cancel()
	end

	self.ticker = C_Timer.NewTimer(60, function ()
		self:triggerAllChecks()
	end)
end


function MUHAPScrollFrameMixin:OnEvent(event, ...)
end

function MUHAPScrollFrameMixin:OnHide()

	if self.ticker then
		self.ticker:Cancel()
	end
end


function MUHAPScrollFrameMixin:checkIfExits(id)
	local match = false
	for _, entry in pairs(self.items) do 
		if entry.id == id then 
			match = true
		end 
	end 
	return match
end

function MUHAPScrollFrameMixin:UpdateList()

	self.statusAuctions = tableFindAll(self.filterdItems, true, "status", "auction")
	self.statusCheck = tableFindAll(self.filterdItems, true, "status", "check")

	self:GetParent().MUHAPFooter.TextAuctions:SetValue(#self.statusAuctions)
	self:GetParent().MUHAPFooter.TextCheck:SetValue(#self.statusCheck)

	if #self.statusCheck == 0 and #self.statusAuctions > 0 then
		self:GetParent().MUHAPFooter.PostButton:SetEnabled(true);
		self:GetParent().MUHAPFooter.PostButton:Show()
	else
		self:GetParent().MUHAPFooter.PostButton:Hide()
	end


	self:ResetList()
	self:SortList()

	for i, entry in ipairs(self.filterdItems) do 
		local frame = _G["MUHAPEntryFrame" .. entry.id]
		local parent = _G["MUHAPScrollListItems" .. i]
		frame:SetParent(parent)
		frame:SetAllPoints(parent)
		parent:Show()
	end

end


function MUHAPScrollFrameMixin:ResetList()

	local children = { self.list:GetChildren() }
	local parent = _G["MUHAPScrollListItemsHolder"]
	for i , Frame in pairs(children) do 
		local child = Frame:GetChildren()
		Frame:Hide()

		if child then 
			child:SetParent(parent)
			child:SetAllPoints(parent)

		end
	end

	local frame = _G["MUHAPEntryFramenil"]
	local parent = _G["MUHAPScrollListItems0"]
	frame:SetParent(parent)
	frame:SetAllPoints(parent)
	parent:Show()
	
end



function MUHAPScrollFrameMixin:generateListFrames()

	local amount = #self.items + 20
    local height = 100

	local holder = CreateFrame("Frame", "MUHAPScrollListItemsHolder", self.list)
	holder:SetPoint("TOPLEFT", 0, 0)
	holder:SetPoint("TOPRIGHT", 0, 0)
	holder:SetHeight(100)
	holder:Hide()

	

	for i = 0, amount, 1 do 
		local pos = i* height * -1
		local Frame = CreateFrame("Frame", "MUHAPScrollListItems" .. i, self.list)
		Frame:SetPoint("TOPLEFT", 0, pos)
		Frame:SetPoint("TOPRIGHT", 0, pos)
		Frame:SetHeight(height)
		Frame:Hide()
	end


	self:addEntry({
		id = nil,
		Category = nil,
		SubCategory = nil,
		SubSubCategory = nil,
		minPrice = 0,
		lastChecked = time(),
		qty = 1,
		enabled = true,
		needAction = false,
		duration = 1
	})



end



function MUHAPScrollFrameMixin:addEntry(entry)
	local height = 100
	local frameName = "MUHAPEntryFramenil"
	if entry.id then
		frameName = "MUHAPEntryFrame" .. entry.id
	end
	--print(" entry.id", entry.id, frameName)
	local Item = CreateFrame("Frame", frameName, MUHAPScrollListItemsHolder, "MUHAPEntryTemplate")
    Item:SetPoint("TOPLEFT", 0, 0)
    Item:SetPoint("TOPRIGHT", 0, 0)
    Item:SetHeight(height) 

	Item:SetItem(entry)

    return Item
end


function MUHAPScrollFrameMixin:OnEvent(event, ...)
   -- print(event)
end


function MUHAPScrollFrameMixin:triggerAllChecks()
	--print("triggerAllChecks")


	for i, entry in ipairs(self.filterdItems) do 
		local frame = _G["MUHAPEntryFrame" .. entry.id]
		frame:runCheck()
	end

	C_Timer.After(3, function() 
		self:FilterList()
		self:UpdateList()
	end)

 end

 function MUHAPScrollFrameMixin:triggerAllPostAuctions()
--	print("triggerAllPostAuctions")
	
	if #self.filterdItems > 0 then 

		local entry = self.filterdItems[1]

		local frame = _G["MUHAPEntryFrame" .. entry.id]
		frame:PostItem()

		self:GetParent().MUHAPFooter.PostButton:SetEnabled(false);
		entry.status.auction = false
	end


 end

 







AuctionHouseMUHAPCategoriesListMixin = CreateFromMixins(AuctionHouseCategoriesListMixin);


function AuctionHouseMUHAPCategoriesListMixin:SetSelectedCategory(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)
    self.selectedCategoryIndex = selectedCategoryIndex;
	self.selectedSubCategoryIndex = selectedSubCategoryIndex;
	self.selectedSubSubCategoryIndex = selectedSubSubCategoryIndex;
    AuctionHouseFrame.MUHAPFrame:OnCategorySelected(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)
	AuctionFrameFilters_Update(self);
end





MUHAPTabsMixin = {};



function MUHAPTabsMixin:GetTab()
	return PanelTemplates_GetSelectedTab(self);
end

function MUHAPTabsMixin:SetTab(tabID)
	if self:GetTab() == tabID then
		return;
	end
	PanelTemplates_SetTab(self, tabID);

	local ScrollFrame = self:GetParent().MUHAPFrame

	ScrollFrame.showDisabled = (tabID == 2) and true or false

	ScrollFrame:FilterList()
	ScrollFrame:UpdateList()

end

function MUHAPTabsMixin:OnLoad()
	PanelTemplates_SetNumTabs(self, 2);
	self:SetTab(1);


end