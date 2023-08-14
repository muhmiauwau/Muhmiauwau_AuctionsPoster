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




local ScrollFrane = {}





function ScrollFrane:OnLoad()

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



function ScrollFrane:AddItem(entry)

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

function ScrollFrane:DeleteItem(id)
	for i, entry in ipairs(self.items) do 
		if entry.id == id then 
			tremove(self.items, i)
		end
	end

	self:FilterList()
    self:UpdateList()
end


function ScrollFrane:FilterList()
	--print("FilterList", self.selectedCategoryIndex, self.selectedSubCategoryIndex, self.selectedSubSubCategoryIndex)
	local filterdItems = {}

	local selectedCategoryIndex = MUHAP.CategoriesList.selectedCategoryIndex
	local selectedSubCategoryIndex = MUHAP.CategoriesList.selectedSubCategoryIndex
	local selectedSubSubCategoryIndex = MUHAP.CategoriesList.selectedSubSubCategoryIndex

	for _, entry in pairs(self.items) do 

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
				item= entry
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

function ScrollFrane:OnShow()
	if self.ticker then
		self.ticker:Cancel()
	end

	self.ticker = C_Timer.NewTimer(60, function ()
		self:triggerAllChecks()
	end)
end


function ScrollFrane:OnEvent(event, ...)
end

function ScrollFrane:OnHide()

	if self.ticker then
		self.ticker:Cancel()
	end
end


function ScrollFrane:checkIfExits(id)
	local match = false
	for _, entry in pairs(self.items) do 
		if entry.id == id then 
			match = true
		end 
	end 
	return match
end

function ScrollFrane:UpdateList()

	self.statusAuctions = tableFindAll(self.filterdItems, true, "status", "auction")
	self.statusCheck = tableFindAll(self.filterdItems, true, "status", "check")

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

	local amount = #self.items + 20
    local height = 100

	local holder = CreateFrame("Frame", "MUHAPScrollListItemsHolder", AuctionHouseFrame)
	holder:SetPoint("TOPLEFT", 0, 0)
	holder:SetPoint("TOPRIGHT", 0, 0)
	holder:SetHeight(100)
	holder:Hide()

	

	for i = 1, amount, 1 do 
		local pos = (i - 1)* height * -1
		local Frame = CreateFrame("Frame", "MUHAPScrollListItems" .. i, self.list, "MUHAPScrollFrameListItemTemplate")
		Frame:SetPoint("TOPLEFT", 0, pos)
		Frame:SetPoint("TOPRIGHT", 0, pos)
		Frame:SetHeight(height)
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


function ScrollFrane:OnEvent(event, ...)
   -- print(event)
end


function ScrollFrane:triggerAllChecks()
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

 function ScrollFrane:triggerAllPostAuctions()
--	print("triggerAllPostAuctions")
	
	if #self.filterdItems > 0 then 

		local entry = self.filterdItems[1]

		local frame = _G["MUHAPEntryFrame" .. entry.id]
		frame:PostItem()

		self:GetParent().Footer.PostButton:SetEnabled(false);
		entry.status.auction = false
	end


 end


 MUHAPScrollFrameMixin = ScrollFrane