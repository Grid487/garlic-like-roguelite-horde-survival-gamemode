if CLIENT then return end

FROZE_GL = FROZE_GL or {}
--
local gl = "garlic_like_"
local rh = "relic_held_"
--
--* CONVARS
do 
    CreateConVar(gl .. "debug_allow_leveling_outside_of_match", 0, FCVAR_ARCHIVE, "", 0, 1)
end
--* NETWORKING AND GLOBALS
do
    util.AddNetworkString(gl .. "xp_gained")
    util.AddNetworkString(gl .. "update_ply_info")
    util.AddNetworkString(gl .. "chose_upgrade")
    util.AddNetworkString(gl .. "enemy_upgrade_broadcast")
    util.AddNetworkString(gl .. "update_skills_held_table")
    util.AddNetworkString(gl .. "choose_weapon")
    util.AddNetworkString(gl .. "open_weapon_crate")
    util.AddNetworkString(gl .. "cooldown_speed_increase")
    util.AddNetworkString(gl .. "cooldowns_update") 
    util.AddNetworkString(gl .. "broadcast_particles") 

    util.AddNetworkString(gl .. "show_gold_popup_sv_to_cl")
    util.AddNetworkString(gl .. "update_database_sv_to_cl")
    util.AddNetworkString(gl .. "update_unlockables_sv_to_cl")
    util.AddNetworkString(gl .. "run_console_command_sv_to_cl") 
    util.AddNetworkString(gl .. "reset_unlockables_sv_to_cl") 
    util.AddNetworkString(gl .. "send_match_stats_sv_to_cl") 
    util.AddNetworkString(gl .. "send_damage_numbers_sv_to_cl") 
    util.AddNetworkString(gl .. "send_chat_message_sv_to_cl") 
    util.AddNetworkString(gl .. "update_tbl_valid_wep_sv_to_cl") 

    util.AddNetworkString(gl .. "update_gold_from_anim_cl_to_sv")
    util.AddNetworkString(gl .. "pause_game_cl_to_sv") 
    util.AddNetworkString(gl .. "update_database_cl_to_sv")
    util.AddNetworkString(gl .. "send_give_item_cl_to_sv")
    util.AddNetworkString(gl .. "update_rank_cl_to_sv")
    util.AddNetworkString(gl .. "reset_cl") 
    --
    SetGlobalInt(gl .. "enemy_kills", 0)
    SetGlobalInt(gl .. "minutes", 0)
    SetGlobalInt(gl .. "seconds", 0)
    SetGlobalInt(gl .. "breaktime_seconds", 0)
    SetGlobalInt(gl .. "skip_break_voters", 0)
    SetGlobalInt(gl .. "wep_power_limit", 10000)
    SetGlobalFloat(gl .. "enemy_modifier_hp", 0)
    SetGlobalFloat(gl .. "enemy_modifier_damage", 0)
    SetGlobalFloat(gl .. "enemy_modifier_resistance", 0)
    SetGlobalFloat(gl .. "enemy_modifier_evasion", 0)
    SetGlobalBool(gl .. "match_running", false)
    SetGlobalBool(gl .. "is_breaktime", false)
    SetGlobalBool(gl .. "stop_enemy_spawns", false)
    SetGlobalBool(gl .. "show_end_screen", false)
end
-- 
--! OPTIMIZE "ENEMY EMPOWERED" TEXT!!!
--* VARIABLES
do
    FROZE_GL.break_time_cur_min = 0
    FROZE_GL.spawned_enemies = {} 
    FROZE_GL.tbl_used_enemy_preset = {}
    FROZE_GL.enemy_preset_max_weight = 0
    FROZE_GL.timer_count = 0
    FROZE_GL.delay_timer = 0
    FROZE_GL.delay_ply = 0
    FROZE_GL.delay_rapid = 0
    FROZE_GL.delay_enemies = 0
    FROZE_GL.rarity_starting_num = 1
    FROZE_GL.rarity_weights_sum = 0
    FROZE_GL.nav_areas = nil 
    FROZE_GL.global_enemy_hp_modifier_stacks = 0  
    FROZE_GL.wep_power_inc = 1000
    FROZE_GL.wep_power_inc_num = 1
    FROZE_GL.tbl_non_ore_mats = {"reroll_crystal", "element_crystal", "crate_key"}
    FROZE_GL.rarity_weights = {
        ["poor"] = {
            min = 0,
            max = 0,
            weight = 640
        },
        ["common"] = {
            min = 0,
            max = 0,
            weight = 640
        },
        ["uncommon"] = {
            min = 0,
            max = 0,
            weight = 320
        },
        ["rare"] = {
            min = 0,
            max = 0,
            weight = 160
        },
        ["epic"] = {
            min = 0,
            max = 0,
            weight = 80
        },
        ["legendary"] = {
            min = 0,
            max = 0,
            weight = 40
        },
        ["god"] = {
            min = 0,
            max = 0,
            weight = 20
        }
    }
    FROZE_GL.ammo_boxes = {
        [1] = "item_ammo_pistol",
        [2] = "item_ammo_smg1",
        [3] = "item_box_buckshot",
        [4] = "item_ammo_357",
        [5] = "item_ammo_ar2",
    } 
    FROZE_GL.tbl_repeated_dmg = {
        [876522] = "fire",
        [876523] = "poison",
        [876524] = "lightning",
        [884251] = "multi hit",
    }
    FROZE_GL.tbl_temp_gem_drops = {} 
    FROZE_GL.gun_bonuses = {} 
    FROZE_GL.tbl_elements = {
        [1] = "fire",
        [2] = "poison",
        [3] = "lightning",
    }
    FROZE_GL.tbl_presets = {}
    FROZE_GL.arcw_atts_init = false
    FROZE_GL.tbl_arccw_atts = {}
end
 
for k, bonus in ipairs(FROZE_GL.tbl_bonuses_weapons) do 
    table.insert(FROZE_GL.gun_bonuses, 1, bonus.name)
end
 
cvars.AddChangeCallback(gl .. "enable", function(name, old, new) end)

local function IsNumBetween(x, min, max)
    return x >= min and x <= max
end

local function create_rarity_weights()
    for k, entry in SortedPairs(FROZE_GL.rarity_weights) do
        entry.min = FROZE_GL.rarity_starting_num
        entry.max = FROZE_GL.rarity_starting_num + entry.weight
        FROZE_GL.rarity_starting_num = FROZE_GL.rarity_starting_num + entry.weight
    end

    for k, entry in pairs(FROZE_GL.rarity_weights) do
        FROZE_GL.rarity_weights_sum = FROZE_GL.rarity_weights_sum + entry.weight
    end
end

function garlic_like_unlock(ply, id, unlock_text) 
    ply:SetPData(id .. "_unlocked", true)
 
    net.Start(gl .. "run_console_command_sv_to_cl")
    net.WriteString(gl .. "debug_show_achievement_unlock")
    net.WriteString(unlock_text)             
    net.Send(ply)

    net.Start(gl .. "update_unlockables_sv_to_cl")
    net.WriteString(id)             
    net.Send(ply)
end

function garlic_like_print_stats(ply)
    -- print("STR: " .. ply:GetNWInt(gl .. "STR", 1))
    -- print("AGI: " .. ply:GetNWInt(gl .. "AGI", 1))
    -- print("INT: " .. ply:GetNWInt(gl .. "INT", 1))
end

function garlic_like_upgrade_str(ply, STR, statboost_num)
    local STR = ply:GetNWInt(gl .. "STR", 1)
    ply:SetNWInt(gl .. "STR", STR - ply.STR_BOOST)
    ply:SetNWInt(gl .. "STR", ply:GetNWInt(gl .. "STR", 1) + statboost_num)
    STR = ply:GetNWInt(gl .. "STR", 1)
    ply.STR_BOOST = math.Round(STR * ply:GetNWFloat(gl .. "bonus_stat_mult_crystal", 1) - STR)
    ply:SetNWInt(gl .. "STR", STR + ply.STR_BOOST)
    STR = ply:GetNWInt(gl .. "STR", 1)

    if ply.old_hp_boost == nil then
        ply.old_hp_boost = 0
    end

    ply.hp_boost = math.Round(math.max(0, STR * 6 + tonumber(ply:GetPData(gl .. "hp_boost_base", 0))) * ply:GetNWFloat(gl .. "bonus_hp_boost_mult", 1))

    if ply.hp_boost > ply.old_hp_boost then
        ply:SetMaxHealth(ply:GetMaxHealth() + (ply.hp_boost - ply.old_hp_boost))
    end

    ply.old_hp_boost = ply.hp_boost
    ply:SetNWInt(gl .. "hp_boost", ply.hp_boost)
    ply:SetNWFloat(gl .. "max_overheal", 1.5 + STR * 0.012 + tonumber(ply:GetPData(gl .. "max_overheal_base", 0))) 
    ply:SetNWFloat(gl .. "bonus_damage", (STR * 0.009 + tonumber(ply:GetPData(gl .. "bonus_damage_base", 0))) * ply:GetNWFloat(gl .. "bonus_damage_mult", 1) * ply:GetNWFloat(gl .. "powerup_InstaKill", 1))
    ply:SetNWFloat(gl .. "bonus_block_resistance", math.min(0.75, STR * 0.015 + tonumber(ply:GetPData(gl .. "bonus_block_resistance_base", 0))))
    ply:SetNWInt(gl .. "bonus_hp_regen", math.Round(math.max(1, 1 + (STR / 40) * 3 + tonumber(ply:GetPData(gl .. "bonus_hp_regen_base", 0)))))
    ply:SetNWFloat(gl .. "bonus_critical_damage", (0.5 + STR * 0.045 + tonumber(ply:GetPData(gl .. "bonus_critical_damage_base", 0))) * (1 + ply:GetNWFloat(gl .. rh .. "hawkeye_sight_mul_2", 1)))

    if not garlic_like_ply_unlocked(ply, "bonus_starting_str") and ply:GetNWInt(gl .. "STR", 1) >= 40 then 
        garlic_like_unlock(ply, gl .. "bonus_starting_str", "Starting STR Upgrade")
    end
end

function garlic_like_upgrade_agi(ply, AGI, statboost_num)
    local AGI = ply:GetNWInt(gl .. "AGI", 1)
    ply:SetNWInt(gl .. "AGI", AGI - ply.AGI_BOOST)
    ply:SetNWInt(gl .. "AGI", ply:GetNWInt(gl .. "AGI", 1) + statboost_num)
    AGI = ply:GetNWInt(gl .. "AGI", 1)
    ply.AGI_BOOST = math.Round(AGI * ply:GetNWFloat(gl .. "bonus_stat_mult_crystal", 1) - AGI)
    ply:SetNWInt(gl .. "AGI", AGI + ply.AGI_BOOST)
    AGI = ply:GetNWInt(gl .. "AGI", 1)
    
    ply:SetNWFloat(gl .. "bonus_resistance", math.min(0.95, AGI * 0.0075 + tonumber(ply:GetPData(gl .. "bonus_resistance_base", 0))))
    ply:SetNWInt(gl .. "bonus_resistance_flat", math.max(0, math.floor(AGI / 5) + tonumber(ply:GetPData(gl .. "bonus_resistance_flat_base", 0))))
    ply:SetNWFloat(gl .. "bonus_block_chance", math.min(1, AGI * 0.006 + tonumber(ply:GetPData(gl .. "bonus_block_chance_base", 0))))
    ply:SetNWFloat(gl .. "bonus_evasion_chance", math.min(0.5, AGI * 0.0045 + tonumber(ply:GetPData(gl .. "bonus_evasion_chance_base", 0))))
    ply:SetNWFloat(gl .. "bonus_critical_chance", (AGI * 0.007 + tonumber(ply:GetPData(gl .. "bonus_critical_chance_base", 0))) * ply:GetNWFloat(gl .. "bonus_critical_chance_mult", 1))
    ply:SetNWFloat(gl .. "bonus_multihit_chance", math.min(5, AGI * 0.015 + tonumber(ply:GetPData(gl .. "bonus_multihit_chance_base", 0))))
    ply:SetNWFloat(gl .. "bonus_accuracy", math.min(10, (1 + AGI * 0.004) + tonumber(ply:GetPData(gl .. "bonus_accuracy_base", 0))))

    if not garlic_like_ply_unlocked(ply, "bonus_starting_agi") and ply:GetNWInt(gl .. "AGI", 1) >= 40 then 
        garlic_like_unlock(ply, gl .. "bonus_starting_agi", "Starting AGI Upgrade")
    end
end

function garlic_like_upgrade_int(ply, INT, statboost_num)
    local INT = ply:GetNWInt(gl .. "INT", 1)
    ply:SetNWInt(gl .. "INT", INT - ply.INT_BOOST)
    ply:SetNWInt(gl .. "INT", ply:GetNWInt(gl .. "INT", 1) + statboost_num)
    INT = ply:GetNWInt(gl .. "INT", 1)
    ply.INT_BOOST = math.Round(INT * ply:GetNWFloat(gl .. "bonus_stat_mult_crystal", 1) - INT)
    ply:SetNWInt(gl .. "INT", INT + ply.INT_BOOST)
    INT = ply:GetNWInt(gl .. "INT", 1)
    mana_regen = ply:GetNWInt(gl .. "mana_regen", 1)
    max_mana = ply:GetNWInt(gl .. "max_mana") + tonumber(ply:GetPData(gl .. "max_mana_base", 0))
    mana_boost = math.max(0, statboost_num * 2)
    mana_regen_boost = math.max(1, 1 + math.floor(INT / 50) + tonumber(ply:GetPData(gl .. "mana_regen_base", 0)))

    ply:SetNWInt(gl .. "max_mana", max_mana + mana_boost)
    ply:SetNWInt(gl .. "mana_regen", mana_regen_boost)
    ply:SetNWFloat(gl .. "bonus_mana_damage", math.max(0, INT * 0.03 + tonumber(ply:GetPData(gl .. "bonus_mana_damage_base", 0))))
    ply:SetNWFloat(gl .. "bonus_mana_resistance", math.min(0.85, INT * 0.015 + tonumber(ply:GetPData(gl .. "bonus_mana_resistance_base", 0))))
    ply:SetNWFloat(gl .. "bonus_xp_gain", (1 + ((INT * 0.0015 + tonumber(ply:GetPData(gl .. "bonus_xp_gain_base", 0))) * ply:GetNWFloat(gl .. "bonus_xp_mult", 1))) * ply:GetNWFloat(gl .. "powerup_DoublePoints", 1))
    ply:SetNWFloat(gl .. "bonus_cooldown_mult", math.max(0.1, (1 - INT * 0.0035 - tonumber(ply:GetPData(gl .. "bonus_cooldown_mult_base", 0))) / ply:GetNWFloat(gl .. "powerup_FullPower", 1)))
    --
    ply.cdr_torrent = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_torrent, "dota2_auto_cast_torrent_delay", "torrent")
    ply.cdr_lightning_bolt = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_lightning_bolt, "dota2_auto_cast_lightning_bolt_delay", "lightning_bolt")
    ply.cdr_diabolic_edict = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_diabolic_edict, "dota2_auto_cast_diabolic_edict_delay", "diabolic_edict")
    ply.cdr_magic_missile = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_magic_missile, "dota2_auto_cast_magic_missile_delay", "magic_missile")
 
    timer.Simple(0.1, function()
        local skills = {
            [1] = {
                name = "diabolic_edict",
                cooldown = GetConVar("dota2_auto_cast_diabolic_edict_delay"):GetFloat()
            },
            [2] = {
                name = "lightning_bolt",
                cooldown = GetConVar("dota2_auto_cast_lightning_bolt_delay"):GetFloat()
            },
            [3] = {
                name = "magic_missile",
                cooldown = GetConVar("dota2_auto_cast_magic_missile_delay"):GetFloat()
            },
            [4] = {
                name = "torrent",
                cooldown = GetConVar("dota2_auto_cast_torrent_delay"):GetFloat()
            },
        }

        net.Start(gl .. "cooldowns_update")
        net.WriteTable(skills)
        net.Send(ply)
    end)

    if not garlic_like_ply_unlocked(ply, "bonus_starting_int") and ply:GetNWInt(gl .. "INT", 1) >= 40 then 
        garlic_like_unlock(ply, gl .. "bonus_starting_int", "Starting INT Upgrade")
    end
end

function garlic_like_reduce_auto_cast_cooldown(ply, cdr_temp, convar, name)    
    if not cdr_temp then return end
    if not IsValid(ply) then return end
    -- print("RAN auto_cast_cooldown reduction fubnction!!!!!")
    auto_cast_cooldown = GetConVar(convar):GetFloat() + cdr_temp -- this returns the cooldown value to it's original value so we can use it as a base value
    cdr_temp = math.Truncate(auto_cast_cooldown * (1 - ply:GetNWFloat(gl .. "bonus_cooldown_mult")) * ply:GetNWFloat(gl .. ply:GetActiveWeapon():GetClass() .. "cooldown_speed", 1), 2) -- creates the coldown reduction amount value
    -- print("cdr_temp " .. cdr_temp)
    auto_cast_cooldown = auto_cast_cooldown - cdr_temp -- reduces the base cooldown with the reduction amount value
    ply:ConCommand(convar .. " " .. tostring(auto_cast_cooldown)) -- changes the console command that controls the cast delay

    net.Start(gl .. "update_skills_held_table") -- updates the clientside stored cooldown value with the updated one
    net.WriteString(name)
    net.WriteFloat(GetConVar(convar):GetFloat())
    net.Send(ply)

    return cdr_temp
end

function garlic_like_xp_gain(ply, xp_amount, xp_type)
    -- print("xp amount: " .. xp_amount)
    net.Start(gl .. "xp_gained")
    net.WriteInt(xp_amount, 32)
    net.WriteString(xp_type)
    net.Send(ply)
end

function garlic_like_update_database(ply, name, number, upgrades_table)
    if name ~= "" or name == nil then
        ply:SetNWInt(gl .. name, ply:GetNWInt(gl .. name) + number)
        ply:SetPData(gl .. "database_" .. name, ply:GetNWInt(gl .. name, 0))
    end

    if upgrades_table ~= nil then end -- ply:SetPData(gl .. "upgrades_PData", upgrades_table)   -- PrintTable(upgrades_table)
end

function garlic_like_reset_stats(ply)
    RunConsoleCommand("dota2_reset")
    RunConsoleCommand("dota2_reset_cl")
    RunConsoleCommand("dota2_cooldown_diabolic_edict", "0")
    RunConsoleCommand("dota2_cooldown_lightning_bolt", "0")
    RunConsoleCommand("dota2_cooldown_torrent", "0")
    RunConsoleCommand("garlic_like_enable_timer", "0")
    -- GLOBALS
    SetGlobalInt(gl .. "enemy_kills", 0)
    SetGlobalInt(gl .. "minutes", 0)
    SetGlobalInt(gl .. "seconds", 0)
    SetGlobalInt(gl .. "breaktime_seconds", 0)
    SetGlobalInt(gl .. "skip_break_voters", 0)
    SetGlobalInt(gl .. "wep_power_limit", 10000)
    SetGlobalFloat(gl .. "enemy_modifier_hp", 0)
    SetGlobalFloat(gl .. "enemy_modifier_damage", 0)
    SetGlobalFloat(gl .. "enemy_modifier_resistance", 0)
    SetGlobalFloat(gl .. "enemy_modifier_evasion", 0)
    SetGlobalBool(gl .. "match_running", false)
    SetGlobalBool(gl .. "is_breaktime", false)
    SetGlobalBool(gl .. "stop_enemy_spawns", false)
    SetGlobalBool(gl .. "show_end_screen", false)

    FROZE_GL.delay_enemies = 0
    FROZE_GL.delay_ply = 0
    FROZE_GL.delay_rapid = 0
    FROZE_GL.delay_timer = 0
    FROZE_GL.global_enemy_hp_modifier_stacks = 0
    --
    ply:SetMaxHealth(100)
    --
    ply:SetNWInt(gl .. "level", 1)
    ply:SetNWInt(gl .. "xp_total", 0)
    ply:SetNWInt(gl .. "xp_to_next_level", 100)
    --
    ply.STR_BOOST = 0
    ply.AGI_BOOST = 0
    ply.INT_BOOST = 0
    --
    ply:SetNWInt(gl .. "STR", 1)
    ply:SetNWInt(gl .. "AGI", 1)
    ply:SetNWInt(gl .. "INT", 1)
    -- STR
    ply:SetNWInt(gl .. "hp_boost", 0)
    ply:SetNWFloat(gl .. "max_overheal", 1.5)
    ply:SetNWFloat(gl .. "bonus_damage", 0)
    ply:SetNWFloat(gl .. "bonus_block_resistance", 0)
    ply.old_hp_boost = 0
    ply:SetNWInt(gl .. "bonus_hp_regen", 1)
    ply:SetNWFloat(gl .. "bonus_critical_damage", 0.25)
    -- AGI
    ply:SetNWFloat(gl .. "bonus_resistance", 0)
    ply:SetNWInt(gl .. "bonus_resistance_flat", 0)
    ply:SetNWFloat(gl .. "bonus_block_chance", 0)
    ply:SetNWFloat(gl .. "bonus_evasion_chance", 0)
    ply:SetNWFloat(gl .. "bonus_multihit_chance", 0)
    ply:SetNWFloat(gl .. "bonus_critical_chance", 0)
    ply:SetNWFloat(gl .. "bonus_accuracy", 1)
    -- INT
    ply:SetNWInt(gl .. "mana", 100)
    ply:SetNWInt(gl .. "max_mana", 100)
    ply:SetNWInt(gl .. "mana_regen", 1)
    ply:SetNWFloat(gl .. "bonus_mana_damage", 0.1)
    ply:SetNWFloat(gl .. "bonus_mana_resistance", 0.05)
    ply:SetNWFloat(gl .. "bonus_xp_gain", 1)
    ply:SetNWFloat(gl .. "bonus_cooldown_mult", 1)
    ply.cdr_torrent = 0
    ply.cdr_diabolic_edict = 0
    ply.cdr_lightning_bolt = 0
    ply.cdr_magic_missile = 0
    -- ITEM STATBOOSTS
    ply:SetNWFloat(gl .. "bonus_stat_mult_crystal", 1)
    ply:SetNWFloat(gl .. "bonus_damage_mult", 1)
    ply:SetNWFloat(gl .. "bonus_xp_mult", 1)
    ply:SetNWFloat(gl .. "bonus_hp_boost_mult", 1)
    ply:SetNWFloat(gl .. "bonus_armor", 0)
    ply:SetNWFloat(gl .. "bonus_shield", 0)
    ply:SetNWFloat(gl .. "bonus_critical_chance_mult", 1)
    garlic_like_print_stats(ply)
    -- RELICS 
    for k, data in pairs(FROZE_GL.garlic_like_upgrades) do 
        if data.upgrade_type == "relic" then 
            ply:SetNWBool(gl .. rh .. data.name2, false) 
            ply:SetNWFloat(gl .. rh .. data.name2 .. "_mul", 0)
            ply:SetNWFloat(gl .. rh .. data.name2 .. "_mul_2", 0)
        end
    end 

    -- WIPE MATERIALS?
    for k, v in pairs(FROZE_GL.tbl_materials_inventory) do 
        -- ply:SetPData(gl .. "held_num_material_" .. k, 0)
        -- ply:SetNWInt(gl .. "held_num_material_" .. k, 0)
    end

    if timer.Exists(gl .. "breaktime_timer") then 
        timer.Remove(gl .. "breaktime_timer")
    end

    --BREAK 
    ply:SetNWBool(gl .. "voted_skip_break", false)
    -- DASH
    ply:SetNWBool(gl .. "dash_available", true)
    -- ULT
    ply:SetNWBool(gl .. "is_using_tf2_ult", false)
    -- ON DEATH
    ply:SetNWInt(gl .. "death_count", 0)
    ply.gl_mga = 0
    ply.gl_tdd = 0
    ply.gl_tdt = 0
    ply.gl_hdd = 0
    ply.gl_rxpg = 0
    -- RESET TABLE(S)
    ply.gl_stored_bonused_weapons = {}
    -- SAVED DATA
    ply:SetNWInt(gl .. "money", ply:GetPData(gl .. "database_money", 0))
    -- CLIENT RESET CALL 
    net.Start(gl .. "reset_cl")
    net.Send(ply)
    --
    -- garlic_like_upgrade_str(ply, ply:GetNWInt(gl .. "STR"), 155)
    -- garlic_like_upgrade_agi(ply, ply:GetNWInt(gl .. "AGI"), 155)
    -- garlic_like_upgrade_int(ply, ply:GetNWInt(gl .. "INT"), 155)
end

function garlic_like_get_nearby_point(ply) 
    if not ply or not ply:IsPlayer() then 
        ply = table.Random(player.GetAll())
    end  

    local ply_pos = ply:GetPos()

    if not FROZE_GL.nav_areas then 
        FROZE_GL.nav_areas = navmesh.GetAllNavAreas() 
    end 

    local filtered_pos_min = {}
    local filtered_pos_max = {}
    local final_areas = {}
    -- PrintTable(FROZE_GL.nav_areas)

    filtered_pos_min = navmesh.Find(ply_pos, 1000, 200, 200)
    filtered_pos_max = navmesh.Find(ply_pos, 4000, 200, 200) 

    -- PrintTable(filtered_pos_min)
    -- PrintTable(filtered_pos_max)
    
    for k, area in pairs(filtered_pos_max) do 
        if not table.HasValue(filtered_pos_min, area) then 
            table.insert(final_areas, #final_areas, area)
        end
    end

    -- print("FINAL POINTS: ")
    -- PrintTable(final_areas)
    
    local chosen_area = final_areas[math.random(1, #final_areas)]

    local loop_num = 0 

    if not chosen_area then print("NAVMESH AREA FOR SPAWNING NOT FOUND!") return end

    -- print("SUCCESFULLY FOUND A SPAWNING POINT FOR THE ENEMY!")

    local point = chosen_area:GetRandomPoint() 

    local loop_num = 0

    while ply:GetPos():Distance(point) < 1000 do
        loop_num = loop_num + 1 
        if loop_num > 5 then print("NO POINT FOUND FURTHER AWAY") break end 
        print("POINT TOO CLOSE, LOOPING TO FIND FURTHER")
        point = chosen_area:GetRandomPoint()
    end
 
    print("FOUND SPAWNPOINT 1000 UNITS AWAY")

    return point 
end

function garlic_like_spawn_ent(ply, spawn_class_override)  
    if #FROZE_GL.spawned_enemies > GetConVar(gl .. "max_enemies_spawned"):GetInt() then return end
    --
    local ply_pos = ply:GetPos() 
    local point = garlic_like_get_nearby_point(ply) 
    local loop_num = 0
     
    -- print(point)
    local enemy_class = "npc_zombie" 
    local random_number = math.random(1, FROZE_GL.enemy_preset_max_weight)

    -- PrintTable(FROZE_GL.tbl_used_enemy_preset)

    local function get_enemy_class()
        for k, v in pairs(FROZE_GL.tbl_used_enemy_preset) do 
            if IsNumBetween(random_number, v.weight_min, v.weight_max) then 
                -- PrintTable(v) 
                return v.class
            end
        end
    end

    enemy_class = get_enemy_class()

    local loop_num = 0

    repeat
        enemy_class = get_enemy_class()
        loop_num = loop_num + 1
        if loop_num > 50 then print("LOOP EXCEED") return end
    until ((enemy_class and enemy_class ~= "npc_zombie"))

    if not enemy_class then enemy_class = "npc_zombie" end 

    if spawn_class_override ~= "enemy" then 
        enemy_class = spawn_class_override
    end

    -- print("ENEMY CLASS IS: " .. enemy_class) 
    if not point then print("NO POINT FOUND!") return end
 
    local enemy = ents.Create(enemy_class)
    enemy:Spawn()
    enemy:SetPos(point)
    enemy:SetNWBool(gl .. "is_spawned_enemy", true)

    -- print("ENEMY SUCCESSFULLY SPAWNED!")

    if spawn_class_override == "enemy" then 
        table.insert(FROZE_GL.spawned_enemies, enemy) 
    end

    return enemy
end

function garlic_like_enemy_shield_recharge(ent)
    timer.Create(gl .. "enemy_shield_recharging_" .. ent:EntIndex(), 0, 100, function()
        if not ent.enemy_is_able_to_recharge or ent:GetNWInt(gl .. "enemy_shield") >= ent:GetNWInt(gl .. "enemy_shield_max") then return end
        ent:SetNWInt(gl .. "enemy_shield", math.min(ent:GetNWInt(gl .. "enemy_shield_max"), ent:GetNWInt(gl .. "enemy_shield") + ent:GetNWInt(gl .. "enemy_shield_max") * 0.01))
    end)
end

function garlic_like_reset_gun_bonuses(ply, weapon_name) 
    for k, element in pairs(FROZE_GL.tbl_elements) do
        ply:SetNWBool(gl .. weapon_name .. element, false)
    end

    for k, bonus in pairs(FROZE_GL.gun_bonuses) do
        ply:SetNWFloat(gl .. weapon_name .. bonus, 1)
    end
end 

function garlic_like_attach_particle(target, operation, particle_name)
    net.Start(gl .. "broadcast_particles")
    net.WriteEntity(target)
    net.WriteString(operation)
    net.WriteString(particle_name)
    net.Broadcast()
end

function garlic_like_proc_fire(attacker, target, damage_amount) 
    -- print("PROC FIRE")
    if not attacker:IsPlayer() and not target:IsPlayer() then return end

    if not target.gl_fire_ignited then 
        target.gl_fire_ignited = true
        garlic_like_attach_particle(target, "ATTACH", "huskar_burning_spear_debuff")  
    end

    if not target.gl_fire_num_hits then 
        target.gl_fire_num_hits = 0
        target.gl_fire_total_dmg = 0
    end

    if target.gl_fire_highest_damage_taken and damage_amount > target.gl_fire_highest_damage_taken then 
        target.gl_fire_highest_damage_taken = damage_amount
    end

    if not target.gl_fire_dont_take_last_damage then 
        target.gl_fire_highest_damage_taken = damage_amount
    end

    target.gl_fire_dont_take_last_damage = false            
    
    if not target.gl_fire_average_dmg_temp then 
        target.gl_fire_average_dmg_temp = 0
    end

    if target.gl_fire_average_dmg and target.gl_fire_average_dmg_temp <= target.gl_fire_average_dmg then 
        target.gl_fire_average_dmg_temp = target.gl_fire_average_dmg       
    end

    target.gl_fire_num_hits = target.gl_fire_num_hits + 1
    target.gl_fire_total_dmg = target.gl_fire_total_dmg + damage_amount
    target.gl_fire_average_dmg = math.Round(target.gl_fire_total_dmg / target.gl_fire_num_hits)

    if target.gl_fire_average_dmg_temp > target.gl_fire_average_dmg then  
        target.gl_fire_average_dmg = target.gl_fire_average_dmg_temp
    end 

    local function ignite() 
        if not IsValid(target) then return end     
        local repsleft = timer.RepsLeft(gl .. "ignited_" .. target:EntIndex())                      
        
        if not target.gl_fire_hit_count then 
            target.gl_fire_hit_count = 0
        end 

        target.gl_fire_hit_count = target.gl_fire_hit_count + 1

        if not target.gl_fire_final_dmg then 
            target.gl_fire_final_dmg = 0
        end

        target.gl_fire_final_dmg = math.max(10, target.gl_fire_average_dmg) 
        local dmg_max = math.Round((target.gl_fire_final_dmg + math.ceil(target:Health() * 0.01))^(1 + target.gl_ignite_reps_left / 4 * 0.01))
        local dmg_min = target.gl_fire_highest_damage_taken * 5
        local final_dmg = math.min(dmg_min, dmg_max) 
        print("damage_max " .. dmg_max)
        print("dmg_min " .. dmg_min)
        print("final_dmg " .. final_dmg)
        print("target.gl_fire_hit_count " .. target.gl_fire_hit_count)
        print("target.gl_ignite_reps_left " .. target.gl_ignite_reps_left)

        if not IsValid(attacker) then 
            attacker = Entity(0)
        end 

        local damage_fire = DamageInfo() 
        damage_fire:SetDamage(final_dmg) 
        damage_fire:SetAttacker(attacker)
        damage_fire:SetInflictor(attacker) 
        damage_fire:SetDamageType(DMG_BURN) 
        damage_fire:SetMaxDamage(876522)
        --
        target:TakeDamageInfo(damage_fire) 

        if not target.gl_fire_dmg_dealt_reduced_mod then 
            target.gl_fire_dmg_dealt_reduced_mod = 0.2
        end

        target.gl_fire_dmg_dealt_reduced_mod = math.min(0.85, target.gl_fire_dmg_dealt_reduced_mod + 0.01)
        -- print(timer.RepsLeft(gl .. "ignited_" .. target:EntIndex()) )
        -- print(target.gl_fire_average_dmg)
        -- print("repsleft: " .. target.gl_ignite_reps_left)
  
        target.gl_ignite_reps_left = target.gl_ignite_reps_left - 1    

        -- print("target.gl_ignite_reps_left " .. target.gl_ignite_reps_left)

        timer.Adjust(gl .. "ignited_" .. target:EntIndex(), 0.25, math.min(120, target.gl_ignite_reps_left), nil) 

        if target.gl_ignite_reps_left == 0 then 
            timer.Remove(gl .. "ignited_" .. target:EntIndex())
            target.gl_ignited = false
            target.gl_fire_num_hits = 0
            target.gl_fire_total_dmg = 0
            target.gl_fire_average_dmg = 0
            target.gl_fire_hit_count = 0
            target.gl_fire_highest_damage_taken = 0
            target.gl_fire_final_dmg = 0
            target.gl_fire_dmg_dealt_reduced_mod = 0 
            --  
            target.gl_fire_ignited = false
            garlic_like_attach_particle(target, "STOP", "huskar_burning_spear_debuff")   
        end 
    end

    if target.gl_ignited then 
        local repsleft = timer.RepsLeft(gl .. "ignited_" .. target:EntIndex())   
        -- target.gl_fire_hit_count = 0  
        target.gl_ignite_reps_left = math.min(120, target.gl_ignite_reps_left + 1)

        -- target.gl_target_hit_counts = math.min(20, target.gl_target_hit_counts + 2)

        -- timer.Adjust(gl .. "ignited_" .. target:EntIndex(), 0.25, math.min(20, repsleft + 2), nil)
    end

    if not target.gl_ignited then 
        target.gl_ignited = true 
        target.gl_target_hit_counts = 20
        target.gl_ignite_reps_left = target.gl_target_hit_counts
        
        timer.Create(gl .. "ignited_" .. target:EntIndex(), 0.25, target.gl_target_hit_counts, function()
            ignite()
        end) 
    end 
end

function garlic_like_proc_lightning(ply, target, damage, ischain, dmginfo)   
    ply.gl_lightning_chain_entities = {} 
    if target.gl_lightning_cooldown_on then return end    
    if not IsValid(target) then return end 
    --
    local nearby_ents = ents.FindInSphere(target:GetPos(), 325)
    target.gl_lightning_cooldown_on = true
    --
    target.gl_lightning_chain_cooldown_on = true

    timer.Simple(1, function() 
        if not IsValid(target) then return end
        --
        target.gl_lightning_chain_cooldown_on = false
    end)

    ParticleEffect("stormspirit_overload_discharge", target:GetPos(), Angle(0, 0, 0), target)
    target:EmitSound("dota2/static_remnant_explode.wav", 100, 100, 1, CHAN_AUTO)

    if not ply.gl_lightning_damage_buff_stacks then 
        ply.gl_lightning_damage_buff_stacks = 0
    end

    ply.gl_lightning_damage_buff_stacks = math.min(37, ply.gl_lightning_damage_buff_stacks + 1)

    -- print("ply.gl_lightning_damage_buff_stacks " .. ply.gl_lightning_damage_buff_stacks)

    if not ply.gl_lightning_chain_num then 
        ply.gl_lightning_chain_num = 0
    end

    timer.Simple(12, function() 
        ply.gl_lightning_damage_buff_stacks = math.max(0, ply.gl_lightning_damage_buff_stacks - 1)
    end)

    garlic_like_attach_particle(target, "ATTACH", "stormspirit_electric_vortex_debuff") 
    target.gl_lightning_debuffed = true

    if not target.gl_lightning_debuffed_stacks then 
        target.gl_lightning_debuffed_stacks = 0
    end

    timer.Simple(1, function() 
        if not IsValid(target) then return end 
        --
        target.gl_lightning_cooldown_on = false
        target.gl_lightning_debuffed = false
        target.gl_lightning_debuffed_stacks = 0
        --
        garlic_like_attach_particle(target, "STOP", "stormspirit_electric_vortex_debuff") 
    end) 

    for k, nearby_ent in pairs(nearby_ents) do 
        if (nearby_ent:IsNPC() or nearby_ent:IsNextBot()) then   
            timer.Simple(0, function() 
                if not IsValid(nearby_ent) then return end
                local damage_lightning = DamageInfo() 
                damage_lightning:SetDamage(ply.gl_lightning_damage * damage) 
                damage_lightning:SetAttacker(ply)
                damage_lightning:SetInflictor(ply) 
                damage_lightning:SetDamageType(DMG_SHOCK) 
                damage_lightning:SetMaxDamage(876524)
                --
                nearby_ent:TakeDamageInfo(damage_lightning)            
            end)

            if math.random() <= math.max(0, 0.5 - ply.gl_lightning_chain_num * 0.1) and not ischain and #ply.gl_lightning_chain_entities <= 3 and target ~= nearby_ent then 
                table.insert(ply.gl_lightning_chain_entities, nearby_ent)
            end
        end
    end  

    for k, chain_ent in pairs(ply.gl_lightning_chain_entities) do 
        timer.Simple(k * 0.2, function()  
            ply.gl_lightning_chain_num = ply.gl_lightning_chain_num + 1
            garlic_like_proc_lightning(ply, chain_ent, 0.75 - math.min(0.6, ply.gl_lightning_chain_num * 0.05), false)

            timer.Simple(1.25, function() 
                ply.gl_lightning_chain_num = math.max(0, ply.gl_lightning_chain_num - 1)
            end)
        end)
    end 

    ply.gl_lightning_chain_entities = {}
end

function garlic_like_proc_poison(attacker, target, damage) 
    if not attacker:IsPlayer() and not target:IsPlayer() then return end

    if not target.gl_poison_dmg_total then 
        target.gl_poison_dmg_total = 0
    end

    target.gl_poison_dmg_total = target.gl_poison_dmg_total + damage * 0.75
    
    -- print(target.gl_poison_dmg_total)

    if not target.gl_poisoned then 
        target.gl_poisoned = true
        garlic_like_attach_particle(target, "ATTACH", "viper_viper_strike_debuff")    
        -- 

        timer.Create(gl .. "poisoned_" .. target:EntIndex(), 1.5, 999, function()
            if not IsValid(target) then return end 
            
            if not IsValid(attacker) then 
                attacker = Entity(0)
            end

            if target.gl_poison_dmg_total < 10 then 
                target.gl_poisoned = false
                target.gl_poison_dmg_taken_mul = 0 
                garlic_like_attach_particle(target, "STOP", "viper_viper_strike_debuff")  
                return 
            end 
            --
            local damage_poison = DamageInfo() 
            damage_poison:SetDamage(target.gl_poison_dmg_total) 
            damage_poison:SetAttacker(attacker)
            damage_poison:SetInflictor(attacker) 
            damage_poison:SetDamageType(DMG_POISON) 
            damage_poison:SetMaxDamage(876523)
            -- print("POISON ATTACKER: " .. tostring(attacker))
            --
            target:TakeDamageInfo(damage_poison)

            if not target.gl_poison_dmg_taken_mul then 
                target.gl_poison_dmg_taken_mul = 0
            end

            target.gl_poison_dmg_taken_mul = math.min(10, (target.gl_poison_dmg_taken_mul + 0.1) * 1.05)

            -- if target.gl_poison_dmg_taken_mul >= 9.5 then 
            --     print("POISON DMG MUL  MAXXED")
            -- else 
            --     print("target.gl_poison_dmg_taken_mul " .. target.gl_poison_dmg_taken_mul)
            -- end

            target.gl_poison_nearby_ents = ents.FindInSphere(target:GetPos(), 110)

            for k, nearby_ent in pairs(target.gl_poison_nearby_ents) do 
                if (nearby_ent:IsNPC() or nearby_ent:IsNextBot()) and nearby_ent ~= target then 
                    damage_poison:SetDamage(math.max(5, target.gl_poison_dmg_total * 0.5))
                    nearby_ent:TakeDamageInfo(damage_poison)
                end
            end

            target.gl_poison_dmg_total = math.Round(math.max(1, target.gl_poison_dmg_total * 0.7)) 
            ParticleEffect("viper_poison_attack_explosion", target:LocalToWorld(target:OBBCenter()), Angle(0, 0, 0), target)
            target:EmitSound("dota2/viper_impact.wav", 100, 100, 1, CHAN_AUTO)

            if i == 300 then 
                target.gl_poisoned = false
            end
        end)
    end
end

function garlic_like_create_fiery_fireball(ent) 
    if not IsValid(ent) then return end 
    if ent.HasFieryFireball then return end
    local ent_pos = ent:GetPos()
    local ent_maxs_world = ent:LocalToWorld(ent:OBBMaxs())
    local ball = ents.Create(gl .. "enemy_fireball") 
    ball:SetPos(ent_maxs_world)
    ball:SetOwner(ent) 
    ball:Spawn() 
    ent.HasFieryFireball = true
    ent:SetNWInt(gl .. "modifier_fiery_cd", CurTime() + 15)
end

function garlic_like_create_poisonball(ent) 
    if not IsValid(ent) then return end 
    if ent.HasPoisonBall then return end
    local ent_pos = ent:GetPos()
    local ent_maxs_world = ent:LocalToWorld(ent:OBBMaxs())
    local ball = ents.Create(gl .. "enemy_poisonball") 
    ball:SetPos(ent_maxs_world)
    ball:SetOwner(ent) 
    ball:Spawn() 
    ent.HasPoisonBall = true
    ent:SetNWInt(gl .. "modifier_poisonball_cd", CurTime() + 5)
end

function garlic_like_create_thunderball(ent) 
    if not IsValid(ent) then return end 
    if ent.HasThunderBall then return end
    local ent_pos = ent:GetPos()
    local ent_maxs_world = ent:LocalToWorld(ent:OBBMaxs())
    local ball = ents.Create(gl .. "enemy_thunderball") 
    ball:SetPos(ent_maxs_world)
    ball:SetOwner(ent) 
    ball:Spawn() 
    ent.HasThunderBall = true
    ent:SetNWInt(gl .. "modifier_thunderball_cd", CurTime() + 5)
end

function garlic_like_reduce_weakening_mul(ply, diff)  
    timer.Simple(6, function() 
        if not IsValid(ply) then return end 
        -- 
        ply.gl_weakened_mul = math.max(1, ply.gl_weakened_mul - diff)
    end)
end

function garlic_like_launch_entity(ent, force_mod)
    local phys = ent:GetPhysicsObject()
    ent:SetPos(ent:GetPos() + Vector(0, 0, 3))
    phys:ApplyForceCenter(ent:GetAngles():Up() * 7000 * force_mod)
    phys:ApplyForceCenter(ent:GetAngles():Right() * 2500 * math.Rand(-1, 1) * force_mod)
    phys:ApplyForceCenter(ent:GetAngles():Forward() * 1250 * math.Rand(-1, 1) * force_mod)
    ent:EmitSound("garlic_like/item_drop_sounds/item_launch.wav", 120, 100, 1, CHAN_AUTO)
end

function garlic_like_create_material_drop(ply, target, item_type, rarity, amount, mod_spawn_pos)  
    local drop = ents.Create(gl .. "wep_crystal")
    local mod_vector = Vector(0, 0, 0) 

    drop:SetNWBool(gl .. "is_" .. item_type, true)
    drop:SetNWBool(gl .. "is_non_ore_mat", false)

    for name, data in pairs(FROZE_GL.tbl_materials_inventory) do 
        if data.id == item_type then 
            drop:SetNWBool(gl .. "is_non_ore_mat", true)
        end
    end

    -- if table.HasValue(FROZE_GL.tbl_non_ore_mats, item_type) then 
    --     drop:SetNWBool(gl .. "is_non_ore_mat", true)
    -- end

    if mod_spawn_pos then 
        mod_vector = mod_spawn_pos
    end

    drop:SetOwner(ply)
    drop:SetNWString(gl .. "assigned_rarity", rarity)
    drop:SetPos(target:GetPos() + Vector(0, 0, 10) + mod_vector)
    drop:Spawn()
    drop:SetNWInt(gl .. "item_amount", amount)
    SafeRemoveEntityDelayed(drop, 90)
end

function garlic_like_check_enemy_spawn_chances() 
    for k, v in ipairs(FROZE_GL.tbl_used_enemy_preset) do 
        -- print("CLASS: " .. v.class) 
        -- print("CHANCE: " .. v.weight / FROZE_GL.enemy_preset_max_weight * 100 .. "%")
    end
end

function garlic_like_get_wep_bonus_value(ply, bonus_name) 
    return ply:GetNWFloat(gl .. ply:GetActiveWeapon():GetClass() .. bonus_name, 1)
end

function garlic_like_create_damage_number(ply, ent, dmg)  
    if (ent:IsNPC() or ent:IsNextBot()) then 
        local ent_pos = ent:GetPos()
        local ent_obbcenter = ent:LocalToWorld(ent:OBBCenter()) 
        local ent_obbmaxs = ent:LocalToWorld(ent:OBBMaxs()) 
        local ent_damagenumber_pos = Vector(ent_obbcenter.x, ent_obbcenter.y, ent_obbmaxs.z + 10)

        local dmg_amount
        local dmg_maxdamage
        local dmg_damagecustom

        -- print(tostring(ply))

        -- print(ent:Health())

        if dmg and not isnumber(dmg) then 
            dmg_amount = dmg:GetDamage()
            dmg_maxdamage = dmg:GetMaxDamage()
            dmg_damagecustom = dmg:GetDamageCustom()
        else 
            dmg_amount = ent:Health() 
            dmg_maxdamage = 1
            dmg_damagecustom = 1
        end

        print("dmg_amount: " .. dmg_amount)
        print("dmg_damagecustom: " .. dmg_damagecustom)

        if dmg_amount > 0 or dmg_damagecustom == 1853 then 
            print("send dmg number froms v to cl")
            net.Start(gl .. "send_damage_numbers_sv_to_cl") 
            net.WriteVector(ent_damagenumber_pos)
            net.WriteInt(dmg_amount, 32)
            net.WriteEntity(ent)
            net.WriteInt(dmg_maxdamage, 32)
            net.WriteInt(dmg_damagecustom, 32)
            net.Send(ply)
        end
    end
end

net.Receive(gl .. "update_rank_cl_to_sv", function(len, ply) 
    local rank_num = net.ReadInt(32) 
    local rank_xp_current = net.ReadInt(32)
    local rank_xp_to_rank_up = net.ReadInt(32)
    ply:SetPData(gl .. "rank_num", rank_num)
    ply:SetPData(gl .. "rank_xp_current", rank_xp_current)
    ply:SetPData(gl .. "rank_xp_to_rank_up", rank_xp_to_rank_up)
end)

net.Receive(gl .. "pause_game_cl_to_sv", function(len, ply)

    if game.GetTimeScale() > 0 then 
        -- print("PAUSE !!!")
        game.SetTimeScale(0)
    else 
        -- print("UN-PAUSE !!!")
        game.SetTimeScale(1)
    end
end)

net.Receive(gl .. "update_ply_info", function(len, ply)
    --* level up
    local ply = net.ReadEntity()
    local level = net.ReadInt(32)
    local xp_to_next_level = net.ReadInt(32)
    ply:SetNWInt(gl .. "level", level)
    ply:SetNWInt(gl .. "xp_to_next_level", xp_to_next_level)

    garlic_like_upgrade_str(ply, nil, 1)
    garlic_like_upgrade_agi(ply, nil, 1)
    garlic_like_upgrade_int(ply, nil, 1)

    if not garlic_like_ply_unlocked(ply, "bonus_xp_gain") and level >= 30 then 
        garlic_like_unlock(ply, gl .. "bonus_xp_gain", "XP Gain Upgrade")
    end

    if not garlic_like_ply_unlocked(ply, "relic_slot_7") and level >= 50 then 
        garlic_like_unlock(ply, gl .. "relic_slot_7", "Unlocked a Relic Slot!")
    end
end)

net.Receive(gl .. "chose_upgrade", function(len, ply)
    -- print("RECEIVE UPGRADE CHOSEN SERVER")
    local ply = net.ReadEntity()
    local upgrade_name = net.ReadString()
    local upgrade_rarity = net.ReadString()
    local statboost_num = net.ReadFloat()
    local upgrade_type = net.ReadString()
    local upgrade_name_2 = net.ReadString()
    local upgrade_mul = net.ReadFloat()
    local upgrade_mul_2 = net.ReadFloat()
    --
    -- print("UPGRADE TYPE SERVER " .. upgrade_type)
    -- print("UPGRADE RARITY SERVER: " .. upgrade_rarity)
    -- print("UPGRADE NAME SERVER " .. upgrade_name)
    --
    STR = ply:GetNWInt(gl .. "STR", 1)
    AGI = ply:GetNWInt(gl .. "AGI", 1)
    INT = ply:GetNWInt(gl .. "INT", 1)

    if upgrade_type == "statboost" then
        upgrade_name = string.upper(upgrade_name)
        -- ply:SetNWInt(gl .. "" .. upgrade_name, ply:GetNWInt(gl .. "" .. upgrade_name, 1) + statboost_num)
        STR = ply:GetNWInt(gl .. "STR", 1)
        AGI = ply:GetNWInt(gl .. "AGI", 1)
        INT = ply:GetNWInt(gl .. "INT", 1)

        if upgrade_name == "STR" then
            garlic_like_upgrade_str(ply, STR, statboost_num)
        elseif upgrade_name == "AGI" then
            garlic_like_upgrade_agi(ply, AGI, statboost_num)
        elseif upgrade_name == "INT" then
            garlic_like_upgrade_int(ply, INT, statboost_num)
        end

        -- print("STAT TYPE " .. upgrade_name)
    end

    if upgrade_type == "item_statboost" then
        if upgrade_name == "xp orb" then
            ply:SetNWFloat(gl .. "bonus_xp_mult", 1 + statboost_num) 
        elseif upgrade_name == "muscles" then
            ply:SetNWFloat(gl .. "bonus_hp_boost_mult", 1 + statboost_num) 
        elseif upgrade_name == "sword" then
            ply:SetNWFloat(gl .. "bonus_damage_mult", 1 + statboost_num) 
        elseif upgrade_name == "crystal" then
            ply:SetNWFloat(gl .. "bonus_stat_mult_crystal", 1 + statboost_num)  

            -- timer.Simple(0.5, function()
            --     garlic_like_upgrade_str(ply, STR, 1)
            --     garlic_like_upgrade_agi(ply, AGI, 1)
            --     garlic_like_upgrade_int(ply, INT, 1) 
            -- end)
        elseif upgrade_name == "glasses" then
            ply:SetNWFloat(gl .. "bonus_critical_chance_mult", (1 + statboost_num) * (1 + ply:GetNWFloat(gl .. rh .. "hawkeye_sight_mul", 0)))
            ply:SetNWFloat(gl .. "bonus_critical_chance", AGI * 0.007 * ply:GetNWFloat(gl .. "bonus_critical_chance_mult", 1))
        elseif upgrade_name == "armor" then
            ply:SetNWFloat(gl .. "bonus_armor", statboost_num)
        elseif upgrade_name == "shield" then
            ply:SetNWFloat(gl .. "bonus_shield", statboost_num)
        end
        
        timer.Simple(0.25, function()
            garlic_like_upgrade_str(ply, STR, 0)
            garlic_like_upgrade_agi(ply, AGI, 0)
            garlic_like_upgrade_int(ply, INT, 0)
        end)
    end

    if upgrade_type == "relic" then
        -- print("RELIC CHOSEN SERVER")
        ply:SetNWBool(gl .. rh .. "" .. upgrade_name_2, true)
        ply:SetNWFloat(gl .. rh .. "" .. upgrade_name_2 .. "_mul", upgrade_mul)
        ply:SetNWFloat(gl .. rh .. "" .. upgrade_name_2 .. "_mul_2", upgrade_mul_2)

        if upgrade_name_2 == "hawkeye_sight" then
            ply:SetNWFloat(gl .. "bonus_critical_chance_mult", (1 + statboost_num) * (1 + ply:GetNWFloat(gl .. rh .. "hawkeye_sight_mul", 0)))
            garlic_like_upgrade_str(ply, STR, 0)
            garlic_like_upgrade_agi(ply, AGI, 0)
        end

        --* RELIC UNLOCKABLES
        --! MAKE RELIC UNLOCKABLE
        if not garlic_like_ply_unlocked(ply, "relic_slot_5") and string.lower(upgrade_rarity) == "legendary" then 
            garlic_like_unlock(ply, gl .. "relic_slot_5", "Unlocked a Relic Slot!")
        end

        if not garlic_like_ply_unlocked(ply, "relic_slot_6") and string.lower(upgrade_rarity) == "god" then 
            garlic_like_unlock(ply, gl .. "relic_slot_6", "Unlocked a Relic Slot!")
        end
    end

    --* DATA / RECORD STUFF FOR UNLOCKABLE [COOLDOWN REDUCTION]
    if not garlic_like_ply_unlocked(ply, "bonus_cooldown_mult") and upgrade_type == "skill" and FROZE_GL.tbl_rarity_to_number[upgrade_rarity] >= 4 then 
        -- print("UNLOCKABLE: PICKED UP A RARE OR HIGHER SKILL!")
        ply:SetNWInt(gl .. "unlockables_rare_skill_amount", ply:GetNWInt(gl .. "unlockables_rare_skill_amount", 0) + 1)
        
        if ply:GetNWInt(gl .. "unlockables_rare_skill_amount", 0) >= 4 then
            -- print("UNLOCKABLE: PICKED UP 4 RARE OR HIGHER SPELLS!") 
            garlic_like_unlock(ply, gl .. "bonus_cooldown_mult", "Cooldown Speed Increase Upgrade") 
        end
    end

    garlic_like_print_stats(ply)
end)

net.Receive(gl .. "update_database_cl_to_sv", function(len, ply) 
    local name = net.ReadString()
    local number = net.ReadInt(32)
    local info = net.ReadString()
    local upgrades_table = net.ReadTable()
    local chr_upgrade_type = net.ReadString()
    local number_float = net.ReadFloat()
    local upgrade_level = net.ReadInt(32)
    local upgrade_id = net.ReadString()

    -- print("DATABASE UPDATE RECEIVED!")
    -- print("DATABASE UPDATE INFO: " .. info)

    if number == nil then
        garlic_like_update_database(ply, "", "", upgrades_table)
    elseif info == "BOUGHT_ITEM" then
        garlic_like_update_database(ply, name, -number)
    elseif info == "GAIN_MONEY" then
        garlic_like_update_database(ply, name, number)
    elseif info == "UPGRADE_CHARACTER" then 
        ply:SetPData(name .. "_base_level", upgrade_level)
        -- print("LEVEL OF " .. name .. "_base_level" .. " UPGRADE: " .. ply:GetPData(name .. "_base_level"))

        if chr_upgrade_type == "INT" then 
            ply:SetNWInt(upgrade_id .. "_base", number)
            ply:SetPData(upgrade_id .. "_base", number)
            -- print("UPGRADED INT AMOUNT FOR " .. upgrade_id .. "_base :" .. number)
        elseif chr_upgrade_type == "Float" then 
            ply:SetNWFloat(upgrade_id .. "_base", number_float)
            ply:SetPData(upgrade_id .. "_base", number_float)
            -- print("UPGRADED FLOAT AMOUNT: " .. upgrade_id .. "_base :" .. number_float)
        end
 
        -- print(ply:GetPData(gl .. "max_deaths_base", 0))
    end
end)

net.Receive(gl .. "choose_weapon", function(len, ply)
    ply.gl_weapon_chosen = net.ReadString()
    ply.gl_weapon_chosen_type = net.ReadString()
    ply.gl_stored_bonused_weapons = net.ReadTable()
    ply.gl_weps_to_remove = net.ReadTable()

    if ply.gl_weps_to_remove and #ply.gl_weps_to_remove > 0 then 
        for k, v in pairs(ply.gl_weps_to_remove) do 
            ply:StripWeapon(v)
        end
    end

    if ply.gl_weapon_chosen_type == "PICK_WEAPON" then
        ply:Give(ply.gl_weapon_chosen, false)
        ply:SelectWeapon(ply.gl_weapon_chosen)
    end
 
    -- PrintTable(ply.gl_stored_bonused_weapons)
    -- print(ply.gl_weapon_chosen)
    garlic_like_reset_gun_bonuses(ply, ply.gl_weapon_chosen)

    for class_name, entry in pairs(ply.gl_stored_bonused_weapons) do
        if class_name == ply.gl_weapon_chosen then
            -- print("ELEMENT: " .. entry.element)
            if entry.element and entry.element ~= "" then 
                -- print(gl .. ply.gl_weapon_chosen .. entry.element)
                ply:SetNWBool(gl .. ply.gl_weapon_chosen .. entry.element, true)
            end

            for k, bonus in pairs(entry.bonuses) do
                PrintTable(bonus) 
                --* multiplicative
                -- ply:SetNWFloat(gl .. ply.gl_weapon_chosen .. bonus.name, ply:GetNWFloat(gl .. ply.gl_weapon_chosen .. bonus.name, 1) * (1 + bonus.modifier * bonus.type_mul))
                --* additive 
                ply:SetNWFloat(gl .. ply.gl_weapon_chosen .. bonus.name, ply:GetNWFloat(gl .. ply.gl_weapon_chosen .. bonus.name, 1) + (bonus.modifier * bonus.type_mul))
                print(gl .. ply.gl_weapon_chosen .. bonus.name .. ": " .. ply:GetNWFloat(gl .. ply.gl_weapon_chosen .. bonus.name, 1)) 
            end
        end
    end
end)

net.Receive(gl .. "update_gold_from_anim_cl_to_sv", function(len, ply) 
    local gold_gained = net.ReadInt(32)
    garlic_like_update_database(ply, "money", gold_gained)
end)

net.Receive(gl .. "send_give_item_cl_to_sv", function(len, ply) 
    local id = net.ReadString() 
    local amount = net.ReadInt(32)
    --
    for k, v in pairs(FROZE_GL.tbl_menu_inventory_items_data) do 
        if id == k then 
            if v.is_ore then 
                ply:SetPData(gl .. "held_num_material_" .. v.rarity, tonumber(ply:GetPData(gl .. "held_num_material_" .. v.rarity, 0)) + amount)
                ply:SetNWInt(gl .. "held_num_material_" .. v.rarity, tonumber(ply:GetNWInt(gl .. "held_num_material_" .. v.rarity, 0)) + amount)
                net.Start(gl .. "update_database_sv_to_cl")
                net.WriteEntity(ply)
                net.WriteString("update_held_num_ores")
                net.WriteString("")
                net.WriteString(v.rarity)
                net.WriteInt(amount, 32)
                net.WriteBool(false)
                net.Send(ply)
            elseif v.is_material then 
                ply:SetPData(gl .. "held_num_material_" .. k, tonumber(ply:GetPData(gl .. "held_num_material_" .. k, 0)) + amount)
                ply:SetNWInt(gl .. "held_num_material_" .. k, tonumber(ply:GetNWInt(gl .. "held_num_material_" .. k, 0)) + amount)
                net.Start(gl .. "update_database_sv_to_cl")
                net.WriteEntity(ply)
                net.WriteString("update_held_num_materials")
                net.WriteString("")
                net.WriteString(k)
                net.WriteInt(amount, 32)
                net.WriteBool(false)
                net.Send(ply) 
            end
        end
    end
end)

--* FUNCTION EXECUTIONS
create_rarity_weights()

--*
hook.Add("PlayerSwitchWeapon", gl .. "check_switch", function(ply, old_wep, new_wep)
    -- INCREASE COOLDOWN SPEEDS
    timer.Create(tostring(ply:SteamID64() .. "weapon_switch_repeat_avoid"), 0.5, 1, function()
        if not IsValid(new_wep) or new_wep == nil then return end
        old_wep.changed_delay_function = false
        --
        -- print("GL || NEW WEP: " .. tostring(new_wep))
        -- print("GL || COOLDOWN SPEED: " .. tostring(ply:GetNWFloat(gl .. new_wep:GetClass() .. "cooldown_speed", 1)))
        --! DEPRECATED BECAUSE HORRIBLE LOGIC
        -- net.Start(gl .. "cooldown_speed_increase")
        -- net.WriteString(new_wep:GetClass())
        -- net.Send(ply)
        --* NEW ONE
        -- print("switched wep!!!")
        ply.cdr_torrent = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_torrent, "dota2_auto_cast_torrent_delay", "torrent")
        ply.cdr_lightning_bolt = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_lightning_bolt, "dota2_auto_cast_lightning_bolt_delay", "lightning_bolt")
        ply.cdr_diabolic_edict = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_diabolic_edict, "dota2_auto_cast_diabolic_edict_delay", "diabolic_edict")
        ply.cdr_magic_missile = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_magic_missile, "dota2_auto_cast_magic_missile_delay", "magic_missile")
    end)
 
    do
    end
end)

local load_queue = {}

hook.Add("PlayerInitialSpawn", gl .. "player_spawn", function(ply)
    load_queue[ ply ] = true 

    --* get the saved materials
    timer.Simple(3, function()
        for rarity, rarity_weight in pairs(FROZE_GL.rarity_weights) do        
            ply:SetNWInt(gl .. "held_num_material_" .. rarity, tonumber(ply:GetPData(gl .. "held_num_material_" .. rarity, 1)))
            net.Start(gl .. "update_database_sv_to_cl")
            net.WriteEntity(ply)
            net.WriteString("load_saved_held_num_material")
            net.WriteString("")
            net.WriteString(rarity)
            net.WriteInt(tonumber(ply:GetPData(gl .. "held_num_material_" .. rarity, 1)), 32)
            net.WriteBool(true)
            net.Send(ply)
        end 

        for k, v in pairs(FROZE_GL.tbl_materials_inventory) do 
            print("v.id IS... " .. v.id) 
            ply:SetNWInt(gl .. "held_num_material_" .. v.id, tonumber(ply:GetPData(gl .. "held_num_material_" .. v.id, 1)))
            net.Start(gl .. "update_database_sv_to_cl")
            net.WriteEntity(ply)
            net.WriteString("load_saved_held_num_material")
            net.WriteString(v.id)
            net.WriteString(v.rarity)
            net.WriteInt(tonumber(ply:GetPData(gl .. "held_num_material_" .. v.id, 1)), 32)
            net.WriteBool(true)
            net.Send(ply)  
        end 
    end)
end)

hook.Add( "SetupMove", gl .. "setupmove", function( ply, _, cmd )
	if load_queue[ ply ] and not cmd:IsForced() then
		load_queue[ ply ] = nil

		timer.Simple(0.1, function()
            ply:SetMaxHealth(ply:GetMaxHealth() + ply:GetNWInt(gl .. "hp_boost", 0))
        end)
    
        timer.Simple(0.25, function()
            garlic_like_reset_stats(ply)
            net.Start(gl .. "update_database_sv_to_cl")
            net.WriteEntity(ply)
            net.WriteString("update_shop")
            net.Send(ply)
    
            if not ply:GetPData(gl .. "total_deaths") then 
                -- print("TOTAL DEATHS NOT INIT")
                ply:SetPData(gl .. "total_deaths", 0)
            end
    
            --* fill up arccw att tbl
        end)
	end
end )

hook.Add("PlayerSpawn", gl .. "player_spawn", function(ply)
    timer.Simple(0.1, function()
        ply.cd_gem_gathering = 0
        ply:SetMaxHealth(ply:GetMaxHealth() + ply:GetNWInt(gl .. "hp_boost", 0))
        --
        net.Start(gl .. "update_database_sv_to_cl")
        net.WriteEntity(ply)
        net.Send(ply) 
 
        if GetConVar(gl .. "enable_timer"):GetBool() then
            ply:ConCommand(gl .. "debug_open_weapon_chest")
        end

        ply:SetNWBool(gl .. "spawn_dmg_reduction", true)

        --* increase walk speed 
        if not ply.gl_old_walk_speed then 
            ply.gl_old_slow_walk_speed = ply:GetSlowWalkSpeed()
            ply.gl_old_walk_speed = ply:GetWalkSpeed()
            ply.gl_old_run_speed = ply:GetRunSpeed()
        end

        ply:SetSlowWalkSpeed(ply:GetWalkSpeed())
        ply:SetWalkSpeed(ply:GetRunSpeed())

        ply:Give("FROZE_GL.default_gun")

        --* RESET UNLOCKABLES 
        -- for k, data in SortedPairs(FROZE_GL.tbl_character_stats) do 
            -- only read entries that are unlockables
            -- if data.unlock_condition then 
            --    ply:SetNWBool(gl .. data.id .. "_unlocked", tobool(ply:GetPData(gl .. data.id .. "_unlocked", false))) 
            -- end
        -- end

        --* LOAD / GIVE ORES ON SPAWN
        ply:ConCommand(gl .. "debug_update_materials_inventory")

        timer.Simple(5, function() 
            ply:SetNWBool(gl .. "spawn_dmg_reduction", false)
        end)
    end)

    if GetConVar(gl .. "reset_stats_after_dying"):GetInt() > 0 then
        timer.Simple(0.1, function()
            garlic_like_reset_stats(ply)
        end)
    end 
end)

hook.Add("PlayerButtonDown", gl .. "button_binds", function(ply, button) 
    if button == KEY_K then 
        ply:Kill()
    end

    if button == KEY_L then 
        ply:ConCommand(gl .. "debug_open_shop")
    end
end)

hook.Add("Think", gl .. "think_server", function()
    if GetConVar(gl .. "enable"):GetInt() < 1 then return end
    -- if GetConVar(gl .. "enable_timer"):GetInt() < 1 then return end
    --* PLAYER ITEM GATHERING / GEM GATHERING AOE
    for k, ply in pairs(player.GetAll()) do 
        if ply.cd_gem_gathering and ply.cd_gem_gathering < CurTime() then 
            ply.cd_gem_gathering = CurTime() + 0.01
            
            for k, ent in pairs(ents.FindInSphere(ply:GetPos(), 250)) do 
                local class = ent:GetClass()

                if ent:GetNWBool(gl .. "settled_2") and (class == gl .. "wep_crystal" or string.find(class, "acwatt")) then  
                    if not ent.FlyToTarget then 
                        local self = ent 

                        ent.FlyToTarget = function(ply) 
                            ent.Target = ply
                            ent:SetNWBool(gl .. "is_being_picked_up", true)

                            if not ent.SpeedMul then 
                                ent.SpeedMul = 50
                            end

                            if IsValid(self.Target) then 
                                ent.SpeedMul = ent.SpeedMul * 1.1
                                self:GetPhysicsObject():ApplyForceCenter((self.Target:LocalToWorld(self.Target:OBBCenter()) - self:GetPos()) * Vector(ent.SpeedMul, ent.SpeedMul, ent.SpeedMul))
                                self:SetAngles(((self.Target:LocalToWorld(self.Target:OBBCenter()) - self:GetPos()) * Vector(ent.SpeedMul, ent.SpeedMul, ent.SpeedMul)):Angle()) 
                            end
                        end
                    end
 
                    ent.FlyToTarget(ply)

                    if ent:GetPos():DistToSqr(ply:GetPos()) <= 1000  then 
                        if class == gl .. "wep_crystal" and ent:GetNWBool(gl .. "settled") then 
                            ent:StartTouch(ply) 
                        elseif string.find(class, "acwatt") and ent:GetNWBool(gl .. "settled_2") then  
                            ent:Use(ply)
                        end
                    end
                end
            end
        end

        if GetGlobalBool(gl .. "is_breaktime") then 
            --* HOLDING RMB EVENTUALLY GIVES YOUR VOTE TO SKIP BREAKTIME
            if ply:KeyDown(IN_ATTACK2) then 
                local var_text = gl .. "breaktime_skip_progress"

                print("ply:GetNWInt(var_text, 0) " .. ply:GetNWInt(var_text, 0))

                if ply:GetNWInt(var_text, 0) < 100 then 
                    ply:SetNWInt(var_text, ply:GetNWInt(var_text, 0) + 1) 
                elseif ply:GetNWInt(var_text, 0) >= 100 and not ply:GetNWBool(gl .. "voted_skip_break") then 
                    ply:SetNWBool(gl .. "voted_skip_break", true)
                    SetGlobalInt(gl .. "skip_break_voters", GetGlobalInt(gl .. "skip_break_voters", 0) + 1)

                    net.Start(gl .. "send_chat_message_sv_to_cl") 
                    net.WriteString(ply:Nick() .. " voted to skip break time! " .. GetGlobalInt(gl .. "skip_break_voters", 1) .. "/" .. game.MaxPlayers())
                    net.Broadcast()

                    --* IF VOTE SKIPPERS ARE AS MUCH AS THE PLAYERS IN GAME THEN SKIP
                    if GetGlobalInt(gl .. "skip_break_voters") >= game.MaxPlayers() and timer.RepsLeft(gl .. "breaktime_timer") > 3 then 
                        timer.Adjust(gl .. "breaktime_timer", 1, 3, nil)

                        timer.Simple(3, function() 
                            SetGlobalInt(gl .. "skip_break_voters", 0)

                            for k2, ply in pairs(player.GetAll()) do 
                                ply:SetNWBool(gl .. "voted_skip_break", false)
                            end
                        end)
                    end
                end
            else 
                ply:SetNWInt(gl .. "breaktime_skip_progress", 0)  
            end  
        end
    end

    if FROZE_GL.delay_rapid <= CurTime() then
        FROZE_GL.delay_rapid = CurTime() + 0.2

        for k, ply in player.Iterator() do
            ply:SetNWInt(gl .. "mana", math.min(ply:GetNWInt(gl .. "max_mana", 100), ply:GetNWInt(gl .. "mana", 100) + ply:GetNWInt(gl .. "mana_regen", 1)))
        end
    end

    if FROZE_GL.delay_timer <= CurTime() then
        local minutes = GetGlobalInt(gl .. "minutes", 0)
        local seconds = GetGlobalInt(gl .. "seconds", 0)

        if GetConVar(gl .. "enable_timer"):GetInt() > 0 then  
            if not GetGlobalBool(gl .. "is_breaktime") and not GetGlobalBool(gl .. "stop_enemy_spawns") then 
                seconds = seconds + 1
                SetGlobalInt(gl .. "seconds", seconds)
            end

            --* DELETE 0 HEALTH ENEMIES THAT DO NOT REMOVE ITSELF
            for k, ent in pairs(ents.GetAll()) do
                if (ent:IsNPC() or ent:IsNextBot()) and ent:Health() <= 0 then 
                    SafeRemoveEntity(ent)
                end
            end

            --* IF SPAWNED ENEMY IS FAR AWAY, RELOCATE TO NEAR THE PLAYER  

            --* OPERATIONS FOR ENEMY MODIFIERS
            if #FROZE_GL.spawned_enemies > 0 then 
                -- print("SPAWNED ENEMEIS IS VALID")
                for k, ent in ipairs(FROZE_GL.spawned_enemies) do 
                    -- print("DISTANCE FROM ENT TO A PLAYER: " .. ent:GetPos():Distance(table.Random(player.GetAll()):GetPos()))
                    if not IsValid(ent) then continue end 
                    if ent:GetPos():Distance(table.Random(player.GetAll()):GetPos()) >= 4100 then 
                        local point = garlic_like_get_nearby_point(ply)
                        local loop_num = 0 

                        if not point then 
                            print("NO RELOCATE POINT FOUND!") 
                            continue 
                        end

                        ent:SetPos(point + Vector(0, 0, 5))
                    end  
                end

                --* relocates entities when they're far away
                for k, ent in pairs(ents.GetAll()) do 
                    -- print("DISTANCE FROM ENT TO A PLAYER: " .. ent:GetPos():Distance(table.Random(player.GetAll()):GetPos()))
                    if not IsValid(ent) then continue end 
                    if string.find(ent:GetClass(), gl) and ent:GetPos():Distance(table.Random(player.GetAll()):GetPos()) >= 4100 then 
                        local point = garlic_like_get_nearby_point(ply)
                        local loop_num = 0 

                        if not point then 
                            print("NO RELOCATE POINT FOUND!") 
                            continue 
                        end

                        ent:SetPos(point + Vector(0, 0, 5))
                    end  
                end

                for k, enemy in ipairs(FROZE_GL.spawned_enemies) do 
                    if not IsValid(enemy) then return end 
                    --
                    if enemy:GetNWBool(gl .. "modifier_healing") then  
                        for k2, ent in ipairs(ents.FindInSphere(enemy:GetPos(), 700)) do 
                            if ent:Health() < ent:GetMaxHealth() then 
                                ent:SetHealth(ent:Health() + enemy:GetMaxHealth() * math.Remap(ent:GetPos():Distance(enemy:GetPos()), 100, 700, 0.05, 0.01)) 
                            end
                        end
                    end

                    if enemy:GetNWBool(gl .. "modifier_defensive") then 
                        for k2, ent in ipairs(ents.FindInSphere(enemy:GetPos(), 700)) do 
                            if not ent.gl_defensive_mul or ent.gl_defensive_mul == 1 then 
                                ent.gl_defensive_mul = math.Remap(enemy:GetPos():Distance(ent:GetPos()), 100, 700, 0.35, 0.85)
                            end
                            
                            if ent ~= enemy then 
                                timer.Simple(1.5, function() 
                                    if not IsValid(ent) then return end 
                                    --
                                    ent.gl_defensive_mul = 1
                                end)
                            end
                        end
                    end

                    if enemy:GetNWBool(gl .. "modifier_loyal") then 
                        for k2, ent in ipairs(ents.FindInSphere(enemy:GetPos(), 700)) do 
                            if ent ~= enemy then 
                                if not ent.gl_loyal_mul or ent.gl_loyal_mul == 1 then 
                                    ent.gl_loyal_mul = 0.5
                                end
                            
                                timer.Simple(1.5, function() 
                                    if not IsValid(ent) then return end 
                                    --
                                    ent.gl_loyal_mul = 1
                                end)
                            end
                        end
                    end
                end
            end
            
            --* STARTS AND COUNTS DOWN BREAKTIME WHEN ENEMY STOP SPAWNING + NO ENEMIES IN ENEMY TABLE ( ENEMY ALL KILLED )
            if GetGlobalBool(gl .. "stop_enemy_spawns") and not GetGlobalBool(gl .. "is_breaktime") and #FROZE_GL.spawned_enemies <= 0 then 
                SetGlobalBool(gl .. "is_breaktime", true) 

                garlic_like_spawn_ent(table.Random(player.GetAll()), gl .. "station_weapon_upgrade") 
                garlic_like_spawn_ent(table.Random(player.GetAll()), gl .. "station_item_fusing") 

                net.Start(gl .. "send_chat_message_sv_to_cl") 
                net.WriteString("Break started!, hold right click to vote to skip the break.")
                net.Broadcast()
                    
                timer.Create(gl .. "breaktime_timer", 1, 90, function() 
                    SetGlobalBool(gl .. "breaktime_seconds", timer.RepsLeft(gl .. "breaktime_timer"))

                    if timer.RepsLeft(gl .. "breaktime_timer") == 0 then 
                        SetGlobalBool(gl .. "stop_enemy_spawns", false)         
                        SetGlobalBool(gl .. "is_breaktime", false)
                    end
                end)
            end

            --* STOPS ENEMY SPAWNING EVERY SET PERIOD
            if minutes > 0 and minutes % 5 == 0 and not GetGlobalBool(gl .. "is_breaktime") and FROZE_GL.break_time_cur_min ~= minutes then                 
                FROZE_GL.break_time_cur_min = minutes
                SetGlobalBool(gl .. "stop_enemy_spawns", true)   
            end 

            --* EVERY 30 SECONDS, BUFF THE ENEMY STATS
            if seconds % 30 == 0 then 
                FROZE_GL.global_enemy_hp_modifier_stacks = FROZE_GL.global_enemy_hp_modifier_stacks + 0.15
                local gehms = FROZE_GL.global_enemy_hp_modifier_stacks
                local base_power = 1.012
                local mod_power = 0
                local mod_power_reduction = 0

                -- if GetGlobalFloat(gl .. "enemy_modifier_hp", 0) > 30 then 
                --     mod_power_reduction = math.max(1.005, (GetGlobalFloat(gl .. "enemy_modifier_hp", 0) / 30) / 2250
                -- end

                mod_power = base_power - mod_power_reduction

                SetGlobalFloat(gl .. "enemy_modifier_hp", ((GetGlobalFloat(gl .. "enemy_modifier_hp", 0) + (0.5 + gehms) * 1.2)^mod_power ) * GetConVar(gl .. "global_enemy_hp_mod_num"):GetFloat() )
                SetGlobalFloat(gl .. "enemy_modifier_damage", (GetGlobalFloat(gl .. "enemy_modifier_damage", 0) + 0.5) * 1.1 * GetConVar(gl .."global_enemy_dmg_mod_num"):GetFloat())
                SetGlobalFloat(gl .. "enemy_modifier_resistance", math.min(0.99, GetGlobalFloat(gl .. "enemy_modifier_resistance", 0) + 0.03))
                SetGlobalFloat(gl .. "enemy_modifier_evasion", math.min(0.99, GetGlobalFloat(gl .. "enemy_modifier_evasion", 0) + 0.01))

                FROZE_GL.timer_count = math.min(FROZE_GL.timer_count + 1, 9999)  
                FROZE_GL.enemy_preset_max_weight = 0
                local final_w_diff = 0
                
                for k, v in pairs(FROZE_GL.tbl_used_enemy_preset) do             
                    final_w_diff = math.Round(math.abs(v.weight_end - v.weight_start) / 60) 
                    v.weight = math.Approach(v.weight, v.weight_end, final_w_diff)

                    FROZE_GL.enemy_preset_max_weight = FROZE_GL.enemy_preset_max_weight + v.weight
        
                    if k == 1 then 
                        v.weight_min = 0
                        v.weight_max = v.weight 
                    else
                        v.weight_min = FROZE_GL.tbl_used_enemy_preset[k - 1].weight_max + 1 
                        v.weight_max = v.weight_min + v.weight 
                    end
                end

                garlic_like_check_enemy_spawn_chances() 

                -- PrintTable(FROZE_GL.tbl_used_enemy_preset)

                timer.Simple(0, function()
                    net.Start(gl .. "enemy_upgrade_broadcast")
                    net.Broadcast()
                end)

                --* increase wep power limits
                FROZE_GL.wep_power_inc = math.min(1000000, FROZE_GL.wep_power_inc + 200 + FROZE_GL.wep_power_inc_num * 100 )
                FROZE_GL.wep_power_inc_num = FROZE_GL.wep_power_inc_num + 1
                SetGlobalInt(gl .. "wep_power_limit", GetGlobalInt(gl .. "wep_power_limit") + FROZE_GL.wep_power_inc)

                --* checks if the wep power limit is bigger than every weapon
                --* if so, then do not update the limit value
                local biggest_power = 0

                for k, power in pairs(FROZE_GL.tbl_wep_power) do  
                    if power > biggest_power then 
                        biggest_power = power
                    end
                end

                if GetGlobalInt(gl .. "wep_power_limit") < biggest_power then  
                    net.Start(gl .. "update_tbl_valid_wep_sv_to_cl")
                    net.Broadcast()
                end 
            end                        

            if seconds == 60 then
                seconds = 0
                minutes = minutes + 1
                SetGlobalInt(gl .. "seconds", seconds)
                SetGlobalInt(gl .. "minutes", minutes)
            end
        end 

        FROZE_GL.delay_timer = CurTime() + 1 * (1 / GetConVar(gl .. "timer_speed_mult"):GetFloat()) 
    end

    --* TIMER RELATING TO PLAYER OPERATIONS
    if FROZE_GL.delay_ply <= CurTime() then
        local minutes = GetGlobalInt(gl .. "minutes", 0)
        local seconds = GetGlobalInt(gl .. "seconds", 0)
         
        for k, ply in ipairs(player.GetAll()) do            
            if not ply:Alive() or not IsValid(ply) then continue end 
            --
            local ply_wep = ply:GetActiveWeapon()
            
            if IsValid(ply_wep) then 
                local ply_wep_class = ply_wep:GetClass()
                ply:SetHealth(math.min(ply:GetMaxHealth() * ply:GetNWFloat(gl .. "max_overheal", 1.5) * ply:GetNWFloat(gl .. ply_wep_class .. "hp_regen", 1), ply:Health() + math.Round(ply:GetNWInt(gl .. "bonus_hp_regen", 1) * ply:GetNWFloat(gl .. ply_wep_class .. "hp_regen", 1))))
            end

            --* RELIC UNLOCKABLES 
            if not garlic_like_ply_unlocked(ply, "relic_slot_1") and minutes >= 10 then 
                garlic_like_unlock(ply, gl .. "relic_slot_1", "Unlocked a Relic Slot!")
            end

            if not garlic_like_ply_unlocked(ply, "relic_slot_2") and minutes >= 15 then 
                garlic_like_unlock(ply, gl .. "relic_slot_2", "Unlocked a Relic Slot!")
                
            end

            if not garlic_like_ply_unlocked(ply, "relic_slot_3") and minutes >= 20 then 
                garlic_like_unlock(ply, gl .. "relic_slot_3", "Unlocked a Relic Slot!")
                
            end

            if not garlic_like_ply_unlocked(ply, "relic_slot_4") and minutes >= 30 then 
                garlic_like_unlock(ply, gl .. "relic_slot_4", "Unlocked a Relic Slot!")
                
            end
        end

        FROZE_GL.delay_ply = CurTime() + 1
    end

    --* ADDED b to turn this off
    --* barrel spawning, crystal spawning
    if not GetGlobalBool(gl .. "stop_enemy_spawns") and GetConVar(gl .. "enable_timer"):GetBool() and FROZE_GL.delay_enemies < CurTime() and not GetGlobalBool(gl .. "is_breaktime") then 
        FROZE_GL.delay_enemies = CurTime() + math.max(0.5, 2 * (90 -   FROZE_GL.timer_count) / 90)
        -- print("ENEMY DELAY")

        if #FROZE_GL.spawned_enemies > 0 then 
            for k, enemy in ipairs(FROZE_GL.spawned_enemies) do 
                if not IsValid(enemy) then continue end 

                if enemy:GetNWBool(gl .. "modifier_fiery") and enemy:GetNWInt(gl .. "modifier_fiery_cd", 0) < CurTime() then 
                    garlic_like_create_fiery_fireball(enemy)
                end
    
                if enemy:GetNWBool(gl .. "modifier_poisonball") and enemy:GetNWInt(gl .. "modifier_poisonball_cd", 0) < CurTime() then 
                    garlic_like_create_poisonball(enemy)
                end

                if enemy:GetNWBool(gl .. "modifier_lightning") and enemy:GetNWInt(gl .. "modifier_thunderball_cd", 0) < CurTime() then 
                    garlic_like_create_thunderball(enemy)
                end
            end
        end

        if #FROZE_GL.spawned_enemies < GetConVar(gl .. "max_enemies_spawned"):GetInt() and math.random() <= 0.75 then   
            garlic_like_spawn_ent(table.Random(player.GetAll()), "enemy")  
        end

        if math.random() <= 0.03 then 
            local ent = garlic_like_spawn_ent(table.Random(player.GetAll()), gl .. "crystal_cluster") 
            SafeRemoveEntityDelayed(ent, 90)
        end

        if math.random() <= 0.12 then 
            local ent = garlic_like_spawn_ent(table.Random(player.GetAll()), gl .. "item_barrel") 
            SafeRemoveEntityDelayed(ent, 90) 
        end        

        if math.random() <= 0.1 then 
            local ent = garlic_like_spawn_ent(table.Random(player.GetAll()), gl .. "weapon_crate_entity") 
            SafeRemoveEntityDelayed(ent, 90)
        end        
    end 
 
    --* WEAPON HACKS / OVERRIDING
    for k, ply in player.Iterator() do
        local ply_wep = ply:GetActiveWeapon() 
        -- print("being iterator...")

        -- print("base " .. weapons.Get(ply_wep:GetClass()).Base)
        -- print(ply_wep.GetClass)
        if IsValid(ply_wep) and ply_wep:IsScripted() and not ply_wep.changed_delay_function and ply.gl_stored_bonused_weapons and ply.gl_stored_bonused_weapons[ply_wep:GetClass()] then 
            print("reworking functions of: " .. ply_wep:GetClass())
            -- print("being changed...")
            ply_wep.changed_delay_function = true 
            local SWEP = ply_wep
            local tbl_stored_wep = ply.gl_stored_bonused_weapons[ply_wep:GetClass()]
            local base_rarity_mod_num = tbl_stored_wep.base_rarity_mod_num

            -- PrintTable(tbl_stored_wep)

            if (string.find(weapons.Get(ply_wep:GetClass()).Base, "arccw")) then  
                -- (math.max(1, garlic_like_get_wep_bonus_value(ply, "attack_speed")))
                function SWEP:GetFiringDelay()
                    local delay = (self.Delay / (math.max(1, garlic_like_get_wep_bonus_value(ply, "attack_speed")) * base_rarity_mod_num) * (1 / (self:GetBuff_Mult("Mult_RPM")))) 
                    delay = self:GetBuff_Hook("Hook_ModifyRPM", delay) or delay

                    -- print("delay: " .. delay)
                
                    return delay
                end

                function SWEP:Reload()
                    if IsValid(self:GetHolster_Entity()) then return end
                    if self:GetHolster_Time() > 0 then return end
                
                    if self:GetOwner():IsNPC() then
                        return
                    end
                
                    if self:GetState() == ArcCW.STATE_CUSTOMIZE then
                        return
                    end
                
                    -- Switch to UBGL
                    if self:GetBuff_Override("UBGL") and self:GetOwner():KeyDown(IN_USE) then
                        if self:GetInUBGL() then
                            --net.Start("arccw_ubgl")
                            --net.WriteBool(false)
                            --net.SendToServer()
                
                            self:DeselectUBGL()
                        else
                            --net.Start("arccw_ubgl")
                            --net.WriteBool(true)
                            --net.SendToServer()
                
                            self:SelectUBGL()
                        end
                
                        return
                    end
                
                    if self:GetInUBGL() then
                        if self:GetNextSecondaryFire() > CurTime() then return end
                            self:ReloadUBGL()
                        return
                    end
                
                    if self:GetNextPrimaryFire() >= CurTime() then return end
                    -- if !game.SinglePlayer() and !IsFirstTimePredicted() then return end
                
                
                    if self.Throwing then return end
                    if self.PrimaryBash then return end
                
                    -- with the lite 3D HUD, you may want to check your ammo without reloading
                    local Lite3DHUD = self:GetOwner():GetInfo("arccw_hud_3dfun") == "1"
                    if self:GetOwner():KeyDown(IN_WALK) and Lite3DHUD then
                        return
                    end
                
                    if self:GetMalfunctionJam() then
                        local r = self:MalfunctionClear()
                        if r then return end
                    end
                
                    if !self:GetMalfunctionJam() and self:Ammo1() <= 0 and !self:HasInfiniteAmmo() then return end
                
                    if self:HasBottomlessClip() then return end
                
                    if self:GetBuff_Hook("Hook_PreReload") then return end
                
                    -- if we must dump our clip when reloading, our reserve ammo should be more than our clip
                    local dumpclip = self:GetBuff_Hook("Hook_ReloadDumpClip")
                    if dumpclip and !self:HasInfiniteAmmo() and self:Clip1() >= self:Ammo1() then
                        return
                    end
                
                    self.LastClip1 = self:Clip1()
                
                    local reserve = self:Ammo1()
                
                    reserve = reserve + self:Clip1()
                    if self:HasInfiniteAmmo() then reserve = self:GetCapacity() + self:Clip1() end
                
                    local clip = self:GetCapacity()
                
                    local chamber = math.Clamp(self:Clip1(), 0, self:GetChamberSize())
                    if self:GetNeedCycle() then chamber = 0 end
                
                    local load = math.Clamp(clip + chamber, 0, reserve)
                
                    if !self:GetMalfunctionJam() and load <= self:Clip1() then return end
                
                    self:SetBurstCount(0)
                
                    local shouldshotgunreload = self:GetBuff_Override("Override_ShotgunReload")
                    local shouldhybridreload = self:GetBuff_Override("Override_HybridReload")
                
                    if shouldshotgunreload == nil then shouldshotgunreload = self.ShotgunReload end
                    if shouldhybridreload == nil then shouldhybridreload = self.HybridReload end
                
                    if shouldhybridreload then
                        shouldshotgunreload = self:Clip1() != 0
                    end
                
                    if shouldshotgunreload and self:GetShotgunReloading() > 0 then return end
                
                    local mult = self:GetBuff_Mult("Mult_ReloadTime") * (1 / garlic_like_get_wep_bonus_value(ply, "reload_speed")) / base_rarity_mod_num
                
                    if shouldshotgunreload then
                        local anim = "sgreload_start"
                        local insertcount = 0
                
                        local empty = self:Clip1() == 0 --or self:GetNeedCycle()
                
                        if self.Animations.sgreload_start_empty and empty then
                            anim = "sgreload_start_empty"
                            empty = false
                            if (self.Animations.sgreload_start_empty or {}).ForceEmpty == true then
                                empty = true
                            end
                
                            insertcount = (self.Animations.sgreload_start_empty or {}).RestoreAmmo or 1
                        else
                            insertcount = (self.Animations.sgreload_start or {}).RestoreAmmo or 0
                        end
                
                        anim = self:GetBuff_Hook("Hook_SelectReloadAnimation", anim) or anim
                
                        local time = self:GetAnimKeyTime(anim)
                        local time2 = self:GetAnimKeyTime(anim, true)
                
                        if time2 >= time then
                            time2 = 0
                        end
                
                        if insertcount > 0 then
                            self:SetMagUpCount(insertcount)
                            self:SetMagUpIn(CurTime() + time2 * mult)
                        end
                        self:PlayAnimation(anim, mult, true, 0, true, nil, true)
                
                        self:SetReloading(CurTime() + time * mult)
                
                        self:SetShotgunReloading(empty and 4 or 2)
                    else
                        local anim = self:SelectReloadAnimation()
                
                        if !self.Animations[anim] then print("Invalid animation \"" .. anim .. "\"") return end
                
                        self:PlayAnimation(anim, mult, true, 0, false, nil, true)
                
                        local reloadtime = self:GetAnimKeyTime(anim, true) * mult
                        local reloadtime2 = self:GetAnimKeyTime(anim, false) * mult
                
                        self:SetNextPrimaryFire(CurTime() + reloadtime2)
                        self:SetReloading(CurTime() + reloadtime2)
                
                        self:SetMagUpCount(0)
                        self:SetMagUpIn(CurTime() + reloadtime)
                    end
                
                    self:SetClipInfo(load)
                    if game.SinglePlayer() then
                        self:CallOnClient("SetClipInfo", tostring(load))
                    end
                
                    for i, k in pairs(self.Attachments) do
                        if !k.Installed then continue end
                        local atttbl = ArcCW.AttachmentTable[k.Installed]
                
                        if atttbl.DamageOnReload then
                            self:DamageAttachment(i, atttbl.DamageOnReload)
                        end
                    end
                
                    if !self.ReloadInSights then
                        self:ExitSights()
                        self.Sighted = false
                    end
                
                    self:GetBuff_Hook("Hook_PostReload")
                end

                function SWEP:MeleeAttack(melee2)
                    local reach = 32 + self:GetBuff_Add("Add_MeleeRange") + self.MeleeRange
                    local dmg = self:GetBuff_Override("Override_MeleeDamage", self.MeleeDamage) or 20
                
                    if melee2 then
                        reach = 32 + self:GetBuff_Add("Add_MeleeRange") + self.Melee2Range
                        dmg = self:GetBuff_Override("Override_MeleeDamage", self.Melee2Damage) or 20
                    end
                
                    dmg = dmg * self:GetBuff_Mult("Mult_MeleeDamage") * garlic_like_get_wep_bonus_value(ply, "bash_damage") * base_rarity_mod_num
                
                    self:GetOwner():LagCompensation(true)
                
                    local filter = {self:GetOwner()}
                
                    table.Add(filter, self.Shields)
                
                    local tr = util.TraceLine({
                        start = self:GetOwner():GetShootPos(),
                        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
                        filter = filter,
                        mask = MASK_SHOT_HULL
                    })
                
                    if (!IsValid(tr.Entity)) then
                        tr = util.TraceHull({
                            start = self:GetOwner():GetShootPos(),
                            endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
                            filter = filter,
                            mins = Vector(-16, -16, -8),
                            maxs = Vector(16, 16, 8),
                            mask = MASK_SHOT_HULL
                        })
                    end
                
                    -- Backstab damage if applicable
                    local backstab = tr.Hit and self:CanBackstab(melee2, tr.Entity)
                    if backstab then
                        if melee2 then
                            local bs_dmg = self:GetBuff_Override("Override_Melee2DamageBackstab", self.Melee2DamageBackstab)
                            if bs_dmg then
                                dmg = bs_dmg * self:GetBuff_Mult("Mult_MeleeDamage")
                            else
                                dmg = dmg * self:GetBuff("BackstabMultiplier") * self:GetBuff_Mult("Mult_MeleeDamage")
                            end
                        else
                            local bs_dmg = self:GetBuff_Override("Override_MeleeDamageBackstab", self.MeleeDamageBackstab)
                            if bs_dmg then
                                dmg = bs_dmg * self:GetBuff_Mult("Mult_MeleeDamage")
                            else
                                dmg = dmg * self:GetBuff("BackstabMultiplier") * self:GetBuff_Mult("Mult_MeleeDamage")
                            end
                        end
                    end
                
                    -- We need the second part for single player because SWEP:Think is ran shared in SP
                    if !(game.SinglePlayer() and CLIENT) then
                        if tr.Hit then
                            if tr.Entity:IsNPC() or tr.Entity:IsNextBot() or tr.Entity:IsPlayer() then
                                self:MyEmitSound(self.MeleeHitNPCSound, 75, 100, 1, CHAN_USER_BASE + 2)
                            else
                                self:MyEmitSound(self.MeleeHitSound, 75, 100, 1, CHAN_USER_BASE + 2)
                            end
                
                            if tr.MatType == MAT_FLESH or tr.MatType == MAT_ALIENFLESH or tr.MatType == MAT_ANTLION or tr.MatType == MAT_BLOODYFLESH then
                                local fx = EffectData()
                                fx:SetOrigin(tr.HitPos)
                
                                util.Effect("BloodImpact", fx)
                            end
                        else
                            self:MyEmitSound(self.MeleeMissSound, 75, 100, 1, CHAN_USER_BASE + 3)
                        end
                    end
                
                    if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0) then
                        local dmginfo = DamageInfo()
                
                        local attacker = self:GetOwner()
                        if !IsValid(attacker) then attacker = self end
                        dmginfo:SetAttacker(attacker)
                
                        local relspeed = (tr.Entity:GetVelocity() - self:GetOwner():GetAbsVelocity()):Length()
                
                        relspeed = relspeed / 225
                
                        relspeed = math.Clamp(relspeed, 1, 1.5)
                
                        dmginfo:SetInflictor(self)
                        dmginfo:SetDamage(dmg * relspeed)
                        dmginfo:SetDamageType(self:GetBuff_Override("Override_MeleeDamageType") or self.MeleeDamageType or DMG_CLUB)
                
                        dmginfo:SetDamageForce(self:GetOwner():GetRight() * -4912 + self:GetOwner():GetForward() * 9989)
                
                        SuppressHostEvents(NULL)
                        tr.Entity:TakeDamageInfo(dmginfo)
                        SuppressHostEvents(self:GetOwner())
                
                        if tr.Entity:GetClass() == "func_breakable_surf" then
                            tr.Entity:Fire("Shatter", "0.5 0.5 256")
                        end
                
                    end
                
                    if SERVER and IsValid(tr.Entity) then
                        local phys = tr.Entity:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:ApplyForceOffset(self:GetOwner():GetAimVector() * 80 * phys:GetMass(), tr.HitPos)
                        end
                    end
                
                    self:GetBuff_Hook("Hook_PostBash", {tr = tr, dmg = dmg})
                
                    self:GetOwner():LagCompensation(false)
                end

                function SWEP:Bash(melee2)
                    melee2 = melee2 or false
                    if self:GetState() == ArcCW.STATE_SIGHTS
                            or (self:GetState() == ArcCW.STATE_SPRINT and !self:CanShootWhileSprint())
                            or self:GetState() == ArcCW.STATE_CUSTOMIZE then
                        return
                    end
                    if self:GetNextPrimaryFire() > CurTime() or self:GetGrenadePrimed() or self:GetPriorityAnim() then return end
                
                    if !self.CanBash and !self:GetBuff_Override("Override_CanBash") then return end
                
                    self:GetBuff_Hook("Hook_PreBash")
                
                    self.Primary.Automatic = true
                
                    local mult = self:GetBuff_Mult("Mult_MeleeTime") / garlic_like_get_wep_bonus_value(ply, "bash_speed") * base_rarity_mod_num
                    local mt = self.MeleeTime * mult
                
                    if melee2 then
                        mt = self.Melee2Time * mult
                    end
                
                    mt = mt * self:GetBuff_Mult("Mult_MeleeWaitTime")
                
                    local bashanim = "bash"
                    local canbackstab = self:CanBackstab(melee2)
                
                    if melee2 then
                        bashanim = canbackstab and self:SelectAnimation("bash2_backstab") or self:SelectAnimation("bash2") or bashanim
                    else
                        bashanim = canbackstab and self:SelectAnimation("bash_backstab") or self:SelectAnimation("bash") or bashanim
                    end
                
                    bashanim = self:GetBuff_Hook("Hook_SelectBashAnim", bashanim) or bashanim
                
                    if bashanim and self.Animations[bashanim] then
                        if SERVER then self:PlayAnimation(bashanim, mult, true, 0, true) end
                    else
                        self:ProceduralBash()
                
                        self:MyEmitSound(self.MeleeSwingSound, 75, 100, 1, CHAN_USER_BASE + 1)
                    end
                
                    if CLIENT then
                        self:OurViewPunch(-self.BashPrepareAng * 0.05)
                    end
                    self:SetNextPrimaryFire(CurTime() + mt )
                
                    if melee2 then
                        if self.HoldtypeActive == "pistol" or self.HoldtypeActive == "revolver" then
                            self:GetOwner():DoAnimationEvent(self.Melee2Gesture or ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE)
                        else
                            self:GetOwner():DoAnimationEvent(self.Melee2Gesture or ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND)
                        end
                    else
                        if self.HoldtypeActive == "pistol" or self.HoldtypeActive == "revolver" then
                            self:GetOwner():DoAnimationEvent(self.MeleeGesture or ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE)
                        else
                            self:GetOwner():DoAnimationEvent(self.MeleeGesture or ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND)
                        end
                    end
                
                    local mat = self.MeleeAttackTime
                
                    if melee2 then
                        mat = self.Melee2AttackTime
                    end
                
                    mat = mat * self:GetBuff_Mult("Mult_MeleeAttackTime") * math.pow(mult, 1.5)
                
                    self:SetTimer(mat or (0.125 * mt), function()
                        if !IsValid(self) then return end
                        if !IsValid(self:GetOwner()) then return end
                        if self:GetOwner():GetActiveWeapon() != self then return end
                
                        if CLIENT then
                            self:OurViewPunch(-self.BashAng * 0.05)
                        end
                
                        self:MeleeAttack(melee2)
                    end)
                
                    self:DoLunge()
                end

                function SWEP:GetCapacity()
                    local clip = self.RegularClipSize or self.Primary.ClipSize
                
                    if !self.RegularClipSize then
                        self.RegularClipSize = self.Primary.ClipSize
                    end
                
                    local level = 1
                
                    if self:GetBuff_Override("MagExtender") then
                        level = level + 1
                    end
                
                    if self:GetBuff_Override("MagReducer") then
                        level = level - 1
                    end
                
                    if level == 0 then
                        clip = self.ReducedClipSize
                    elseif level == 2 then
                        clip = self.ExtendedClipSize
                    end
                
                    clip = self:GetBuff("ClipSize", true, clip) or clip
                
                    local ret = self:GetBuff_Hook("Hook_GetCapacity", clip)
                
                    clip = ret or clip
                
                    clip = math.Clamp(math.Round(clip * garlic_like_get_wep_bonus_value(ply, "mag_upgrade") * base_rarity_mod_num), 0, math.huge)
                
                    self.Primary.ClipSize = clip
                
                    return clip
                end

                function SWEP:DoRecoil()
                    local single = game.SinglePlayer()
                
                    if !single and !IsFirstTimePredicted() then return end
                
                    if single and self:GetOwner():IsValid() and SERVER then self:CallOnClient("DoRecoil") end
                
                    -- math.randomseed(self:GetBurstLength() + (self.Recoil * 409) + (self.RecoilSide * 519))
                
                    local rec = {
                        Recoil = 1,
                        RecoilSide = 1,
                        VisualRecoilMul = 1
                    }
                    rec = self:GetBuff_Hook("Hook_ModifyRecoil", rec) or rec
                
                    local recoil = rec.Recoil
                    local side   = rec.RecoilSide
                    local visual = rec.VisualRecoilMul
                
                    local rmul = (recoil or 1) * self:GetBuff_Mult("Mult_Recoil") / base_rarity_mod_num
                    local recv = (visual or 1) * self:GetBuff_Mult("Mult_VisualRecoilMult") / base_rarity_mod_num
                    local recs = (side or 1)   * self:GetBuff_Mult("Mult_RecoilSide") / base_rarity_mod_num
                
                    -- local rrange = math.Rand(-recs, recs) * self.RecoilSide
                
                    -- local irec = math.Rand(rrange - 1, rrange + 1)
                    -- local recu = math.Rand(0.5, 1)
                
                    local irec = math.Rand(-1, 1)
                    local recu = 1
                
                    if self:InBipod() then
                        local b = self.BipodRecoil * self:GetBuff_Mult("Mult_BipodRecoil")
                
                        rmul = rmul * b
                        recs = recs * b
                        recv = recv * b
                    end
                
                    local recoiltbl = self:GetBuff_Override("Override_ShotRecoilTable") or self.ShotRecoilTable
                
                    if recoiltbl and recoiltbl[self:GetBurstCount()] then rmul = rmul * recoiltbl[self:GetBurstCount()] end
                
                    if ArcCW.ConVars["mult_crouchrecoil"]:GetFloat() != 1 and self:GetOwner():OnGround() and self:GetOwner():Crouching() then
                        rmul = rmul * ArcCW.ConVars["mult_crouchrecoil"]:GetFloat()
                    end
                
                    local punch = Angle()
                
                    punch = punch + (self:GetBuff_Override("Override_RecoilDirection", self.RecoilDirection) * math.max(self.Recoil, 0.25) * recu * recv * rmul)
                    punch = punch + (self:GetBuff_Override("Override_RecoilDirectionSide", self.RecoilDirectionSide) * math.max(self.RecoilSide, 0.25) * irec * recv * rmul)
                    punch = punch + Angle(0, 0, 90) * math.Rand(-1, 1) * math.Clamp(self.Recoil, 0.25, 1) * recv * rmul * 0.01
                    punch = punch * (self.RecoilPunch or 1) * self:GetBuff_Mult("Mult_RecoilPunch")
                
                    self:SetFreeAimAngle(self:GetFreeAimAngle() - punch)
                
                    if CLIENT then self:OurViewPunch(punch) end
                
                    if CLIENT or single then
                        recv = recv * self.VisualRecoilMult
                
                        self.RecoilAmount     = self.RecoilAmount + (self.Recoil * rmul * recu)
                        self.RecoilAmountSide = self.RecoilAmountSide + (self.RecoilSide * irec * recs * rmul)
                        self.RecoilPunchBack  = math.Clamp(self.RecoilAmount * recv * 5, 1, 5)
                
                        if self.MaxRecoilBlowback > 0 then
                            self.RecoilPunchBack = math.Clamp(self.RecoilPunchBack, 0, self.MaxRecoilBlowback)
                        end
                
                        self.RecoilPunchSide = self.RecoilSide * 0.1 * irec * recv * rmul
                        self.RecoilPunchUp   = self.RecoilRise * 0.1 * recu
                    end
                
                    -- math.randomseed(CurTime() + (self:EntIndex() * 3))
                end
            elseif (string.find(weapons.Get(ply_wep:GetClass()).Base, "tfa")) then 
                local function l_Lerp(v, f, t)
                    return f + (t - f) * v
                end
                local l_mathApproach = math.Approach
                local l_CT = CurTime 
                local stat --Weapon status
                local ct  = 0--Curtime, frametime, real frametime
                local sp = game.SinglePlayer() --Singleplayer
                local developer = GetConVar("developer") 
                local att = {}
                local tr = {}
                local traceres = {}
                local pos, ang, mdl, ski, prop
                local fwd, eang, scl, dirv
                local strikedir = Vector()
                local lim_up_vec = Vector(1, 1, 0.05) 
                local TracerName
                local procedural_vellimit = 5
                local l_Lerp = Lerp
                local l_mathApproach = math.Approach
                local l_mathClamp = math.Clamp
                local viewbob_intensity_cvar, viewbob_animated_cvar
                viewbob_intensity_cvar = GetConVar("cl_tfa_viewbob_intensity")
                viewbob_animated_cvar = GetConVar("cl_tfa_viewbob_animated")
                local oldangtmp
                local mzang_fixed
                local mzang_fixed_last
                local mzang_velocity = Angle()
                local progress = 0
                local targint, targbool
                local cv_dmg_mult = GetConVar("sv_tfa_damage_multiplier")
                local cv_dmg_mult_npc = GetConVar("sv_tfa_damage_multiplier_npc")
                local cv_dmg_mult_min = GetConVar("sv_tfa_damage_mult_min")
                local cv_dmg_mult_max = GetConVar("sv_tfa_damage_mult_max") 
                local cv_forcemult = GetConVar("sv_tfa_force_multiplier")
                local sv_tfa_bullet_penetration_power_mul = GetConVar("sv_tfa_bullet_penetration_power_mul")
                local sv_tfa_bullet_randomseed = GetConVar("sv_tfa_bullet_randomseed") 
                local sv_tfa_recoil_legacy = GetConVar("sv_tfa_recoil_legacy") 
                local sv_tfa_recoil_mul_p = GetConVar("sv_tfa_recoil_mul_p")
                local sv_tfa_recoil_mul_p_npc = GetConVar("sv_tfa_recoil_mul_p_npc")
                local sv_tfa_recoil_mul_y = GetConVar("sv_tfa_recoil_mul_y")
                local sv_tfa_recoil_mul_y_npc = GetConVar("sv_tfa_recoil_mul_y_npc") 
                local sv_tfa_recoil_viewpunch_mul = GetConVar("sv_tfa_recoil_viewpunch_mul")
                local sv_tfa_recoil_eyeangles_mul = GetConVar("sv_tfa_recoil_eyeangles_mul")
                SWEP.hpf = false
                SWEP.hpw = false

                if not SWEP.OldClipSize then 
                    SWEP.OldClipSize = SWEP.Primary.ClipSize 
                    SWEP.Old = {} 
                end

                if SWEP.Shotgun then 
                    SWEP.Primary.ClipSize = math.Round(SWEP.OldClipSize * garlic_like_get_wep_bonus_value(ply, "mag_upgrade") * base_rarity_mod_num)
                end 

                local function TraceHitFlesh(b)
                    return b.MatType == MAT_FLESH or b.MatType == MAT_ALIENFLESH or (IsValid(b.Entity) and b.Entity.IsNPC and (b.Entity:IsNPC() or b.Entity:IsPlayer() or b.Entity:IsRagdoll()))
                end

                function SWEP:GetFireDelay()
                    -- print("TFA GET FIRE DELAY")
                    if self:GetMaxBurst() > 1 and self:GetStatL("Primary.RPM_Burst") and self:GetStatL("Primary.RPM_Burst") > 0 then
                        -- print("TFA GET FIRE DELAY 1")
                        return 60 / self:GetStatL("Primary.RPM_Burst")
                    elseif self:GetStatL("Primary.RPM_Semi") and not self.Primary_TFA.Automatic and self:GetStatL("Primary.RPM_Semi") and self:GetStatL("Primary.RPM_Semi") > 0 then
                        -- print("TFA GET FIRE DELAY 2")
                        return 60 / self:GetStatL("Primary.RPM_Semi")
                    elseif self:GetStatL("Primary.RPM") and self:GetStatL("Primary.RPM") > 0 then
                        -- print("TFA GET FIRE DELAY 3")
                        -- print(60 / self:GetStatL("Primary.RPM"))
                        return 60 / self:GetStatL("Primary.RPM") / ((math.max(1, garlic_like_get_wep_bonus_value(ply, "attack_speed"))) * base_rarity_mod_num)
                    else
                        -- print("TFA GET FIRE DELAY 4")
                        return self:GetStatL("Primary.Delay") or 0.1
                    end
                end

                function SWEP:GetAnimationRate(ani, animationType)
                    local self2 = self:GetTable()
                    local bonus_melee_rate = math.max(0, ((boolToNumber(garlic_like_is_tfa_melee(SWEP)) * (garlic_like_get_wep_bonus_value(ply, "attack_speed"))) * base_rarity_mod_num) - 1)
                    
                    -- print("bonus_melee_rate " .. bonus_melee_rate)
                    local rate = 1 + bonus_melee_rate
                    local gl_speed_mod = math.max(1, garlic_like_get_wep_bonus_value(ply, "reload_speed")) * base_rarity_mod_num
                    local reload_speed_mod = garlic_like_get_wep_bonus_value(ply, "reload_speed")
                    if not ani or ani < 0 or not self2.VMIV(self) then return rate end 

                    -- print("booltonum 1 " .. tostring(boolToNumber(1)))
                    -- print("booltonum 2 " .. tostring(boolToNumber(2)))

                    -- print("ani " .. ani)
                
                    local nm
                
                    if animationType == TFA.Enum.ANIMATION_ACT or animationType == nil then
                        nm = self2.OwnerViewModel:GetSequenceName(self2.OwnerViewModel:SelectWeightedSequence(ani))
                    elseif isnumber(ani) then
                        nm = self2.OwnerViewModel:GetSequenceName(ani)
                    elseif isstring(ani) then
                        nm = ani
                    else
                        error("ani argument is typeof " .. type(ani))
                    end
                
                    local sqto = self2.GetStatL(self, "SequenceTimeOverride." .. nm) or self2.GetStatL(self, "SequenceTimeOverride." .. (ani or "0"))
                    local sqro = (self2.GetStatL(self, "SequenceRateOverride." .. nm) or self2.GetStatL(self, "SequenceRateOverride." .. (ani or "0")))  
                
                    if ani == ACT_VM_RELOAD then 
                        print("ACT_VM_RELOAD!!!") 
                    end
                
                    if sqro then
                        print("SQRO!!!")
                        rate = (rate * sqro) 
                    elseif sqto then
                        print("SQTO!!!")
                        local t = self:GetActivityLengthRaw(ani, false)
                
                        if t then
                            rate = rate * t / sqto
                        end
                    end
                
                    rate = (hook.Run("TFA_AnimationRate", self, ani, rate) or rate) * base_rarity_mod_num * reload_speed_mod 
                
                    return rate
                end 

                function SWEP:Recoil(recoil, ifp)
                    if sp and type(recoil) == "string" then
                        local _, CurrentRecoil = self:CalculateConeRecoil()
                        self:Recoil(CurrentRecoil, true)
                
                        return
                    end
                
                    local owner = self:GetOwner()
                    local isplayer = owner:IsPlayer()
                
                    self:SetSpreadRatio(l_mathClamp(self:GetSpreadRatio() + self:GetStatL("Primary.SpreadIncrement"), 1, self:GetStatL("Primary.SpreadMultiplierMax")))
                    self:QueueRecoil(-owner:GetAimVector() * self:GetStatL("Primary.Knockback") * cv_forcemult:GetFloat() * recoil / 5)
                
                    local seed = self:GetSeed() + 1
                
                    local kickP = util.SharedRandom("TFA_KickDown", self:GetStatL("Primary.KickDown"), self:GetStatL("Primary.KickUp"), seed) * recoil * -1
                    local kickY = util.SharedRandom("TFA_KickHorizontal", -self:GetStatL("Primary.KickHorizontal"), self:GetStatL("Primary.KickHorizontal"), seed) * recoil
                
                    if isplayer then
                        kickP, kickY = kickP * sv_tfa_recoil_mul_p:GetFloat(), kickY * sv_tfa_recoil_mul_y:GetFloat()
                    else
                        kickP, kickY = kickP * sv_tfa_recoil_mul_p_npc:GetFloat(), kickY * sv_tfa_recoil_mul_y_npc:GetFloat()
                    end
                
                    local factor = (1 - self:GetStatL("Primary.StaticRecoilFactor")) 
                
                    if self:GetIronSights() then
                        factor = factor * Lerp(self:GetIronSightsProgress(), 1, self:GetStatL("Primary.IronRecoilMultiplier", 0.5))
                    end
                
                    factor = (factor * Lerp(self:GetCrouchingRatio(), 1, self:GetStatL("CrouchAccuracyMultiplier", 0.5))) / base_rarity_mod_num
                
                    local punchY = kickY * factor
                    local deltaP = 0
                    local deltaY = 0
                
                    if self:HasRecoilLUT() then
                        local ang = self:GetRecoilLUTAngle()
                
                        if self:GetPrevRecoilAngleTime() < CurTime() then
                            self:SetPrevRecoilAngleTime(CurTime() + 0.1)
                            self:SetPrevRecoilAngle(ang)
                        end
                
                        local prev_recoil_angle = self:GetPrevRecoilAngle()
                        deltaP = ang.p - prev_recoil_angle.p
                        deltaY = ang.y - prev_recoil_angle.y
                        self:SetPrevRecoilAngle(ang)
                    end
                
                    if isplayer then
                        local maxdist = math.min(math.max(0, 89 + owner:EyeAngles().p - math.abs(owner:GetViewPunchAngles().p * 2)), 88.5)
                        local punchP = l_mathClamp((kickP + deltaP * self:GetStatL("Primary.RecoilLUT_ViewPunchMult")) * factor, -maxdist, maxdist)
                
                        owner:ViewPunch(Angle(punchP * sv_tfa_recoil_viewpunch_mul:GetFloat(), (punchY + deltaY * self:GetStatL("Primary.RecoilLUT_ViewPunchMult")) * sv_tfa_recoil_viewpunch_mul:GetFloat()))
                    end
                
                    if (not isplayer or not sv_tfa_recoil_legacy:GetBool()) and not self:HasRecoilLUT() then
                        local maxdist2 = l_mathClamp(30 - math.abs(self:GetViewPunchP()), 0, 30)
                        local punchP2 = l_mathClamp(kickP, -maxdist2, maxdist2) * factor
                
                        self:SetViewPunchP(self:GetViewPunchP() + punchP2 * 1.5)
                        self:SetViewPunchY(self:GetViewPunchY() + punchY * 1.5)
                        self:SetViewPunchBuild(math.min(3, self:GetViewPunchBuild() + math.sqrt(math.pow(punchP2, 2) + math.pow(punchY, 2)) / 3) + 0.2)
                    end
                
                    if isplayer and ((game.SinglePlayer() and SERVER) or (CLIENT and ifp)) then
                        local neweyeang = owner:EyeAngles()
                
                        local ap, ay = (kickP + deltaP * self:GetStatL("Primary.RecoilLUT_AnglePunchMult")) * self:GetStatL("Primary.StaticRecoilFactor") * sv_tfa_recoil_eyeangles_mul:GetFloat(),
                                        (kickY + deltaY * self:GetStatL("Primary.RecoilLUT_AnglePunchMult")) * self:GetStatL("Primary.StaticRecoilFactor") * sv_tfa_recoil_eyeangles_mul:GetFloat()
                
                        neweyeang.p = neweyeang.p + ap
                        neweyeang.y = neweyeang.y + ay
                        --neweyeang.p = l_mathClamp(neweyeang.p, -90 + math.abs(owner:GetViewPunchAngles().p), 90 - math.abs(owner:GetViewPunchAngles().p))
                        owner:SetEyeAngles(neweyeang)
                    end
                end

                function SWEP:ProcessStatus()
                    local self2 = self:GetTable()
                
                    is = self2.GetIronSightsRaw(self)
                    spr = self2.GetSprinting(self)
                    wlk = self2.GetWalking(self)
                    cst = self2.GetCustomizing(self)
                
                    local ply = self:GetOwner()
                    local isplayer = ply:IsPlayer()
                
                    if stat == TFA.Enum.STATUS_FIDGET and is then
                        self:SetStatusEnd(0)
                
                        self2.Idle_Mode_Old = self2.Idle_Mode
                        self2.Idle_Mode = TFA.Enum.IDLE_BOTH
                        self2.ClearStatCache(self, "Idle_Mode")
                        self2.ChooseIdleAnim(self)
                
                        if sp then
                            self:CallOnClient("ChooseIdleAnim", "")
                        end
                
                        self2.Idle_Mode = self2.Idle_Mode_Old
                        self2.ClearStatCache(self, "Idle_Mode")
                        self2.Idle_Mode_Old = nil
                        statend = -1
                    end
                
                    is = self:GetIronSights()
                    stat = self:GetStatus()
                    statend = self:GetStatusEnd()
                
                    ct = l_CT()
                
                    if stat ~= TFA.Enum.STATUS_IDLE and ct > statend then
                        self:SetFirstDeployEvent(false)
                        finalstat = TFA.Enum.STATUS_IDLE
                
                        --Holstering
                        if stat == TFA.Enum.STATUS_HOLSTER then                            
                            -- print("PROCESS A_2")
                            finalstat = TFA.Enum.STATUS_HOLSTER_READY
                            self:SetStatusEnd(ct)
                        elseif stat == TFA.Enum.STATUS_HOLSTER_READY then                            
                            -- print("PROCESS A_1")
                            self2.FinishHolster(self)
                            finalstat = TFA.Enum.STATUS_HOLSTER_FINAL
                            self:SetStatusEnd(ct + 0.6)
                        elseif stat == TFA.Enum.STATUS_RELOADING_LOOP_START_EMPTY then
                            --Shotgun Reloading from empty
                            if not self2.IsJammed(self) then
                                self2.InsertPrimaryAmmo(self, self2.GetStatL(self, "LoopedReloadInsertAmount", 1))
                                
                                -- print("PROCESS A_3")
                            end
                
                            if self2.Ammo1(self) <= 0 or self:Clip1() >= self2.GetPrimaryClipSize(self) or self:GetReloadLoopCancel() then
                                -- print("PROCESS 1")
                                finalstat = TFA.Enum.STATUS_RELOADING_LOOP_END
                                local _, tanim, ttype = self2.ChooseShotgunPumpAnim(self)
                                self:SetStatusEnd(ct + self2.GetActivityLength(self, tanim, false, ttype))
                                self:SetReloadLoopCancel(false)
                
                                if not self:GetReloadLoopCancel() then
                                    self:SetJammed(false)
                                end
                            else
                                -- print("PROCESS 2")
                                lact = self:GetLastActivity()
                                waittime = self2.GetActivityLength(self, lact, false) - self2.GetActivityLength(self, lact, true)
                
                                if waittime > 0.01 then
                                    finalstat = TFA.Enum.STATUS_RELOADING_WAIT
                                    self:SetStatusEnd(ct + waittime)
                                else
                                    finalstat = self2.LoadShell(self)
                                end
                
                                self:SetJammed(false)
                                --finalstat = self:LoadShell()
                                --self:SetStatusEnd( self:GetNextPrimaryFire() )
                            end
                        elseif stat == TFA.Enum.STATUS_RELOADING_LOOP_START then
                            --Shotgun Reloading
                            finalstat = self2.LoadShell(self)
                            -- print("PROCESS 3")
                        elseif stat == TFA.Enum.STATUS_RELOADING_LOOP then
                            -- print("PROCESS 4")
                            self2.InsertPrimaryAmmo(self, self2.GetStatL(self, "LoopedReloadInsertAmount", 1))
                            lact = self:GetLastActivity()
                
                            if self2.GetActivityLength(self, lact, true) < self2.GetActivityLength(self, lact, false) - 0.01 then
                                -- print("PROCESS 4_1A")
                                local sht = self2.GetStatL(self, "LoopedReloadInsertTime")
                
                                if sht then
                                    sht = sht / self2.GetAnimationRate(self, ACT_VM_RELOAD)
                                end
                
                                waittime = (sht or self2.GetActivityLength(self, lact, false)) - self2.GetActivityLength(self, lact, true)
                            else
                                -- print("PROCESS 4_2A")
                                waittime = 0
                            end
                
                            if waittime > 0.01 then
                                finalstat = TFA.Enum.STATUS_RELOADING_WAIT
                                self:SetStatusEnd(ct + waittime)
                                
                                -- print("PROCESS 4_3A")
                            else
                                if self2.Ammo1(self) <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetReloadLoopCancel() then
                                    -- print("PROCESS 4A")
                                    finalstat = TFA.Enum.STATUS_RELOADING_LOOP_END
                                    local _, tanim, ttype = self2.ChooseShotgunPumpAnim(self)
                                    self:SetStatusEnd(ct + self2.GetActivityLength(self, tanim, false, ttype))
                                    self:SetReloadLoopCancel(false)
                                else
                                    -- print("PROCESS 4B")
                                    finalstat = self2.LoadShell(self)
                                end
                            end
                        elseif stat == TFA.Enum.STATUS_RELOADING then
                            -- print("PROCESS 5")
                            self2.CompleteReload(self)
                            lact = self:GetLastActivity()
                            waittime = self2.GetActivityLength(self, lact, false) - self2.GetActivityLength(self, lact, true)
                
                            if waittime > 0.01 then
                                finalstat = TFA.Enum.STATUS_RELOADING_WAIT
                                self:SetStatusEnd(ct + waittime)
                            end
                        elseif stat == TFA.Enum.STATUS_SILENCER_TOGGLE then
                            -- print("PROCESS 6")
                            --self:SetStatusEnd( self:GetNextPrimaryFire() )
                            self:SetSilenced(not self:GetSilenced())
                            self2.Silenced = self:GetSilenced()
                        elseif stat == TFA.Enum.STATUS_RELOADING_WAIT and self:GetStatL("LoopedReload") then
                            -- print("PROCESS 7")
                            if self2.Ammo1(self) <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetReloadLoopCancel() then
                                -- print("PROCESS 8")
                                finalstat = TFA.Enum.STATUS_RELOADING_LOOP_END
                                local _, tanim, ttype = self2.ChooseShotgunPumpAnim(self)
                                self:SetStatusEnd(ct + self2.GetActivityLength(self, tanim, false, ttype))
                                --self:SetReloadLoopCancel( false )
                            else
                                -- print("PROCESS 9")
                                finalstat = self2.LoadShell(self)
                            end
                        elseif stat == TFA.Enum.STATUS_RELOADING_LOOP_END and self:GetStatL("LoopedReload") then
                            -- print("PROCESS 10")
                            self:SetReloadLoopCancel(false)
                        elseif self2.GetStatL(self, "PumpAction") and stat == TFA.Enum.STATUS_PUMP then
                            -- print("PROCESS 11")
                            self:SetReloadLoopCancel(false)
                        elseif stat == TFA.Enum.STATUS_SHOOTING and self2.GetStatL(self, "PumpAction") then
                            -- print("PROCESS 12")
                            if self:Clip1() == 0 and self2.GetStatL(self, "PumpAction").value_empty then
                                -- print("PROCESS 13")
                                --finalstat = TFA.Enum.STATUS_PUMP_READY
                                self:SetReloadLoopCancel(true)
                            elseif (self2.GetStatL(self, "Primary.ClipSize") < 0 or self:Clip1() > 0) and self2.GetStatL(self, "PumpAction").value then
                                -- print("PROCESS 14")
                                --finalstat = TFA.Enum.STATUS_PUMP_READY
                                self:SetReloadLoopCancel(true)
                            end
                        end
                        -- print("PROCESS 15")
                
                        --self:SetStatusEnd( math.huge )
                        self:SetStatus(finalstat)
                
                        local sightsMode = self2.GetStatL(self, "Sights_Mode")
                        local sprintMode = self2.GetStatL(self, "Sprint_Mode")
                        local walkMode = self2.GetStatL(self, "Walk_Mode")
                        local customizeMode = self2.GetStatL(self, "Customize_Mode")
                
                        local smi = sightsMode ~= TFA.Enum.LOCOMOTION_LUA
                        local spi = sprintMode ~= TFA.Enum.LOCOMOTION_LUA
                        local wmi = walkMode ~= TFA.Enum.LOCOMOTION_LUA
                        local cmi = customizeMode ~= TFA.Enum.LOCOMOTION_LUA
                
                        if
                            not TFA.Enum.ReadyStatus[stat] and
                            stat ~= TFA.Enum.STATUS_SHOOTING and
                            stat ~= TFA.Enum.STATUS_PUMP and
                            finalstat == TFA.Enum.STATUS_IDLE and
                            ((smi or spi) or (cst and cmi))
                        then
                            is = self2.GetIronSights(self, true)
                
                            if (is and smi) or (spr and spi) or (wlk and wmi) or (cst and cmi) then
                                local success, _ = self2.Locomote(self, is and smi, is, spr and spi, spr, wlk and wmi, wlk, cst and cmi, cst)
                
                                if success == false then
                                    self:SetNextIdleAnim(-1)
                                else
                                    self:SetNextIdleAnim(math.max(self:GetNextIdleAnim(), ct + 0.1))
                                end
                            end
                        end
                
                        self2.LastBoltShoot = nil
                
                        if self:GetBurstCount() > 0 then
                            if finalstat ~= TFA.Enum.STATUS_SHOOTING and finalstat ~= TFA.Enum.STATUS_IDLE then
                                self:SetBurstCount(0)
                            elseif self:GetBurstCount() < self:GetMaxBurst() and self:Clip1() > 0 then
                                self:PrimaryAttack()
                            else
                                self:SetBurstCount(0)
                                self:SetNextPrimaryFire(self2.GetNextCorrectedPrimaryFire(self, self2.GetBurstDelay(self)))
                            end
                        end
                    end
                
                    --if stat == TFA.Enum.STATUS_IDLE and self:GetReloadLoopCancel() and (self2.GetStatL(self, "AllowSprintAttack") or self:GetSprintProgress() < 0.1) then
                    if stat == TFA.Enum.STATUS_IDLE and self:GetReloadLoopCancel() then
                        if self2.GetStatL(self, "PumpAction") then
                            if ct > self:GetNextPrimaryFire() and not self:KeyDown(IN_ATTACK) then
                                self2.DoPump(self)
                            end
                        else
                            self:SetReloadLoopCancel(false)
                        end
                    end
                end

                function SWEP:Reload(released)
                    local self2 = self:GetTable()
                
                    self:PreReload(released)
                
                    if hook.Run("TFA_PreReload", self, released) then return end
                
                    local isplayer = self:GetOwner():IsPlayer()
                    local vm = self2.VMIV(self)
                
                    if isplayer and not vm then return end
                
                    if not self:IsJammed() then
                        if self:Ammo1() <= 0 then return end
                        if self:GetStatL("Primary.ClipSize") < 0 then return end
                    end
                
                    if not released and not self:GetLegacyReloads() then return end
                    if self:GetLegacyReloads() and not dryfire_cvar:GetBool() and not self:KeyDown(IN_RELOAD) then return end
                    if self:KeyDown(IN_USE) then return end

                    print("RELOADING")
                
                    ct = l_CT()
                    stat = self:GetStatus()
                
                    if self:GetStatL("PumpAction") and self:GetReloadLoopCancel() then
                        if stat == TFA.Enum.STATUS_IDLE then
                            self:DoPump()
                        end
                    elseif TFA.Enum.ReadyStatus[stat] or (stat == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting()) or self:IsJammed() then
                        if self:Clip1() < self:GetPrimaryClipSize() or self:IsJammed() then
                            if hook.Run("TFA_Reload", self) then return end
                            self:SetBurstCount(0)
                
                            if self:GetStatL("LoopedReload") then
                                local _, tanim, ttype = self:ChooseShotgunReloadAnim()
                
                                if self:GetStatL("ShotgunStartAnimShell") then
                                    self:SetStatus(TFA.Enum.STATUS_RELOADING_LOOP_START_EMPTY)
                                elseif self2.ShotgunEmptyAnim then
                                    local _, tg = self:ChooseAnimation("reload_empty")
                                    local action = tanim
                
                                    if type(tg) == "string" and tonumber(tanim) and tonumber(tanim) > 0 and isplayer then
                                        if ttype == TFA.Enum.ANIMATION_ACT then
                                            action = vm:GetSequenceName(vm:SelectWeightedSequenceSeeded(tanim, self:GetSeedIrradical()))
                                        else
                                            action = vm:GetSequenceName(tanim)
                                        end
                                    end
                
                                    if action == tg and self:GetStatL("ShotgunEmptyAnim_Shell") then
                                        self:SetStatus(TFA.Enum.STATUS_RELOADING_LOOP_START_EMPTY)
                                    else
                                        self:SetStatus(TFA.Enum.STATUS_RELOADING_LOOP_START)
                                    end
                                else
                                    self:SetStatus(TFA.Enum.STATUS_RELOADING_LOOP_START)
                                end
                
                                self:SetStatusEnd(ct + self:GetActivityLength(tanim, true, ttype))
                                --self:SetNextPrimaryFire(ct + self:GetActivityLength( tanim, false ) )
                            else
                                local _, tanim, ttype = self:ChooseReloadAnim()
                
                                self:SetStatus(TFA.Enum.STATUS_RELOADING)
                
                                if self:GetStatL("IsProceduralReloadBased") then
                                    self:SetStatusEnd(ct + self:GetStatL("ProceduralReloadTime"))
                                else
                                    self:SetStatusEnd(ct + self:GetActivityLength(tanim, true, ttype))
                                    self:SetNextPrimaryFire(ct + self:GetActivityLength(tanim, false, ttype))
                                end
                
                                if CLIENT then
                                    self2.ReloadAnimationStart = ct
                                    self2.ReloadAnimationEnd = ct + self:GetActivityLength(tanim, false, ttype)
                                elseif sp then
                                    net.Start("tfa_reload_blending", true)
                                    net.WriteEntity(self)
                                    net.WriteDouble(ct)
                                    net.WriteDouble(ct + self:GetActivityLength(tanim, false, ttype))
                                    net.Broadcast()
                                end
                            end
                
                            self:GetOwner():SetAnimation(PLAYER_RELOAD)
                
                            if self:GetStatL("Primary.ReloadSound") and IsFirstTimePredicted() then
                                self:EmitSound(self:GetStatL("Primary.ReloadSound"))
                            end
                
                            self:ResetAnimCycle()
                
                            self:SetNextPrimaryFire( -1 )
                        elseif released or self:KeyPressed(IN_RELOAD) then--if self:GetOwner():KeyPressed(IN_RELOAD) or not self:GetLegacyReloads() then
                            self:CheckAmmo()
                        end
                    end
                
                    self:PostReload(released)
                
                    hook.Run("TFA_PostReload", self)
                end

                function SWEP:TakePrimaryAmmo(num, pool)
                    num = math.floor(num)
                    if num == 0 then return 0 end

                    if ply.held_bloody_ammo then 
                        if self:Clip1() == num then 
                            if not ply.bloody_ammo_num_shots then 
                                ply.bloody_ammo_num_shots = 0
                            end

                            ply.bloody_ammo_num_shots = ply.bloody_ammo_num_shots + 1

                            if ply.bloody_ammo_num_shots % 6 == 0 then 
                                ply.bloody_ammo_num_shots = 0
                                ply:SetHealth(ply:Health() - ply:Health() * ply:GetNWFloat(gl .. "bloody_ammo_mul"))
                            end

                            return 0 
                        end
                    end
                
                    if num < 0 then
                        -- Doesn't use clips
                        if self:GetStatL("Primary.ClipSize") < 0 or pool then
                            if not self:GetOwner():IsPlayer() then return -num end -- assume NPCs always take all the ammo
                            return self:GetOwner():GiveAmmo(-num, self:GetPrimaryAmmoTypeC())
                        else
                            local old = self:Clip1()
                            local new = math.max(self:Clip1() - num, 0)
                            self:SetClip1(new)
                            return new - old
                        end
                    else
                        -- Doesn't use clips
                        if self:GetStatL("Primary.ClipSize") < 0 or pool then
                            if not self:GetOwner():IsPlayer() then return num end -- assume NPCs always provide all the ammo
                            local old = self:Ammo1()
                            if old <= 0 then return 0 end
                            local toRemove = math.min(old, num)
                            self:GetOwner():RemoveAmmo(toRemove, self:GetPrimaryAmmoTypeC())
                            return toRemove
                        else
                            if ply.held_genesis and math.random() <= ply:GetNWFloat(gl .. "genesis_mul") then 
                                if ply.held_advanced_depot then 
                                    ply:GiveAmmo(math.Round(num * ply:GetNWFloat(gl .. "genesis_mul_2")))
                                else 
                                    self:SetClip1(self:Clip1() + self:Clip1() * ply:GetNWFloat(gl .. "genesis_mul_2"))
                                end
                            end

                            if ply.held_advanced_depot then 
                                local old = self:Clip1()
                                local new = math.max(self:Clip1() - 0, 0)
                                self:SetClip1(new)
                                --
                                ply:RemoveAmmo(num, self:GetPrimaryAmmoType())
                                return old - new
                            else
                                local old = self:Clip1()
                                local new = math.max(self:Clip1() - num, 0)
                                self:SetClip1(new)
                                return old - new
                            end
                        end
                    end
                end

                function SWEP:GetPrimaryClipSize(calc)
                    local targetclip = math.Round(self:GetStatL("Primary.ClipSize") * garlic_like_get_wep_bonus_value(ply, "mag_upgrade") * base_rarity_mod_num)
                
                    if self:CanChamber() and not (calc and self:Clip1() <= 0) then
                        targetclip = targetclip + (self:GetStatL("IsAkimbo") and 2 or 1)
                    end
                
                    return math.max(targetclip, -1)
                end
                
                function SWEP:GetPrimaryClipSizeForReload(calc)
                    local targetclip = math.Round(self:GetStatL("Primary.ClipSize") * garlic_like_get_wep_bonus_value(ply, "mag_upgrade") * base_rarity_mod_num)
                
                    if self:CanChamber() and not (calc and self:Clip1() <= 0) and not self:IsJammed() then
                        targetclip = targetclip + (self:GetStatL("IsAkimbo") and 2 or 1)
                    end
                
                    return math.max(targetclip, -1)
                end

                function SWEP:GetSecondaryClipSize(calc)
                    local targetclip = math.Round(self:GetStatL("Secondary.ClipSize") * garlic_like_get_wep_bonus_value(ply, "mag_upgrade") * base_rarity_mod_num)
                
                    return math.max(targetclip, -1)
                end

                local function BallisticFirebullet(ply, bul, ovr, angPreserve)
                    local wep = ply:GetActiveWeapon()
                
                    if TFA.Ballistics and TFA.Ballistics:ShouldUse(wep) then
                        if ballistics_distcv:GetInt() == -1 or util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 0x7fff, ply).HitPos:Distance(ply:GetShootPos()) > (ballistics_distcv:GetFloat() * TFA.Ballistics.UnitScale) then
                            bul.SmokeParticle = bul.SmokeParticle or wep.BulletTracer or wep.TracerBallistic or wep.BallisticTracer or wep.BallisticsTracer
                
                            if ovr then
                                TFA.Ballistics:FireBullets(wep, bul, angPreserve or angle_zero, true)
                            else
                                TFA.Ballistics:FireBullets(wep, bul, angPreserve)
                            end
                        else
                            ply:FireBullets(bul)
                        end
                    else
                        ply:FireBullets(bul)
                    end
                end

                function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
                    if not IsFirstTimePredicted() and not game.SinglePlayer() then return end
                    num_bullets = num_bullets or 1
                    aimcone = aimcone or 0
                
                    self:SetLastGunFire(CurTime())
                
                    if self:GetStatL("Primary.Projectile") then
                        if CLIENT then return end
                
                        for _ = 1, num_bullets do
                            local ent = ents.Create(self:GetStatL("Primary.Projectile"))
                
                            local ang = self:GetOwner():GetAimVector():Angle()
                
                            if not sv_tfa_recoil_legacy:GetBool() then
                                ang.p = ang.p + self:GetViewPunchP()
                                ang.y = ang.y + self:GetViewPunchY()
                            end
                
                            ang:RotateAroundAxis(ang:Right(), -aimcone / 2 + math.Rand(0, aimcone))
                            ang:RotateAroundAxis(ang:Up(), -aimcone / 2 + math.Rand(0, aimcone))
                
                            ent:SetPos(self:GetOwner():GetShootPos())
                            ent:SetOwner(self:GetOwner())
                            ent:SetAngles(ang)
                            ent.damage = self:GetStatL("Primary.Damage")
                            ent.mydamage = self:GetStatL("Primary.Damage")
                
                            if self:GetStatL("Primary.ProjectileModel") then
                                ent:SetModel(self:GetStatL("Primary.ProjectileModel"))
                            end
                
                            self:PreSpawnProjectile(ent)
                
                            ent:Spawn()
                
                            local dir = ang:Forward()
                            dir:Mul(self:GetStatL("Primary.ProjectileVelocity"))
                
                            ent:SetVelocity(dir)
                            local phys = ent:GetPhysicsObject()
                
                            if IsValid(phys) then
                                phys:SetVelocity(dir)
                            end
                
                            if self.ProjectileModel then
                                ent:SetModel(self:GetStatL("Primary.ProjectileModel"))
                            end
                
                            ent:SetOwner(self:GetOwner())
                
                            self:PostSpawnProjectile(ent)
                        end
                        -- Source
                        -- Dir of self.MainBullet
                        -- Aim Cone X
                        -- Aim Cone Y
                        -- Show a tracer on every x bullets
                        -- Amount of force to give to phys objects
                
                        return
                    end
                
                    if self.Tracer == 1 then
                        TracerName = "Ar2Tracer"
                    elseif self.Tracer == 2 then
                        TracerName = "AirboatGunHeavyTracer"
                    else
                        TracerName = "Tracer"
                    end
                
                    self.MainBullet.PCFTracer = nil
                
                    if self:GetStatL("TracerName") and self:GetStatL("TracerName") ~= "" then
                        if self:GetStatL("TracerPCF") then
                            TracerName = nil
                            self.MainBullet.PCFTracer = self:GetStatL("TracerName")
                            self.MainBullet.Tracer = 0
                        else
                            TracerName = self:GetStatL("TracerName")
                        end
                    end
                
                    local owner = self:GetOwner()
                
                    self.MainBullet.Attacker = owner
                    self.MainBullet.Inflictor = self
                    self.MainBullet.Src = owner:GetShootPos()
                
                    self.MainBullet.Dir = self:GetAimVector()
                    self.MainBullet.HullSize = self:GetStatL("Primary.HullSize") or 0
                    self.MainBullet.Spread.x = 0
                    self.MainBullet.Spread.y = 0
                
                    self.MainBullet.Num = 1
                
                    if num_bullets == 1 then
                        local dYaw, dPitch = self:ComputeBulletDeviation(1, 1, aimcone)
                
                        local ang = self.MainBullet.Dir:Angle()
                        local up, right = ang:Up(), ang:Right()
                
                        ang:RotateAroundAxis(up, dYaw)
                        ang:RotateAroundAxis(right, dPitch)
                
                        self.MainBullet.Dir = ang:Forward()
                    end
                
                    self.MainBullet.Wep = self
                
                    if self.TracerPCF then
                        self.MainBullet.Tracer = 0
                    else
                        self.MainBullet.Tracer = self:GetStatL("TracerCount") or 3
                    end

                    --* modify gun base damage here 
                    damage = damage * base_rarity_mod_num 
                
                    self.MainBullet.TracerName = TracerName
                    self.MainBullet.PenetrationCount = 0
                    self.MainBullet.PenetrationPower = self:GetStatL("Primary.PenetrationPower") * sv_tfa_bullet_penetration_power_mul:GetFloat(1)
                    self.MainBullet.InitialPenetrationPower = self.MainBullet.PenetrationPower
                    self.MainBullet.AmmoType = self:GetPrimaryAmmoType()
                    self.MainBullet.Force = self:GetStatL("Primary.Force") * cv_forcemult:GetFloat() * self:GetAmmoForceMultiplier()
                    self.MainBullet.Damage = damage  
                    self.MainBullet.InitialDamage = damage
                    self.MainBullet.InitialForce = self.MainBullet.Force
                    self.MainBullet.InitialPosition = Vector(self.MainBullet.Src)
                    self.MainBullet.HasAppliedRange = false
                
                    if self.CustomBulletCallback then
                        self.MainBullet.Callback2 = self.CustomBulletCallback
                    else
                        self.MainBullet.Callback2 = nil
                    end
                
                    if num_bullets > 1 then
                        local ang_ = self.MainBullet.Dir:Angle()
                        local up, right = ang_:Up(), ang_:Right()
                
                        -- single callback per multiple bullets fix
                        for i = 1, num_bullets do
                            local bullet = table.Copy(self.MainBullet)
                
                            local ang = Angle(ang_)
                
                            local dYaw, dPitch = self:ComputeBulletDeviation(i, num_bullets, aimcone)
                            ang:RotateAroundAxis(up, dYaw)
                            ang:RotateAroundAxis(right, dPitch)
                
                            bullet.Dir = ang:Forward()
                
                            function bullet.Callback(attacker, trace, dmginfo)
                                if not IsValid(self) then return end
                
                                dmginfo:SetInflictor(self)
                                dmginfo:SetDamage(dmginfo:GetDamage() * bullet:CalculateFalloff(trace.HitPos))
                
                                if bullet.Callback2 then
                                    bullet.Callback2(attacker, trace, dmginfo)
                                end
                
                                self:CallAttFunc("CustomBulletCallback", attacker, trace, dmginfo)
                
                                bullet:Penetrate(attacker, trace, dmginfo, self, {})
                                self:PCFTracer(bullet, trace.HitPos or vector_origin)
                            end
                
                            BallisticFirebullet(owner, bullet, nil, ang)
                        end
                
                        return
                    end
                
                    function self.MainBullet.Callback(attacker, trace, dmginfo)
                        if not IsValid(self) then return end
                
                        dmginfo:SetInflictor(self)
                        dmginfo:SetDamage(dmginfo:GetDamage() * self.MainBullet:CalculateFalloff(trace.HitPos))
                
                        if self.MainBullet.Callback2 then
                            self.MainBullet.Callback2(attacker, trace, dmginfo)
                        end
                
                        self:CallAttFunc("CustomBulletCallback", attacker, trace, dmginfo)
                
                        self.MainBullet:Penetrate(attacker, trace, dmginfo, self, {})
                        self:PCFTracer(self.MainBullet, trace.HitPos or vector_origin)
                    end
                
                    BallisticFirebullet(owner, self.MainBullet)
                end

                function SWEP:Strike(attk, precision)
                    local hitWorld, hitNonWorld, hitFlesh, needsCB
                    local distance, direction, maxhull
                    local ow = self:GetOwner()
                    if not IsValid(ow) then return end
                    distance = attk.len * base_rarity_mod_num
                    direction = attk.dir
                    maxhull = attk.hull
                    eang = ow:EyeAngles()
                    fwd = ow:EyeAngles():Forward()
                    tr.start = ow:GetShootPos()
                    scl = direction:Length() / precision / 2
                    tr.maxs = Vector(scl, scl, scl)
                    tr.mins = -tr.maxs
                    tr.mask = MASK_SHOT
                    tr.filter = {self, ow}

                    hitWorld = false
                    hitNonWorld = false
                    hitFlesh = false

                    if attk.callback then
                        needsCB = true
                    else
                        needsCB = false
                    end

                    if maxhull then
                        tr.maxs.x = math.min(tr.maxs.x, maxhull / 2)
                        tr.maxs.y = math.min(tr.maxs.y, maxhull / 2)
                        tr.maxs.z = math.min(tr.maxs.z, maxhull / 2)
                        tr.mins = -tr.maxs
                    end

                    strikedir:Zero()
                    strikedir:Add(direction.x * eang:Right())
                    strikedir:Add(direction.y * eang:Forward())
                    strikedir:Add(direction.z * eang:Up())
                    local strikedirfull = strikedir * 1

                    if ow:IsPlayer() and ow:IsAdmin() and GetConVarNumber("developer") > 0 then
                        local spos, epos = tr.start + Vector(0, 0, -1) + fwd * distance / 2 - strikedirfull / 2, tr.start + Vector(0, 0, -1) + fwd * distance / 2 + strikedirfull / 2
                        debugoverlay.Line(spos, epos, 5, Color(255, 0, 0))
                        debugoverlay.Cross(spos, 8, 5, Color(0, 255, 0), true)
                        debugoverlay.Cross(epos, 4, 5, Color(0, 255, 255), true)
                    end

                    if SERVER and not game.SinglePlayer() and ow:IsPlayer() then
                        ow:LagCompensation(true)
                    end

                    local totalResults = {}
                    for i = 1, precision do
                        dirv = LerpVector((i - 0.5) / precision, -direction / 2, direction / 2)
                        strikedir:Zero()
                        strikedir:Add(dirv.x * eang:Right())
                        strikedir:Add(dirv.y * eang:Forward())
                        strikedir:Add(dirv.z * eang:Up())
                        tr.endpos = tr.start + distance * fwd + strikedir
                        traceres = util.TraceLine(tr)
                        table.insert(totalResults, traceres)
                    end

                    if SERVER and not game.SinglePlayer() and ow:IsPlayer() then
                        ow:LagCompensation(false)
                    end

                    local basedmg = attk.dmg

                    local ind = self:GetMelAttackID() or 1
                    local srctbl = ind >= 0 and "Primary" or "Secondary"
                    if not self:GetStatL(srctbl .. ".SplitDamage") or not basedmg then
                        basedmg = self:GetStatL(srctbl .. ".Damage")
                    end

                    local dmg = basedmg * util.SharedRandom("TFA_Melee_RandomDamageMult" .. CurTime(), cv_dmg_mult_min:GetFloat(), cv_dmg_mult_max:GetFloat(), self:EntIndex())
                    if ow:IsNPC() then
                        dmg = dmg * cv_dmg_mult_npc:GetFloat()
                    else
                        dmg = dmg * cv_dmg_mult:GetFloat()
                    end

                    local forcevec = strikedirfull:GetNormalized() * (attk.force or basedmg / 4) * 128
                    local damage = DamageInfo()
                    damage:SetAttacker(self:GetOwner())
                    damage:SetInflictor(self)
                    damage:SetDamage(dmg * base_rarity_mod_num)
                    damage:SetDamageType(attk.dmgtype or DMG_SLASH)
                    damage:SetDamageForce(forcevec)
                    local fleshHits = 0

                    --Handle flesh
                    for _, v in ipairs(totalResults) do
                        if v.Hit and IsValid(v.Entity) and TraceHitFlesh(v) and (not v.Entity.TFA_HasMeleeHit) then
                            self:ApplyDamage(v, damage, attk)
                            self:SmackEffect(v, damage)
                            v.Entity.TFA_HasMeleeHit = true
                            fleshHits = fleshHits + 1
                            if fleshHits >= (attk.maxhits or 3) then break end

                            if attk.hitflesh and not hitFlesh then
                                self:EmitSoundNet(attk.hitflesh)
                            end

                            if attk.callback and needsCB then
                                attk.callback(attk, self, v)
                                needsCB = false
                            end

                            hitFlesh = true
                        end
                        --debugoverlay.Sphere( v.HitPos, 5, 5, color_white )
                    end

                    --Handle non-world
                    for _, v in ipairs(totalResults) do
                        if v.Hit and (not TraceHitFlesh(v)) and (not v.Entity.TFA_HasMeleeHit) then
                            self:ApplyDamage(v, damage, attk)
                            v.Entity.TFA_HasMeleeHit = true

                            if not hitNonWorld then
                                self:SmackEffect(v, damage)

                                if attk.hitworld and not hitFlesh then
                                    self:EmitSoundNet(attk.hitworld)
                                end

                                if attk.callback and needsCB then
                                    attk.callback(attk, self, v)
                                    needsCB = false
                                end

                                self:BurstDoor(v.Entity, damage)
                                hitNonWorld = true
                            end
                        end
                    end

                    -- Handle world
                    if not hitNonWorld and not hitFlesh then
                        for _, v in ipairs(totalResults) do
                            if v.Hit and v.HitWorld and not hitWorld then
                                hitWorld = true

                                if attk.hitworld then
                                    self:EmitSoundNet(attk.hitworld)
                                end

                                self:SmackEffect(v, damage)

                                if attk.callback and needsCB then
                                    attk.callback(attk, self, v)
                                    needsCB = false
                                end
                            end
                        end
                    end

                    --Handle empty + cleanup
                    for _, v in ipairs(totalResults) do
                        if needsCB then
                            attk.callback(attk, self, v)
                            needsCB = false
                        end

                        if IsValid(v.Entity) then
                            v.Entity.TFA_HasMeleeHit = false
                        end
                    end

                    if attk.kickback and (hitFlesh or hitNonWorld or hitWorld) then
                        self:SendViewModelAnim(attk.kickback)
                    end
                end
            end
        end
    end
end) 

hook.Add("EntityTakeDamage", gl .. "damage_modifiers", function(ent, dmg)
    if GetConVar(gl .. "enable"):GetInt() == 0 then return end
    if FROZE_GL.tbl_repeated_dmg[dmg:GetMaxDamage()] then return end
    local attacker = dmg:GetAttacker()
 
    if (IsValid(attacker) and IsValid(ent)) and (string.find(attacker:GetClass(), "trigger") or attacker:IsWorld()) and (ent:IsNPC() or ent:IsNextBot() or table.HasValue(FROZE_GL.tbl_valid_entities, ent:GetClass())) then 
    
    end

    if (attacker:IsPlayer() or (IsValid(attacker:GetOwner()) and attacker:GetOwner():IsPlayer())) and (ent:IsNPC() or ent:IsNextBot() or table.HasValue(FROZE_GL.tbl_valid_entities, ent:GetClass())) and ((attacker:IsPlayer() and attacker.Alive and attacker:Alive()) or (attacker:GetOwner():IsPlayer() and attacker:GetOwner():Alive())) then
        ply = dmg:GetAttacker()

        if IsValid(attacker:GetOwner()) and attacker:GetOwner():IsPlayer() then 
            ply = attacker:GetOwner() 
        end

        ply_wep = ply:GetActiveWeapon()
        ply_wep_class = ply_wep:GetClass()
        mana = ply:GetNWInt(gl .. "mana")
        damage_num = dmg:GetDamage()
        if not IsValid(ply) then return end
        -- dmg:ScaleDamage(55)
        --
        local hit_chance = ply:GetNWFloat(gl .. "bonus_accuracy", 1) * (1 - GetGlobalFloat(gl .. "enemy_modifier_evasion", 0))
        -- print('hit chance: ' .. hit_chance)

        -- if miss
        if math.random() > hit_chance then 
            dmg:SetDamage(0)
            dmg:SetDamageCustom(1853) 
        else  
            ply:SetNWInt(gl .. "is_critting", 0)
            crit_chance = ply:GetNWFloat(gl .. "bonus_critical_chance") * ply:GetNWFloat(gl .. ply_wep_class .. "crit_chance", 1)
            -- crit_chance = 1
            crit_dmg = (ply:GetNWFloat(gl .. "bonus_critical_damage") + ply:GetNWFloat(gl .. "brutal_gloves_crit_damage_mod", 0)) * ply:GetNWFloat(gl .. ply_wep_class .. "crit_damage", 1)
            overcrit_damage = 1
            local preemptive_strike_mul = 1

            if ply:GetNWBool(gl .. rh .. "preemptive_strike") and ply_wep:Clip1() >= ply_wep:GetMaxClip1() then 
                preemptive_strike_mul = (1 + ply:GetNWFloat(gl .. rh .. "preemptive_strike_mul", 0))
                crit_chance = crit_chance * (1 + ply:GetNWFloat(gl .. rh .. "preemptive_strike_mul_2", 0))
            end

            dmg:ScaleDamage(1 + ply:GetNWFloat(gl .. "bonus_damage", 0) * preemptive_strike_mul * (1 - GetGlobalFloat(gl .. "enemy_modifier_resistance", 0)))
    
            if mana <= damage_num * 0.75 then
                dmg:ScaleDamage(1)
            elseif mana > damage_num * 0.75 then
                dmg:ScaleDamage(1 + ply:GetNWFloat(gl .. "bonus_mana_damage") * ply:GetNWFloat(gl .. ply_wep_class .. "damage_mana", 1))
                ply:SetNWInt(gl .. "mana", math.Round(math.max(0, mana - damage_num * 0.75)))
            end

            if ent:GetNWBool(gl .. "modifier_resistive") then 
                crit_chance = crit_chance * 0.5 
                crit_dmg = crit_dmg * 0.75
            end 

            if math.random() <= crit_chance then
                -- print("IM CRITTING!!!")
                overcrit_damage = 1
                ply:SetNWInt(gl .. "is_critting", 1)

                if crit_chance > 1 then
                    division_result = math.floor(crit_chance)
                    mod_result = crit_chance % 1
                    chance = math.random()

                    if chance <= mod_result then
                        overcrit_damage = division_result + 1
                        -- print("OVERCRIT DAMAGE: " .. overcrit_damage)
                        ply:SetNWInt(gl .. "is_critting", overcrit_damage)
                    else
                        overcrit_damage = division_result
                        ply:SetNWInt(gl .. "is_critting", overcrit_damage)
                    end
                end

                -- print("DAMAGE CUSTOM: " .. dmg:GetDamageCustom())
                --! WORK ON CRIT TIERS
                --* 7314 is custom damage to signify tier 2 crits.

                dmg:SetDamageCustom(7313 + math.min(5, overcrit_damage))
                dmg:ScaleDamage(1 * (1 + crit_dmg * overcrit_damage))
                ply:EmitSound("player/crit_hit" .. tostring(math.random(2, 5)) .. ".wav")
            end

            if ent:GetNWInt(gl .. "enemy_shield") > 0 then
                enemy_shield = ent:GetNWInt(gl .. "enemy_shield")
                ent:SetNWInt(gl .. "enemy_shield", math.max(0, ent:GetNWInt(gl .. "enemy_shield") - dmg:GetDamage()))
                dmg:SetDamage(math.max(0, dmg:GetDamage() * 0.75))
                ent.enemy_is_able_to_recharge = false

                timer.Create("enemy_shield_recharge_" .. ent:EntIndex(), 2, 1, function()
                    garlic_like_enemy_shield_recharge(ent)
                    ent.enemy_is_able_to_recharge = true
                end)
            end

            if ply:GetNWInt(gl .. "is_critting", 0) > 0 then
                dmg:SetMaxDamage(91245)
            end

            if ply:GetNWBool(gl .. rh .. "advanced_depot") then
                dmg:ScaleDamage(1 - ply:GetNWFloat(gl .. rh .. "advanced_depot_mul"))
            end

            if ply:GetNWBool(gl .. rh .. "brutal_gloves") and ply:GetNWInt(gl .. "is_critting", 0) == 1 then 
                -- print("BRUTAL GLOVES EFFECT!")
                ply:SetNWFloat(gl .. "brutal_gloves_crit_damage_mod", ply:GetNWFloat(gl .. "brutal_gloves_crit_damage_mod", 0) + ply:GetNWFloat(gl .. rh .. "brutal_gloves_mul"))

                timer.Simple(9, function() 
                    if not IsValid(ply) then return end 
                    -- 
                    ply:SetNWFloat(gl .. "brutal_gloves_crit_damage_mod", math.max(0, ply:GetNWFloat(gl .. "brutal_gloves_crit_damage_mod", 0) - ply:GetNWFloat(gl .. rh .. "brutal_gloves_mul")))
                end)
            end

            if GetConVar(gl .. "damage_random_min_maxes_enable"):GetInt() > 0 then
                dmg:ScaleDamage(math.Rand(0.9, 1.1))
            end 

            if ent.gl_poison_dmg_taken_mul then 
                dmg:ScaleDamage(1 + ent.gl_poison_dmg_taken_mul)
            end 

            -- print(math.Truncate(1.04^ply.gl_lightning_damage_buff_stacks, 2))

            if ply.gl_lightning_damage_buff_stacks and ply.gl_lightning_damage_buff_stacks > 0 then 
                -- print("math.min(5, math.Truncate(1.045^ply.gl_lightning_damage_buff_stacks, 2)) " .. math.min(5, math.Truncate(1.045^ply.gl_lightning_damage_buff_stacks, 2)))
                dmg:ScaleDamage(math.min(5, math.Truncate(1.045^ply.gl_lightning_damage_buff_stacks, 2)))
            end

            if ent.gl_lightning_debuffed then             
                -- print("(1.25 + ent.gl_lightning_debuffed_stacks / 15 )" .. (1.25 + ent.gl_lightning_debuffed_stacks / 15))
                ent.gl_lightning_debuffed_stacks = ent.gl_lightning_debuffed_stacks + 1
                dmg:ScaleDamage(1.25 + math.Truncate(ent.gl_lightning_debuffed_stacks / 15, 2))
            end

            if ent.gl_loyal_mul then 
                dmg:ScaleDamage(0.5)
            end

            if ent:GetNWBool(gl .. "modifier_armored") and ent:Health() >= ent:GetMaxHealth() * 0.5 then 
                dmg:ScaleDamage(0.35)

                if not ent.gl_armored_stacks then 
                    ent.gl_armored_stacks = 0
                end

                ent.gl_armored_stacks = math.min(250, ent.gl_armored_stacks + 1)

                dmg:ScaleDamage(1 - ent.gl_armored_stacks * 0.003)
            end

            if ent:GetNWBool(gl .. "modifier_immortal") then 
                if ent.gl_immortal then 
                    dmg:SetDamage(0)
                end

                if not ent.gl_immortal_init then 
                    ent.gl_immortal_init = true 
                    ent.gl_immortal = true 

                    timer.Simple(7, function() 
                        if not IsValid(ent) then return end 
                        ent.gl_immortal = false
                    end)
                end
            end

            if ent:GetNWBool(gl .. "modifier_agile") and math.random() <= 0.33 then 
                dmg:SetDamage(0)
            end 

            if ent:GetNWBool(gl .. "modifier_golden") then
                dmg:ScaleDamage(1 - (ent:Health() / ent:GetMaxHealth()) / 1.5)
            end

            if ent.gl_defensive_mul then 
                dmg:ScaleDamage(ent.gl_defensive_mul)
            end

            if ply_wep_class == FROZE_GL.default_gun and dmg:IsBulletDamage() then 
                dmg:ScaleDamage(1 + (ply:GetNWInt(gl .. "level")) * 0.05)
            end
    
            -- print("BONUS WEAPON DAMAGE: " .. ply:GetNWFloat(gl .. ply_wep_class .. "damage", 1))
            dmg:ScaleDamage(1 * ply:GetNWFloat(gl .. ply_wep_class .. "damage", 1)) 
            --
        end
    end

    if ent:IsPlayer() and (attacker:IsNPC() or attacker:IsNextBot() or attacker:IsPlayer()) then
        if not IsValid(ent) then return end 
        if not ent:Alive() then return end
        ply = ent
        ply_wep = ply:GetActiveWeapon()
        ply_wep_class = ply_wep:GetClass()
        ply.mana = ply:GetNWInt(gl .. "mana")
        ply.mana_resistance = 1
        damage_num = dmg:GetDamage()
        ply.block_chance = ply:GetNWFloat(gl .. "bonus_block_chance", 0) * ply:GetNWFloat(gl .. ply_wep_class .. "block_chance", 1)
        ply.block_resistance = 1
        ply.evasion_chance = ply:GetNWFloat(gl .. "bonus_evasion_chance", 0)
        ply.final_evasion = math.min(0.9, 1 - ((1 - ply.evasion_chance) - (1 - ply.evasion_chance) * (ply:GetNWFloat(gl .. ply_wep:GetClass() .. "evasion_chance", 1) - 1)))
        ply.evasion = 1 
        
        if attacker.gl_fire_hit_count then 
            ply.final_evasion = math.min(0.9, ply.final_evasion + attacker.gl_fire_hit_count * 0.0075)
        end

        if ply:GetNWBool(gl .. "spawn_dmg_reduction") then 
            dmg:ScaleDamage(0.1)
        end

        if math.random() <= ply.block_chance then
            ply:EmitSound("physics/metal/metal_canister_impact_hard" .. tostring(math.random(1, 3)) .. ".wav")
            ply.block_resistance = (1 - math.min(0.95, ply:GetNWFloat(gl .. "bonus_block_resistance", 0) * ply:GetNWFloat(gl .. ply_wep_class .. "resistance_block", 1))) * (1 - ply:GetNWFloat(gl .. "bonus_shield", 0))
        end

        if ply.garlic_like_is_dashing then
            ply.final_evasion = 1
        end

        if math.random() <= ply.final_evasion then
            ply:EmitSound("mvm/mvm_money_vanish.wav")
            ply.evasion = 0
        end 

        if ply.mana > damage_num * 0.75 and ply.evasion ~= 0 then
            ply:SetNWInt(gl .. "mana", math.Round(math.max(0, ply.mana - damage_num * 0.75)))
            ply.mana_resistance = 1 - ply:GetNWFloat(gl .. "bonus_mana_resistance", 0)
        end

        if attacker.gl_fire_dmg_dealt_reduced_mod then 
            dmg:ScaleDamage(1 - attacker.gl_fire_dmg_dealt_reduced_mod)
        end

        if ply.gl_weakened_mul then 
            dmg:ScaleDamage(ply.gl_weakened_mul)
        end

        if attacker:GetNWBool(gl .. "modifier_aggressive") then 
            dmg:ScaleDamage(1.25)
        end

        if attacker:GetNWBool(gl .. "modifier_robust") then 
            dmg:ScaleDamage(1.25)
        end

        if attacker:GetNWBool(gl .. "modifier_powerful") then 
            dmg:ScaleDamage(1.75)
        end 

        if attacker:GetNWBool(gl .. "modifier_bleed") and dmg:GetMaxDamage() ~= 152131 then 
            attacker.gl_bleed_dmginfo = DamageInfo() 
            attacker.gl_bleed_dmginfo:SetDamageType(DMG_SLASH)
            attacker.gl_bleed_dmginfo:SetAttacker(attacker)
            attacker.gl_bleed_dmginfo:SetInflictor(attacker) 
            attacker.gl_bleed_dmginfo:SetMaxDamage(152131)
            attacker.gl_bleed_dmginfo:SetDamage(dmg:GetDamage() * 0.14)

            timer.Create(gl .. "enemy_bleed_modifier", 0.5, 20, function() 
                if IsValid(attacker) and ent:Alive() then 
                    ent:TakeDamageInfo(attacker.gl_bleed_dmginfo)
                end
            end)
        end

        dmg:SetDamage(dmg:GetDamage() - ply:GetNWInt(gl .. "bonus_resistance_flat", 0) * ply:GetNWFloat(gl .. ply_wep_class .. "resistance_flatdmg", 1))
        dmg:ScaleDamage((1 - ply:GetNWFloat(gl .. "bonus_resistance", 0)) * (ply:GetNWFloat(gl .. ply_wep_class .. "resistance", 1)) * ply.mana_resistance * ply.block_resistance * ply.evasion * (1 + GetGlobalFloat(gl .. "enemy_modifier_damage", 0)) * (1 - ply:GetNWFloat(gl .. "bonus_armor", 0)) * ply:GetNWFloat(gl .. ply_wep_class .. "damage", 1))

        if ply:GetNWBool(gl .. rh .. "blade_mail") and ply ~= attacker then
            local blade_mail_damage = DamageInfo()
            blade_mail_damage:SetDamage(ply:Health() * ply:GetNWFloat(gl .. rh .. "blade_mail_mul"))
            blade_mail_damage:SetDamagePosition(attacker:EyePos())
            blade_mail_damage:SetDamageType(DMG_GENERIC)
            blade_mail_damage:SetAttacker(ply)
            blade_mail_damage:SetInflictor(ply)
            attacker:TakeDamageInfo(blade_mail_damage)
        end
    end
end)

hook.Add("PostEntityTakeDamage", gl .. "post_damage_modifiers", function(ent, dmg) 
    if GetConVar(gl .. "enable"):GetInt() == 0 then return end
    if FROZE_GL.tbl_repeated_dmg[dmg:GetMaxDamage()] then return end
    local attacker = dmg:GetAttacker()
 
    if (attacker:IsPlayer() or dmg:GetInflictor():IsPlayer()) and (ent:IsNPC() or ent:IsNextBot()) and attacker:Alive() then 
        local ply = attacker 
        local ply_wep = ply:GetActiveWeapon()
        local ent_pos = ent:GetPos()
        local ent_obbcenter = ent:LocalToWorld(ent:OBBCenter()) 
        local ent_obbmaxs = ent:LocalToWorld(ent:OBBMaxs()) 
        local ent_damagenumber_pos = Vector(ent_obbcenter.x, ent_obbcenter.y, ent_obbmaxs.z + 10)

        if ply:GetNWBool(gl .. ply_wep:GetClass() .. "fire") and dmg:GetMaxDamage() ~= 876522 then 
            -- print("PROC FIRE 11")
            garlic_like_proc_fire(ply, ent, dmg:GetDamage())   
        end

        if ply:GetNWBool(gl .. ply_wep:GetClass() .. "poison") and dmg:GetMaxDamage() ~= 876523 then 
            garlic_like_proc_poison(attacker, ent, dmg:GetDamage())
        end 

        if dmg:GetMaxDamage() ~= 876524 then 
            ply.gl_lightning_damage = math.Round(dmg:GetDamage())
            -- print(ply.gl_lightning_damage)  

            if ply:GetNWBool(gl .. ply_wep:GetClass() .. "lightning") and math.random() <= 0.09 then   
                garlic_like_proc_lightning(ply, ent, 3, false, dmg)
            end   
        end

        --* TEMPORARY VALUE, REPLACE WITH VALUE ON PLAYER
        local mh_chance = ply:GetNWFloat(gl .. "bonus_multihit_chance", 0) * ply:GetNWFloat(gl .. ply_wep:GetClass() .. "multihit", 1)

        if ent:GetNWBool(gl .. "modifier_agile") then 
            mh_chance = mh_chance * 0.5
        end

        if dmg:GetMaxDamage() ~= 884251 then 
            ent.gl_mh_chances = {}

            repeat
                table.insert(ent.gl_mh_chances, 1 + #ent.gl_mh_chances, mh_chance)
                mh_chance = mh_chance - 1
            until (mh_chance <= 0)

            -- PrintTable(ent.gl_mh_chances)
            if not ent.gl_mh_dmg_tbl then 
                ent.gl_mh_dmg_tbl = {}
                ent.gl_mh_num = 0
            end 

            for k, mh_chance in pairs(ent.gl_mh_chances) do  
                if math.random() <= mh_chance then 
                    table.insert(ent.gl_mh_dmg_tbl, #ent.gl_mh_dmg_tbl + 1, math.Round(dmg:GetDamage()))
                    -- PrintTable(ent.gl_mh_dmg_tbl)
                    ent.gl_mh_num = ent.gl_mh_num + 1      

                    timer.Simple(k * 0.15, function()
                        if not IsValid(ent) then return end 
                        --
                        local multihit = DamageInfo()
                        multihit:SetMaxDamage(884251)
                        multihit:SetAttacker(ply)
                        multihit:SetInflictor(ply)
                        multihit:SetDamageType(DMG_GENERIC) 
                        multihit:SetDamage(ent.gl_mh_dmg_tbl[ent.gl_mh_num] * 0.5)
                        ent:TakeDamageInfo(multihit)
                    end)
                end
            end 
        end

        if ply:GetNWFloat(gl .. ply_wep:GetClass() .. "lifesteal", 0) > 0 then 
            if ply:Health() < ply:GetMaxHealth() then 
                ply:SetHealth(ply:Health() + dmg:GetDamage() * (ply:GetNWFloat(gl .. ply_wep:GetClass() .. "lifesteal", 0) - 1))
            else 
                ply:SetHealth(ply:Health() + dmg:GetDamage() * (ply:GetNWFloat(gl .. ply_wep:GetClass() .. "lifesteal", 0) - 1) / 2)
            end
        end 

        --* HIGHEST DAMAGE DEALT 
        if not ply.gl_hdd then 
            ply.gl_hdd = 0
        end

        if ply.gl_hdd < dmg:GetDamage() then 
            ply.gl_hdd = dmg:GetDamage()
        end 

        --* MELEE BASE DMG REDUCTION UNLOCK
        if not garlic_like_ply_unlocked(ply, "dmg_reduction_melee") and tonumber(ply:GetPData(gl .. "total_melee_damage_dealt", 0)) < 50000 and (garlic_like_is_tfa_melee(ply_wep) or garlic_like_is_arccw_melee(ply_wep)) then 
            ply:SetPData(gl .. "total_melee_damage_dealt", tonumber(ply:GetPData(gl .. "total_melee_damage_dealt", 0) + math.Round(dmg:GetDamage())))
            print("total_melee_dealt: " .. tonumber(ply:GetPData(gl .. "total_melee_damage_dealt", 0)))
        end
    end

    if ent:IsPlayer() then 
        local ply = ent 
        local ply_hp = ply:Health() 
        local ply_maxhp = ply:GetMaxHealth() 

        if attacker:GetNWBool(gl .. "modifier_weakening") then 
            if not ply.gl_weakened_mul then 
                ply.gl_weakened_mul = 1 
            end
 
            local diff = dmg:GetDamage() / ply_maxhp
            ply.gl_weakened_mul = ply.gl_weakened_mul + diff

            garlic_like_reduce_weakening_mul(ply, diff)
        end

        if not ply.gl_tdt then 
            ply.gl_tdt = 0
        end

        ply.gl_tdt = ply.gl_tdt + dmg:GetDamage()
    end
end)

hook.Add("PostEntityTakeDamage", gl .. "damage_numbers", function(ent, dmg) 
    if GetConVar(gl .. "enable"):GetInt() == 0 then return end
    local att = dmg:GetAttacker()
    
    if att:IsPlayer() or (IsValid(att:GetOwner()) and att:GetOwner():IsPlayer()) then 
        local ply = att

        if (IsValid(att:GetOwner()) and att:GetOwner():IsPlayer()) then 
            ply = att:GetOwner()
        end
        --* DAMAGE NUMBERS
        garlic_like_create_damage_number(ply, ent, dmg)  

        --* TOTAL DAMAGE DEALT STAT
        if not ply.gl_tdd then 
            ply.gl_tdd = 0
        end

        ply.gl_tdd = ply.gl_tdd + dmg:GetDamage()

        if not garlic_like_ply_unlocked(ply, "relic_slot_8") and ply.gl_tdd >= 1000000 then 
            garlic_like_unlock(ply, gl .. "relic_slot_8", "Unlocked a Relic Slot!")
        end
    end
end) 

hook.Add("OnEntityCreated", gl .. "entity_creation", function(ent) 
    if not IsValid(ent) then return end
    if GetConVar(gl .. "enable"):GetInt() == 0 then return end

    if string.find(ent:GetClass(), "acwatt") then 
        ent:SetNWBool(gl .. "settled_2", true)
        ent:SetNWString(gl .. "item_name", "[ACWATT] " .. ent.PrintName)
    end

    if ent:IsNPC() or ent:IsNextBot() then
        timer.Simple(0, function()
            if not IsValid(ent) then return end
            maxhealth = ent:GetMaxHealth()
            ent:SetMaxHealth(maxhealth * math.random(75, 125) / 100 * (1 + GetGlobalFloat(gl .. "enemy_modifier_hp", 0)))
            ent:SetHealth(ent:GetMaxHealth())   
            ent.gl_modifier_num = 0   
             
            timer.Simple(0, function() 
                local max_modifiers = math.max(1, math.Round(GetGlobalBool(gl .. "minutes", 0) / 5))
                -- local max_modifiers = 10

                if ent:GetNWBool(gl .. "is_spawned_enemy") then 
                    for k, mod in RandomPairs(FROZE_GL.tbl_enemy_modifiers) do   
                        -- print(k)
                        if math.random() < 0.02 and ent.gl_modifier_num < max_modifiers then 
                        -- if math.random() <= 1 and ent.gl_modifier_num < max_modifiers then                             
                            ent:SetNWBool(gl .. "modifier_" .. string.lower(k), true)
                            ent.gl_modifier_num = ent.gl_modifier_num  + 1
                        end
                    end 
                end

                timer.Simple(0, function() 
                    if IsValid(ent) then  
                        if ent:GetNWBool(gl .. "modifier_shielding") then 
                            ent.garlic_like_shield_entity = ents.Create(gl .. "shield_entity")
                            ent.garlic_like_shield_entity:SetNWEntity("shield_entity", ent)
                            ent.garlic_like_shield_entity:Spawn() 
                            ent:SetNWBool(gl .. "enemy_shielded", true)
                            ent:SetNWInt(gl .. "enemy_shield_max", ent:GetMaxHealth() * math.random(750, 1250) / 1000)
                            ent:SetNWInt(gl .. "enemy_shield", ent:GetNWInt(gl .. "enemy_shield_max")) 
                        end

                        if ent:GetNWBool(gl .. "modifier_robust") then 
                            ent:SetMaxHealth(ent:GetMaxHealth() * 4)
                            ent:SetHealth(ent:GetMaxHealth())
                        end
                         
                        if ent:GetNWBool(gl .. "modifier_aggressive") or ent:GetNWBool(gl .. "modifier_powerful") then 
                            ent:SetMaxHealth(ent:GetMaxHealth() * 3)
                            ent:SetHealth(ent:GetMaxHealth())
                        end

                        if ent:GetNWBool(gl .. "modifier_agile") then 
                            ent:SetMaxHealth(ent:GetMaxHealth() * 2)
                            ent:SetHealth(ent:GetMaxHealth())
                        end

                        if ent:GetNWBool(gl .. "modifier_golden") then 
                            ent:SetNWInt(gl .. "modifier_golden_mul", 10)
                            ent:SetMaterial("models/player/shared/gold_player")
                        end
                    end
                end)
            end)
        end)
    end
end)

hook.Add("ScaleNPCDamage", gl .. "hitgroups", function(npc, hitgroup, dmg)
    if GetConVar(gl .. "enable"):GetInt() == 0 then return end
    if not dmg:GetAttacker():IsPlayer() then return end
    local ply = dmg:GetAttacker()

    if hitgroup == HITGROUP_HEAD then
        -- print("HEADSHOT")
        -- garlic_like_xp_gain(ply, math.max(1, npc:GetMaxHealth() * 0.1), "HEADSHOT")
        -- garlic_like_xp_gain(ply, math.max(1, dmg:GetDamage()), "HEADSHOT")
    end
end) 

hook.Add("OnNPCKilled", gl .. "enemy_killed", function(npc, att, infl) 
    if GetConVar(gl .. "enable"):GetInt() == 0 then return end 
    if att:IsPlayer() or (IsValid(att:GetOwner()) and att:GetOwner():IsPlayer()) then 
        -- if not GetGlobalBool(gl .. "match_running") then return end
        local ent = npc
        local target = npc
        local ply = att

        if IsValid(att:GetOwner()) then 
            ply = att:GetOwner()
        end

        local ply_wep = ply:GetActiveWeapon()
        local npc_maxhp = npc:GetMaxHealth() 
        local wep_crystal_drop_chance = math.Remap(npc_maxhp, 1, 5000000, 0.25, 1) 
        local wep_crystal_crate_drop_chance = 0.05
        local ammo_drop_chance = 1
    
        if not npc.gl_modifier_num then 
            npc.gl_modifier_num = 0
        end

        --* create arccw ply tbl list
        if not FROZE_GL.arcw_atts_init then 
            FROZE_GL.arcw_atts_init = true 

            for k, ent_tbl in pairs(scripted_ents.GetList()) do 
                if string.find(ent_tbl.t.ClassName, "acwatt") then 
                    table.insert(FROZE_GL.tbl_arccw_atts, ent_tbl.t.ClassName)
                end
            end
        end

        --* drop crate key 
        if math.random() <= 0.09 then 
            garlic_like_create_material_drop(ply, target, "crate_key", rarity, 1, mod_spawn_pos)
        end

        --* drop element crystal
        if math.random() <= 0.04 then 
            garlic_like_create_material_drop(ply, target, "element_crystal", rarity, math.Round(math.Remap(npc_maxhp, 0, 50000000, 1, math.random(100, 300) ) * (1 + npc.gl_modifier_num / 5)), mod_spawn_pos)
        end

        -- --* drop random atts 
        -- if math.random() <= 0.12 then 
        --     -- PrintTable(FROZE_GL.tbl_arccw_atts)
        --     local ply = ents.Create(table.Random(FROZE_GL.tbl_arccw_atts)) 
        --     ply:SetPos(npc:GetPos() + Vector(0, 0, 20))
        --     ply:Spawn()
        -- end

        -- print("CRYSTAL DROP CHANCE: " .. wep_crystal_drop_chance)
        -- print(" BONUS XP: " .. ply:GetNWFloat(gl .. ply_wep:GetClass() .. "xp_gain", 1))
        --
        
        local gold_gained = math.max(1, math.Round(math.pow(npc_maxhp, math.max(0.4, 1 - GetGlobalFloat(gl .. "minutes", 0) * 0.01)) * (math.random(100, 200) / 1000) * math.random(500, 1000) / 1000 * ply:GetNWFloat(gl .. ply_wep:GetClass() .. "gold_gain", 1) * ply:GetNWFloat(gl .. "bonus_gold_gain", 1))) * (1 + npc.gl_modifier_num / 4) * (npc:GetNWInt(gl .. "modifier_golden_mul", 1))
        
        --* INSTEAD OF INSTANTLY UPDATING, MONEY GETS UPDATED AFTER ANIMATION ON CLIENT FINISHES
        -- garlic_like_update_database(ply, "money", gold_gained)
        --
        if not garlic_like_ply_unlocked(ply, "bonus_gold_gain") and tonumber(ply:GetNWInt(gl .. "money", 0)) >= 100000 then  
            garlic_like_unlock(ply, gl .. "bonus_gold_gain", "Gold Gain Upgrade") 
        end

        if (not GetGlobalBool(gl .. "match_running") and GetConVar(gl .. "debug_allow_leveling_outside_of_match"):GetBool()) or (GetGlobalBool(gl .. "match_running")) then 
            garlic_like_xp_gain(ply, npc_maxhp * 0.1 * ply:GetNWFloat(gl .. ply_wep:GetClass() .. "xp_gain", 1) * ply:GetNWFloat(gl .. "bonus_xp_gain", 1), "KILL")
            --* match gold accumulated
            if not ply.gl_mga then 
                ply.gl_mga = 0
            end

            ply.gl_mga = ply.gl_mga + gold_gained

            net.Start(gl .. "show_gold_popup_sv_to_cl")
            net.WriteInt(gold_gained, 32)
            net.WriteEntity(npc)
            net.Send(ply)
            --
            SetGlobalInt(gl .. "enemy_kills", GetGlobalInt(gl .. "enemy_kills") + 1)
        end

        -- RELICS ON KILL 
        if ply:GetNWBool(gl .. rh .. "veteran") and math.random() <= 0.85 then
            ply:SetMaxHealth(ply:GetMaxHealth() + 1)

            if math.random() <= ply:GetNWFloat(gl .. rh .. "veteran_mul") then
                ply:SetMaxHealth(ply:GetMaxHealth() + 1)
            end
        end

        if ply:GetNWBool(gl .. rh .. "silver_medal") and math.random() <= ply:GetNWFloat(gl .. rh .. "silver_medal_mul") then
            ply:SetArmor(ply:Armor() + 2)
        end

        if ply:GetNWBool(gl .. rh .. "deft_hands") then
            if ply:GetNWBool(gl .. rh .. "deft_hands_activated") == false then
                ply:SetNWBool(gl .. rh .. "deft_hands_activated", true)
            end

            timer.Create(ply:EntIndex() .. "deft_hands_tiemr", ply:GetNWFloat(gl .. rh .. "deft_hands_mul"), 1, function()
                ply:SetNWBool(gl .. rh .. "deft_hands_activated", false)
            end)
        end

        if GetConVar(gl .. "debug_crate_drops"):GetInt() > 0 and math.random() >= 0.93 then 
            local weapon_crate = ents.Create(gl .. "weapon_crate_entity")
            wc = weapon_crate
            wc:Spawn()
            wc:SetPos(npc:EyePos())
            wc:SetAngles(npc:GetAngles()) 
            SafeRemoveEntityDelayed(wc, 60)
        end


        --* give ammo on kill
        ply:GiveAmmo(ply_wep:GetMaxClip1() * 0.1, ply_wep:GetPrimaryAmmoType(), true)

        if math.random() <= 0.5 then 
            ply:GiveAmmo(ply_wep:GetMaxClip2() * 0.1, ply_wep:GetSecondaryAmmoType(), true)
        end 

        --* WEAPON GEM DROPS
        if math.random() <= wep_crystal_drop_chance then         
            local bonus_gem_drops = (1 + ply:GetNWFloat(gl .. "bonus_gem_drops_base", 0)) 

            if not FROZE_GL.tbl_temp_gem_drops[npc:EntIndex()] then 
                FROZE_GL.tbl_temp_gem_drops[npc:EntIndex()] = {
                    poor = 0,
                    common = 0,
                    uncommon = 0,
                    rare = 0,
                    epic = 0,
                    legendary = 0,
                    god = 0,
                }
            end
            
            for i = 1, math.Remap(npc_maxhp, 0, 100000000, math.random(2, 7) * bonus_gem_drops, math.random(500, 1500) * bonus_gem_drops) * (1 + npc.gl_modifier_num / 5) do
                local number = math.random(1, FROZE_GL.rarity_weights_sum)
    
                for rarity, entry in pairs(FROZE_GL.rarity_weights) do
                    if IsNumBetween(number, entry.min, entry.max) then
                        -- print(rarity)
                        FROZE_GL.tbl_temp_gem_drops[npc:EntIndex()][string.lower(rarity)] = FROZE_GL.tbl_temp_gem_drops[npc:EntIndex()][string.lower(rarity)] + 1
                    end
                end 
            end

            for rarity, amount in pairs(FROZE_GL.tbl_temp_gem_drops[npc:EntIndex()]) do 
                if amount < 1 then continue end 
                --         
                garlic_like_create_material_drop(ply, npc, "ore", rarity, amount)    
            end 

            FROZE_GL.tbl_temp_gem_drops[npc:EntIndex()] = nil 
        end 

        --* REROLL CRYSTAL DROP CHANCE 
        if math.random() <= 0.15 then 
            local bonus_reroll_gem_drops = (1 + ply:GetNWFloat(gl .. "bonus_reroll_gem_drops_base", 0)) 
            npc.gl_reroll_drop_num = 1

            for i = 1, math.Remap(npc_maxhp, 0, 1000000, math.random(1, 2) * bonus_reroll_gem_drops, math.random(250, 500)) * bonus_reroll_gem_drops * (1 + npc.gl_modifier_num / 5) do
                npc.gl_reroll_drop_num = npc.gl_reroll_drop_num + 1
            end 
    
            garlic_like_create_material_drop(ply, npc, "reroll_crystal", rarity, npc.gl_reroll_drop_num)  
        end

        if GetConVar(gl .. "debug_gem_crate_drops"):GetInt() > 0 and math.random() >= 0.95 then   
            local crate = ents.Create(gl .. "crate")
            crate:Spawn()
            crate:SetPos(npc:GetPos() + Vector(0, 0, 30))
            crate:GetPhysicsObject():Wake()
            -- crate:OpenCrate(ply)
            SafeRemoveEntityDelayed(crate, 300)
        end 

        --* IF ENEMY WAS POISONED
        if ent.gl_poisoned then 
            ParticleEffect("viper_poison_attack_explosion", ent:LocalToWorld(ent:OBBCenter()), Angle(0, 0, 0), ent)
            ent:EmitSound("dota2/viper_impact.wav", 100, 100, 1, CHAN_AUTO)

            local damage_poison = DamageInfo() 
            damage_poison:SetDamage(ent.gl_poison_dmg_total) 
            damage_poison:SetAttacker(ply)
            damage_poison:SetInflictor(ply) 
            damage_poison:SetDamageType(DMG_POISON) 
            damage_poison:SetMaxDamage(876523)

            ent.gl_poison_nearby_ents = ents.FindInSphere(ent:GetPos(), 125)
    
            for k, nearby_ent in pairs(ent.gl_poison_nearby_ents) do 
                if (nearby_ent:IsNPC() or nearby_ent:IsNextBot()) and nearby_ent ~= ent then 
                    local dist = ent:GetPos():Distance(nearby_ent:GetPos())

                    damage_poison:SetDamage(math.max(5, ent.gl_poison_dmg_total) * math.Remap(dist, 0, 125, 1, 0.75))
                    nearby_ent:TakeDamageInfo(damage_poison)
                end
            end
        end

        if ply:GetNWBool(gl .. ply_wep:GetClass() .. "lightning") then 
            ply.gl_lightning_chain_entities = {}  
            garlic_like_proc_lightning(ply, npc, 0.75, false, dmg)
        end 

        --* DAMAGE NUMBERS
        if (ent:IsNPC() or ent:IsNextBot()) then 
            garlic_like_create_damage_number(ply, ent, dmg)  
            -- print("DNUMBER ONNPCKILLEd")
            -- local ent_pos = ent:GetPos()
            -- local ent_obbcenter = ent:LocalToWorld(ent:OBBCenter()) 
            -- local ent_obbmaxs = ent:LocalToWorld(ent:OBBMaxs()) 
            -- local ent_damagenumber_pos = Vector(ent_obbcenter.x, ent_obbcenter.y, ent_obbmaxs.z + 10)

            -- net.Start(gl .. "send_damage_numbers_sv_to_cl") 
            -- net.WriteVector(ent_damagenumber_pos)
            -- net.WriteInt(ent:Health(), 32)
            -- net.WriteEntity(ent)
            -- net.WriteInt(1, 32)
            -- net.WriteInt(1, 32)
            -- net.Send(ply)
        end
    end
end)

hook.Add("EntityRemoved", gl .. "entity_removal", function(ent) 
    timer.Simple(0, function() 
        if #FROZE_GL.spawned_enemies > 0 then  
            table.RemoveByValue(FROZE_GL.spawned_enemies, ent)
        end
    end)
end)

hook.Add("PlayerDeath", gl .. "player_death", function(ply, infl, att)
    if GetConVar(gl .. "enable"):GetInt() == 0 then return end
    
    if not GetGlobalBool(gl .. "match_running") then return end

    for k, ent in pairs(ents.GetAll()) do
        if ent:IsNPC() or ent:IsNextBot() then
            SafeRemoveEntity(ent)
        end
    end

    ply:SetNWInt(gl .. "death_count", ply:GetNWInt(gl .. "death_count", 0) + 1)
    -- print(ply:Nick() .. " DEATH COUNT: " .. ply:GetNWInt(gl .. "death_count", 0))

    if ply:GetNWInt(gl .. "death_count", 0) > tonumber(ply:GetPData(gl .. "max_deaths_base", 0)) then
        net.Start(gl .. "send_match_stats_sv_to_cl")
        net.WriteInt(GetGlobalInt(gl .. "minutes"), 32)
        net.WriteInt(GetGlobalInt(gl .. "seconds"), 32)
        --* gold gained
        net.WriteInt(math.Round(ply.gl_mga), 32)
        net.WriteInt(ply:GetNWInt(gl .. "level"), 32) 
        net.WriteFloat(1 + GetGlobalFloat(gl .. "enemy_modifier_hp"))
        net.WriteFloat(1 + GetGlobalFloat(gl .. "enemy_modifier_damage"))
        net.WriteFloat(1 - GetGlobalFloat(gl .. "enemy_modifier_resistance"))
        net.WriteFloat(1 - GetGlobalFloat(gl .. "enemy_modifier_evasion"))
        net.WriteInt(math.Round(ply.gl_tdd), 32)
        net.WriteInt(math.Round(ply.gl_tdt), 32)
        net.WriteInt(math.Round(ply.gl_hdd), 32) 
        -- net.WriteInt(ply.gl_rxpg, 32)
        net.WriteInt(GetGlobalInt(gl .. "enemy_kills", 0) * 3, 32)
        net.Send(ply)

        ply:ConCommand("gmod_admin_cleanup")
        ply:ConCommand(gl .. "enable_timer 0")
        -- ply:ConCommand("zinv 0")
        -- print("--- GARLIC LIKE RUN END ---")
        ply:SetNWInt(gl .. "death_count", 0)
        SetGlobalBool(gl .. "show_end_screen", true)
        SetGlobalBool(gl .. "match_running", false)

        ply:ConCommand(gl .. "reset_stats_run")

        timer.Simple(10, function()
            SetGlobalBool(gl .. "show_end_screen", false)
        end)
    end 

    ply:SetPData(gl .. "total_deaths", tonumber(ply:GetPData(gl .. "total_deaths", 0)) + 1)

    if not garlic_like_ply_unlocked(ply, "max_deaths") and tonumber(ply:GetPData(gl .. "total_deaths")) >= 3 and GetGlobalInt(gl .. "minutes") >= 10 then 
        garlic_like_unlock(ply, gl .. "max_deaths", "Lives Upgrade")
    end

    -- print("GL TOTAL AMOUNT OF DEATHS: " .. ply:GetPData(gl .. "total_deaths"))
end)

hook.Add("EntityFireBullets", gl .. "fire_bullets", function(ent, data)
    -- if asds == nil then return end
    if GetConVar(gl .. "enable"):GetInt() == 0 then return end
    if ent:IsNPC() or ent:IsNextBot() then return end
    local ply

    if ent:IsPlayer() then
        ply = ent
    elseif not ent:IsPlayer() then
        ply = ent:GetOwner()
    end
  
    -- ply.GL_wep = ply:GetActiveWeapon()
    if not ply.GetActiveWeapon then return end 
    local wep = ply:GetActiveWeapon()

    -- print("WEP IS: " .. wep:GetClass())
    if not wep.PrintName then return end

    ply.GL_wep_clip1 = wep:Clip1()
    ply.GL_wep_max_clip1 = wep:GetMaxClip1()
    ply.GL_ammo_type = wep:GetPrimaryAmmoType()
    ply.held_advanced_depot = ply:GetNWBool(gl .. rh .. "advanced_depot", false)
    ply.held_genesis = ply:GetNWBool(gl .. rh .. "genesis", false)
    ply.held_deft_hands = ply:GetNWBool(gl .. rh .. "deft_hands", false)
    ply.held_bloody_ammo = ply:GetNWBool(gl .. rh .. "bloody_ammo", false)

    ply.genesis_chance = math.Rand(0, 1)

    if ply.bloody_ammo_num_shots == nil then
        ply.bloody_ammo_num_shots = 0
    end
    
    wep.garlic_like_bloody_ammo_on = false

    if wep:GetClass() == "FROZE_GL.default_gun" then 
        print("IS GL PISTOL!")
        print("AMMO COUNT: " .. wep:Clip1())
        -- wep:SetClip1(1)

        -- ply:SetAmmo(9999, gl .. "pistol_ammo")
        wep:SetClip1(wep:GetMaxClip1())
    end

    local is_arccw = garlic_like_is_arccw_wep(wep)
    -- local is_tfa = garlic_like_is_tfa_wep(wep)

    -- DEBUG  
    if is_arccw then 
        if ply.held_genesis and not ply.held_advanced_depot and ply.genesis_chance <= ply:GetNWFloat(gl .. rh .. "genesis_mul") and ply.GL_wep_clip1 < ply.GL_wep_max_clip1 then
            -- print("GENESIS PROC")
            wep:SetClip1(math.min(wep:GetMaxClip1(), ply.GL_wep_clip1 + ply.GL_wep_max_clip1 * ply:GetNWFloat(gl .. rh .. "genesis_mul_2")))
        elseif ply.held_genesis and ply.held_advanced_depot and ply.genesis_chance <= ply:GetNWFloat(gl .. rh .. "genesis_mul") then
            -- print("GENESIS PROC WITH DEPOT")
            if ply.GL_wep_clip1 > 0 then
                ply:GiveAmmo(ply.GL_wep_clip1 * ply:GetNWFloat(gl .. rh .. "genesis_mul_2"), ply.GL_ammo_type, true)
            else
                ply:GiveAmmo(10 * ply:GetNWFloat(gl .. rh .. "genesis_mul_2"), ply.GL_ammo_type, true)
            end
        end

        if is_arccw then 
            function wep:TakePrimaryAmmo(num)
                wep.GL_owner = self:GetOwner()
                ply.GL_ammo_type = self:GetPrimaryAmmoType()
                -- print("TAKEPRIMARY AMMO")
                -- print("NUM " .. num)

                if ply:GetNWBool(gl .. rh .. "deft_hands_activated") then
                    -- print("DEFT HANDS ON")

                    return
                end
        
                if not ply.held_advanced_depot then
                    if self.Weapon:Clip1() <= 0 then
                        if self:Ammo1() <= 0 then return end
                        self.Owner:RemoveAmmo(num, self.Weapon:GetPrimaryAmmoType())

                        return
                    end

                    self.Weapon:SetClip1(self.Weapon:Clip1() - num)
                end
        
                if ply.held_bloody_ammo and self.Weapon:Clip1() == num then
                    ply.bloody_ammo_num_shots = ply.bloody_ammo_num_shots + 1
                    -- print("BLOODY AMMO")
                    wep.garlic_like_bloody_ammo_on = true
                    self.Weapon:SetClip1(self.Weapon:Clip1() + num)

                    if ply.bloody_ammo_num_shots % 6 == 0 then
                        ply:SetHealth(math.max(1, ply:Health() - ply:Health() * ply:GetNWFloat(gl .. rh .. "bloody_ammo_mul")))
                        ply.bloody_ammo_num_shots = 0
                    end

                    if not ply.held_advanced_depot then
                        wep.GL_owner:RemoveAmmo(num - num, self.Weapon:GetPrimaryAmmoType())
                    end
                end

                if ply.held_advanced_depot then
                    -- print("ADVANCED DEPOT")

                    if self.Weapon:Clip1() <= 0 and wep.GL_owner:GetAmmoCount(ply.GL_ammo_type) ~= num then
                        wep.GL_owner:RemoveAmmo(num, ply.GL_ammo_type)
                    elseif self.Weapon:Clip1() > 0 then
                        if (self.Weapon:Clip1() ~= num) or (self.Weapon:GetMaxClip1() == 1) then
                            -- print("self.Weapon:Ammo1() " .. self.Weapon:Ammo1())
                            -- print("DEPOT SHOT!")
                            -- print("num " .. num)
                            -- print("self:Clip1() " .. self:Clip1())

                            -- if self.Weapon:Ammo1() > 0 then 
                            --     self:SetClip1(self:Clip1())
                            -- end

                            if self.Weapon:GetMaxClip1() == 1 and self:Clip1() > 0 and self.Weapon:Ammo1() < 1 then
                                -- print("DEPOT OUT OF AMMO1!!!")
                                self:SetClip1(0)
                            elseif self.Weapon:Ammo1() < 1 and self:Clip1() > num then 
                                -- print("DEPOT TAKE FROM CLIP1!")
                                self:SetClip1(self:Clip1() - num)
                            end                

                            if self:GetMaxClip1() > 1 and self:Ammo1() < 1 and self:Clip1() == num then 
                                self:SetClip1(0)
                            end

                            wep.GL_owner:RemoveAmmo(num, ply.GL_ammo_type)
                        elseif self.Weapon:Clip1() == num and wep.GL_owner:GetAmmoCount(ply.GL_ammo_type) < 1 then
                            -- print("NO DEPOT SHOT!")
                            self:SetClip1(self:Clip1() - num)
                        end
                    end
                end
            end
        end
    end

    if wep.Base == "mg_base" then
        num = 1

        if ply:GetNWBool(gl .. rh .. "deft_hands_activated") == false then
            if (not ply.held_advanced_depot and ply.held_genesis) or (ply.held_advanced_depot and ply.held_genesis) then
                if wep.GL_num_shot == nil then
                    wep.GL_num_shot = 0
                end

                wep.GL_num_shot = wep.GL_num_shot + 1

                if wep:Clip1() < ply.GL_wep_max_clip1 and wep.GL_num_shot % math.Round(1 / ply:GetNWFloat(gl .. rh .. "genesis_mul")) == 0 and math.random() >= 0.5 then
                    wep:SetClip1(math.min(ply.GL_wep_max_clip1, ply.GL_wep_clip1 + ply.GL_wep_max_clip1 * ply:GetNWFloat(gl .. rh .. "genesis_mul_2")))
                    wep.GL_num_shot = 0
                elseif wep:Clip1() >= wep:GetMaxClip1() and wep.GL_num_shot % math.Round(1 / ply:GetNWFloat(gl .. rh .. "genesis_mul")) == 0 and math.random() >= 0.5 then
                    ply:GiveAmmo(ply.GL_wep_max_clip1 * ply:GetNWFloat(gl .. rh .. "genesis_mul_2"), ply.GL_ammo_type, true)
                    wep.GL_num_shot = 0
                end
            end

            if ply.held_bloody_ammo and wep:Clip1() == num then
                ply.bloody_ammo_num_shots = ply.bloody_ammo_num_shots + 1
                -- print("BLOODY AMMO")
                wep.garlic_like_bloody_ammo_on = true
                wep:SetClip1(wep:Clip1() + num)

                if ply.bloody_ammo_num_shots % 6 == 0 then
                    ply:SetHealth(math.max(1, ply:Health() - ply:Health() * ply:GetNWFloat(gl .. rh .. "bloody_ammo_mul")))
                    ply.bloody_ammo_num_shots = 0
                end

                if not ply.held_advanced_depot then
                    ply:RemoveAmmo(num - num, wep:GetPrimaryAmmoType())
                end
            end

            if ply.held_advanced_depot and ply:GetAmmoCount(ply.GL_ammo_type) > 0 then
                wep.garlic_like_num = 1

                if wep:Clip1() <= 0 and ply:GetAmmoCount(ply.GL_ammo_type) ~= wep.garlic_like_num then
                    ply:RemoveAmmo(wep.garlic_like_num, ply.GL_ammo_type)
                elseif wep:Clip1() > 0 and wep:Clip1() ~= wep.garlic_like_num then
                    ply:RemoveAmmo(wep.garlic_like_num, ply.GL_ammo_type)
                    wep:SetClip1(math.min(ply.GL_wep_max_clip1, wep:Clip1() + wep.garlic_like_num))
                end
            end
        elseif ply:GetNWBool(gl .. rh .. "deft_hands_activated") then
            wep:SetClip1(math.min(wep:Clip1() + 1, ply.GL_wep_max_clip1))
        end
    end
end)

hook.Add("EntityFireBullets", gl .. "npc_fire_bullets", function(ent, bullet)
    if GetConVar(gl .. "enable"):GetInt() == 0 then return end

    if gasdwsa ~= nil and ent:IsNPC() then
        bullet.Trajectory = bullet.Src + (bullet.Dir + Vector(math.Rand(-bullet.Spread.x, bullet.Spread.x), math.Rand(-bullet.Spread.x, bullet.Spread.x), math.Rand(-bullet.Spread.x, bullet.Spread.x))) * 10000

        ent.bPath = util.TraceLine({
            start = bullet.Src,
            endpos = bullet.Trajectory,
            filter = ent
        })

        ParticleEffect("explo_tiny_mac_edited", ent.bPath.HitPos, Angle(0, 0, 0))
    end
end) 

hook.Add("OnSpawnMenuOpen", gl .. "onspawnmenu", function() 
    if GetGlobalBool(gl .. "match_running") then return false end  
end)

concommand.Add(gl .. "debug_give_xp", function(ply, cmd, args, argStr)
    garlic_like_xp_gain(ply, tonumber(argStr), "KILL")
end)

concommand.Add(gl .. "debug_list_scripted_ents", function(ply, cmd, args, argStr)
    for k, ent_tbl in pairs(scripted_ents.GetList()) do     
        if string.find(ent_tbl.t.ClassName, "acwatt") then 
            print(ent_tbl.t.ClassName)
        end
    end
end)

concommand.Add(gl .. "debug_init_pdata_test", function(ply, cmd, args, argStr)
    local total_deaths = ply:GetPData(gl .. "total_deaths")

    -- print(total_deaths)

    if not total_deaths then 
        -- print("TOTAL DEATHS NOT INIT!!!")
        ply:SetPData(gl .. "total_deaths", 0)
    end
end)

concommand.Add(gl .. "debug_reset_unlockables", function(ply, cmd, args, argStr)
    if argStr == "ALL" then 
        -- print("ALL UNLOCKABLES LOCKED AGAIN!")

        for k, v in pairs(FROZE_GL.tbl_character_stats) do 
            if v.unlock_condition then                 
                ply:SetPData(v.id .. "_unlocked", false)
            end
        end 

        for i = 1, 8 do 
            ply:SetPData(gl .. "relic_slot_" .. i .. "_unlocked", false)             
        end

        ply:SetNWInt(gl .. "relic_slots_unlocked", 0)

        net.Start(gl .. "reset_unlockables_sv_to_cl")
        net.Send(ply)
    else 
        print("use ALL as arg")
    end
end)

concommand.Add(gl .. "debug_create_enemy_preset", function(ply, cmd, args, argStr)
    local tbl_enemy_preset = {
        [1] = {
            class = "npc_scout_mvm_melee",
            weight_start = 200,
            weight_end = 0,
            weight = 0,
            weight_min = 0,
            weight_max = 0,
        },
        [2] = {
            class = "npc_heavy_mvm_boxer",
            weight_start = 300,
            weight_end = 55,
            weight = 0,
            weight_min = 0,
            weight_max = 0,
        },
        [3] = {
            class = "npc_scout_mvm_minorleague",
            weight_start = 155,
            weight_end = 0,
            weight = 0,
            weight_min = 0,
            weight_max = 0,
        },
        [4] = {
            class = "npc_demo_mvm_katana",
            weight_start = 125,
            weight_end = 55,
            weight = 0,
            weight_min = 0,
            weight_max = 0,
        },
        [5] = {
            class = "npc_pyro_mvm",
            weight_start = 55,
            weight_end = 155,
            weight = 0,
            weight_min = 0,
            weight_max = 0,
        },
        [6] = {
            class = "npc_heavy_mvm_steel",
            weight_start = 25,
            weight_end = 255,
            weight = 0,
            weight_min = 0,
            weight_max = 0,
        },
        [7] = {
            class = "npc_scout_mvm_majorleague",
            weight_start = 0,
            weight_end = 125,
            weight = 0,
            weight_min = 0,
            weight_max = 0,
        },
        [8] = {
            class = "npc_medic_mvm",
            weight_start = 0,
            weight_end = 200,
            weight = 0,
            weight_min = 0,
            weight_max = 0,
        },
    }

    file.CreateDir("garlic_like")
    file.Write("garlic_like/preset_1.txt", util.TableToJSON(tbl_enemy_preset, true))
end) 

concommand.Add(gl .. "debug_get_random_pos_near_you", function(ply, cmd, args, argStr)
    garlic_like_spawn_ent(ply, "enemy")  
end)

concommand.Add(gl .. "debug_shoot_fireball", function(ply, cmd, args, argStr)
    -- garlic_like_create_fiery_fireball(ply) 
    garlic_like_create_fiery_fireball(ply:GetEyeTrace().Entity)

    -- timer.Simple(1, function() 
    --     ball:SetParent(nil)
    --     ball:Shoot()
    -- end)
end)

concommand.Add(gl .. "debug_shoot_poisonball", function(ply, cmd, args, argStr)
    -- garlic_like_create_fiery_fireball(ply) 
    garlic_like_create_poisonball(ply:GetEyeTrace().Entity)

    -- timer.Simple(1, function() 
    --     ball:SetParent(nil)
    --     ball:Shoot()
    -- end)
end)

concommand.Add(gl .. "debug_shoot_thunderball", function(ply, cmd, args, argStr)
    -- garlic_like_create_fiery_fireball(ply) 
    garlic_like_create_thunderball(ply:GetEyeTrace().Entity)

    -- timer.Simple(1, function() 
    --     ball:SetParent(nil)
    --     ball:Shoot()
    -- end)
end)

concommand.Add(gl .. "debug_spawn_crate", function(ply, cmd, args, argStr)
    local ent = ents.Create(gl .. "crate")
    ent:SetPos(ply:GetEyeTrace().HitPos + Vector(0, 0, 10))
    ent:Spawn()
end)

concommand.Add(gl .. "debug_100_stats", function(ply, cmd, args, argStr)
    garlic_like_upgrade_str(ply, STR, 100)
    garlic_like_upgrade_agi(ply, AGI, 100)
    garlic_like_upgrade_int(ply, INT, 100)
end)

concommand.Add(gl .. "debug_9999_materials", function(ply, cmd, args, argStr)
    for rarity, rarity_weight in pairs(FROZE_GL.rarity_weights) do
        ply:SetPData(gl .. "held_num_material_" .. rarity, 9999)
        ply:SetNWInt(gl .. "held_num_material_" .. rarity, 9999)
        net.Start(gl .. "update_database_sv_to_cl")
        net.WriteEntity(ply)
        net.WriteString("update_held_num_ores")
        net.WriteString("")
        net.WriteString(rarity)
        net.WriteInt(9999, 32)
        net.WriteBool(true)
        net.Send(ply)
    end 

    for k, v in pairs(FROZE_GL.tbl_materials_inventory) do 
        print("K IS... " .. v.id)
        net.Start(gl .. "update_database_sv_to_cl")
        net.WriteEntity(ply)
        net.WriteString("update_held_num_materials")
        net.WriteString(v.id)
        net.WriteString(v.rarity)
        net.WriteInt(9999, 32)
        net.WriteBool(true)
        net.Send(ply)  

        ply:SetPData(gl .. "held_num_material_" .. v.id, 9999)
        ply:SetNWInt(gl .. "held_num_material_" .. v.id, 9999)
    end 
end)

concommand.Add(gl .. "debug_0_materials", function(ply, cmd, args, argStr)
    for rarity, rarity_weight in pairs(FROZE_GL.rarity_weights) do
        ply:SetPData(gl .. "held_num_material_" .. rarity, 0)
        ply:SetNWInt(gl .. "held_num_material_" .. rarity, 0)
        net.Start(gl .. "update_database_sv_to_cl")
        net.WriteEntity(ply)
        net.WriteString("update_held_num_ores")
        net.WriteString("")
        net.WriteString(rarity)
        net.WriteInt(-9999, 32)
        net.WriteBool(true)
        net.Send(ply)
    end 

    for k, v in pairs(FROZE_GL.tbl_materials_inventory) do 
        print("K IS... " .. k)
        net.Start(gl .. "update_database_sv_to_cl")
        net.WriteEntity(ply)
        net.WriteString("update_held_num_materials")
        net.WriteString(k)
        net.WriteString(v.rarity)
        net.WriteInt(-9999, 32)
        net.WriteBool(true)
        net.Send(ply)  

        ply:SetPData(gl .. "held_num_material_" .. k, 0)
        ply:SetNWInt(gl .. "held_num_material_" .. k, 0)
    end 
end)

concommand.Add(gl .. "debug_update_materials_inventory", function(ply, cmd, args, argStr)
    net.Start(gl .. "update_database_sv_to_cl")
    net.WriteEntity(ply)
    net.WriteString("load_saved_held_num_material")
    net.WriteString("")
    net.WriteString("")
    net.WriteInt(0, 32)
    net.WriteBool(true)
    net.Send(ply)
end)

concommand.Add(gl .. "spawn_tf2_ultimate_base_entity", function(ply, cmd, args, argStr)
    if ply:GetNWBool(gl .. "is_using_tf2_ult") then return end
    local tub = ents.Create(gl .. "tf2_ultimate_base")
    tub:SetOwner(ply)
    tub:Spawn()
    ply:SetNWBool(gl .. "is_using_tf2_ult", true)
end)

concommand.Add(gl .. "dash", function(ply, cmd, args, argStr)
    if ply:GetNWBool(gl .. "dash_available") then
        ply.garlic_like_groundDashSpeed = 3000
        ply.garlic_like_airDashSpeed = 880
        ply.garlic_like_dash_direction = 0
        ply.garlic_like_pdBonusSpeed = 1
        ply:SetNWFloat(gl .. "dash_cooldown", 1 * (1 - ply:GetNWFloat(gl .. rh .. "advanced_jogger_mul", 0)))
        -- print("DASH COOLDOWN " .. ply:GetNWFloat(gl .. "dash_cooldown"))
        ply.garlic_like_is_dashing = true
        --
        ply:SetGravity(-0.1)
        pfw = ply:GetForward()
        pr = ply:GetRight()

        if ply:KeyDown(IN_FORWARD) and ply:KeyDown(IN_MOVERIGHT) then
            ply.garlic_like_dash_direction = pfw + pr
        elseif ply:KeyDown(IN_FORWARD) and ply:KeyDown(IN_MOVELEFT) then
            ply.garlic_like_dash_direction = pfw + -pr
        elseif ply:KeyDown(IN_BACK) and ply:KeyDown(IN_MOVERIGHT) then
            ply.garlic_like_dash_direction = -pfw + pr
        elseif ply:KeyDown(IN_BACK) and ply:KeyDown(IN_MOVELEFT) then
            ply.garlic_like_dash_direction = -pfw + -pr
        elseif ply:KeyDown(IN_FORWARD) then
            ply.garlic_like_dash_direction = pfw
        elseif ply:KeyDown(IN_MOVELEFT) then
            ply.garlic_like_dash_direction = -pr
        elseif ply:KeyDown(IN_MOVERIGHT) then
            ply.garlic_like_dash_direction = pr
        elseif ply:KeyDown(IN_BACK) then
            ply.garlic_like_dash_direction = -pfw
        else
            ply.garlic_like_dash_direction = pfw
        end

        if ply:IsOnGround() then
            ply:SetVelocity(-ply:GetVelocity() + ply.garlic_like_dash_direction * ply.garlic_like_groundDashSpeed * ply.garlic_like_pdBonusSpeed)
        else
            ply:SetVelocity(-ply:GetVelocity() + ply.garlic_like_dash_direction * ply.garlic_like_airDashSpeed * ply.garlic_like_pdBonusSpeed)
        end

        ply:EmitSound("garlic_like/dash.wav", 90, 100, 0.3, CHAN_AUTO)

        timer.Simple(0.25, function()
            if not IsValid(ply) then return end 
            ply:SetVelocity(-ply:GetVelocity() * 0.8)
            ply:SetGravity(1)
            ply.garlic_like_is_dashing = false
        end)

        ply:SetNWBool(gl .. "dash_available", false)
        -- 
        ply.GL_dash_cd_target = math.Round(ply:GetNWFloat(gl .. "dash_cooldown") * 100)
        -- print(ply.GL_dash_cd_target)

        for i = 1, ply.GL_dash_cd_target do
            timer.Simple(i / 100, function()
                ply:SetNWFloat(gl .. "dash_cooldown", ply:GetNWFloat(gl .. "dash_cooldown") - 0.01)

                if i == ply.GL_dash_cd_target then
                    ply:SetNWBool(gl .. "dash_available", true)
                end
            end)
        end
    end
end)

concommand.Add(gl .. "debug_print_preset_tbl", function(ply, cmd, args, argStr) 
    if argStr then 
        if not FROZE_GL.tbl_presets[argStr] then 
            print("PRESET IS NOT LOADED!")
        else
            PrintTable(FROZE_GL.tbl_presets[argStr])
        end
    else
        PrintTable(FROZE_GL.tbl_presets)
    end
end)

concommand.Add(gl .. "start", function(ply, cmd, args, argStr)
    if not ply:IsSuperAdmin() then return end 
    -- local preset = "data/garlic_like/" .. GetConVar(gl .. "enemy_preset"):GetString()
    local preset = GetConVar(gl .. "enemy_preset"):GetString() 

    -- if file.Exists(preset, "GAME") then
    if FROZE_GL.tbl_presets[preset] then
        -- ply:ConCommand("zinv 1")
        ply:ConCommand(gl .. "enable_timer 1")
        SetGlobalBool(gl .. "show_end_screen", false)
        SetGlobalBool(gl .. "match_running", true)
        -- print("FILE EXISTS!")

        -- FROZE_GL.tbl_used_enemy_preset = util.JSONToTable(file.Read(preset, "GAME")) 
        FROZE_GL.tbl_used_enemy_preset = FROZE_GL.tbl_presets[preset]
        FROZE_GL.enemy_preset_max_weight = 0

        -- PrintTable(FROZE_GL.tbl_presets[preset])
                
        if not FROZE_GL.tbl_used_enemy_preset then return end

        for k, v in ipairs(FROZE_GL.tbl_used_enemy_preset) do             
            v.weight = v.weight_start

            if v.weight == 0 then continue end 

            FROZE_GL.enemy_preset_max_weight = FROZE_GL.enemy_preset_max_weight + v.weight

            if k == 1 then 
                v.weight_min = 0
                v.weight_max = v.weight 
            else
                v.weight_min = FROZE_GL.tbl_used_enemy_preset[k - 1].weight_max + 1 
                v.weight_max = v.weight_min + v.weight 
            end
        end

        garlic_like_check_enemy_spawn_chances() 
        garlic_like_upgrade_str(ply, nil, tonumber(ply:GetPData(gl .. "bonus_starting_str_base", 0)))
        garlic_like_upgrade_agi(ply, nil, tonumber(ply:GetPData(gl .. "bonus_starting_agi_base", 0)))
        garlic_like_upgrade_int(ply, nil, tonumber(ply:GetPData(gl .. "bonus_starting_int_base", 0)))
 
        --* sync NWInt with PData  
        for rarity, rarity_weight in pairs(FROZE_GL.rarity_weights) do 
            ply:SetNWInt(gl .. "held_num_material_" .. rarity, ply:GetPData(gl .. "held_num_material_" .. rarity, 0))
        end 

        for k, v in pairs(FROZE_GL.tbl_materials_inventory) do   
            ply:SetNWInt(gl .. "held_num_material_" .. k, ply:GetPData(gl .. "held_num_material_" .. k, 0))
        end 

        ply:StripWeapons()
        ply:Give("FROZE_GL.default_gun")
    
        for k, v in pairs(game.GetAmmoTypes()) do 
            ply:SetAmmo(0, v)
        end

        -- PrintTable(FROZE_GL.tbl_used_enemy_preset)
    else 
        -- print("FILE DOESNT EXIST!")
    end
end)

concommand.Add(gl .. "debug_give_level", function(ply, cmd, args, argStr)
    print(ply:GetNWInt(gl .. "xp_to_next_level", 100))
    garlic_like_xp_gain(ply, ply:GetNWInt(gl .. "xp_to_next_level", 500), "KILL")
    -- garlic_like_xp_gain(ply, 500, "KILL")
end)

concommand.Add(gl .. "debug_give_xp", function(ply, cmd, args, argStr)
    local xp = (isnumber(tonumber(argStr))) and tonumber(argStr) or 1
    
    garlic_like_xp_gain(ply, xp, "KILL")
end)

concommand.Add(gl .. "debug_set_gold", function(ply, cmd, args, argStr)
    ply:SetNWInt(gl .. "money", tonumber(argStr))
end)

concommand.Add(gl .. "reset_stats_run", function(ply, cmd, args, argStr)
    garlic_like_reset_stats(ply)
end)

concommand.Add(gl .. "load_data", function(ply, cmd, args, argStr)
    -- print(file.Read(gl .. "saves.txt", false))
    for k, ply in pairs(player.GetAll()) do
        -- print(ply:GetPData(gl .. "money", 0))
    end
end)

concommand.Add(gl .. "save_data", function(ply, cmd, args, argStr)
    for k, ply in pairs(player.GetAll()) do
        ply:SetPData(gl .. "money", 1000)
    end
end)

concommand.Add(gl .. "debug_arccw_melee_detect", function(ply, cmd, args, argStr)
    print(tostring(garlic_like_is_arccw_melee(ply:GetActiveWeapon())))
end)

concommand.Add(gl .. "debug_measure_wep_power", function(ply, cmd, args, argStr)
    print(garlic_like_get_wep_power(ply, ply:GetActiveWeapon()))
end)

concommand.Add(gl .. "debug_create_wep_power_tbl", function(ply, cmd, args, argStr)
    garlic_like_create_wep_power_tbl()
    PrintTable(FROZE_GL.tbl_wep_power)
end)