
local Footer = {}

function Footer:OnLoad()

end



MUHAPFooterMixin = Footer






MUHAPFooterCheckButtonMixin = {};
function MUHAPFooterCheckButtonMixin:OnClick()
	AuctionHouseFrame.MUHAP.ScrollFrame:triggerAllChecks()
end



MUHAPFooterPostButtonMixin = {};
function MUHAPFooterPostButtonMixin:OnClick()
	AuctionHouseFrame.MUHAP.ScrollFrame:triggerAllPostAuctions()
end
