local MUHAP = LibStub("AceAddon-3.0"):GetAddon("MUHAP")

local Lodash = LibStub:GetLibrary("Lodash")
local _ = Lodash:init()


MUHAP.List = {}

MUHAP.List.list = {}



function MUHAP.List:reload()
    MUHAP.ScrollFrame:reload()
end


function MUHAP.List:reset()
    MUHAP.List.list = {}
end

function MUHAP.List:get()
    return MUHAP.List.list
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

    MUHAP.List.list =  _.filter(MUHAP.items, function(entry) 
        entry = checkStatus(entry)
        return  checkEnabled(entry) and checkCategories(entry)
    end)


    table.sort(MUHAP.List.list, function(a,b)
		return
			a.needAction and not b.needAction or
            (a.needAction == b.needAction and a.lastChecked > b.lastChecked)
	end)


end







