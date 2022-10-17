-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
local _G = getfenv(0)
local select = _G.select
local string = _G.string
local format = string.format

-- WoW
local function C_Map_GetAreaInfo(id)
	local d = C_Map.GetAreaInfo(id)
	return d or "GetAreaInfo"..id
end

-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local addonname = ...
local AtlasLoot = _G.AtlasLoot
local data = AtlasLoot.ItemDB:Add(addonname, 1)

local AL = AtlasLoot.Locales
local ALIL = AtlasLoot.IngameLocales

local GetForVersion = AtlasLoot.ReturnForGameVersion

local BEFORE_RAID_DIFF = data:AddDifficulty(AL["Before Raid"], "n", 1, nil, true)
local P1_DIFF = data:AddDifficulty(AL["P1"], "h", 2, nil, true)

local DIFF_TRANSFORM = {
	["PR"] = BEFORE_RAID_DIFF,
	["T7"] = P1_DIFF
}
local ALLIANCE_DIFF, HORDE_DIFF, LOAD_DIFF
if UnitFactionGroup("player") == "Horde" then
	HORDE_DIFF = data:AddDifficulty(FACTION_HORDE, "horde", nil, 1)
	ALLIANCE_DIFF = data:AddDifficulty(FACTION_ALLIANCE, "alliance", nil, 1)
	LOAD_DIFF = HORDE_DIFF
else
	ALLIANCE_DIFF = data:AddDifficulty(FACTION_ALLIANCE, "alliance", nil, 1)
	HORDE_DIFF = data:AddDifficulty(FACTION_HORDE, "horde", nil, 1)
	LOAD_DIFF = ALLIANCE_DIFF
end

local NORMAL_ITTYPE = data:AddItemTableType("Item", "Item")
local SET_ITTYPE = data:AddItemTableType("Set", "Item")

local QUEST_EXTRA_ITTYPE = data:AddExtraItemTableType("Quest")
local PRICE_EXTRA_ITTYPE = data:AddExtraItemTableType("Price")
local SET_EXTRA_ITTYPE = data:AddExtraItemTableType("Set")

local VENDOR_CONTENT = data:AddContentType(AL["Vendor"], ATLASLOOT_DUNGEON_COLOR)
local SET_CONTENT = data:AddContentType(AL["Sets"], ATLASLOOT_PVP_COLOR)
local WORLD_BOSS_CONTENT = data:AddContentType(AL["World Bosses"], ATLASLOOT_WORLD_BOSS_COLOR)
local COLLECTIONS_CONTENT = data:AddContentType(AL["Collections"], ATLASLOOT_COLLECTIONS_COLOR)
local WORLD_EVENT_CONTENT = data:AddContentType(AL["World Events"], ATLASLOOT_SEASONALEVENTS_COLOR)

-- local x = {["a"]=1, ['b']=2, 1,2,3,4}
-- for k, v in pairs(x) do
-- 	print(k, v, type(k), type(v))
-- end

for className, talents in pairs(Bistooltip_bislists) do
	for talent, parts  in pairs(talents) do 
		data[className .. talent] = data[className .. talent] or {
			name = AL[string.format("%s %s BiS", className, talent)],
			ContentType = SET_CONTENT,
			items = {}
		}
		for part, slots in pairs(parts) do
			for slot, items in pairs(slots) do
				-- local dbItems, dbItem
				data[className .. talent].items = data[className .. talent].items or {}
				data[className .. talent].items[slot] = data[className .. talent].items[slot] or {}
				data[className .. talent].items[slot][DIFF_TRANSFORM[part]] = data[className .. talent].items[slot][DIFF_TRANSFORM[part]] or {}

				for i = 1, #items do
					table.insert(data[className .. talent].items[slot][DIFF_TRANSFORM[part]], {i, items[i]})
				end
				-- for i = 1, items.enhs do
					-- TODOS: enchant here
				-- end
				data[className .. talent].items[slot].name = AL[items.slot_name]
			end
		end
	end
end