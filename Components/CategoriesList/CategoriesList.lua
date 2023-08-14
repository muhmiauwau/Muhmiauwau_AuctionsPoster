
local CategoriesList = CreateFromMixins(AuctionHouseCategoriesListMixin);

function CategoriesList:SetSelectedCategory(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)
    self.selectedCategoryIndex = selectedCategoryIndex;
	self.selectedSubCategoryIndex = selectedSubCategoryIndex;
	self.selectedSubSubCategoryIndex = selectedSubSubCategoryIndex;

    MUHAP:OnCategorySelected(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)
    AuctionFrameFilters_Update(self);
end



MUHAPCategoriesListMixin = CategoriesList