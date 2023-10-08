if CLIENT then return end
--
local gl = "garlic_like_"
local rh = "relic_held_"
--
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

util.AddNetworkString(gl .. "update_gold_from_anim_cl_to_sv")
util.AddNetworkString(gl .. "pause_game_cl_to_sv") 
util.AddNetworkString(gl .. "update_database_cl_to_sv")
util.AddNetworkString(gl .. "reset_cl") 
--
SetGlobalInt(gl .. "enemy_kills", 0)
SetGlobalInt(gl .. "minutes", 0)
SetGlobalInt(gl .. "seconds", 0)
SetGlobalInt(gl .. "breaktime_seconds", 0)
SetGlobalInt(gl .. "skip_break_voters", 0)
SetGlobalFloat(gl .. "enemy_modifier_hp", 0)
SetGlobalFloat(gl .. "enemy_modifier_damage", 0)
SetGlobalFloat(gl .. "enemy_modifier_resistance", 0)
SetGlobalBool(gl .. "match_running", false)
SetGlobalBool(gl .. "is_breaktime", false)
SetGlobalBool(gl .. "stop_enemy_spawns", false)
SetGlobalBool(gl .. "show_end_screen", false)
-- 
--! OPTIMIZE "ENEMY EMPOWERED" TEXT!!!
local break_time_cur_min = 0
local spawned_enemies = {}
--
local tbl_used_enemy_preset = {}
local enemy_preset_max_weight = 0
local timer_count = 0
local delay_timer = 0
local delay_ply = 0
local delay_rapid = 0
local delay_enemies = 0
local rarity_starting_num = 1
local rarity_weights_sum = 0
local nav_areas

local rarity_weights = {
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

local ammo_boxes = {
    [1] = "item_ammo_pistol",
    [2] = "item_ammo_smg1",
    [3] = "item_box_buckshot",
    [4] = "item_ammo_357",
    [5] = "item_ammo_ar2",
} 

local tbl_repeated_dmg = {
    [876522] = "fire",
    [876523] = "poison",
    [876524] = "lightning",
    [884251] = "multi hit",
}

local tbl_temp_gem_drops = {} 
 
local gun_bonuses = {}
 
for k, bonus in ipairs(tbl_gl_bonuses_weapons) do 
    table.insert(gun_bonuses, 1, bonus.name)
end

tbl_gl_elements = {
    [1] = "fire",
    [2] = "poison",
    [3] = "lightning",
}

tbl_gl_presets = {}
 
cvars.AddChangeCallback(gl .. "enable", function(name, old, new) end)

local function IsNumBetween(x, min, max)
    return x >= min and x <= max
end

local function create_rarity_weights()
    for k, entry in SortedPairs(rarity_weights) do
        entry.min = rarity_starting_num
        entry.max = rarity_starting_num + entry.weight
        rarity_starting_num = rarity_starting_num + entry.weight
    end

    for k, entry in pairs(rarity_weights) do
        rarity_weights_sum = rarity_weights_sum + entry.weight
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

    if ply.old_hp_boost == nil then
        ply.old_hp_boost = 0
    end

    ply.hp_boost = math.Round(math.max(0, STR * 3 + tonumber(ply:GetPData(gl .. "hp_boost_base", 0))) * ply:GetNWFloat(gl .. "bonus_hp_boost_mult", 1))

    if ply.hp_boost > ply.old_hp_boost then
        ply:SetMaxHealth(ply:GetMaxHealth() + (ply.hp_boost - ply.old_hp_boost))
    end

    ply.old_hp_boost = ply.hp_boost
    ply:SetNWInt(gl .. "hp_boost", ply.hp_boost)
    ply:SetNWFloat(gl .. "max_overheal", 1.5 + STR * 0.005 + tonumber(ply:GetPData(gl .. "max_overheal_base", 0))) 
    ply:SetNWFloat(gl .. "bonus_damage", (STR * 0.005 + tonumber(ply:GetPData(gl .. "bonus_damage_base", 0))) * ply:GetNWFloat(gl .. "bonus_damage_mult", 1))
    ply:SetNWFloat(gl .. "bonus_block_resistance", math.min(0.75, STR * 0.005 + tonumber(ply:GetPData(gl .. "bonus_block_resistance_base", 0))))
    ply:SetNWInt(gl .. "bonus_hp_regen", math.Round(math.max(1, 1 + STR / 40 + tonumber(ply:GetPData(gl .. "bonus_hp_regen_base", 0)))))
    ply:SetNWFloat(gl .. "bonus_critical_damage", (0.25 + STR * 0.015 + tonumber(ply:GetPData(gl .. "bonus_critical_damage_base", 0))) * (1 + ply:GetNWFloat(gl .. rh .. "hawkeye_sight_mul_2", 1)))

    if not tobool(ply:GetPData(gl .. "bonus_starting_str_unlocked")) and ply:GetNWInt(gl .. "STR", 1) >= 40 then 
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
    -- print("AGI BOOST " .. ply.AGI_BOOST)
    ply:SetNWFloat(gl .. "bonus_resistance", math.min(0.95, AGI * 0.004 + tonumber(ply:GetPData(gl .. "bonus_resistance_base", 0))))
    ply:SetNWInt(gl .. "bonus_resistance_flat", math.max(0, math.floor(AGI / 4) + tonumber(ply:GetPData(gl .. "bonus_resistance_flat_base", 0))))
    ply:SetNWFloat(gl .. "bonus_block_chance", math.min(1, AGI * 0.005 + tonumber(ply:GetPData(gl .. "bonus_block_chance_base", 0))))
    ply:SetNWFloat(gl .. "bonus_evasion_chance", math.min(0.5, AGI * 0.0025 + tonumber(ply:GetPData(gl .. "bonus_evasion_chance_base", 0))))
    ply:SetNWFloat(gl .. "bonus_critical_chance", (AGI * 0.007 + tonumber(ply:GetPData(gl .. "bonus_critical_chance_base", 0))) * ply:GetNWFloat(gl .. "bonus_critical_chance_mult", 1))
    ply:SetNWFloat(gl .. "bonus_multihit_chance", math.min(5, AGI * 0.005 + tonumber(ply:GetPData(gl .. "bonus_multihit_chance_base", 0))))

    if not tobool(ply:GetPData(gl .. "bonus_starting_agi_unlocked")) and ply:GetNWInt(gl .. "AGI", 1) >= 40 then 
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
    mana_regen = ply:GetNWInt(gl .. "mana_regen", 1)
    max_mana = ply:GetNWInt(gl .. "max_mana") + tonumber(ply:GetPData(gl .. "max_mana_base", 0))
    mana_boost = math.max(0, statboost_num * 2)
    mana_regen_boost = math.max(1, 1 + math.floor(INT / 50) + tonumber(ply:GetPData(gl .. "mana_regen_base", 0)))

    ply:SetNWInt(gl .. "max_mana", max_mana + mana_boost)
    ply:SetNWInt(gl .. "mana_regen", mana_regen_boost)
    ply:SetNWFloat(gl .. "bonus_mana_damage", math.max(0, INT * 0.01 + tonumber(ply:GetPData(gl .. "bonus_mana_damage_base", 0))))
    ply:SetNWFloat(gl .. "bonus_mana_resistance", math.min(0.85, INT * 0.005 + tonumber(ply:GetPData(gl .. "bonus_mana_resistance_base", 0))))
    ply:SetNWFloat(gl .. "bonus_xp_gain", (INT * 0.003 + tonumber(ply:GetPData(gl .. "bonus_xp_gain_base", 0))) * ply:GetNWFloat(gl .. "bonus_xp_mult", 1))
    ply:SetNWFloat(gl .. "bonus_cooldown_mult", math.max(0.1, 1 - INT * 0.0015 - tonumber(ply:GetPData(gl .. "bonus_cooldown_mult_base", 0)))) 
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

    if not tobool(ply:GetPData(gl .. "bonus_starting_int_unlocked")) and ply:GetNWInt(gl .. "INT", 1) >= 40 then 
        garlic_like_unlock(ply, gl .. "bonus_starting_int", "Starting INT Upgrade")
    end
end

function garlic_like_reduce_auto_cast_cooldown(ply, cdr_temp, convar, name)    
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
    SetGlobalFloat(gl .. "enemy_modifier_hp", 0)
    SetGlobalFloat(gl .. "enemy_modifier_damage", 0)
    SetGlobalFloat(gl .. "enemy_modifier_resistance", 0)
    SetGlobalBool(gl .. "match_running", false)
    SetGlobalBool(gl .. "is_breaktime", false)
    SetGlobalBool(gl .. "stop_enemy_spawns", false)
    SetGlobalBool(gl .. "show_end_screen", false)

    delay_enemies = 0
    delay_ply = 0
    delay_rapid = 0
    delay_timer = 0
    --
    ply:SetMaxHealth(100)
    --
    ply:SetNWInt(gl .. "level", 1)
    ply:SetNWInt(gl .. "xp_total", 0)
    ply:SetNWInt(gl .. "xp_to_next_level", 500)
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
    -- INT
    ply:SetNWInt(gl .. "mana", 100)
    ply:SetNWInt(gl .. "max_mana", 100)
    ply:SetNWInt(gl .. "mana_regen", 1)
    ply:SetNWFloat(gl .. "bonus_mana_damage", 0.1)
    ply:SetNWFloat(gl .. "bonus_mana_resistance", 0.05)
    ply:SetNWFloat(gl .. "bonus_xp_gain", 0)
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

    for k, data in pairs(garlic_like_upgrades) do 
        if data.upgrade_type == "relic" then 
            ply:SetNWBool(gl .. rh .. data.name2, false) 
            ply:SetNWFloat(gl .. rh .. data.name2 .. "_mul", 0)
            ply:SetNWFloat(gl .. rh .. data.name2 .. "_mul_2", 0)
        end
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

    if not nav_areas then 
        nav_areas = navmesh.GetAllNavAreas() 
    end 

    local filtered_pos_min = {}
    local filtered_pos_max = {}
    local final_points = {}
    -- PrintTable(nav_areas)

    filtered_pos_min = navmesh.Find(ply_pos, 1000, 300, 300)
    filtered_pos_max = navmesh.Find(ply_pos, 3000, 300, 300) 
    
    for k, area in pairs(filtered_pos_max) do 
        if not table.HasValue(filtered_pos_min, area) then 
            table.insert(final_points, #final_points, area)
        end
    end
    
    local pre_point = final_points[math.random(1, #final_points)]

    local loop_num = 0

    while (not pre_point and loop_num < 100) do
        loop_num = loop_num + 1
        pre_point = final_points[math.random(1, #final_points)]
    end

    if not pre_point then return end
    local point = pre_point:GetRandomPoint() 
    --
    return point
end

function garlic_like_spawn_enemy(ply, spawn_class_override)  
    if #spawned_enemies > GetConVar(gl .. "max_enemies_spawned"):GetInt() then return end
    --
    local ply_pos = ply:GetPos() 
    local point = garlic_like_get_nearby_point(ply)
    -- print(point)
    local enemy_class = "npc_zombie" 
    local random_number = math.random(1, enemy_preset_max_weight)

    -- PrintTable(tbl_used_enemy_preset)

    local function get_enemy_class()
        for k, v in pairs(tbl_used_enemy_preset) do 
            if IsNumBetween(random_number, v.weight_min, v.weight_max) then 
                -- PrintTable(v)
                enemy_class = v.class
            end
        end
    end

    get_enemy_class()

    local loop_num = 0

    while (enemy_class == "npc_zombie" and loop_num < 200) do 
        loop_num = loop_num + 1
        get_enemy_class()
    end 

    if spawn_class_override ~= "enemy" then 
        enemy_class = spawn_class_override
    end

    -- print("ENEMY CLASS IS: " .. enemy_class)

    --! add loop to keep looping until point is not nil!!!    
    local loop_num = 0

    while (not point) do
        loop_num = loop_num + 1 
        if loop_num >= 200 then return end 
        point = garlic_like_get_nearby_point(ply)
    end
 
    local enemy = ents.Create(enemy_class)
    enemy:Spawn()
    enemy:SetPos(point)
    enemy:SetNWBool(gl .. "is_spawned_enemy", true)

    if spawn_class_override == "enemy" then 
        table.insert(spawned_enemies, enemy) 
    end
end

function garlic_like_enemy_shield_recharge(ent)
    timer.Create(gl .. "enemy_shield_recharging_" .. ent:EntIndex(), 0, 100, function()
        if not ent.enemy_is_able_to_recharge or ent:GetNWInt(gl .. "enemy_shield") >= ent:GetNWInt(gl .. "enemy_shield_max") then return end
        ent:SetNWInt(gl .. "enemy_shield", math.min(ent:GetNWInt(gl .. "enemy_shield_max"), ent:GetNWInt(gl .. "enemy_shield") + ent:GetNWInt(gl .. "enemy_shield_max") * 0.01))
    end)
end

function garlic_like_reset_gun_bonuses(ply, weapon_name) 
    for k, element in pairs(tbl_gl_elements) do
        ply:SetNWBool(gl .. weapon_name .. element, false)
    end

    for k, bonus in pairs(gun_bonuses) do
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
        local final_dmg = math.min(target.gl_fire_highest_damage_taken * 5, math.Round((target.gl_fire_final_dmg + math.ceil(target:Health() * 0.01))^(1 + target.gl_ignite_reps_left / 4 * 0.01))) 
        -- print("final_dmg " .. final_dmg)
        -- print("target.gl_fire_hit_count " .. target.gl_fire_hit_count)

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
            target.gl_fire_dmg_dealt_reduced_mod = 0.15
        end

        target.gl_fire_dmg_dealt_reduced_mod = math.min(0.75, target.gl_fire_dmg_dealt_reduced_mod + 0.01)
        -- print(timer.RepsLeft(gl .. "ignited_" .. target:EntIndex()) )
        -- print(target.gl_fire_average_dmg)
        -- print("repsleft: " .. target.gl_ignite_reps_left)
  
        target.gl_ignite_reps_left = target.gl_ignite_reps_left - 1    

        timer.Adjust(gl .. "ignited_" .. target:EntIndex(), 0.25, math.min(20, target.gl_ignite_reps_left), nil) 

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
        target.gl_ignite_reps_left = math.min(20, target.gl_ignite_reps_left + 1)

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

    ply.gl_lightning_damage_buff_stacks = math.min(30, ply.gl_lightning_damage_buff_stacks + 1)

    -- print("ply.gl_lightning_damage_buff_stacks " .. ply.gl_lightning_damage_buff_stacks)

    if not ply.gl_lightning_chain_num then 
        ply.gl_lightning_chain_num = 0
    end

    timer.Simple(10, function() 
        ply.gl_lightning_damage_buff_stacks = math.max(0, ply.gl_lightning_damage_buff_stacks - 1)
    end)

    garlic_like_attach_particle(target, "ATTACH", "stormspirit_electric_vortex_debuff") 
    target.gl_lightning_debuffed = true
    target.gl_lightning_debuffed_stacks = 0

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

    target.gl_poison_dmg_total = target.gl_poison_dmg_total + damage * 0.5
    
    -- print(target.gl_poison_dmg_total)

    if not target.gl_poisoned then 
        target.gl_poisoned = true
        garlic_like_attach_particle(target, "ATTACH", "viper_viper_strike_debuff")    
        -- 

        timer.Create(gl .. "poisoned_" .. target:EntIndex(), 2, 999, function()
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

            target.gl_poison_dmg_taken_mul = math.min(2.5, target.gl_poison_dmg_taken_mul + 0.125)

            target.gl_poison_nearby_ents = ents.FindInSphere(target:GetPos(), 100)

            for k, nearby_ent in pairs(target.gl_poison_nearby_ents) do 
                if (nearby_ent:IsNPC() or nearby_ent:IsNextBot()) and nearby_ent ~= target then 
                    damage_poison:SetDamage(math.max(5, target.gl_poison_dmg_total * 0.6))
                    nearby_ent:TakeDamageInfo(damage_poison)
                end
            end

            target.gl_poison_dmg_total = math.Round(math.max(1, target.gl_poison_dmg_total * 0.667)) 
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

function garlic_like_create_material_drop(ply, target, item_type, rarity, amount, mod_spawn_pos)  
    local drop = ents.Create(gl .. "wep_crystal")
    local mod_vector = Vector(0, 0, 0)
    
    if item_type == "reroll_crystal" then   
        drop:SetNWBool(gl .. "is_reroll_crystal", true) 
    elseif item_type == "food" then 
        drop:SetNWBool(gl .. "is_food", true)   
        mod_vector = Vector(0, 0, 30)
    elseif item_type == "ore" then 
        drop:SetNWBool(gl .. "is_ore", true)
    end

    if mod_spawn_pos then 
        mod_vector = mod_spawn_pos
    end

    drop:SetOwner(ply)
    drop:SetNWString(gl .. "assigned_rarity", rarity)
    drop:SetPos(target:GetPos() + Vector(0, 0, 10) + mod_vector)
    drop:Spawn()
    drop:SetNWInt(gl .. "item_amount", amount)
    SafeRemoveEntityDelayed(drop, 45)
end

function garlic_like_check_enemy_spawn_chances() 
    for k, v in ipairs(tbl_used_enemy_preset) do 
        -- print("CLASS: " .. v.class) 
        -- print("CHANCE: " .. v.weight / enemy_preset_max_weight * 100 .. "%")
    end
end

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
    local ply = net.ReadEntity()
    local level = net.ReadInt(32)
    local xp_to_next_level = net.ReadInt(32)
    ply:SetNWInt(gl .. "level", level)
    ply:SetNWInt(gl .. "xp_to_next_level", xp_to_next_level)

    if not tobool(ply:GetPData(gl .. "bonus_xp_gain_unlocked")) and level >= 30 then 
        garlic_like_unlock(ply, gl .. "bonus_xp_gain", "XP Gain Upgrade")
    end

    if not tobool(ply:GetPData(gl .. "relic_slot_7_unlocked")) and level >= 50 then 
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
        elseif upgrade_name == "glasses" then
            ply:SetNWFloat(gl .. "bonus_critical_chance_mult", (1 + statboost_num) * (1 + ply:GetNWFloat(gl .. rh .. "hawkeye_sight_mul", 0)))
            ply:SetNWFloat(gl .. "bonus_critical_chance", AGI * 0.007 * ply:GetNWFloat(gl .. "bonus_critical_chance_mult", 1))
        elseif upgrade_name == "armor" then
            ply:SetNWFloat(gl .. "bonus_armor", statboost_num)
        elseif upgrade_name == "shield" then
            ply:SetNWFloat(gl .. "bonus_shield", statboost_num)
        end
        
        timer.Simple(0.1, function()
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
        if not tobool(ply:GetPData(gl .. "relic_slot_5_unlocked")) and string.lower(upgrade_rarity) == "legendary" then 
            garlic_like_unlock(ply, gl .. "relic_slot_5", "Unlocked a Relic Slot!")
        end

        if not tobool(ply:GetPData(gl .. "relic_slot_6_unlocked")) and string.lower(upgrade_rarity) == "god" then 
            garlic_like_unlock(ply, gl .. "relic_slot_6", "Unlocked a Relic Slot!")
        end
    end

    --* DATA / RECORD STUFF FOR UNLOCKABLE [COOLDOWN REDUCTION]
    if not tobool(ply:GetPData(gl .. "bonus_cooldown_mult_unlocked")) and upgrade_type == "skill" and tbl_gl_rarity_to_number[upgrade_rarity] >= 4 then 
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
                -- PrintTable(bonus) 
                ply:SetNWFloat(gl .. ply.gl_weapon_chosen .. bonus.name, ply:GetNWFloat(gl .. ply.gl_weapon_chosen .. bonus.name, 1) * (1 + bonus.modifier * bonus.type_mul))
                -- print(gl .. ply.gl_weapon_chosen .. bonus.name) 
            end
        end
    end
end)

net.Receive(gl .. "update_gold_from_anim_cl_to_sv", function(len, ply) 
    local gold_gained = net.ReadInt(32)
    garlic_like_update_database(ply, "money", gold_gained)
end)

--* FUNCTION EXECUTIONS
create_rarity_weights()

--*
hook.Add("PlayerSwitchWeapon", gl .. "check_switch", function(ply, old_wep, new_wep)
    -- INCREASE COOLDOWN SPEEDS
    timer.Create(tostring(ply:SteamID64() .. "weapon_switch_repeat_avoid"), 0.5, 1, function()
        if not IsValid(new_wep) or new_wep == nil then return end
        --
        -- print("GL || NEW WEP: " .. tostring(new_wep))
        -- print("GL || COOLDOWN SPEED: " .. tostring(ply:GetNWFloat(gl .. new_wep:GetClass() .. "cooldown_speed", 1)))
        --! DEPRECATED BECAUSE HORRIBLE LOGIC
        -- net.Start(gl .. "cooldown_speed_increase")
        -- net.WriteString(new_wep:GetClass())
        -- net.Send(ply)
        --* NEW ONE
        print("switched wep!!!")
        ply.cdr_torrent = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_torrent, "dota2_auto_cast_torrent_delay", "torrent")
        ply.cdr_lightning_bolt = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_lightning_bolt, "dota2_auto_cast_lightning_bolt_delay", "lightning_bolt")
        ply.cdr_diabolic_edict = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_diabolic_edict, "dota2_auto_cast_diabolic_edict_delay", "diabolic_edict")
        ply.cdr_magic_missile = garlic_like_reduce_auto_cast_cooldown(ply, ply.cdr_magic_missile, "dota2_auto_cast_magic_missile_delay", "magic_missile")
    end)

    --[[ 
        TODO: WHEN SWITCHING WEAPON
        * 1. get current ddelay / cooldown number, store it.
        * 2. get the live / actual convar and multiply it with cooldown_speed
        !! problems arise when switching weapons !!
        * 3. when switching weapon, in one tick change the live ddelay value with the stored value
        * 4. repeat steps 1 and 2.
        --
        TODO: WHEN UPGRADING INT
        * 1. upgrade the cooldown values stored in the table
        * 2. call the function above
            !! THIS IS A HORRIBLE ALGO THAT FORGETS ABOUT THE TABLE WHEN USING THE WEP UPGRADE VALUE !!
        
        --]]
    do
    end
end)

hook.Add("PlayerInitialSpawn", gl .. "player_spawn", function(ply)
    timer.Simple(0.1, function()
        ply:SetMaxHealth(ply:GetMaxHealth() + ply:GetNWInt(gl .. "hp_boost", 0))
    end)

    timer.Simple(0.25, function()
        garlic_like_reset_stats(ply)
        net.Start(gl .. "update_database_sv_to_cl")
        net.WriteEntity(ply)
        net.WriteString("update_shop")
        net.Send(ply)

        if ply:GetPData(gl .. "total_deaths") ~= 0 then 
            -- print("TOTAL DEATHS NOT INIT")
            ply:SetPData(gl .. "total_deaths", 0)
        end
    end)
end)

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

        --* RESET UNLOCKABLES 
        -- for k, data in SortedPairs(tbl_gl_character_stats) do 
            -- only read entries that are unlockables
            -- if data.unlock_condition then 
            --    ply:SetNWBool(gl .. data.id .. "_unlocked", tobool(ply:GetPData(gl .. data.id .. "_unlocked", false))) 
            -- end
        -- end

        timer.Simple(5, function() 
            ply:SetNWBool(gl .. "spawn_dmg_reduction", false)
        end)
    end)

    if GetConVar(gl .. "reset_stats"):GetInt() > 0 then
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
    --* PLAYER GEM GATHERING AOE
    for k, ply in pairs(player.GetAll()) do 
        if ply.cd_gem_gathering and ply.cd_gem_gathering < CurTime() then 
            ply.cd_gem_gathering = CurTime() + 0.15
            
            for k, ent in pairs(ents.FindInSphere(ply:GetPos(), 100)) do 
                if ent:GetClass() == gl .. "wep_crystal" and ent:GetNWBool(gl .. "settled") then 
                    ent:StartTouch(ply)
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

    if delay_rapid <= CurTime() then
        delay_rapid = CurTime() + 0.1

        for k, ply in pairs(player.GetAll()) do
            ply:SetNWInt(gl .. "mana", math.min(ply:GetNWInt(gl .. "max_mana", 100), ply:GetNWInt(gl .. "mana", 100) + ply:GetNWInt(gl .. "mana_regen", 1)))
        end
    end

    if delay_timer <= CurTime() then
        local minutes = GetGlobalInt(gl .. "minutes", 0)
        local seconds = GetGlobalInt(gl .. "seconds", 0)

        if GetConVar(gl .. "enable_timer"):GetInt() > 0 then  
            if not GetGlobalBool(gl .. "is_breaktime") and not GetGlobalBool(gl .. "stop_enemy_spawns") then 
                seconds = seconds + 1
                SetGlobalInt(gl .. "seconds", seconds)
            end

            --* IF SPAWNED ENEMY IS FAR AWAY, RELOCATE TO NEAR THE PLAYER  

            --* OPERATIONS FOR ENEMY MODIFIERS
            if #spawned_enemies > 0 then 
                -- print("SPAWNED ENEMEIS IS VALID")
                for k, ent in ipairs(spawned_enemies) do 
                    -- print("DISTANCE FROM ENT TO A PLAYER: " .. ent:GetPos():Distance(table.Random(player.GetAll()):GetPos()))
                    if not IsValid(ent) then continue end 
                    if ent:GetPos():Distance(table.Random(player.GetAll()):GetPos()) >= 3300 then 
                        local point = garlic_like_get_nearby_point()
                        local loop_num = 0
                        
                        while (not point and loop_num < 200) do
                            point = garlic_like_get_nearby_point()
                        end

                        if not point then continue end

                        ent:SetPos(point + Vector(0, 0, 5))
                    end  
                end

                for k, enemy in ipairs(spawned_enemies) do 
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
            if GetGlobalBool(gl .. "stop_enemy_spawns") and not GetGlobalBool(gl .. "is_breaktime") and #spawned_enemies <= 0 then 
                SetGlobalBool(gl .. "is_breaktime", true) 

                garlic_like_spawn_enemy(table.Random(player.GetAll()), gl .. "station_weapon_upgrade") 
                garlic_like_spawn_enemy(table.Random(player.GetAll()), gl .. "station_item_fusing") 

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
            if minutes > 0 and minutes % 5 == 0 and not GetGlobalBool(gl .. "is_breaktime") and break_time_cur_min ~= minutes then                 
                break_time_cur_min = minutes
                SetGlobalBool(gl .. "stop_enemy_spawns", true)   
            end 

            --* EVERY 30 SECONDS, BUFF THE ENEMY STATS
            if seconds % 30 == 0 then 
                SetGlobalFloat(gl .. "enemy_modifier_hp", ((GetGlobalFloat(gl .. "enemy_modifier_hp", 0) + 0.8)^1.011 ) * 1.04)
                SetGlobalFloat(gl .. "enemy_modifier_damage", (GetGlobalFloat(gl .. "enemy_modifier_damage", 0) + 0.11) * 1.085)
                SetGlobalFloat(gl .. "enemy_modifier_resistance", math.min(0.98, GetGlobalFloat(gl .. "enemy_modifier_resistance", 0) + 0.02))

                timer_count = math.min(timer_count + 1, 9999)  
                enemy_preset_max_weight = 0
                local final_w_diff = 0
                
                for k, v in pairs(tbl_used_enemy_preset) do             
                    final_w_diff = math.Round(math.abs(v.weight_end - v.weight_start) / 60) 
                    v.weight = math.Approach(v.weight, v.weight_end, final_w_diff)

                    enemy_preset_max_weight = enemy_preset_max_weight + v.weight
        
                    if k == 1 then 
                        v.weight_min = 0
                        v.weight_max = v.weight 
                    else
                        v.weight_min = tbl_used_enemy_preset[k - 1].weight_max + 1 
                        v.weight_max = v.weight_min + v.weight 
                    end
                end

                garlic_like_check_enemy_spawn_chances() 

                -- PrintTable(tbl_used_enemy_preset)

                timer.Simple(0, function()
                    net.Start(gl .. "enemy_upgrade_broadcast")
                    net.Broadcast()
                end)
            end                        

            if seconds == 60 then
                seconds = 0
                minutes = minutes + 1
                SetGlobalInt(gl .. "seconds", seconds)
                SetGlobalInt(gl .. "minutes", minutes)
            end
        end 

        delay_timer = CurTime() + 1 * (1 / GetConVar(gl .. "timer_speed_mult"):GetFloat()) 
    end

    --* TIMER RELATING TO PLAYER OPERATIONS
    if delay_ply <= CurTime() then
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
            if not tobool(ply:GetPData(gl .. "relic_slot_1_unlocked")) and minutes >= 10 then 
                garlic_like_unlock(ply, gl .. "relic_slot_1", "Unlocked a Relic Slot!")
            end

            if not tobool(ply:GetPData(gl .. "relic_slot_2_unlocked")) and minutes >= 15 then 
                garlic_like_unlock(ply, gl .. "relic_slot_2", "Unlocked a Relic Slot!")
                
            end

            if not tobool(ply:GetPData(gl .. "relic_slot_3_unlocked")) and minutes >= 20 then 
                garlic_like_unlock(ply, gl .. "relic_slot_3", "Unlocked a Relic Slot!")
                
            end

            if not tobool(ply:GetPData(gl .. "relic_slot_4_unlocked")) and minutes >= 30 then 
                garlic_like_unlock(ply, gl .. "relic_slot_4", "Unlocked a Relic Slot!")
                
            end
        end

        delay_ply = CurTime() + 1
    end

    --* ADDED b to turn this off
    if not GetGlobalBool(gl .. "stop_enemy_spawns") and GetConVar(gl .. "enable_timer"):GetBool() and delay_enemies < CurTime() and not GetGlobalBool(gl .. "is_breaktime") then 
        delay_enemies = CurTime() + math.max(0.75, 2.5 * (90 - timer_count) / 90)
        -- print("ENEMY DELAY")

        if #spawned_enemies > 0 then 
            for k, enemy in ipairs(spawned_enemies) do 
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

        if #spawned_enemies < GetConVar(gl .. "max_enemies_spawned"):GetInt() and math.random() <= 0.75 then   
            garlic_like_spawn_enemy(table.Random(player.GetAll()), "enemy")  
        end

        if math.random() <= 0.05 then 
            garlic_like_spawn_enemy(table.Random(player.GetAll()), gl .. "crystal_cluster") 
        end

        if math.random() <= 0.1 then 
            garlic_like_spawn_enemy(table.Random(player.GetAll()), gl .. "item_barrel") 
        end        
    end
end) 

hook.Add("EntityTakeDamage", gl .. "damage_modifiers", function(ent, dmg)
    if GetConVar(gl .. "enable"):GetInt() == 0 then return end
    if tbl_repeated_dmg[dmg:GetMaxDamage()] then return end
    local attacker = dmg:GetAttacker()
 
    if (IsValid(attacker) and IsValid(ent)) and (string.find(attacker:GetClass(), "trigger") or attacker:IsWorld()) and (ent:IsNPC() or ent:IsNextBot() or table.HasValue(tbl_gl_valid_entities, ent:GetClass())) then 
    
    end

    if attacker:IsPlayer() and (ent:IsNPC() or ent:IsNextBot() or table.HasValue(tbl_gl_valid_entities, ent:GetClass())) and attacker:Alive() then
        ply = dmg:GetAttacker()
        ply_wep = ply:GetActiveWeapon()
        mana = ply:GetNWInt(gl .. "mana")
        damage_num = dmg:GetDamage()
        if not IsValid(ply) then return end
        -- dmg:ScaleDamage(55)
        --
        ply:SetNWInt(gl .. "is_critting", 0)
        crit_chance = ply:GetNWFloat(gl .. "bonus_critical_chance") * ply:GetNWFloat(gl .. ply_wep:GetClass() .. "crit_chance", 1)
        -- crit_chance = 1
        crit_dmg = (ply:GetNWFloat(gl .. "bonus_critical_damage") + ply:GetNWFloat(gl .. "brutal_gloves_crit_damage_mod", 0)) * ply:GetNWFloat(gl .. ply_wep:GetClass() .. "crit_damage", 1)
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
            dmg:ScaleDamage(1 + ply:GetNWFloat(gl .. "bonus_mana_damage") * ply:GetNWFloat(gl .. ply_wep:GetClass() .. "damage_mana", 1))
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
            --* 7314 is custom damage to signify tier 1 crits.

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
            dmg:ScaleDamage(math.min(3.5, math.Truncate(1.045^ply.gl_lightning_damage_buff_stacks, 2)))
        end

        if ent.gl_lightning_debuffed then             
            dmg:ScaleDamage(1.25 + ent.gl_lightning_debuffed_stacks / 25)
            ent.gl_lightning_debuffed_stacks = ent.gl_lightning_debuffed_stacks + 1
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
 
        -- print("BONUS WEAPON DAMAGE: " .. ply:GetNWFloat(gl .. ply_wep:GetClass() .. "damage", 1))
        dmg:ScaleDamage(1 * ply:GetNWFloat(gl .. ply_wep:GetClass() .. "damage", 1)) 
        --
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
            attacker.gl_bleed_dmginfo:SetDamage(dmg:GetDamage() * 0.12)

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
    if tbl_repeated_dmg[dmg:GetMaxDamage()] then return end
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

            if ply:GetNWBool(gl .. ply_wep:GetClass() .. "lightning") and math.random() <= 0.13 then   
                garlic_like_proc_lightning(ply, ent, 2.5, false, dmg)
            end   
        end

        --* TEMPORARY VALUE, REPLACE WITH VALUE ON PLAYER
        local mh_chance = ply:GetNWFloat(gl .. "bonus_multihit_chance", 0) * ply:GetNWFloat(gl .. ply_wep:GetClass() .. "multihit", 1)

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
                        multihit:SetDamageType(dmg:GetDamageType()) 
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

        --* TOTAL DAMAGE DEALT STAT
        if not ply.gl_tdd then 
            ply.gl_tdd = 0
        end

        ply.gl_tdd = ply.gl_tdd + dmg:GetDamage()

        if not tobool(ply:GetPData(gl .. "relic_slot_8_unlocked")) and ply.gl_tdd >= 1000000 then 
            garlic_like_unlock(ply, gl .. "relic_slot_8", "Unlocked a Relic Slot!")
        end

        --* HIGHEST DAMAGE DEALT 
        if not ply.gl_hdd then 
            ply.gl_hdd = 0
        end

        if ply.gl_hdd < dmg:GetDamage() then 
            ply.gl_hdd = dmg:GetDamage()
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
    --* DAMAGE NUMBERS
    if dmg:GetAttacker():IsPlayer() and (ent:IsNPC() or ent:IsNextBot()) and dmg:GetDamage() > 0 then 
        local ent_pos = ent:GetPos()
        local ent_obbcenter = ent:LocalToWorld(ent:OBBCenter()) 
        local ent_obbmaxs = ent:LocalToWorld(ent:OBBMaxs()) 
        local ent_damagenumber_pos = Vector(ent_obbcenter.x, ent_obbcenter.y, ent_obbmaxs.z + 10)

        net.Start(gl .. "send_damage_numbers_sv_to_cl") 
        net.WriteVector(ent_damagenumber_pos)
        net.WriteInt(dmg:GetDamage(), 32)
        net.WriteEntity(ent)
        net.WriteInt(dmg:GetMaxDamage(), 32)
        net.WriteInt(dmg:GetDamageCustom(), 32)
        net.Send(ply)
    end
end) 

hook.Add("OnEntityCreated", gl .. "entity_creation", function(ent) 
    if not IsValid(ent) then return end
    if GetConVar(gl .. "enable"):GetInt() == 0 then return end

    if ent:IsNPC() or ent:IsNextBot() then
        timer.Simple(0, function()
            if not IsValid(ent) then return end
            maxhealth = ent:GetMaxHealth()
            ent:SetMaxHealth(maxhealth * math.random(75, 125) / 100 * (1 + GetGlobalFloat(gl .. "enemy_modifier_hp", 0)))
            ent:SetHealth(ent:GetMaxHealth())   
            ent.gl_modifier_num = 0   
             
            timer.Simple(0, function() 
                local max_modifiers = math.max(1, math.Round(GetGlobalBool(gl .. "minutes", 0) / 3))
                -- local max_modifiers = 10

                if not ent:GetNWBool(gl .. "is_spawned_enemy") then 
                    for k, mod in RandomPairs(tbl_gl_enemy_modifiers) do   
                        -- print(k)
                        if math.random() < 0.08 and ent.gl_modifier_num < max_modifiers then 
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
                            ent:SetNWInt(gl .. "modifier_golden_mul", 3)
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
    if not att:IsPlayer() then return end
    local ply = att
    local ply_wep = ply:GetActiveWeapon()
    local npc_maxhp = npc:GetMaxHealth() 
    local wep_crystal_drop_chance = math.Remap(npc_maxhp, 1, 1000000, 0.3, 1) 
    local wep_crystal_crate_drop_chance = 0.05
    local ammo_drop_chance = 1

    if not GetGlobalBool(gl .. "match_running") then return end
 
    if not npc.gl_modifier_num then 
        npc.gl_modifier_num = 0
    end

    -- print("CRYSTAL DROP CHANCE: " .. wep_crystal_drop_chance)
    -- print(" BONUS XP: " .. ply:GetNWFloat(gl .. ply_wep:GetClass() .. "xp_gain", 1))
    --
    local gold_gained = math.max(1, math.Round(npc_maxhp * (math.random(150, 200) / 1000) * math.random(500, 1000) / 1000 * ply:GetNWFloat(gl .. ply_wep:GetClass() .. "gold_gain", 1) * ply:GetNWFloat(gl .. "bonus_gold_gain", 1))) * (1 + npc.gl_modifier_num / 4) * (npc:GetNWInt(gl .. "modifier_golden_mul", 1))
    garlic_like_xp_gain(att, npc_maxhp * ply:GetNWFloat(gl .. ply_wep:GetClass() .. "xp_gain", 1), "KILL")
    --* INSTEAD OF INSTANTLY UPDATING, MONEY GETS UPDATED AFTER ANIMATION ON CLIENT FINISHES
    -- garlic_like_update_database(att, "money", gold_gained)
    --
    if not tobool(ply:GetPData(gl .. "bonus_gold_gain_unlocked")) and tonumber(ply:GetNWInt(gl .. "money", 0)) >= 100000 then  
        garlic_like_unlock(ply, gl .. "bonus_gold_gain", "Gold Gain Upgrade") 
    end

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

    -- RELICS ON KILL 
    if ply:GetNWBool(gl .. rh .. "veteran") and math.random() <= 0.85 then
        att:SetMaxHealth(att:GetMaxHealth() + 1)

        if math.random() <= ply:GetNWFloat(gl .. rh .. "veteran_mul") then
            att:SetMaxHealth(att:GetMaxHealth() + 1)
        end
    end

    if ply:GetNWBool(gl .. rh .. "silver_medal") and math.random() <= ply:GetNWFloat(gl .. rh .. "silver_medal_mul") then
        att:SetArmor(att:Armor() + 2)
    end

    if ply:GetNWBool(gl .. rh .. "deft_hands") then
        if ply:GetNWBool(gl .. rh .. "deft_hands_activated") == false then
            ply:SetNWBool(gl .. rh .. "deft_hands_activated", true)
        end

        timer.Create(ply:EntIndex() .. "deft_hands_tiemr", ply:GetNWFloat(gl .. rh .. "deft_hands_mul"), 1, function()
            ply:SetNWBool(gl .. rh .. "deft_hands_activated", false)
        end)
    end

    if GetConVar(gl .. "debug_crate_drops"):GetInt() > 0 and math.random() >= 0.9 then
    -- if math.random() <= 1 then        
        local weapon_crate = ents.Create(gl .. "weapon_crate_entity")
        wc = weapon_crate
        wc:Spawn()
        wc:SetPos(npc:EyePos())
        wc:SetAngles(npc:GetAngles()) 
        SafeRemoveEntityDelayed(wc, 60)
    end

    --* WEAPON GEM DROPS
    if math.random() <= wep_crystal_drop_chance then  
    -- if math.random() <= 1 then      
    -- if math.random() <= 0 then         
        local bonus_gem_drops = (1 + ply:GetNWFloat(gl .. "bonus_gem_drops_base", 0)) 

        if not tbl_temp_gem_drops[npc:EntIndex()] then 
            tbl_temp_gem_drops[npc:EntIndex()] = {
                poor = 0,
                common = 0,
                uncommon = 0,
                rare = 0,
                epic = 0,
                legendary = 0,
                god = 0,
            }
        end
        
        for i = 1, math.Remap(npc_maxhp, 0, 10000000, math.random(3, 9) * bonus_gem_drops, math.random(1000, 3000) * bonus_gem_drops) * (1 + npc.gl_modifier_num / 5) do
            local number = math.random(1, rarity_weights_sum)
 
            for rarity, entry in pairs(rarity_weights) do
                if IsNumBetween(number, entry.min, entry.max) then
                    -- print(rarity)
                    tbl_temp_gem_drops[npc:EntIndex()][string.lower(rarity)] = tbl_temp_gem_drops[npc:EntIndex()][string.lower(rarity)] + 1
                end
            end 
        end

        for rarity, amount in pairs(tbl_temp_gem_drops[npc:EntIndex()]) do 
            if amount < 1 then continue end 
            --         
            garlic_like_create_material_drop(ply, npc, "ore", rarity, amount)    
        end 

        tbl_temp_gem_drops[npc:EntIndex()] = nil 
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
    -- if math.random() <= 1 then        
        local crate = ents.Create(gl .. "crate")
        crate:Spawn()
        crate:SetPos(npc:GetPos() + Vector(0, 0, 30))
        crate:GetPhysicsObject():Wake()
        crate:OpenCrate(ply)
        SafeRemoveEntityDelayed(crate, 60)
    end

    if math.random() <= ammo_drop_chance and ply_wep:GetPrimaryAmmoType() and ply_wep:GetMaxClip1() then
        -- for i = 1, math.Remap(npc_maxhp, 0, 50000, math.random(1, 3), math.random(4, 8)) * (1 + npc.gl_modifier_num / 5) do
        --     local ammo_box = ents.Create(ammo_boxes[math.random(1, #ammo_boxes)])
        --     ammo_box:SetOwner(ply)
        --     ammo_box:SetPos(ply:EyePos())
        --     ammo_box:Spawn()
        --     SafeRemoveEntityDelayed(ammo_box, 60)
        -- end
        ply:GiveAmmo(ply_wep:GetMaxClip1() * 0.5, ply_wep:GetPrimaryAmmoType(), true)
    end

    if ply:GetNWBool(gl .. ply_wep:GetClass() .. "lightning") then 
        ply.gl_lightning_chain_entities = {}  
        garlic_like_proc_lightning(ply, npc, 0.75, false, dmg)
    end 
end)

hook.Add("EntityRemoved", gl .. "entity_removal", function(ent) 
    timer.Simple(0, function() 
        if #spawned_enemies > 0 then  
            table.RemoveByValue(spawned_enemies, ent)
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
        net.WriteInt(ply.gl_mga, 32)
        net.WriteInt(ply:GetNWInt(gl .. "level"), 32) 
        net.WriteFloat(1 + GetGlobalFloat(gl .. "enemy_modifier_hp"))
        net.WriteFloat(1 + GetGlobalFloat(gl .. "enemy_modifier_damage"))
        net.WriteFloat(1 - GetGlobalFloat(gl .. "enemy_modifier_resistance"))
        net.WriteInt(ply.gl_tdd, 32)
        net.WriteInt(ply.gl_tdt, 32)
        net.WriteInt(ply.gl_hdd, 32) 
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

    if not tobool(ply:GetPData(gl .. "max_deaths_unlocked")) and tonumber(ply:GetPData(gl .. "total_deaths")) >= 3 and GetGlobalInt(gl .. "minutes") >= 10 then 
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
  
    ply.GL_wep = ply:GetActiveWeapon()

    if not ply.GL_wep.PrintName then return end

    ply.GL_wep_clip1 = ply.GL_wep:Clip1()
    ply.GL_wep_max_clip1 = ply.GL_wep:GetMaxClip1()
    ply.GL_ammo_type = ply.GL_wep:GetPrimaryAmmoType()
    ply.held_advanced_depot = ply:GetNWBool(gl .. rh .. "advanced_depot", false)
    ply.held_genesis = ply:GetNWBool(gl .. rh .. "genesis", false)
    ply.held_deft_hands = ply:GetNWBool(gl .. rh .. "deft_hands", false)
    ply.held_bloody_ammo = ply:GetNWBool(gl .. rh .. "bloody_ammo", false)

    if ply.bloody_ammo_num_shots == nil then
        ply.bloody_ammo_num_shots = 0
    end

    --
    ply.GL_wep.garlic_like_bloody_ammo_on = false

    -- DEBUG  
    if string.find(ply.GL_wep.PrintName, "arccw") then
        ply.genesis_chance = math.Rand(0, 1)

        if ply.held_genesis and not ply.held_advanced_depot and ply.genesis_chance <= ply:GetNWFloat(gl .. rh .. "genesis_mul") and ply.GL_wep_clip1 < ply.GL_wep_max_clip1 then
            -- print("GENESIS PROC")
            ply.GL_wep:SetClip1(math.min(ply.GL_wep:GetMaxClip1(), ply.GL_wep_clip1 + ply.GL_wep_max_clip1 * ply:GetNWFloat(gl .. rh .. "genesis_mul_2")))
        elseif ply.held_genesis and ply.held_advanced_depot and ply.genesis_chance <= ply:GetNWFloat(gl .. rh .. "genesis_mul") then
            -- print("GENESIS PROC WITH DEPOT")
            if ply.GL_wep_clip1 > 0 then
                ply:GiveAmmo(ply.GL_wep_clip1 * ply:GetNWFloat(gl .. rh .. "genesis_mul_2"), ply.GL_ammo_type, true)
            else
                ply:GiveAmmo(10 * ply:GetNWFloat(gl .. rh .. "genesis_mul_2"), ply.GL_ammo_type, true)
            end
        end
    end

    function ply.GL_wep:TakePrimaryAmmo(num)
        ply.GL_wep.GL_owner = self:GetOwner()
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
            ply.GL_wep.garlic_like_bloody_ammo_on = true
            self.Weapon:SetClip1(self.Weapon:Clip1() + num)

            if ply.bloody_ammo_num_shots % 6 == 0 then
                ply:SetHealth(math.max(1, ply:Health() - ply:Health() * ply:GetNWFloat(gl .. rh .. "bloody_ammo_mul")))
                ply.bloody_ammo_num_shots = 0
            end

            if not ply.held_advanced_depot then
                ply.GL_wep.GL_owner:RemoveAmmo(num - num, self.Weapon:GetPrimaryAmmoType())
            end
        end

        if ply.held_advanced_depot then
            -- print("ADVANCED DEPOT")

            if self.Weapon:Clip1() <= 0 and ply.GL_wep.GL_owner:GetAmmoCount(ply.GL_ammo_type) ~= num then
                ply.GL_wep.GL_owner:RemoveAmmo(num, ply.GL_ammo_type)
            elseif self.Weapon:Clip1() > 0 then
                if self.Weapon:Clip1() ~= num then
                    self:SetClip1(self:Clip1())
                    ply.GL_wep.GL_owner:RemoveAmmo(num, ply.GL_ammo_type)

                    if ply.GL_wep.GL_owner:GetAmmoCount(ply.GL_ammo_type) < 1 then
                        self:SetClip1(self:Clip1() - num)
                    end
                elseif self.Weapon:Clip1() == num and ply.GL_wep.GL_owner:GetAmmoCount(ply.GL_ammo_type) < 1 then
                    self:SetClip1(self:Clip1() - num)
                end
            end
        end
    end

    if ply.GL_wep.Base == "mg_base" then
        num = 1

        if ply:GetNWBool(gl .. rh .. "deft_hands_activated") == false then
            if (not ply.held_advanced_depot and ply.held_genesis) or (ply.held_advanced_depot and ply.held_genesis) then
                if ply.GL_wep.GL_num_shot == nil then
                    ply.GL_wep.GL_num_shot = 0
                end

                ply.GL_wep.GL_num_shot = ply.GL_wep.GL_num_shot + 1

                if ply.GL_wep:Clip1() < ply.GL_wep_max_clip1 and ply.GL_wep.GL_num_shot % math.Round(1 / ply:GetNWFloat(gl .. rh .. "genesis_mul")) == 0 and math.random() >= 0.5 then
                    ply.GL_wep:SetClip1(math.min(ply.GL_wep_max_clip1, ply.GL_wep_clip1 + ply.GL_wep_max_clip1 * ply:GetNWFloat(gl .. rh .. "genesis_mul_2")))
                    ply.GL_wep.GL_num_shot = 0
                elseif ply.GL_wep:Clip1() >= ply.GL_wep:GetMaxClip1() and ply.GL_wep.GL_num_shot % math.Round(1 / ply:GetNWFloat(gl .. rh .. "genesis_mul")) == 0 and math.random() >= 0.5 then
                    ply:GiveAmmo(ply.GL_wep_max_clip1 * ply:GetNWFloat(gl .. rh .. "genesis_mul_2"), ply.GL_ammo_type, true)
                    ply.GL_wep.GL_num_shot = 0
                end
            end

            if ply.held_bloody_ammo and ply.GL_wep:Clip1() == num then
                ply.bloody_ammo_num_shots = ply.bloody_ammo_num_shots + 1
                -- print("BLOODY AMMO")
                ply.GL_wep.garlic_like_bloody_ammo_on = true
                ply.GL_wep:SetClip1(ply.GL_wep:Clip1() + num)

                if ply.bloody_ammo_num_shots % 6 == 0 then
                    ply:SetHealth(math.max(1, ply:Health() - ply:Health() * ply:GetNWFloat(gl .. rh .. "bloody_ammo_mul")))
                    ply.bloody_ammo_num_shots = 0
                end

                if not ply.held_advanced_depot then
                    ply:RemoveAmmo(num - num, ply.GL_wep:GetPrimaryAmmoType())
                end
            end

            if ply.held_advanced_depot and ply:GetAmmoCount(ply.GL_ammo_type) > 0 then
                ply.GL_wep.garlic_like_num = 1

                if ply.GL_wep:Clip1() <= 0 and ply:GetAmmoCount(ply.GL_ammo_type) ~= ply.GL_wep.garlic_like_num then
                    ply:RemoveAmmo(ply.GL_wep.garlic_like_num, ply.GL_ammo_type)
                elseif ply.GL_wep:Clip1() > 0 and ply.GL_wep:Clip1() ~= ply.GL_wep.garlic_like_num then
                    ply:RemoveAmmo(ply.GL_wep.garlic_like_num, ply.GL_ammo_type)
                    ply.GL_wep:SetClip1(math.min(ply.GL_wep_max_clip1, ply.GL_wep:Clip1() + ply.GL_wep.garlic_like_num))
                end
            end
        elseif ply:GetNWBool(gl .. rh .. "deft_hands_activated") then
            ply.GL_wep:SetClip1(math.min(ply.GL_wep:Clip1() + 1, ply.GL_wep_max_clip1))
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

        for k, v in pairs(tbl_gl_character_stats) do 
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
    garlic_like_spawn_enemy(ply, "enemy")  
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
    for rarity, rarity_weight in pairs(rarity_weights) do
        ply:SetNWInt(gl .. "held_num_material_" .. rarity, 9999)
        net.Start(gl .. "update_database_sv_to_cl")
        net.WriteEntity(ply)
        net.WriteString("update_held_num_ores")
        net.WriteString("")
        net.WriteString(rarity)
        net.WriteInt(9999, 32)
        net.Send(ply)
    end

    net.Start(gl .. "update_database_sv_to_cl")
    net.WriteEntity(ply)
    net.WriteString("update_held_num_materials")
    net.WriteString("Reroll Crystal")
    net.WriteString("common")
    net.WriteInt(9999, 32)
    net.Send(ply)  
end)

concommand.Add(gl .. "debug_update_materials_inventory", function(ply, cmd, args, argStr)
    net.Start(gl .. "update_database_sv_to_cl")
    net.WriteEntity(ply)
    net.WriteString("load_saved_held_num_material")
    net.WriteString("")
    net.WriteString("")
    net.WriteInt(0, 32)
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
        if not tbl_gl_presets[argStr] then 
            print("PRESET IS NOT LOADED!")
        else
            PrintTable(tbl_gl_presets[argStr])
        end
    else
        PrintTable(tbl_gl_presets)
    end
end)

concommand.Add(gl .. "start", function(ply, cmd, args, argStr)
    if not ply:IsSuperAdmin() then return end 
    -- local preset = "data/garlic_like/" .. GetConVar(gl .. "enemy_preset"):GetString()
    local preset = GetConVar(gl .. "enemy_preset"):GetString() 

    -- if file.Exists(preset, "GAME") then
    if tbl_gl_presets[preset] then
        -- ply:ConCommand("zinv 1")
        ply:ConCommand(gl .. "enable_timer 1")
        SetGlobalBool(gl .. "show_end_screen", false)
        SetGlobalBool(gl .. "match_running", true)
        -- print("FILE EXISTS!")

        -- tbl_used_enemy_preset = util.JSONToTable(file.Read(preset, "GAME")) 
        tbl_used_enemy_preset = tbl_gl_presets[preset]
        enemy_preset_max_weight = 0

        -- PrintTable(tbl_gl_presets[preset])
                
        if not tbl_used_enemy_preset then return end

        for k, v in ipairs(tbl_used_enemy_preset) do             
            v.weight = v.weight_start

            if v.weight == 0 then continue end 

            enemy_preset_max_weight = enemy_preset_max_weight + v.weight

            if k == 1 then 
                v.weight_min = 0
                v.weight_max = v.weight 
            else
                v.weight_min = tbl_used_enemy_preset[k - 1].weight_max + 1 
                v.weight_max = v.weight_min + v.weight 
            end
        end

        garlic_like_check_enemy_spawn_chances() 
        garlic_like_upgrade_str(ply, nil, tonumber(ply:GetPData(gl .. "bonus_starting_str_base", 0)))
        garlic_like_upgrade_agi(ply, nil, tonumber(ply:GetPData(gl .. "bonus_starting_agi_base", 0)))
        garlic_like_upgrade_int(ply, nil, tonumber(ply:GetPData(gl .. "bonus_starting_int_base", 0)))

        -- PrintTable(tbl_used_enemy_preset)
    else 
        -- print("FILE DOESNT EXIST!")
    end
end)

concommand.Add(gl .. "give_level", function(ply, cmd, args, argStr)
    garlic_like_xp_gain(ply, ply:GetNWInt(gl .. "xp_to_next_level", 500), "KILL")
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