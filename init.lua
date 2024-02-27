--Thank you to Kaedenn, Neffc, Nathan and all the other regs from Noita 
--discord community, aswell as ChatGTP.
--This is my first mod and coding project, most was repurposed from existing
--code and it is still the hardest thing ive ever done.
--Gaulde

dofile("mods/forbidden_scrolls/common.lua")
dofile("mods/forbidden_scrolls/settings.lua") 

--scroll spawn flag logic
    print("whats the flag old man:",tostring(HasSettingFlag("scroll_spawn")))
if  HasSettingFlag("scroll_spawn") == true then ModSettingRemove("scroll_spawn") 
    print("scrollspawn set to false on ng and true on restart:",tostring(HasSettingFlag("scroll_spawn"))) --and then spawn the empty scrolls

--picking spawn coordinates
local function random_between(min, max)
    return math.random(min, max) end

--choosing coordinates with more_spawn flag set in settings menu
local coordinates = {
    {pos_x = 10000, pos_y = -1200},
    {pos_x = 2337, pos_y = 845},
    {pos_x = 800, pos_y = -1100},
    {pos_x = -1337, pos_y = -200},
    {pos_x = -1500, pos_y = -750},
    {pos_x = 3450, pos_y = 1800},
    {pos_x = 4400, pos_y = 800},
    {pos_x = 680, pos_y = -150},
    {pos_x = 16100, pos_y = -1800},
}

if HasSettingFlag("morespawn") == true then 
    -- Insert an additional coordinate when the flag is true
    table.insert(coordinates, {pos_x = -4900, pos_y = 800})
else
    print("Regular spawns only")
end

local year, month, day, hour, minute, second = GameGetDateAndTimeLocal()
local locationscramblingseed = year + month + day + hour + minute + second
math.randomseed(locationscramblingseed)

for i = #coordinates, 2, -1 do
    local j = random_between(1, i)
    coordinates[i], coordinates[j] = coordinates[j], coordinates[i] end
local newCoordinates = {coordinates[1], coordinates[2], coordinates[3]}

--loading uninscripted scrolls into overworld
local nxml = dofile_once("mods/forbidden_scrolls/nxml.lua")
local xml_path = "data/biome/_pixel_scenes.xml"
local xml_content = ModTextFileGetContent(xml_path)
local xml = nxml.parse(xml_content)
local new_elements = {
    {pos_x = tostring(newCoordinates[1].pos_x), pos_y = tostring(newCoordinates[1].pos_y), just_load_an_entity = "mods/forbidden_scrolls/files/lc_book.xml"},
    {pos_x = tostring(newCoordinates[2].pos_x), pos_y = tostring(newCoordinates[2].pos_y), just_load_an_entity = "mods/forbidden_scrolls/files/ap_book.xml"},
    {pos_x = tostring(newCoordinates[3].pos_x), pos_y = tostring(newCoordinates[3].pos_y), just_load_an_entity = "mods/forbidden_scrolls/files/fs_book.xml"},}
local root_element = xml:first_of("mBufferedPixelScenes")
if not root_element then
    root_element = nxml.new_element("mBufferedPixelScenes")
    xml:add_child(root_element) end
for _, element_data in ipairs(new_elements) do
    local new_element = nxml.new_element("PixelScene", element_data)
    root_element:add_child(new_element) end
local modified_xml_content = nxml.tostring(xml, true)
ModTextFileSetContent(xml_path, modified_xml_content)
print(tostring(modified_xml_content))
else -- if flag = true
    print("scroll_spawn stopped bc flag was set 'true' for restart")
end 

function OnPlayerSpawned(player_entity)
        if HasSettingFlag("scroll_spawn") == false then
        AddSettingFlag("scroll_spawn") 
        print("scrollspawn set to true:",tostring(HasSettingFlag("scroll_spawn")))
    end
end