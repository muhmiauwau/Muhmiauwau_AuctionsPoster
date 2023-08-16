local Footer = {}

local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()


function Footer:OnLoad()
	self.checksNum = 0
	self.auctionNum = 0
	self.ticker = nil
end


function Footer:OnShow()
	if self.ticker then
		self.ticker:Cancel()
	end

	self.ticker = C_Timer.NewTicker(5, function ()
		self:processChecks()
	end)
end



function Footer:OnHide()

	if self.ticker then
		self.ticker:Cancel()
	end
end


function Footer:UpdateDisplay()
	self.checksNum = MUHAP.Queue:getNumByType("check")
	MUHAP.Footer.TextCheck:SetValue(self.checksNum)

    self:UpdateAuctions()
end

function Footer:UpdateAuctions()
	self.auctionNum =  MUHAP.Queue:getNumByType("auction")
	MUHAP.Footer.TextAuctions:SetValue(self.auctionNum)

	if self.auctionNum > 0 then
		self.PostButton:SetEnabled(true);
	else
        self.PostButton:SetEnabled(false);
	end
end



function Footer:processChecks()
	if self.checksNum == 0 then return end
	_.forEach(MUHAP.Queue:getByType("check"), function(queueEntry)
		MUHAP.Item:runCheck(queueEntry.itemKey)
	end)
end




function Footer:triggerAllChecks()
	_.map(MUHAP.Entry:getAll(), function(frame)
		MUHAP.Queue:add({
			type = "check",
			itemKey = frame.entry.itemKey
		})
	end)
 end

 function Footer:triggerAllPostAuctions()
	print("triggerAllPostAuctions")
	local items = _.filter(MUHAP.List:get(), function(v)
		return v.status.auction == true
	end)
	local item = _.first(items)
	if item then
		local frame = MUHAP.Entry:get(item.itemKey)
		frame:PostItem()

		MUHAP.Footer.PostButton:SetEnabled(false);
	end
 end




MUHAPFooterMixin = Footer



MUHAPFooterCheckButtonMixin = {};
function MUHAPFooterCheckButtonMixin:OnClick()
	self:GetParent():triggerAllChecks()
end



MUHAPFooterPostButtonMixin = {};
function MUHAPFooterPostButtonMixin:OnClick()
	self:GetParent():triggerAllPostAuctions()
end
