dofile("data/scripts/lib/utilities.lua")
dofile("data/scripts/lib/mod_settings.lua")

--This is eba/evaisa's flag system from the Noita Discord
--and it just saved my day
-------------- scroll spawn toggle
function HasSettingFlag(scroll_spawn)
    return ModSettingGet(scroll_spawn) or false
end

function AddSettingFlag(scroll_spawn)
    ModSettingSet(scroll_spawn, true)
end

function RemoveSettingFlag(scroll_spawn)
    ModSettingRemove(scroll_spawn)
end
------------- beta fungal shift logic
function FsLogicHasSettingFlag(new_fungal_logic)
    return ModSettingGet(new_fungal_logic) or false
end

function FsLogicAddSettingFlag(new_fungal_logic)
    ModSettingSet(new_fungal_logic, true)
    print("beta fs logic flag unset:", tostring(HasSettingFlag("new_fungal_logic"))) 
end

function FsLogicRemoveSettingFlag(new_fungal_logic)
    ModSettingRemove(new_fungal_logic)
    print("beta fs logic flag unset:", tostring(HasSettingFlag("new_fungal_logic")))
 end
--------------- more spawn locations
function morespawn_HasSettingFlag(morespawn)
    return ModSettingGet(morespawn) or false 
end

function morespawn_AddSettingFlag(morespawn)
    ModSettingSet(morespawn, true)
        print("spawn flag set",tostring(HasSettingFlag("morespawn")))
end

function morespawn_RemoveSettingFlag(morespawn)
        print("spawn flag unset",tostring(HasSettingFlag("morespawn")))
    ModSettingRemove(morespawn)
end
----------------- silly names
function altnames_HasSettingFlag(altnames)
    return ModSettingGet(altnames) or false 
end

function altnames_AddSettingFlag(altnames)
    ModSettingSet(altnames, true)
    print("Alternative names set:",tostring(HasSettingFlag("altnames")))
end

function altnames_RemoveSettingFlag(altnames)
    ModSettingRemove(altnames)
    print("Alternative names unset:",tostring(HasSettingFlag("altnames")))
end
--trying to create a gui to set fungal scroll to main or beta branch... and maybe handle resets

function mod_setting_changed_callback(mod_id, gui, in_main_menu, setting, old_value, new_value)
    print("Setting changed:", setting.ui_name)
    
    if setting.id == "BETA check" then
        if new_value then
            AddSettingFlag("new_fungal_logic")
            print("BETA fs logic enabled")
        else
            RemoveSettingFlag("new_fungal_logic")
            print("BETA fs logic disabled")
        end
    elseif setting.id == "more spawns" then
        if new_value then
            morespawn_AddSettingFlag("morespawn")
            print("more spawns enabled")
        else
            morespawn_RemoveSettingFlag("morespawn")
            print("more spawns disabled")
        end
    elseif setting.id == "alt mat names" then
        if new_value then
            altnames_AddSettingFlag("altnames")
            print("Alternative material names enabled")
        else
            altnames_RemoveSettingFlag("altnames")
            print("Alternative material names disabled")
        end
--[[  -------template for more options
    elseif setting.id == "One More Option" then
        if new_value then
            -- Handle logic for turning on One More Option
            -- You can call custom functions or set flags here
            OneMoreOptionAddSettingFlag()
            print("One More Option enabled")
        else
            -- Handle logic for turning off One More Option
            -- You can call custom functions or remove flags here
            OneMoreOptionRemoveSettingFlag()
            print("One More Option disabled")
        end
        --]] 
    end
    -- Add similar checks for other settings if needed
end
-- wow this worked way better than i thought it would

local mod_id = "evil_scrolls_gui"
mod_settings = {
    {
        id = "BETA check",
        ui_name = "BETA Fungal shifts logic",
        ui_description = "only affects Forbidden Fungal Scroll",
        value_default = 0,
        change_fn = mod_setting_changed_callback,
        scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
        ui_fn = mod_setting_bool,
    },
    {
        id = "more spawns",
        ui_name = "More spawn locations",
        ui_description = "Adds the Alchemists Boss room to the spawn list, Thanks for the suggestions!",
        value_default = false,
        change_fn = mod_setting_changed_callback,
        scope = MOD_SETTING_SCOPE_NEW_GAME,
        ui_fn = mod_setting_bool,
    },
    -- Add more settings as needed
}


function mod_setting_bool(mod_id, gui, in_main_menu, im_id, setting)
    local value = ModSettingGetNextValue(mod_setting_get_id(mod_id, setting))
    if type(value) ~= "boolean" then value = setting.value_default or false end

    local text = setting.ui_name .. ": " .. GameTextGet(value and "$option_on" or "$option_off")

    local clicked, right_clicked = GuiButton(gui, im_id, mod_setting_group_x_offset, 0, text)
    if clicked then
        ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), not value, false)
        mod_setting_handle_change_callback(mod_id, gui, in_main_menu, setting, value, not value)
    end
    if right_clicked then
        local new_value = setting.value_default or false
        ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), new_value, false)
        mod_setting_handle_change_callback(mod_id, gui, in_main_menu, setting, value, new_value)
    end

    mod_setting_tooltip(mod_id, gui, in_main_menu, setting)
end 

function ModSettingsUpdate(init_scope)
    print("-------------------------update called")
    mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
    return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
    mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
