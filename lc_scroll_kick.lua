dofile_once("data/scripts/lib/utilities.lua")

function kick()
	local entity_id = GetUpdatedEntityID()
	local pos_x, pos_y = EntityGetTransform( entity_id )
	pos_y = pos_y + 10

	if EntityGetFirstComponent( entity_id, "PhysicsBodyComponent" ) == nil then
		return -- do nothing if item is in the inventory or hand
	end

	GamePlaySound( "data/audio/Desktop/misc.bank", "misc/beam_from_sky_kick", pos_x, pos_y )
	EntityLoad( "data/entities/particles/polymorph_explosion.xml", pos_x, pos_y )

dofile("data/alchemyrecipes/neffs_alchemy_code.lua")
lc_recipe = alchemy_concoction()
local booklc = EntityGetClosestWithTag(0, 0, "modbook1")

local function setBookDescription(bookEntity, description)
    if bookEntity ~= 0 then
        for k, v in ipairs(EntityGetComponent(bookEntity, "ItemComponent")) do
            ComponentSetValue2(v, "ui_description", tostring(description))
        end
    end
end
    setBookDescription(booklc, lc_recipe)
end