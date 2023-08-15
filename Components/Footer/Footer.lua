
local Footer = {}

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




MUHAPFooterMixin = Footer



MUHAPFooterCheckButtonMixin = {};
function MUHAPFooterCheckButtonMixin:OnClick()
	MUHAP:triggerAllChecks()
end



MUHAPFooterPostButtonMixin = {};
function MUHAPFooterPostButtonMixin:OnClick()
	MUHAP:triggerAllPostAuctions()
end
