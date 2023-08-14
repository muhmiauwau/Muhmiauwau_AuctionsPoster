
local Tabs = {}

function Tabs:GetTab()
	return PanelTemplates_GetSelectedTab(self);
end

function Tabs:SetTab(tabID)
	if self:GetTab() == tabID then
		return;
	end
	PanelTemplates_SetTab(self, tabID);

	local ScrollFrame = self:GetParent().ScrollFrame

	ScrollFrame.showDisabled = (tabID == 2) and true or false

	ScrollFrame:FilterList()
	ScrollFrame:UpdateList()

end

function Tabs:OnLoad()
	PanelTemplates_SetNumTabs(self, 2);
	self:SetTab(1);


end


MUHAPTabsMixin = Tabs;