local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()



local ScrollFrane = {}


function ScrollFrane:OnLoad()

	self.showDisabled = false


	self.selectedCategoryIndex = nil;
	self.selectedSubCategoryIndex = nil;
	self.selectedSubSubCategoryIndex = nil;

	self.filterdItems = {}


    self.list = self.scrollFrame.ScrollBox
	self.list:SetWidth(self.scrollFrame:GetWidth() -  8)
	self.list:SetHeight(1) 

	self:generateListFrames()

	for _, entry in pairs(MUHAP.items) do 
		MUHAP.Entry:add(entry)
	end
end


function ScrollFrane:FilterList()
	--print("FilterList", self.selectedCategoryIndex, self.selectedSubCategoryIndex, self.selectedSubSubCategoryIndex)
	local filterdItems = {}

	local selectedCategoryIndex = MUHAP.CategoriesList.selectedCategoryIndex
	local selectedSubCategoryIndex = MUHAP.CategoriesList.selectedSubCategoryIndex
	local selectedSubSubCategoryIndex = MUHAP.CategoriesList.selectedSubSubCategoryIndex

	for _, entry in pairs(MUHAP.items) do 

		local item = nil

		local Category = entry.Category
		local SubCategory = entry.SubCategory
		local SubSubCategory = entry.SubSubCategory

		if selectedCategoryIndex == nil  then
			item = entry
		elseif selectedSubCategoryIndex == nil then
			if selectedCategoryIndex == Category then 
				item = entry
			end
		elseif selectedSubSubCategoryIndex == nil then
			if selectedCategoryIndex == Category and selectedSubCategoryIndex == SubCategory then 
				item = entry
			end
		else
			if selectedCategoryIndex == Category  and selectedSubCategoryIndex == SubCategory and selectedSubSubCategoryIndex == SubSubCategory then 
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



function ScrollFrane:checkStatus(entry)
	if not entry then return end
	if not entry.enabled then return entry end

	entry.status = entry.status or {auction = false, check = false}

	entry.status.check = (entry.lastChecked + 60) < time()
	entry.status.auction = entry.needAction

	return entry
end

function ScrollFrane:SortList()

	table.sort(self.filterdItems, function(a,b)

		return
			a.needAction and not b.needAction or
            (a.needAction == b.needAction and a.lastChecked > b.lastChecked)
	end)

end


function ScrollFrane:UpdateList()

	self.statusCheck =  _.filter(self.filterdItems, function(v)
		if not v.status then return false end
		return v.status.check == true
	end)

	self.statusAuctions =  _.filter(self.filterdItems, function(v)
		if not v.status then return false end
		return v.status.auction == true
	end)

	self:GetParent().Footer.TextAuctions:SetValue(#self.statusAuctions)
	self:GetParent().Footer.TextCheck:SetValue(#self.statusCheck)

	if #self.statusCheck == 0 and #self.statusAuctions > 0 then
		self:GetParent().Footer.PostButton:SetEnabled(true);
		self:GetParent().Footer.PostButton:Show()
	else
		self:GetParent().Footer.PostButton:Hide()
	end


	self:ResetList()
	self:SortList()

	for i, entry in ipairs(self.filterdItems) do 
		local parent = _G["MUHAPScrollListItems" .. i]
		parent:Fill(entry.id)
	end

end


function ScrollFrane:ResetList()
	local children = { self.list:GetChildren() }
	for _, child in pairs(children) do 
		child:Empty()
	end
end



function ScrollFrane:generateListFrames()

	local amount = #MUHAP.items + 20
    local height = 100

	local holder = CreateFrame("Frame", "MUHAPScrollListItemsHolder", AuctionHouseFrame)
	holder:SetPoint("TOPLEFT", 0, 0)
	holder:SetPoint("TOPRIGHT", 0, 0)
	holder:SetHeight(100)
	holder:Hide()

	
--FramePoolMixin use  this
	for i = 1, amount, 1 do 
		local pos = (i - 1)* height * -1
		local Frame = CreateFrame("Frame", "MUHAPScrollListItems" .. i, self.list, "MUHAPScrollFrameListItemTemplate")
		Frame:SetPoint("TOPLEFT", 0, pos)
		Frame:SetPoint("TOPRIGHT", 0, pos)
		Frame:SetHeight(height)
	end

	local settings = CreateFrame("Frame", "MUHAPEntrySettings", MUHAPScrollListItemsHolder, "MUHAPEntrySettingsTemplate")
    settings:SetPoint("TOPLEFT", 0, 0)
    settings:SetPoint("TOPRIGHT", 0, 0)
	settings:SetFrameLevel(500)
    settings:SetHeight(height) 
end



function ScrollFrane:addEntry(entry)
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




 MUHAPScrollFrameMixin = ScrollFrane