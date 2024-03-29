local balamod = require('balamod')


joker = {}
joker.jokers = {}
joker.jokerEffects = {}
joker.loc_vars = {}
local function add(args)
    if type(args) ~= "table" then balamod.logger:error("Joker API addJoker: Invalid parameters"); return; end
    local id = args.id or "j_Joker_Placeholder" .. #G.P_CENTER_POOLS["Joker"] + 1
    local name = args.name or "Joker Placeholder"
    local joker_effect = args.joker_effect or function(_) end
    local order = args.order or #G.P_CENTER_POOLS["Joker"] + 1
    local unlocked = args.unlocked or true
    local discovered = args.discovered or true
    local cost = args.cost or 4
    local pos = args.pos or {x=9, y=9} --blank joker sprite
    local effect = args.effect or ""
    local config = args.config or {}
    local desc = args.desc or {"Placeholder"}
    local rarity = args.rarity or 1
    local unlocked = args.unlocked or true
    local blueprint_compat = args.blueprint_compat or false
    local eternal_compat = args.eternal_compat or false
    local no_pool_flag = args.no_pool_flag or nil
    local yes_pool_flag = args.yes_pool_flag or nil
    local unlock_condition = args.unlock_condition or nil
    local alerted = args.alerted or true
    local loc_vars = args.loc_vars or function(_) return {} end

    --joker object
    local newJoker = {
        balamod = {
            mod_id = mod_id,
            key = id,
            asset_key = mod_id .. "_" .. id
        },
        order = order,
        discovered = discovered,
        cost = cost,
        consumeable = false,
        name = name,
        pos = pos,
        set = "Joker",
        effect = "",
        cost_mult = 1.0,
        config = config,
        key = id, 
        rarity = rarity, 
        unlocked = unlocked,
        blueprint_compat = blueprint_compat,
        eternal_compat = eternal_compat,
        no_pool_flag = no_pool_flag,
        yes_pool_flag = yes_pool_flag,
        unlock_condition = unlock_condition,
        alerted = alerted,
    }

    --add it to all the game tables
    table.insert(G.P_CENTER_POOLS["Joker"], newJoker)
    table.insert(G.P_JOKER_RARITY_POOLS[rarity], newJoker)
    G.P_CENTERS[id] = newJoker

    --add name + description to the localization object
    local newJokerText = {name=name, text=desc, text_parsed={}, name_parsed={}}
    for _, line in ipairs(desc) do
        newJokerText.text_parsed[#newJokerText.text_parsed+1] = loc_parse_string(line)
    end
    for _, line in ipairs(type(newJokerText.name) == 'table' and newJokerText.name or {newJoker.name}) do
        newJokerText.name_parsed[#newJokerText.name_parsed+1] = loc_parse_string(line)
    end
    G.localization.descriptions.Joker[id] = newJokerText

    --add joker effect to game
    table.insert(joker.jokerEffects, use_effect)

    --add joker loc vars to the game
    joker.loc_vars[id] = loc_vars

    --save indices for removal
    joker.jokers[id] = {
        pool_indices={#G.P_CENTER_POOLS["Joker"], #G.P_JOKER_RARITY_POOLS[rarity]}, 
        use_indices={#joker.jokerEffects},
    }
    return newJoker, newJokerText
end

local function remove(id)
    local rarity = G.P_CENTERS[id].rarity
    G.P_CENTER_POOLS['Joker'][joker.jokers[id].pool_indices[1]] = nil
    G.P_JOKER_RARITY_POOLS[rarity][joker.jokers[id].pool_indices[2]] = nil
    G.P_CENTERS[id] = nil
    G.localization.descriptions.Joker[id] = nil
    joker.jokerEffects[joker.jokers[id].use_indices[1]] = nil
    joker.jokers[id] = nil
end
local function getJokers()
    return jokerAPI.jokers
end

_MODULE.add = add
_MODULE.remove = remove
_MODULE.getJokers = getJokers

local _MODULE = {
    _VERSION = "0.1.0"
    JOKER_API = jokerAPI
}

return _MODULE