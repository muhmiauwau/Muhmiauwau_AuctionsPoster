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

	self.selectedCategoryIndex = nil;
	self.selectedSubCategoryIndex = nil;
	self.selectedSubSubCategoryIndex = nil;

	self.items = AuctionsPosterCharDB.items
	self.filterdItems = {}

	self.entries = {}
	self.frames = {}


	

    --self:RegisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
	-- Create the scrolling parent frame and size it to fit inside the texture
    local scrollFrame = CreateFrame("ScrollFrame", nil, self, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", 0, 0)
    scrollFrame.Texture = scrollFrame:CreateTexture()
    scrollFrame.Texture:SetAllPoints()
    scrollFrame.Texture:SetAtlas("auctionhouse-background-auctions", true);


    -- Create the scrolling child frame, set its width to fit, and give it an arbitrary minimum height (such as 1)
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(1) 


    self.list = scrollChild


	self:generateListFrames()

	for _, entry in pairs(self.items) do 
		self:addEntry(entry)
	end
end

function MUHAPScrollFrameMixin:AddItem(entry)

	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
    itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
    expacID, setID, isCraftingReagent = GetItemInfo(entry.id)

	entry.Category = classID
    entry.SubCategory = subclassID
    entry.SubSubCategory = nil

	DevTools_Dump(entry)

	self.items[#self.items + 1] = entry

	self:FilterList()
	self:UpdateList()
	

end

function MUHAPScrollFrameMixin:OnCategorySelected(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)
    self.selectedCategoryIndex = selectedCategoryIndex;
	self.selectedSubCategoryIndex = selectedSubCategoryIndex;
	self.selectedSubSubCategoryIndex = selectedSubSubCategoryIndex;

	self:FilterList()
    self:UpdateList()
end

function MUHAPScrollFrameMixin:FilterList()
	--print("FilterList", self.selectedCategoryIndex, self.selectedSubCategoryIndex, self.selectedSubSubCategoryIndex)
	local filterdItems = {}

	for _, entry in pairs(self.items) do 

		local Category = entry.Category
		local SubCategory = entry.SubCategory
		local SubSubCategory = entry.SubSubCategory

		if self.selectedCategoryIndex == nil  then
			filterdItems[#filterdItems + 1] = entry
		elseif self.selectedSubCategoryIndex == nil then
			if self.selectedCategoryIndex == Category then 
				filterdItems[#filterdItems + 1] = entry
			end
		elseif self.selectedSubSubCategoryIndex == nil then
			if self.selectedCategoryIndex == Category and self.selectedSubCategoryIndex == SubCategory then 
				filterdItems[#filterdItems + 1] = entry
			end
		else
			if self.selectedCategoryIndex == Category  and self.selectedSubCategoryIndex == SubCategory and self.selectedSubSubCategoryIndex == SubSubCategory then 
				filterdItems[#filterdItems + 1] = entry
			end
		end
	end


	self.filterdItems = filterdItems
end


function MUHAPScrollFrameMixin:SortList()

	table.sort(self.filterdItems, function(a,b)
		return a.needAction and not b.needAction
	end)

	table.sort(self.filterdItems, function(a,b)
		if a.needAction == b.needAction then 
			return a.lastChecked > b.lastChecked
		else
			return false
		end
	end)

end

function MUHAPScrollFrameMixin:OnShow()
	self:FilterList()
	self:UpdateList()
end


function MUHAPScrollFrameMixin:OnEvent(event, ...)
end

function MUHAPScrollFrameMixin:OnHide()
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
	print("UpdateList")
	self:ResetList()
	self:SortList()

	for i, entry in ipairs(self.filterdItems) do 
		print(i)

		self.entries[entry.id]:SetParent("MUHAPScrollListItems" .. i)
	end

	--[[
	for _, entry in pairs(self.filterdItems) do 
		self:addEntry(entry)
	end

	if self.filterdItems[#self.filterdItems].id ~= nil then 
		self:addEntry({
			id = nil,
			Category = nil,
			SubCategory = nil,
			SubSubCategory = nil,
			minPrice = 0,
			lastChecked = time(),
			qty = 1,
			enabled = true,
			needAction = true,
			duration = 1
		})
	end
	]]
end


function MUHAPScrollFrameMixin:ResetList()
	self.entries = {}
	for _, frame in ipairs(self.entries) do 
		entries:SetParent("MUHAPScrollListItemsHolder")
	end
end



function MUHAPScrollFrameMixin:generateListFrames()

	local amount = 20

    local height = 100

	local holder = CreateFrame("Frame", "MUHAPScrollListItemsHolder", self.list)
	holder:Hide()

	for i = 0, amount, 1 do 
		local pos = i * height * -1
		local Frame = CreateFrame("Frame", "MUHAPScrollListItems" .. i, self.list)
		Frame:SetPoint("TOPLEFT", 0, pos)
		Frame:SetPoint("TOPRIGHT", 0, pos)
		Frame:SetHeight(height)
	end

end

function MUHAPScrollFrameMixin:addEntryFrame()

    local height = 100
	local Item = CreateFrame("Frame", nil, "MUHAPScrollListItemsHolder", "MUHAPEntryTemplate")
    Item:SetPoint("TOPLEFT", 0, 0)
    Item:SetPoint("TOPRIGHT", 0, 0)
    Item:SetHeight(height) 

    return Item
end

function MUHAPScrollFrameMixin:addEntry(entry)
    local frame = self:addEntryFrame()
    self.entries[entry.id] = frame:SetItem(entry)
end


function MUHAPScrollFrameMixin:OnEvent(event, ...)
    print(event)
end









AuctionHouseMUHAPCategoriesListMixin = CreateFromMixins(AuctionHouseCategoriesListMixin);


function AuctionHouseMUHAPCategoriesListMixin:SetSelectedCategory(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)
    self.selectedCategoryIndex = selectedCategoryIndex;
	self.selectedSubCategoryIndex = selectedSubCategoryIndex;
	self.selectedSubSubCategoryIndex = selectedSubSubCategoryIndex;

    print("select")

    AuctionHouseFrame.MUHAPFrame:OnCategorySelected(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)

	AuctionFrameFilters_Update(self);
end



