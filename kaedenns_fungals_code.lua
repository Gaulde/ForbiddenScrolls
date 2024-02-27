dofile("mods/forbidden_scrolls/common.lua")

--materials
MATERIALS_FROM = 
{
    { probability = 1.0, materials = { "water", "water_static", "water_salt", "water_ice" }, name_material = "water" },
    { probability = 1.0, materials = { "lava" } },
    { probability = 1.0, materials = { "radioactive_liquid", "poison", "material_darkness" }, name_material = "poisonous liquid"},
    { probability = 1.0, materials = { "oil", "swamp", "peat" }, name_material = "oil" },
    { probability = 1.0, materials = { "blood" } }, -- NOTE(Olli): I'm not sure if it's a good idea to convert blood, because that often just feels buggy. but let's see.
    { probability = 1.0, materials = { "blood_fungi", "fungi", "fungisoil" }, name_material = "fungals" },
    { probability = 1.0, materials = { "freezing liquid", "leanium" } },
    { probability = 1.0, materials = { "acid" } },
    { probability = 0.4, materials = { "acid_gas", "acid_gas_static", "poison_gas", "fungal_gas", "radioactive_gas", "radioactive_gas_static" }, name_material = "poisonous gases" },
    { probability = 0.4, materials = { "magic_liquid_polymorph", "magic_liquid_unstable_polymorph" }, name_material = "harmonic polymorphine" },
    { probability = 0.4, materials = { "magic_liquid_berserk", "magic_liquid_charm", "magic_liquid_invisibility" }, name_material = "magical liquids"},
    { probability = 0.6, materials = { "diamond" } },
    { probability = 0.6, materials = { "silver", "brass", "copper" } },
    { probability = 0.2, materials = { "steam", "smoke" } },
    { probability = 0.4, materials = { "sand" } },
    { probability = 0.4, materials = { "snow_sticky" }, name_material = "snow" }, 
    { probability = 0.05, materials = { "rock_static" },name_material = "rock" },
    { probability = 0.0003, materials = { "gold", "gold_box2d" }, name_material = "gold" },}

MATERIALS_TO = 
{
    { probability = 1.00, material = "water" },
    { probability = 1.00, material = "lava" },
    { probability = 1.00, material = "toxic sludge" },
    { probability = 1.00, material = "oil" },
    { probability = 1.00, material = "blood" },
    { probability = 1.00, material = "fungus blood" },
    { probability = 1.00, material = "acid" },
    { probability = 1.00, material = "swamp" },
    { probability = 1.00, material = "whiskey" },
    { probability = 1.00, material = "sima" },
    { probability = 1.00, material = "leanium" },
    { probability = 1.00, material = "poison" },
    { probability = 1.00, material = "vomit" },
    { probability = 1.00, material = "pea_soup" },
    { probability = 1.00, material = "fungi" },
    { probability = 0.80, material = "sand" },
    { probability = 0.80, material = "diamond" },
    { probability = 0.80, material = "silver" },
    { probability = 0.80, material = "steam" },
    { probability = 0.50, material = "rock" },
    { probability = 0.50, material = "gunpowder" },
    { probability = 0.50, material = "ominous liquid" },
    { probability = 0.50, material = "flummoxium" },
    { probability = 0.20, material = "toxic rock" },
    { probability = 0.02, material = "polymorphine" },
    { probability = 0.02, material = "chaotic polymorphine" },
    { probability = 0.15, material = "teleportatium" },
    { probability = 0.01, material = "piss" },
    { probability = 0.01, material = "shit" },
    { probability = 0.01, material = "void liquid" },
    { probability = 0.01, material = "cheese" },}

function add_source_material(materials, probability, name)
    local entry = {
        probability = probability,
        materials = materials
    }
    if name ~= nil then
        entry.name_material = name
    end
    table.insert(MATERIALS_FROM, entry)
end

function add_target_material(material, probability)
    table.insert(MATERIALS_TO, {material=material, probability=probability})
end
-----------------------------------------------------------------------------

local shift_messages = {}
local MAX_SHIFTS = 20

function get_current_iter()
    return tonumber(GlobalsGetValue("fungal_shift_iteration", "0"))
end

function get_abs_shift(player_entity, iter)
    q_log(("get_abs_shift(player=%s, %s)"):format(player_entity, iter))
    if not random_create then
        GamePrint("get_shift: random_create undefined")
        return SHIFT_FAIL
    end
    SetRandomSeed(89346, 42345+iter)
    local rnd = random_create(9123, 58925+iter)
    local mat_from = pick_random_from_table_weighted(rnd, MATERIALS_FROM)
    local mat_to = pick_random_from_table_weighted(rnd, MATERIALS_TO)

    mat_from.flask = false
    mat_to.flask = false
    if random_nexti(rnd, 1, 100) <= 75 then -- 75% to use a flask
        if random_nexti(rnd, 1, 100) <= 50 then -- 50% which side gets it
            mat_from.flask = true
        else
            mat_to.flask = true
        end
    end
    return {from=mat_from, to=mat_to}
end

-- Build the final shift string
function q_shift_str(which, source, dest)
    return ("%s %s to %s"):format(which, source, dest)
end

-- Format a shift result
function q_format_shift(result)
    local localize = q_setting_get("localize")
    return format_shift_loc(result, localize)
end

-- Deduce and format the absolute-indexed shift
function q_find_shift(shift_index)
    q_log(("q_find_shift(%s)"):format(tostring(shift_index)))
    local curr_iter = get_current_iter()
    local player = get_players()[1]
    local shift_result = get_abs_shift(player, shift_index)
    local next_msg = format_relative(curr_iter, shift_index)
    for index, spair in ipairs(q_format_shift(shift_result)) do
        local msg = q_shift_str(next_msg, spair[1], spair[2])
        table.insert(shift_messages, msg)
    end
end

-- Determine the absolute start and end range for shifts
function q_which_shifts()
    local curr_iter = get_current_iter()
    local range_prev = math.floor(q_setting_get("previous_count"))
    local range_next = math.floor(q_setting_get("next_count"))
    q_log(("start-count = %s, end-count = %s, curr = %s"):format(
        range_prev, range_next, curr_iter))
    local idx_start = curr_iter
    local idx_end = curr_iter
    if range_prev < 0 then
        idx_start = 0
    elseif range_prev > 0 then
        idx_start = curr_iter - range_prev
    end

    if range_next < 0 then
        idx_end = MAX_SHIFTS
    elseif range_next > 0 then
        idx_end = curr_iter + range_next
    end

    if idx_start < 0 then idx_start = 0 end
    if idx_start > idx_end then idx_start = idx_end end
    if idx_end > MAX_SHIFTS then idx_end = MAX_SHIFTS end

    q_log(("start = %s, end = %s"):format(idx_start, idx_end))
    return {first=idx_start, last=idx_end}
end

-- Find all relevant shifts based on the settings
function q_find_shifts()
    local range_bounds = q_which_shifts()
    local rstart = range_bounds.first
    local rend = range_bounds.last
    q_log(("Querying shifts from %s to %s"):format(rstart, rend))
    local i = rstart
    while i <= rend do
        q_log(("Querying shift %s"):format(i))
        q_find_shift(i)
        i = i + 1
    end
end

-- Fungal Shifts
    local MAX_SHIFTS = 20
    local player = get_players()[1]
    local curr_iter = 0
    local shifts = {}  -- Initialize a table to store individual shifts

    for i = curr_iter, curr_iter + 4 do  -- Print the next 5 shifts
        local shift_result = get_abs_shift(player, i)
        local next_msg = format_relative(curr_iter, i)

    for index, spair in ipairs(q_format_shift(shift_result)) do
        local msg = q_shift_str(next_msg, spair[1], spair[2])
        table.insert(shifts, msg)  -- Store each shift in the table
fs_inscription = table.concat(shifts, "\n")
        end
    end

function fungals_inscription()
    return tostring(fs_inscription)
end