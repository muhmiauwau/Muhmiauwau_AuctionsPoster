MUHAPScrollListItemsMixin = {}

function MUHAPScrollListItemsMixin:OnLoad()
    self.holder = _G["MUHAPScrollListItemsHolder"]
end

function MUHAPScrollListItemsMixin:Empty()
    self:Hide()
    local child = self:GetChildren()

    if child then 
        child:SetParent(self.holder)
        child:SetAllPoints(self.holder)
    end
end

function MUHAPScrollListItemsMixin:Fill(id)
    self:Show()
    local entryFrame = _G["MUHAPEntryFrame" .. id]

    if entryFrame then 
        entryFrame:SetParent(self)
		entryFrame:SetAllPoints(self)
    end
end