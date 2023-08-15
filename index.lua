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
	showDisabled = false
}


MUHAP.state =  {
	showDisabled = false,
	List = {}
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









function MUHAP:triggerAllChecks()

	_.map(MUHAP.Entry:getAll(), function(frame)
		frame:runCheck() 
	end)


	C_Timer.After(3, function() 
		MUHAP.List:reload()
	end)

 end

 function MUHAP:triggerAllPostAuctions()
	print("triggerAllPostAuctions")
	print(#MUHAP.List:get(), #MUHAP.state.List)
	local items = _.filter(MUHAP.List:get(), function(v)
		return v.status.auction == true
	end)
	local item = _.first(items)
	if item then
		local frame = MUHAP.Entry:get(item.id)
		frame:PostItem()

		MUHAP.Footer.PostButton:SetEnabled(false);
	end
 end

