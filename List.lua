--local MUHAP = LibStub("AceAddon-3.0"):GetAddon("MUHAP")

local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()


MUHAP.List = {}



function MUHAP.List:reload()
    MUHAP.ScrollFrame:reload()
end

function MUHAP.List:get()
    return MUHAP.state.List
end

function MUHAP.List:set(list)
    MUHAP.state.List = list
end



function MUHAP.List:update()

    local selectedCategory = MUHAP.CategoriesList.selectedCategoryIndex
	local selectedSubCategory = MUHAP.CategoriesList.selectedSubCategoryIndex
	local selectedSubSubCategory = MUHAP.CategoriesList.selectedSubSubCategoryIndex 


    local checkStatus = function(entry)
        if not entry then return end
        if not entry.enabled then return entry end
    
        entry.status = entry.status or {auction = false, check = false}
    
        entry.status.check = (entry.lastChecked + 60) < time()
        entry.status.auction = entry.needAction
    
        return entry
    end


    local checkEnabled = function(entry) 
        return  ( not MUHAP.state.showDisabled and entry.enabled ) 
                or
                ( MUHAP.state.showDisabled and not entry.enabled )
    end

    local checkCategories = function(entry) 
        return  ( selectedCategory == nil ) 
                or
                ( ( selectedCategory == entry.Category  ) and ( selectedSubCategory == nil ) )
                or
                ( ( selectedCategory == entry.Category ) and ( selectedSubCategory == entry.SubCategory )  and ( selectedSubSubCategory == nil ))
                or
                ( ( selectedCategory == entry.Category ) and ( selectedSubCategory == entry.SubCategory )  and ( selectedSubSubCategory == entry.SubSubCategory ))
    end

    local list = _.filter(MUHAP.items, function(item) 
        item = checkStatus(item)
        item = MUHAP.Item:addMissingInfo(item)
        return  checkEnabled(item) and checkCategories(item)
    end)

    table.sort(list, function(a,b)
		return
			a.needAction and not b.needAction or
            (a.needAction == b.needAction and a.Name < b.Name)
	end)


    local statusCheck =  _.filter(list, function(v)
		if not v.status then return false end
		return v.status.check == true
	end)

	local statusAuctions =  _.filter(list, function(v)
		if not v.status then return false end
		return v.status.auction == true
	end)

    
	MUHAP.Footer.TextCheck:SetValue(#statusCheck)
    MUHAP.Footer.TextAuctions:SetValue(#statusAuctions)


	if #statusAuctions > 0 then
		MUHAP.Footer.PostButton:SetEnabled(true);
	else
        MUHAP.Footer.PostButton:SetEnabled(false);
	end


    self:set(list)

end