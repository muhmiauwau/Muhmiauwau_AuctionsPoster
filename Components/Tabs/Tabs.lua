local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()

local Tabs = {}

function Tabs:GetTab()
	return PanelTemplates_GetSelectedTab(self);
end

function Tabs:SetTab(tabID, force)
	if self:GetTab() == tabID and not force then
		return;
	end
	
	PanelTemplates_SetTab(self, tabID);
	MUHAP.state.showDisabled = (tabID == 2) and true or false
	MUHAP.List:reload()
end

function Tabs:OnLoad()
	PanelTemplates_SetNumTabs(self, 2);
	self:SetTab(1);
end


MUHAPTabsMixin = Tabs;