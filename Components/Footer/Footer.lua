local Footer = {}

local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()


function Footer:OnLoad()
	self.ticker = nil
end


function Footer:OnShow()
	if self.ticker then
		self.ticker:Cancel()
	end

	self.ticker = C_Timer.NewTimer(60, function ()
		MUHAP:triggerAllChecks()
	end)
end



function Footer:OnHide()

	if self.ticker then
		self.ticker:Cancel()
	end
end


function Footer:checkAuctions()

	local list =  MUHAP.List:get()

    local statusCheck =  _.filter(list, function(v)
		if not v.status then return false end
		return v.status.check == true
	end)

	local statusAuctions =  _.filter(list, function(v)
		if not v.status then return false end
		return v.status.auction == true
	end)

    
	MUHAP.Footer.TextCheck:SetValue(#statusCheck)


    self:SetAuctions(statusAuctions)
end

function Footer:SetAuctions(auction)

	MUHAP.Footer.TextAuctions:SetValue(#auction)

	if #auction > 0 then
		self.PostButton:SetEnabled(true);
	else
        self.PostButton:SetEnabled(false);
	end
end






MUHAPFooterMixin = Footer



MUHAPFooterCheckButtonMixin = {};
function MUHAPFooterCheckButtonMixin:OnClick()
	MUHAP:triggerAllChecks()
end



MUHAPFooterPostButtonMixin = {};
function MUHAPFooterPostButtonMixin:OnClick()
	MUHAP:triggerAllPostAuctions()
end
