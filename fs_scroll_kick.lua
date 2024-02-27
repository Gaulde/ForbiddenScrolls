dofile_once("data/scripts/lib/utilities.lua")
dofile("mods/forbidden_scrolls/settings.lua") 

function kick()
	local entity_id = GetUpdatedEntityID()
	local pos_x, pos_y = EntityGetTransform( entity_id )
	pos_y = pos_y + 10

	if EntityGetFirstComponent( entity_id, "PhysicsBodyComponent" ) == nil then
		return -- do nothing if item is in the inventory or hand
	end

	GamePlaySound( "data/audio/Desktop/misc.bank", "misc/beam_from_sky_kick", pos_x, pos_y )
	EntityLoad( "data/entities/particles/polymorph_explosion.xml", pos_x, pos_y )

    if FsLogicHasSettingFlag("new_fungal_logic") == true 
        then dofile("data/alchemyrecipes/beta_fungals_code.lua")
        print("New logic enganged---------------------------+++")
    elseif FsLogicHasSettingFlag("new_fungal_logic") == false
        then dofile("data/alchemyrecipes/kaedenns_fungals_code.lua")
        print("Old logic enganged---------------------------+++")
    end
    
fs_recipe = fungals_inscription()
local bookfs = EntityGetClosestWithTag(0, 0, "modbook3")

local function setBookDescription(bookEntity, description)
    if bookEntity ~= 0 then
        for k, v in ipairs(EntityGetComponent(bookEntity, "ItemComponent")) do
            ComponentSetValue2(v, "ui_description", tostring(description))
        end
    end
end
    setBookDescription(bookfs, fs_recipe)
end