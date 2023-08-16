local MUHAP = LibStub("AceAddon-3.0"):GetAddon("MUHAP")

local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()


MUHAP.Entry = {}

MUHAP.Entry.pool = CreateFramePool("Frame", nil, "MUHAPEntryTemplate")


MUHAP.Entry.activeFrames = {}

function MUHAP.Entry:get(itemKey)
    local find = _.find(self.activeFrames, function(value)
        return value.entry.itemKey.itemID == itemKey.itemID and  value.entry.itemKey.itemLevel == itemKey.itemLevel
    end)

    return find
end

function MUHAP.Entry:getAll()
    return self.activeFrames
end


function MUHAP.Entry:delete(itemKey)
    if not itemKey then return end

    local isActive = self.pool:IsActive(frame)
    if not isActive then return end

    local frame = _.remove(self.activeFrames, function(value)
        return value.entry.itemKey.itemID == itemKey.itemID and  value.entry.itemKey.itemLevel == itemKey.itemLevel
    end)
    if not frame then return end
    self.pool:Release(frame)

end


function MUHAP.Entry:deleteAll()
    self.pool:ReleaseAll() 
    self.activeFrames = {}
end


function MUHAP.Entry:add(itemKey)
	if not itemKey then return end

    local exist = self:get(itemKey)
    if exist then return exist end

   local item = MUHAP.Item:get(itemKey)
   if not item then return end

    local Frame = self.pool:Acquire()
	Frame:Init(item)
    self.activeFrames[#self.activeFrames + 1] = Frame
    return Frame
end



