if SERVER then return end 
  
FROZE_GL = FROZE_GL or {}
--
local gl = "garlic_like_"
local rh = "relic_held_"
--
CreateClientConVar(gl .. "hud_enable", 1, true, true, "", 0, 1)
CreateClientConVar(gl .. "hud_show_abilities", 1, true, true, "", 0, 1)
CreateClientConVar(gl .. "hud_xp_notification_animation", 1, true, true, "", 0, 1)
CreateClientConVar(gl .. "hud_font", "Carbon Regular", true, true, "", 0, 1)
CreateClientConVar(gl .. "hud_font_2", "Reggae One", true, true, "", 0, 1)
CreateClientConVar(gl .. "starting_weapon", "", true, true, "", 0, 0)
--* experimental
CreateConVar(gl .. "enable", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "enables / disables all of garlic-like's systems.", 0, 1)
CreateConVar(gl .. "enemy_preset", "preset_1.txt", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 0)
CreateConVar(gl .. "mana_usage_mul", 0.75, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 1)
CreateConVar(gl .. "reset_stats_after_dying", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 1)
CreateConVar(gl .. "enable_timer", 0, FCVAR_NONE, "", 0, 1)
CreateConVar(gl .. "timer_speed_mult", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 10)
CreateConVar(gl .. "damage_random_min_maxes_enable", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 1)
CreateConVar(gl .. "max_enemies_spawned", 25, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 1, 100)
CreateConVar(gl .. "debug_crate_drops", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 1)
CreateConVar(gl .. "debug_gem_crate_drops", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 1)
CreateConVar(gl .. "global_enemy_hp_mod_num", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 100)
CreateConVar(gl .. "global_enemy_dmg_mod_num", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 100)
--
W = ScrW()
H = ScrH()
H_half_screen = H * 0.5
--
color_black = Color(0, 0, 0, 255)
color_white = Color(255, 255, 255)
color_white_100 = Color(255, 255, 255, 100)
color_white_40 = Color(255, 255, 255, 40)
color_yellow = Color(255, 238, 0)
color_blue = Color(0, 200, 255)
color_red = Color(255, 0, 0)
color_black_alpha_50 = Color(0, 0, 0, 50)
color_black_alpha_100 = Color(0, 0, 0, 100)
color_black_alpha_150 = Color(0, 0, 0, 150)
color_black_alpha_200 = Color(0, 0, 0, 200)
color_black_alpha_225 = Color(0, 0, 0, 225)
--
start, oldxp, newxp = 0, -1, -1
barW = W * 0.5
animationTime = 0.1
minutes = 0
seconds = 0
addedzero = 0
--
--* variables
do 
    FROZE_GL.color_empowered_text = Color(255, 255, 255, 0)
    FROZE_GL.show_empowered_text = false
    FROZE_GL.fading_out = false
    --
    --* mats / materials
    do 
        FROZE_GL.mat_beam = Material("effects/ihalo_haze.vmt")
        FROZE_GL.mat_hl = Material("garlic_like/icon_hl.png")
        FROZE_GL.mat_heart = Material("garlic_like/icon_ui/heart.png")
        FROZE_GL.mat_gradient_l = Material("vgui/gradient-l")
        FROZE_GL.mat_gradient_r = Material("vgui/gradient-r")
        FROZE_GL.mat_gradient_u = Material("vgui/gradient-u")
        FROZE_GL.mat_gradient_d = Material("vgui/gradient-d")
        FROZE_GL.mat_padlock = Material("garlic_like/icon_ui/padlock.png")
        FROZE_GL.mat_icon_str = Material("garlic_like/icon_str.png")
        FROZE_GL.mat_icon_agi = Material("garlic_like/icon_agi.png")
        FROZE_GL.mat_icon_int = Material("garlic_like/icon_int.png")
        FROZE_GL.mat_dice = Material("garlic_like/icon_ui/dice2.png")
        FROZE_GL.mat_padlock = Material("garlic_like/icon_ui/padlock.png")
        FROZE_GL.mat_exchange_rotated = Material("garlic_like/icon_ui/exchange_white_rotated.png")
        FROZE_GL.mat_anvil = Material("garlic_like/icon_ui/anvil.png")
        FROZE_GL.mat_sparkle = Material("garlic_like/icon_ui/sparkle.png")
        FROZE_GL.mat_star_yellow = Material("garlic_like/icon_star_yellow.png") 
        FROZE_GL.mat_star_gray = Material("garlic_like/icon_star_gray.png")
        FROZE_GL.mat_gacha_banner1 = Material("garlic_like/gacha_banner1.png")
        FROZE_GL.mat_icon_powercell = Material("garlic_like/icon_materials/icon_powercell.png")
        FROZE_GL.mat_icon_dash = Material("garlic_like/icon_relics/advanced-jogger.png")
        FROZE_GL.mat_icon_ult = Material("garlic_like/icon_tf2_ult.png")
    end
    --  
    --* xp stuff 
    do 
        FROZE_GL.ply_level = 1
        FROZE_GL.xp = 0
        FROZE_GL.xp_text = nil
        FROZE_GL.xp_numbers = {}
        FROZE_GL.xp_texts = {}
        FROZE_GL.xp_text_W = W * 0.55
        FROZE_GL.xp_total = 0
        FROZE_GL.xp_to_next_level = 100
        FROZE_GL.xp_bar_width = 0
        FROZE_GL.xp_cumulative = 0
        FROZE_GL.pending_level_ups = 0
        FROZE_GL.xp_notification_font = nil 
    end
            
    FROZE_GL.stats_menu = "STATS"
    FROZE_GL.heights_stat_menu_desc = {} 
    --
    FROZE_GL.show_weapon_stats = true
    FROZE_GL.show_weapon_stats_base_mod_num = false
    FROZE_GL.show_weapon_stats_lifetime = 0
    FROZE_GL.line_length = W * 0.75
    FROZE_GL.line_alpha_mul = 1
    --
    FROZE_GL.weapons_table = {}
    FROZE_GL.weapons_table_filtered = {}
    FROZE_GL.weapon_image = "entities/weapon_fists.png"
    FROZE_GL.weapon_rarity_random = "Sample Rarity "
    FROZE_GL.weapon_name_random = "Sample Name" 

    --* choice pickup / choice screen / level up screen
    do 
        FROZE_GL.choice_panels = {}
        FROZE_GL.items_held = {}
        FROZE_GL.skills_held = {}
        FROZE_GL.relics_held = {}
        FROZE_GL.tbl_id_upgrades_statboost = {}
        FROZE_GL.tbl_id_upgrades_item_statboost = {}
        FROZE_GL.tbl_id_upgrades_skill = {}
        FROZE_GL.tbl_id_upgrades_relic = {}
    end

    FROZE_GL.tbl_valid_weapons = {}
    FROZE_GL.tbl_damage_numbers = {}  
    FROZE_GL.tbl_gl_unlockables = {}

    --* GLOBAL ITEM DROPS TABLE
    FROZE_GL.garlic_like_item_drops_entities = {}

    FROZE_GL.tbl_gl_entities = {
        gl .. "wep_crystal", gl .. "weapon_crate_entity", gl .. "station_item_fusing", gl .. "station_weapon_upgrade"
    }

    --* circle colors
    do 
        FROZE_GL.item_circle_colors = {
            [1] = color_white,
            [2] = color_white,
            [3] = color_white,
            [4] = color_white
        }

        FROZE_GL.skill_circle_colors = {
            [1] = color_white,
            [2] = color_white,
            [3] = color_white,
            [4] = color_white
        }

        FROZE_GL.relic_circle_colors = {
            [1] = color_white,
            [2] = color_white,
            [3] = color_white,
            [4] = color_white,
            [5] = color_white,
            [6] = color_white,
            [7] = color_white,
            [8] = color_white,
            [9] = color_white,
            [10] = color_white,
            [11] = color_white,
            [12] = color_white,
        }

        FROZE_GL.skill_cooldown_dark = {
            [1] = color_black_alpha_150,
            [2] = color_black_alpha_150,
            [3] = color_black_alpha_150,
            [4] = color_black_alpha_150
        }

        FROZE_GL.skill_cooldown_numbers = {
            [1] = "",
            [2] = "",
            [3] = "",
            [4] = ""
        }

        FROZE_GL.tbl_rarity_colors = {
            ["poor"] = Color(189, 189, 189),
            ["common"] = Color(255, 255, 255),
            ["uncommon"] = Color(111, 221, 255),
            ["rare"] = Color(0, 132, 255),
            ["epic"] = Color(195, 0, 255),
            ["legendary"] = Color(255, 72, 0),
            ["ultimate"] = Color(255, 0, 0),
        }
    end

    --* RARITY CHANCES 
    do 
        FROZE_GL.rarity_wep = {
            ["poor"] = {
                min = 0,
                max = 0,
                weight = 50
            },
            ["common"] = {
                min = 0,
                max = 0,
                weight = 240
            },
            ["uncommon"] = {
                min = 0,
                max = 0,
                weight = 120
            },
            ["rare"] = {
                min = 0,
                max = 0,
                weight = 60
            },
            ["epic"] = {
                min = 0,
                max = 0,
                weight = 30
            },
            ["legendary"] = {
                min = 0,
                max = 0,
                weight = 15
            },
            ["ultimate"] = {
                min = 0,
                max = 0,
                weight = 5
            }
        }

        -- create min maxes
        FROZE_GL.rarity_starting_num = 1

        -- create sum
        FROZE_GL.rarity_weights_sum = 0

        FROZE_GL.cleared_rarities = table.ClearKeys(FROZE_GL.rarities)
        -- PrintTable(FROZE_GL.cleared_rarities)
    end
    
    FROZE_GL.gl_stored_bonused_weapons = {}
    -- 
    FROZE_GL.skills = {}

    FROZE_GL.FormatColors = {
        [1] = Color(122, 122, 122),
        [2] = Color(146, 58, 58),
        [3] = Color(35, 125, 199),
        [4] = Color(204, 44, 138),
        [5] = Color(158, 41, 226),
        [6] = Color(195, 231, 33),
    }

    --* MATERIALS INVENTORY
    FROZE_GL.WepCrystalsInventory = {
        [1] = {
            name = "Poor Ore",
            rarity = "poor",
            material = Material("garlic_like/icon_materials/icon_poor_ore.png"),
            held_num = 0
        },
        [2] = {
            name = "Common Ore",
            rarity = "common",
            material = Material("garlic_like/icon_materials/icon_common_ore.png"),
            held_num = 0
        },
        [3] = {
            name = "Uncommon Ore",
            rarity = "uncommon",
            material = Material("garlic_like/icon_materials/icon_uncommon_ore.png"),
            held_num = 0
        },
        [4] = {
            name = "Rare Ore",
            rarity = "rare",
            material = Material("garlic_like/icon_materials/icon_rare_ore.png"),
            held_num = 0
        },
        [5] = {
            name = "Epic Crystal",
            rarity = "epic",
            material = Material("garlic_like/icon_materials/icon_epic_crystal.png"),
            held_num = 0
        },
        [6] = {
            name = "Legendary Crystal",
            rarity = "legendary",
            material = Material("garlic_like/icon_materials/icon_legendary_crystal.png"),
            held_num = 0
        },
        [7] = {
            name = "Ultimate Crystal",
            rarity = "ultimate",
            material = Material("garlic_like/icon_materials/icon_god_crystal.png"),
            held_num = 0
        },
    } 

    --* INVENTORY MENU
    FROZE_GL.tbl_menu_inventory = {
        consumables = {},
        materials = {}, 
        obtained_weapons = {},
    } 

    if IsValid(LocalPlayer()) then 
        LocalPlayer():ConCommand("garlic_like_debug_create_obtained_weapons_tbl2")
    end

    FROZE_GL.tbl_anim_frame_id = FROZE_GL.tbl_anim_frame_id or {}

    -- fill in the materials table above A
    for k, v in pairs(FROZE_GL.tbl_menu_inventory_items_data) do 
        if v.material then   
            FROZE_GL.tbl_menu_inventory.materials[#FROZE_GL.tbl_menu_inventory.materials + 1] = {
                id = k, 
                name = v.name, 
                desc = v.desc,
                icon_mat = v.icon_mat, 
                is_ore = v.is_ore,
                is_currency = v.is_currency,
                is_material = v.is_material,
                rarity = v.rarity,
                amount = 0,
            }
        end
    end

    -- PrintTable(FROZE_GL.tbl_menu_inventory)
    --* other tables
    do         
        FROZE_GL.tbl_glss = {
            glss_left_pos = W * 0.25 - W * 0.025,
            glss_mid_pos = W * 0.5 - W * 0.025,
            glss_right_pos = W * 0.75 - W * 0.025,
            glss_left_pos_base = W * 0.25,
            glss_mid_pos_base = W * 0.5,
            glss_right_pos_base = W * 0.75,
            glss_height_1 = H * 0.15,
        }

        FROZE_GL.tbl_ult = {
            ult_cooldown = 60,
            ult_num_cooldown = 60,
            ult_starttime = RealTime(),
            ult_clicked = false,
            ult_key_combo_activated = false,
        }

        FROZE_GL.tbl_gold_popups = {}

        FROZE_GL.tbl_gold_hud = {
            scale_vector = Vector(2, 2, 2),
            scale_num = 1,
            scale_mod = 0,
            bounce = false,
        }

        FROZE_GL.glips = {
            entries = {},
            bg_height = H * 0.055,
            bg_width = W * 0.2,
            color_bg = Color(0, 0, 0, 200),
        }

        FROZE_GL.tbl_crystal_clusters = {}
        
        FROZE_GL.tbl_unlocks_queue = {}

        FROZE_GL.tbl_unlocks_hud = {
            pos_x_bg = W * 0.77, 
            pos_y_bg = -H * 0.12, 
            target_pos_x_bg = W * 0.77, 
            target_pos_y_bg = H * 0.01, 
            w_bg = W * 0.22, 
            h_bg = H * 0.12,
            lifetime = 0,
            text = "",
            show = true,
            isrunning = false,
            audioplayed = false,
        }

        FROZE_GL.tbl_break_hud = {
            text_break = "BREAK TIME!",
            text_time = 0,
            tb_pos_x = W * 0.5,
            tb_pos_y = H * 0.2,
        }

        FROZE_GL.tbl_hud_elements = {
            apbar_t_x = W * 0.376,
            apbar_t_y = H * 0.803,
            apbar_x = W * 0.391, 
            apbar_y = H * 0.794,
            apbar_w = W * 0.235,
            apbar_h = H * 0.02,
            apbar_color = Color(99, 81, 0),
            apbar_color_gradient = Color(255, 208, 0),
            hpbar_t_x = W * 0.376,
            hpbar_t_y = H * 0.823,
            hpbar_x = W * 0.391, 
            hpbar_y = H * 0.815,
            hpbar_w = W * 0.235,
            hpbar_h = H * 0.02,
            hpbar_color = Color(0, 0, 108),
            hpbar_color_gradient = Color(35, 210, 90),
            hpbar_color_2 = Color(0, 0, 108),
            hpbar_color_gradient_2 = Color(223, 63, 255),
            mpbar_t_x = W * 0.376,
            mpbar_t_y = H * 0.843,
            mpbar_x = W * 0.391, 
            mpbar_y = H * 0.835,
            mpbar_w = W * 0.235,
            mpbar_h = H * 0.02,
            mpbar_color = Color(0, 87, 138),
            mpbar_color_gradient = Color(68, 186, 255),
        }

        FROZE_GL.hide = {
            ["CHudHealth"] = true,
            ["CHudBattery"] = true
        }

        FROZE_GL.tbl_run_end_screen = { 
            res_t_life = 0,
            bg_color = Color(0, 0, 0, 0),
            res_size_num = 60,
            mat_flare = Material("garlic_like/lens_flare_1.png"),
            flare_w = W * 0.3, 
            flare_h = H * 0.45,
            flare_a = 255, 
            color_yellow = Color(255, 196, 0),
            time_survived_min = 0,
            time_survived_seconds = 0, 
            gold_gained = 0,
            level_reached = 0,
            enemy_hp_mult = 0,
            enemy_dmg_mult = 0,
            enemy_dr_mult = 0,
            total_dmg_dealt = 0,
            total_dmg_taken = 0,
            highest_dmg = 0,       
            total_seconds = 0,
            rank_xp_gained = 1111,
            shown_time_survived_min = 0,
            shown_time_survived_seconds = 0,
            shown_gold_gained = 0,
            shown_level_reached = 0,
            shown_enemy_hp_mult = 0,
            shown_enemy_dmg_mult = 0,
            shown_enemy_dr_mult = 0,
            shown_total_dmg_dealt = 0,
            shown_total_dmg_taken = 0,
            shown_highest_dmg = 0, 
            shown_rank_xp_gained = 0,
            sound_played = false, 
        }

        --* rank stuff
        FROZE_GL.tbl_run_end_screen_2 = {
            is_running = false,
            stop_running = true, 
            tbl_gained_chests = {},
            w_xp_bar = 0,
            color_xp_bar_bg = Color(0, 0, 0, 100),
            color_xp_bar = Color(255, 166, 0, 200),
            color_xp_bar_highlight = Color(255, 255, 255, 0),                
            rank_num = 1,
            rank_xp_gained = nil,
            rank_xp_gained_2 = 0,
            rank_xp_current = 0,
            rank_xp_to_rank_up = 7,
            time_elapsed = 0,
            time_elapsed_hold_rmb = 0,
        }

        FROZE_GL.tbl_inventory_menu = {
            color_inventory_box = Color(128, 128, 128),
        }

        FROZE_GL.tbl_invalid_tfa_upgrades = {"bash_speed", "bash_damage"}

        FROZE_GL.scaledfonts = {}

        FROZE_GL.tbl_named_colors = {
            red = Color(255, 0, 0),
            green = Color(0, 255, 0),
            blue = Color(0, 0, 255),
            yellow = Color(255, 255, 0),
            cyan = Color(0, 255, 255),
            magenta = Color(255, 0, 255),
            white = Color(255, 255, 255),
            black = Color(0, 0, 0),
        }

        FROZE_GL.tbl_menu_colors = {
            color_base = Color(61, 61, 61),
            color_but1 = Color(255, 166, 0, 255),
            color_but_grey = Color(100, 100, 100, 255),
        }
    end
    
    --* set this to false to debug and have it show isntantly
    FROZE_GL.run_end_screen_stop_showing = true
    FROZE_GL.run_end_screen_progress_num = 0
end

--* operations on the variables 
do 
    for i = 1, 9 do
        FROZE_GL.heights_stat_menu_desc[#FROZE_GL.heights_stat_menu_desc + 1] = H * (0.31 + (0.025 * i))
    end

    for k, entry in SortedPairs(FROZE_GL.rarity_wep) do
        entry.min = FROZE_GL.rarity_starting_num
        entry.max = FROZE_GL.rarity_starting_num + entry.weight
        FROZE_GL.rarity_starting_num = FROZE_GL.rarity_starting_num + entry.weight
    end

    for k, rarity in pairs(FROZE_GL.rarity_wep) do
        FROZE_GL.rarity_weights_sum = FROZE_GL.rarity_weights_sum + rarity.weight
    end 

    for k, v in pairs(FROZE_GL.tbl_rarity_colors) do 
        FROZE_GL.tbl_crystal_clusters[k] = {}
    end

    for id, upgrade in SortedPairs(FROZE_GL.garlic_like_upgrades) do
        if upgrade.upgrade_type == "statboost" then
            table.insert(FROZE_GL.tbl_id_upgrades_statboost, id)
        elseif upgrade.upgrade_type == "item_statboost" then
            table.insert(FROZE_GL.tbl_id_upgrades_item_statboost, id)
        elseif upgrade.upgrade_type == "skill" then
            table.insert(FROZE_GL.tbl_id_upgrades_skill, id)
        elseif upgrade.upgrade_type == "relic" then
            table.insert(FROZE_GL.tbl_id_upgrades_relic, id)
        end
    end 
end

cvars.AddChangeCallback(gl .. "hud_font", function(name, old, new)
    garlic_like_create_fonts()
end)

cvars.AddChangeCallback(gl .. "hud_font_2", function(name, old, new)
    garlic_like_create_fonts()
end)  

--* global clientside functions
do  
    function garlic_like_update_tbl_valid_weapons()
        FROZE_GL.tbl_valid_weapons = {}
        FROZE_GL.weapons_table = weapons.GetList()
        
        for k, wep in SortedPairs(weapons.GetList()) do
            str_1, str_2 = string.find(wep.ClassName, "base") 
            if wep.Base == "tfa_nade_base" then continue end
            if wep.Base == "arccw_base" then continue end 
            if string.find(wep.ClassName, "arccw") then continue end 
            if table.HasValue(FROZE_GL.tbl_wep_blacklist, wep.ClassName) then continue end

            --* power limits
            if GetGlobalBool(gl .. "match_running") then 
                if (garlic_like_is_tfa_wep(wep)) and not string.find(wep.ClassName, "FROZE_GL.default_gun") and FROZE_GL.tbl_wep_power[wep.ClassName] and FROZE_GL.tbl_wep_power[wep.ClassName] <= GetGlobalInt(gl .. "wep_power_limit", 10000) then 
                --* does not use limits
                -- if (garlic_like_is_arccw_wep(wep) or garlic_like_is_tfa_wep(wep)) and not string.find(wep.ClassName, "arccw_g18_garlic_like") then 
                    table.insert(FROZE_GL.tbl_valid_weapons, wep)
                end
            else 
                table.insert(FROZE_GL.tbl_valid_weapons, wep)
            end

            if wep.ClassName == "weapon_fists" then
                tbl_fallback_weapon = wep
            end
        end 

        --* check if the client owns the gun in FROZE_GL.tbl_menu_inventory.obtained_weapons 
        local filtered_weapons = {}
        for _, wep in ipairs(FROZE_GL.tbl_valid_weapons) do
            local is_owned = false
            for _, owned_wep in pairs(FROZE_GL.tbl_menu_inventory.obtained_weapons) do
                if owned_wep.classname == wep.ClassName and owned_wep.owned then
                    is_owned = true
                    break
                end
            end
            if is_owned then
                table.insert(filtered_weapons, wep)
            end
        end
        FROZE_GL.tbl_valid_weapons = filtered_weapons
    end
    
    function garlic_like_init_unlockables() 
        local ply = LocalPlayer()
        --* CREATE UNLOCKABLES FOR CHAR UPGRADES
        for k, stat in pairs(FROZE_GL.tbl_character_stats) do 
            if stat.unlock_condition then             
                FROZE_GL.tbl_gl_unlockables[stat.id] = {
                    unlock_status = false, 
                    unlock_condition = stat.unlock_condition,
                    unlock_text = "Unlocks " .. stat.name .. " Char Upgrade",
                }

                if ply:GetPData(gl .. stat.id .. "_unlocked") == "true" then 
                    FROZE_GL.tbl_gl_unlockables[stat.id].unlock_status = true
                end
            end
        end

        --* UNLOCKABLES FOR RELIC SLOTS
        ply:SetNWInt(gl .. "relic_slots_unlocked", 0)

        for i = 1, 8 do 
            local unlock_condition = ""

            if i == 1 then 
                unlock_condition = "Survive for 10 minutes."
            elseif i == 2 then 
                unlock_condition = "Survive for 15 minutes."
            elseif i == 3 then 
                unlock_condition = "Survive for 20 minutes."
            elseif i == 4 then 
                unlock_condition = "Survive for 30 minutes."
            elseif i == 5 then 
                unlock_condition = "Obtain a legendary rarity relic."
            elseif i == 6 then 
                unlock_condition = "Obtain a ultimate rarity relic."
            elseif i == 7 then 
                unlock_condition = "Reach level 50."
            elseif i == 8 then 
                unlock_condition = "Deal a total of 1000000 damage in a single run."
            end

            FROZE_GL.tbl_gl_unlockables[gl .. "relic_slot_" .. i] = {
                unlock_status = false, 
                unlock_condition = unlock_condition,
                unlock_text = "Unlocks a Relic Slot",
            }

            if tobool(ply:GetPData(gl .. "relic_slot_" .. i .. "_unlocked")) then 
                FROZE_GL.tbl_gl_unlockables[gl .. "relic_slot_" .. i].unlock_status = true

                ply:SetNWInt(gl .. "relic_slots_unlocked", ply:GetNWInt(gl .. "relic_slots_unlocked", 0) + 1)
            end

            FROZE_GL.tbl_gl_unlockables[gl .. "summon20"] = {
                unlock_status = false, 
                unlock_condition = "Summon weapons 200 times.",
                unlock_text = "Unlocks the Summon x20 feature.",
            }

            FROZE_GL.tbl_gl_unlockables[gl .. "summon40"] = {
                unlock_status = false, 
                unlock_condition = "Summon weapons 500 times.",
                unlock_text = "Unlocks the Summon x40 feature.",
            }

            if tobool(ply:GetPData(gl .. "summon20_unlocked")) then 
                FROZE_GL.tbl_gl_unlockables[gl .. "summon20"].unlock_status = true 
            end

            if tobool(ply:GetPData(gl .. "summon40_unlocked")) then 
                FROZE_GL.tbl_gl_unlockables[gl .. "summon40"].unlock_status = true 
            end
        end

        --* CREATE UNLOCKABLES FOR ITEM DROPS 

        --* CREATE UNLOCKABLES FOR RELIC DROPS 
    end

    function garlic_like_init() 
        timer.Simple(1, function() 
            garlic_like_init_unlockables()  
            garlic_like_update_tbl_valid_weapons()
        end)
    end   

    function garlic_like_start_cl() 
        local ply = LocalPlayer()                        
    end

    function garlic_like_give_item(id, amount)   
        if id == "gold" then 
            garlic_like_update_money(amount, "GAIN_MONEY") 
        end

        -- print("TRYING TO GIVE: " .. id .. " AMOUNT: " .. amount)
        net.Start(gl .. "send_give_item_cl_to_sv") 
        net.WriteString(id)
        net.WriteInt(amount, 32)
        net.SendToServer()
    end

    function garlic_like_get_weapon(wep_choice, tbl_valid_weapons, get_type, rarity)
        wep_choice.wep_rarity = rarity
        wep_choice.wep_rarity_color = FROZE_GL.tbl_rarity_colors[wep_choice.wep_rarity]
        wep_choice.wep_element = FROZE_GL.tbl_elements[math.random(1, #FROZE_GL.tbl_elements)]
        wep_choice.wep_element_tier = 0
        wep_choice.wep_bonuses_amount = garlic_like_determine_weapon_bonuses_amount(wep_choice.wep_rarity)
        wep_choice.wep_bonuses_modifier = garlic_like_determine_weapon_bonuses_modifiers(wep_choice.wep_rarity)
        wep_choice.wep_base_rarity_mod_num = math.Truncate(FROZE_GL.tbl_wep_rarity_base_stat_modifier_nums[garlic_like_rarity_to_num(rarity)] * math.Rand(0.85, 1.15), 3)            
        wep_choice.wep_bonuses = {}            

        if wep_choice.wep_bonuses_amount > 0 then
            local rarity_rand_modifier = math.Remap(garlic_like_rarity_to_num(wep_choice.wep_rarity), 1, 7, 1.5, 2)

            for i = 1, wep_choice.wep_bonuses_amount do
                local get_tbl_bonus = FROZE_GL.tbl_bonuses_weapons[math.random(1, #FROZE_GL.tbl_bonuses_weapons)]

                wep_choice.wep_bonuses[i] = {
                    id = i,
                    name = get_tbl_bonus.name,
                    modifier = get_tbl_bonus.modifier,
                    desc = get_tbl_bonus.desc,
                    upgrade_mul = get_tbl_bonus.upgrade_mul,
                    max_mul = get_tbl_bonus.max_mul,
                    type_mul = get_tbl_bonus.type_mul,
                }
            end

            local mod_stars = 1 

            -- print("GET TYPE:", get_type)
 
            --* moved down
            -- if FROZE_GL.wep_cso[get_type] then 
            --     for k, data in pairs(FROZE_GL.tbl_menu_inventory.obtained_weapons) do 
            --         if data.classname == wep_choice.wep.ClassName then 
            --             mod_stars = 1 + (data.stars * 0.15)
            --             break
            --         end
            --     end
            -- end

            -- wep_choice.wep_bonuses_modifier = wep_choice.wep_bonuses_modifier * mod_stars 
            -- wep_choice.wep_base_rarity_mod_num = math.Truncate(wep_choice.wep_base_rarity_mod_num * mod_stars, 3)

            -- print("FINAL MOD STARS:", mod_stars)
            -- print("FINAL MOD STARS:", mod_stars)
            -- print("FINAL MOD STARS:", mod_stars)

            for k, bonus in pairs(wep_choice.wep_bonuses) do
                bonus.modifier = math.Truncate(bonus.modifier * wep_choice.wep_bonuses_modifier * math.Rand(0.25 * rarity_rand_modifier, 0.5 * rarity_rand_modifier), 3)
            end
        end
        
        if get_type == "ROLL" then
            -- print("ROLL CHOICE WEP")
            wep_choice.wep = tbl_valid_weapons[math.random(1, #tbl_valid_weapons)]
        elseif get_type == "FALLBACK" then
            wep_choice.wep = tbl_fallback_weapon
        else 
            --* get type is actually the wep classname here
            -- print("GET TYPE: " .. get_type)
            for k, data in pairs(tbl_valid_weapons) do 
                if data.ClassName == get_type then 
                    wep_choice.wep = data
                end
            end
        end
 
        --* STARS MODIFIER
        for k, data in pairs(FROZE_GL.tbl_menu_inventory.obtained_weapons) do 
            if data.classname == wep_choice.wep.ClassName then 
                mod_stars = 1 + (data.stars * 0.12)
                break
            end
        end 

        -- wep_choice.wep_bonuses_modifier = wep_choice.wep_bonuses_modifier * mod_stars 
        wep_choice.wep_base_rarity_mod_num = math.Truncate(wep_choice.wep_base_rarity_mod_num * mod_stars, 3)

        for k, bonus in pairs(wep_choice.wep_bonuses) do
            bonus.modifier = math.Truncate(bonus.modifier * mod_stars, 3)
        end

        wep_choice.wep_name = wep_choice.wep.PrintName
        wep_choice.wep_stored = weapons.Get(wep_choice.wep.ClassName)
        wep_choice.wep_icon = wep_choice.wep_stored.WepSelectIcon or weapons.Get(wep_choice.wep_stored.Base).WepSelectIcon 

        if garlic_like_is_arccw_wep(wep_choice.wep) then
            local mat = Material("arccw/weaponicons/" .. wep_choice.wep.ClassName)

            if not mat:IsError() then
                wep_choice.wep_icon = surface.GetTextureID(mat:GetTexture("$basetexture"):GetName())
                -- print("ICON " .. wep_choice.wep_icon)
            end
        end

        if garlic_like_is_tfa_wep(wep_choice.wep) then 
            wep_choice.wep_icon = Material("entities/" .. wep_choice.wep.ClassName .. ".png")
            wep_choice.wep_icon_is_material = true
        end

        if wep_choice.wep_icon == nil then
            wep_choice.wep_icon_use_backup = true
        end

        if not wep_choice.loop then 
            wep_choice.loop = 0
        end

        while wep_choice.wep == nil or wep_choice.wep.PrintName == nil do
            wep_choice.loop = wep_choice.loop + 1
            --
            garlic_like_get_weapon(wep_choice, FROZE_GL.tbl_valid_weapons, "ROLL", rarity)

            if wep_choice.loop > 50 then
                garlic_like_get_weapon(wep_choice, FROZE_GL.tbl_valid_weapons, "FALLBACK", rarity)
            end
        end
    end 

    function garlic_like_store_wep_bonuses(ply, wep_choice) 
        if wep_choice.wep_bonuses_amount > 0 then
            FROZE_GL.gl_stored_bonused_weapons[wep_choice.wep.ClassName] = {
                bonuses = {},
                bonus_amount = 0,
                name = "",
                rarity = "",
                base_rarity_mod_num = 0,
                level = 1
            }

            FROZE_GL.gl_stored_bonused_weapons[wep_choice.wep.ClassName].bonuses = wep_choice.wep_bonuses
            FROZE_GL.gl_stored_bonused_weapons[wep_choice.wep.ClassName].name = wep_choice.wep.PrintName
            FROZE_GL.gl_stored_bonused_weapons[wep_choice.wep.ClassName].rarity = wep_choice.wep_rarity
            FROZE_GL.gl_stored_bonused_weapons[wep_choice.wep.ClassName].element = wep_choice.wep_element.name
            FROZE_GL.gl_stored_bonused_weapons[wep_choice.wep.ClassName].element_tier = wep_choice.wep_element_tier
            FROZE_GL.gl_stored_bonused_weapons[wep_choice.wep.ClassName].bonus_amount = wep_choice.wep_bonuses_amount
            FROZE_GL.gl_stored_bonused_weapons[wep_choice.wep.ClassName].base_rarity_mod_num = wep_choice.wep_base_rarity_mod_num
            FROZE_GL.gl_stored_bonused_weapons[wep_choice.wep.ClassName].level = 1 
        end

        -- PrintTable( FROZE_GL.gl_stored_bonused_weapons)
        --
        net.Start(gl .. "choose_weapon")
        net.WriteString(wep_choice.wep.ClassName)
        net.WriteString("PICK_WEAPON")
        net.WriteTable( FROZE_GL.gl_stored_bonused_weapons)
        net.WriteTable({})
        net.SendToServer()

        timer.Simple(0.1, function() 
            if not IsValid(ply) then return end 
            
            --* gives the bonused table to the wep entity
            for class_name, entry in pairs(FROZE_GL.gl_stored_bonused_weapons) do 
                for k, wep in pairs(ply:GetWeapons()) do 
                    if wep:GetClass() == class_name then 
                        wep.gl_stored_bonused_weapon = entry
                    end
                end
            end
        end)
    end

    function garlic_like_update_materials(name, amount) 
        net.Start(gl .. "update_database_cl_to_sv")                      
        net.WriteString(name)
        net.WriteInt(amount, 32)
        net.WriteString("MATERIAL_UPDATE")
        net.WriteTable({})
        net.WriteString("")
        net.WriteFloat(0)
        net.WriteInt(0, 32)
        net.WriteString("")
        net.SendToServer() 
    end

    function garlic_like_update_ores(name, amount) 
        net.Start(gl .. "update_database_cl_to_sv")                      
        net.WriteString(name)
        net.WriteInt(amount, 32)
        net.WriteString("ORE_UPDATE")
        net.WriteTable({})
        net.WriteString("")
        net.WriteFloat(0)
        net.WriteInt(0, 32)
        net.WriteString("")
        net.SendToServer() 
    end

    function garlic_like_update_money(price, operation) 
        net.Start(gl .. "update_database_cl_to_sv") 
        net.WriteString("money")
        net.WriteInt(price, 32)
        net.WriteString(operation)
        net.WriteTable({})
        net.SendToServer() 
    end

    function garlic_like_animated_xp_fonts_create()
        for i = 1, 30 do
            number = H * 0.116928 - i * (H * 0.00283)
            number_extra = H * 0.095 - i * (H * 0.0023)

            surface.CreateFont(gl .. "xp_notification_" .. i, {
                font = GetConVar(gl .. "hud_font_2"):GetString(),
                extended = false,
                size = number,
                weight = 500,
                blursize = 0,
                scanlines = 0,
                antialias = true,
                underline = false,
                italic = false,
                strikeout = false,
                symbol = false,
                shadow = true,
                outline = false,
            })

            surface.CreateFont(gl .. "xp_notification_extra_" .. i, {
                font = GetConVar(gl .. "hud_font_2"):GetString(),
                extended = false,
                size = number_extra,
                weight = 300,
                blursize = 0,
                scanlines = 0,
                antialias = true,
                underline = false,
                italic = false,
                strikeout = false,
                symbol = false,
                shadow = true,
                outline = false,
            })

            number = H * (0.042 - (i * 0.000466))

            surface.CreateFont(gl .. "font_money_" .. i, {
                font = GetConVar(gl .. "hud_font_2"):GetString(),
                extended = false,
                size = number,
                weight = 500,
                blursize = 0,
                scanlines = 0,
                antialias = true,
                underline = false,
                italic = false,
                strikeout = false,
                symbol = false,
                rotary = false,
                shadow = true,
                additive = false,
                outline = false,
            })
        end
    end

    function garlic_like_update_hud_skills(ply, skill_name)
        for k, upgrade in SortedPairs(table.ClearKeys(FROZE_GL.skills_held)) do
            if upgrade.name2 == skill_name then
                local cd_number = GetConVar("dota2_auto_cast_" .. upgrade.name2 .. "_delay"):GetFloat()
                -- local cd_number = upgrade.cooldown
                -- print("UPDATE HUD SKILLS")
                FROZE_GL.skill_cooldown_numbers[k] = nil
                FROZE_GL.skill_cooldown_dark[k] = color_black_alpha_150
                FROZE_GL.skill_cooldown_numbers[k] = cd_number

                for i = 1, cd_number * 100 do
                    timer.Simple(i / 100, function()
                        FROZE_GL.skill_cooldown_numbers[k] = cd_number - i / 100

                        if FROZE_GL.skill_cooldown_numbers[k] <= 0 then
                            FROZE_GL.skill_cooldown_numbers[k] = 0

                            return
                        end
                    end)
                end
            end
        end
    end

    function garlic_like_start_auto_cast(ply, upgrade, damage, cooldown, area)
        -- print("AUTO CAST SETTINGS")
        -- print("dota2_auto_cast_" .. upgrade.name2 .. "_delay " .. tostring(cooldown))
        ply:ConCommand("dota2_damage_" .. upgrade.name2 .. " " .. tostring(damage))
        ply:ConCommand("dota2_auto_cast_" .. upgrade.name2 .. " 1")
        ply:ConCommand("dota2_auto_cast_" .. upgrade.name2 .. "_delay " .. tostring(cooldown))

        if type(area) == "number" then
            ply:ConCommand("dota2_radius_" .. upgrade.name2 .. " " .. tostring(area))
        end
    end

    function garlic_like_determine_wep_rarity() 
        return FROZE_GL.rarity_weights_new:Roll()["name"]
    end

    function garlic_like_determine_stats(tbl_upgrade, upgrade_type)
        local rarity
        local statboost_num
        local chance = math.random()

        -- 10%
        -- if chance <= 0.1 then
        --     rarity = "poor"
        --     num_modifier = 0.5
        -- elseif chance <= 0.25 then
        --     -- 40% 
        --     rarity = "common"
        --     num_modifier = 1
        -- elseif chance <= 0.7 then
        --     -- 20% 
        --     rarity = "uncommon"
        --     num_modifier = 1.25
        -- elseif chance <= 0.82 then
        --     -- 12%
        --     rarity = "rare"
        --     num_modifier = 1.75
        -- elseif chance <= 0.91 then
        --     -- 9%
        --     rarity = "epic"
        --     num_modifier = 2.5
        -- elseif chance <= 0.97 then
        --     -- 6%
        --     rarity = "legendary"
        --     num_modifier = 3.5
        -- elseif chance <= 1 then
        --     -- 3% 
        --     rarity = "ultimate"
        --     num_modifier = 5
        -- end           
        
        local tbl_rarity_to_num_mod = {
            poor = 0.5,
            common = 1,
            uncommon = 1.25,
            rare = 1.75,
            epic = 2.5,
            legendary = 3.5,
            ultimate = 5
        }

        rarity = FROZE_GL.rarity_weights_new:Roll()["name"] 

        num_modifier = tbl_rarity_to_num_mod[rarity]

        if upgrade_type == "statboost" then
            statboost_num = math.Round(1 + 2 * num_modifier * (1 + tbl_upgrade.upgrade_level * 0.08))
            -- print("DETERMINED STAT BOOST RARITY " .. rarity)
            --* IF CARNAGE
            if GetGlobalInt(gl .. "minutes", 1) >= 20 and ply:GetNWInt(gl .. string.upper(tbl_upgrade.name), 1) >= 150 then 
                statboost_num = statboost_num * 5
            end

            return rarity, statboost_num
        elseif upgrade_type == "item_statboost" then
            --* if the upgrade_type is item_statboost and the player already has that item in their items_held, then apply the already owned item's rarity and num_modifier 
            -- PrintTable(tbl_upgrade)
            local has_the_item = false
            local owned_item_statboost 
            local statboost_increase_amount
            local stacks = 0
            local number_addition

            -- print("tbl_upgrade.name : " .. tbl_upgrade.name)
            -- print("tbl_upgrade.number_addition : " .. tbl_upgrade.number_addition) 

            for k, v in pairs(FROZE_GL.items_held) do 
                -- print("KEY IS: " .. k)
                -- PrintTable(v)
                for k2, v2 in pairs(tbl_upgrade) do 
                    if v.name == tbl_upgrade.name then 
                        rarity = v.rarity  
                        num_modifier = garlic_like_rarity_to_num(rarity)

                        has_the_item = true 
                        owned_item_statboost = v.statboost
                        stacks = v.stacks
                        number_addition = v.number_addition
                        -- PrintTable(v) 
                    end
                end
            end

            if tbl_upgrade.number_addition == -1 then 
                num_modifier = math.Truncate(math.max(1, garlic_like_rarity_to_num(rarity) * 0.75, 3))
            end

            -- print("tbl_upgrade.statboost " .. tbl_upgrade.statboost) 
            -- print("tbl_upgrade.upgrade_level " .. tbl_upgrade.upgrade_level)
            -- print("num_modifier " .. num_modifier)

            statboost_increase_amount = math.Truncate(tbl_upgrade.statboost * num_modifier, 3)

            if not has_the_item then 
                statboost_num = statboost_increase_amount
            else 
                if number_addition == 1 then 
                    statboost_num = owned_item_statboost + statboost_increase_amount
                elseif number_addition == -1 then 
                    statboost_num = math.Truncate((1 - (1 - statboost_increase_amount)^(stacks + 1)), 3)
                end
            end

            -- print("determine statboost_num " .. statboost_num)

            -- print("DETERMINE ITEM RARITY " .. tbl_upgrade.name)
            -- print("DETERIMEND STATBOOST: " .. statboost_num)

            return rarity, math.Truncate(statboost_num, 3), statboost_increase_amount, stacks 
        elseif upgrade_type == "skill" then
            damage = math.Round(tbl_upgrade.damage * math.Remap(num_modifier, 1, 7, 1, 1.3) * (1 + tbl_upgrade.upgrade_level * 0.05))
            cooldown = tonumber(string.format("%.2f", GetConVar("dota2_auto_cast_" .. tbl_upgrade.name2 .. "_delay"):GetFloat() * math.Remap(num_modifier, 1, 7, 1, 0.7) * (1 + tbl_upgrade.upgrade_level * 0.05)))

            if type(tbl_upgrade.area) == "string" then
                -- print("DETERMINED SKILL RARITY")

                return rarity, damage, cooldown
            elseif type(tbl_upgrade.area) == "number" then
                area = math.Round(tbl_upgrade.area * math.Remap(num_modifier, 1, 7, 1, 1.5))

                return rarity, damage, cooldown, area
            end
        elseif upgrade_type == "relic" then
            if not tbl_upgrade.mul_is_debuff then
                mul = math.Truncate(tbl_upgrade.mul * math.Remap(num_modifier, 1, 7, 1, 1.5), 2)
            else
                mul = math.Truncate(tbl_upgrade.mul * math.Remap(num_modifier, 1, 7, 1, 0.65), 2)
            end

            if tbl_upgrade.mul_2 == nil then
                return rarity, mul
            elseif tbl_upgrade.mul_2 ~= nil then
                mul_2 = math.Truncate(tbl_upgrade.mul_2 * math.Remap(num_modifier, 1, 7, 1, 1.5), 2)

                return rarity, mul, mul_2
            end
        end
    end

    function garlic_like_save_table_to_json(ply, table_to_convert, table_name)
        local converted_table = util.TableToJSON(table_to_convert, true)
        file.Write(table_name .. ".json", converted_table)
    end

    function garlic_like_load_json_to_table(ply, json_to_convert, table_to_replace)
        local JSON_data = file.Read(json_to_convert)
        table_to_replace = util.JSONToTable(JSON_data)

        return table_to_replace
    end

    function garlic_like_give_hover_sounds(panel, sound) 
        --* USE IN PAINT OR THINK FUNCTION
        if panel:IsHovered() then 
            if not panel.IsHovering then
                surface.PlaySound(sound)
            end

            panel.IsHovering = true
        else 
            panel.IsHovering = false
        end
    end     

    function garlic_like_save_menu_inventory() 
        local tbl_temp = table.Copy(FROZE_GL.tbl_menu_inventory.consumables) 

        for k, v in pairs(tbl_temp) do 
            if v.icon_mat ~= "" then 
                v.icon_mat = ""
            end
        end

        local tbl = util.TableToJSON(tbl_temp, true) 
        file.CreateDir("garlic_like")
        file.Write("garlic_like/inventory_consumables.json", tbl)
    end

    function garlic_like_load_menu_inventory() 
        if not file.Exists("garlic_like/inventory_consumables.json", "DATA") then return end 
        local tbl = util.JSONToTable(file.Read("garlic_like/inventory_consumables.json", "DATA"))

        for k, v in pairs(tbl) do 
            v.icon_mat = Material(v.icon_mat_string .. ".png")
        end

        FROZE_GL.tbl_menu_inventory.consumables = tbl
    end 

    function garlic_like_net_start_chose_upgrade(ply, upgrade, statboost_num, upgrade_mul, upgrade_mul_2)
        if statboost_num == nil or type(statboost_num) == "string" then
            statboost_num = 0
        end

        if upgrade.mul == nil then
            upgrade_mul = 0
        else
            upgrade_mul = upgrade.mul
        end

        if upgrade.mul_2 == nil then
            upgrade_mul_2 = 0
        else
            upgrade_mul_2 = upgrade.mul_2
        end

        if upgrade.name2 == nil then
            upgrade_name_2 = ""
        else
            upgrade_name_2 = upgrade.name2
        end

        net.Start(gl .. "chose_upgrade")
        net.WriteEntity(ply)
        net.WriteString(upgrade.name)
        net.WriteString(upgrade.rarity)
        net.WriteFloat(statboost_num)
        net.WriteString(upgrade.upgrade_type)
        net.WriteString(upgrade_name_2)
        net.WriteFloat(upgrade_mul)
        net.WriteFloat(upgrade_mul_2)

        if not (upgrade.upgrade_type ~= "statboost" or upgrade.upgrade_type ~= "item_statboost") then
            net.WriteString(upgrade.name2)
        end

        net.SendToServer()
        -- PrintTable(upgrade)
    end

    function garlic_like_update_held_upgrade_table(ply, upgrade, statboost_num, item_rarity, damage, cooldown, area, relic_mul, relic_mul_2)
        for k, v in SortedPairs(FROZE_GL.garlic_like_upgrades) do
            if v.name == upgrade.name and upgrade.upgrade_type == "item_statboost" then
                FROZE_GL.garlic_like_upgrades[k].disable_picking_up = false

                if not FROZE_GL.items_held[upgrade.name] then 
                    FROZE_GL.items_held[upgrade.name] = table.Copy(v)
                end

                if not FROZE_GL.items_held[upgrade.name].stacks then 
                    FROZE_GL.items_held[upgrade.name].stacks = 0
                end

                FROZE_GL.items_held[upgrade.name].stacks = FROZE_GL.items_held[upgrade.name].stacks + 1
                FROZE_GL.items_held[upgrade.name].rarity = item_rarity
                FROZE_GL.items_held[upgrade.name].statboost = statboost_num

                -- print("statboost_num " .. statboost_num)

                for k2, v2 in SortedPairs(table.ClearKeys(FROZE_GL.items_held)) do
                    FROZE_GL.item_circle_colors[k2] = FROZE_GL.tbl_rarity_colors[v2.rarity]
                end

                garlic_like_net_start_chose_upgrade(ply, upgrade, statboost_num)
                --
                -- PrintTable(FROZE_GL.garlic_like_upgrades)
            elseif v.name == upgrade.name and upgrade.upgrade_type == "skill" then
                FROZE_GL.garlic_like_upgrades[k].disable_picking_up = true
                FROZE_GL.skills_held[upgrade.name] = v
                FROZE_GL.skills_held[upgrade.name].rarity = item_rarity
                FROZE_GL.skills_held[upgrade.name].damage = damage
                FROZE_GL.skills_held[upgrade.name].cooldown = cooldown
                FROZE_GL.skills_held[upgrade.name].area = area

                if type(upgrade.area) == "string" then
                    garlic_like_start_auto_cast(ply, v, damage, cooldown)
                elseif type(upgrade.area) == "number" then
                    garlic_like_start_auto_cast(ply, v, damage, cooldown, area)
                end

                for k3, v3 in SortedPairs(table.ClearKeys(FROZE_GL.skills_held)) do
                    FROZE_GL.skill_circle_colors[k3] = FROZE_GL.tbl_rarity_colors[v3.rarity]
                end

                garlic_like_net_start_chose_upgrade(ply, upgrade, statboost_num)
                --
                -- PrintTable(FROZE_GL.garlic_like_upgrades)
            elseif v.name == upgrade.name and upgrade.upgrade_type == "relic" then
                FROZE_GL.garlic_like_upgrades[k].disable_picking_up = true
                FROZE_GL.relics_held[upgrade.name] = v
                FROZE_GL.relics_held[upgrade.name].rarity = item_rarity
                FROZE_GL.relics_held[upgrade.name].mul = relic_mul

                if v.mul_2 then
                    FROZE_GL.relics_held[upgrade.name].mul_2 = relic_mul_2
                end

                for k3, v3 in SortedPairs(table.ClearKeys(FROZE_GL.relics_held)) do
                    FROZE_GL.relic_circle_colors[k3] = FROZE_GL.tbl_rarity_colors[v3.rarity]
                end

                garlic_like_net_start_chose_upgrade(ply, upgrade, statboost_num)
                --
                -- PrintTable(FROZE_GL.garlic_like_upgrades)
            end
        end
        -- PrintTable(FROZE_GL.garlic_like_upgrades)
    end

    function garlic_like_choose_upgrade(ply, chosen, upgrade_name, statboost_num, item_rarity, upgrade, damage, cooldown, area, relic_mul, relic_mul_2)
        surface.PlaySound("player/recharged.wav")

        if chosen == nil or not chosen then
            upgrade_name = ""
            statboost_num = 0
        elseif chosen then
            upgrade_name = string.lower(upgrade_name)

            if upgrade.upgrade_type == "statboost" then
                garlic_like_net_start_chose_upgrade(ply, upgrade, statboost_num)
            end

            garlic_like_update_held_upgrade_table(ply, upgrade, statboost_num, item_rarity, damage, cooldown, area, relic_mul, relic_mul_2)
        end
    end 

    function garlic_like_enemies_empowered_hud_show()
        FROZE_GL.show_empowered_text = true
        FROZE_GL.color_empowered_text = color_white

        for i = 1, 50 do
            timer.Simple(i / 500, function()
                surface.CreateFont(gl .. "empowered_text", {
                    font = GetConVar(gl .. "hud_font"):GetString(),
                    extended = false,
                    size = H * 0.001 * i,
                    weight = 500,
                    blursize = 0,
                    scanlines = 0,
                    antialias = true,
                    underline = false,
                    italic = false,
                    strikeout = false,
                    symbol = false,
                    rotary = false,
                    shadow = false,
                    additive = false,
                    outline = true,
                })

                surface.CreateFont(gl .. "empowered_text_sub", {
                    font = GetConVar(gl .. "hud_font_2"):GetString(),
                    extended = false,
                    size = H * 0.0006 * i,
                    weight = 500,
                    blursize = 0,
                    scanlines = 0,
                    antialias = true,
                    underline = false,
                    italic = false,
                    strikeout = false,
                    symbol = false,
                    rotary = false,
                    shadow = false,
                    additive = false,
                    outline = true,
                })

                if i == 50 then
                    timer.Simple(3, function()
                        for transparency = 1, 255 do
                            timer.Simple(transparency / 600, function()
                                FROZE_GL.color_empowered_text = Color(255, 255, 255, 255 - transparency)

                                if transparency == 255 then
                                    FROZE_GL.show_empowered_text = false
                                end
                            end)
                        end
                    end)
                end
            end)
        end
    end

    function garlic_like_determine_weapon_bonuses_amount(rarity)
        local bonus_num = 0
        local rarity_num = garlic_like_rarity_to_num(rarity)
        local chance_get_bonus_stat = 0.1 * rarity_num

        for i = 1, 7 do
            bonus_num = bonus_num + 1
            if bonus_num >= rarity_num then break end
        end

        return bonus_num
    end

    function garlic_like_determine_weapon_bonuses_modifiers(rarity)
        local modifier = 1
        local rarity_num = 1
        --
        if rarity == "poor" then return 0.5 end

        for k, rarity_entry in pairs(FROZE_GL.cleared_rarities) do
            if rarity == rarity_entry then
                rarity_num = k
                modifier = math.Truncate(modifier * math.Remap(rarity_num, 1, 7, 1, 3), 1)
            end
        end

        return modifier
    end

    function garlic_like_rarity_to_num(rarity)
        local num = 0

        for k, rarity_entry in pairs(FROZE_GL.rarities) do
            if rarity == rarity_entry then
                num = k
            end
        end

        return num
    end

    function garlic_like_update_cooldowns_weapon(ply, wep_name)
        for k, skill in pairs(FROZE_GL.skills) do
            RunConsoleCommand("dota2_auto_cast_" .. skill.name .. "_delay", skill.cooldown)
        end

        timer.Simple(0.1, function()
            for k, skill in pairs(FROZE_GL.skills) do
                -- RunConsoleCommand("dota2_auto_cast_" .. skill.name .. "_delay", skill.cooldown / ply:GetNWFloat(gl .. wep_name .. "cooldown_speed", 1))
                -- this is wrong because when you upgrade INT, it takes the _delay convar value, increases it with cdr temp without taking account the decrease made with the wep modifier.
            end
        end)
    end 

    function garlic_like_use_inventory_item(name) 
        for k, v in ipairs(FROZE_GL.tbl_valid_inventory_items) do                 
            if v.name == name then 
                --* for chest type items
                if v.chest_drops then 
                    -- do somethingm, 
                end                    
            end
        end
    end

    function garlic_like_add_inventory_item(name, amount) 
        local ply = LocalPlayer() 

        -- print("added item:", name .. " x" .. amount)
        
        for i = 1, amount do 
            for k, v in ipairs(FROZE_GL.tbl_valid_inventory_items) do 
                if v.name == name then 
                    local chest_drops, found_stackable_same = nil, false 

                    if v.chest_drops then 
                        chest_drops = v.chest_drops
                    end

                    for k2, v2 in pairs(FROZE_GL.tbl_menu_inventory.consumables) do 
                        if v2.name == v.name and v2.amount < 3 then 
                            v2.amount = v2.amount + 1 
                            found_stackable_same = true
                        end
                    end

                    if not found_stackable_same then 
                        FROZE_GL.tbl_menu_inventory.consumables[#FROZE_GL.tbl_menu_inventory.consumables + 1] = {
                            name = v.name,
                            desc = v.desc,
                            chest_drops = chest_drops,
                            icon_mat = v.icon_mat,
                            icon_mat_string = v.icon_mat:GetName(), 
                            rarity = v.rarity,
                            amount = 1,
                        }    
                    end
                end
            end                             
        end
    end

    function garlic_like_pause_game_toggle() 
        if not game.SinglePlayer() then return end 

        net.Start(gl .. "pause_game_cl_to_sv")
        net.SendToServer() 
    end

    function garlic_like_summon(summon_type, amount) 
        local ply = LocalPlayer()
        ply.gl_temp_chest_rewards = {}
        ply.gl_is_summoning = true

        if not amount then 
            amount = 1 
        end

        --* test weapon pulling 
        -- PrintTable(FROZE_GL.rarity_weights_weapons:ListChances())
        for i = 1, amount do  
            if string.lower(summon_type) == "weapon" then 
                local rarity1 = FROZE_GL.rarity_weights_weapons:Roll().name

                if rarity1 == "poor" then 
                    rarity1 = "common"
                end

                for classname, wep in RandomPairs(FROZE_GL.wep_cso) do 
                    if garlic_like_rarity_to_num(rarity1) == wep.rarity_num then 
                        local wep_tbl = weapons.Get(classname)

                        ply.gl_temp_chest_rewards[#ply.gl_temp_chest_rewards + 1] = {
                            name = wep_tbl.PrintName,
                            id = classname,
                            icon_mat = Material("entities/" .. classname .. ".png"),
                            rarity = rarity1,
                            amount = 1,
                            is_weapon = true,
                        }

                        for k, v in pairs(FROZE_GL.tbl_menu_inventory.obtained_weapons) do 
                            if v.classname == classname then 
                                if not v.owned then 
                                    v.owned = true     
                                else 
                                    v.owned_fragments = v.owned_fragments + 1
                                end
                                                                
                                break 
                            end
                        end

                        break 
                    end
                end 
            end
        end

        --* save obtained weapons
        ply:GLSaveObtainedWeapons()

        garlic_like_create_rewards_screen()
    end

    function garlic_like_create_point_bar(type, bar_x, bar_y, bar_w, bar_h, bar_t_x, bar_t_y, bar_color, bar_color_gradient) 
        local ply = LocalPlayer() 
        local front_text = type 
        local cur_points 
        local max_points
        local points_text 
        
        if type == "AP" then 
            cur_points = ply:Armor()
            max_points = 100
            points_text = cur_points
        elseif type == "HP" then 
            cur_points = ply:Health() 
            max_points = ply:GetMaxHealth()
            points_text = cur_points .. " / " .. max_points
        elseif type == "MP" then 
            cur_points = ply:GetNWInt(gl .. "mana", 0) 
            max_points = ply:GetNWInt(gl .. "max_mana", 100)
            points_text = cur_points .. " / " .. max_points
        end

        draw.RoundedBox(0, bar_x - W * 0.015, bar_y, bar_w * 0.065, bar_h, color_black_alpha_200)
        draw.SimpleText(front_text, gl .. "font_subtitle", bar_t_x, bar_t_y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)    
        draw.RoundedBox(0, bar_x, bar_y, bar_w, bar_h, color_black_alpha_225)
        --
        -- local cur_points = ply:Armor()
        -- local max_points = ply:Armor()
        local points_width = math.min(bar_w * 0.985, math.Remap(cur_points, 0, max_points, 0, bar_w * 0.985))
        local points_height = bar_h * 0.7
        local points_x = bar_x * 1.005
        local points_y = bar_y + bar_h * 0.15
        -- the bigger shape
        draw.RoundedBox(0, points_x, points_y, points_width, points_height, bar_color)
        surface.SetDrawColor(bar_color_gradient:Unpack())
        surface.SetMaterial(FROZE_GL.mat_gradient_r) 
        surface.DrawTexturedRectUV(points_x + points_width * 0.2, points_y, points_width * 0.8 - 1, points_height, 0, 0, 1, 1)
        -- small line under
        draw.RoundedBox(0, points_x, points_y + points_height * 0.8, math.max(0, points_width - 1), points_height * 0.2, bar_color_gradient)
        surface.SetDrawColor(bar_color:Unpack())
        surface.SetMaterial(FROZE_GL.mat_gradient_r) 
        surface.DrawTexturedRectUV(points_x + points_width * 0.2, points_y + points_height * 0.8, points_width * 0.8 - 1, points_height * 0.2, 0, 0, 1, 1)

        -- overheal for hp
        if type == "HP" and cur_points > max_points then 
            local points_width_2 = math.min(bar_w * 0.985, math.Remap(cur_points, max_points, max_points * ply:GetNWFloat(gl .. "max_overheal", 1), 0, bar_w * 0.985))
            -- the bigger shape
            draw.RoundedBox(0, points_x, points_y, points_width_2, points_height, FROZE_GL.tbl_hud_elements.hpbar_color_2)
            surface.SetDrawColor(FROZE_GL.tbl_hud_elements.hpbar_color_gradient_2:Unpack())
            surface.SetMaterial(FROZE_GL.mat_gradient_r) 
            surface.DrawTexturedRectUV(points_x + points_width_2 * 0.2, points_y, points_width_2 * 0.8 - 1, points_height, 0, 0, 1, 1)
            -- small line under
            draw.RoundedBox(0, points_x, points_y + points_height * 0.8, math.max(0, points_width_2 - 1), points_height * 0.2, FROZE_GL.tbl_hud_elements.hpbar_color_gradient_2)
            surface.SetDrawColor(FROZE_GL.tbl_hud_elements.hpbar_color_2:Unpack())
            surface.SetMaterial(FROZE_GL.mat_gradient_r) 
            surface.DrawTexturedRectUV(points_x + points_width_2 * 0.2, points_y + points_height * 0.8, points_width_2 * 0.8 - 1, points_height * 0.2, 0, 0, 1, 1)
        end

        -- local points_text = cur_points  
        surface.SetFont(gl .. "font_subtitle_2") 
        local points_t_w, points_t_h = surface.GetTextSize(points_text)

        draw.DrawText(points_text, gl .. "font_subtitle_2", points_x + bar_w * 0.97, points_y - H * 0.007, color_white, TEXT_ALIGN_RIGHT)
    end
end

if IsValid(LocalPlayer()) then 
    local ply = LocalPlayer() 
    ply:GLLoadObtainedWeapons()
end

garlic_like_init() 
garlic_like_animated_xp_fonts_create()
garlic_like_create_wep_power_tbl() 