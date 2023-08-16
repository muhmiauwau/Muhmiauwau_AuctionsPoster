MUHAP = LibStub("AceAddon-3.0"):NewAddon("MUHAP", "AceEvent-3.0")
local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()



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


MUHAP.state =  {
	showDisabled = false,
	List = {},
	Queue = {}
}


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


	self.items = AuctionsPosterCharDB.items
 end 


 function MUHAP:formatPlayerName(name, realm)
	realm = realm or GetRealmName()
	local nameWithRealm = name.. "-" .. realm
	nameWithRealm = nameWithRealm:gsub("%s+", "")
	return nameWithRealm
 end
 


 
 function MUHAP:OnEnable()
	MUHAP:RegisterEvent("ADDON_LOADED", "AddonLoadedEvent")

	MUHAP:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED", "ItemCheckEvent")
	MUHAP:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED", "ItemCheckEvent")
 end
 
 

 function MUHAP:AddonLoadedEvent(event, name)
    if name == "Blizzard_AuctionHouseUI" then 
		self:UnregisterEvent(event)

	
		-- create Parent
		AuctionHouseFrame.MUHAP = CreateFrame("Frame", nil, AuctionHouseFrame)
		AuctionHouseFrame.MUHAP:SetPoint("TOPLEFT", 0, 0)
		AuctionHouseFrame.MUHAP:SetPoint("BOTTOMRIGHT", 0, 0)

		-- create CategoriesList 
		MUHAP.CategoriesList = CreateFrame("Frame", nil, AuctionHouseFrame.MUHAP, "MUHAPCategoriesListTemplate")
		AuctionHouseFrame.MUHAP.CategoriesList = MUHAP.CategoriesList

		-- create MUHAPFrame
		MUHAP.ScrollFrame = CreateFrame("Frame", nil, AuctionHouseFrame.MUHAP, "MUHAPScrollFrameTemplate")
		AuctionHouseFrame.MUHAP.ScrollFrame = MUHAP.ScrollFrame

		-- create MUHAPFooter
		MUHAP.Footer = CreateFrame("Frame", nil, AuctionHouseFrame.MUHAP, "MUHAPFooterTemplate")
		AuctionHouseFrame.MUHAP.Footer = MUHAP.Footer

		-- create MUHAPTabs
		MUHAP.Tabs = CreateFrame("Frame", nil, AuctionHouseFrame.MUHAP, "MUHAPTabsTemplate")
		AuctionHouseFrame.MUHAP.Tabs = MUHAP.Tabs 

		-- create MUHAPCreateNew
		MUHAP.CreateNew = CreateFrame("Frame", nil, AuctionHouseFrame.MUHAP, "MUHAPCreateNewTemplate")
		AuctionHouseFrame.MUHAP.CreateNew = MUHAP.CreateNew


		local settings = CreateFrame("Frame", "MUHAPEntrySettings",  AuctionHouseFrame.MUHAP, "MUHAPEntrySettingsTemplate")
		settings:Hide()


		--FramePoolMixin use  this
		local holder = CreateFrame("Frame", "MUHAPScrollListItemsHolder", AuctionHouseFrame.MUHAP)
		holder:SetPoint("TOPLEFT", 0, 0)
		holder:SetPoint("TOPRIGHT", 0, 0)
		holder:SetHeight(100)
		holder:Hide()

		

		
		-- Display config
		AuctionHouseFrameDisplayMode["MUHAP"] = {
			"MUHAP"
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


function MUHAP:OnCategorySelected(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)
	MUHAP.List:reload()
end









function MUHAP:ItemCheckEvent(event, itemKey)
	if MUHAP.Footer.checksNum == 0 then return end



	local itemKey = _.isTable(itemKey) and itemKey or C_AuctionHouse.MakeItemKey(itemKey)

	local queueEntry = {
		type =  "check",
		itemKey = itemKey
	}
	local isInQuery = MUHAP.Queue:get(queueEntry)

	if isInQuery then 
		local item = MUHAP.Item:get(itemKey)

		MUHAP.Queue:delete(queueEntry)


		local priceKey = "buyoutAmount"
		if item.isCommodity then 
			priceKey = "unitPrice"
		end

		local needUpdate = function(result)
			local match = true
			
			if #result.owners > 0 then 
				local _, realm =  UnitName("player")
				local formattedName = MUHAP:formatPlayerName(result.owners[1], realm )
				if result.owners[1] == "player" or AuctionsPosterDB.activeChars[formattedName] or AuctionsPosterDB.activeChars[result.owners[1] ] then 
					match = false
				end
			else
				match = false
			end

			if item.minPrice > result[priceKey] then 
				match = false
			end

			return match
		end

		local result = nil
		
		if item.isCommodity then 
			result = C_AuctionHouse.GetCommoditySearchResultInfo(itemKey.itemID, 1)
		else 
			result = C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1)
		end


		if result then 
			print("ok")
			item.needAction = needUpdate(result)
			item.buyoutAmount = result[priceKey]
		else
			print("not")
			item.needAction = false
			item.buyoutAmount = 0
		end

		item.lastChecked = time()

		

		local entry = MUHAP.Entry:get(itemKey)
		entry:Init(item)

	end

	


		

			--[[
			

			local priceKey = "buyoutAmount"
			if self.entry.isCommodity then 
				priceKey = "unitPrice"
			end


            local needUpdate = function(result)
				local match = true
				
				if #result.owners > 0 then 
					local _, realm =  UnitName("player")
					local formattedName = MUHAP:formatPlayerName(result.owners[1], realm )
					if result.owners[1] == "player" or AuctionsPosterDB.activeChars[formattedName] or AuctionsPosterDB.activeChars[result.owners[1] ] then 
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
]]
        

end
