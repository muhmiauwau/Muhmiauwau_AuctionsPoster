
local SettingsLib = LibStub:NewLibrary("SettingsLib", 1)

if not SettingsLib then
   return	-- already loaded and no upgrade necessary
end

-- Please fix this bug blizzard
-- overwrite SettingsPanel close fucntion in order to aviod error on closing
function SettingsPanel:ExitWithCommit(skipTransitionBackToOpeningPanel)
   local unrevertable = true;
   self:Commit(unrevertable);
   HideUIPanel(self);
end

SettingsLib.db = nil
SettingsLib.defaultConfig = nil
SettingsLib.title = ""

SettingsLib.Options = {}



function SettingsLib:createSettings(db, config)
   if not config then return end

   SettingsLib.title = config.globals.title or ""

   SettingsLib.defaultConfig = {}
   for idx, entry in pairs(config.options) do 
      SettingsLib.defaultConfig[idx] = entry.default
   end
   SettingsLib.db = (db == nil) and SettingsLib.defaultConfig  or db

   SettingsLib.Options = config.options

   SettingsLib:generateView() 

   return SettingsLib
 end



function SettingsLib:GetDropDownOptions(obj)
   return function()
      local container = Settings.CreateControlTextContainer();
      for v , k in ipairs(obj) do
         container:Add(v - 1, k);
      end
      return container:GetData();
   end
end

function SettingsLib:GetSettings(category, opt)
    return Settings.RegisterProxySetting(category, opt.variable, self.db, opt.VarType, opt.name, opt.default);
end



 --[[ Checkbox 
 ]]
function SettingsLib:addCheckbox(category, opt)
   opt.VarType = Settings.VarType.Boolean
   Settings.CreateCheckBox(category, SettingsLib:GetSettings(category, opt), opt.tooltip);
end 
 



 --[[ Dropdown
   {
      type = "dropdown",
      variable = "droptest",
      name = "dropdown", 
      tooltip = "dropdown",
      options = {
         "Option A",
         "Option B",
         "Option C"
      } 
 ]]
 function SettingsLib:addDropDown(category, opt)
   opt.VarType = Settings.VarType.Number
   Settings.CreateDropDown(category, SettingsLib:GetSettings(category, opt), SettingsLib:GetDropDownOptions(opt.options), opt.tooltip);
end 

 --[[ Headline
   {
      type = "headline",
      name = L["Settings/fastBrowse.name"],
   },
]]
function SettingsLib:addHeadline(layout, opt)
   layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(opt.name));
end



function SettingsLib:generateView() 
   local category, layout = Settings.RegisterVerticalLayoutCategory(SettingsLib.title);

    
   for k, opt in pairs(SettingsLib.Options) do
      if opt.type == "checkbox" then
        SettingsLib:addCheckbox(category, opt)
      elseif opt.type == "dropdown" then
        SettingsLib:addDropDown(category, opt)
      elseif opt.type == "slider" then
         --AHCC:setSlider(category, opt)
      elseif opt.type == "headline" then
         SettingsLib:addHeadline(layout, opt)
      end
   end

   Settings.RegisterAddOnCategory(category);
end


