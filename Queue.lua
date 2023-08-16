local MUHAP = LibStub("AceAddon-3.0"):GetAddon("MUHAP")

local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()


MUHAP.Queue = {}

local queueEntryInterface = {
    type = {
        required = true,
        type = "string",
        values = {
            "auction",
            "check"
        }
    },
    itemKey = {
        required = true,
        type = "table"
    }
}






function MUHAP.Queue:get(queueEntry)
    if not queueEntry then return end
    return _.find(MUHAP.state.Queue, function(v)
        return v.type == queueEntry.type and v.itemKey.itemID == queueEntry.itemKey.itemID  and v.itemKey.itemLevel == queueEntry.itemKey.itemLevel 
    end)
end

function MUHAP.Queue:set(queue)
    MUHAP.state.Queue = queue
end

function MUHAP.Queue:getByItemkey(itemKey)
    return _.find(MUHAP.state.Queue, function(v)
        return v.itemKey.itemID == itemKey.itemID  and v.itemKey.itemLevel == itemKey.itemLevel 
    end)
end


function MUHAP.Queue:getByType(queueEntryType)
    assert(queueEntryType, string.format("argument missing Usage: 'MUHAP.Queue:getByType(queueEntryType)'"))
    assert(type(queueEntryType) == queueEntryInterface.type.type, string.format("'%s' is not a valid type for queueEntry.type", type(queueEntryType)))

    local idx = _.findIndex(queueEntryInterface.type.values, function(v)
        return v == queueEntryType
    end)

    assert((idx > 0), string.format("'%s' is not a valid value for queueEntry.type", queueEntryType))


    local filter = _.filter(MUHAP.state.Queue, function(v)
        return v.type == queueEntryType
    end)

    return filter
end

function MUHAP.Queue:getNumByType(queueEntryType)
    local table = MUHAP.Queue:getByType(queueEntryType)
    if not table then return 0 end
    return #table
end



function MUHAP.Queue:isValid(queueEntry)
    if not queueEntry and not _.table(queueEntry) then return false end



    _.forEach(queueEntryInterface, function(interface, key) 

        if interface.required then 
            assert(queueEntry[key] ~= nil, string.format("queueEntry '%s' is required: %s", key, _.str(queueEntry[key])))
        end 

        if interface.type then 
            assert(type(queueEntry[key]) == interface.type, string.format("queueEntry '%s' has an invalid type:'%s' ",key, type(queueEntry[key])))
           
        end

        if interface.values then 
            local idx = _.findIndex(interface.values, function(v)
                return v == queueEntry[key]
            end)

            assert((idx > 0), string.format("'%s' is not a valid value for queueEntry.type", queueEntry[key]))

        end
    end)

end



function MUHAP.Queue:add(queueEntry)
    self:isValid(queueEntry)
    if self:get(queueEntry) then return end
    MUHAP.state.Queue[#MUHAP.state.Queue + 1] = queueEntry
    MUHAP.Footer:UpdateDisplay()
end

function MUHAP.Queue:delete(queueEntry)
	self:isValid(queueEntry)
    _.remove(MUHAP.state.Queue, function(value)
        return value.itemKey.itemID == queueEntry.itemKey.itemID and  value.itemKey.itemLevel == queueEntry.itemKey.itemLevel
    end)
    MUHAP.Footer:UpdateDisplay()
end

