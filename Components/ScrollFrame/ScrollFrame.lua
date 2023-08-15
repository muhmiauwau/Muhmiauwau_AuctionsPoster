local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()



local ScrollFrane = {}


function ScrollFrane:OnLoad()
	self.items = {}

    self.list = self.scrollFrame.ScrollBox
	self.list:SetWidth(self.scrollFrame:GetWidth() -  8)
	self.list:SetHeight(1) 

	self:generateListFrames()
end


function ScrollFrane:generateListFrames()

	local amount = #MUHAP.items + 20
    local height = 100

	for i = 1, amount, 1 do 
		local pos = (i - 1)* height * -1
		local Frame = CreateFrame("Frame", nil, self.list, "MUHAPScrollFrameListItemTemplate")
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
	self:ResetList()
	local childs =  { self.list:GetChildren() }
	_.forEach(self.items, function(item, key) 
		local parent = childs[key]
		parent:Fill(item.id)
	end)
end


function ScrollFrane:ResetList()
	MUHAP.Entry:deleteAll()
end


 MUHAPScrollFrameMixin = ScrollFrane