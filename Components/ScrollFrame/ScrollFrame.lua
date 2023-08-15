local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()



local ScrollFrane = {}


function ScrollFrane:OnLoad()

	self.items = {}


    self.list = self.scrollFrame.ScrollBox
	self.list:SetWidth(self.scrollFrame:GetWidth() -  8)
	self.list:SetHeight(1) 

	self:generateListFrames()

	_.forEach(MUHAP.items, MUHAP.Entry.add, MUHAP.Entry)

end


function ScrollFrane:generateListFrames()

	local amount = #MUHAP.items + 20
    local height = 100


	--FramePoolMixin use  this
	for i = 1, amount, 1 do 
		local pos = (i - 1)* height * -1
		local Frame = CreateFrame("Frame", "MUHAPScrollListItems" .. i, self.list, "MUHAPScrollFrameListItemTemplate")
		Frame:SetPoint("TOPLEFT", 0, pos)
		Frame:SetPoint("TOPRIGHT", 0, pos)
		Frame:SetHeight(height)
	end
end




function ScrollFrane:reload()
	MUHAP.List:update()
	self.items = MUHAP.List:get()
	self:UpdateList()
end



function ScrollFrane:UpdateList()

	self.statusCheck =  _.filter(self.items, function(v)
		if not v.status then return false end
		return v.status.check == true
	end)

	self.statusAuctions =  _.filter(self.items, function(v)
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


	
	for i, entry in ipairs(self.items) do 
		local parent = _G["MUHAPScrollListItems" .. i]
		parent:Fill(entry.id)
	end
end


function ScrollFrane:ResetList()
	MUHAP.List:reset()
	MUHAP.Entry:deleteAll()
end







 MUHAPScrollFrameMixin = ScrollFrane