MUHAP = LibStub("AceAddon-3.0"):NewAddon("MUHAP", "AceEvent-3.0")



MUHAP_MIN_UNIT_PRICE_LABEL = "min price"


MUHAP_QUANTITY_LABEL = "Qty"


MUHAP_DURATION_LABEL = "Duration"

MUHAP_ENABLED = "Enabled"

MUHAP_TEXT_TYPE = {
	qty =  "QTY",
	Available = "Available",
	minPrice =  "min price",
	buyout = "buyout price",
	lastChecked = "last checked",
	Duration = MUHAP_DURATION_LABEL,
	Auctions = "Auctions",
	Check = "Check"
}


AUCTION_DURATIONS = {
	AUCTION_DURATION_ONE,
	AUCTION_DURATION_TWO,
	AUCTION_DURATION_THREE,
};


MUHAP_CREATE_BUTTON = "Create"



function MUHAP:OnInitialize()
	-- AHCC:initOptions()


	if AuctionsPosterDB == nil then
		AuctionsPosterDB = {} 
	end
	
	if AuctionsPosterDB.activeChars == nil then
		AuctionsPosterDB.activeChars = {} 
	end


	if AuctionsPosterCharDB == nil then
		AuctionsPosterCharDB = {} 
	end
	
	if AuctionsPosterCharDB.items == nil then
		AuctionsPosterCharDB.items = {} 
	--[[
		AuctionsPosterCharDB.items = {
			{
				id = 194017,
				Category = 3,
				SubCategory = 1,
				SubSubCategory = nil,
				minPrice = 400000,
				lastChecked = time(),
				qty = 5,
				enabled = true,
				needAction = false,
				duration = 1
			},
			{
				id = 184480,
				Category = 3,
				SubCategory = 1,
				SubSubCategory = nil,
				minPrice = 2000000,
				lastChecked = time(),
				qty = 5,
				enabled = true,
				needAction = false,
				duration = 1
			},
			{
				id = 194019,
				Category = 3,
				SubCategory = 11,
				SubSubCategory = nil,
				minPrice = 400000,
				lastChecked = time(),
				qty = 5,
				enabled = true,
				needAction = true,
				duration = 1
			}
		}
		]]
	end

	if #AuctionsPosterCharDB.items > 0 then 
		local name, realm =  UnitName("player")
		local formattedName = self:formatPlayerName(name, realm )
		
		AuctionsPosterDB.activeChars[formattedName] = time()
	end

 end 


 function MUHAP:formatPlayerName(name, realm)
	realm = realm or GetRealmName()
	local nameWithRealm = name.. "-" .. realm
	nameWithRealm = nameWithRealm:gsub("%s+", "")
	return nameWithRealm
 end
 


 
 function MUHAP:OnEnable()
	MUHAP:RegisterEvent("ADDON_LOADED", "AddonLoadedEvent")
 end
 
 

 function MUHAP:AddonLoadedEvent(event, name)
    if name == "Blizzard_AuctionHouseUI" then 

		MUHAP:UnregisterEvent("ADDON_LOADED")

		-- create schrollframe
		AuctionHouseFrame.MUHAPFrame = CreateFrame("Frame", nil, AuctionHouseFrame, "MUHAPFrameTemplate")

		-- create schrollframe
		AuctionHouseFrame.MUHAPFooter = CreateFrame("Frame", nil, AuctionHouseFrame, "MUHAPFooterTemplate")

		-- create schrollframe
		AuctionHouseFrame.MUHAPTabs = CreateFrame("Frame", nil, AuctionHouseFrame, "MUHAPTabsTemplate")

		-- create CategoriesList 
		AuctionHouseFrame.MUHAPCategoriesList = CreateFrame("Frame", nil, AuctionHouseFrame, "AuctionHouseMUHAPCategoriesListTemplate")
		AuctionHouseFrame.MUHAPCategoriesList:SetPoint("LEFT",4, 0)
		AuctionHouseFrame.MUHAPCategoriesList:SetPoint("TOP",0, -73)


		-- Display config
		AuctionHouseFrameDisplayMode["MUHAP"] = {
			"MUHAPTabs",
			"MUHAPCategoriesList",
			"MUHAPFrame",
			"MUHAPFooter"
		}

		-- Add Tab 
		local tabsAmount = #AuctionHouseFrame.Tabs + 1
		local button = CreateFrame("Button", "AuctionHouseFrameTab" .. tabsAmount, AuctionHouseFrame, "AuctionHouseFrameDisplayModeTabTemplate")
		button:SetText("Auction Poster")

		button:SetScript("OnClick", function ()
			PanelTemplates_SetTab(AuctionHouseFrame, tabsAmount)
			AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode["MUHAP"]);
		end)

		PanelTemplates_SetNumTabs(AuctionHouseFrame, tabsAmount);


	end 
end































--###########################
--[[

function findinBag(itemID)
	for i = 0, NUM_BAG_SLOTS do
    	for z = 1, C_Container.GetContainerNumSlots(i) do
			if C_Container.GetContainerItemID(i, z) == itemID then
				return i, z
			end
		end
	end
end





local ItemTable = {
	[194017] = {
		qty = 3
	},
	[194019] = {
		qty = 4
	}
}
local eventActive = {}

local postItemTable = {}

local postItemID = nil
local postUnitPrice = nil




function checkItem(itemId)
	eventActive[itemId] = eventActive[itemId] or {}
	eventActive[itemId] = true

	local itemKey = C_AuctionHouse.MakeItemKey(itemId)
	C_AuctionHouse.SendSearchQuery(itemKey, {
		{sortOrder = Enum.AuctionHouseSortOrder.Buyout, reverseSort = false},
	}, true)

end




function checkItems()

	for k,v in pairs(ItemTable) do 
		checkItem(k)
	end
	

end



function PostIUten(itemId, price)
	if price and itemId then 
		print("PostIUten", itemId, price)
		local bagId, slotId = findinBag(itemId)
		local qty = ItemTable[itemId].qty or 1
		C_AuctionHouse.PostItem(ItemLocation:CreateFromBagAndSlot(bagId, slotId), 1, qty, nil, price)

	end
end


local checkActive = nil

local btnPost = nil 

local addondddd = CreateFrame("Frame")
addondddd:RegisterEvent("AUCTION_HOUSE_SHOW")
addondddd:SetScript("OnEvent", function()

	C_Timer.After(5, checkItems)

	if not checkActive then
		checkActive = true
		C_Timer.NewTicker(60, checkItems)
	end



	local btn = CreateFrame("Button", nil, AuctionHouseFrame, "UIPanelButtonTemplate")
	btn:SetPoint("RIGHT", "AuctionHouseFrame", "RIGHT", 130,40)
	btn:SetSize(120, 40)
	btn:SetText("Wildstofftasche")
	btn:SetScript("OnClick", function(self, button) 

		local itemId = 194017
		checkItem(itemId)
	end)

	local btn2 = CreateFrame("Button", nil, AuctionHouseFrame, "UIPanelButtonTemplate")
	btn2:SetPoint("RIGHT", "AuctionHouseFrame", "RIGHT", 130,0)
	btn2:SetSize(120, 40)
	btn2:SetText("Einfach genähte Reagenzientasche")
	btn2:SetScript("OnClick", function(self, button) 

		local itemId = 194019
		checkItem(itemId)
	end)




	local btn2 = CreateFrame("Button", nil, AuctionHouseFrame, "UIPanelButtonTemplate")
	btn2:SetPoint("RIGHT", "AuctionHouseFrame", "RIGHT", 130, -40)
	btn2:SetSize(120, 40)
	btn2:SetText("post")
	btn2:SetScript("OnClick", function(self, button) 

			PostIUten(postItemID, postUnitPrice)
			postItemID =  nil
			postUnitPrice = nil

	end)

	btnPost = CreateFrame("Button", nil, AuctionHouseFrame, "UIPanelButtonTemplate")
	btnPost:SetPoint("RIGHT", "AuctionHouseFrame", "RIGHT", 130, -80)
	btnPost:SetSize(120, 40)
	btnPost:SetText("Post Table")
	btnPost:SetScript("OnClick", function(self, button) 

		if #postItemTable >  0 then
			local itemID = postItemTable[#postItemTable].itemID
			local unitPrice = postItemTable[#postItemTable].unitPrice
			--print("btn", itemID, unitPrice)
			PostIUten(itemID, unitPrice)
			tremove(postItemTable, #postItemTable)
		else
			print("nothing to post")
			btnPost:Hide()
		end
	end)
	btnPost:Hide()


end)





local function has_value (tab, key, val)
    for index, value in ipairs(tab) do
        if value[key] == val then
            return true
        end
    end

    return false
end



function PostItems(itemID, unitPrice)

	if not has_value(postItemTable, "itemID",  itemID) then
		tinsert(postItemTable, {
			itemID = itemID,
			unitPrice = unitPrice
		})

		btnPost:Show()
	end

	postItemID =  itemID
	postUnitPrice = unitPrice
end


local f = CreateFrame("Frame")

function f:ITEM_SEARCH_RESULTS_UPDATED(event, itemKey)

	--print(itemKey.itemID)
	if eventActive[itemKey.itemID] then 
		eventActive[itemKey.itemID] = false
		local result = C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1)
		--DevTools_Dump(result)
		if result.owners[1] ~= "player" then
			print("not player item", itemKey.itemID)
			PostItems(itemKey.itemID, result.buyoutAmount)
		else
			print("player item", itemKey.itemID)
		end
	end
end


function f:OnEvent(event, ...)
	self[event](self, event, ...)
end

f:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")
f:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

]]
