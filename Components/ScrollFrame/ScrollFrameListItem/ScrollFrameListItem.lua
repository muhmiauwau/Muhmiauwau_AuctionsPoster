local ListItem = {}

function ListItem:OnLoad()
    self.holder = _G["MUHAPScrollListItemsHolder"]
end

function ListItem:Empty()
    self:Hide()
    local child = self:GetChildren()

    if child then 
        MUHAP.Entry:delete(child.entry.itemKey)
    end
end

function ListItem:Fill(itemKey)
    self:Show()
    local entryFrame = MUHAP.Entry:add(itemKey)

    if entryFrame then 
        entryFrame:Show()
        entryFrame:SetParent(self)
		entryFrame:SetAllPoints(self)
    end
end



MUHAPScrollFrameListItemMixin = ListItem