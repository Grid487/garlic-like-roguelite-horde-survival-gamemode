if SERVER then return end 

timer.Simple(1, function()
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
    --
    local W = ScrW()
    local H = ScrH()
    local H_half_screen = H * 0.5
    --
    local color_black = Color(0, 0, 0, 255)
    local color_white = Color(255, 255, 255)
    local color_white_100 = Color(255, 255, 255, 100)
    local color_white_40 = Color(255, 255, 255, 40)
    local color_yellow = Color(255, 238, 0)
    local color_blue = Color(0, 200, 255)
    local color_red = Color(255, 0, 0)
    local color_black_alpha_50 = Color(0, 0, 0, 50)
    local color_black_alpha_100 = Color(0, 0, 0, 100)
    local color_black_alpha_150 = Color(0, 0, 0, 150)
    local color_black_alpha_200 = Color(0, 0, 0, 200)
    local color_black_alpha_225 = Color(0, 0, 0, 225)
    --
    local start, oldxp, newxp = 0, -1, -1
    local barW = W * 0.5
    local animationTime = 0.1
    local minutes = 0
    local seconds = 0
    local addedzero = 0
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
        
        FROZE_GL.rarities = {"poor", "common", "uncommon", "rare", "epic", "legendary", "god"} 

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
                ["god"] = Color(255, 0, 0),
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
                ["god"] = {
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
                name = "God Crystal",
                rarity = "god",
                material = Material("garlic_like/icon_materials/icon_god_crystal.png"),
                held_num = 0
            },
        } 

        --* INVENTORY MENU
        FROZE_GL.tbl_menu_inventory = {
            consumables = {},
            materials = {},
        }
 
        FROZE_GL.tbl_anim_frame_id = {}

        -- fill in the materials table above A
        for k, v in pairs(FROZE_GL.tbl_menu_inventory_items_data) do 
            if v.material then   
                FROZE_GL.tbl_menu_inventory.materials[#FROZE_GL.tbl_menu_inventory.materials + 1] = {
                    id = k, 
                    name = v.name, 
                    icon_mat = v.icon_mat, 
                    is_ore = v.is_ore,
                    is_currency = v.is_currency,
                    is_material = v.is_material,
                    rarity = v.rarity,
                    amount = 0,
                }
            end
        end

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
                rank_xp_current = 0,
                rank_xp_to_rank_up = 100,
                time_elapsed = 0,
                time_elapsed_hold_rmb = 0,
            }

            FROZE_GL.tbl_inventory_menu = {
                color_inventory_box = Color(128, 128, 128),
            }

            FROZE_GL.tbl_invalid_tfa_upgrades = {"bash_speed", "bash_damage"}

            FROZE_GL.scaledfonts = {}
        end
        
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

    local function outline_box(wide, height) 
        surface.SetDrawColor(255, 0, 0)
        surface.DrawOutlinedRect(0, 0, wide, height, 1)
    end 

    --* global clientside functions
    do 
        function SafeRemovePanel(panel) 
            if not IsValid(panel) then 
                -- print("Panel doesn't exist.") 
                return 
            end

            panel:Remove()
        end

        function SafeRemovePanelDelayed(panel, time) 
            timer.Simple(time, function() 
                SafeRemovePanel(panel)
            end) 
        end
        
        function SafeRemovePanels( ... ) 
            local panels = { ... } 
            
            for k, panel in pairs(panels) do 
                SafeRemovePanel(panel)
            end 
        end

        function SafeRemovePanelsDelayed(panels, time) 
            timer.Simple(time, function() 
                for k, panel in pairs(panels) do 
                    SafeRemovePanel(panel)
                end
            end)
        end

        function garlic_like_update_tbl_valid_weapons()
            FROZE_GL.weapons_table = weapons.GetList()
            
            for k, wep in SortedPairs(weapons.GetList()) do
                str_1, str_2 = string.find(wep.ClassName, "base") 
                if wep.Base == "tfa_nade_base" then continue end
                if table.HasValue(FROZE_GL.tbl_wep_blacklist, wep.ClassName) then continue end

                --* power limits
                if (garlic_like_is_arccw_wep(wep) or garlic_like_is_tfa_wep(wep)) and not string.find(wep.ClassName, "FROZE_GL.default_gun") and FROZE_GL.tbl_wep_power[wep.ClassName] <= GetGlobalInt(gl .. "wep_power_limit", 10000) then 
                --* does not use limits
                -- if (garlic_like_is_arccw_wep(wep) or garlic_like_is_tfa_wep(wep)) and not string.find(wep.ClassName, "arccw_g18_garlic_like") then 
                    table.insert(FROZE_GL.tbl_valid_weapons, wep)
                end

                if wep.ClassName == "weapon_fists" then
                    tbl_fallback_weapon = wep
                end
            end 
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
                    unlock_condition = "Obtain a god rarity relic."
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
            end

            --* CREATE UNLOCKABLES FOR ITEM DROPS 

            --* CREATE UNLOCKABLES FOR RELIC DROPS 
        end

        function garlic_like_init() 
            timer.Simple(1, function() 
                garlic_like_init_unlockables() 
            end)

            garlic_like_update_tbl_valid_weapons()
        end

        function garlic_like_create_fonts()
            surface.CreateFont(gl .. "xp_notification", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.095 - 30 * (H * 0.0023),
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
                outline = false,
            })

            surface.CreateFont(gl .. "xp_notification_extra", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.095 - 30 * (H * 0.0023),
                weight = 300,
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
                outline = false,
            })

            surface.CreateFont(gl .. "xp_notification_settled", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.095 - 30 * (H * 0.0023),
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

            surface.CreateFont(gl .. "xp_notification_extra_settled", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.095 - 30 * (H * 0.0023),
                weight = 300,
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
                outline = false,
            })

            surface.CreateFont(gl .. "gold_popup", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = ScreenScale(12),
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

            surface.CreateFont(gl .. "item_pickup_name", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.03,
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

            surface.CreateFont(gl .. "item_pickup_held_num", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.02,
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
                outline = false,
            })

            surface.CreateFont(gl .. "mana", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.03,
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
                outline = true,
            })

            surface.CreateFont(gl .. "mana_numbers", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.025,
                weight = 55,
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
                outline = true,
            })

            surface.CreateFont(gl .. "reroll_button_text", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.025,
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
                outline = true,
            })

            surface.CreateFont(gl .. "xp_level", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.04,
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

            surface.CreateFont(gl .. "xp_numbers", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.02,
                weight = 55,
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

            for i = 1, 60 do 
                surface.CreateFont(gl .. "font_title_result_screen_" .. i, {
                    font = GetConVar(gl .. "hud_font"):GetString(),
                    extended = false,
                    size = H * (0.1 + i / 100),
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

            surface.CreateFont(gl .. "font_title_big", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.125,
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

            surface.CreateFont(gl .. "font_title_big_smaller", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.1,
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

            surface.CreateFont(gl .. "font_title", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.05,
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

            surface.CreateFont(gl .. "font_title_2", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.04,
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

            surface.CreateFont(gl .. "font_title_3", {
                font = GetConVar(gl .. "hud_font_2"):GetString(),
                extended = false,
                size = H * 0.03,
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

            surface.CreateFont(gl .. "font_title_3_alt", {
                font = "DIN Black",
                extended = false,
                size = H * 0.04,
                weight = 200,
                blursize = 0,
                scanlines = 0,
                antialias = false,
                underline = false,
                italic = false,
                strikeout = false,
                symbol = false,
                rotary = false,
                shadow = true,
                additive = false,
                outline = false,
            })

            for i = 1, 10 do 
                surface.CreateFont(gl .. "font_title_3_alt_" .. i, {
                    font = "DIN Black",
                    extended = false,
                    size = H * (0.04 + i / 1000),
                    weight = 200,
                    blursize = 0,
                    scanlines = 0,
                    antialias = false,
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

            for i = 1, 30 do 
                surface.CreateFont(gl .. "font_damage_number_" .. i, {
                    font = GetConVar(gl .. "hud_font_2"):GetString(),
                    extended = false,
                    size = H * 0.03 - H * i * 0.001,
                    weight = 300,
                    blursize = 0.05,
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
 
            for tier = 1, 10 do 
                local initial_size = (H * 0.04 + H * 0.002 * tier)
                -- print("tier: " .. tier) 
                -- print("initial size: " .. initial_size)

                for i = 1, 30 do 
                    surface.CreateFont(gl .. "font_damage_number_crit_tier_" .. tier .. "_" .. i, {
                        font = GetConVar(gl .. "hud_font_2"):GetString(),
                        extended = false,
                        size = initial_size - (i * initial_size / 30), 
                        weight = 600,
                        blursize = 0.05,
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

            surface.CreateFont(gl .. "font_money", {
                font = GetConVar(gl .. "hud_font_2"):GetString(),
                extended = false,
                size = H * 0.028,
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

            surface.CreateFont(gl .. "font_subtitle_small", {
                font = GetConVar(gl .. "hud_font_2"):GetString(),
                extended = false,
                size = H * 0.015,
                weight = 300,
                blursize = 0.05,
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

            surface.CreateFont(gl .. "font_subtitle", {
                font = GetConVar(gl .. "hud_font_2"):GetString(),
                extended = false,
                size = H * 0.0185,
                weight = 300,
                blursize = 0.05,
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

            surface.CreateFont(gl .. "font_subtitle_2", {
                font = GetConVar(gl .. "hud_font_2"):GetString(),
                extended = false,
                size = H * 0.025,
                weight = 300,
                blursize = 0.05,
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

            surface.CreateFont(gl .. "font_subtitle_3", {
                font = GetConVar(gl .. "hud_font_2"):GetString(),
                extended = false,
                size = H * 0.03,
                weight = 300,
                blursize = 0.05,
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

            surface.CreateFont(gl .. "font_small_level", {
                font = GetConVar(gl .. "hud_font_2"):GetString(),
                extended = false,
                size = H * 0.025,
                weight = 500,
                blursize = 0.05,
                scanlines = 0,
                antialias = true,
                underline = false,
                italic = false,
                strikeout = false,
                symbol = false,
                rotary = false,
                shadow = false,
                additive = false,
                outline = false,
            })

            surface.CreateFont(gl .. "font_stat_entry", {
                font = "Bio Sans SemiBold",
                extended = false,
                size = H * 0.02,
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

            surface.CreateFont(gl .. "empowered_text", {
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.05,
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
                font = GetConVar(gl .. "hud_font"):GetString(),
                extended = false,
                size = H * 0.04,
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

            surface.CreateFont(gl .. "font_empowered_numbers", {
                font = GetConVar(gl .. "hud_font_2"):GetString(),
                extended = false,
                size = H * 0.028,
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

            FROZE_GL.xp_notification_font = gl .. "xp_notification"
            xp_notification_font_extra = gl .. "xp_notification_extra"
            gold_notification_font = gl .. "font_money"
        end

        function gl_cse(ply, pos_x, pos_y, front_operator, numbers, short_desc, align_center_y, additional_front_text, front_text, rainbow, font, color, align_center_x)
            surface.SetFont(gl .. "font_subtitle")
            -- print(pos_x)

            if align_center_x == nil then
                align_center_x = true
            end

            if font ~= nil then
                surface.SetFont(font)
            end

            text_full = front_operator .. numbers .. short_desc

            if additional_front_text then
                text_full = front_text .. front_operator .. numbers .. short_desc
            end

            txt_width, txt_height = surface.GetTextSize(text_full)

            if not align_center_y and align_center_x then
                surface.SetTextPos(pos_x - txt_width * 0.5, pos_y)
            elseif align_center_y and align_center_x then
                surface.SetTextPos(pos_x - txt_width * 0.5, pos_y - txt_height * 0.5)
            elseif not align_center_x and not align_center_y then
                surface.SetTextPos(pos_x, pos_y)
            elseif not align_center_x and align_center_y then
                surface.SetTextPos(pos_x, pos_y - txt_height * 0.5)
            end

            if additional_front_text then
                surface.SetTextColor(255, 255, 255)
                surface.DrawText(front_text)
            end

            if not rainbow then
                if color == nil then
                    surface.SetTextColor(21, 255, 0)
                else
                    surface.SetTextColor(color.r, color.g, color.b)
                end
            elseif rainbow then
                col = HSVToColor((RealTime() * 100) % 360, 1, 1)
                surface.SetTextColor(col.r, col.g, col.b)
            end

            surface.DrawText(front_operator .. numbers)
            surface.SetTextColor(color_white.r, color_white.g, color_white.b)
            surface.DrawText(short_desc)
        end

        function garlic_like_draw_animated_border_2dhook(w, h, mod_w, mod_h, mod_x, mod_y, id, folder_name, frame_amount, type_init)   
            if not FROZE_GL.tbl_anim_frame_id[id] then 
                FROZE_GL.tbl_anim_frame_id[id] = {
                    tbl_frames = {},
                    cur_frame = 0,
                }

                for i = 1, frame_amount do 
                    local frame = i

                    if frame < 10 then 
                        frame = "00" .. i
                    elseif frame < 100 then 
                        frame = "0" .. i
                    end

                    FROZE_GL.tbl_anim_frame_id[id].tbl_frames[i] = Material("garlic_like/borders/" .. folder_name .. "/frame_apngframe" .. frame .. ".png") 
                end

                PrintTable(FROZE_GL.tbl_anim_frame_id)
            end

            if not type_init then 
                FROZE_GL.tbl_anim_frame_id[id].cur_frame = FROZE_GL.tbl_anim_frame_id[id].cur_frame + RealFrameTime() * 30

                local final_cur_frame = math.Round(math.Clamp(FROZE_GL.tbl_anim_frame_id[id].cur_frame, 1, frame_amount))

                if final_cur_frame == frame_amount then 
                    FROZE_GL.tbl_anim_frame_id[id].cur_frame = 1
                end

                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(FROZE_GL.tbl_anim_frame_id[id].tbl_frames[final_cur_frame])
                surface.DrawTexturedRect(mod_x, mod_y, w * mod_w, h * mod_h)
            end
        end

        garlic_like_draw_animated_border_2dhook(w, h, mod_w, mod_h, mod_x, mod_y, "id_dota2_default", "dota2_default", 150, true) 
        garlic_like_draw_animated_border_2dhook(w, h, mod_w, mod_h, mod_x, mod_y, "id_dota2_god_rarity", "dota2_god_rarity", 150, true) 

        function garlic_like_draw_scaled(text, x, y, width, font, font_name, color, alignment, alignment_y, lines_order)
            -- Split the text by new lines
            local lines 
            local lines_enabled

            if lines_order == "LINES_ENABLED" then 
                lines_enabled = true 
                lines = string.Split(text, "\n") 
            else 
                lines = text
            end
            
            -- Set the font and color
            surface.SetFont(font)
            surface.SetTextColor(color.r, color.g, color.b, color.a)
            
            -- Calculate the maximum text width and scale factor for each line
            local scale = 1
            local tw
            local th

            if lines_enabled then 
                for i, line in ipairs(lines) do
                    tw, th = surface.GetTextSize(line)
                    if tw > width then
                        local lineScale = width / tw
                        if lineScale < scale then
                            scale = lineScale
                        end
                    end
                end
            else 
                tw, th = surface.GetTextSize(text)
                if tw > width then
                    local lineScale = width / tw
                    if lineScale < scale then
                        scale = lineScale
                    end
                end
            end
        
            -- Create a scaled font if it doesn't already exist
            local scaledFontName = font .. "_scaled_" .. tostring(math.floor(scale * 100))
            if not FROZE_GL.scaledfonts[scaledFontName] then
                surface.CreateFont(scaledFontName, {
                    font = font_name,
                    size = math.floor(select(2, surface.GetTextSize("Hg")) * scale),
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
                FROZE_GL.scaledfonts[scaledFontName] = true
            end
            
            -- Set the scaled font
            surface.SetFont(scaledFontName)
            
            -- Draw each line of text with the correct alignment and position
            if lines_enabled then 
                for i, line in ipairs(lines) do
                    local tw, th = surface.GetTextSize(line)
                    local offsetX = 0
                    local offsetY = 0
                    if alignment == TEXT_ALIGN_CENTER then
                        offsetX = (width - tw) / 2
                    elseif alignment == TEXT_ALIGN_RIGHT then
                        offsetX = width - tw
                    end

                    if alignment_y == TEXT_ALIGN_CENTER then 
                        offsetY = th / 2
                    end
            
                    surface.SetTextPos(x + offsetX, (y + (i - 1) * th) - offsetY)
                    surface.DrawText(line)
                end
            else 
                local tw, th = surface.GetTextSize(text)
                local offsetX = 0
                local offsetY = 0
                if alignment == TEXT_ALIGN_CENTER then
                    offsetX = tw / 2
                elseif alignment == TEXT_ALIGN_RIGHT then
                    offsetX = width - tw
                end

                if alignment_y == TEXT_ALIGN_CENTER then 
                    offsetY = th / 2
                end
        
                surface.SetTextPos(x - offsetX, (y + (1 - 1) * th) - offsetY)
                surface.DrawText(text)
            end
        end

        function garlic_like_start_cl() 
            local ply = LocalPlayer()                        
        end

        function garlic_like_give_item(id, amount)   
            if id == "gold" then 
                garlic_like_update_money(amount, "GAIN_MONEY") 
            end

            print("TRYING TO GIVE: " .. id .. " AMOUNT: " .. amount)
            net.Start(gl .. "send_give_item_cl_to_sv") 
            net.WriteString(id)
            net.WriteInt(amount, 32)
            net.SendToServer()
        end

        function garlic_like_get_weapon(wep_choice, tbl_valid_weapons, get_type, rarity)
            wep_choice.wep_rarity = rarity
            wep_choice.wep_rarity_color = FROZE_GL.tbl_rarity_colors[wep_choice.wep_rarity]
            wep_choice.wep_element = FROZE_GL.tbl_elements[math.random(1, #FROZE_GL.tbl_elements)]
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

                for k, bonus in pairs(wep_choice.wep_bonuses) do
                    bonus.modifier = math.Truncate(bonus.modifier * wep_choice.wep_bonuses_modifier * math.Rand(0.25 * rarity_rand_modifier, 0.5 * rarity_rand_modifier), 3)
                end
            end
            
            if get_type == "ROLL" then
                -- print("ROLL CHOICE WEP")
                wep_choice.wep = FROZE_GL.tbl_valid_weapons[math.random(1, #FROZE_GL.tbl_valid_weapons)]
            elseif get_type == "FALLBACK" or wep_choice.wep == nil then
                wep_choice.wep = tbl_fallback_weapon
            else 

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
            local picker = math.random(1, FROZE_GL.rarity_weights_sum)
            local rarity = "poor"

            for name, rarity_entry in SortedPairs(FROZE_GL.rarity_wep) do
                if IsNumBetween(picker, rarity_entry.min, rarity_entry.max) then
                    -- print("RARITY GET:" .. name)
                    rarity = name
                end
            end

            return rarity
        end

        function garlic_like_determine_stats(tbl_upgrade, upgrade_type)
            local rarity
            local statboost_num
            local chance = math.random()

            -- 10%
            if chance <= 0.1 then
                rarity = "poor"
                num_modifier = 0.5
            elseif chance <= 0.25 then
                -- 40% 
                rarity = "common"
                num_modifier = 1
            elseif chance <= 0.7 then
                -- 20% 
                rarity = "uncommon"
                num_modifier = 1.25
            elseif chance <= 0.82 then
                -- 12%
                rarity = "rare"
                num_modifier = 1.75
            elseif chance <= 0.91 then
                -- 9%
                rarity = "epic"
                num_modifier = 2.5
            elseif chance <= 0.97 then
                -- 6%
                rarity = "legendary"
                num_modifier = 3.5
            elseif chance <= 1 then
                -- 3% 
                rarity = "god"
                num_modifier = 5
            end                        

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

                print("tbl_upgrade.name : " .. tbl_upgrade.name)
                print("tbl_upgrade.number_addition : " .. tbl_upgrade.number_addition) 

                for k, v in pairs(FROZE_GL.items_held) do 
                    -- print("KEY IS: " .. k)
                    PrintTable(v)
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

        function garlic_like_open_char_upgrades_menu(shop_base_panel) 
            local tbl_upgrade_panels = {}
            --
            local bf = vgui.Create("DPanel") 
            bf:SetSize(W * 0.4, H * 0.5)
            bf:Center()
            bf:CenterVertical(0.55)

            local bf_w, bf_h = bf:GetWide(), bf:GetTall()
            bf.panel_color = Color(61, 61, 61)

            bf.Paint = function(self, w, h) 
                draw.RoundedBox(6, 0, 0, w, h, self.panel_color)
            end

            local bt_exit = vgui.Create("DButton") 
            bt_exit:SetY(bf:GetY())
            bt_exit:MoveRightOf(bf, W * 0.01)
            bt_exit:SetText("") 
            bt_exit:SetSize(W * 0.03, W * 0.03)
            --
            bt_exit:MakePopup()
            bf:MakePopup()

            bt_exit.DoClick = function(self) 
                SafeRemovePanel(bf)
                SafeRemovePanel(self)
                surface.PlaySound("garlic_like/disgaea5_item_clicked.wav") 
                shop_base_panel:Show()
            end

            bt_exit.Paint = function(self, w, h) 
                draw.RoundedBox(6, 0, 0, w, h, color_black_alpha_150) 
                draw.DrawText("X", gl .. "font_title", w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)

                garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
            end

            local money_bar = vgui.Create("DPanel", bf) 
            money_bar:SetTall(bf:GetTall() * 0.1)
            money_bar:Dock(TOP)
            money_bar:DockMargin(ScreenScale(4), ScreenScale(4), ScreenScale(4), ScreenScale(2))

            money_bar.Paint = function(self, w, h) 
                local money = ply:GetNWInt(gl .. "money", 0) 
                surface.SetFont(gl .. "font_title_2")
                local money_w, money_h = surface.GetTextSize(tostring(money))
                draw.RoundedBox(6, w * 0.91 - money_w - w * 0.02, h * 0.05, money_w + w * 0.1 / 2 + w * 0.02, money_h, color_black_alpha_200)
                surface.SetDrawColor(255, 255, 255) 
                surface.SetMaterial(FROZE_GL.mat_hl) 
                surface.DrawTexturedRect(w * 0.93, h * 0.45 - w * 0.07 / 2, w * 0.07, w * 0.07)
                draw.DrawText(tostring(money), gl .. "font_title_2", w * 0.91, h * 0.45 - money_h / 2, color_white, TEXT_ALIGN_RIGHT)        
            end

            local dsp = vgui.Create( "DScrollPanel", bf )
            dsp:Dock( FILL )

            for k, entry in SortedPairs(FROZE_GL.tbl_character_stats) do                         
                local uframe = dsp:Add("DPanel") 
                uframe.panel_color = Color(161, 161, 161)
                uframe:SetTall(bf_h * 0.4)
                uframe:Dock(TOP)
                uframe:DockMargin(bf_w * 0.05, bf_h * 0.025, bf_w * 0.05, bf_h * 0.005)
                uframe.upgrade_level = 0
                uframe.color_yellow = Color(255, 208, 0)

                local pdata_name = entry.name .. "_base_level"

                if ply:GetPData(pdata_name, nil) then 
                    uframe.upgrade_level = tonumber(ply:GetPData(pdata_name))
                end 

                local bt_plus = vgui.Create("DButton", uframe) 
                btp = bt_plus
                btp:SetText("")
                btp:SetSize(bf_h * 0.1, bf_h * 0.1) 
                btp:SetX(bf_w * 0.7)
                btp:SetY(uframe:GetTall() * 0.45)
                btp.panel_color = Color(87, 87, 87)

                local function btp_click(uframe, operation) 
                    net.Start(gl .. "update_database_cl_to_sv")  
                    net.WriteString(entry.name) 

                    if entry.upgrade_type == "INT" then 
                        number = entry.shop_upgrade_amount * uframe.upgrade_level
                        number_float = 1
                    elseif entry.upgrade_type == "Float" then 
                        number = 1
                        number_float = entry.shop_upgrade_amount * uframe.upgrade_level
                    end

                    net.WriteInt(number, 32)
                    net.WriteString("UPGRADE_CHARACTER") 
                    net.WriteTable({}) 
                    net.WriteString(entry.upgrade_type) 
                    net.WriteFloat(number_float)
                    net.WriteInt(uframe.upgrade_level, 32)
                    net.WriteString(entry.id)
                    net.SendToServer()

                    if operation == "BUY" then 
                        -- print("BUY ITEM")
                        garlic_like_update_money(uframe.price, "BOUGHT_ITEM")
                    elseif operation == "SELL" then 
                        garlic_like_update_money(uframe.price - entry.shop_upgrade_price_increase, "GAIN_MONEY")         
                    end
                end 

                btp.DoClick = function(self)
                    if uframe.upgrade_level >= 10 then return end
                    if tonumber(ply:GetNWInt(gl .. "money", 0)) < tonumber(uframe.price) then return end
                    --
                    local number 
                    local number_float
                    ply:SetPData(pdata_name, ply:GetPData(pdata_name, 0) + 1)
                    uframe.upgrade_level = tonumber(ply:GetPData(pdata_name))
                    btp_click(uframe, "BUY")
                    surface.PlaySound("garlic_like/disgaea5_item_bought.wav")
                end
                
                btp.Paint = function(self, w, h) 
                    draw.RoundedBox(6, 0, 0, w, h, self.panel_color)
                    -- draw.DrawText("+", gl .. "font_title", w * 0.5, h * 0.0, color_white, TEXT_ALIGN_CENTER)
                    draw.SimpleText("+", gl .. "font_title", w * 0.5, h * 0.45, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    if self:IsHovered() then 
                        draw.RoundedBox(6, 0, 0, w, h, color_black_alpha_50)
                    end

                    if self:IsDown() then 
                        draw.RoundedBox(6, 0, 0, w, h, color_black_alpha_100)
                    end

                    garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
                end

                local bt_minus = vgui.Create("DButton", uframe) 
                btm = bt_minus
                btm:SetText("")
                btm:SetSize(bf_h * 0.1, bf_h * 0.1) 
                btm:SetX(bf_w * 0.7 + bf_h * 0.11)
                btm:SetY(uframe:GetTall() * 0.45)
                btm.panel_color = Color(211, 211, 211)

                local frame_locked = vgui.Create("DPanel", uframe) 
                frame_locked:SetSize(bf_w * 0.875, uframe:GetTall() * 1)
                frame_locked:Hide() 
                -- frame_locked:Center()
                    
                if entry.unlock_condition and not tobool(ply:GetPData(entry.id .. "_unlocked")) then 
                    frame_locked:Show()
                end

                btm.DoClick = function(self) 
                    if not ply:GetPData(pdata_name, nil) or tonumber(ply:GetPData(pdata_name)) < 1 then return end 
                    --
                    local number 
                    local number_float
                    ply:SetPData(pdata_name, ply:GetPData(pdata_name, 0) - 1)
                    uframe.upgrade_level = tonumber(ply:GetPData(pdata_name))
                    btp_click(uframe, "SELL")
                    surface.PlaySound("garlic_like/disgaea5_item_bought.wav")
                end

                btm.Paint = function(self, w, h) 
                    draw.RoundedBox(6, 0, 0, w, h, self.panel_color)
                    -- draw.DrawText("-", gl .. "font_title", w * 0.5, h * 0.0, color_white, TEXT_ALIGN_CENTER)
                    draw.SimpleText("-", gl .. "font_title", w * 0.5, h * 0.45, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    if self:IsHovered() then 
                        draw.RoundedBox(6, 0, 0, w, h, color_black_alpha_50)
                    end
                    
                    if self:IsDown() then 
                        draw.RoundedBox(6, 0, 0, w, h, color_black_alpha_100)
                    end

                    garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
                end
                
                uframe.Paint = function(self, w, h) 
                    surface.SetAlphaMultiplier(1)
                    local prefix = "" 

                    if entry.stat_type ~= "EXTRA" then 
                        prefix = "Base "
                    end

                    draw.RoundedBox(6, 0, 0, w, h, self.panel_color)
                    draw.DrawText(prefix .. entry.name, gl .. "font_title_2", w * 0.05, h * 0.07, color_white, TEXT_ALIGN_LEFT)    
                    
                    -- print("UPGRADE LEVEL IS: " .. self.upgrade_level)

                    for i = 1, 10 do 
                        if tonumber(self.upgrade_level) >= i then 
                            draw.RoundedBox(6, w * 0.05 + (i - 1) * w * 0.08, h * 0.3, w * 0.07, h * 0.04, uframe.color_yellow)
                        else
                            draw.RoundedBox(6, w * 0.05 + (i - 1) * w * 0.08, h * 0.3, w * 0.07, h * 0.04, color_black)
                        end                                
                    end

                    self.price = entry.shop_upgrade_base_price + entry.shop_upgrade_price_increase * self.upgrade_level
                    self.price_text = "Upgrade Price: " .. self.price

                    if self.upgrade_level >= 10 then 
                        self.price_text = "MAX LEVEL"
                    end

                    if entry.upgrade_type == "INT" then 
                        uframe.upgrade_value = entry.shop_upgrade_amount * uframe.upgrade_level
                    elseif entry.upgrade_type == "Float" then 
                        uframe.upgrade_value = entry.shop_upgrade_amount * uframe.upgrade_level * 100 .. "%"
                    end

                    draw.DrawText("+" .. self.upgrade_value, gl .. "font_title_2", w * 0.05, h * 0.35, uframe.color_yellow, TEXT_ALIGN_LEFT)   
                    draw.DrawText(self.price_text, gl .. "font_title_2", w * 0.89, h * 0.75, color_white, TEXT_ALIGN_RIGHT)                          
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(FROZE_GL.mat_hl) 
                    surface.DrawTexturedRect(w * 0.9, h * 0.74, bf_h * 0.1, bf_h * 0.1) 
                end
                
                frame_locked.Paint = function(self, w, h) 
                    draw.RoundedBox(0, 0, 0, w, h, color_black_alpha_200)  
                    draw.RoundedBox(0, 0, h * 0.4, w, h * 0.225, color_black_alpha_225)              
                    -- draw.DrawText("SAMPLE TEXT", gl .. "font_title", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER)
                    draw.SimpleText("LOCKED", gl .. "font_title", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                table.insert(tbl_upgrade_panels, uframe)
            end

            -- SafeRemovePanelDelayed(bf, 5)
            -- SafeRemovePanelDelayed(bt_exit, 5)
        end 

        function garlic_like_create_rewards_screen() 
            --* this is for debugging
            local ply = LocalPlayer()

            do
                -- ply.gl_temp_chest_rewards = {
                --     [1] = {
                --         name = "Gold",
                --         id = "gold",
                --         icon_mat = FROZE_GL.tbl_menu_inventory_items_data["gold"].icon_mat,
                --         rarity = FROZE_GL.tbl_menu_inventory_items_data["gold"].rarity,
                --         amount = 100000,
                --     },
                --     [2] = {
                --         name = "Stat Scroll",
                --         id = "stat_scroll",
                --         icon_mat = FROZE_GL.tbl_menu_inventory_items_data["stat_scroll"].icon_mat,
                --         rarity = FROZE_GL.tbl_menu_inventory_items_data["stat_scroll"].rarity,
                --         amount = 3,
                --     },
                --     [3] = {
                --         name = FROZE_GL.tbl_menu_inventory_items_data["ore_poor"].name,
                --         id = "ore_poor",
                --         icon_mat = FROZE_GL.tbl_menu_inventory_items_data["ore_poor"].icon_mat,
                --         rarity = FROZE_GL.tbl_menu_inventory_items_data["ore_poor"].rarity,
                --         amount = 100,
                --     }, 
                --     [4] = {
                --         name = FROZE_GL.tbl_menu_inventory_items_data["ore_common"].name,
                --         id = "ore_common",
                --         icon_mat = FROZE_GL.tbl_menu_inventory_items_data["ore_common"].icon_mat,
                --         rarity = FROZE_GL.tbl_menu_inventory_items_data["ore_common"].rarity,
                --         amount = 100,
                --     }, 
                --     [5] = {
                --         name = FROZE_GL.tbl_menu_inventory_items_data["ore_uncommon"].name,
                --         id = "ore_uncommon",
                --         icon_mat = FROZE_GL.tbl_menu_inventory_items_data["ore_uncommon"].icon_mat,
                --         rarity = FROZE_GL.tbl_menu_inventory_items_data["ore_uncommon"].rarity,
                --         amount = 100,
                --     }, 
                --     [6] = {
                --         name = FROZE_GL.tbl_menu_inventory_items_data["ore_rare"].name,
                --         id = "ore_rare",
                --         icon_mat = FROZE_GL.tbl_menu_inventory_items_data["ore_rare"].icon_mat,
                --         rarity = FROZE_GL.tbl_menu_inventory_items_data["ore_rare"].rarity,
                --         amount = 100,
                --     }, 
                --     [7] = {
                --         name = FROZE_GL.tbl_menu_inventory_items_data["ore_epic"].name,
                --         id = "ore_epic",
                --         icon_mat = FROZE_GL.tbl_menu_inventory_items_data["ore_epic"].icon_mat,
                --         rarity = FROZE_GL.tbl_menu_inventory_items_data["ore_epic"].rarity,
                --         amount = 100,
                --     }, 
                --     [8] = {
                --         name = FROZE_GL.tbl_menu_inventory_items_data["ore_legendary"].name,
                --         id = "ore_legendary",
                --         icon_mat = FROZE_GL.tbl_menu_inventory_items_data["ore_legendary"].icon_mat,
                --         rarity = FROZE_GL.tbl_menu_inventory_items_data["ore_legendary"].rarity,
                --         amount = 100,
                --     }, 
                --     [9] = {
                --         name = FROZE_GL.tbl_menu_inventory_items_data["ore_god"].name,
                --         id = "ore_god",
                --         icon_mat = FROZE_GL.tbl_menu_inventory_items_data["ore_god"].icon_mat,
                --         rarity = FROZE_GL.tbl_menu_inventory_items_data["ore_god"].rarity,
                --         amount = 100,
                --     }, 
                -- }
            end

            local frame_background = vgui.Create("DFrame", nil, "rewards_base_frame") -- frame that covers the whole screen, acts as a base frame and background 
            local fb = frame_background 
            fb:SetPos(0, 0)
            fb:SetSize(W, H)
            fb.color_bg = Color(0, 0, 0, 150)
            fb:MakePopup()
            fb.progress_exit = 0
            
            fb.Paint = function(self, w, h) 
                local RFT = RealFrameTime()

                draw.RoundedBox(0, 0, 0, w, h, self.color_bg)
                draw.RoundedBox(0, 0, H * 0.125, w, h * 0.125, self.color_bg)
                draw.DrawText("OBTAINED", gl .. "font_title_big", W * 0.5, H * 0.125, color_white, TEXT_ALIGN_CENTER)

                draw.RoundedBox(0, w * 0.025, h * 0.275, w - w * 0.05, h - (h * 0.275) - w * 0.025, self.color_bg)

                if fb.allow_exit then 
                    if not self.exit_now then 
                        if input.IsMouseDown(MOUSE_RIGHT) then 
                            self.progress_exit = math.min(1, self.progress_exit + RFT * 3)
                        else 
                            self.progress_exit = 0
                        end
                    end

                    if self.progress_exit >= 1 then 
                        self.exit_now = true
                        SafeRemovePanelDelayed(fb, 0.5)
                    end

                    draw.DrawText("HOLD RMB TO EXIT SCREEN " .. math.Round(math.Remap(self.progress_exit, 0, 1, 0, 100)) .. "%", gl .. "font_title_2", W * 0.5, H * 0.9, color_white, TEXT_ALIGN_CENTER)
                end
            end

            local grid = vgui.Create( "DGrid", fb )
            grid:SetPos( W * 0.0325, H * 0.29 )
            grid:SetCols( 10 )
            grid:SetColWide( W * 0.095 )
            grid:SetRowHeight(W * 0.095) 

            local stop_loop  

            repeat
                stop_loop = true 

                for k, v in ipairs(ply.gl_temp_chest_rewards) do 
                    if ply.gl_temp_chest_rewards[k + 1] and garlic_like_rarity_to_num(v.rarity) > garlic_like_rarity_to_num(ply.gl_temp_chest_rewards[k + 1].rarity) then 
                        local temp_tbl = ply.gl_temp_chest_rewards[k + 1]
                        ply.gl_temp_chest_rewards[k + 1] = ply.gl_temp_chest_rewards[k] 
                        ply.gl_temp_chest_rewards[k] = temp_tbl
                                
                        stop_loop = false   
                        break 
                    end 
                end
            until (stop_loop == true) 

            local stop_loop_2
            
            repeat
                stop_loop_2 = true 
                
                for k, v in ipairs(ply.gl_temp_chest_rewards) do 
                    if ply.gl_temp_chest_rewards[k + 1] and ply.gl_temp_chest_rewards[k + 1].id == "gold" then 
                        local temp_tbl = ply.gl_temp_chest_rewards[k + 1]
                        ply.gl_temp_chest_rewards[k + 1] = ply.gl_temp_chest_rewards[k] 
                        ply.gl_temp_chest_rewards[k] = temp_tbl
                                
                        stop_loop_2 = false   
                        break 
                    end  
                end
            until (stop_loop_2 == true)

            for k, v in ipairs(ply.gl_temp_chest_rewards) do 
                timer.Simple(k * 0.15, function() 
                    local but = vgui.Create( "DButton" )
                    but.color_box = Color(80, 80, 80, 255)
                    but.color_box_2 = Color(25, 25, 25, 255)
                    but.color_outline = Color(255, 255, 255, 255)
                    but.color_highlight = Color(255, 255, 255, 0)
                    but.color_amount_bg = Color(0, 0, 0, 100)
                    but.highlight_start = false
                    but.played_launch_sound = false
                    but:SetText( "" )
                    but:SetSize( W * 0.08, 0 )
                    but:SizeTo(W * 0.08, W * 0.08, 0.12, 0, 0.5, function(animData, pnl) 
                    
                    end)

                    but.phase = 1
                    but.lifetime = 0

                    but.Paint = function(self, w, h) 
                        local RFT = RealFrameTime() 

                        if not self.played_launch_sound then 
                            self.played_launch_sound = true 
                            surface.PlaySound("garlic_like/item_drop_sounds/item_launch.wav")
                        end

                        self.lifetime = self.lifetime + RFT 

                        if self.phase == 1 and self.lifetime >= 1 then 
                            self.phase = 2
                        end

                        if self.phase == 2 then 
                            self.color_outline = FROZE_GL.tbl_rarity_colors[v.rarity]

                            if not self.highlight_start then 
                                self.highlight_start = true
                                self.color_highlight = Color(FROZE_GL.tbl_rarity_colors[v.rarity]:Unpack())
                                self.color_box_2 = Color(FROZE_GL.tbl_rarity_colors[v.rarity]:Unpack())
                                self.color_box_2.a = 125
  
                                surface.PlaySound("garlic_like/item_drop_sounds/item_drop_" .. v.rarity .. ".wav")

                                garlic_like_give_item(v.id, v.amount)
                            end

                            self.color_highlight.a = Lerp(RFT * 7, self.color_highlight.a, 0)
                            -- self.color_highlight.a = math.max(0, self.color_highlight.a - RFT * 255)
                        end

                        draw.RoundedBox(0, 0, 0, w, h, self.color_box)
 
                        surface.SetDrawColor(self.color_box_2.r, self.color_box_2.g, self.color_box_2.b, 255)
                        surface.SetMaterial(FROZE_GL.mat_gradient_d)
                        surface.DrawTexturedRect(0, h * 0.35, w, h)

                        surface.SetDrawColor(self.color_outline.r, self.color_outline.g, self.color_outline.b, self.color_outline.a)
                        surface.DrawOutlinedRect(0, 0, w, h, 1)
                   
                        if self.phase == 1 then 
                            draw.SimpleText("?", gl .. "font_title_big", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
                        elseif self.phase == 2 then 
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.SetMaterial(v.icon_mat)
                            surface.DrawTexturedRect(w * 0.5 - w * 0.2, h * 0.5 - w * 0.2, w * 0.4, w * 0.4)

                            garlic_like_draw_scaled(v.name, w * 0.5, h * 0.15, w * 0.9, gl .. "font_title_3", GetConVar(gl .. "hud_font_2"):GetString(), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "LINES_DISABLED")

                            draw.RoundedBox(0, 0, h * 0.8, w, h * 0.15, self.color_amount_bg)
                            garlic_like_draw_scaled(v.amount, w * 0.5, h * 0.875, w * 0.9, gl .. "font_subtitle", GetConVar(gl .. "hud_font_2"):GetString(), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "LINES_DISABLED")

                            if v.rarity == "god" then 
                                garlic_like_draw_animated_border_2dhook(w, h, 1.18, 1.18, -w * 0.09, -h * 0.09, "id_dota2_god_rarity", "id_dota2_god_rarity", 150, false) 
                            end

                            if not fb.allow_exit and k == #ply.gl_temp_chest_rewards then 
                                fb.allow_exit = true 
                            end
                        end

                        -- the flashing effect which color is dependant on rarity
                        draw.RoundedBox(0, 0, 0, w, h, self.color_highlight)      
                    end

                    grid:AddItem( but )  
                end)
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

        -- garlic_like_create_rewards_screen() 

        function garlic_like_open_inventory_menu(shop_base_panel)
            local ply = LocalPlayer()

            local bf = vgui.Create("DPanel") 
            bf:SetSize(W * 0.55, H * 0.55) 
            bf:CenterHorizontal() 
            bf:CenterVertical(0.55) 
            local bf_w, bf_h = bf:GetWide(), bf:GetTall()
            bf.panel_color = Color(61, 61, 61)

            local but_cat_consumables = vgui.Create("DButton")
            local bcc = but_cat_consumables
            bcc:SetSize(W * 0.12, H * 0.04)
            bcc:MoveLeftOf(bf, W * 0.01)
            bcc:SetY(bf:GetY())
            bcc:SetText("")      

            local but_cat_materials = vgui.Create("DButton")
            local bcm = but_cat_materials
            bcm:SetSize(W * 0.12, H * 0.04)
            bcm:MoveLeftOf(bf, W * 0.01)
            bcm:MoveBelow(bcc, W * 0.005)
            bcm:SetText("")  
        
            local bt_exit = vgui.Create("DButton") 
            bt_exit:SetY(bf:GetY())
            bt_exit:MoveRightOf(bf, W * 0.01)
            bt_exit:SetText("") 
            bt_exit:SetSize(W * 0.03, W * 0.03)
            
            local title = vgui.Create("DLabel", bf)
            title:Dock(TOP)
            title:SetHeight(bf_h * 0.08)
            title:SetText("")

            title.Paint = function(self, w, h) 
                -- draw.RoundedBox(0, 0, 0, w, h, color_white)
                draw.DrawText("INVENTORY", gl .. "font_title", bf_w * 0.03, h * 0.1, color_white, TEXT_ALIGN_LEFT)
                -- if vgui.GetHoveredPanel() then 
                --     print("hovered panel: " .. tostring(vgui.GetHoveredPanel()))
                -- end
            end

            local DSP = vgui.Create( "DScrollPanel", bf )
            DSP:Dock( FILL )
            DSP:DockMargin(0, bf_h * 0.05, 0, 0)

            local tbl_panel_grid = {}
            local tbl_panel_items = {}

            local function create_inv_grid(reset_order, key_to_remove, category)  
                if reset_order then 
                    SafeRemovePanel(ply.gl_inventory_grid_panel)

                    if reset_order == "RESET_CAT_CONSUMABLES" then 
                        FROZE_GL.tbl_menu_inventory.consumables[key_to_remove] = nil  
                        FROZE_GL.tbl_menu_inventory.consumables = table.ClearKeys(FROZE_GL.tbl_menu_inventory.consumables) 
                        garlic_like_save_menu_inventory()
                        PrintTable(FROZE_GL.tbl_menu_inventory.consumables) 
                    end

                    ply.gl_inventory_grid_panel = nil
                end

                bf.item_cat = category
 
                local grid = DSP:Add("DGrid")
                grid:SetPos( bf_w * 0.03, bf_h * 0.00 )
                grid:SetCols( 8 )
                grid:SetColWide( bf_w * 0.12 )    
                grid:SetRowHeight( bf_w * 0.12)        

                local prompt = vgui.Create("DPanel", bf, "prompt_panel_xxddd")
                prompt:SetSize(W * 0.11, H * 0.035)
                prompt:SetPos(0, 0)
                prompt:Hide()

                function prompt:Reset() 
                    prompt:Hide() 
                    prompt.hoverable_panels = nil
                    prompt.hovered_panel = nil 
                    prompt.item_clicked = nil  

                    if prompt.button_open then 
                        prompt.button_open:Remove()   
                        prompt.button_open = nil
                    end

                    prompt:SetTall(H * 0.035)  
                end
                
                prompt.color = Color(0, 0, 0, 200)

                prompt.Paint = function(self, w, h) 
                    draw.RoundedBox(0, 0, 0, w, h, self.color)
    
                    if prompt.hoverable_panels then 
                        PrintTable(prompt.hoverable_panels)
                    end

                    if prompt.hovered_panel then 
                        if prompt.button_open and prompt.button_open:IsHovered() then 
                            print("OPEN BUTTON HOVERED!")
                        end

                        if (prompt.item_clicked and prompt.hoverable_panels and not table.HasValue(prompt.hoverable_panels, vgui.GetHoveredPanel())) then 
                            prompt:Reset()
                        elseif (not prompt.item_clicked and not prompt.hovered_panel:IsHovered()) then 
                            prompt:Reset()
                        end
                    end
                end 

                local prompt_name = vgui.Create("DLabel", prompt, "prompt_name_xxdd") 
                prompt_name:SetWide(prompt:GetWide())
                prompt_name:SetTall(H * 0.035)
                prompt_name:SetText("")
                prompt_name:Dock(TOP)

                prompt_name.color_text = color_white

                prompt.panel_name = prompt_name

                prompt_name.Paint = function(self, w, h) 
                    -- draw.DrawText("SAMPLE TEXT", gl .. "font_title_3", 0, 0, self.color_text, TEXT_ALIGN_LEFT)
                    if not prompt.hovered_panel then return end 

                    garlic_like_draw_scaled(prompt.hovered_panel.item_data.name, w * 0.05, 0, prompt:GetWide() * 0.9, gl .. "font_title_3", GetConVar(gl .. "hud_font_2"):GetString(), color_white, TEXT_ALIGN_LEFT, NO_ALIGNMENT, "LINES_DISABLED")

                    surface.SetDrawColor(255, 255, 255)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                end

                local tbl_menu_inv

                if category == "CONSUMABLES" then 
                    garlic_like_load_menu_inventory()
                    tbl_menu_inv = FROZE_GL.tbl_menu_inventory.consumables
                elseif category == "MATERIALS" then 
                    tbl_menu_inv = FROZE_GL.tbl_menu_inventory.materials
                end 
                
                for i = 1, math.max(32, #tbl_menu_inv) do      
                    local but = vgui.Create( "DButton" )
                    but:SetText( "" )
                    but:SetSize( bf_w * 0.11, bf_w * 0.11 )
                    but.color_highlight = Color(255, 255, 255, 0)
                    but.color_outline = Color(192, 192, 192)
                    but.color_item_amount_bg = Color(0, 0, 0, 100)

                    if tbl_menu_inv[i] then 
                        but.item_data = tbl_menu_inv[i]
                        but.color_outline = FROZE_GL.tbl_rarity_colors[but.item_data.rarity]
                        but.has_item = true
                    end 

                    but.Paint = function(self, w, h) 
                        local RFT = RealFrameTime() 
                        draw.RoundedBox(0, 0, 0, w, h, FROZE_GL.tbl_inventory_menu.color_inventory_box)
    
                        if self.item_data then  
                            surface.SetDrawColor(self.color_outline.r, self.color_outline.g, self.color_outline.b, 155)
                            surface.SetMaterial(FROZE_GL.mat_gradient_u)
                            surface.DrawTexturedRect(0, 0, w, h)

                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.SetMaterial(self.item_data.icon_mat)

                            if category == "CONSUMABLES" then 
                                surface.DrawTexturedRect(0, 0, w, h) 
                            elseif category == "MATERIALS" then 
                                surface.DrawTexturedRect(w * 0.5 - w * 0.25, h * 0.5 - h * 0.25, w * 0.5, h * 0.5)

                                draw.RoundedBox(0, 0, h * 0.8, w, h * 0.2, self.color_item_amount_bg)

                                if self.item_data.is_ore then 
                                    self.item_data.amount = ply:GetNWInt(gl .. "held_num_material_" .. self.item_data.rarity)
                                elseif self.item_data.is_currency then 
                                    self.item_data.amount = ply:GetNWInt(gl .. "money", 0)
                                elseif self.item_data.is_material then 
                                    self.item_data.amount = ply:GetNWInt(gl .. "held_num_material_" .. self.item_data.id)
                                end

                                draw.SimpleText(self.item_data.amount, gl .. "font_subtitle", w * 0.5, h * 0.9, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            end
    
                            if self:IsHovered() then 
                                prompt:Show()

                                if not prompt.item_clicked then 
                                    prompt:SetPos(input.GetCursorPos())
                                    prompt:SetX(prompt:GetX() + 10)
                                    prompt:SetY(prompt:GetY() + 15)
                                end

                                prompt:MakePopup()
                                prompt.hovered_panel = self
                            end
                        end

                        surface.SetDrawColor(self.color_outline.r, self.color_outline.g, self.color_outline.b, self.color_outline.a)
                        surface.DrawOutlinedRect(0, 0, w, h, 1)

                        if self:IsDown() and self:IsHovered() then  
                            self.color_highlight.a = 125      
                        elseif self:IsHovered() and not self:IsDown() then 
                            self.color_highlight.a = math.min(50, self.color_highlight.a + RFT * 455)
                        else
                            self.color_highlight.a = math.max(0, self.color_highlight.a - RFT * 455) 
                        end 

                        draw.RoundedBox(0, 0, 0, w, h, self.color_highlight)
                        surface.SetDrawColor(255, 255, 255, 255)
                    end

                    but.DoClick = function(self, w, h)
                        print("getting clicekd")   
                        if category == "MATERIALS" then return end 
                        
                        if not prompt.item_clicked then  
                            prompt.item_clicked = true 
                            prompt:SetTall(prompt:GetTall() + H * 0.025)

                            prompt.button_open = vgui.Create("DButton", prompt, "prompt_button_open") 
                            prompt.button_open:SetText("")
                            prompt.button_open:SetSize(prompt:GetWide(), H * 0.025)
                            prompt.button_open:Dock(TOP)                        
                            prompt.button_open.color_highlight = Color(255, 255, 255, 0)

                            prompt:SetPos(input.GetCursorPos())
                            prompt:SetX(prompt:GetX() - prompt:GetWide() * 0.5)
                            prompt:SetY(prompt:GetY() - 5)

                            prompt.button_open.Paint = function(self, w, h) 
                                local RFT = RealFrameTime()                            

                                if self:IsHovered() and not self:IsDown() then                                 
                                    self.color_highlight.a = math.min(50, self.color_highlight.a + RFT * 355)
                                elseif self:IsDown() then 
                                    self.color_highlight.a = math.min(100, self.color_highlight.a + RFT * 555)
                                else
                                    self.color_highlight.a = math.max(0, self.color_highlight.a - RFT * 355) 
                                end             

                                draw.SimpleText("OPEN", gl .. "font_subtitle", w * 0.05, 0, color_white, TEXT_ALIGN_LEFT)
                                
                                surface.SetDrawColor(255, 255, 255)
                                surface.DrawOutlinedRect(0, 0, w, h, 1)

                                draw.RoundedBox(0, 0, 0, w, h, self.color_highlight)
                            end

                            prompt.button_open.DoClick = function(self)  
                                local chest_drops = but.item_data.chest_drops
                                ply.gl_temp_chest_rewards = {}

                                PrintTable(but.item_data)
    
                                local obtained_gold = math.random(chest_drops.gold.min, chest_drops.gold.max)
                                local obtained_material_num = math.random(chest_drops.material_drop_amount.min, chest_drops.material_drop_amount.max)
                                local obtained_stat_scroll_num = math.random(chest_drops.stat_scroll.min, chest_drops.stat_scroll.max)   

                                ply.gl_temp_chest_rewards[#ply.gl_temp_chest_rewards + 1] = {
                                    name = "Gold", 
                                    id = "gold",
                                    rarity = FROZE_GL.tbl_menu_inventory_items_data["gold"].rarity,
                                    icon_mat = FROZE_GL.tbl_menu_inventory_items_data["gold"].icon_mat,
                                    amount = obtained_gold,
                                }

                                ply.gl_temp_chest_rewards[#ply.gl_temp_chest_rewards + 1] = {
                                    name = "Stat Scroll", 
                                    id = "stat_scroll",
                                    rarity = FROZE_GL.tbl_menu_inventory_items_data["stat_scroll"].rarity,
                                    icon_mat = FROZE_GL.tbl_menu_inventory_items_data["stat_scroll"].icon_mat,
                                    amount = obtained_stat_scroll_num,
                                }

                                ply:SetNWInt(gl .."obtained_mat_poor", 0)
                                ply:SetNWInt(gl .."obtained_mat_common", 0)
                                ply:SetNWInt(gl .."obtained_mat_uncommon", 0)
                                ply:SetNWInt(gl .."obtained_mat_rare", 0)
                                ply:SetNWInt(gl .."obtained_mat_epic", 0)
                                ply:SetNWInt(gl .."obtained_mat_legendary", 0)
                                ply:SetNWInt(gl .."obtained_mat_god", 0)
 
                                print("---")
                                PrintTable(FROZE_GL.rarity_weights)
                                print("FROZE_GL.rarity_weights_sum_gems " .. FROZE_GL.rarity_weights_sum_gems)

                                for i = 1, obtained_material_num do 
                                    local weight = math.random(1, FROZE_GL.rarity_weights_sum_gems)

                                    for k, v in pairs(FROZE_GL.rarity_weights) do 
                                        if IsNumBetween(weight, v.min, v.max) then 
                                            print("ore rarity: " .. k)
                                            ply:SetNWInt(gl .. "obtained_mat_" .. k, ply:GetNWInt(gl .. "obtained_mat_" .. k) + 1)
                                        end
                                    end
                                end

                                --* put the amount of mats gathered of each rarity into the table seperately
                                for k, v in pairs(FROZE_GL.tbl_menu_inventory_items_data) do 
                                    if string.find(k, "ore") and ply:GetNWInt(gl .. "obtained_mat_" .. string.sub(k, 5)) > 0 then 
                                        ply.gl_temp_chest_rewards[#ply.gl_temp_chest_rewards + 1] = {
                                            name = v.name, 
                                            id = k,
                                            rarity = v.rarity,
                                            icon_mat = v.icon_mat,
                                            amount = ply:GetNWInt(gl .. "obtained_mat_" .. string.sub(k, 5)),
                                        }
                                    end
                                end
                                
                                --

                                prompt:Reset()
                                garlic_like_create_rewards_screen()  

                                for k, v in ipairs(tbl_panel_items) do 
                                    SafeRemovePanel(v)                                
                                end

                                tbl_panel_items = {}
 
                                SafeRemovePanel(grid) 
                                create_inv_grid("RESET_CAT_CONSUMABLES", i, "CONSUMABLES")  
                            end
    
                            prompt.hoverable_panels = {
                                [1] = prompt,
                                [2] = prompt.hovered_panel,
                                [3] = prompt.panel_name,
                                [4] = prompt.button_open,
                            }
                        else 
                            prompt:Reset()
                        end
                    end

                    grid:AddItem( but )
                    table.insert(tbl_panel_items, but)
                end

                ply.gl_inventory_grid_panel = grid 
            end  

            create_inv_grid(reset_order, key_to_remove, "CONSUMABLES")  

            --

            bt_exit.DoClick = function(self) 
                SafeRemovePanel(bf)
                SafeRemovePanel(tooltip)
                SafeRemovePanel(self)
                SafeRemovePanel(bcc)
                SafeRemovePanel(bcm)
                surface.PlaySound("garlic_like/disgaea5_item_clicked.wav") 
                
                for k, panel in pairs(ply.gl_panels) do 
                    if panel:GetName() == gl .. "shop_base_dpanel" then 
                        panel:Show()
                    end
                end
            end 
        
            bt_exit:MakePopup()
            bf:MakePopup() 

            bf.Paint = function(self, w, h) 
                draw.RoundedBox(4, 0, 0, w, h, self.panel_color)
            end              

            local function draw_cat_but(name, w, h)
                draw.RoundedBox(4, 0, 0, w, h, bf.panel_color)                
                draw.SimpleText(name, gl .. "font_title_3", w * 0.05, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                if bf.item_cat == name then 
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                end
            end

            bcc.Paint = function(self, w, h)  
                draw_cat_but("CONSUMABLES", w, h)
            end          

            bcm.Paint = function(self, w, h) 
                draw_cat_but("MATERIALS", w, h)
            end

            bcc.DoClick = function(self) 
                create_inv_grid("RESET", nil, "CONSUMABLES")
                bf.item_cat = "CONSUMABLES"
            end

            bcm.DoClick = function(self) 
                create_inv_grid("RESET", nil, "MATERIALS")
                bf.item_cat = "MATERIALS"
            end

            bt_exit.Paint = function(self, w, h) 
                draw.RoundedBox(6, 0, 0, w, h, color_black_alpha_150) 
                draw.DrawText("X", gl .. "font_title", w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)

                garlic_like_save_menu_inventory() 
                garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
            end
        end

        function garlic_like_draw_multi_line(tbl_text, x, y, bg_color)  
            draw.RoundedBox(0, x - 5, y - 5, tbl_text.w + 10, tbl_text.h + 10, bg_color)

            for k, v in pairs(tbl_text) do
                if isnumber(k) then 
                    surface.SetFont(gl .. "font_subtitle_2") 
                    local t_w, t_h = surface.GetTextSize(v) 

                    if tbl_text.w < t_w then 
                        tbl_text.w = t_w 
                    end 

                    draw.SimpleText(v, gl .. "font_subtitle_2", x, y + t_h * (k - 1), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                    if k == #tbl_text then  
                        tbl_text.h = t_h * (k) 
                    end
                end
            end 
        end

        function garlic_like_open_unlockables_menu() 
            local bf = vgui.Create("DPanel") 
            bf:SetSize(W * 0.45, H * 0.5) 
            bf:CenterHorizontal() 
            bf:CenterVertical(0.55) 
            local bf_w, bf_h = bf:GetWide(), bf:GetTall()
            bf.panel_color = Color(61, 61, 61)
        
            local bt_exit = vgui.Create("DButton") 
            bt_exit:SetY(bf:GetY())
            bt_exit:MoveRightOf(bf, W * 0.01)
            bt_exit:SetText("") 
            bt_exit:SetSize(W * 0.03, W * 0.03)

            bt_exit.DoClick = function(self) 
                SafeRemovePanel(bf)
                SafeRemovePanel(self)
                surface.PlaySound("garlic_like/disgaea5_item_clicked.wav") 
                
                for k, panel in pairs(ply.gl_panels) do 
                    if panel:GetName() == gl .. "shop_base_dpanel" then 
                        panel:Show()
                    end
                end
            end
        
            bt_exit:MakePopup()
            bf:MakePopup()

            local money_bar = vgui.Create("DPanel", bf) 
            money_bar:SetTall(bf:GetTall() * 0.1)
            money_bar:Dock(TOP)
            money_bar:DockMargin(ScreenScale(4), ScreenScale(4), ScreenScale(4), ScreenScale(2))

            local dsp = vgui.Create( "DScrollPanel", bf )
            dsp:Dock( FILL )

            for id, data in SortedPairs(FROZE_GL.tbl_gl_unlockables) do 
                local card = dsp:Add("DPanel") 
                card.panel_color = Color(161, 161, 161)
                card.unlock_color = Color(32, 190, 0)
                card.panel_highlight_color = Color(92, 92, 92)
                card.mat_check = Material("garlic_like/icon_ui/check-mark.png")
                card:SetTall(bf_h * 0.25)
                card:Dock(TOP)
                card:DockMargin(bf_w * 0.05, bf_h * 0.025, bf_w * 0.05, bf_h * 0.005)

                card.Paint = function(self, w, h) 
                    draw.RoundedBox(4, 0, 0, w, h, self.panel_color)
                    draw.RoundedBox(4, h * 0.1, h * 0.5, w - h * 0.2, h * 0.4, color_black_alpha_200)
                    draw.DrawText(data.unlock_condition, gl .. "font_title_3", w * 0.01, h * 0.05, color_white, TEXT_ALIGN_LEFT)
                    draw.DrawText(data.unlock_text, gl .. "font_title_3", w * 0.5, h * 0.55, self.unlock_color, TEXT_ALIGN_CENTER)

                    -- print(id .. (ply:GetPData(gl .. id .. "_unlocked")))
                    -- print(id)

                    if tobool(ply:GetPData(id .. "_unlocked")) then 
                        draw.RoundedBox(4, 0, 0, w, h, color_black_alpha_200)                
                        surface.SetDrawColor(255, 255, 255) 
                        surface.DrawCircle(w * 0.5, h * 0.5, h * 0.4, 255, 255, 255, 255)
                        surface.SetMaterial(self.mat_check) 
                        surface.DrawTexturedRect(w * 0.5 - w * 0.1, h * 0.5 - h * 0.3, w * 0.2, h * 0.6)                
                    end
                end
            end

            bf.Paint = function(self, w, h) 
                draw.RoundedBox(4, 0, 0, w, h, self.panel_color)
            end

            bt_exit.Paint = function(self, w, h) 
                draw.RoundedBox(6, 0, 0, w, h, color_black_alpha_150) 
                draw.DrawText("X", gl .. "font_title", w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)

                garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
            end

            money_bar.Paint = function(self, w, h) 
                draw.DrawText("UNLOCKABLES & ACHIEVEMENTS", gl .. "font_title_2", w * 0.5, h * 0.1, color_white, TEXT_ALIGN_CENTER)
            end
            
            -- SafeRemovePanelDelayed(bf, 5)
            -- SafeRemovePanelDelayed(bt_exit, 5)
        end

        function garlic_like_open_glossary() 
            local bf = vgui.Create("DPanel") 
            bf:SetSize(W * 0.55, H * 0.55) 
            bf:CenterHorizontal() 
            bf:CenterVertical(0.55) 
            local bf_w, bf_h = bf:GetWide(), bf:GetTall()
            bf.panel_color = Color(61, 61, 61)
        
            local bt_exit = vgui.Create("DButton") 
            bt_exit:SetY(bf:GetY())
            bt_exit:MoveRightOf(bf, W * 0.01)
            bt_exit:SetText("") 
            bt_exit:SetSize(W * 0.03, W * 0.03)

            local DSP = vgui.Create( "DScrollPanel", bf )
            DSP:Dock( FILL )

            local title_1 = DSP:Add("DLabel")
            title_1:SetPos(10, bf:GetTall() * 0.05) 
            title_1:SetSize(W * 0.4, H * 0.05)
            title_1:SetText("") 
            title_1:Dock(TOP)
            title_1:DockMargin(W * 0.01, H * 0.01, W * 0.01, H * 0.01)   

            title_1.Paint = function(self, w, h) 
                draw.SimpleText("ENEMY MODIFIERS", gl .. "font_title", 0, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        
            local tooltip = vgui.Create("DPanel") 
            local hovered_panel = nil 

            local grid = DSP:Add("DGrid")
            grid:SetPos( 10, bf:GetTall() * 0.2 ) 
            grid:SetCols( 5 )
            grid:SetColWide( bf:GetWide() * 0.2 )
            grid:Dock(TOP)
            grid:DockMargin(W * 0.01, H * 0.01, W * 0.01, H * 0.01)   
            
            for modifier_name, v in pairs(FROZE_GL.tbl_enemy_modifiers) do
                surface.SetFont(gl .. "font_subtitle_2")
                local but = vgui.Create( "DButton" )
                but.name = modifier_name
                but.t_w, but.t_h = surface.GetTextSize(but.name) 
                but:SetText( "" )
                but:SetSize( but.t_w + bf:GetWide() * 0.05, but.t_h + bf:GetTall() * 0.02 )

                but.Paint = function(self, w, h) 
                    draw.RoundedBox(0, 0, 0, w, h, color_black_alpha_100)
                    draw.SimpleText(but.name, gl .. "font_subtitle_2", w * 0.5, h * 0.5, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
                    if self:IsHovered() or self:IsDown() then 
                        -- print("is hovering!")
                        tooltip:SetPos(gui.MouseX() + 5, gui.MouseY() + 5)
                        surface.SetFont(gl .. "font_subtitle")
                        tooltip.text = v.tbl_txt
                        tooltip.t_w = v.tbl_txt.w 
                        tooltip.t_h = v.tbl_txt.h 

                        if gui.MouseX() + tooltip.t_w > W then 
                            tooltip:SetPos(gui.MouseX() - 5 - tooltip.t_w, gui.MouseY() + 5)
                        end

                        if not tooltip:IsVisible() then 
                            tooltip:Show()
                            tooltip:MakePopup()             
                        end

                        hovered_panel = self 
                    end

                    if ispanel(hovered_panel) and not hovered_panel:IsHovered() and tooltip:IsVisible() then 
                        tooltip:Hide()                 
                        hovered_panel = nil
                    end
                end

                grid:AddItem( but )
            end

            --*
        
            local title_2 = DSP:Add("DLabel")
            title_2:SetPos(10, bf:GetTall() * 0.05) 
            title_2:SetSize(W * 0.4, H * 0.05)
            title_2:SetText("") 
            title_2:Dock(TOP)
            title_2:DockMargin(W * 0.01, H * 0.01, W * 0.01, H * 0.01)   

            title_2.Paint = function(self, w, h) 
                draw.SimpleText("ELEMENTS", gl .. "font_title", 0, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            local grid_e = DSP:Add("DGrid")
            grid_e:SetPos( 10, bf:GetTall() * 0.2 ) 
            grid_e:SetCols( 3 )
            grid_e:SetColWide( bf:GetWide() * 0.3 )
            grid_e:Dock(TOP)
            grid_e:DockMargin(W * 0.01, H * 0.01, W * 0.01, H * 0.01)   

            for k, v in pairs(FROZE_GL.tbl_elements) do
                surface.SetFont(gl .. "font_subtitle_2")
                local but = vgui.Create( "DButton" )
                but.name = string.upper(v.name)
                but.t_w, but.t_h = surface.GetTextSize(but.name) 
                but:SetText( "" )
                but:SetSize( but.t_w + bf:GetWide() * 0.05, but.t_h + bf:GetTall() * 0.02 )

                but.Paint = function(self, w, h) 
                    draw.RoundedBox(0, 0, 0, w, h, color_black_alpha_100)
                    draw.SimpleText(but.name, gl .. "font_subtitle_2", w * 0.5, h * 0.5, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
                    if self:IsHovered() or self:IsDown() then 
                        -- print("is hovering!")
                        tooltip:SetPos(gui.MouseX() + 5, gui.MouseY() + 5)
                        surface.SetFont(gl .. "font_subtitle")
                        tooltip.text = v.tbl_txt
                        tooltip.t_w = v.tbl_txt.w 
                        tooltip.t_h = v.tbl_txt.h 

                        if gui.MouseX() + tooltip.t_w > W then 
                            tooltip:SetPos(gui.MouseX() - 5 - tooltip.t_w, gui.MouseY() + 5)
                        end

                        if not tooltip:IsVisible() then 
                            tooltip:Show()
                            tooltip:MakePopup()             
                        end

                        hovered_panel = self 
                    end

                    if ispanel(hovered_panel) and not hovered_panel:IsHovered() and tooltip:IsVisible() then 
                        tooltip:Hide()                 
                        hovered_panel = nil
                    end
                end

                grid_e:AddItem( but )
            end

            --*

            local title_3 = DSP:Add("DLabel")
            title_3:SetPos(10, bf:GetTall() * 0.05) 
            title_3:SetSize(W * 0.4, H * 0.05)
            title_3:SetText("") 
            title_3:Dock(TOP)
            title_3:DockMargin(W * 0.01, H * 0.01, W * 0.01, H * 0.01)   

            title_3.Paint = function(self, w, h) 
                draw.SimpleText("CHARACTER STATS", gl .. "font_title", 0, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            local grid_cs = DSP:Add("DGrid")
            grid_cs:SetPos( 10, bf:GetTall() * 0.2 ) 
            grid_cs:SetCols( 3 )
            grid_cs:SetColWide( bf:GetWide() * 0.3 )
            grid_cs:Dock(TOP)
            grid_cs:DockMargin(W * 0.01, H * 0.01, W * 0.01, H * 0.01)    

            for k, v in pairs(FROZE_GL.tbl_character_stats) do  
                surface.SetFont(gl .. "font_subtitle_2")
 
                if not v.tbl_txt then continue end

                local but = vgui.Create( "DButton" )
                but.name = string.upper(v.name)
                but.t_w, but.t_h = surface.GetTextSize(but.name) 
                but:SetText( "" )
                but:SetSize( but.t_w + bf:GetWide() * 0.05, but.t_h + bf:GetTall() * 0.02 )

                but.Paint = function(self, w, h) 
                    draw.RoundedBox(0, 0, 0, w, h, color_black_alpha_100)
                    draw.SimpleText(but.name, gl .. "font_subtitle_2", w * 0.5, h * 0.5, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
                    if self:IsHovered() or self:IsDown() then 
                        -- print("is hovering!")
                        tooltip:SetPos(gui.MouseX() + 5, gui.MouseY() + 5)
                        surface.SetFont(gl .. "font_subtitle")
                        tooltip.text = v.tbl_txt
                        tooltip.t_w = v.tbl_txt.w 
                        tooltip.t_h = v.tbl_txt.h 

                        if gui.MouseX() + tooltip.t_w > W then 
                            tooltip:SetPos(gui.MouseX() - 5 - tooltip.t_w, gui.MouseY() + 5)
                        end

                        if not tooltip:IsVisible() then 
                            tooltip:Show()
                            tooltip:MakePopup()             
                        end

                        hovered_panel = self 
                    end

                    if ispanel(hovered_panel) and not hovered_panel:IsHovered() and tooltip:IsVisible() then 
                        tooltip:Hide()                 
                        hovered_panel = nil
                    end
                end

                grid_cs:AddItem( but )
            end

            --*

            bt_exit.DoClick = function(self) 
                SafeRemovePanel(bf)
                SafeRemovePanel(tooltip)
                SafeRemovePanel(self)
                surface.PlaySound("garlic_like/disgaea5_item_clicked.wav") 
                
                for k, panel in pairs(ply.gl_panels) do 
                    if panel:GetName() == gl .. "shop_base_dpanel" then 
                        panel:Show()
                    end
                end
            end

            tooltip:SetPos(bf:GetPos())
            tooltip:SetSize(W, H)
            tooltip:Hide()
            
            tooltip.Paint = function(self, w, h)  
                garlic_like_draw_multi_line(self.text, 10, 5, color_black_alpha_225)  
            end
        
            bt_exit:MakePopup()
            bf:MakePopup()
            tooltip:MakePopup()

            bf.Paint = function(self, w, h) 
                draw.RoundedBox(4, 0, 0, w, h, self.panel_color)
            end

            bt_exit.Paint = function(self, w, h) 
                draw.RoundedBox(6, 0, 0, w, h, color_black_alpha_150) 
                draw.DrawText("X", gl .. "font_title", w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)

                garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
            end
        end

        function garlic_like_open_main_menu(ply)  
            -- garlic_like_pause_game_toggle()
            
            local tbl_buttons = {}        
            surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
            ply = LocalPlayer()
            ply.gl_panels = {}
            ply.gl_has_menu_open = true

            local background = vgui.Create("DPanel") 
            background:SetSize(W, H)  
            background.paint_init = false

            background.Paint = function(self, w, h) 
                local RFT = RealFrameTime()

                if not self.paint_init then  
                    self.paint_init = true
                    self.highlight_width = 0
                    self.highlight_x = w * 0.5
                    self.change_speed = w * 2.5
                end

                if ply.gl_has_menu_open then 
                    self.highlight_width = math.Approach(self.highlight_width, w * 0.5, RFT * self.change_speed)
                    self.highlight_x = math.Approach(self.highlight_x, w * 0.25, RFT * self.change_speed / 2)
                else 
                    self.highlight_width = math.Approach(self.highlight_width, 0, RFT * self.change_speed)
                    self.highlight_x = math.Approach(self.highlight_x, w * 0.5, RFT * self.change_speed / 2)
                end

                draw.RoundedBox(0, 0, 0, w, h, color_black_alpha_200)
                draw.RoundedBox(0, self.highlight_x, 0, self.highlight_width, h, color_black_alpha_150)
            end

            local logo = vgui.Create("DPanel") 
            logo.size_w, logo.size_h = 0, 0
            logo.target_size_w, logo.target_size_h = W * 0.5, H * 0.35
            -- logo:SetSize(logo.size_w, logo.size_h) 
            logo:SetSize(W * 0.5, H * 0.35) 
            logo:Center() 
            logo:CenterVertical(0.2) 
            logo.logo = Material("garlic_like/icon_ui/LOGO_garlic_like_1.png")
            logo.color = Color(255, 255, 255, 0)

            logo.Paint = function(self, w, h) 
                local RFT = RealFrameTime() 
                --   
                if ply.gl_has_menu_open then 
                    self.color.a = math.Approach(self.color.a, 255, RFT * 555)
                    self.size_w = math.min(self.target_size_w, self.size_w + RFT * 12 * math.max(self.target_size_w / 5, (self.target_size_w - self.size_w)))
                    self.size_h = math.min(self.target_size_h, self.size_h + RFT * 12 * math.max(self.target_size_h / 5, (self.target_size_h - self.size_h)))
                    -- print(self:GetWide())
                else 
                    self.color.a = math.Approach(self.color.a, 0, RFT * 2500)
                    self.size_w = math.max(0, self.size_w - RFT * 12 * math.max(self.size_w / 5, math.abs(0 - self.size_w)))
                    self.size_h = math.max(0, self.size_h - RFT * 12 * math.max(self.size_h / 5, math.abs(0 - self.size_h)))            
                end
                
                self:SetSize(self.size_w, self.size_h) 
                -- self:Center()
                self:CenterHorizontal()
                self:CenterVertical(0.2)

                surface.SetDrawColor(self.color.r, self.color.g, self.color.b, self.color.a) 
                surface.SetMaterial(self.logo)
                surface.DrawTexturedRect(0, 0, w, h)
                --
                surface.SetDrawColor(255, 255, 255)
            end 

            local shop_base_panel = vgui.Create("DPanel", nil, gl .. "shop_base_dpanel")
            shop_base_panel:SetName(gl .. "shop_base_dpanel")
            shop_base_panel:MakePopup(true)
            shop_base_panel:SetSize(0, 0)
            shop_base_panel:CenterHorizontal() 
            shop_base_panel:CenterVertical(0.55)
            shop_base_panel.isAnimating = true

            shop_base_panel.Paint = function(self, w, h)
                -- draw.RoundedBox(0, 0, 0, w, h, color_black_alpha_200)
            end

            --* INSERT TABLE TO A PLAYER ATTRIBUTE SO THAT I CAN BE ACCESSED ANYWHERE
            table.insert(ply.gl_panels, shop_base_panel)

            local function exit() 
                ply.gl_has_menu_open = false
                surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                shop_base_panel:SetMouseInputEnabled(false)
                shop_base_panel.isAnimating = true
                -- garlic_like_pause_game_toggle()

                shop_base_panel:SizeTo(0, 0, 0.15, 0, 0.5, function()
                    shop_base_panel.isAnimating = false
                    SafeRemovePanels(shop_base_panel, background, logo)
                end)
            end

            local function create_button(name, text)  
                local button = shop_base_panel:Add("DButton")
                button:SetName(gl .. name)
                button:Dock(TOP) 
                button:SetText("")      
                button.panel_color = Color(200, 200, 200, 100)   
                button.font_num = 1
                button.font = gl .. "font_title_3_alt_" .. button.font_num      
                
                if GetGlobalBool(gl .. "match_running") and name == "button_start" then 
                    button:SetMouseInputEnabled(false)
                    button.panel_color = Color(98, 98, 98, 100)   
                end

                button.Paint = function(self, w, h) 
                    local RFT = RealFrameTime()  
                    self.font = gl .. "font_title_3_alt_" .. math.Round(self.font_num)
        
                    if self:IsHovered() then 
                        self.panel_color.a = math.Approach(self.panel_color.a, 255, RFT * 755)
                        self.font_num = math.Approach(self.font_num, 10, RFT * 100)                
                    elseif not self:IsHovered() and not self:IsDown() then  
                        self.panel_color.a = math.Approach(self.panel_color.a, 100, RFT * 755)
                        self.font_num = math.Approach(self.font_num, 1, RFT * 100)                 
                    end 

                    -- self:SetTall(self.h)
        
                    if self:IsDown() then 
                        self.panel_color.r = 75
                        self.panel_color.g = 75
                        self.panel_color.b = 75
                    else 
                        self.panel_color.r = 200 
                        self.panel_color.g = 200
                        self.panel_color.b = 200
                    end 

                    if GetGlobalBool(gl .. "match_running") and name == "button_start" then 
                        button:SetMouseInputEnabled(false)
                        button.panel_color.a = 50
                    end

                    draw.RoundedBox(4, 0, 0, w, h, self.panel_color)

                    garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")

                    draw.SimpleText(text, self.font, w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                table.insert(tbl_buttons, button)
            end

            -- timer.Simple(10, function()
            --     if not IsValid(shop_base_panel) then return end
            --     exit()
            -- end)

            local tbl_buttons_doclicks = {
                [gl .. "button_start"] = {
                    doclick = function(self) 
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                            
                        garlic_like_start_cl()
                        ply:ConCommand(gl .. "start")

                        timer.Simple(0.1, function() 
                            if GetConVar(gl .. "enable_timer"):GetBool() then 
                                ply:ConCommand(gl .. "debug_open_weapon_chest") 
                            end
                        end)
                        
                        exit()
                    end,
                },
                [gl .. "button_shop"] = {
                    doclick = function(self) 
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                        shop_base_panel:SetPos(10000, 10000)
                        local frame = vgui.Create("DPanel", shop_base_panel)
                        frame:SetPos(W * 0.5 - W * 0.25, H_half_screen - H * 0.25)
                        frame:SetSize(W * 0.5, H_half_screen)
                        frame:MakePopup()

                        frame.Paint = function(self, w, h)
                            draw.RoundedBox(8, 0, 0, w, h, color_black_alpha_200)
                        end

                        local shop_button_hint = vgui.Create("DImageButton", shop_base_panel)
                        shop_button_hint:SetPos(W * 0.01, H * 0.16)
                        shop_button_hint:MoveRightOf(frame, 0)
                        shop_button_hint:SetSize(W * 0.05, W * 0.05)
                        shop_button_hint:MakePopup()
                        shop_button_hint.toggled = false

                        shop_button_hint.Paint = function(self, w, h)
                            if self:IsDown() then
                                draw.RoundedBox(8, w * 0.05, w * 0.05, w * 0.90, w * 0.90, color_black_alpha_200)
                                draw.SimpleText("?", gl .. "font_title_3", w * 0.5, w * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                draw.RoundedBox(8, w * 0.05, w * 0.05, w * 0.90, w * 0.90, Color(255, 255, 255, 50))
                            else
                                draw.RoundedBox(8, 0, 0, w, h, color_black_alpha_200)
                                draw.SimpleText("?", gl .. "font_title_3", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                                if self:IsHovered() then  
                                    draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, 50))                             
                                end
                            end

                            garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
                        end

                        local help_frame

                        shop_button_hint.DoClick = function(self)
                            surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")

                            if not shop_button_hint.toggled then
                                help_frame = vgui.Create("DPanel", shop_base_panel)
                                help_frame:SetSize(W * 0.2, H * 0.4)
                                help_frame:Center()
                                help_frame:MoveRightOf(frame, W * 0.01)
                                help_frame:MoveBelow(shop_button_hint, H * 0.01)
                                help_frame:MakePopup()

                                help_frame.Paint = function(self, w, h)
                                    draw.RoundedBox(8, 0, 0, w, h, color_black_alpha_200)
                                    draw.DrawText("INFO ON STATS UPGRADE:\nEvery star increases stat\ngain by 8%.\n\nINFO ON ITEM UPGRADE:\nEvery star increases multiplier\nby 10%.\n\nINFO ON ABILITY UPGRADE:\nEvery star increases damage\nby 5% and cooldown reduced\nby 5%.\n\nIMPORTANT NOTE:\nUpgrades have to be bought BEFORE\npicking them up!", gl .. "font_subtitle", w * 0.5, h * 0.1, color_white, TEXT_ALIGN_CENTER)
                                end

                                shop_button_hint.toggled = true
                            else
                                shop_button_hint.toggled = false
                                help_frame:Remove()
                            end
                        end

                        local shop_button_back = vgui.Create("DImageButton", shop_base_panel)
                        shop_button_back:SetPos(W * 0.01, H * 0.16)
                        shop_button_back:MoveLeftOf(frame, 0)
                        shop_button_back:SetSize(W * 0.05, W * 0.05)
                        shop_button_back:MakePopup()

                        shop_button_back.Paint = function(self, w, h)
                            if self:IsDown() then
                                draw.RoundedBox(8, w * 0.05, w * 0.05, w * 0.90, w * 0.90, color_black_alpha_200)
                                draw.SimpleText("BACK", gl .. "font_title_3", w * 0.5, w * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                draw.RoundedBox(8, w * 0.05, w * 0.05, w * 0.90, w * 0.90, Color(255, 255, 255, 50))
                            else
                                draw.RoundedBox(8, 0, 0, w, h, color_black_alpha_200)
                                draw.SimpleText("BACK", gl .. "font_title_3", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                                if self:IsHovered() then 
                                    draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, 50))                            
                                end
                            end

                            garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
                        end

                        shop_button_back.DoClick = function(self)
                            surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                            frame:Remove()
                            shop_base_panel:Center()
                            shop_button_back:Remove()
                            shop_button_hint:Remove()

                            if IsValid(help_frame) then
                                help_frame:Remove()
                            end
                        end

                        local scroll_panel = vgui.Create("DScrollPanel", frame)
                        scroll_panel:Dock(FILL)
                        local sbar = scroll_panel:GetVBar()

                        function sbar:Paint(w, h)
                        end

                        function sbar.btnUp:Paint(w, h)
                        end

                        function sbar.btnDown:Paint(w, h)
                        end

                        function sbar.btnGrip:Paint(w, h)
                        end

                        local upgrades_list = vgui.Create("DIconLayout", scroll_panel)
                        upgrades_list:Dock(FILL)
                        upgrades_list:DockMargin(frame:GetWide() * 0.021, 0, 0, 0)
                        upgrades_list:SetSpaceX(scroll_panel:GetWide() * 0.3)
                        upgrades_list:SetSpaceY(scroll_panel:GetWide() * 0.3)

                        for k, upgrade in SortedPairs(FROZE_GL.garlic_like_upgrades) do
                            local list_item = upgrades_list:Add("DButton")
                            list_item:SetText("")
                            list_item:SetSize(frame:GetWide() * 0.3, frame:GetWide() * 0.2)
                            list_item.upgrade = FROZE_GL.garlic_like_upgrades[k]
                            list_item.item_price = list_item.upgrade.upgrade_price + list_item.upgrade.upgrade_price_increase * list_item.upgrade.upgrade_level
                            list_item.item_price_tw, list_item.item_price_th = surface.GetTextSize(list_item.item_price)
                            list_item.item_max_tw, list_item.item_max_th = surface.GetTextSize("MAX")

                            list_item.Paint = function(self, w, h)
                                if self:IsDown() then
                                    draw.RoundedBox(8, w * 0.15, h * 0.15, w * 0.7, h * 0.7, color_black_alpha_150)

                                    if self:IsHovered() then
                                        draw.RoundedBox(8, w * 0.15, h * 0.15, w * 0.7, h * 0.7, Color(255, 255, 255, 50))
                                    end

                                    surface.SetDrawColor(255, 255, 255)
                                    surface.SetMaterial(Material(list_item.upgrade.icon))
                                    surface.DrawTexturedRect(w * 0.3, h * 0.3, w * 0.4, h * 0.4)
                                else
                                    draw.RoundedBox(8, w * 0.1, h * 0.1, w * 0.8, h * 0.8, color_black_alpha_150)

                                    if self:IsHovered() then 
                                        draw.RoundedBox(8, w * 0.1, h * 0.1, w * 0.8, h * 0.8, Color(255, 255, 255, 50))                                 
                                    end

                                    surface.SetDrawColor(255, 255, 255)
                                    surface.SetMaterial(Material(list_item.upgrade.icon))
                                    surface.DrawTexturedRect(w * 0.25, h * 0.25, w * 0.5, h * 0.5)
                                end

                                garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")

                                surface.SetFont(gl .. "font_title_3")
                                surface.SetTextColor(255, 255, 255)
                                surface.SetDrawColor(255, 255, 255)

                                if list_item.upgrade.upgrade_level < 5 then
                                    surface.SetTextPos(w * 0.5 - list_item.item_price_tw * 0.5, h * 0.8)
                                    surface.DrawText(list_item.item_price)
                                    -- HL ICON
                                    surface.SetMaterial(FROZE_GL.mat_hl)
                                    surface.DrawTexturedRect(w * 0.4 + list_item.item_price_tw * 1.1, h * 0.78, w * 0.2, h * 0.2)
                                else
                                    surface.SetTextPos(w * 0.5 - list_item.item_max_tw * 0.5, h * 0.8)
                                    surface.DrawText("MAX")
                                end

                                -- STARS
                                for i = 1, 5 do
                                    surface.SetDrawColor(255, 255, 255)

                                    if list_item.upgrade.upgrade_level >= i then
                                        surface.SetMaterial(Material("garlic_like/icon_star_yellow.png"))
                                    else
                                        surface.SetMaterial(Material("garlic_like/icon_star_gray.png"))
                                    end

                                    surface.DrawTexturedRect((w * 0.15 * i) - w * 0.15 / 5, h * 0.03, w * 0.15, h * 0.15)
                                end
                            end

                            list_item.DoClick = function()
                                if tonumber(list_item.upgrade.upgrade_level) > 4 or tonumber(ply:GetNWInt(gl .. "money", 0)) < tonumber(list_item.item_price) then return end
                                --
                                surface.PlaySound("garlic_like/disgaea5_item_bought.wav")
                                --
                                garlic_like_update_money(list_item.item_price, "BOUGHT_ITEM")
                                --
                                FROZE_GL.garlic_like_upgrades[i].upgrade_level = FROZE_GL.garlic_like_upgrades[i].upgrade_level + 1
                                list_item.upgrade = FROZE_GL.garlic_like_upgrades[i]
                                list_item.item_price = list_item.upgrade.upgrade_price + list_item.upgrade.upgrade_price_increase * list_item.upgrade.upgrade_level
                                list_item.item_price_tw, list_item.item_price_th = surface.GetTextSize(list_item.item_price)
                                FROZE_GL.garlic_like_upgrades[i] = list_item.upgrade
                                -- 
                                garlic_like_save_table_to_json(ply, FROZE_GL.garlic_like_upgrades, gl .. "upgrades")
                            end
                        end
                    end,
                },
                [gl .. "button_chr_upgrades"] = {
                    doclick = function(self)
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")

                        shop_base_panel:Hide()
                        --
                        garlic_like_open_char_upgrades_menu(shop_base_panel)
                    end,
                },
                [gl .. "button_inventory"] = {
                    doclick = function(self)
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")

                        shop_base_panel:Hide()
                        --
                        garlic_like_open_inventory_menu()
                    end,
                },
                [gl .. "button_blacksmith"] = {
                    doclick = function(self) 
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")

                        -- shop_base_panel:Hide()
                        exit()

                        ply:ConCommand(gl .. "debug_open_weapon_upgrade_menu BLACKSMITH")
                        -- exit()
                    end,
                },
                [gl .. "button_fusion"] = {
                    doclick = function(self) 
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")

                        -- shop_base_panel:Hide()
                        exit()

                        ply:ConCommand(gl .. "debug_open_weapon_upgrade_menu FUSION")
                        -- exit()
                    end,
                },
                [gl .. "button_unlockables"] = {
                    doclick = function(self) 
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")

                        shop_base_panel:Hide()

                        garlic_like_open_unlockables_menu()
                    end,
                },
                [gl .. "button_glossary"] = {
                    doclick = function(self) 
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                        
                        shop_base_panel:Hide()

                        garlic_like_open_glossary()
                    end,
                },
                [gl .. "button_settings"] = {
                    doclick = function(self) 
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                    end,
                },
                [gl .. "button_exit"] = {
                    doclick = function(self) 
                        exit()
                    end,
                },
            }

            create_button("button_start", "START") 
            -- create_button("button_shop", "SHOP") 
            create_button("button_chr_upgrades", "CHARACTER UPGRADES")
            create_button("button_inventory", "INVENTORY")
            -- create_button("button_blacksmith", "WEAPON UPGRADE") 
            -- create_button("button_fusion", "ITEM FUSION") 
            create_button("button_unlockables", "UNLOCKABLES")
            create_button("button_glossary", "GLOSSARY")
            -- create_button("button_settings", "SETTINGS") 
            create_button("button_exit", "EXIT")  

            shop_base_panel:SizeTo(W * 0.5, H_half_screen, 0.25, 0, 0.5, function()
                shop_base_panel.isAnimating = false
            end)

            -- PrintTable(tbl_buttons_doclicks)

            for k, panel in pairs(tbl_buttons) do 
                -- print(panel:GetName())
                panel.DoClick = tbl_buttons_doclicks[panel:GetName()].doclick
            end

            shop_base_panel.OnSizeChanged = function(self, w, h)
                if self.isAnimating then
                    -- self:Center()
                    self:CenterHorizontal()
                    self:CenterVertical(0.55)
                end

                for k, panel in pairs(tbl_buttons) do 
                    local topmod = 0
                    
                    if k == 1 then 
                        topmod = h * 0.02
                    end

                    panel:SetTall(h * 0.1)
                    panel:DockMargin(w * 0.025, h * 0.01 + topmod, w * 0.025, h * 0.025)                
                end

                -- button_toggle_start:SetTall(h * 0.1)
                -- button_toggle_start:DockMargin(w * 0.025, h * 0.03, w * 0.025, h * 0.025)
                -- button_shop:SetTall(h * 0.1)
                -- button_shop:DockMargin(w * 0.025, h * 0.01, w * 0.025, h * 0.025)
                -- button_settings:SetTall(h * 0.1)
                -- button_settings:DockMargin(w * 0.025, h * 0.01, w * 0.025, h * 0.025)
                -- button_blacksmith:SetTall(h * 0.1)
                -- button_blacksmith:DockMargin(w * 0.025, h * 0.01, w * 0.025, h * 0.025)
                -- button_exit:SetTall(h * 0.1)
                -- button_exit:DockMargin(w * 0.025, h * 0.01, w * 0.025, h * 0.035)
            end
            -- timer.Simple(5, function()
            --     shop_base_panel:Remove()
            -- end)
        end
        
        function garlic_like_open_weapon_crate_menu(rarity)
            -- garlic_like_pause_game_toggle()
            
            local ply = LocalPlayer() 
            local tbl_fallback_weapon = {}
            local mat_fallback = Material("entities/weapon_fists.png")
            local ready_to_click = false

            if not rarity then 
                rarity = "common"
            end 

            local black_bg = vgui.Create("DPanel", nil)
            black_bg:SetSize(W, H)
            black_bg:Center()

            black_bg.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, color_black_alpha_150)
            end

            local base_frame = vgui.Create("DPanel", nil, "base_frame_weapons_chest")
            base_frame:SetSize(W * 0.6, H * 0.65)
            base_frame:Center()
            base_frame:MakePopup()

            base_frame.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(55, 55, 55, 0))
            end

            local bs_w = base_frame:GetWide()
            local bs_t = base_frame:GetTall() 

            local tbl_wep_choice = {}

            for i = 1, 3 do
                local wep_choice = vgui.Create("DButton", base_frame, "wep_choice_" .. i)
                wep_choice:SetSize(bs_w * 0.25, bs_t * 0.8)
                wep_choice:CenterVertical()
                wep_choice:SetX((i * bs_w * 0.3) - (bs_w * 0.3) + (bs_w * 0.075))
                wep_choice:SetText("")
                wep_choice:Hide()
                -- 
                -- wep_choice.wep_level = math.random(1, 100)
                -- wep_choice.wep_rarity = garlic_like_determine_wep_rarity()
                

                -- PrintTable(wep_choice.wep_bonuses)
                --
                table.insert(tbl_wep_choice, wep_choice)
            end

            -- PrintTable( FROZE_GL.gl_stored_bonused_weapons)
            --
            local wep_already_held = vgui.Create("DButton", black_bg, "wep_choice_" .. 4)
            wep_already_held:SetSize(bs_w * 0.25, bs_t * 0.8)
            wep_already_held:CenterVertical()
            wep_already_held:SetX(W * 0.22 + (4 * bs_w * 0.3) - (bs_w * 0.3) + (bs_w * 0.075))
            wep_already_held:SetText("")
            wep_already_held:Hide() 

            wep_already_held.Paint = function(self, w, h) 
                draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 35, 255))
            
                if self.initialized then 
                    surface.SetDrawColor(255, 255, 255)
                    surface.DrawCircle(w * 0.5, h * 0.2, w * 0.25, self.wep_rarity_color)
                    surface.SetDrawColor(255, 255, 255)
                    if isnumber(self.wep_icon) then 
                        surface.SetTexture(self.wep_icon)
                    else 
                        surface.SetMaterial(self.wep_icon)
                    end
                    
                    surface.DrawTexturedRect(w * 0.15, h * 0.1, w * 0.7, w * 0.4)
                    draw.DrawText(string.upper(self.wep_rarity), gl .. "font_subtitle", w * 0.5, h * 0.35, self.wep_rarity_color, TEXT_ALIGN_CENTER)
                    -- draw.DrawText(element, gl .. "font_subtitle", w * 0.5, h * 0.4, self.wep_element.color, TEXT_ALIGN_CENTER)
                    -- local element_w, element_h = surface.GetTextSize(element)
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(self.mat_element)
                    surface.DrawTexturedRect(w * 0.5 - W * 0.0055, h * 0.41, W * 0.011, W * 0.011)
                    
                    draw.DrawText(self.wep_name, gl .. "font_title_3", w * 0.5, h * 0.45, color_white, TEXT_ALIGN_CENTER)  
                    
                    if self.wep_bonuses_amount > 0 then
                        draw.DrawText("When held :", gl .. "font_subtitle", w * 0.5, h * 0.52, color_white, TEXT_ALIGN_CENTER)

                        for i = 1, self.wep_bonuses_amount do
                            gl_cse(ply, w * 0.5, (h * 0.55) + (i * h * 0.05), 100 * self.wep_bonuses[i].modifier, "%", self.wep_bonuses[i].desc, true, false, "", false, gl .. "font_subtitle", nil, true)
                        end
                    end
                end
            end
            --
            local wep_already_held_text = vgui.Create("DLabel", black_bg)
            local waht = "Already Owned:"
            surface.SetFont(gl .. "font_title_2")
            local waht_w, waht_h = surface.GetTextSize(waht)
            waht_w = waht_w * 1.05
            wep_already_held_text:SetSize(waht_w, wep_already_held:GetTall() * 0.1)
            wep_already_held_text:SetX(wep_already_held:GetX() + (wep_already_held:GetWide() - waht_w) / 2)
            wep_already_held_text:MoveAbove(wep_already_held, H * 0.03)
            wep_already_held_text:SetText(waht)
            wep_already_held_text:SetFont(gl .. "font_title_2")
            wep_already_held_text:SetColor(color_white)
            wep_already_held_text:Hide()  

            for k, wep_choice in pairs(tbl_wep_choice) do
                timer.Simple((k - 1) * 0.2, function()
                    surface.PlaySound("garlic_like/mm_rank_up_achieved.wav")

                    if wep_choice.fade_in_transparency == nil then
                        wep_choice.fade_in_transparency = 255
                        wep_choice.highlight_transparency = 10
                        wep_choice.icon_set = false
                        wep_choice.facing = "FRONT"
                        wep_choice:SetTooltip("PRESS RMB TO SWAP INFO")
                        --
                        garlic_like_get_weapon(wep_choice, FROZE_GL.tbl_valid_weapons, "ROLL", rarity)

                        -- print("WEP RARITY: " .. wep_choice.wep_rarity)
                    end

                    wep_choice:Show()

                    wep_choice.Paint = function(self, w, h)
                        self.fade_in_transparency = math.Approach(self.fade_in_transparency, 0, 30)

                        local ply = LocalPlayer()
                        local element = string.upper(self.wep_element.name)
                        local mat_element = self.wep_element.mat_1
                        --
                        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 35, 255))
                        surface.SetDrawColor(255, 255, 255)
                        surface.DrawCircle(w * 0.5, h * 0.2, w * 0.25, self.wep_rarity_color)
                        surface.SetDrawColor(255, 255, 255)
                        if not self.wep_icon_is_material then 
                            surface.SetTexture(self.wep_icon)
                        else
                            surface.SetMaterial(self.wep_icon)
                        end
                        surface.DrawTexturedRect(w * 0.15, h * 0.1, w * 0.7, w * 0.4)
                        draw.DrawText(string.upper(self.wep_rarity), gl .. "font_subtitle", w * 0.5, h * 0.35, self.wep_rarity_color, TEXT_ALIGN_CENTER)
                        -- draw.DrawText(element, gl .. "font_subtitle", w * 0.5, h * 0.4, self.wep_element.color, TEXT_ALIGN_CENTER)
                        -- local element_w, element_h = surface.GetTextSize(element)
                        surface.SetDrawColor(255, 255, 255)
                        surface.SetMaterial(mat_element)
                        surface.DrawTexturedRect(w * 0.5 - W * 0.0055, h * 0.41, W * 0.011, W * 0.011)
                        
                        -- draw.DrawText(self.wep_name, gl .. "font_title_3", w * 0.5, h * 0.45, color_white, TEXT_ALIGN_CENTER)
                        garlic_like_draw_scaled(self.wep_name, w * 0.5, h * 0.45, h * 0.45, gl .. "font_title_3", GetConVar(gl .. "hud_font_2"):GetString(), color_white, TEXT_ALIGN_CENTER, nil, "LINES_DISABLED")
                        draw.RoundedBox(6, 0, 0, w, h, Color(self.wep_rarity_color.r, self.wep_rarity_color.g, self.wep_rarity_color.b, self.fade_in_transparency))                    

                        -- print("self.facing " .. self.facing)

                        if self.facing == "FRONT" and self.wep_bonuses_amount > 0 then
                            draw.DrawText("When held :", gl .. "font_subtitle", w * 0.5, h * 0.52, color_white, TEXT_ALIGN_CENTER)

                            for i = 1, self.wep_bonuses_amount do
                                gl_cse(ply, w * 0.5, (h * 0.55) + (i * h * 0.05), 100 * self.wep_bonuses[i].modifier, "%", self.wep_bonuses[i].desc, true, false, "", false, gl .. "font_subtitle", nil, true)
                            end
                        elseif self.facing == "BACK" then 
                            draw.DrawText("RARITY BASE STATS MODIFIER", gl .. "font_subtitle", w * 0.5, h * 0.52, color_white, TEXT_ALIGN_CENTER) 
                            local base_mod_num = wep_choice.wep_base_rarity_mod_num
                            -- print("base_mod_num " .. base_mod_num)
                            local color_text 

                            if base_mod_num > 1 then 
                                color_text = nil 
                            else
                                color_text = color_red
                            end

                            local wep = wep_choice.wep

                            local is_tfa_melee = garlic_like_is_tfa_melee(weapons.Get(wep.ClassName))

                            -- print("is melee? " .. tostring(is_tfa_melee)) 
                            wep.cl_wep_base_rarity_mod_num = base_mod_num
                            local power = garlic_like_get_wep_power(ply, wep)
                            local dmg = 1
                            local dmg_melee_1
                            local dmg_melee_2                            
                            local range_1
                            local aspd_1
                            local aspd_2
                            local numshot = 1
                            local rpm = 1 
                            local magcap = 1
                            local recoil = 1 
                            local text_numshot
                            
                            local tbl_wep_primary = (wep.Primary)  
                            local tbl_wep_secondary = (wep.Secondary)  
                            
                            if garlic_like_is_arccw_wep(wep) and wep.Damage then 
                                dmg = wep.Damage * base_mod_num
                                rpm = (60 / wep.Delay) * base_mod_num
                                numshot = wep.Num
                                magcap = tbl_wep_primary.ClipSize * base_mod_num
                                recoil = 1 / base_mod_num
                            elseif garlic_like_is_tfa_wep(wep) then 
                                if is_tfa_melee then 
                                    dmg_melee_1 = tbl_wep_primary.Attacks[1].dmg * base_mod_num
                                    dmg_melee_2 = tbl_wep_secondary.Attacks[1].dmg * base_mod_num
                                    aspd_1 = 1 / tbl_wep_primary.Attacks[1]['end'] * base_mod_num
                                    aspd_2 = 1 / tbl_wep_secondary.Attacks[1]['end'] * base_mod_num
                                    range_1 = tbl_wep_primary.Attacks[1].len * base_mod_num
                                    range_2 = tbl_wep_secondary.Attacks[1].len * base_mod_num
                                else
                                    if tbl_wep_primary then 
                                        dmg = tbl_wep_primary.Damage * base_mod_num
                                        rpm = tbl_wep_primary.RPM * base_mod_num
                                        numshot = tbl_wep_primary.NumShots
                                        magcap = tbl_wep_primary.ClipSize * base_mod_num
                                        recoil = 1 / base_mod_num
                                    else 
                                        dmg = 1
                                        rpm = 1
                                        numshot = 1
                                        magcap = 1
                                        recoil = 1
                                    end
                                end
                            end 

                            if dmg then 
                                dmg = math.Round(dmg)
                                rpm = math.Round(rpm)
                                magcap = math.Round(magcap) 
                                recoil = math.Truncate(recoil, 3)
                                text_numshot = (numshot > 1) and "x" .. numshot or ""
                            else 
                                dmg = ""
                                rpm = ""
                                magcap = ""
                                text_numshot = ""
                            end

                            if dmg_melee_1 then 
                                dmg_melee_1 = math.Round(dmg_melee_1)
                                dmg_melee_2 = math.Round(dmg_melee_2)
                                aspd_1 = math.Truncate(aspd_1, 3)
                                aspd_2 = math.Truncate(aspd_2, 3)
                                range_1 = math.Round(range_1)
                                range_2 = math.Round(range_2)
                            end                            
                            
                            gl_cse(ply, w * 0.5, (h * 0.55) + (1 * h * 0.05), power, " ", "POWER", true, false, "", false, gl .. "font_subtitle", color_text, true)
                            gl_cse(ply, w * 0.5, (h * 0.55) + (2 * h * 0.05), "x" .. base_mod_num, " ", "BASE STATS", true, false, "", false, gl .. "font_subtitle", color_text, true)

                            color_text = nil

                            --* if it's a tfa melee
                            if is_tfa_melee then  
                                gl_cse(ply, w * 0.5, (h * 0.55) + (3 * h * 0.05), "", dmg_melee_1, " LMB DMG", true, false, "", false, gl .. "font_subtitle", color_text, true)
                                gl_cse(ply, w * 0.5, (h * 0.55) + (4 * h * 0.05), "", aspd_1, " LMB ASPD", true, false, "", false, gl .. "font_subtitle", color_text, true)
                                gl_cse(ply, w * 0.5, (h * 0.55) + (5 * h * 0.05), "", range_1, " LMB RAMGE", true, false, "", false, gl .. "font_subtitle", color_text, true)
                                gl_cse(ply, w * 0.5, (h * 0.55) + (6 * h * 0.05), "", dmg_melee_2, " RMB DMG", true, false, "", false, gl .. "font_subtitle", color_text, true)                                
                                gl_cse(ply, w * 0.5, (h * 0.55) + (7 * h * 0.05), "", aspd_2, " RMB ASPD", true, false, "", false, gl .. "font_subtitle", color_text, true)                                
                                gl_cse(ply, w * 0.5, (h * 0.55) + (8 * h * 0.05), "", range_2, " RMB RAMGE", true, false, "", false, gl .. "font_subtitle", color_text, true)
                            else --* if it's a gun
                                gl_cse(ply, w * 0.5, (h * 0.55) + (3 * h * 0.05), "", dmg .. text_numshot, " DMG", true, false, "", false, gl .. "font_subtitle", color_text, true)
                                gl_cse(ply, w * 0.5, (h * 0.55) + (4 * h * 0.05), "", rpm, " RPM", true, false, "", false, gl .. "font_subtitle", color_text, true)
                                gl_cse(ply, w * 0.5, (h * 0.55) + (5 * h * 0.05), "", magcap, " MAG CAP", true, false, "", false, gl .. "font_subtitle", color_text, true)
                                gl_cse(ply, w * 0.5, (h * 0.55) + (6 * h * 0.05), "x", base_mod_num, " RELOAD", true, false, "", false, gl .. "font_subtitle", color_text, true)        
                                gl_cse(ply, w * 0.5, (h * 0.55) + (7 * h * 0.05), "x", recoil, " RECOIL", true, false, "", false, gl .. "font_subtitle", color_text, true)        
                            end
                        end

                        if not self:IsHovered() and not self:IsDown() then
                            self.highlight_transparency = math.Approach(self.highlight_transparency, 0, 3)
                        end

                        if k == 1 then 
                            wep_already_held:Hide()
                            wep_already_held_text:Hide() 
                        end

                        if self:IsHovered() then   
                            --* Shows a preview of the already held weapon of the same class
                            if  FROZE_GL.gl_stored_bonused_weapons[self.wep.ClassName] then 
                                --* If the shown owned weapon isn't the same as the one being hovered, reset
                                if wep_already_held.wep_name ~= self.wep_name then 
                                    wep_already_held.initialized = false
                                    wep_already_held:Hide()
                                    wep_already_held_text:Hide()
                                end 
                                    
                                self.sbw =  FROZE_GL.gl_stored_bonused_weapons[self.wep.ClassName]
                                wep_already_held:Show()
                                wep_already_held_text:Show()

                                -- INITIALIZE THE PANEL, GIVE IT THE SAME PROPERTIES AS self
                                if not wep_already_held.initialized then 
                                    wep_already_held.initialized = true 
                                    -- 
                                    wep_already_held.wep_rarity =  self.sbw.rarity
                                    wep_already_held.wep_rarity_color =  FROZE_GL.tbl_rarity_colors[self.sbw.rarity]  
                                    wep_already_held.wep_element =  self.sbw.element  
                                    wep_already_held.wep_bonuses_amount =  self.sbw.bonus_amount  
                                    wep_already_held.wep_bonuses_modifier =  garlic_like_determine_weapon_bonuses_modifiers(self.sbw.rarity) 
                                    wep_already_held.wep_bonuses =  self.sbw.bonuses  
                                    --
                                    wep_already_held.wep = self.wep
                                    wep_already_held.wep_name = self.wep_name
                                    wep_already_held.wep_stored = self.wep_stored
                                    wep_already_held.wep_icon = self.wep_icon  
                                    wep_already_held.mat_element = self.wep_element.mat_1
                                end 
                            else 
                                wep_already_held.initialized = false
                                wep_already_held:Hide()
                                wep_already_held_text:Hide()
                            end

                            if self:IsDown() then
                                self.highlight_transparency = 20
                            else 
                                self.highlight_transparency = 10 
                            end 
                        end

                        draw.RoundedBox(6, 0, 0, w, h, Color(self.wep_rarity_color.r, self.wep_rarity_color.g, self.wep_rarity_color.b, self.highlight_transparency))
                    end

                    wep_choice.DoRightClick = function(self)  
                        self.facing = (self.facing == "FRONT") and "BACK" or "FRONT" 
                    end

                    wep_choice.DoClick = function(self)   
                        if not ready_to_click then return end             
                        surface.PlaySound("items/gift_pickup.wav")

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

                        if IsValid(base_frame) then
                            -- garlic_like_pause_game_toggle()
                            base_frame:Remove()
                            black_bg:Remove()
                            tbl_wep_choice = {}
                        end
                    end

                    if k == #tbl_wep_choice then 
                        ready_to_click = true
                    end
                end)
            end

            local button_exit = vgui.Create("DButton", black_bg) 
            button_exit:SetSize(W * 0.08, H * 0.04) 
            button_exit:Center() 
            button_exit:SetY(H * 0.1)
            button_exit:SetText("Cancel")
            button_exit:MakePopup()

            button_exit.DoClick = function(self) 
                if IsValid(base_frame) then
                    -- garlic_like_pause_game_toggle()
                    base_frame:Remove()
                    black_bg:Remove()
                    tbl_wep_choice = {}
                end
            end

            -- timer.Simple(2, function()
            --     if IsValid(base_frame) then
            --         base_frame:Remove()
            --         black_bg:Remove()
            --         tbl_wep_choice = {}
            --     end
            -- end)
            do
            end
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

                    print("statboost_num " .. statboost_num)

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

        function garlic_like_show_level_up_screen(ply)
            local ply = LocalPlayer()
            if not IsValid(ply) then return end 
            --
            choice_panels_num = 3
            FROZE_GL.choice_panels = {} 
            --
            local BASEPANEL = vgui.Create("DPanel", nil, gl .. "BASEPANEL") 
            BASEPANEL:SetSize(W, H)
            BASEPANEL.color = Color(0, 0, 0, 0)
            BASEPANEL.reroll_chances = 1 + math.floor(ply:GetNWInt(gl .. "level", 1) / 10)

            BASEPANEL.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, self.color)
            end
            --
            local BlackBG = vgui.Create("DPanel", BASEPANEL, gl .. "BlackBG")
            BlackBG:SetSize(W, H)

            BlackBG.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, color_black_alpha_150)
            end

            local function create_choices()
                local reroll_button = vgui.Create("DButton", BASEPANEL, gl .. "reroll_button") 

                local Choice_transparency

                local function lower_highlight_transparency() 
                    Choice_transparency = 125
                    -- print("TIMER START")
                    surface.PlaySound("garlic_like/mm_rank_up_achieved.wav")

                    for i = 1, 125 do
                        timer.Simple(i / 65, function()
                            if Choice_transparency <= 0 then return end
                            --
                            Choice_transparency = math.max(0, Choice_transparency - i)                                        
                        end)
                    end
                end

                local function create_upgrade_choice(choice_panel) 
                    --* KEYS CLEARED BECAUSE THERE ARE GAPS BETWEEN THE ENTRIES' KEYS
                    FROZE_GL.garlic_like_upgrades_cleared = table.ClearKeys(FROZE_GL.garlic_like_upgrades)
                    Chance_upgrade_choice = math.random(1, 100)
                    local loop = 1
                    local chance_stats = (0.65 * 100)
                    local chance_items = chance_stats + (0.1 * 100)
                    local chance_skills = chance_items + (0.15 * 100)
                    local chance_relics = chance_skills + (0.1 * 100)

                    -- print("CHANCE UPGRADE CHOICE " .. Chance_upgrade_choice)
                    if Chance_upgrade_choice <= chance_stats then
                        choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_statboost)]
                    elseif Chance_upgrade_choice <= chance_items then                
                        choice_panel.tbl_upgrade = table.Copy(FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_item_statboost)])

                        if table.Count(FROZE_GL.items_held) >= 4 then 
                            print("holding 4 items!")
                            for k, tbl_upgrade in RandomPairs(FROZE_GL.items_held) do 
                                for k2, v2 in pairs(FROZE_GL.garlic_like_upgrades) do 
                                    if v2.name == tbl_upgrade.name then 
                                        choice_panel.tbl_upgrade = table.Copy(v2)
                                        break
                                    end
                                end

                                print("chose: ")
                                PrintTable(tbl_upgrade)
                                -- choice_panel.tbl_upgrade = table.Copy(tbl_upgrade)
                                
                            end
                        end

                        while choice_panel.tbl_upgrade == nil or choice_panel.tbl_upgrade.disable_picking_up do
                            loop = loop + 1
                            -- print("Loop A " .. loop)

                            if loop > 50 then
                                choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_statboost)]
                            end

                            choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_item_statboost)]
                        end
                    elseif Chance_upgrade_choice <= chance_skills and table.Count(FROZE_GL.skills_held) < 4 then                
                        choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_skill)]

                        while choice_panel.tbl_upgrade == nil or choice_panel.tbl_upgrade.disable_picking_up do
                            loop = loop + 1
                            -- print("Loop B " .. loop)

                            if loop > 50 then
                                choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_statboost)]
                            end

                            choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_skill)]
                        end
                    elseif Chance_upgrade_choice <= chance_relics and table.Count(FROZE_GL.relics_held) < 4 + ply:GetNWInt(gl .. "relic_slots_unlocked", 0) then                
                        choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_relic)]

                        while choice_panel.tbl_upgrade == nil or choice_panel.tbl_upgrade.disable_picking_up do
                            loop = loop + 1
                            -- print("Loop C " .. loop)

                            if loop > 50 then
                                choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_statboost)]
                            end

                            choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_relic)]
                        end
                    else
                        choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_statboost)]
                    end 

                    if choice_panel.tbl_upgrade.upgrade_type == "statboost" then
                        choice_panel.rarity, choice_panel.statboost, choice_panel.statboost_increase_amount = garlic_like_determine_stats(choice_panel.tbl_upgrade, choice_panel.tbl_upgrade.upgrade_type)
                        --* CARNAGE STAT UPGRADES 
                        -- PrintTable(choice_panel.tbl_upgrade)
                        if GetGlobalInt(gl .. "minutes", 1) >= 20 and ply:GetNWInt(gl .. string.upper(choice_panel.tbl_upgrade.name), 1) >= 100 then  
                            choice_panel.tbl_upgrade.icon = "garlic_like/icon_" .. choice_panel.tbl_upgrade.name .. "_carnage.png"
                            -- choice_panel.tbl_upgrade.name = "carnage " .. choice_panel.tbl_upgrade.name
                        end
                    elseif choice_panel.tbl_upgrade.upgrade_type == "item_statboost" then
                        choice_panel.rarity, choice_panel.statboost, choice_panel.statboost_increase_amount, choice_panel.stacks = garlic_like_determine_stats(choice_panel.tbl_upgrade, choice_panel.tbl_upgrade.upgrade_type)
                    elseif choice_panel.tbl_upgrade.upgrade_type == "skill" then
                        if type(choice_panel.tbl_upgrade.area) == "string" then
                            choice_panel.rarity, choice_panel.statboost, choice_panel.cooldown = garlic_like_determine_stats(choice_panel.tbl_upgrade, choice_panel.tbl_upgrade.upgrade_type)
                            choice_panel.damage = math.Round(choice_panel.statboost * (1 + ply:GetNWFloat(gl .. "bonus_damage")))
                            choice_panel.area = choice_panel.tbl_upgrade.area
                        elseif type(choice_panel.tbl_upgrade.area) == "number" then
                            choice_panel.rarity, choice_panel.statboost, choice_panel.cooldown, choice_panel.area = garlic_like_determine_stats(choice_panel.tbl_upgrade, choice_panel.tbl_upgrade.upgrade_type)
                            choice_panel.damage = choice_panel.statboost
                        end
                    elseif choice_panel.tbl_upgrade.upgrade_type == "relic" then
                        choice_panel.rarity, choice_panel.mul, choice_panel.mul_2 = garlic_like_determine_stats(choice_panel.tbl_upgrade, choice_panel.tbl_upgrade.upgrade_type)
                    end

                    choice_panel.upgrade_type = choice_panel.tbl_upgrade.upgrade_type
                    --
                    choice_panel.color_rarity_border = FROZE_GL.tbl_rarity_colors[choice_panel.rarity]
                end

                timer.Create(gl .. "lower_transparency", 0.5, 1, function()
                    lower_highlight_transparency()
                end)

                -- PrintTable(FROZE_GL.tbl_id_upgrades_statboost)
                -- PrintTable(FROZE_GL.garlic_like_upgrades[FROZE_GL.tbl_id_upgrades_statboost[math.random(1, #tbl_id_upgrades_statboost)]])

                for i = 1, choice_panels_num do
                    local Choice = vgui.Create("DButton", nil, gl .. "Choice_" .. i)
                    Choice:SetSize(W * 0.22, H * 0.75)
                    Choice:SetPos((i * W * 0.26) - W * 0.043 * choice_panels_num, 0 - Choice:GetTall())
                    Choice:SetText("")
                    Choice:MakePopup()
                    Choice:SetMouseInputEnabled(true)
                    Choice.damage = nil
                    Choice.cooldown = nil
                    Choice.area = nil
                    Choice.isAnimating = true

                    Choice:MoveTo((i * W * 0.26) - W * 0.043 * choice_panels_num, H * 0.15, 0.3, 0.1, 0.5, function()
                        Choice.isAnimating = false
                    end)

                    Choice.Think = function(self)
                        if self.isAnimating then end
                    end

                    Choice.Paint = function(self, w, h)
                        draw.RoundedBox(6, w * 0.02, h * 0.013, w * 0.98, h * 0.98, color_black_alpha_100)
                        draw.RoundedBox(6, w * 0.01, h * 0.007, w * 0.98, h * 0.985, Color(35, 35, 35))
                        surface.SetDrawColor(255, 255, 255)
                        surface.SetMaterial(Material("garlic_like/question_mark.png"))
                        surface.DrawTexturedRect(0, h * 0.25, w, h * 0.5)
                    end

                    create_upgrade_choice(Choice)

                    timer.Simple(0.5, function()
                        timer.Simple(0.05, function()
                            if not IsValid(Choice) then return end
                            Choice:SetMouseInputEnabled(true)

                            -- Shows reroll button after the choices settled
                            -- if not reroll_button or not IsValid(reroll_button)  then return end 
                            if BASEPANEL.reroll_chances < 1 then return end
                            --
                            reroll_button:Show()      
                            reroll_button:MoveTo(reroll_button:GetX(), H * 0.925, 0.2, 0, -1, function() 
                                reroll_button.on_cooldown = true

                                timer.Simple(0.5, function() 
                                    if reroll_button and IsValid(reroll_button) then 
                                        reroll_button.on_cooldown = false
                                    end
                                end)
                            end)              
                        end)

                        local icon_upgrade = vgui.Create("DImage", Choice, gl .. "icon_upgrade_" .. i)
                        icon_upgrade:SetSize(Choice:GetWide() * 0.4, Choice:GetTall() * 0.2)
                        icon_upgrade:SetPos(0, icon_upgrade:GetParent():GetTall() * 0.1)
                        icon_upgrade:CenterHorizontal()

                        icon_upgrade.Paint = function(self, w, h)
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.SetMaterial(Material(Choice.tbl_upgrade.icon))
                            surface.DrawTexturedRect(w * 0.25, h * 0.25, w * 0.5, h * 0.5)
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.DrawCircle(w * 0.5, h * 0.5, W * 0.04, Choice.color_rarity_border)
                        end

                        local name = vgui.Create("DLabel", Choice, gl .. "name_" .. i)
                        name:SetPos(0, Choice:GetTall() * 0.1)
                        name:SetSize(Choice:GetWide(), Choice:GetTall() * 0.5)
                        name:SetFont("Default")
                        name:SetText("")
                        name.text = string.upper(Choice.tbl_upgrade.name)
                        name.color = color_white
                        name.color_carnage = Color(221, 0, 0)

                        -- print("ICON " .. Choice.tbl_upgrade.icon)

                        if string.find(Choice.tbl_upgrade.icon, "carnage") then 
                            name.color = name.color_carnage
                            name.color_carnage_highlight = Color(255, 255, 255, 100)
                            name.iscarnage = true
                        end

                        name.Paint = function(self, w, h) 
                            draw.SimpleText(name.text, gl .. "font_title", w * 0.5, h * 0.5, self.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                            if self.iscarnage then 
                                local color = self.color_carnage_highlight
                                color.a = math.abs(math.cos(CurTime() * 2) * 50)

                                draw.SimpleText(name.text, gl .. "font_title", w * 0.5, h * 0.5, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            end
                        end

                        local rarity = vgui.Create("DLabel", Choice, gl .. "name_" .. i)
                        rarity:SetPos(0, Choice:GetTall() * 0.15)
                        rarity:SetSize(Choice:GetWide(), Choice:GetTall() * 0.5)
                        rarity:SetFont("Default")
                        rarity:SetText("")
                        rarity.tier = string.upper(Choice.rarity)

                        rarity.Paint = function(self, w, h)
                            draw.SimpleText(rarity.tier, gl .. "font_subtitle", w * 0.5, h * 0.5, Choice.color_rarity_border, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end

                        local desc = vgui.Create("DLabel", Choice, gl .. "desc_" .. i)
                        desc:SetPos(0, Choice:GetTall() * 0.2)
                        desc:SetSize(Choice:GetWide(), Choice:GetTall() * 0.5)
                        desc:SetFont("Default")
                        desc:SetText("")

                        desc.Paint = function(self, w, h)
                            draw.DrawText(Choice.tbl_upgrade.desc, gl .. "font_subtitle", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER)
                        end

                        local statboost_num = vgui.Create("DLabel", Choice, gl .. "desc_" .. i)
                        statboost_num:SetPos(0, Choice:GetTall() * 0.25)
                        statboost_num:SetSize(Choice:GetWide(), Choice:GetTall() * 0.5)
                        statboost_num:SetFont("Default")
                        statboost_num:SetText("")
                        statboost_num.num = Choice.statboost
                        statboost_num.item_modifier = 1
                        statboost_num.item_additive = 0
                        statboost_num.item_string_operator = "+"

                        if Choice.tbl_upgrade.upgrade_type == "statboost" then
                            statboost_num.sb_type = string.upper(Choice.tbl_upgrade.name)
                            statboost_num.STR_Plus = math.Round(ply:GetNWInt(gl .. "STR", 1) / ply:GetNWFloat(gl .. "bonus_stat_mult_crystal", 1)) + statboost_num.num
                            statboost_num.AGI_Plus = math.Round(ply:GetNWInt(gl .. "AGI", 1) / ply:GetNWFloat(gl .. "bonus_stat_mult_crystal", 1)) + statboost_num.num
                            statboost_num.INT_Plus = math.Round(ply:GetNWInt(gl .. "INT", 1) / ply:GetNWFloat(gl .. "bonus_stat_mult_crystal", 1)) + statboost_num.num
                        elseif Choice.tbl_upgrade.upgrade_type == "item_statboost" and Choice.tbl_upgrade.item_type == "reducing_mult" then
                            statboost_num.num = Choice.statboost
                            statboost_num.item_modifier = 1
                            statboost_num.item_additive = -1
                            statboost_num.item_string_operator = "x"
                        elseif Choice.tbl_upgrade.upgrade_type == "item_statboost" and Choice.tbl_upgrade.item_type == "increasing_mult" then
                            statboost_num.num = Choice.statboost
                            statboost_num.item_modifier = 1
                            statboost_num.item_additive = 1
                            statboost_num.item_string_operator = "x"
                        elseif Choice.tbl_upgrade.upgrade_type == "skill" then
                            statboost_num.num = Choice.damage

                            if type(Choice.area) ~= "string" then
                                Choice.area_shortdesc = " AREA"
                            else
                                Choice.area_shortdesc = ""
                            end
                        elseif Choice.tbl_upgrade.upgrade_type == "relic" then
                            statboost_num.num = ""
                        end

                        statboost_num.Paint = function(self, w, h)
                            pos_x_mid = w * 0.5 

                            if Choice.upgrade_type == "skill" then
                                -- gl_cse(ply, pos_x, pos_y, front_operator, numbers, short_desc)
                                gl_cse(ply, pos_x_mid, h * 0.625, "", Choice.damage, " DAMAGE", true)
                                gl_cse(ply, pos_x_mid, h * 0.675, "", Choice.cooldown, " COOLDOWN", true)
                                gl_cse(ply, pos_x_mid, h * 0.725, "", Choice.area, Choice.area_shortdesc, true)
                                -- draw.DrawText(Choice.damage .. " DAMAGE \n" .. Choice.cooldown .. "s COOLDOWN \n" .. Choice.area, gl .. "font_subtitle", pos_x_mid, h * 0.6, color_white, TEXT_ALIGN_CENTER)
                            elseif Choice.upgrade_type == "statboost" then
                                -- gl_cse(ply, pos_x, pos_y, front_operator, numbers, short_desc)
                                gl_cse(ply, pos_x_mid, h * 0.5, statboost_num.item_string_operator, math.abs(statboost_num.item_additive + statboost_num.num) * statboost_num.item_modifier, "", true)

                                --! FIX THIS BY ADDING THE CURRENT VALUE WITH THE STATBOOST VALUE
                                if statboost_num.sb_type == "STR" then
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 1), "", math.Round(math.max(0, statboost_num.num * 6) * ply:GetNWFloat(gl .. "bonus_hp_boost_mult", 1)), " HP BOOST", true, true, "+" .. ply:GetNWInt(gl .. "hp_boost", 0) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 2), "%", math.Truncate(statboost_num.num * 0.012, 3) * 100, " MAX HP Regen Overheal", true, true, "%" .. math.Truncate(ply:GetNWFloat(gl .. "max_overheal", 1.5), 2) * 100 .. " + " )
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 3), "%", string.format("%.1f", (statboost_num.num * 0.009) * 100), " DMG Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_damage", 0) * 100) .. " + " )                                
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 4), "%", string.format("%.1f", math.min(0.75, statboost_num.num * 0.015) * 100), " BLOCK DMG Reduction", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_block_resistance", 0) * 100) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 5), "", math.Truncate(math.max(0, (statboost_num.num / 40) * 3), 2), " HP REGEN/ s", true, true, ply:GetNWInt(gl .. "bonus_hp_regen", 1) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 6), "%", string.format("%.1f", (statboost_num.num * 0.045) * 100), " CRITICAL DMG", true, true, "%" .. string.format("%.1f", (1 + ply:GetNWFloat(gl .. "bonus_critical_damage", 0)) * 100) .. " + " )
                                elseif statboost_num.sb_type == "AGI" then
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 1), "%", string.format("%.1f", math.min(0.95, statboost_num.num * 0.0075) * 100), " DMG Reduction", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_resistance", 0) * 100) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 2), "", math.max(0, math.Round(statboost_num.num / 5)), " FLAT DMG Reduction", true, true, "+" .. ply:GetNWInt(gl .. "bonus_resistance_flat", 0) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 3), "%", string.format("%.1f", math.min(1, statboost_num.num * 0.006) * 100), " BLOCK Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_block_chance", 0) * 100) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 4), "%", string.format("%.1f", math.min(0.5, statboost_num.num * 0.0045) * 100), " EVASION Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_evasion_chance", 0) * 100) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 5), "%", string.format("%.1f", statboost_num.num * 0.007 * ply:GetNWFloat(gl .. "bonus_critical_chance_mult", 1) * 100), " CRITICAL Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_critical_chance", 0) * 100) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 6), "%", string.format("%.1f", math.min(5, statboost_num.num * 0.015) * 100), " MULTI HIT Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_multihit_chance", 0) * 100) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 7), "%", string.format("%.1f", math.min(10, statboost_num.num * 0.004) * 100), " Accuracy", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_accuracy", 0) * 100) .. " + " )
                                elseif statboost_num.sb_type == "INT" then
                                    gl_cse(ply, pos_x_mid, h * 0.625, "", math.max(0, statboost_num.num * 2), " MAX MANA", true, true, "+" .. ply:GetNWInt(gl .. "max_mana", 0) - 100 .. " + " )
                                    gl_cse(ply, pos_x_mid, h * 0.675, "", math.Truncate(statboost_num.num / 50, 3), " MANA REGEN/ 0.2s", true, true, "" .. ply:GetNWInt(gl .. "mana_regen", 1) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * 0.725, "%", string.format("%.1f", math.max(0, statboost_num.num * 0.03) * 100), " MANA DMG Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_mana_damage", 0) * 100) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * 0.775, "%", string.format("%.1f", math.min(0.85, statboost_num.num * 0.015) * 100), " MANA DMG Reduction", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_mana_resistance", 0) * 100) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * 0.825, "%", string.format("%.1f", statboost_num.num * 0.0015 * ply:GetNWFloat(gl .. "bonus_xp_mult", 1) * 100), " XP GAIN Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_xp_gain", 0) * 100) .. " + " )
                                    gl_cse(ply, pos_x_mid, h * 0.875, "%", string.format("%.1f", (1 - math.max(0.1, 1 - statboost_num.num * 0.0035)) * 100), " COOLDOWN Reduction", true, true, "%" .. string.format("%.1f", (1 - ply:GetNWFloat(gl .. "bonus_cooldown_mult", 0)) * 100) .. " + " )
                                end
                            elseif Choice.upgrade_type == "item_statboost" then
                                -- local modifier_num = ((1 + statboost_num.num +  math.min(Choice.stacks, 1) * Choice.statboost_increase_amount) / (1 + math.min(Choice.stacks, 1) * statboost_num.num))
                                local modifier_num = (1 + (statboost_num.num))
                                local modifier_divisor = (1 + (statboost_num.num - Choice.statboost_increase_amount) * math.Clamp(Choice.stacks, 0, 1))
                                -- print("name " .. Choice.tbl_upgrade.name)
                                -- print("statboost num " .. statboost_num.num)
                                -- print("increase amount " .. Choice.statboost_increase_amount)
                                -- print("stacks " .. Choice.stacks)
                                -- print("modifier num " .. modifier_num)
                                -- print("modifier_divisor " .. modifier_divisor)
                                -- print("")
                                
                                if string.lower(name.text) == "sword" then
                                    gl_cse(ply, pos_x_mid, h * 0.625, "%", math.Truncate(modifier_num * ply:GetNWFloat(gl .. "bonus_damage", 0) / modifier_divisor * 100, 2), " DMG Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_damage", 0) * 100) .. " > ")
                                elseif string.lower(name.text) == "crystal" then
                                    gl_cse(ply, pos_x_mid, h * 0.625, "", math.Round(ply:GetNWInt(gl .. "STR") / modifier_divisor * modifier_num), " STR", true, true, "" .. ply:GetNWInt(gl .. "STR") .. " > ")
                                    gl_cse(ply, pos_x_mid, h * 0.675, "", math.Round(ply:GetNWInt(gl .. "AGI") / modifier_divisor * modifier_num), " AGI", true, true, "" .. ply:GetNWInt(gl .. "AGI") .. " > ")
                                    gl_cse(ply, pos_x_mid, h * 0.725, "", math.Round(ply:GetNWInt(gl .. "INT") / modifier_divisor * modifier_num), " INT", true, true, "" .. ply:GetNWInt(gl .. "INT") .. " > ")
                                elseif string.lower(name.text) == "glasses" then
                                    gl_cse(ply, pos_x_mid, h * 0.625, "%", string.format("%.1f", ply:GetNWFloat(gl .. "bonus_critical_chance", 0) / modifier_divisor * modifier_num * 100), " CRITICAL Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_critical_chance", 0) * 100) .. " > ")
                                elseif string.lower(name.text) == "xp orb" then
                                    gl_cse(ply, pos_x_mid, h * 0.625, "%", string.format("%.1f", (1 + ((ply:GetNWFloat(gl .. "bonus_xp_gain", 1) - 1) / modifier_divisor * modifier_num)) * 100), " XP GAIN Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_xp_gain", 0) * 100) .. " > ")
                                elseif string.lower(name.text) == "muscles" then
                                    gl_cse(ply, pos_x_mid, h * 0.625, "+", math.Round(ply:GetNWInt(gl .. "hp_boost", 0) / modifier_divisor * modifier_num), " HP BOOST", true, true, "+" .. ply:GetNWInt(gl .. "hp_boost", 0) .. " > ")
                                end

                                if Choice.stacks < 1 then 
                                    gl_cse(ply, pos_x_mid, h * 0.5, statboost_num.item_string_operator, math.abs(statboost_num.item_additive + statboost_num.num) * statboost_num.item_modifier, "", true)
                                else 
                                    local number_addition = Choice.tbl_upgrade.number_addition

                                    if number_addition == 1 then 
                                        gl_cse(ply, pos_x_mid, h * 0.5, statboost_num.item_string_operator, math.abs(statboost_num.item_additive + statboost_num.num) * statboost_num.item_modifier, "", true, true, statboost_num.item_string_operator ..  (math.abs(statboost_num.item_additive + statboost_num.num) * statboost_num.item_modifier) - Choice.statboost_increase_amount .. " > ")
                                    else 
                                        gl_cse(ply, pos_x_mid, h * 0.5, statboost_num.item_string_operator, math.abs(statboost_num.item_additive + statboost_num.num) * statboost_num.item_modifier, "", true, true, statboost_num.item_string_operator ..  math.abs(statboost_num.item_additive + (1 - (1 - Choice.statboost_increase_amount)^(Choice.stacks))) .. " > ")
                                    end
                                end
                            elseif Choice.upgrade_type == "relic" then
                                if Choice.tbl_upgrade.mul_2 == nil then
                                    -- function gl_cse(ply, pos_x, pos_y, front_operator, numbers, short_desc, align_center_y, additional_front_text, front_text, rainbow, font, color)
                                    if Choice.tbl_upgrade.mul_is_debuff then
                                        gl_cse(ply, pos_x_mid, h * 0.625, Choice.mul * 100 .. "%", "", Choice.tbl_upgrade.shortdesc, false, false, "", false, nil, color_red)
                                    elseif Choice.tbl_upgrade.mul_is_second then
                                        gl_cse(ply, pos_x_mid, h * 0.625, Choice.mul .. "s", "", Choice.tbl_upgrade.shortdesc, false, false, "", false, nil)
                                    else
                                        gl_cse(ply, pos_x_mid, h * 0.625, Choice.mul * 100 .. "%", "", Choice.tbl_upgrade.shortdesc)
                                    end
                                elseif Choice.tbl_upgrade.mul_2 ~= nil then
                                    gl_cse(ply, pos_x_mid, h * 0.625, Choice.mul * 100 .. "%", "", Choice.tbl_upgrade.shortdesc)
                                    gl_cse(ply, pos_x_mid, h * 0.675, Choice.mul_2 * 100 .. "%", "", Choice.tbl_upgrade.shortdesc_2)
                                end
                            end
                        end

                        Choice.ishovered_transparency = 10

                        Choice.Paint = function(self, w, h)
                            draw.RoundedBox(6, w * 0.02, h * 0.013, w * 0.98, h * 0.98, color_black_alpha_100)
                            draw.RoundedBox(6, w * 0.01, h * 0.007, w * 0.98, h * 0.985, Color(35, 35, 35))

                            for i = 1, 5 do
                                surface.SetDrawColor(255, 255, 255)

                                if Choice.tbl_upgrade.upgrade_level >= i then
                                    surface.SetMaterial(Material("garlic_like/icon_star_yellow.png"))
                                else
                                    surface.SetMaterial(Material("garlic_like/icon_star_gray.png"))
                                end

                                surface.DrawTexturedRect((i * w * 0.1) + w * 0.15, h * 0.03, w * 0.1, w * 0.1)
                            end

                            if not self:IsDown() then
                                if self:IsHovered() and Choice.color_rarity_border ~= nil then
                                    Choice.ishovered_transparency = 10
                                end

                                if not self:IsHovered() and Choice.ishovered_transparency > 0 then
                                    Choice.ishovered_transparency = math.Approach(Choice.ishovered_transparency, 0, 3)
                                    -- print(Choice.ishovered_transparency)
                                end

                                draw.RoundedBox(6, w * 0.01, h * 0.007, w * 0.98, h * 0.985, Color(Choice.color_rarity_border.r, Choice.color_rarity_border.g, Choice.color_rarity_border.b, Choice.ishovered_transparency))
                            end

                            if self:IsDown() and Choice.color_rarity_border ~= nil then
                                draw.RoundedBox(6, w * 0.01, h * 0.007, w * 0.98, h * 0.985, Color(Choice.color_rarity_border.r, Choice.color_rarity_border.g, Choice.color_rarity_border.b, 20))
                            end

                            draw.RoundedBox(6, w * 0.01, h * 0.007, w * 0.98, h * 0.985, Color(Choice.color_rarity_border.r, Choice.color_rarity_border.g, Choice.color_rarity_border.b, Choice_transparency)) 
                        end

                        Choice.DoClick = function(self)                        
                            garlic_like_choose_upgrade(ply, true, name.text, statboost_num.num, Choice.rarity, Choice.tbl_upgrade, Choice.damage, Choice.cooldown, Choice.area, Choice.mul, Choice.mul_2)
                            BASEPANEL:Remove()

                            for k, v in pairs(FROZE_GL.choice_panels) do
                                v:Remove()
                            end
                        end

                        table.insert(FROZE_GL.choice_panels, Choice)
                    end)
                end

                local text_title = vgui.Create("DLabel", BASEPANEL, gl .. "Text_1")
                text_title:SetSize(W * 0.5, H * 0.2)
                text_title:SetPos(0, H * 0.04)
                text_title:CenterHorizontal()
                text_title:SetFont(gl .. "font_title")
                text_title:SetText("")

                text_title.Paint = function(self, w, h)
                    draw.SimpleText("Choose Upgrade", gl .. "font_title", w * 0.5, h * 0.1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                reroll_button:SetSize(W * 0.15, H * 0.05)
                reroll_button:Center()
                reroll_button:SetY(H + H * 0.05)
                reroll_button:SetText("") 
                reroll_button.but_color = Color(25, 25, 25, 255)
                reroll_button.but_highlight_color = Color(155, 155, 155, 0)
                reroll_button:MakePopup()
                reroll_button:Hide()

                reroll_button.Paint = function(self, w, h)             
                    draw.RoundedBox(6, 0, 0, w, h, self.but_color)
                    draw.DrawText("REROLL " .. "(x" .. BASEPANEL.reroll_chances .. ")", gl .. "reroll_button_text", w * 0.5, h * 0.24, color_white, TEXT_ALIGN_CENTER)

                    if self:IsHovered() then 
                        reroll_button.but_highlight_color.a = 75            
                    else 
                        reroll_button.but_highlight_color.a = math.max(0, reroll_button.but_highlight_color.a - RealFrameTime() * 755)
                    end

                    if self:IsDown() then 
                        reroll_button.but_highlight_color.a = 150
                    end

                    draw.RoundedBox(6, 0, 0, w, h, self.but_highlight_color)
                end

                reroll_button.DoClick = function(self) 
                    if self.on_cooldown then return end 
                    --
                    -- PrintTable(FROZE_GL.choice_panels)

                    -- for k, panel in pairs(FROZE_GL.choice_panels) do 
                    --     create_upgrade_choice(panel)
                    -- end

                    -- lower_highlight_transparency()

                    self:Hide()
                    self:SetY(H + H * 0.05)
                    BlackBG:Remove()

                    for k, v in pairs(FROZE_GL.choice_panels) do
                        v:Remove()
                    end

                    create_choices() 

                    BASEPANEL.reroll_chances = BASEPANEL.reroll_chances - 1

                    self.on_cooldown = true 

                    timer.Simple(1.75, function() 
                        if self and IsValid(self) then 
                            self.on_cooldown = false
                        end
                    end)
                end
            end

            create_choices()
            -- timer.Simple(3, function()
            --     BlackBG:Remove()
            --     for k, v in pairs(FROZE_GL.choice_panels) do
            --         v:Remove()
            --     end
            -- end)
            do
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
            
            for i = 1, amount do 
                for k, v in ipairs(FROZE_GL.tbl_valid_inventory_items) do 
                    if v.name == name then 
                        local chest_drops = nil 

                        if v.chest_drops then 
                            chest_drops = v.chest_drops
                        end

                        FROZE_GL.tbl_menu_inventory.consumables[#FROZE_GL.tbl_menu_inventory.consumables + 1] = {
                            name = v.name,
                            chest_drops = chest_drops,
                            icon_mat = v.icon_mat,
                            icon_mat_string = v.icon_mat:GetName(), 
                            rarity = v.rarity,
                        }    
                    end
                end                             
            end
        end

        function garlic_like_pause_game_toggle() 
            if not game.SinglePlayer() then return end 

            net.Start(gl .. "pause_game_cl_to_sv")
            net.SendToServer() 
        end

        function tonumber_bool(bool) 
            if bool then 
                return 1
            else
                return 0
            end
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

    garlic_like_init() 
    garlic_like_create_fonts()
    garlic_like_animated_xp_fonts_create()

    --* net receive 
    do 
        net.Receive(gl .. "send_chat_message_sv_to_cl", function(len, ply) 
            local text = net.ReadString() 
            chat.AddText(text)
        end)

        net.Receive(gl .. "broadcast_particles", function(len, ply)
            local argument = net.ReadString() 
            -- 
            RunConsoleCommand(gl .. "debug_show_achievement_unlock", argument)
        end)

        net.Receive(gl .. "broadcast_particles", function(len, ply)
            local ent = net.ReadEntity()
            local order = net.ReadString()
            local name = net.ReadString()
            if not IsValid(ent) then return end
            --
            if order == "ATTACH" then 
                ParticleEffectAttach(name, PATTACH_POINT_FOLLOW, ent, 0)
            elseif order == "STOP" then 
                ent:StopParticlesNamed(name)
            end
        end)

        net.Receive(gl .. "cooldowns_update", function(len, ply)
            local ply = LocalPlayer()
            local temp_skills = net.ReadTable()
            FROZE_GL.skills = temp_skills

            if not IsValid(ply) or not IsValid(ply:GetActiveWeapon()) then return end

            garlic_like_update_cooldowns_weapon(ply, ply:GetActiveWeapon():GetClass())
            -- PrintTable(FROZE_GL.skills)
        end)

        net.Receive(gl .. "cooldown_speed_increase", function(len, ply)
            local ply = LocalPlayer()
            local wep_name = net.ReadString()
            garlic_like_update_cooldowns_weapon(ply, wep_name)
        end)
        
        --! SYNC CLIENTSIDE held_num WITH SERVERSIDE PData and NWInt
        net.Receive(gl .. "update_database_sv_to_cl", function(len, ply)
            local ply = net.ReadEntity()
            local order_type = net.ReadString()
            local item_name = net.ReadString()
            local item_rarity = net.ReadString()
            local item_num = net.ReadInt(32) 
            local show_notification = net.ReadBool()

            if order_type == "food" or order_type == "powerup" then return end 

            if order_type == "update_gold" then
                for i = 1, 60 do
                    timer.Simple(i / 600, function()
                        if i < 30 then
                            gold_notification_font = gl .. "font_money_" .. math.max(1, 30 - i)
                        else
                            gold_notification_font = gl .. "font_money_" .. math.Clamp(i - 30, 1, 30)
                        end
                    end)
                end
            elseif order_type == "update_shop" then
                -- print("UPDATE TABLE ON RESPAWN")
                -- ply = net.ReadEntity()
                -- temp_table = garlic_like_load_json_to_table(ply, gl .. "upgrades.json", FROZE_GL.garlic_like_upgrades)
                -- for k, upgrade in SortedPairs(FROZE_GL.garlic_like_upgrades) do
                --     upgrade.upgrade_level = temp_table[k].upgrade_level
                -- end
                return
            elseif order_type == "update_held_num_ores" then 
                -- print("updated " .. item_name .. " amount!")

                for k, entry in ipairs(FROZE_GL.WepCrystalsInventory) do
                    if entry.rarity == item_rarity or entry.name == item_name then
                        entry.held_num = math.max(0, entry.held_num + item_num)
                        -- print(gl .. "held_num_material_" .. FROZE_GL.rarities[k]) 
                        ply:SetPData(gl .. "held_num_material_" .. string.lower(entry.rarity), entry.held_num)

                        if show_notification then 
                            RunConsoleCommand(gl .. "debug_item_pickup_test", entry.name, item_num, item_rarity, "ore")
                        end
                    end
                end  
            elseif order_type == "update_held_num_materials" then 
                for name, entry in pairs(FROZE_GL.tbl_materials_inventory) do
                    if name == item_name then
                        entry.held_num = math.max(0, entry.held_num + item_num)

                        if show_notification then 
                            RunConsoleCommand(gl .. "debug_item_pickup_test", item_name, item_num, item_rarity, "material")
                        end
                    end
                end
            elseif order_type == "load_saved_held_num_material" then
                -- print("ORDER TYPE IS TO LOAD MATERIALS!!!")
                -- print("ORDER TYPE IS TO LOAD MATERIALS!!!")
                -- print("ORDER TYPE IS TO LOAD MATERIALS!!!")
                -- print("ORDER TYPE IS TO LOAD MATERIALS!!!")
                -- print("ORDER TYPE IS TO LOAD MATERIALS!!!")
                -- print("ITEM NUM IS: " .. item_num)

                for k, entry in ipairs(FROZE_GL.WepCrystalsInventory) do
                    if entry.rarity == item_rarity then 
                        -- print(ply:GetPData("garlic_like_held_num_material_common", 0))
                        ply:SetPData(gl .. "held_num_material_" .. string.lower(entry.rarity), item_num)
                        entry.held_num = tonumber(ply:GetPData(gl .. "held_num_material_" .. string.lower(entry.rarity)))
                        -- entry.held_num = ply:GetNWInt(gl .. "held_num_material_" .. string.lower(entry.rarity))
                        -- PrintTable(entry)
                    end
                end

                for name, entry in pairs(FROZE_GL.tbl_materials_inventory) do
                    if name == item_name then 
                        ply:SetPData(gl .. "held_num_material_" .. name, item_num)
                        entry.held_num = tonumber(ply:GetPData(gl .. "held_num_material_" .. name))
                        -- entry.held_num = ply:GetNWInt(gl .. "held_num_material_" .. name)
                        -- PrintTable(entry)
                    end
                end
            end

            --* add rarrities to FROZE_GL.WepCrystalsInventory !--
            -- PrintTable(FROZE_GL.WepCrystalsInventory)
        end)

        net.Receive(gl .. "update_skills_held_table", function(len, ply)
            local upgrade_name = net.ReadString()
            local new_cooldown = net.ReadFloat()

            for k, upgrade in SortedPairs(FROZE_GL.skills_held) do
                if upgrade.name2 == upgrade_name then
                    upgrade.cooldown = math.Truncate(new_cooldown, 2)
                end
            end
        end)

        net.Receive(gl .. "run_console_command_sv_to_cl", function(len, ply) 
            local command = net.ReadString() 
            local arg = net.ReadString() 
            -- 
            RunConsoleCommand(command, arg)
        end)

        net.Receive(gl .. "update_unlockables_sv_to_cl", function(len, ply)
            local ply = LocalPlayer()
            local id = net.ReadString() 
            -- print("CLIENT: UNLOCKED UNLOCKABLE!!!")
            -- print(id)
            -- PrintTable(FROZE_GL.tbl_gl_unlockables)
            -- 
            ply:SetPData(id .. "_unlocked", true)

            FROZE_GL.tbl_gl_unlockables[id].unlock_status = true
        end)

        net.Receive(gl .. "reset_cl", function(len, ply)
            local ply = LocalPlayer()
            garlic_like_create_upgrade_table()
            FROZE_GL.tbl_run_end_screen_2.rank_num = tonumber(ply:GetPData(gl .. "rank_num", 1))
            FROZE_GL.tbl_run_end_screen_2.rank_xp_current = tonumber(ply:GetPData(gl .. "rank_xp_current", 1))
            FROZE_GL.tbl_run_end_screen_2.rank_xp_to_rank_up = tonumber(ply:GetPData(gl .. "rank_xp_to_rank_up", 1))
            FROZE_GL.ply_level = 0
            FROZE_GL.xp = 0
            FROZE_GL.xp_total = 0
            FROZE_GL.xp_to_next_level = 100
            FROZE_GL.pending_level_ups = 0
            FROZE_GL.items_held = {}
            FROZE_GL.skills_held = {}
            FROZE_GL.relics_held = {}
            FROZE_GL.item_circle_colors[1] = color_white
            FROZE_GL.item_circle_colors[2] = color_white
            FROZE_GL.item_circle_colors[3] = color_white
            FROZE_GL.item_circle_colors[4] = color_white
            FROZE_GL.skill_circle_colors = {
                [1] = color_white,
                [2] = color_white,
                [3] = color_white,
                [4] = color_white
            }
        end)

        net.Receive(gl .. "enemy_upgrade_broadcast", function(len, ply)
            chat.AddText(Color(255, 0, 119), "As time passes, enemies have become more powerful!")
            chat.AddText("Enemy HP  : x" .. string.format("%.2f", 1 + GetGlobalFloat(gl .. "enemy_modifier_hp"), 0))
            chat.AddText("Enemy DMG : x" .. string.format("%.2f", 1 + GetGlobalFloat(gl .. "enemy_modifier_damage"), 0))
            chat.AddText("Enemy RES : x" .. string.format("%.2f", 1 - GetGlobalFloat(gl .. "enemy_modifier_resistance"), 0))
            garlic_like_enemies_empowered_hud_show()
        end)

        net.Receive(gl .. "xp_gained", function(len, ply)
            -- print("RECEIVED XP")
            local ply = LocalPlayer()
            local xp_amount = net.ReadInt(32)
            surface.PlaySound("garlic_like/mm_xp_chime.wav")
            FROZE_GL.xp = math.floor(xp_amount * (ply:GetNWFloat(gl .. "bonus_xp_gain", 1)))
            FROZE_GL.xp_cumulative = FROZE_GL.xp_cumulative + FROZE_GL.xp
            xp_type = net.ReadString()
            FROZE_GL.xp_total = FROZE_GL.xp_total + FROZE_GL.xp

            -- print("xp_amount: " .. xp_amount)
            -- print("FROZE_GL.xp " .. FROZE_GL.xp)

            if xp_type == "HEADSHOT" then
                FROZE_GL.xp_text = "HEADSHOT!"
                table.insert(FROZE_GL.xp_texts, 1, FROZE_GL.xp_text)
                -- FROZE_GL.xp_texts[1] = FROZE_GL.xp_text
                -- FROZE_GL.xp_texts[1] = FROZE_GL.xp_text
                -- timer.Simple(0.5, function()
                --     FROZE_GL.xp_texts[#FROZE_GL.xp_texts] = ""
                -- end)
            elseif xp_type == "KILL" then
            end

            -- table.insert(FROZE_GL.xp_texts, 1, "")
            local function garlic_like_level_up_cl(ply, ply_level, xp_to_next_level)
                -- garlic_like_show_level_up_screen(ply)
                -- surface.PlaySound("garlic_like/mm_rank_up_achieved.wav")
                -- surface.PlaySound("garlic_like/level_up_skyrim.wav")
                surface.PlaySound("garlic_like/level_up_disgaea_2.wav")
                ply:ScreenFade(SCREENFADE.IN, Color(252, 255, 98, 30), 0.3, 0)
                net.Start(gl .. "update_ply_info")
                net.WriteEntity(ply)
                net.WriteInt(FROZE_GL.ply_level, 32)
                net.WriteInt(FROZE_GL.xp_to_next_level, 32)
                net.SendToServer()
            end

            -- LEVEL UP
            -- print("FROZE_GL.xp_total: " .. FROZE_GL.xp_total)
            -- print("FROZE_GL.xp_to_next_level: " .. FROZE_GL.xp_to_next_level)

            if FROZE_GL.xp_total >= FROZE_GL.xp_to_next_level then
                local i = 1

                while FROZE_GL.xp_total >= FROZE_GL.xp_to_next_level do
                    FROZE_GL.ply_level = FROZE_GL.ply_level + 1
                    FROZE_GL.pending_level_ups = FROZE_GL.pending_level_ups + 1
                    FROZE_GL.xp_total = FROZE_GL.xp_total - FROZE_GL.xp_to_next_level
                    FROZE_GL.xp_to_next_level = math.Round(FROZE_GL.xp_to_next_level * 1.05 + 100 * (1.1 + FROZE_GL.ply_level / 10))

                    if i == 1 then
                    elseif i >= 2 then
                        garlic_like_level_up_cl(ply, FROZE_GL.ply_level, FROZE_GL.xp_to_next_level)

                        timer.Simple(i / 3, function()
                            FROZE_GL.ply_level = FROZE_GL.ply_level + 1
                        end)
                    end

                    garlic_like_level_up_cl(ply, FROZE_GL.ply_level, FROZE_GL.xp_to_next_level)
                    i = i + 1
                end
            end

            FROZE_GL.xp_bar_width = math.Remap(FROZE_GL.xp_total, 0, FROZE_GL.xp_to_next_level, 0, W * 0.5)
            color_yellow = Color(255, 238, 0, 255)
            -- table.insert(xp_numbers, 1, xp)
            FROZE_GL.xp_numbers[1] = FROZE_GL.xp_cumulative

            if #FROZE_GL.xp_numbers > 6 then
                FROZE_GL.xp_numbers[#FROZE_GL.xp_numbers] = nil
            end

            if #FROZE_GL.xp_texts > 6 then
                FROZE_GL.xp_texts[#FROZE_GL.xp_texts] = nil
            end

            -- PrintTable(FROZE_GL.xp_numbers)
            FROZE_GL.fading_out = false

            if GetConVar(gl .. "hud_xp_notification_animation"):GetInt() > 0 then
                for i = 1, 30 do
                    timer.Simple(i / 300, function()
                        FROZE_GL.xp_notification_font = gl .. "xp_notification_" .. i
                        xp_notification_font_extra = gl .. "xp_notification_extra_" .. i
                    end)
                end
            end

            timer.Create(gl .. "fade_out_text", 1.5, 1, function()
                FROZE_GL.fading_out = true

                for i = 1, 255 do
                    timer.Simple(i / 900, function()
                        if not FROZE_GL.fading_out then return end
                        color_yellow = Color(255, 238, 0, 255 - i)

                        if i == 255 then
                            FROZE_GL.xp_numbers = {}
                            FROZE_GL.xp_texts = {}
                            FROZE_GL.xp_cumulative = 0
                        end
                    end)
                end
            end)
        end)

        net.Receive(gl .. "open_weapon_crate", function(len, ply)
            local rarity = net.ReadString()
            garlic_like_open_weapon_crate_menu(rarity)
        end) 

        net.Receive(gl .. "show_gold_popup_sv_to_cl", function(len, ply)
            local gold_gained = net.ReadInt(32)
            local entity_killed = net.ReadEntity()
            --
            if not IsValid(entity_killed) then return end
            --
            local entity_obbmaxs = entity_killed:OBBMaxs() 
            local entity_obbcenter = entity_killed:OBBCenter()
            local entity_pos = entity_killed:LocalToWorld(Vector(entity_obbcenter.x, entity_obbcenter.y, entity_obbmaxs.z))
            --
            FROZE_GL.tbl_gold_popups[#FROZE_GL.tbl_gold_popups + 1] = {
                gold_amount = gold_gained, 
                gold_shown = 0,
                pos_ent = entity_pos,
                pos_2d = entity_pos:ToScreen(),  
                pos_y_mod = 0,
                pos_x_mod = 0,
                lifetime = 0, 
                move_to_hl_icon_pos = false,
                color = Color(255, 255, 255, 0),
                combined_distance = 0,
            } 
        end) 

        net.Receive(gl .. "reset_unlockables_sv_to_cl", function(len, ply) 
            -- print("ALL UNLOCKABLES LOCKED AGAIN!")
            local ply = LocalPlayer()
            
            for k, v in pairs(FROZE_GL.tbl_character_stats) do 
                if v.unlock_condition then                 
                    ply:SetPData(v.id .. "_unlocked", false)
                end
            end

            for i = 1, 8 do 
                ply:SetPData(gl .. "relic_slot_" .. i .. "_unlocked", false)
            end

            ply:SetNWInt(gl .. "relic_slots_unlocked", 0)
        end)

        net.Receive(gl .. "send_match_stats_sv_to_cl", function(len, ply)   
            FROZE_GL.tbl_run_end_screen = { 
                res_t_life = 0,
                bg_color = Color(0, 0, 0, 0),
                res_size_num = 60,
                mat_flare = Material("garlic_like/lens_flare_1.png"),
                flare_w = W * 0.3, 
                flare_h = H * 0.45,
                flare_a = 255, 
                color_yellow = Color(255, 196, 0),
                time_survived_min = net.ReadInt(32),
                time_survived_seconds = net.ReadInt(32), 
                gold_gained = net.ReadInt(32),
                level_reached = net.ReadInt(32),
                enemy_hp_mult = net.ReadFloat(),
                enemy_dmg_mult = net.ReadFloat(),
                enemy_dr_mult = net.ReadFloat(),
                enemy_eva_mult = net.ReadFloat(),
                total_dmg_dealt = net.ReadInt(32),
                total_dmg_taken = net.ReadInt(32),
                highest_dmg = net.ReadInt(32),    
                rank_xp_gained = net.ReadInt(32),
                total_seconds = 0,
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

            local tbl = FROZE_GL.tbl_run_end_screen 
            tbl.total_seconds = tbl.total_seconds + tbl.time_survived_min * 60 + tbl.time_survived_seconds 
            
            FROZE_GL.run_end_screen_stop_showing = false

            -- PrintTable(FROZE_GL.tbl_run_end_screen)
        end)

        net.Receive(gl .. "send_damage_numbers_sv_to_cl", function(len, ply)   
            local pos = net.ReadVector() 
            local dmg = net.ReadInt(32) 
            local ent = net.ReadEntity()  
            local maxdamage = net.ReadInt(32)  
            local customtype = net.ReadInt(32)

            if dmg <= 0 and customtype ~= 1853 then return end

            print("customtye: " .. customtype)

            if customtype == 1853 then 
                dmg = "MISSED!"
            end

            local data = {
                pos = pos, 
                dmg = dmg,
                ent = ent,
                vel = Vector(math.random(90, -90), math.random(90, -90), math.random(75, 100)),
                color = Color(255, 255, 255, 255),
                lifetime_lived = 0,
                size_i = 30,
                font_name = "font_damage_number_"
            }

            if maxdamage == 876523 then  
                data.color = Color(59, 220, 0)
            elseif maxdamage == 876522 then
                data.color = Color(255, 152, 43)
            elseif maxdamage == 876524 then
                data.color = Color(41, 162, 255)
            elseif maxdamage == 884251 then
                data.color = Color(147, 147, 147)
            end

            if customtype and customtype > 7300 then 
                local tier = customtype - 7313
                data.font_name = "font_damage_number_crit_tier_" .. tier .. "_"
                data.dmg = data.dmg .. "!"
                
                if tier == 1 then 
                    data.color = Color(255, 242, 0)
                elseif tier == 2 then 
                    data.color = Color(255, 106, 0)
                elseif tier == 3 then 
                    data.color = Color(255, 0, 0)
                elseif tier == 4 then 
                    data.color = Color(153, 0, 255)
                elseif tier >= 5 then 
                    data.color = Color(255, 0, 191)
                end
            end
            
            table.insert(FROZE_GL.tbl_damage_numbers, #FROZE_GL.tbl_damage_numbers + 1, data)

            timer.Simple(2, function() 
                FROZE_GL.tbl_damage_numbers[1] = nil 
                FROZE_GL.tbl_damage_numbers = table.ClearKeys(FROZE_GL.tbl_damage_numbers)
            end)
        end)
 
        net.Receive(gl .. "update_tbl_valid_wep_sv_to_cl", function(len, ply) 
            timer.Simple(0.1, function() 
                garlic_like_update_tbl_valid_weapons()
            end)

            chat.AddText(Color(255, 255, 255), "Up to POWER ", Color(255, 100, 100), tostring(GetGlobalInt(gl .. "wep_power_limit", 10000)), Color(255, 255, 255), " weapons are now able to appear in weapon boxes!")
        end)
    end

    --* hooks 
    do 
        hook.Add("InitPostEntity", gl .. "initialize", function()
            timer.Simple(0.25, function() 
                garlic_like_init()
            end)
        end)

        hook.Add("Initialize", gl .. "initialize_cooldowns", function()
            --* used for weapon cooldown increase
            timer.Simple(3, function()
                FROZE_GL.skills = {
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
            end)
        end) 

        hook.Add("OnEntityCreated", gl .. "item_drop_insert_entity", function(ent)
            if not GetConVar(gl .. "enable"):GetBool() then return end 

            timer.Simple(0.1, function()
                if not IsValid(ent) then return end 
                local class = ent:GetClass()

                timer.Simple(0.2, function()
                    if not IsValid(ent) then return end 
                    if ent:GetClass() == gl .. "crystal_cluster" and FROZE_GL.tbl_crystal_clusters[ent:GetNWString(gl .. "item_rarity")] then 
                        table.insert(FROZE_GL.tbl_crystal_clusters[ent:GetNWString(gl .. "item_rarity")], 1, ent)
                        -- PrintTable(FROZE_GL.tbl_crystal_clusters)
                    end
                end)

                if table.HasValue(FROZE_GL.tbl_gl_entities, ent:GetClass()) or string.find(class, "acwatt") or string.find(class, "item_") then  
                    if #FROZE_GL.garlic_like_item_drops_entities > 0 then
                        FROZE_GL.garlic_like_item_drops_entities = table.ClearKeys(FROZE_GL.garlic_like_item_drops_entities)
                    end

                    table.insert(FROZE_GL.garlic_like_item_drops_entities, ent)
                end
            end)
        end)

        hook.Add("EntityRemoved", gl .. "item_drop_remove_from_table", function(ent)
            if not GetConVar(gl .. "enable"):GetBool() then return end 

            if ent:GetClass() == gl .. "crystal_cluster" then  
                for k, v in pairs(FROZE_GL.tbl_crystal_clusters) do 
                    for k2, v2 in pairs(v) do 
                        if v2 == ent then 
                            FROZE_GL.tbl_crystal_clusters[ent:GetNWString(gl .. "item_rarity")][k2] = nil
                            FROZE_GL.tbl_crystal_clusters[ent:GetNWString(gl .. "item_rarity")] = table.ClearKeys(FROZE_GL.tbl_crystal_clusters[ent:GetNWString(gl .. "item_rarity")])
                        end
                    end
                end
                -- PrintTable(FROZE_GL.tbl_crystal_clusters)
            end

            for k, ent_entry in pairs(FROZE_GL.garlic_like_item_drops_entities) do
                if ent_entry == ent then
                    FROZE_GL.garlic_like_item_drops_entities[k] = nil
                end
            end

            if #FROZE_GL.garlic_like_item_drops_entities > 0 then
                FROZE_GL.garlic_like_item_drops_entities = table.ClearKeys(FROZE_GL.garlic_like_item_drops_entities)
            end
        end)

        hook.Add("PostDrawTranslucentRenderables", gl .. "item_floating_labels", function()
            if #FROZE_GL.garlic_like_item_drops_entities < 1 then return end
            --
            -- PrintTable(FROZE_GL.garlic_like_item_drops_entities)
            local ply = LocalPlayer() 

            for k, ent in pairs(FROZE_GL.garlic_like_item_drops_entities) do
                if not ent:GetNWBool(gl .. "settled_2") then continue end
                if ent:GetNWBool(gl .. "is_being_picked_up") then continue end
                --
                local angles = ply:EyeAngles()
                local obbcenter = ent:LocalToWorld(ent:OBBCenter())
                local basepos = ent:GetPos()
                local pos = Vector(basepos.x, basepos.y, basepos.z)
                local rarity = ent:GetNWString(gl .. "item_rarity")
                local rarity_color = FROZE_GL.tbl_rarity_colors[rarity]
                local beam_start = pos + Vector(0, 0, 10)
                local beam_end = pos + Vector(0, 0, math.Remap(garlic_like_rarity_to_num(rarity), 1, 7, 100, 175))
                --
                render.SetMaterial(FROZE_GL.mat_beam)

                if ent:GetClass() == "garlic_like_station_weapon_upgrade" or ent:GetClass() == gl .. "station_item_fusing" then 
                    -- do nothing
                else
                    render.DrawBeam(beam_start, beam_end, 1, 0, 1, rarity_color)
                end

                if not rarity then 
                    rarity = "common"
                end
                
                cam.Start3D2D(Vector(obbcenter.x, obbcenter.y, ent:LocalToWorld(ent:OBBMaxs()).z + 40), Angle(0, angles.y - 90, 90), 0.5)  
                
                if ent:GetClass() == gl .. "wep_crystal" then 
                    local amount = " x" .. ent:GetNWInt(gl .. "item_amount", 1)

                    if ent:GetNWBool(gl .. "is_food") or ent:GetNWBool(gl .. "is_powerup") then 
                        amount = ""
                    end

                    if rarity_color == nil then 
                        rarity_color = color_white
                    end

                    draw.WordBox(4, 0, 0, ent:GetNWString(gl .. "item_name") .. amount, gl .. "font_subtitle", color_black_alpha_200, rarity_color, TEXT_ALIGN_CENTER)
                else 
                    if not rarity_color then 
                        rarity_color = color_white
                    end
                    
                    local name = ent:GetNWString(gl .. "item_name")

                    if (not name or name == "") and ent.PrintName then 
                        name = ent.PrintName
                    end

                    if not ent:IsScripted() then 
                        name = language.GetPhrase(ent:GetClass())
                    end

                    draw.WordBox(4, 0, 0, name, gl .. "font_subtitle", color_black_alpha_200, rarity_color, TEXT_ALIGN_CENTER)
                end

                cam.End3D2D()
            end
        end) 

        hook.Add("Think", gl .. "detect_key_combinations", function()
            if not GetConVar(gl .. "enable"):GetBool() then return end 
            ply = LocalPlayer()

            if ply:KeyDown(IN_DUCK) and ply:KeyDown(IN_ATTACK) and ply:KeyDown(IN_ATTACK2) then
                -- print("EXECUTING ULT")
                if FROZE_GL.tbl_ult.ult_cooldown > 0 and (FROZE_GL.tbl_ult.ult_clicked == nil or not FROZE_GL.tbl_ult.ult_clicked) then
                    FROZE_GL.tbl_ult.ult_clicked = true
                    -- print("ULTIMATE STILL ON COOLDOWN!")
                    surface.PlaySound("garlic_like/deny_cooldown.wav")

                    timer.Simple(0.75, function()
                        FROZE_GL.tbl_ult.ult_clicked = false
                    end)

                    return
                elseif FROZE_GL.tbl_ult.ult_cooldown <= 0 and not FROZE_GL.tbl_ult.ult_clicked then
                    FROZE_GL.tbl_ult.ult_clicked = true
                    FROZE_GL.tbl_ult.ult_key_combo_activated = true
                    FROZE_GL.tbl_ult.ult_cooldown = 300
                    FROZE_GL.tbl_ult.ult_starttime = RealTime()
                    ply:ConCommand(gl .. "spawn_tf2_ultimate_base_entity")

                    timer.Simple(0.75, function()
                        FROZE_GL.tbl_ult.ult_clicked = false
                    end)

                    timer.Simple(0.75, function()
                        FROZE_GL.tbl_ult.ult_key_combo_activated = false
                    end)
                end
            end
        end)   

        hook.Add("DrawDeathNotice", gl .. "death_notice", function(x, y) 
            if GetConVar(gl .. "enable"):GetBool() then return 0, 0 end 
    
        end)

        hook.Add("HUDPaint", gl .. "test", function() 
            -- if not b then return end 
            -- draw.RoundedBox(0, W * 0.5, H * 0.5, W * 0.3, H * 0.1, color_black)
            -- garlic_like_draw_scaled("The quick borwn fox jumps over the lazy dog The quick borwn fox jumps over the lazy dog The quick borwn fox jumps over the lazy dog The quick borwn fox jumps over the lazy dog\nThe quick borwn fox jumps over the lazy dog The quick borwn fox jumps over the lazy dog", W * 0.5, H * 0.5, W * 0.35, "Default", "Arial", color_white, TEXT_ALIGN_LEFT)
            
            -- garlic_like_draw_multi_line(sample_tbl, W * 0.5, H * 0.5, color_black_alpha_200)
        end)

        hook.Add("HUDPaint", gl .. "unlockables_popups", function() 
            if not GetConVar(gl .. "enable"):GetBool() then return end  
            if table.IsEmpty(FROZE_GL.tbl_unlocks_queue) then return end 
            local ply = LocalPlayer() 
            local RFT = RealFrameTime()  

            FROZE_GL.tbl_unlocks_hud.text = FROZE_GL.tbl_unlocks_queue[1]
            -- print(FROZE_GL.tbl_unlocks_hud.text)

            draw.RoundedBox(4, FROZE_GL.tbl_unlocks_hud.pos_x_bg, FROZE_GL.tbl_unlocks_hud.pos_y_bg, FROZE_GL.tbl_unlocks_hud.w_bg, FROZE_GL.tbl_unlocks_hud.h_bg, color_black_alpha_200)
            draw.RoundedBoxEx(4, FROZE_GL.tbl_unlocks_hud.pos_x_bg, FROZE_GL.tbl_unlocks_hud.pos_y_bg, FROZE_GL.tbl_unlocks_hud.w_bg, FROZE_GL.tbl_unlocks_hud.h_bg * 0.3, color_black, true, true, false, false)
            draw.DrawText("UNLOCKED!", gl .. "font_title_3", FROZE_GL.tbl_unlocks_hud.pos_x_bg + FROZE_GL.tbl_unlocks_hud.w_bg / 2, FROZE_GL.tbl_unlocks_hud.pos_y_bg, color_white, TEXT_ALIGN_CENTER)
            draw.DrawText(FROZE_GL.tbl_unlocks_hud.text, gl .. "font_subtitle_2", FROZE_GL.tbl_unlocks_hud.pos_x_bg + FROZE_GL.tbl_unlocks_hud.w_bg / 2, FROZE_GL.tbl_unlocks_hud.pos_y_bg + H * 0.06, color_white, TEXT_ALIGN_CENTER)

            if FROZE_GL.tbl_unlocks_hud.lifetime > 3 then 
                FROZE_GL.tbl_unlocks_hud.pos_y_bg = math.Approach(FROZE_GL.tbl_unlocks_hud.pos_y_bg, -H * 0.12, RFT * H * 0.3)

                if FROZE_GL.tbl_unlocks_hud.pos_y_bg <= -H * 0.12 then 
                    FROZE_GL.tbl_unlocks_hud.isrunning = false
                    FROZE_GL.tbl_unlocks_queue[1] = nil 
                    FROZE_GL.tbl_unlocks_queue = table.ClearKeys(FROZE_GL.tbl_unlocks_queue)
                    
                    FROZE_GL.tbl_unlocks_hud = {
                        pos_x_bg = W * 0.77, 
                        pos_y_bg = -H * 0.12, 
                        target_pos_x_bg = W * 0.77, 
                        target_pos_y_bg = H * 0.01, 
                        w_bg = W * 0.22, 
                        h_bg = H * 0.12,
                        lifetime = 0,
                        text = FROZE_GL.tbl_unlocks_queue[1],
                        show = true,
                        isrunning = true,
                        audioplayed = false,
                    } 
                    -- print("RETURNED TO ORIGINAL POS!!!")
                end
            else 
                if not FROZE_GL.tbl_unlocks_hud.audioplayed then 
                    FROZE_GL.tbl_unlocks_hud.audioplayed = true
                    surface.PlaySound("garlic_like/achievement_sound.wav")
                end

                FROZE_GL.tbl_unlocks_hud.isrunning = true
                FROZE_GL.tbl_unlocks_hud.pos_y_bg = math.Approach(FROZE_GL.tbl_unlocks_hud.pos_y_bg, FROZE_GL.tbl_unlocks_hud.target_pos_y_bg, RFT * H * 0.3)
            end

            FROZE_GL.tbl_unlocks_hud.lifetime = FROZE_GL.tbl_unlocks_hud.lifetime + RFT  
            -- print(FROZE_GL.tbl_unlocks_hud.lifetime) 
        end)

        hook.Add("HUDPaint", gl .. "gold_popups", function() 
            if not GetConVar(gl .. "enable"):GetBool() then return end 
            if #FROZE_GL.tbl_gold_popups < 1 then return end 
            --
            local RFT = RealFrameTime()

            -- PrintTable(FROZE_GL.tbl_gold_popups)
            
            for k, data in pairs(FROZE_GL.tbl_gold_popups) do  
                data.lifetime = data.lifetime + 1 * RFT
            
                if data.lifetime < 2.25 then 
                    data.pos_2d = data.pos_ent:ToScreen()
                    
                    data.pos_2d.x = math.Clamp(data.pos_2d.x, 0, W)
                    data.pos_2d.y = math.Clamp(data.pos_2d.y, 0, H)

                    data.pos_y_mod = math.Approach(data.pos_y_mod, H * 0.13, RFT * 4 * math.max(H * 0.01, ((H * 0.13) - data.pos_y_mod)))  
                end

                if data.lifetime <= 0.5 then 
                    data.color.a = math.min(255, data.color.a + RFT * 555)
                end

                if data.lifetime >= 2.25 then 
                    data.combined_distance = math.abs((W * 0.735) - data.pos_2d.x) + math.abs((H * 0.075) - data.pos_2d.y)
                    -- print("combined distance: " .. data.combined_distance)

                    if data.combined_distance <= 15 then 
                        data.color.a = math.max(0, data.color.a - RFT * 1500)
                    end

                    if not data.move_to_hl_icon_pos then 
                        data.pos_2d.y = data.pos_2d.y - data.pos_y_mod 
                        data.pos_y_mod = 0
                    end

                    data.pos_2d.x = math.Approach(data.pos_2d.x, W * 0.735, RFT * 6 * math.max(W * 0.01, math.abs((W * 0.735) - data.pos_2d.x)))
                    data.pos_2d.y = math.Approach(data.pos_2d.y, H * 0.075, RFT * 6 * math.max(H * 0.01, math.abs((H * 0.075) - data.pos_2d.y)))

                    data.move_to_hl_icon_pos = true
                end

                data.gold_shown = math.Round(math.Approach(data.gold_shown, data.gold_amount, math.max(1, RFT * 1.5 * (data.gold_amount))))

                surface.SetDrawColor(255, 255, 255, data.color.a)
                surface.SetMaterial(FROZE_GL.mat_hl)
                surface.DrawTexturedRect(data.pos_2d.x - ScreenScale(12), data.pos_2d.y - data.pos_y_mod + ScreenScale(1), ScreenScale(12), ScreenScale(12))
                draw.DrawText(data.gold_shown, gl .. "gold_popup", data.pos_2d.x, data.pos_2d.y - data.pos_y_mod, data.color, TEXT_ALIGN_LEFT)
                
                if FROZE_GL.tbl_gold_popups[1] and FROZE_GL.tbl_gold_popups[1].lifetime >= 2.5 and FROZE_GL.tbl_gold_popups[1].combined_distance <= 8 then
                    net.Start(gl .. "update_gold_from_anim_cl_to_sv")
                    net.WriteInt(data.gold_amount, 32)
                    net.SendToServer()

                    surface.PlaySound("dota2/coins.wav")

                    FROZE_GL.tbl_gold_popups[1] = nil 
                    FROZE_GL.tbl_gold_popups = table.ClearKeys(FROZE_GL.tbl_gold_popups) 
                    FROZE_GL.tbl_gold_hud.scale_mod = 0

                    timer.Create(gl .. "gold_bounce", 0.02, 10, function() 
                        local repsleft = timer.RepsLeft(gl .. "gold_bounce") 

                        if repsleft > 5 then 
                            FROZE_GL.tbl_gold_hud.scale_mod = FROZE_GL.tbl_gold_hud.scale_mod + 0.08
                        else 
                            FROZE_GL.tbl_gold_hud.scale_mod = math.max(0, FROZE_GL.tbl_gold_hud.scale_mod - 0.08)
                        end
                    end)
                end

                -- if data.lifetime >= 3 and data.pos_2d.x + W * 0.001 >= W * 0.735 then 
                    -- print("DESTROY")
                    -- table.remove(FROZE_GL.tbl_gold_popups, k)
                    -- table.ClearKeys(FROZE_GL.tbl_gold_popups)
                -- end

                surface.SetDrawColor(255, 255, 255, 255)
            end  
        end)

        hook.Add("HUDPaint", gl .. "xp_number_notifications", function()
            if GetConVar(gl .. "enable"):GetInt() == 0 then return end
            if #FROZE_GL.xp_numbers < 1 then return end

            for i = 2, #FROZE_GL.xp_numbers do
                draw.SimpleText("+" .. FROZE_GL.xp_numbers[i] .. " XP", gl .. "xp_notification_settled", FROZE_GL.xp_text_W, H * 0.43 + i * H * 0.022, color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            for i = 2, #FROZE_GL.xp_texts do
                draw.SimpleText(FROZE_GL.xp_texts[i], gl .. "xp_notification_extra_settled", FROZE_GL.xp_text_W * 1.15, H * 0.43 + i * H * 0.022, color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            draw.SimpleText("+" .. FROZE_GL.xp_numbers[1] .. " XP", FROZE_GL.xp_notification_font, FROZE_GL.xp_text_W, H * 0.45, color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            if #FROZE_GL.xp_texts > 0 then
                draw.SimpleText(FROZE_GL.xp_texts[1], xp_notification_font_extra, FROZE_GL.xp_text_W * 1.15, H * 0.45, color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end)

        hook.Add("HUDPaint", gl .. "xp_bar", function() 
            if GetConVar(gl .. "hud_enable"):GetInt() == 0 then return end
            if GetConVar(gl .. "enable"):GetInt() == 0 then return end
            local ply = LocalPlayer()
            local convar_font_2 = GetConVar(gl .. "hud_font_2"):GetString()

            if ply.gl_has_menu_open then return end 
            if not FROZE_GL.run_end_screen_stop_showing then return end
            
            if gl_weapon_selector_showing then 
                surface.SetAlphaMultiplier(0.3)
            end
            -- if GetGlobalBool(gl .. "show_end_screen") then return end

            local ply_level = ply:GetNWInt(gl .. "level", 1)
            FROZE_GL.xp = FROZE_GL.xp_total
            local maxxp = ply:GetNWInt(gl .. "xp_to_next_level", 100)
            local RFT = RealFrameTime()

            if oldxp == -1 and newxp == -1 then
                oldxp = FROZE_GL.xp
                newxp = FROZE_GL.xp
            end

            local smoothXP = Lerp((SysTime() - start) / animationTime, oldxp, newxp)

            if newxp ~= FROZE_GL.xp then
                if smoothXP ~= FROZE_GL.xp then
                    newxp = smoothXP
                end

                oldxp = newxp
                start = SysTime()
                newxp = FROZE_GL.xp
            end

            minutes = GetGlobalInt(gl .. "minutes")
            seconds = GetGlobalInt(gl .. "seconds")

            if seconds >= 10 and seconds ~= 60 then
                addedzero = ""
            elseif seconds < 10 then
                addedzero = "0"
            end

            draw.RoundedBox(2, W * 0.25, H * 0.045, W * 0.5, H * 0.015, color_black_alpha_100)
            draw.RoundedBox(2, W * 0.25, H * 0.045, math.max(0, smoothXP) / maxxp * barW, H * 0.015, Color(218, 214, 0))
            draw.SimpleText(minutes .. ":" .. addedzero .. seconds, gl .. "xp_level", W * 0.5, H * 0.022, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("LV " .. ply:GetNWInt(gl .. "level", 1), gl .. "xp_level", W * 0.5, H * 0.08, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(FROZE_GL.xp_total .. "/" .. maxxp, gl .. "xp_numbers", W * 0.5, H * 0.11, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            -- HL / GOLD COUNTER  
            local nwmoney = tonumber(ply:GetNWInt(gl .. "money", 0))

            if not ply.gl_money then 
                ply.gl_money = 0
            end 

            ply.gl_money = math.Round(math.Approach(ply.gl_money, nwmoney, math.max(RFT * math.abs(nwmoney - ply.gl_money) * 0.75, 2)))
            --* MONEY INDICATOR
            local w, h = ScrW(), ScrH()
            local t = RealTime() * 50
            
            local m = Matrix()
            local money_pos_x = W * 0.735
            local money_pos_y = H * 0.085 
            local center = Vector( money_pos_x, money_pos_y )

            FROZE_GL.tbl_gold_hud.scale_num = 1 + FROZE_GL.tbl_gold_hud.scale_mod

            FROZE_GL.tbl_gold_hud.scale_vector.x = FROZE_GL.tbl_gold_hud.scale_num
            FROZE_GL.tbl_gold_hud.scale_vector.y = FROZE_GL.tbl_gold_hud.scale_num
            FROZE_GL.tbl_gold_hud.scale_vector.z = FROZE_GL.tbl_gold_hud.scale_num

            m:Translate( center )
            -- m:Rotate( Angle( 0, t, 0 ) )
            m:Scale( FROZE_GL.tbl_gold_hud.scale_vector )
            m:Translate( -center )
            --
            cam.PushModelMatrix( m )
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(FROZE_GL.mat_hl)
            surface.DrawTexturedRect(money_pos_x + W * 0.001, money_pos_y - W * 0.0075, W * 0.015, W * 0.015)
            draw.SimpleText(ply.gl_money, gold_notification_font, money_pos_x, money_pos_y, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            cam.PopModelMatrix()	

            -- ENEMY KILL COUNTER
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(Material("garlic_like/icon_skull_bw.png"))
            surface.DrawTexturedRect(W * 0.25, H * 0.074, W * 0.016, W * 0.016)
            draw.SimpleText(GetGlobalInt(gl .. "enemy_kills", 0), gold_notification_font, W * 0.268, H * 0.085, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            -- ENEMY EMPOWERED STATS
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(Material("garlic_like/icon_empowered_hp.png"))
            surface.DrawTexturedRect(W * 0.3, H * 0.074, W * 0.016, W * 0.016)
            -- garlic_like_draw_scaled(text, x, y, width, font, font_name, color, alignment)

            --* OPTIMIZE THIS FUNCTION! AT 5000 FOR LOOP, IT HAS 30% LESS PERFORMANCE THAN A draw.SimpleText !!!
            -- for i = 1, 5000 do 
            garlic_like_draw_scaled("x" .. 1 + math.Truncate(GetGlobalFloat(gl .. "enemy_modifier_hp", 0), 1), W * 0.318, H * 0.088, W * 0.04, gl .. "font_empowered_numbers", convar_font_2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, "LINES_DISABLED")            
            -- end

            -- for i = 1, 5000 do
            -- draw.SimpleText("x" .. 1 + math.Truncate(GetGlobalFloat(gl .. "enemy_modifier_hp", 0), 1), gl .. "font_empowered_numbers", W * 0.318, H * 0.085, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            -- end
            -- 
            surface.SetMaterial(Material("garlic_like/icon_empowered_damage.png"))
            surface.DrawTexturedRect(W * 0.36, H * 0.074, W * 0.016, W * 0.016)
            garlic_like_draw_scaled("x" .. 1 + math.Truncate(GetGlobalFloat(gl .. "enemy_modifier_damage", 0), 1), W * 0.378, H * 0.088, W * 0.04, gl .. "font_empowered_numbers", convar_font_2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, "LINES_DISABLED")
            -- draw.SimpleText("x" .. 1 + math.Truncate(GetGlobalFloat(gl .. "enemy_modifier_damage", 0), 1), gl .. "font_empowered_numbers", W * 0.378, H * 0.085, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            --
            surface.SetMaterial(Material("garlic_like/icon_empowered_resistance.png"))
            surface.DrawTexturedRect(W * 0.42, H * 0.074, W * 0.016, W * 0.016)
            -- garlic_like_draw_scaled("x" .. 1 - math.Truncate(GetGlobalFloat(gl .. "enemy_modifier_resistance", 0), 1), W * 0.438, H * 0.088, W * 0.04, gl .. "font_empowered_numbers", convar_font_2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, "LINES_DISABLED")
            draw.SimpleText("x" .. 1 - math.Truncate(GetGlobalFloat(gl .. "enemy_modifier_resistance", 0), 2), gl .. "font_empowered_numbers", W * 0.438, H * 0.087, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            surface.SetMaterial(Material("garlic_like/icon_empowered_evasion.png"))
            surface.DrawTexturedRect(W * 0.54, H * 0.074, W * 0.016, W * 0.016)
            -- garlic_like_draw_scaled("x" .. 1 - math.Truncate(GetGlobalFloat(gl .. "enemy_modifier_evasion", 0), 1), W * 0.558, H * 0.088, W * 0.04, gl .. "font_empowered_numbers", convar_font_2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, "LINES_DISABLED")
            draw.SimpleText("x" .. 1 - math.Truncate(GetGlobalFloat(gl .. "enemy_modifier_evasion", 0), 2), gl .. "font_empowered_numbers", W * 0.558, H * 0.087, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            --
            local pending_text = "PENDING LEVEL UPS"

            if not GetConVar(gl .. "enable_timer"):GetBool() then 
                pending_text = "PRESS " .. "L" .. " TO OPEN GAME MENU"
            end

            if FROZE_GL.pending_level_ups > 0 or (not GetConVar(gl .. "enable_timer"):GetBool() and not ply.gl_has_menu_open) then
                
                surface.SetAlphaMultiplier(1)
                -- draw.RoundedBox(4, W * 0.5 - W * 0.08, H * 0.125, W * 0.16, H * 0.085, color_black_alpha_150)
                if FROZE_GL.pending_level_ups > 0 then 
                    gl_cse(ply, W * 0.5, H * 0.125, FROZE_GL.pending_level_ups, "", "", false, false, "", true, gl .. "font_title")
                end

                alpha_mult = math.Clamp(math.abs(math.cos(CurTime() * 2)), 0, 255)        
                surface.SetFont(gl .. "font_title_3")
                pending_text_w, pending_text_h = surface.GetTextSize(pending_text)
                surface.SetAlphaMultiplier(alpha_mult)
                surface.SetTextColor(color_white)
                surface.SetTextPos(W * 0.5 - pending_text_w * 0.5, H * 0.19 - pending_text_h * 0.5)
                surface.DrawText(pending_text)
                surface.SetAlphaMultiplier(1)
            end

            surface.SetAlphaMultiplier(1)
        end)

        hook.Add("HUDPaint", gl .. "enemy_empowered_show_on_hud", function()
            if not GetConVar(gl .. "enable"):GetBool() then return end 
            if not FROZE_GL.show_empowered_text then return end
            draw.SimpleText("ENEMIES EMPOWERED!", gl .. "empowered_text", W * 0.5, H * 0.2, FROZE_GL.color_empowered_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("HP x" .. string.format("%.2f", 1 + GetGlobalFloat(gl .. "enemy_modifier_hp", 0)) .. " DMG x" .. string.format("%.2f", 1 + GetGlobalFloat(gl .. "enemy_modifier_damage", 0)) .. " RES x" .. string.format("%.2f", 1 - GetGlobalFloat(gl .. "enemy_modifier_resistance", 0)), gl .. "empowered_text_sub", W * 0.5, H * 0.25, FROZE_GL.color_empowered_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)

        hook.Add("HUDPaint", gl .. "item_pickup", function() 
            if not GetConVar(gl .. "enable"):GetBool() then return end 
            local RFT = RealFrameTime() 
            -- PrintTable(FROZE_GL.glips.entries)
            for k, data in pairs (FROZE_GL.glips.entries) do  
                local operation_type = " x"

                if string.find(tostring(data.amount), "-") then 
                    operation_type = " "
                end

                -- print("data.amount " .. data.amount)

                data.lifetime = data.lifetime + RFT * 1000 

                if data.pos_y == 0 then 
                    data.pos_y = H * 0.82 - k * FROZE_GL.glips.bg_height * 1.05 
                end 

                data.pos_y = math.Approach(data.pos_y, H * 0.82 - k * FROZE_GL.glips.bg_height * 1.05, RFT * H * 0.8)

                if data.lifetime >= 2500 or k > 6 then 
                    data.color_text.a = data.color_text.a - RFT * 900
                    data.color_text_held.a = data.color_text_held.a - RFT * 900
                    data.color_bg.a = data.color_bg.a - RFT * 900
                    data.pos_x = data.pos_x - W * 0.001 * RFT * 550

                    if data.color_bg.a < 0 then 
                        FROZE_GL.glips.entries[k] = nil
                        FROZE_GL.glips.entries = table.ClearKeys(FROZE_GL.glips.entries)
                    end
                else 
                    data.pos_x = math.min(W * 0.02, data.pos_x + W * 0.001 * RFT * 350)
                    data.color_highlight.a = data.color_highlight.a - RFT * 850 
                end 
                
                draw.RoundedBox(8, data.pos_x, data.pos_y, FROZE_GL.glips.bg_width, FROZE_GL.glips.bg_height, data.color_bg)
                draw.DrawText(data.text .. operation_type .. data.amount, gl .. "item_pickup_name", data.pos_x + W * 0.035, data.pos_y + H * 0.01, data.color_text, TEXT_ALIGN_LEFT)

                if data.item_type == "ore" then 
                    draw.DrawText("Held: " .. FROZE_GL.WepCrystalsInventory[FROZE_GL.tbl_rarity_to_number[data.rarity]].held_num, gl .. "item_pickup_held_num", (data.pos_x - W * 0.005) + FROZE_GL.glips.bg_width, data.pos_y + H * 0.03, data.color_text_held, TEXT_ALIGN_RIGHT)            
                elseif data.item_type == "material" then 
                    draw.DrawText("Held: " .. FROZE_GL.tbl_materials_inventory[data.text].held_num, gl .. "item_pickup_held_num", (data.pos_x - W * 0.005) + FROZE_GL.glips.bg_width, data.pos_y + H * 0.03, data.color_text_held, TEXT_ALIGN_RIGHT)            
                end

                draw.RoundedBox(8, data.pos_x, data.pos_y, FROZE_GL.glips.bg_width, FROZE_GL.glips.bg_height, data.color_highlight)
                surface.SetDrawColor(255, 255, 255, data.color_text.a)
                surface.SetMaterial(data.icon)
                surface.DrawTexturedRect((data.pos_x - W * 0.005), data.pos_y, W * 0.035, H * 0.06)
            end
        end)  

        hook.Add("HUDPaint", gl .. "show_use_key", function() 
            if not GetConVar(gl .. "enable"):GetBool() then return end 
            -- 
            local ply = LocalPlayer()
            local ent = ply:GetEyeTrace().Entity 

            local use_range = 17000

            if not IsValid(ent) then return end 

            local class = ent:GetClass() 
            local pos = ent:LocalToWorld(ent:OBBCenter())
            local dist = pos:DistToSqr(ply:GetPos()) 

            -- print(class)
            -- print(dist)

            if (class == gl .. "station_item_fusing" or class == gl .. "station_weapon_upgrade") and dist <= use_range then 
                surface.SetFont(gl .. "font_title_2")
                local text = "Press " .. string.upper(input.LookupBinding("+use")) .. " to use " .. ent.PrintName
                local t_w, t_h = surface.GetTextSize(text)
                draw.RoundedBox(0, W * 0.5 - (t_w * 1.05) / 2, H * 0.55 - (t_h * 1.1) / 2, t_w * 1.05, t_h * 1.1, color_black_alpha_150)
                draw.SimpleText(text, gl .. "font_title_2", W * 0.5, H * 0.55, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end        
        end)

        local debug_c = false

        hook.Add("HUDPaint", gl .. "run_end_screen", function() 
            if not GetConVar(gl .. "enable"):GetBool() then return end 
            local RFT = RealFrameTime()  

            if debug_c then return end
            if FROZE_GL.run_end_screen_stop_showing then return end

            local tbl = FROZE_GL.tbl_run_end_screen
            
            if tbl.res_t_life < 2 then 
                tbl.res_t_life = tbl.res_t_life + RFT
                draw.DrawText("RUN END!", gl .. "font_title", W * 0.5, H * 0.3, color_white, TEXT_ALIGN_CENTER)
                -- print("RES T LIFE: " .. tbl.res_t_life)
            else 
                tbl.bg_color.a = math.min(225, tbl.bg_color.a + RFT * 500)
                draw.RoundedBox(0, 0, 0, W, H, tbl.bg_color)

                if tbl.bg_color.a >= 225 then 
                    tbl.res_size_num = math.max(1, (tbl.res_size_num - RFT * 155))            

                    if tbl.res_size_num <= 1 then 
                        if not tbl.sound_played then 
                            tbl.sound_played = true 
                            surface.PlaySound("garlic_like/result_screen.wav")
                        end

                        local stat_y = H * 0.29
                        local stat_y_diff = H * 0.035
                        surface.SetDrawColor(255, 255, 255, tbl.flare_a) 
                        surface.SetMaterial(tbl.mat_flare)  
                        surface.DrawTexturedRect(W * 0.5 - tbl.flare_w / 2, H * 0.1 - tbl.flare_h / 2, tbl.flare_w, tbl.flare_h)

                        tbl.flare_w = math.min(W, tbl.flare_w + RFT * W * 2)
                        tbl.flare_a = math.max(0, tbl.flare_a - RFT * 1100)

                        draw.SimpleText("MAP " .. game.GetMap(), gl .. "font_title_2", W * 0.5, H * 0.2, tbl.color_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        draw.SimpleText("PRESET " .. GetConVar(gl .. "enemy_preset"):GetString(), gl .. "font_title_3", W * 0.5, H * 0.24, tbl.color_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        draw.SimpleText("Time Survived", gl .. "font_subtitle_3", W * 0.15, stat_y + stat_y_diff * 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText("Gold Earned", gl .. "font_subtitle_3", W * 0.15, stat_y + stat_y_diff * 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText("Level Reached", gl .. "font_subtitle_3", W * 0.15, stat_y + stat_y_diff * 3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) 
                        draw.SimpleText("Enemy HP Mult", gl .. "font_subtitle_3", W * 0.15, stat_y + stat_y_diff * 4, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) 
                        draw.SimpleText("Enemy DMG Mult", gl .. "font_subtitle_3", W * 0.15, stat_y + stat_y_diff * 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) 
                        draw.SimpleText("Enemy DR Mult", gl .. "font_subtitle_3", W * 0.15, stat_y + stat_y_diff * 6, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) 
                        draw.SimpleText("Total DMG Dealt", gl .. "font_subtitle_3", W * 0.15, stat_y + stat_y_diff * 7, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) 
                        draw.SimpleText("Total DMG Taken", gl .. "font_subtitle_3", W * 0.15, stat_y + stat_y_diff * 8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) 
                        draw.SimpleText("Highest DMG Dealt", gl .. "font_subtitle_3", W * 0.15, stat_y + stat_y_diff * 9, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) 
                        draw.SimpleText("Rank XP Gained", gl .. "font_subtitle_3", W * 0.15, stat_y + stat_y_diff * 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) 
        
                        tbl.shown_time_survived_seconds = math.min(tbl.total_seconds, tbl.shown_time_survived_seconds + math.Round(RFT * math.max(1, tbl.total_seconds)))
                        tbl.shown_gold_gained = math.Approach(tbl.shown_gold_gained, tbl.gold_gained, math.Round(RFT * math.max(1, tbl.gold_gained)))
                        tbl.shown_level_reached = math.Approach(tbl.shown_level_reached, tbl.level_reached, math.Round(RFT * 5 * math.max(1, tbl.level_reached)))
                        tbl.shown_enemy_hp_mult = math.Truncate(math.Approach(tbl.shown_enemy_hp_mult, tbl.enemy_hp_mult, RFT * math.max(0.1, tbl.enemy_hp_mult)), 2)
                        tbl.shown_enemy_dmg_mult = math.Truncate(math.Approach(tbl.shown_enemy_dmg_mult, tbl.enemy_dmg_mult, RFT * math.max(0.1, tbl.enemy_dmg_mult)), 2)
                        tbl.shown_enemy_dr_mult = math.Truncate(math.Approach(tbl.shown_enemy_dr_mult, tbl.enemy_dr_mult, RFT * math.max(0.1, tbl.enemy_dr_mult)), 2)
                        tbl.shown_total_dmg_dealt = math.Approach(tbl.shown_total_dmg_dealt, tbl.total_dmg_dealt, math.Round(RFT * math.max(1, tbl.total_dmg_dealt)))
                        tbl.shown_total_dmg_taken = math.Approach(tbl.shown_total_dmg_taken, tbl.total_dmg_taken, math.Round(RFT * math.max(1, tbl.total_dmg_taken)))
                        tbl.shown_highest_dmg = math.Approach(tbl.highest_dmg, tbl.highest_dmg, math.Round(RFT * math.max(1, tbl.highest_dmg)))
                        tbl.shown_rank_xp_gained = math.Approach(tbl.rank_xp_gained, tbl.rank_xp_gained, math.Round(RFT * math.max(1, tbl.rank_xp_gained)))

                        draw.SimpleText(": " .. string.FormattedTime( tbl.shown_time_survived_seconds, "%02i:%02i" ), gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 1, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(": " .. tbl.shown_gold_gained, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 2, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(": " .. tbl.shown_level_reached, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 3, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(": " .. tbl.shown_enemy_hp_mult, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 4, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(": " .. tbl.shown_enemy_dmg_mult, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 5, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(": " .. tbl.shown_enemy_dr_mult, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 6, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(": " .. tbl.shown_total_dmg_dealt, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 7, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(": " .. tbl.shown_total_dmg_taken, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 8, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(": " .. tbl.shown_highest_dmg, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 9, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(": " .. tbl.shown_rank_xp_gained, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 10, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                        draw.SimpleText("HOLD RIGHT MOUSE BUTTON TO CONTINUE!", gl .. "font_subtitle_2", W * 0.5, H * 0.85, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                        if input.IsMouseDown(MOUSE_RIGHT) then 
                            FROZE_GL.run_end_screen_progress_num = FROZE_GL.run_end_screen_progress_num + RFT * 100
                            draw.SimpleText(math.min(100, math.Round(FROZE_GL.run_end_screen_progress_num)) .. "%", gl .. "font_subtitle_2", W * 0.5, H * 0.9, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        else 
                            FROZE_GL.run_end_screen_progress_num = 0
                            FROZE_GL.run_end_screen_stop_showing = false
                        end

                        if math.Round(FROZE_GL.run_end_screen_progress_num) >= 100 then 
                            FROZE_GL.run_end_screen_stop_showing = true

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
                                rank_xp_gained = 0,
                                total_seconds = 0,
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

                            FROZE_GL.tbl_run_end_screen_2.stop_running = false
                            FROZE_GL.tbl_run_end_screen_2.is_running = true
                            FROZE_GL.tbl_run_end_screen_2.rank_xp_gained = tbl.rank_xp_gained
                            -- debug_c = true
                        end
                    end

                    draw.SimpleText("RESULTS!", gl .. "font_title_result_screen_" .. math.Round(tbl.res_size_num), W * 0.5, H * 0.1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    surface.SetDrawColor(255, 255, 255, 255) 
                end
            end
        end)

        hook.Add("HUDPaint", gl .. "run_end_screen_xp_gain", function() 
            -- if not b then return end -- to disable for debugging
            if not GetConVar(gl .. "enable"):GetBool() then return end 
            if FROZE_GL.tbl_run_end_screen_2.stop_running then return end
            local ply = LocalPlayer()
            local RFT = RealFrameTime()   
            local tbl = FROZE_GL.tbl_run_end_screen
            local tbl2 = FROZE_GL.tbl_run_end_screen_2            

            tbl2.time_elapsed = tbl2.time_elapsed + RFT 

            if tbl2.rank_xp_gained > 0 then 
                local speed_mod = 1
    
                if input.IsMouseDown(MOUSE_RIGHT) then 
                    tbl2.time_elapsed_hold_rmb = math.min(1, tbl2.time_elapsed_hold_rmb + RFT)
                    
                    if tbl2.time_elapsed_hold_rmb >= 1 then 
                        speed_mod = 100
                    end
                else 
                    speed_mod = 1
                    tbl2.time_elapsed_hold_rmb = 0
                end

                tbl2.rank_xp_gained = math.max(0, tbl2.rank_xp_gained - math.min(tbl2.rank_xp_to_rank_up, RFT * 255 * speed_mod))
                tbl2.rank_xp_current = tbl2.rank_xp_current + math.min(tbl2.rank_xp_to_rank_up, RFT * 255 * speed_mod) 

                --! MAKE THE CLIENTSIDE RANK PERSISTENT AND LINK IT WITH SERVER
                if tbl2.rank_xp_current >= tbl2.rank_xp_to_rank_up then 
                    surface.PlaySound("garlic_like/mm_rank_up_achieved.wav")                    

                    tbl2.color_xp_bar_highlight.a = 200
                    tbl2.rank_xp_to_rank_up = tbl2.rank_xp_to_rank_up + 5
                    tbl2.rank_num = tbl2.rank_num + 1
                    tbl2.rank_xp_current = 0

                    local weight_rolled = math.random(1, FROZE_GL.valid_inventory_items_max_weight)
                    print("weight rolled: " .. weight_rolled)

                    for k, v in ipairs(FROZE_GL.tbl_valid_inventory_items) do 
                        if not v.ru_reward then continue end 

                        if IsNumBetween(weight_rolled, v.drop_weight_min_ru, v.drop_weight_max_ru) then 
                            garlic_like_add_inventory_item(v.name, 1) 

                            tbl2.tbl_gained_chests[#tbl2.tbl_gained_chests + 1] = {
                                name = v.name, 
                                icon_mat = v.icon_mat,  
                                rarity = v.rarity,
                                pos_x = 0,
                                pos_y = 0,
                                offset_pos_x = 0,
                                offset_pos_y = 0,
                                amount_ATT = 0,
                                color_highlight = Color(FROZE_GL.tbl_rarity_colors[v.rarity]:Unpack()),
                                color_text = Color(FROZE_GL.tbl_rarity_colors[v.rarity]:Unpack()),
                            }

                            tbl2.tbl_gained_chests[#tbl2.tbl_gained_chests].color_text.a = 0
                        end
                    end

                    --
                    net.Start(gl .. "update_rank_cl_to_sv")
                    net.WriteInt(tbl2.rank_num, 32)
                    net.WriteInt(tbl2.rank_xp_current, 32)
                    net.WriteInt(tbl2.rank_xp_to_rank_up, 32)
                    net.SendToServer()

                    ply:SetPData(gl .. "rank_num", tonumber(ply:GetPData(gl .. "rank_num", 1)) + 1)
                    --

                    PrintTable(FROZE_GL.tbl_menu_inventory.consumables)
                    print("------------------------------------------------------------------------------------------------------")
                    print("------------------------------------------------------------------------------------------------------")
                    PrintTable(tbl2.tbl_gained_chests)
                    print("------------------------------------------------------------------------------------------------------")
                end
            elseif tbl2.rank_xp_gained <= 0 then 
                if not ply.gl_close_end_screen_2_time then 
                    ply.gl_close_end_screen_2_time = CurTime() + 1.25
                    print("SET TIMER FOR END 2")
                end

                if ply.gl_close_end_screen_2_time and ply.gl_close_end_screen_2_time < CurTime() then 
                    ply.gl_close_end_screen_2_time = nil
                    tbl2.stop_running = true
                    tbl2.is_running = false 
                    tbl2.tbl_gained_chests = {}
                    tbl2.rank_xp_gained = 0 
                end
            end

            tbl2.color_xp_bar_highlight.a = math.max(0, tbl2.color_xp_bar_highlight.a - RFT * 455)
 
            draw.RoundedBox(0, 0, 0, W, H, Color(0, 0, 0, 225))
            draw.DrawText("RANK " .. tbl2.rank_num, gl .. "font_title_big_smaller", W * 0.5, H * 0.25, color_white, TEXT_ALIGN_CENTER)

            draw.RoundedBox(4, W * 0.2, H * 0.4, W * 0.6, H * 0.07, tbl2.color_xp_bar_bg)
            draw.RoundedBox(4, W * 0.2, H * 0.4, math.Remap(tbl2.rank_xp_current, 0, tbl2.rank_xp_to_rank_up, 0, W * 0.6), H * 0.07, tbl2.color_xp_bar)
            draw.RoundedBox(4, W * 0.2, H * 0.4, W * 0.6, H * 0.07, tbl2.color_xp_bar_highlight)

            draw.DrawText(math.Round(tbl2.rank_xp_current) .. "/" .. tbl2.rank_xp_to_rank_up .. " XP", gl .. "font_title", W * 0.5, H * 0.405, color_white, TEXT_ALIGN_CENTER)
            draw.DrawText("+" .. math.Round(tbl2.rank_xp_gained) .. " XP", gl .. "font_title_2", W * 0.5, H * 0.5, color_white, TEXT_ALIGN_CENTER)

            --* draw the obtained chests
            local size_item_bg = W * 0.08
            local limit_per_line = 10
            for k, v in ipairs(tbl2.tbl_gained_chests) do  
                surface.SetDrawColor(255, 255, 255, 255)                 
                v.pos_y = H * 0.6
 
                if #tbl2.tbl_gained_chests <= 20 then 
                    if k > limit_per_line then   
                        local addition_y = 0
                        v.pos_x = (W * 0.5 - ((size_item_bg + W * 0.01) / 2) * (#tbl2.tbl_gained_chests - k + 1)) + ((size_item_bg + W * 0.01) * ((k - 1) % 10 )) / 2
                        v.offset_pos_y = math.floor((k - 1) / limit_per_line) * (size_item_bg + W * 0.03) 
                    else  
                        v.pos_x = (W * 0.5 - ((size_item_bg + W * 0.01) / 2) * math.min(limit_per_line, #tbl2.tbl_gained_chests)) + ((size_item_bg + W * 0.01) * (k - 1))
                    end
                end

                if k < 21 then 
                    local color_rarity = FROZE_GL.tbl_rarity_colors[v.rarity]
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(v.icon_mat) 
                    surface.DrawTexturedRect(v.pos_x + size_item_bg * 0.05, v.pos_y + v.offset_pos_y + size_item_bg * 0.05, size_item_bg * 0.9, size_item_bg * 0.9)
                    surface.SetDrawColor(color_rarity.r, color_rarity.g, color_rarity.b, 255)
                    surface.DrawOutlinedRect(v.pos_x, v.pos_y + v.offset_pos_y, size_item_bg, size_item_bg, 2)
                    draw.RoundedBox(0, v.pos_x - v.offset_pos_x, v.pos_y + v.offset_pos_y, size_item_bg, size_item_bg, Color(0, 0, 0, 125))

                    v.color_highlight.a = math.max(0, v.color_highlight.a - RFT * 855)
                    v.color_text.a = math.min(255, v.color_text.a + RFT * 555)

                    draw.RoundedBox(0, v.pos_x - v.offset_pos_x, v.pos_y + v.offset_pos_y, size_item_bg, size_item_bg, v.color_highlight)
                    garlic_like_draw_scaled(v.name, v.pos_x + size_item_bg * 0.5, v.pos_y + v.offset_pos_y - H * 0.013, size_item_bg, gl .. "font_title_3", GetConVar(gl .. "hud_font_2"):GetString(), v.color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "LINES_DISABLED")
                    --* finish the che  st showcase
                    -- draw.DrawText(k, "Default", v.pos_x, v.pos_y + v.offset_pos_y, color_white, TEXT_ALIGN_LEFT)
                end
            end

            draw.SimpleText("HOLD RIGHT MOUSE BUTTON TO CONTINUE!", gl .. "font_subtitle_2", W * 0.5, H * 0.85, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(math.min(100, math.Round(tbl2.time_elapsed_hold_rmb * 100)) .. "%", gl .. "font_subtitle_2", W * 0.5, H * 0.9, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            surface.SetDrawColor(255, 255, 255, 255)
        end) 

        hook.Add("PostDrawHUD", gl .. "damage_numbers", function() 
            if not GetConVar(gl .. "enable"):GetBool() then return end 
            local tbl = FROZE_GL.tbl_damage_numbers
            local RFT = RealFrameTime()
            local ply = LocalPlayer()

            cam.Start2D()
                if #tbl > 0 then 
                    -- PrintTable(tbl)
                    for k, v in pairs(tbl) do             
                        -- print(isvector(v.vel))
                        -- print(isvector(v.pos))            
                        local distance_modifier = math.Clamp(v.pos:Distance(ply:GetPos()) / 300, 0.25, 10) 
                        v.pos = (v.pos + v.vel * RFT * distance_modifier)
                        v.vel.z = v.vel.z - 100 * RFT
                        v.lifetime_lived = v.lifetime_lived + RFT

                        if v.lifetime_lived < 0.3 then 
                            -- v.color.a = math.min(255, v.color.a + RFT * 1350)
                            v.size_i = math.max(1, v.size_i - RFT * 255)
                        elseif v.lifetime_lived > 0.7 then 
                            v.color.a = math.max(0, v.color.a - RFT * 500)
                            v.size_i = math.min(30, v.size_i + RFT * 50)
                        end
                        
                        -- print(math.Round(v.size_i))
                        -- print(v.pos.z)
                        -- print(v.lifetime_lived)
                        local pos = v.pos:ToScreen()

                        -- print(v.pos)

                        draw.SimpleText(v.dmg, gl .. v.font_name .. math.Round(v.size_i), pos.x, pos.y, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            cam.End2D()
        end)

        hook.Add("PostDrawHUD", gl .. "show_break_text", function() 
            if not GetConVar(gl .. "enable"):GetBool() then return end 
            if not GetGlobalBool(gl .. "is_breaktime") or GetGlobalInt(gl .. "breaktime_seconds") <= 0 then return end 
            local ply = LocalPlayer()
            -- 
            draw.DrawText(FROZE_GL.tbl_break_hud.text_break, gl .. "font_title", FROZE_GL.tbl_break_hud.tb_pos_x, FROZE_GL.tbl_break_hud.tb_pos_y, color_white, TEXT_ALIGN_CENTER)
            draw.DrawText(GetGlobalInt(gl .. "breaktime_seconds"), gl .. "font_title", FROZE_GL.tbl_break_hud.tb_pos_x, FROZE_GL.tbl_break_hud.tb_pos_y + H * 0.05, color_white, TEXT_ALIGN_CENTER)

            if ply:GetNWInt(gl .. "breaktime_skip_progress", 0) > 0 then 
                draw.DrawText("SKIPPING PROGRESS: " .. ply:GetNWInt(gl .. "breaktime_skip_progress") .. "%", gl .. "font_title_2", FROZE_GL.tbl_break_hud.tb_pos_x, FROZE_GL.tbl_break_hud.tb_pos_y + H * 0.1, color_white, TEXT_ALIGN_CENTER)
            end            
        end)

        hook.Add("PostDrawHUD", gl .. "hud_elements", function()
            if GetConVar(gl .. "hud_enable"):GetInt() == 0 then return end
            if GetConVar(gl .. "enable"):GetInt() == 0 or (ply.garlic_like_is_opening_stats_screen ~= nil and ply.garlic_like_is_opening_stats_screen) then return end        
            -- if not GetConVar(gl .. "enable_timer"):GetBool() then return end  
            local ply = LocalPlayer()
            if ply.gl_has_menu_open then return end
            if not IsValid(ply) or not ply:Alive() then return end
            if not FROZE_GL.run_end_screen_stop_showing then return end
            if FROZE_GL.tbl_run_end_screen_2.is_running then return end 
            -- if GetGlobalBool(gl .. "show_end_screen") then return end
            --
            local ply_wep = ply:GetActiveWeapon() 
            --
            if not IsValid(ply_wep) then return end
            --
            local RFT = RealFrameTime()
            local ply_wep_class = ply_wep:GetClass()
            --
            -- draw.SimpleText("LIVES: " .. 1 + ply:GetNWInt(gl .. "max_deaths_base")  - ply:GetNWInt(gl .. "death_count", 0), gl .. "font_title_3", W * 0.5, H * 0.78, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            -- draw.SimpleText("MANA", gl .. "mana", W * 0.5, H * 0.81, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            -- draw.SimpleText(ply:GetNWInt(gl .. "mana", 100) .. "/" .. ply:GetNWInt(gl .. "max_mana", 100), gl .. "mana_numbers", W * 0.5, H * 0.84, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local heart_amount = 1 + ply:GetNWInt(gl .. "max_deaths_base")  - ply:GetNWInt(gl .. "death_count", 0)
            local heart_x = W * 0.17
            local heart_y = H * 0.91   
            local added_y = 0 
            local added_x = 0
            local num = 1 

            local heart_bg_x = heart_x + W * 0.016 / 2
            local heart_bg_y = heart_y - W * 0.018
            local heart_bg_w = 6 * W * 0.016

            cam.Start2D()

            draw.RoundedBox(4, heart_bg_x, heart_bg_y, heart_bg_w, H * 0.09, color_black_alpha_150)
            draw.SimpleText("LIVES", gl .. "font_subtitle_3", heart_bg_x + 6 * W * 0.016 / 2, heart_bg_y + W * 0.008, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(FROZE_GL.mat_heart) 

            for i = 1, 10 do 
                if i > heart_amount then 
                    surface.SetDrawColor(0, 0, 0, 175)
                end

                if i > 5 then 
                    num = i - (math.ceil(i / 5) - 1) * 5 
                else 
                    num = i
                end

                surface.DrawTexturedRect(heart_x + num * W * 0.016 + added_x, heart_y + added_y, W * 0.016, H * 0.025)

                if i % 5 == 0 then 
                    added_y = i / 5 * H * 0.026            
                end
            end
            
            garlic_like_create_point_bar("AP", FROZE_GL.tbl_hud_elements.apbar_x, FROZE_GL.tbl_hud_elements.apbar_y - 1, FROZE_GL.tbl_hud_elements.apbar_w, FROZE_GL.tbl_hud_elements.apbar_h, FROZE_GL.tbl_hud_elements.apbar_t_x, FROZE_GL.tbl_hud_elements.apbar_t_y - 1, FROZE_GL.tbl_hud_elements.apbar_color, FROZE_GL.tbl_hud_elements.apbar_color_gradient) 
            garlic_like_create_point_bar("HP", FROZE_GL.tbl_hud_elements.hpbar_x, FROZE_GL.tbl_hud_elements.hpbar_y - 1, FROZE_GL.tbl_hud_elements.hpbar_w, FROZE_GL.tbl_hud_elements.hpbar_h, FROZE_GL.tbl_hud_elements.hpbar_t_x, FROZE_GL.tbl_hud_elements.hpbar_t_y - 1, FROZE_GL.tbl_hud_elements.hpbar_color, FROZE_GL.tbl_hud_elements.hpbar_color_gradient) 
            garlic_like_create_point_bar("MP", FROZE_GL.tbl_hud_elements.mpbar_x, FROZE_GL.tbl_hud_elements.mpbar_y, FROZE_GL.tbl_hud_elements.mpbar_w, FROZE_GL.tbl_hud_elements.mpbar_h, FROZE_GL.tbl_hud_elements.mpbar_t_x, FROZE_GL.tbl_hud_elements.mpbar_t_y, FROZE_GL.tbl_hud_elements.mpbar_color, FROZE_GL.tbl_hud_elements.mpbar_color_gradient)      
        
            if GetConVar(gl .. "hud_show_abilities"):GetInt() > 0 then
                draw.RoundedBox(4, W * 0.375, H * 0.86, W * 0.25, H * 0.125, color_black_alpha_150)

                for i = 1, 4 do
                    draw.RoundedBox(0, (i * W * 0.06) - W * 0.06 + W * 0.385, H * 0.88, W * 0.05, W * 0.05, Color(0, 0, 0, 200))
                end

                for k, upgrade in SortedPairs(table.ClearKeys(FROZE_GL.skills_held)) do
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(Material(upgrade.icon))
                    surface.DrawTexturedRect((k * W * 0.06) - W * 0.06 + W * 0.385, H * 0.88, W * 0.05, W * 0.05)

                    if type(FROZE_GL.skill_cooldown_numbers[k]) ~= "string" and FROZE_GL.skill_cooldown_numbers[k] > 0 then
                        surface.SetDrawColor(FROZE_GL.skill_cooldown_dark[k])
                        surface.DrawRect((k * W * 0.06) - W * 0.06 + W * 0.385, H * 0.88, W * 0.05, W * 0.05)
                        draw.SimpleText(string.format("%.1f", FROZE_GL.skill_cooldown_numbers[k]), gl .. "font_title_2", (k * W * 0.06) + W * 0.35, H * 0.925, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end

                for i = 1, 4 do
                    surface.SetDrawColor(FROZE_GL.skill_circle_colors[i])
                    surface.DrawOutlinedRect((i * W * 0.06) - W * 0.06 + W * 0.385, H * 0.88, W * 0.05, W * 0.05, 1)
                end

                draw.RoundedBox(4, W * 0.3, H * 0.88, W * 0.05, W * 0.05, color_black_alpha_150)
                --
                draw.RoundedBox(4, W * 0.65, H * 0.88, W * 0.05, W * 0.05, color_black_alpha_150) -- TF2 ULTIMATE SKILL ICON

                if FROZE_GL.tbl_ult.ult_cooldown > 0 then
                    -- FROZE_GL.tbl_ult.ult_cooldown = math.max(0, math.Approach(FROZE_GL.tbl_ult.ult_cooldown, 0, 0.03)) 
                    if GetGlobalBool(gl .. "match_running", false) then 
                        FROZE_GL.tbl_ult.ult_cooldown = math.Clamp(FROZE_GL.tbl_ult.ult_num_cooldown * (1 - (RealTime() - FROZE_GL.tbl_ult.ult_starttime) / FROZE_GL.tbl_ult.ult_num_cooldown), 0, FROZE_GL.tbl_ult.ult_num_cooldown)
                    end
                
                    surface.SetDrawColor(125, 125, 125)
                    surface.SetMaterial(Material("garlic_like/icon_tf2_ult.png"))
                    surface.DrawTexturedRect(W * 0.655, H * 0.89, W * 0.04, W * 0.04)
                    draw.SimpleText(math.Truncate(FROZE_GL.tbl_ult.ult_cooldown, 1), gl .. "font_title_2", W * 0.675, H * 0.92, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(Material("garlic_like/icon_tf2_ult.png"))
                    surface.DrawTexturedRect(W * 0.655, H * 0.89, W * 0.04, W * 0.04)
                end

                if ply:GetNWBool(gl .. "dash_available") ~= false then
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(Material("garlic_like/icon_relics/advanced-jogger.png"))
                    surface.DrawTexturedRect(W * 0.3, H * 0.88, W * 0.05, W * 0.05)
                else
                    surface.SetDrawColor(125, 125, 125)
                    surface.SetMaterial(Material("garlic_like/icon_relics/advanced-jogger.png"))
                    surface.DrawTexturedRect(W * 0.3, H * 0.88, W * 0.05, W * 0.05)
                    draw.SimpleText(math.Truncate(ply:GetNWFloat(gl .. "dash_cooldown"), 1), gl .. "font_title_2", W * 0.325, H * 0.92, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                --
                surface.SetDrawColor(255, 255, 255)
            end

            if FROZE_GL.tbl_ult.ult_clicked and FROZE_GL.tbl_ult.ult_cooldown > 0 and not FROZE_GL.tbl_ult.ult_key_combo_activated then
                draw.SimpleText("ULTIMATE STILL ON COOLDOWN!", gl .. "font_title_2", W * 0.5, H_half_screen, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            if FROZE_GL.show_weapon_stats then
                FROZE_GL.line_length = W * 0.8
                FROZE_GL.line_alpha_mul = 1
            else
                FROZE_GL.line_length = math.Approach(FROZE_GL.line_length, W, W * 0.015)
                FROZE_GL.line_alpha_mul = math.Approach(FROZE_GL.line_alpha_mul, 0, 0.15)
            end

            if FROZE_GL.line_alpha_mul > 0 and IsValid(ply_wep) and  FROZE_GL.gl_stored_bonused_weapons[ply_wep_class] ~= nil then
                if ply:Alive() then
                    weapon_name = ply_wep:GetPrintName()
                else
                    weapon_name = ""
                end

                local tbl_stored_wep = FROZE_GL.gl_stored_bonused_weapons[ply_wep_class]

                FROZE_GL.show_weapon_stats_lifetime = FROZE_GL.show_weapon_stats_lifetime + RFT 
                
                if FROZE_GL.show_weapon_stats_lifetime >= 1.5 then 
                    FROZE_GL.show_weapon_stats_base_mod_num = true
                else 
                    FROZE_GL.show_weapon_stats_base_mod_num = false
                end

                -- print("lifetime: " .. FROZE_GL.show_weapon_stats_lifetime)

                -- PrintTable( tbl_stored_wep)

                local rarity =  tbl_stored_wep.rarity
                local element =  tbl_stored_wep.element
                local tbl_rarity_color = FROZE_GL.tbl_rarity_colors[rarity]
                surface.SetAlphaMultiplier(FROZE_GL.line_alpha_mul)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetDrawColor(tbl_rarity_color.r, tbl_rarity_color.g, tbl_rarity_color.b)
                surface.DrawLine(FROZE_GL.line_length, H_half_screen, W, H_half_screen)
                surface.DrawLine(FROZE_GL.line_length, H_half_screen + 1, W, H_half_screen + 1)
                surface.DrawLine(FROZE_GL.line_length, H_half_screen + 2, W, H_half_screen + 2)
                surface.DrawLine(FROZE_GL.line_length, H_half_screen + 3, W, H_half_screen + 3)
                surface.DrawLine(FROZE_GL.line_length, H_half_screen + 4, W, H_half_screen + 4)            

                for k, v in pairs(FROZE_GL.tbl_elements) do 
                    if v.name == element then 
                        surface.SetDrawColor(255, 255, 255)
                        surface.SetMaterial(v.mat_1)
                        surface.DrawTexturedRect(FROZE_GL.line_length, H * 0.48 - W * 0.015 / 2, W * 0.015, W * 0.015)
                    end
                end

                -- surface.SetMaterial()
                gl_cse(ply, FROZE_GL.line_length, H * 0.45, string.upper(rarity), "", "", true, false, "", false, gl .. "font_title_3", FROZE_GL.tbl_rarity_colors[rarity], false)
                gl_cse(ply, FROZE_GL.line_length + W * 0.017, H * 0.48, "", "", weapon_name, true, false, "", false, gl .. "font_title_2", FROZE_GL.tbl_rarity_colors[rarity], false)

                if FROZE_GL.show_weapon_stats_base_mod_num then                        
                    local wep = ply_wep
                    local base_mod_num = tbl_stored_wep.base_rarity_mod_num
                    local color_text 

                    if base_mod_num > 1 then 
                        color_text = nil 
                    else
                        color_text = color_red
                    end 

                    local is_tfa_melee = garlic_like_is_tfa_melee(wep)

                    local power = garlic_like_get_wep_power(ply, wep)
                    local dmg 
                    local dmg_melee_1
                    local dmg_melee_2                            
                    local range_1
                    local aspd_1
                    local aspd_2
                    local numshot
                    local rpm 
                    local magcap
                    local recoil 
                    local text_numshot
                    
                    local tbl_wep_primary = (wep.Primary)  
                    local tbl_wep_secondary = (wep.Secondary)  
                    
                    if garlic_like_is_arccw_wep(wep) then 
                        dmg = wep.Damage * base_mod_num
                        rpm = (60 / wep.Delay) * base_mod_num
                        numshot = wep.Num
                        magcap = tbl_wep_primary.ClipSize * base_mod_num
                        recoil = 1 / base_mod_num
                    elseif garlic_like_is_tfa_wep(wep) then 
                        if is_tfa_melee then 
                            dmg_melee_1 = tbl_wep_primary.Attacks[1].dmg * base_mod_num
                            dmg_melee_2 = tbl_wep_secondary.Attacks[1].dmg * base_mod_num
                            aspd_1 = 1 / tbl_wep_primary.Attacks[1]['end'] * base_mod_num
                            aspd_2 = 1 / tbl_wep_secondary.Attacks[1]['end'] * base_mod_num
                            range_1 = tbl_wep_primary.Attacks[1].len * base_mod_num
                            range_2 = tbl_wep_secondary.Attacks[1].len * base_mod_num
                        else
                            if tbl_wep_primary then 
                                dmg = tbl_wep_primary.Damage * base_mod_num
                                rpm = tbl_wep_primary.RPM * base_mod_num
                                numshot = tbl_wep_primary.NumShots
                                magcap = tbl_wep_primary.ClipSize * base_mod_num
                                recoil = 1 / base_mod_num
                            else 
                                dmg = 1
                                rpm = 1
                                numshot = 1
                                magcap = 1
                                recoil = 1
                            end
                        end
                    end 

                    if dmg then 
                        dmg = math.Round(dmg)
                        rpm = math.Round(rpm)
                        magcap = math.Round(magcap) 
                        recoil = math.Truncate(recoil, 3)
                        text_numshot = (numshot > 1) and "x" .. numshot or ""
                    else 
                        dmg = ""
                        rpm = ""
                        magcap = ""
                        text_numshot = ""
                    end

                    if dmg_melee_1 then 
                        dmg_melee_1 = math.Round(dmg_melee_1)
                        dmg_melee_2 = math.Round(dmg_melee_2)
                        aspd_1 = math.Truncate(aspd_1, 3)
                        aspd_2 = math.Truncate(aspd_2, 3)
                        range_1 = math.Round(range_1)
                        range_2 = math.Round(range_2)
                    end                            
                                        
                    gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((1) * H * 0.035), "x" .. base_mod_num, " ", "Base Stat Modifier", true, false, "", false, gl .. "font_subtitle_2", color_text, false)

                    color_text = nil

                    gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((0) * H * 0.035), power, " ", "Power", true, false, "", false, gl .. "font_subtitle_2", color_text, false)

                    --* if it's a tfa melee
                    if is_tfa_melee then  
                        gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((2) * H * 0.035), "", dmg_melee_1, " LMB DMG", true, false, "", false, gl .. "font_subtitle_2", color_text, false)
                        gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((3) * H * 0.035), "", aspd_1, " LMB ASPD", true, false, "", false, gl .. "font_subtitle_2", color_text, false)
                        gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((4) * H * 0.035), "", range_1, " LMB RAMGE", true, false, "", false, gl .. "font_subtitle_2", color_text, false)
                        gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((5) * H * 0.035), "", dmg_melee_2, " RMB DMG", true, false, "", false, gl .. "font_subtitle_2", color_text, false)                                
                        gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((6) * H * 0.035), "", aspd_2, " RMB ASPD", true, false, "", false, gl .. "font_subtitle_2", color_text, false)                                
                        gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((7) * H * 0.035), "", range_2, " RMB RAMGE", true, false, "", false, gl .. "font_subtitle_2", color_text, false)
                    else --* if it's a gun
                        gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((2) * H * 0.035), "", dmg .. text_numshot, " DMG", true, false, "", false, gl .. "font_subtitle_2", color_text, false)
                        gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((3) * H * 0.035), "", rpm, " RPM", true, false, "", false, gl .. "font_subtitle_2", color_text, false)
                        gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((4) * H * 0.035), "", magcap, " Magazine Capacity", true, false, "", false, gl .. "font_subtitle_2", color_text, false)
                        gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((5) * H * 0.035), "x", base_mod_num, " Reload Speed", true, false, "", false, gl .. "font_subtitle_2", color_text, false)        
                        gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((6) * H * 0.035), "x", recoil, " Recoil", true, false, "", false, gl .. "font_subtitle_2", color_text, false)        
                    end
                else
                    if tbl_stored_wep.bonus_amount > 0 then
                        for k, bonus in pairs( tbl_stored_wep.bonuses) do
                            gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((k - 1) * H * 0.035), "", 100 * bonus.modifier .. "%", " " .. bonus.desc, true, false, "", false, gl .. "font_subtitle_2", nil, false)
                        end
                    end
                end
            end

            if FROZE_GL.line_alpha_mul <= 0 then 
                FROZE_GL.show_weapon_stats_lifetime = 0
                FROZE_GL.show_weapon_stats_base_mod_num = false
            end

            surface.SetAlphaMultiplier(1)
            cam.End2D()

            -- FROZE_GL.weapon_image = "vgui/entities/" .. FROZE_GL.weapons_table_filtered[math.random(#FROZE_GL.weapons_table_filtered)].ClassName
            -- surface.SetDrawColor(255, 255, 255)
            -- surface.SetMaterial(Material(FROZE_GL.weapon_image))
            -- surface.DrawTexturedRect(up_text_width, H * 0.5 - W * 0.05, W * 0.1, W * 0.1)
            -- -- function gl_cse(ply, pos_x, pos_y, front_operator, numbers, short_desc, align_center_y, additional_front_text, front_text, rainbow, font, color, align_center_x)
            -- gl_cse(ply, W * 0.5, H * 0.62, FROZE_GL.weapon_rarity_random, "", FROZE_GL.weapon_name_random, true, false, "", false, gl .. "font_title_3", nil, true)
            do
            end
        end) 

        hook.Add("PostDrawHUD", gl .. "stats_screen", function()
            if not GetConVar(gl .. "enable"):GetBool() then return end   
            ply = LocalPlayer()
            if not ply:Alive() then return end
            if not IsValid(ply) then return end
            if not IsValid(ply:GetActiveWeapon()) then return end
            ply_wep = ply:GetActiveWeapon()
            ply_wep_class = ply_wep:GetClass()

            if ply_wep_2 ~= nil and ply_wep_2 ~= ply_wep then
                FROZE_GL.show_weapon_stats = true 
                FROZE_GL.show_weapon_stats_lifetime = 0

                timer.Create("show_stats_" .. ply:Nick(), 2.5, 1, function()
                    FROZE_GL.show_weapon_stats = false 
                end)
            end

            ply_wep_2 = ply_wep

            cam.Start2D()
            if ply:KeyDown(IN_WALK) then
                ply.garlic_like_is_opening_stats_screen = true
                FROZE_GL.show_weapon_stats = true

                if FROZE_GL.stats_menu == "STATS" then
                    if ply:KeyPressed(IN_USE) then
                        FROZE_GL.stats_menu = "SKILLS"
                    end

                    draw.RoundedBox(0, 0, 0, W, H, color_black_alpha_150)
                    draw.RoundedBox(8, W * 0.15, H * 0.1, W * 0.7, H * 0.42, Color(0, 0, 0, 200))
                    draw.SimpleText("STATS", gl .. "font_title", FROZE_GL.tbl_glss.glss_mid_pos_base, H * 0.1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.RoundedBox(4, FROZE_GL.tbl_glss.glss_left_pos, FROZE_GL.tbl_glss.glss_height_1, W * 0.05, H * 0.1, color_black_alpha_150)
                    draw.RoundedBox(4, FROZE_GL.tbl_glss.glss_mid_pos, FROZE_GL.tbl_glss.glss_height_1, W * 0.05, H * 0.1, color_black_alpha_150)
                    draw.RoundedBox(4, FROZE_GL.tbl_glss.glss_right_pos, FROZE_GL.tbl_glss.glss_height_1, W * 0.05, H * 0.1, color_black_alpha_150)
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(FROZE_GL.mat_icon_str)
                    surface.DrawTexturedRect(FROZE_GL.tbl_glss.glss_left_pos, FROZE_GL.tbl_glss.glss_height_1, W * 0.05, H * 0.1)
                    surface.SetMaterial(FROZE_GL.mat_icon_agi)
                    surface.DrawTexturedRect(FROZE_GL.tbl_glss.glss_mid_pos, FROZE_GL.tbl_glss.glss_height_1, W * 0.05, H * 0.1)
                    surface.SetMaterial(FROZE_GL.mat_icon_int)
                    surface.DrawTexturedRect(FROZE_GL.tbl_glss.glss_right_pos, FROZE_GL.tbl_glss.glss_height_1, W * 0.05, H * 0.1)
                    -- 
                    draw.SimpleText("STR", gl .. "font_subtitle", FROZE_GL.tbl_glss.glss_left_pos_base, FROZE_GL.tbl_glss.glss_height_1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("AGI", gl .. "font_subtitle", FROZE_GL.tbl_glss.glss_mid_pos_base, FROZE_GL.tbl_glss.glss_height_1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("INT", gl .. "font_subtitle", FROZE_GL.tbl_glss.glss_right_pos_base, FROZE_GL.tbl_glss.glss_height_1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(math.Truncate(ply:GetNWInt(gl .. "STR", 0), 1), gl .. "font_title", FROZE_GL.tbl_glss.glss_left_pos_base, H * 0.29, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(math.Truncate(ply:GetNWInt(gl .. "AGI", 0), 1), gl .. "font_title", FROZE_GL.tbl_glss.glss_mid_pos_base, H * 0.29, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(math.Truncate(ply:GetNWInt(gl .. "INT", 0), 1), gl .. "font_title", FROZE_GL.tbl_glss.glss_right_pos_base, H * 0.29, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        
                    for k, entry in ipairs(FROZE_GL.tbl_character_stats) do  
                        if entry.stat_type == "EXTRA" then continue end 
                        --
                        local prefix_symbol 
                        local value
                        local index_for_pos
                        local x_pos
                        local added_value = 0 --* added value depends on if the upgrade is reductive or multiplicative.
                        
                        if entry.stat_type == "STR" then 
                            index_for_pos = k
                            x_pos = FROZE_GL.tbl_glss.glss_left_pos_base
                        elseif entry.stat_type == "AGI" then 
                            index_for_pos = k - 6
                            x_pos = FROZE_GL.tbl_glss.glss_mid_pos_base
                        elseif entry.stat_type == "INT" then 
                            index_for_pos = k - 13
                            x_pos = FROZE_GL.tbl_glss.glss_right_pos_base
                        end

                        local wep_modifier = ply:GetNWFloat(gl .. ply_wep_class .. entry.weapon_upgrade_id, 1)
                        local operation_type_num = 0

                        if entry.upgrade_type == "INT" then 
                            prefix_symbol = "+"
                            value = math.Round(ply:GetNWInt(entry.id, 0) * wep_modifier)
                        else
                            if entry.name == "Critical Damage" then 
                                added_value = 1
                            elseif entry.name == "Cooldown Reduction" then 
                                added_value = -1 
                            end

                            if entry.operation_type and entry.operation_type == "reducing_mult" then 
                                -- print("REDUCING MULT NAME: " .. entry.name)
                                -- print("MODIFIER NUM: " .. wep_modifier)
                                operation_type_num = 2
                            elseif not entry.operation_type then 
                                operation_type_num = wep_modifier * 2
                            end

                            prefix_symbol = "%"
                            -- print("WEP MODIFIER: " .. wep_modifier)
                            value = math.abs(math.Truncate(math.min(entry.max_stat or 999, (ply:GetNWFloat(entry.id, 0) + added_value) * math.abs(operation_type_num - wep_modifier)), 3) * 100)

                            if entry.name == "Evasion Chance" then 
                                -- print("BASE EVASION CHANCE: " .. ply:GetNWFloat(entry.id, 0))
                                -- print("EVASIONW WEP MOD: " .. wep_modifier - 1)
                                local chance_evading = math.min(entry.max_stat, (1 - ((1 - ply:GetNWFloat(entry.id, 0)) - (1 - ply:GetNWFloat(entry.id, 0)) * (wep_modifier - 1))))                            
                                wep_modifier = ply:GetNWFloat(gl .. ply_wep_class .. entry.weapon_upgrade_id, 0)
                                value = math.Truncate(chance_evading, 3) * 100
                            end
 
                            if entry.name == "Critical Chance" then        
                                if ply_wep:Clip1() >= ply_wep:GetMaxClip1() then               
                                    value = math.Round(value * (1 + ply:GetNWFloat(gl .. rh .. "preemptive_strike_mul_2", 0)), 2)
                                end
                            end

                            if entry.name == "Bonus Damage" then    
                                if ply_wep:Clip1() >= ply_wep:GetMaxClip1() then    
                                    value = math.Round(value * (1 + ply:GetNWFloat(gl .. rh .. "preemptive_strike_mul", 0)), 2)
                                end
                            end
                        end
                        
                        print("entry name: " .. entry.name)
                        print("stat type: " .. entry.stat_type)
                        print("index for pos: " .. index_for_pos)
                        PrintTable(FROZE_GL.heights_stat_menu_desc)
                        print("y pos: " .. FROZE_GL.heights_stat_menu_desc[index_for_pos])
                        gl_cse(ply, x_pos, FROZE_GL.heights_stat_menu_desc[index_for_pos], prefix_symbol, value, " " .. (entry.name), false, false, "", false, gl .. "font_stat_entry")     
                    end    
                    
                    -- ITEMS BOX
                    draw.RoundedBox(8, W * 0.15, H * 0.595, W * 0.7, H * 0.235, Color(0, 0, 0, 200))
                    draw.SimpleText("ITEMS", gl .. "font_title", W * 0.5, H * 0.595, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    -- draw.RoundedBox(4, W * 0.15, H * 0.8, W * 0.7, H * 0.15, color_black_alpha_150)
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawCircle(W * 0.25, H * 0.7, W * 0.035, FROZE_GL.item_circle_colors[1])
                    surface.DrawCircle(W * 0.417, H * 0.7, W * 0.035, FROZE_GL.item_circle_colors[2])
                    surface.DrawCircle(W * 0.584, H * 0.7, W * 0.035, FROZE_GL.item_circle_colors[3])
                    surface.DrawCircle(W * 0.75, H * 0.7, W * 0.035, FROZE_GL.item_circle_colors[4])
                    -- DRAW ITEMS
                    surface.SetDrawColor(255, 255, 255, 255)

                    -- for i = 1, 4 do
                    for i, upgrade in SortedPairs(table.ClearKeys(FROZE_GL.items_held)) do
                        -- surface.SetMaterial(Material("garlic_like/icon_orb_xp.png"))
                        surface.SetMaterial(Material(upgrade.icon))
                        surface.DrawTexturedRect(W * (0.084 + i * 0.167) - W * 0.03, H * 0.65, W * 0.06, H * 0.1)
                        --
                        -- draw.SimpleText("SAMPLE ITEM", gl .. "font_subtitle", W * (0.112 + i * 0.167) - W * 0.03, H * 0.6, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        -- draw.SimpleText(string.upper(upgrade.name), gl .. "font_subtitle", W * (0.112 + i * 0.167) - W * 0.03, H * 0.62, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        gl_cse(ply, W * (0.112 + i * 0.167) - W * 0.03, H * 0.62, "", " (x" .. upgrade.stacks .. ")", "", true, "", string.upper(upgrade.name), false, gl .. "font_subtitle", nil, true)
                        -- draw.SimpleText("SAMPLE DESC", gl .. "font_subtitle", W * (0.112 + i * 0.167) - W * 0.03, H * 0.77, Color(0, 219, 37), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        draw.SimpleText(string.upper(upgrade.rarity), gl .. "font_subtitle", W * (0.112 + i * 0.167) - W * 0.03, H * 0.78, FROZE_GL.item_circle_colors[i], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        gl_cse(ply, W * (0.112 + i * 0.167) - W * 0.03, H * 0.81, "x", math.abs(upgrade.number_addition + upgrade.statboost), " " .. upgrade.desc_short, true)
                        -- draw.SimpleText("x" .. math.abs(upgrade.number_addition + upgrade.statboost) .. " " .. upgrade.desc_short, gl .. "font_subtitle", W * (0.112 + i * 0.167) - W * 0.03, H * 0.81, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                elseif FROZE_GL.stats_menu == "SKILLS" then
                    if ply:KeyPressed(IN_USE) then
                        FROZE_GL.stats_menu = "RELICS"
                    end

                    draw.RoundedBox(0, 0, 0, W, H, color_black_alpha_150)
                    -- draw.RoundedBox(8, W * 0.05, H * 0.1, W * 0.9, H * 0.85, Color(0, 0, 0, 200))
                    draw.SimpleText("SKILLS", gl .. "font_title", FROZE_GL.tbl_glss.glss_mid_pos_base, H * 0.06, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    for i = 1, 4 do
                        draw.RoundedBox(8, (i * W * 0.2) - W * 0.092, H * 0.095, W * 0.19, H * 0.4, Color(0, 0, 0, 200))
                        draw.RoundedBox(0, (i * W * 0.2) - W * 0.032, H * 0.15, W * 0.07, W * 0.07, Color(0, 0, 0, 200))
                    end

                    for i, skill in SortedPairs(table.ClearKeys(FROZE_GL.skills_held)) do
                        if ply:GetNWInt(gl .. "mana") >= skill.damage then
                            mana_damage_buff = 1 + ply:GetNWFloat(gl .. "bonus_mana_damage")
                        else
                            mana_damage_buff = 1
                        end

                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(Material(skill.icon))
                        surface.DrawTexturedRect((i * W * 0.2) - W * 0.032, H * 0.15, W * 0.07, W * 0.07)
                        --
                        -- gl_cse(ply, pos_x, pos_y, front_operator, numbers, short_desc)
                        --
                        draw.DrawText(string.upper(skill.name), gl .. "font_title_2", (i * W * 0.2) + W * 0.0025, H * 0.1025, color_white, TEXT_ALIGN_CENTER)
                        draw.DrawText(string.upper(skill.rarity), gl .. "font_subtitle", (i * W * 0.2) + W * 0.0025, H * 0.295, FROZE_GL.skill_circle_colors[i], TEXT_ALIGN_CENTER)
                        draw.DrawText(skill.desc, gl .. "font_subtitle", (i * W * 0.2) + W * 0.0025, H * 0.335, color_white, TEXT_ALIGN_CENTER)
                        --
                        -- print(skill.name2)
                        gl_cse(ply, (i * W * 0.2) + W * 0.0025, H * 0.41, "", math.Round(skill.damage * (1 + ply:GetNWFloat(gl .. "bonus_damage")) * mana_damage_buff), " DAMAGE", false, false, "", false, gl .. "font_stat_entry")
                        gl_cse(ply, (i * W * 0.2) + W * 0.0025, H * 0.435, "", math.Truncate(GetConVar("dota2_auto_cast_" .. skill.name2 .. "_delay"):GetFloat(), 3), " COOLDOWN", false, false, "", false, gl .. "font_stat_entry")
                        gl_cse(ply, (i * W * 0.2) + W * 0.0025, H * 0.46, "", skill.area, " RANGE", false, false, "", false, gl .. "font_stat_entry")                    
                    end

                    -- for i = 1, 4 do
                    --     draw.DrawText("TITLE", gl .. "font_title", (i * W * 0.2) + W * 0.0025, H * 0.125, color_white, TEXT_ALIGN_CENTER)
                    --     draw.DrawText("RARITY", gl .. "font_subtitle", (i * W * 0.2) + W * 0.0025, H * 0.325, color_white, TEXT_ALIGN_CENTER)
                    --     draw.DrawText("WRITING WRITING WRITING\nWRTIING WRITING", gl .. "font_subtitle", (i * W * 0.2) + W * 0.0025, H * 0.365, color_white, TEXT_ALIGN_CENTER)
                    --     draw.DrawText("1000" .. " SAMPLE_TEXT \n" .. "1" .. "s SAMPLE_TEXT \n" .. "200", gl .. "font_subtitle", (i * W * 0.2) + W * 0.0025, H * 0.44, color_white, TEXT_ALIGN_CENTER)
                    -- end
                    for i = 1, 4 do
                        surface.SetDrawColor(FROZE_GL.skill_circle_colors[i])
                        surface.DrawOutlinedRect((i * W * 0.2) - W * 0.032, H * 0.15, W * 0.07, W * 0.07, 1)
                    end

                    -- RELICS HUD
                    draw.SimpleText("RELICS", gl .. "font_title", FROZE_GL.tbl_glss.glss_mid_pos_base, H * 0.53, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    for i = 1, 4 do
                        draw.RoundedBox(8, (i * W * 0.2) - W * 0.092, H * 0.565, W * 0.19, H * 0.4, Color(0, 0, 0, 200))
                        draw.RoundedBox(0, (i * W * 0.2) - W * 0.032, H * 0.62, W * 0.07, W * 0.07, Color(0, 0, 0, 200))
                    end

                    for i, relic in SortedPairs(table.ClearKeys(FROZE_GL.relics_held)) do
                        if i > 4 then continue end
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(Material(relic.icon))
                        surface.DrawTexturedRect((i * W * 0.2) - W * 0.032, H * 0.62, W * 0.07, W * 0.07) 
                        draw.DrawText(string.upper(relic.name), gl .. "font_title_2", (i * W * 0.2) + W * 0.0025, H * 0.5725, color_white, TEXT_ALIGN_CENTER)
                        draw.DrawText(string.upper(relic.rarity), gl .. "font_subtitle", (i * W * 0.2) + W * 0.0025, H * 0.765, FROZE_GL.skill_circle_colors[i], TEXT_ALIGN_CENTER)
                        draw.DrawText(relic.desc, gl .. "font_subtitle_small", (i * W * 0.2) + W * 0.0025, H * 0.805, color_white, TEXT_ALIGN_CENTER)

                        --
                        if relic.mul_is_second then
                            gl_cse(ply, (i * W * 0.2) + W * 0.0025, H * 0.88, "s", relic.mul, relic.shortdesc, false, false, "", false, gl .. "font_stat_entry")
                        elseif relic.mul_is_debuff then
                            gl_cse(ply, (i * W * 0.2) + W * 0.0025, H * 0.88, "%", relic.mul * 100, relic.shortdesc, false, false, "", false, gl .. "font_stat_entry", color_red)
                        else
                            gl_cse(ply, (i * W * 0.2) + W * 0.0025, H * 0.88, "%", relic.mul * 100, relic.shortdesc, false, false, "", false, gl .. "font_stat_entry")
                        end

                        if relic.mul_2 ~= nil then
                            gl_cse(ply, (i * W * 0.2) + W * 0.0025, H * 0.905, "%", relic.mul_2 * 100, relic.shortdesc_2, false, false, "", false, gl .. "font_stat_entry")
                        end 
                    end

                    for i = 1, 4 do
                        surface.SetDrawColor(FROZE_GL.relic_circle_colors[i])
                        surface.DrawOutlinedRect((i * W * 0.2) - W * 0.032, H * 0.62, W * 0.07, W * 0.07, 1)
                    end
                elseif FROZE_GL.stats_menu == "RELICS" then 
                    if ply:KeyPressed(IN_USE) then
                        FROZE_GL.stats_menu = "STATS"
                    end
    
                    local mod_y_1 = H * 0.47
                    local i_x = 0
                    
                    draw.RoundedBox(0, 0, 0, W, H, color_black_alpha_150) 
                    draw.SimpleText("RELICS", gl .. "font_title", FROZE_GL.tbl_glss.glss_mid_pos_base, H * 0.53 - mod_y_1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    -- creates black boxes
                    for i = 1, 8 do
                        i_x = i

                        if i > 4 then 
                            mod_y_1 = 0
                            i_x = i_x - 4
                        end

                        draw.RoundedBox(8, (i_x * W * 0.2) - W * 0.092, H * 0.565 - mod_y_1, W * 0.19, H * 0.4, color_black_alpha_200)
                        draw.RoundedBox(0, (i_x * W * 0.2) - W * 0.032, H * 0.62 - mod_y_1, W * 0.07, W * 0.07, color_black_alpha_200)
                    end

                    -- PrintTable(FROZE_GL.relics_held)  
                    local mod_y_1 = H * 0.47
                    local i_x = 0

                    for i, relic in SortedPairs(table.ClearKeys(FROZE_GL.relics_held)) do
                        -- print("key: " .. i) 
                        -- PrintTable(relic)
                        if i > 4 then                         
                            i_x = i

                            if i > 8 then 
                                mod_y_1 = 0
                                i_x = i_x - 4
                            end
    
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.SetMaterial(Material(relic.icon))
                            surface.DrawTexturedRect(((i - 4) * W * 0.2) - W * 0.032, H * 0.62 - mod_y_1, W * 0.07, W * 0.07) 
                            draw.DrawText(string.upper(relic.name), gl .. "font_title_2", ((i - 4) * W * 0.2) + W * 0.0025, H * 0.5725 - mod_y_1, color_white, TEXT_ALIGN_CENTER)
                            draw.DrawText(string.upper(relic.rarity), gl .. "font_subtitle", ((i - 4) * W * 0.2) + W * 0.0025, H * 0.765 - mod_y_1, FROZE_GL.skill_circle_colors[(i - 4)], TEXT_ALIGN_CENTER)
                            draw.DrawText(relic.desc, gl .. "font_subtitle_small", ((i - 4) * W * 0.2) + W * 0.0025, H * 0.805 - mod_y_1, color_white, TEXT_ALIGN_CENTER)
            
                            if relic.mul_is_second then
                                gl_cse(ply, ((i - 4) * W * 0.2) + W * 0.0025, H * 0.88 - mod_y_1, "s", relic.mul, relic.shortdesc, false, false, "", false, gl .. "font_stat_entry")
                            elseif relic.mul_is_debuff then
                                gl_cse(ply, ((i - 4) * W * 0.2) + W * 0.0025, H * 0.88 - mod_y_1, "%", relic.mul * 100, relic.shortdesc, false, false, "", false, gl .. "font_stat_entry", color_red)
                            else
                                gl_cse(ply, ((i - 4) * W * 0.2) + W * 0.0025, H * 0.88 - mod_y_1, "%", relic.mul * 100, relic.shortdesc, false, false, "", false, gl .. "font_stat_entry")
                            end

                            if relic.mul_2 ~= nil then
                                gl_cse(ply, ((i - 4) * W * 0.2) + W * 0.0025, H * 0.905 - mod_y_1, "%", relic.mul_2 * 100, relic.shortdesc_2, false, false, "", false, gl .. "font_stat_entry")
                            end 
                        end
                    end

                    local mod_y_1 = H * 0.47
                    local i_x = 0

                    -- creates rarity outlines
                    for i = 1, 8 do
                        i_x = i

                        if i > 4 then 
                            mod_y_1 = 0
                            i_x = i_x - 4
                        end

                        surface.SetDrawColor(FROZE_GL.relic_circle_colors[i + 4])
                        surface.DrawOutlinedRect((i_x * W * 0.2) - W * 0.032, H * 0.62 - mod_y_1, W * 0.07, W * 0.07, 1)

                        if i > ply:GetNWInt(gl .. "relic_slots_unlocked", 0) then 
                            draw.RoundedBox(8, (i_x * W * 0.2) - W * 0.092, H * 0.565 - mod_y_1, W * 0.19, H * 0.4, Color(111, 111, 111, 55))
                            draw.RoundedBox(0, (i_x * W * 0.2) - W * 0.032, H * 0.62 - mod_y_1, W * 0.07, W * 0.07, Color(111, 111, 111, 55))
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.SetMaterial(FROZE_GL.mat_padlock)
                            surface.DrawTexturedRect((i_x * W * 0.2) - W * 0.032, H * 0.62 - mod_y_1, W * 0.07, W * 0.07) 
                        end
                    end 
                end
            end

            if ply:KeyReleased(IN_WALK) then
                ply.garlic_like_is_opening_stats_screen = false
                FROZE_GL.show_weapon_stats_lifetime = 0

                timer.Create("show_stats_" .. ply:Nick(), 3, 1, function()
                    FROZE_GL.show_weapon_stats = false
                end)
            end
            cam.End2D()
        end)

        hook.Add("PreDrawHalos", gl .. "draw_halo", function()
            if not GetConVar(gl .. "enable"):GetBool() then return end 
            
            outline.Add(ents.FindByClass(gl .. "weapon_crate_entity"), color_yellow, 0) 
            outline.Add(ents.FindByClass(gl .. "station_item_fusing"), color_blue, 0)
            outline.Add(ents.FindByClass(gl .. "station_weapon_upgrade"), color_blue, 0)
            outline.Add(ents.FindByClass(gl .. "item_barrel"), color_yellow, 0) 
            
            for rarity, color in SortedPairs(FROZE_GL.tbl_rarity_colors) do  
                if #FROZE_GL.tbl_crystal_clusters[rarity] > 0 then 
                    outline.Add(FROZE_GL.tbl_crystal_clusters[rarity], color, 0)
                end
            end      
        end)

        hook.Add("HUDShouldDraw", gl .. "HideHUD", function( name )
            if not GetConVar(gl .. "enable"):GetBool() then return end

            if ( FROZE_GL.hide[ name ] ) then
                return false
            end

            -- if name == "CHudHealth" then 
            --     return false
            -- end

            -- Don't return anything here, it may break other addons that rely on this hook.
        end)
    end

    --* concommands
    do 
        concommand.Add(gl .. "debug_populate_menu_inventory", function(ply, cmd, args, argStr) 
            for i = 1, 15 do 
                local weight_rolled = math.random(1, FROZE_GL.valid_inventory_items_max_weight)
                print("weight rolled: " .. weight_rolled)

                for k, v in ipairs(FROZE_GL.tbl_valid_inventory_items) do 
                    if not v.ru_reward then continue end 

                    if IsNumBetween(weight_rolled, v.drop_weight_min_ru, v.drop_weight_max_ru) then 
                        garlic_like_add_inventory_item(v.name, 1)  
                    end
                end
            end

            garlic_like_save_menu_inventory()
        end)

        concommand.Add(gl .. "debug_show_achievement_unlock", function(ply, cmd, args, argStr)
            table.insert(FROZE_GL.tbl_unlocks_queue, #FROZE_GL.tbl_unlocks_queue + 1, args[1])

            -- if not FROZE_GL.tbl_unlocks_hud.isrunning then  
            --     FROZE_GL.tbl_unlocks_hud = {
            --         pos_x_bg = W * 0.77, 
            --         pos_y_bg = -H * 0.12, 
            --         target_pos_x_bg = W * 0.77, 
            --         target_pos_y_bg = H * 0.01, 
            --         w_bg = W * 0.22, 
            --         h_bg = H * 0.12,
            --         lifetime = 0,
            --         text = args[1],
            --         show = true,
            --         isrunning = true,
            --     }
            -- else 
            -- end
        end)

        concommand.Add(gl .. "TEST_COS", function(ply, cmd, args, argStr) 
            local panel_base = vgui.Create("DPanel") 

            timer.Simple(5, function() 
                panel_base:Remove()
            end)

            panel_base:SetSize(W * 0.5, H * 0.5)
            panel_base:Center()
            panel_base:MakePopup() 
            --
            local mod_speed = 30
            local button = vgui.Create("DButton", panel_base) 
            button.mod_w = 1
            button.mod_h = 1
            button.size_w = panel_base:GetWide() * 0.2
            button.size_h = panel_base:GetTall() * 0.2
            --
            local button_2 = vgui.Create("DButton", panel_base) 
            -- 
            button:SetSize(button.size_w, button.size_h)
            button:CenterHorizontal()
            button:CenterVertical(0.25) 
            button:SetText("")    
            -- 
            button.Think = function(self) 
                if self.resize then 
                    local mod = 1 + math.abs(-math.cos(CurTime() * mod_speed - self.starttime) + 1) / 8 
                    self:SetSize(self.size_w * mod, self.size_h * mod)
                    self:CenterHorizontal()
                    self:CenterVertical(0.25)
                    
                    if not self.hitmax and mod >= 1.24 then 
                        self.hitmax = true            
                    end

                    if self.hitmax and mod <= 1.01 then 
                        self.resize = false
                        self.hitmax = false
                        self.mod_w, self.mod_h = 1, 1
                    end         

                    -- print(mod)
                end
            end
            --
            button_2:SetSize(button_2:GetParent():GetWide() * 0.2, button_2:GetParent():GetTall() * 0.2) 
            button_2:MoveBelow(button, button_2:GetParent():GetTall() * 0.3)
            button_2:CenterHorizontal()
            --
            button_2.DoClick = function(self) 
                button:SetSize(self.size_w, self.size_h)
                button.hitmax = false
                button.resize = true
                button.starttime = CurTime() * mod_speed 
            end 
        end)  

        concommand.Add(gl .. "debug_rearrange_ehb_table", function(ply, cmd, args, argStr)
            local last_dist = 0
            local temp_storage

            for k, ent in pairs(valid_ehb_entities) do         
                if valid_ehb_entities[k + 1].ehb_dist_to_ply > valid_ehb_entities[k].ehb_dist_to_ply and k < #valid_ehb_entities then  
                    temp_storage = ent.ehb_dist_to_ply
                    valid_ehb_entities[k] = valid_ehb_entities[k + 1]
                    valid_ehb_entities[k + 1] = temp_storage
                    break
                end    
            end

            -- PrintTable(valid_ehb_entities)
        end)

        concommand.Add(gl .. "debug_item_pickup_test", function(ply, cmd, args, argStr) 
            -- FROZE_GL.glips.entries[#FROZE_GL.glips.entries + 1] = "entry" .. math.random() * 10000
            -- PrintTable(args)
            --* POLISH THE CODE!!!

            local rarity_color = FROZE_GL.tbl_rarity_colors[string.lower(args[3])]
            local entry_data = {}
            local insertable = true

            if args[4] == "ore" then 
                entry_data = {
                    text = args[1] or "test" .. math.random(),
                    item_type = args[4],
                    amount = math.Round(args[2]),
                    pos_x = -W * 0.03,
                    pos_x_mod = 0,
                    pos_y = 0,
                    lifetime = 0,
                    rarity = string.lower(args[3]), 
                    icon = FROZE_GL.WepCrystalsInventory[FROZE_GL.tbl_rarity_to_number[string.lower(args[3])]].material,
                    color_bg = Color(29, 27, 27, 200),
                    color_text = Color(rarity_color.r, rarity_color.g, rarity_color.b, 255),
                    color_text_held = Color(255, 255, 255, 255),
                    color_highlight = Color(rarity_color.r, rarity_color.g, rarity_color.b, 255),
                }
            elseif args[4] == "material" then 
                entry_data = {
                    text = args[1] or "test" .. math.random(),
                    item_type = args[4],
                    amount = math.Round(args[2]),
                    pos_x = -W * 0.03,
                    pos_x_mod = 0,
                    pos_y = 0,
                    lifetime = 0,
                    rarity = string.lower(args[3]), 
                    icon = FROZE_GL.tbl_materials_inventory[args[1]].material,
                    color_bg = Color(29, 27, 27, 200),
                    color_text = Color(rarity_color.r, rarity_color.g, rarity_color.b, 255),
                    color_text_held = Color(255, 255, 255, 255),
                    color_highlight = Color(rarity_color.r, rarity_color.g, rarity_color.b, 255),
                } 
            end

            if FROZE_GL.glips.entries then 
                for k, v in pairs(FROZE_GL.glips.entries) do 
                    if v.icon == entry_data.icon then 
                        v.lifetime = 0
                        v.color_highlight.a = 255 
                        v.color_bg.a = 200
                        v.color_text.a = 255 
                        v.color_text_held.a = 255
                        v.amount = v.amount + args[2]
                        insertable = false
                        -- print("FOUND SAME ITEM IN GELIPS") 
                    end
                end
            end        

            if insertable then        
                table.insert(FROZE_GL.glips.entries, 1, entry_data)
            end
        end)

        concommand.Add(gl .. "debug_open_weapon_upgrade_menu", function(ply, cmd, args, argStr)
            local menu_type = argStr

            if argStr == nil then 
                menu_type = "BLACKSMITH"
            end

            local color_button_orange = Color(255, 166, 0)
            local color_button_orange_pressed = Color(209, 136, 0)
            local color_button_grey = Color(100, 100, 100) 
            local gold = ply:GetNWInt(gl .. "money", 0)

            if menu_type == "BLACKSMITH" then  
                local tbl_bonus_labels = {}
                local tbl_reroll_buttons = {} 
                local tbl_bonus_locks = {}
                local tbl_material_icons = {}
                local tbl_material_labels = {}
                local weapon_tbl = {}
                local weapon_rarity_num = 0
                local weapon_rarity = "poor" 
                local price = 0
                --*
                local base_frame = vgui.Create("DPanel", nil, gl .. "base_frame_weapon_upgrade")
                bf = base_frame
                bf:SetSize(W * 0.5, H * 0.75)
                bf:Center()
                bf:MakePopup()
                bf:MoveToBack()
                local bf_w, bf_h = bf:GetWide(), bf:GetTall()
                --*
                local weapons_stored = vgui.Create("DPanel")
                weapons_stored:MakePopup()
                weapons_stored:SetSize(W * 0.23, H * 0.85)
                weapons_stored:Center()
                weapons_stored:MoveRightOf(bf, W * 0.01)
                weapons_stored:Hide()
                weapons_stored.IsHidden = true
                --*
                local weapons_stored_dscrollpanel = vgui.Create("DScrollPanel", weapons_stored)
                wsd = weapons_stored_dscrollpanel
                wsd:Dock(FILL)
                wsd:SetMouseInputEnabled(true)
                --* STORED WEAPONS RIGHT SIDE PANEL
                local label_weapons = wsd:Add("DLabel")
                label_weapons:SetSize(W * 0.4, H * 0.05)
                label_weapons:Dock(TOP)
                label_weapons:SetText("") 
                --*
                local button_upgrade = vgui.Create("DButton", bf)
                button_upgrade:SetSize(bf_w * 0.5, bf_h * 0.1)
                button_upgrade:Center()
                button_upgrade:SetY(bf_h * 0.725)
                button_upgrade:SetText("")
                --*
                local button_weapon_slot = vgui.Create("DButton", bf)
                button_weapon_slot:SetSize(bf_w * 0.25, bf_h * 0.15)
                button_weapon_slot:Center()
                button_weapon_slot:SetY(bf_h * 0.05)
                button_weapon_slot:SetText("")
                button_weapon_slot.gl_chosen_weapon = "NONE"
                --*
                local label_price = vgui.Create("DLabel", bf)
                label_price:SetFont(gl .. "font_subtitle")
                label_price:SetSize(bf_w, bf_h * 0.05)  
                label_price:MoveBelow(button_upgrade, 1)      
                label_price:CenterHorizontal()
                label_price:SetText("")
                --*
                local label_weapon_name = vgui.Create("DLabel", bf)
                label_weapon_name:SetSize(bf_w * 0.85, bf_h * 0.1)
                label_weapon_name:Center()
                label_weapon_name:MoveBelow(button_weapon_slot, bf_h * 0.04)
                label_weapon_name:SetText("") 
                --*
                local label_upgrade_cost = vgui.Create("DLabel", bf)
                label_upgrade_cost:SetSize(bf_w * 0.85, bf_h * 0.05)
                label_upgrade_cost:Center()
                label_upgrade_cost:MoveBelow(button_upgrade, bf_h * 0.05)
                label_upgrade_cost:SetText("")
                --* 
                local reroll_button_element = vgui.Create("DImageButton", bf) 
                local rbe = reroll_button_element 
                rbe:SetSize(bf_w * 0.03, bf_h * 0.04)
                rbe:MoveRightOf(label_weapon_name, 0)
                rbe:SetY(label_weapon_name:GetY() + bf_h * 0.03)
                rbe:Hide()
                rbe.erc_needed = 0
                rbe.alpha_element = 0
                --*
                local dpanel_material_showcase = vgui.Create("DPanel", bf)
                dms = dpanel_material_showcase
                dms:SetSize(bf_w * 0.95, bf_h * 0.125)
                dms:Center()
                dms:MoveBelow(button_upgrade, bf_h * 0.015)
                --*
                local button_exit = vgui.Create("DButton", bf)
                button_exit:SetSize(bf_w * 0.1, bf_h * 0.05)
                button_exit:SetText("EXIT")
                button_exit:SetY(bf_h * 0.025)
                button_exit:SetX(bf_w * 0.025)  
                --
                local required_reroll_crystals = 1                    

                --* BONUS / AFFIXES DISPLAY
                --* NEW FINISH STAT REROLL CURSOR TOOLTIP TO SHOW HELD NUM OF REROLL CRYSTALS
                for i = 1, 7 do
                    local bonus_label = vgui.Create("DLabel", bf)
                    bonus_label:SetSize(bf_w * 0.8, bf_h * 0.045)
                    bonus_label:CenterHorizontal()
                    -- bonus_label:SetX(bf_w * 0.075)
                    bonus_label:SetY(bf_h * 0.3 + i * bf_h * 0.05)
                    bonus_label:SetText("")
                    bonus_label.bonus_text_front = ""
                    bonus_label.bonus_text = ""
                    bonus_label.color_potency = Color(255, 255, 255, 100)

                    --*
                    local reroll_button = vgui.Create("DImageButton", bf) 
                    reroll_button:SetSize(bf_w * 0.03, bf_h * 0.04)
                    reroll_button:SetY(bonus_label:GetY())
                    reroll_button:MoveRightOf(bonus_label, bf_w * 0.01)     
                    reroll_button:SetTooltip(required_reroll_crystals .. " Reroll Crystals required. x3 for right click / potency rolling." .. " Owned: " .. FROZE_GL.tbl_materials_inventory["Reroll Crystal"].held_num)                
                    reroll_button.potency_potential = 0
                    
                    --* functions 
                    local function reroll_click(self, mouse_button)
                        local final_required_reroll_crystals 

                        if mouse_button == "LEFT" then 
                            final_required_reroll_crystals = required_reroll_crystals
                        elseif mouse_button == "RIGHT" then 
                            final_required_reroll_crystals = required_reroll_crystals * 3
                        end

                        -- PrintTable( FROZE_GL.gl_stored_bonused_weapons)
                        if FROZE_GL.tbl_materials_inventory["Reroll Crystal"].held_num < final_required_reroll_crystals then 
                            return
                        end

                        if  FROZE_GL.gl_stored_bonused_weapons[button_weapon_slot.gl_chosen_weapon] then 
                            --*
                            self:SetTooltip(false)
                            FROZE_GL.tbl_materials_inventory["Reroll Crystal"].held_num = FROZE_GL.tbl_materials_inventory["Reroll Crystal"].held_num - final_required_reroll_crystals
                            local weapon_tbl =  FROZE_GL.gl_stored_bonused_weapons[button_weapon_slot.gl_chosen_weapon]  
                            local get_tbl_bonus = FROZE_GL.tbl_bonuses_weapons[math.random(1, #FROZE_GL.tbl_bonuses_weapons)]
                            local rarity_rand_modifier = math.Remap(garlic_like_rarity_to_num(weapon_tbl.rarity), 1, 7, 1, 2)  
                            local potency_rand_min = 0.15 * rarity_rand_modifier
                            local potency_rand_max = 0.5 * rarity_rand_modifier
                            local potency = math.Rand(potency_rand_min, potency_rand_max)
                            reroll_button.potency_potential = math.Truncate(math.Remap(potency, potency_rand_min, potency_rand_max, 0, 1), 3)
                            bonus_label.color_potency.a = 50 * reroll_button.potency_potential

                            -- print("potency: " .. potency .. " min pot: " .. potency_rand_min .. " max pot: " .. potency_rand_max .. " pot range in: %" .. reroll_button.potency_potential)

                            local base_modifier = get_tbl_bonus.modifier * get_tbl_bonus.upgrade_mul^weapon_tbl.level * garlic_like_determine_weapon_bonuses_modifiers(weapon_tbl.rarity)

                            if mouse_button == "LEFT" then 
                                weapon_tbl.bonuses[i] = {
                                    id = i,
                                    name = get_tbl_bonus.name,
                                    modifier = math.Truncate(base_modifier * potency, 3),
                                    desc = get_tbl_bonus.desc,
                                    upgrade_mul = get_tbl_bonus.upgrade_mul,
                                    max_mul = get_tbl_bonus.max_mul,
                                    type_mul = get_tbl_bonus.type_mul,
                                    potency = potency,
                                }
                            elseif mouse_button == "RIGHT" then 
                                weapon_tbl.bonuses[i].modifier = math.Truncate(base_modifier * potency, 3)
                                weapon_tbl.bonuses[i].potency = potency
                            end

                            net.Start(gl .. "choose_weapon")
                            net.WriteString(button_weapon_slot.gl_chosen_weapon)
                            net.WriteString("UPGRADE_WEAPON")
                            net.WriteTable( FROZE_GL.gl_stored_bonused_weapons)
                            net.WriteTable({})
                            net.SendToServer()

                            for k, bonus in pairs(weapon_tbl.bonuses) do
                                local bonus_min 
                                local bonus_max 
                                local potency_range_text = "" 

                                if bonus.potency then 
                                    bonus_min = math.Truncate(bonus.modifier / bonus.potency * potency_rand_min, 3) * 100
                                    bonus_max = math.Truncate(bonus.modifier / bonus.potency * potency_rand_max, 3) * 100
                                    potency_range_text = " [" .. bonus_min .. "%-" .. bonus_max .. "%]"
                                end

                                tbl_bonus_labels[k].bonus_text_front =  tostring(bonus.modifier * 100) .. "% " .. "-> " .. tostring(math.Truncate(math.min(bonus.max_mul, bonus.modifier * bonus.upgrade_mul) * 100, 1)) .. "% "
                                tbl_bonus_labels[k].bonus_text = bonus.desc .. potency_range_text
                            end

                            -- PrintTable(weapon_tbl.bonuses)
                            surface.PlaySound("garlic_like/slot_beep.wav")
                        end
                    end
                    
                    reroll_button.DoClick = function(self) 
                        reroll_click(self, "LEFT") 
                    end

                    reroll_button.DoRightClick = function(self) 
                        reroll_click(self, "RIGHT")
                    end

                    reroll_button.Paint = function(self, w, h) 
                        if bonus_label.bonus_text ~= "" then 
                            local color = 255

                            if FROZE_GL.tbl_materials_inventory["Reroll Crystal"].held_num < required_reroll_crystals then 
                                color = 125
                            end

                            if self:IsHovered() then 
                                self:SetTooltip(required_reroll_crystals .. "/" .. required_reroll_crystals * 3 .. " Reroll Crystals required." .. " Owned: " .. FROZE_GL.tbl_materials_inventory["Reroll Crystal"].held_num)
                            end

                            surface.SetDrawColor(color, color, color, 255) 
                            surface.SetMaterial(FROZE_GL.mat_dice) 
                            surface.DrawTexturedRect(0, 0, w, h)

                            if not self:IsMouseInputEnabled() then 
                                self:SetMouseInputEnabled(true)
                            end 
                        else 
                            if self:IsMouseInputEnabled() then 
                                self:SetMouseInputEnabled(false)
                            end
                        end
                    end

                    bonus_label.Paint = function(self, w, h)
                        draw.RoundedBoxEx(6, 0, 0, w, h, color_black, true, true, true, true)
                        draw.RoundedBoxEx(6, 0, 0, w * reroll_button.potency_potential, h, self.color_potency, true, true, true, true)
                        gl_cse(ply, w * 0.5, h * 0.5, bonus_label.bonus_text_front, "", bonus_label.bonus_text, true, false, "", false, gl .. "font_subtitle", color, true)
                    end

                    table.insert(tbl_bonus_labels, bonus_label)
                    table.insert(tbl_reroll_buttons, reroll_button)
                    table.insert(tbl_bonus_locks, blb)
                end

                --* WEAPONS SCROLL PANEL
                for k, wep in pairs(ply:GetWeapons()) do
                    if not wep:IsScripted() or FROZE_GL.gl_stored_bonused_weapons[wep.ClassName] == nil then continue end
                    --
                    local mat_wep_icon
                    local mat_wep_icon_texture
                    local wep_icon_is_material = false

                    local wep_tbl_sp = FROZE_GL.gl_stored_bonused_weapons[wep.ClassName]

                    local weapon_box = wsd:Add("DButton")
                    weapon_box:SetSize(wsd:GetWide(), H * 0.4)
                    weapon_box:Dock(TOP)
                    weapon_box:DockMargin(W * 0.01, W * 0.01, W * 0.01, 0)
                    weapon_box:SetText("") 

                    -- new code
                    local wep_stored = weapons.Get(wep.ClassName)
                    mat_wep_icon = wep_stored.WepSelectIcon or weapons.Get(wep_stored.Base).WepSelectIcon 

                    if garlic_like_is_arccw_wep(wep) then
                        local mat = Material("arccw/weaponicons/" .. wep.ClassName)

                        if not mat:IsError() then
                            mat_wep_icon = surface.GetTextureID(mat:GetTexture("$basetexture"):GetName())
                            -- print("ICON " .. wep_choice.mat_wep_icon)
                        end  
                    elseif garlic_like_is_tfa_wep(wep) then 
                        mat_wep_icon = Material("entities/" .. wep.ClassName .. ".png")
                        wep_icon_is_material = true
                    end

                    if mat_wep_icon == nil then
                        wep_icon_use_backup = true
                    end

                    weapon_box.mat_wep_icon = mat_wep_icon
                    weapon_box.wep_icon_is_material = wep_icon_is_material

                    --

                    --*
                    --! FINISH WEAPON UPGRADE MENU
                    --*
                    weapon_box.DoClick = function(self, w, h)
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                        button_weapon_slot.gl_chosen_weapon = wep.ClassName
                        button_upgrade.enough_materials = nil 
                        weapon_tbl =  FROZE_GL.gl_stored_bonused_weapons[button_weapon_slot.gl_chosen_weapon]
                        weapon_rarity = weapon_tbl.rarity 
                        weapon_rarity_num = garlic_like_rarity_to_num(weapon_rarity) 
                        required_reroll_crystals = math.Round(math.Remap((FROZE_GL.tbl_rarity_to_number[weapon_rarity] + 1) / 2, 1, 4, 1, 50))

                        --* SHOW REROLL ELEMENT BUTTON
                        rbe:Show()
                        rbe.erc_needed = math.Round(4^(weapon_rarity_num / 4))

                        --* SET THE NEW REROLL CRYSTAL VALUE
                        for k, panel in ipairs(tbl_reroll_buttons) do 
                            panel:SetTooltip(required_reroll_crystals .. "/" .. required_reroll_crystals * 3 .. " Reroll Crystals required." .. " Owned: " .. FROZE_GL.tbl_materials_inventory["Reroll Crystal"].held_num)
                        end 

                        button_weapon_slot.gl_chosen_weapon_mat = self.mat_wep_icon

                        --
                        --* SET THE TEXT IN BONUS_LABELS
                        for k, panel in pairs(tbl_bonus_labels) do
                            panel.bonus_text_front = ""
                            panel.bonus_text = ""
                        end

                        for k, bonus in pairs(weapon_tbl.bonuses) do
                            tbl_bonus_labels[k].bonus_text_front = tostring(bonus.modifier * 100) .. "% " .. "-> " .. tostring(math.Truncate(math.min(bonus.max_mul, bonus.modifier * bonus.upgrade_mul) * 100, 1)) .. "% "
                            tbl_bonus_labels[k].bonus_text = bonus.desc
                        end

                        -- PrintTable(weapon_tbl)
                    end

                    weapon_box.Paint = function(self, w, h)
                        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 35))
                        surface.SetDrawColor(255, 255, 255)
                        surface.DrawCircle(w * 0.5, w * 0.2, w * 0.15, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity])
                        gl_cse(ply, w * 0.5, h * 0.375, string.upper( FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity), "", "", true, false, "", false, gl .. "font_subtitle", FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity], true)
                        gl_cse(ply, w * 0.5, h * 0.425, "", "", wep.PrintName, true, false, "", false, gl .. "font_title_3", nil, true)
                        draw.DrawText("LEVEL " ..  FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].level, gl .. "font_subtitle", w * 0.5, h * 0.46, color_white, TEXT_ALIGN_CENTER)
                        surface.SetDrawColor(255, 255, 255)
                        if wep_icon_is_material then 
                            surface.SetMaterial(mat_wep_icon)
                        else 
                            surface.SetTexture(mat_wep_icon)
                        end
                        surface.DrawTexturedRect(w * 0.5 - w * 0.225, h * 0.1, w * 0.45, h * 0.2)

                        --* DRAW THE ELEMENT ICON
                        surface.SetDrawColor(255, 255, 255, 255)

                        local mat_element 
                        local mat_element_white
                        
                        for k, v in pairs(FROZE_GL.tbl_elements) do 
                            if v.name == string.lower(wep_tbl_sp.element) then 
                                mat_element = v.mat_1 
                                mat_element_white = v.mat_white                            
                            end
                        end

                        surface.SetFont(gl .. "font_title_3")
                        local t_w, t_h = surface.GetTextSize(wep.PrintName)

                        surface.SetMaterial(mat_element)
                        surface.DrawTexturedRect(w * 0.505 + t_w * 0.5, h * 0.425 - h * 0.05 / 2, w * 0.05, h * 0.05)

                        --* ELEMENT ICON END

                        for k, bonus in pairs( FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].bonuses) do
                            gl_cse(ply, w * 0.5, (h * 0.5) + (k * h * 0.06), 100 * bonus.modifier, "%", bonus.desc, true, false, "", false, gl .. "font_subtitle", nil, true)
                        end

                        if self:IsHovered() and not self:IsDown() then
                            draw.RoundedBox(8, 0, 0, w, h, Color(FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].r, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].g, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].b, 10))
                        end

                        if self:IsDown() then
                            draw.RoundedBox(8, 0, 0, w, h, Color(FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].r, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].g, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].b, 30))
                        end
                    end
                end

                --* MATERIALS ON THE BOTTOM DISPLAY
                -- PrintTable(FROZE_GL.WepCrystalsInventory)
                for k, ore in pairs(FROZE_GL.WepCrystalsInventory) do
                    local material_icon = vgui.Create("DImage", bf)
                    material_icon:SetImage(ore.material:GetName() .. ".png") 
                    material_icon:SetWide(dms:GetWide() * 0.06)
                    material_icon:SetTall(dms:GetTall() * 0.45)
                    material_icon:SetX((k * dms:GetWide() * 0.15) - dms:GetWide() * 0.1)
                    material_icon:SetY(bf_h * 0.9)
                    table.insert(tbl_material_icons, material_icon)
                    --*
                    local materials_needed = vgui.Create("DLabel", bf)
                    materials_needed:SetFont(gl .. "font_subtitle_2")
                    materials_needed:SetWide(material_icon:GetWide() * 2)
                    materials_needed:SetTall(material_icon:GetTall())
                    materials_needed:SetX(material_icon:GetX() - material_icon:GetWide() * 0.5)
                    materials_needed:MoveBelow(material_icon, 3)
                    materials_needed:SetText("")
                    table.insert(tbl_material_labels, materials_needed)

                    --[[
                        * Every level requires 1 + last value needed
                        * Material requirement start at 1
                        * When a weapon is of epic rarity, it will require poor - rare materials of the same amount
                    ]]
                    materials_needed.Paint = function(self, w, h)
                        -- surface.SetDrawColor(255, 255, 255)
                        -- surface.DrawOutlinedRect(0, 0, w, h, 1)    

                        if button_weapon_slot.gl_chosen_weapon ~= "NONE" then
                            ore.rarity_num = garlic_like_rarity_to_num(ore.rarity)
                            ore.num_needed_material = weapon_tbl.level * 3

                            if ore.rarity_num > garlic_like_rarity_to_num(weapon_tbl.rarity) then
                                ore.num_needed_material = 0
                            end
                        else
                            ore.num_needed_material = 0
                        end

                        local color_held_material_num = color_white

                        if ore.held_num ~= nil then
                            if ore.held_num < ore.num_needed_material then
                                color_held_material_num = color_red
                                button_upgrade.enough_materials = false
                            else
                                color_held_material_num = color_white 
                            end
                        end

                        gl_cse(ply, w * 0.5, h * 0.25, "", ore.held_num, "/" .. ore.num_needed_material, true, false, nil, false, gl .. "font_subtitle_2", color_held_material_num, true)
                    end
                end

                --* DOCLICKS
                button_upgrade.DoClick = function(self)
                    if button_upgrade.enough_materials ~= false and gold > price and weapon_tbl.level then
                        surface.PlaySound("garlic_like/disgaea5_item_bought.wav")

                        for k, ore in pairs(FROZE_GL.WepCrystalsInventory) do
                            if ore.held_num >= ore.num_needed_material then
                                ore.held_num = ore.held_num - ore.num_needed_material
                            end
                        end

                        weapon_tbl.level = weapon_tbl.level + 1

                        -- PrintTable(weapon_tbl.bonuses)

                        for k, bonus in pairs(weapon_tbl.bonuses) do
                            if bonus.type_mul == -1 then
                                bonus.modifier = math.min(math.Truncate(bonus.modifier * bonus.upgrade_mul, 3), 0.95)
                            else 
                                bonus.modifier = math.min(bonus.max_mul, math.Truncate(bonus.modifier * bonus.upgrade_mul, 3))
                            end

                            tbl_bonus_labels[k].bonus_text_front = tostring(bonus.modifier * 100) .. "% " .. "-> " .. tostring(math.Truncate(math.min(bonus.max_mul, bonus.modifier * bonus.upgrade_mul) * 100, 1)) .. "% "
                            tbl_bonus_labels[k].bonus_text = bonus.desc
                        end

                        net.Start(gl .. "choose_weapon")
                        net.WriteString(button_weapon_slot.gl_chosen_weapon)
                        net.WriteString("UPGRADE_WEAPON")
                        net.WriteTable( FROZE_GL.gl_stored_bonused_weapons)
                        net.WriteTable({})
                        net.SendToServer()

                        garlic_like_update_money(price, "BOUGHT_ITEM")

                        -- PrintTable( FROZE_GL.gl_stored_bonused_weapons[button_weapon_slot.gl_chosen_weapon])
                    end
                end

                button_weapon_slot.DoClick = function(self)
                    surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                    
                    if weapons_stored.IsHidden then
                        weapons_stored.IsHidden = false
                        weapons_stored:Show()
                    else
                        weapons_stored.IsHidden = true
                        weapons_stored:Hide()
                    end
                end

                button_exit.DoClick = function(self) 
                    if IsValid(bf) then
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                        bf:Remove()
                        weapons_stored:Remove()

                        if ply.gl_panels then 
                            for k, panel in pairs(ply.gl_panels) do 
                                if IsValid(panel) and panel:GetName() == gl .. "shop_base_dpanel" then 
                                    panel:Show()
                                end
                            end
                        end
                    end
                end

                rbe.DoClick = function(self) 
                    if self.erc_needed < FROZE_GL.tbl_materials_inventory["Element Crystal"].held_num then return end 
                    surface.PlaySound("garlic_like/slot_beep.wav")

                    self.alpha_element = 255

                    for k, v in RandomPairs(FROZE_GL.tbl_elements) do 
                        weapon_tbl.element = v.name
                    end
                end

                --* PAINTS
                dms.Paint = function(self, w, h) end

                label_weapon_name.Paint = function(self, w, h)
                    -- surface.SetDrawColor(255, 255, 255) 
                    -- surface.DrawOutlinedRect(0, 0, w, h, 1)            

                    if button_weapon_slot.gl_chosen_weapon == "NONE" then
                        draw.DrawText("WEAPON NAME", gl .. "font_title_2", w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)
                    else
                        local wep_name = button_weapon_slot.gl_chosen_weapon
                        gl_cse(ply, w * 0.5, h * 0.15, string.upper( FROZE_GL.gl_stored_bonused_weapons[wep_name].rarity), "", "", true, false, "", false, gl .. "font_title_3", FROZE_GL.tbl_rarity_colors[string.lower( FROZE_GL.gl_stored_bonused_weapons[wep_name].rarity)], true)
                        gl_cse(ply, w * 0.5, h * 0.5, string.upper( FROZE_GL.gl_stored_bonused_weapons[wep_name].name), "", "", true, false, "", false, gl .. "font_title_2", color_white, true)
                        draw.DrawText("LEVEL " .. weapon_tbl.level, gl .. "font_subtitle_2", w * 0.5, h * 0.6, color_white, TEXT_ALIGN_CENTER)
                        --* DRAW THE ELEMENT ICON
                        surface.SetDrawColor(255, 255, 255, 255)

                        local mat_element 
                        local mat_element_white
                        
                        for k, v in pairs(FROZE_GL.tbl_elements) do 
                            if v.name == string.lower(weapon_tbl.element) then 
                                mat_element = v.mat_1 
                                mat_element_white = v.mat_white                            
                            end
                        end

                        surface.SetFont(gl .. "font_title_2")
                        local t_w, t_h = surface.GetTextSize(string.upper( FROZE_GL.gl_stored_bonused_weapons[wep_name].name))

                        surface.SetMaterial(mat_element)
                        surface.DrawTexturedRect(w * 0.505 + t_w * 0.5, h * 0.5 - w * 0.03 / 2, w * 0.03, h * 0.3)

                        rbe.alpha_element = math.max(0, rbe.alpha_element - RealFrameTime() * 1000)
                    
                        surface.SetDrawColor(255, 255, 255, rbe.alpha_element)
                        surface.SetMaterial(mat_element_white)
                        surface.DrawTexturedRect(w * 0.505 + t_w * 0.5, h * 0.5 - w * 0.03 / 2, w * 0.03, h * 0.3)

                        rbe:SetX(bf_w * 0.5 + t_w * 0.5 + rbe:GetWide() + w * 0.01)
                        surface.SetDrawColor(255, 255, 255, 255)
                    end
                end   

                label_weapons.Paint = function(self, w, h)
                    draw.DrawText("WEAPONS", gl .. "font_title_2", w * 0.5, h * 0.25, color_white, TEXT_ALIGN_CENTER)
                end

                label_price.Paint = function(self, w, h) 
                    -- outline_box(w, h)
                    if button_weapon_slot.gl_chosen_weapon == "NONE" then return end 
                    --
                    gold = tonumber(ply:GetNWInt(gl .. "money", 0))
                    price = math.Round(150 * weapon_rarity_num^(1.5 + weapon_tbl.level * 0.3))
                    local color_price = color_white 
                    
                    if gold < price then
                        color_price = color_red
                    end
                    --
                    gl_cse(ply, w * 0.5, h * 0.5, price, "", "", true, false, "", false, gl .. "font_subtitle_3", color_price, true)
                    --
                    local t_w, t_h = surface.GetTextSize(price)
                    local screenscale_8 = ScreenScale(8)
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(FROZE_GL.mat_hl)
                    surface.DrawTexturedRect(w * 0.5 + t_w / 2, h * 0.5 - screenscale_8 / 2, screenscale_8, screenscale_8)
                end

                rbe.Paint = function(self, w, h)                 
                    local color = 255  

                    if FROZE_GL.tbl_materials_inventory["Element Crystal"].held_num < self.erc_needed then 
                        color = 125
                    end

                    surface.SetDrawColor(color, color, color, 255) 
                    surface.SetMaterial(FROZE_GL.mat_dice) 
                    surface.DrawTexturedRect(0, 0, w, h)

                    if self:IsHovered() then 
                        self:SetTooltip(self.erc_needed .. " Element Crystals required." .. " Owned: " .. FROZE_GL.tbl_materials_inventory["Element Crystal"].held_num)
                    end

                    if not self:IsMouseInputEnabled() then 
                        self:SetMouseInputEnabled(true)
                    end 
                end

                button_weapon_slot.Paint = function(self, w, h)
                    if self.gl_chosen_weapon == "NONE" then
                        draw.DrawText("?", gl .. "font_title_big", w * 0.5, -h * 0.125, color_white, TEXT_ALIGN_CENTER)
                    else
                        surface.SetDrawColor(255, 255, 255)
                        surface.SetMaterial(self.gl_chosen_weapon_mat)
                        surface.DrawTexturedRect(0, 0 - h * 0.05, w, h)
                    end
                end

                button_upgrade.Paint = function(self, w, h)
                    local up_text_width = w * 0.5
                    local up_text_height = h * 0.5

                    if button_weapon_slot.gl_chosen_weapon ~= "NONE" and (button_upgrade.enough_materials ~= false and tonumber(gold) > tonumber(price)) then
                        if not self:IsHovered() and not self:IsDown() then
                            draw.RoundedBox(6, w * 0.015, h * 0.015, w * 0.97, h * 0.97, color_button_orange)
                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(Material("garlic_like/ui_text/UPGRADE.png"))
                            surface.DrawTexturedRect(w * 0.5 - up_text_width / 2, h * 0.5 - up_text_height / 2, up_text_width, up_text_height)
                        end

                        if self:IsHovered() and not self:IsDown() then
                            draw.RoundedBox(6, 0, 0, w, h, color_button_orange)
                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(Material("garlic_like/ui_text/UPGRADE.png"))
                            surface.DrawTexturedRect(w * 0.5 - up_text_width / 0.95 / 2, h * 0.5 - up_text_height / 0.95 / 2, up_text_width / 0.95, up_text_height / 0.95)
                        end

                        if self:IsDown() then
                            draw.RoundedBox(6, w * 0.015, h * 0.015, w * 0.97, h * 0.97, color_button_orange_pressed)
                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(Material("garlic_like/ui_text/UPGRADE.png"))
                            surface.DrawTexturedRect(w * 0.5 - up_text_width / 2, h * 0.5 - up_text_height / 2, up_text_width, up_text_height)
                        end
                    else
                        draw.RoundedBox(6, w * 0.015, h * 0.015, w * 0.97, h * 0.97, color_button_grey)
                        surface.SetDrawColor(255, 255, 255)
                        surface.SetMaterial(Material("garlic_like/ui_text/UPGRADE_black.png"))
                        surface.DrawTexturedRect(w * 0.275 - w * 0.015, h * 0.3 - h * 0.015, up_text_width + w * 0.03, h * 0.35 + h * 0.03)
                    end
                end  
                
                bf.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50))
                    draw.RoundedBox(8, 0, h * 0.875, w, h * 0.125, Color(30, 30, 30))
                    surface.SetDrawColor(255, 255, 255)

                    if button_weapon_slot.gl_chosen_weapon == "NONE" then
                        surface.DrawCircle(w * 0.5, w * 0.105, w * 0.085, color_white)
                    else
                        surface.DrawCircle(w * 0.5, w * 0.105, w * 0.085, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[button_weapon_slot.gl_chosen_weapon].rarity])
                    end
                end

                weapons_stored.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50))
                end

                -- timer.Simple(5, function()
                --     if IsValid(bf) then
                --         bf:Remove()
                --         weapons_stored:Remove()
                --     end
                -- end)
                do 
                end
            elseif menu_type == "FUSION" then 
                local price = 0
                local tbl_bt_item_to_fuse = {}      
                local tbl_weapon_boxes = {}
                local currently_chosen_fuse_slot = 1  
                local isfusable = false    
                local hasfused = false
                local fused_rarity   
                --*
                local base_frame = vgui.Create("DPanel", nil, gl .. "base_frame_weapon_upgrade")
                bf = base_frame
                bf:SetSize(W * 0.5, H * 0.75)
                bf:Center()
                bf:MakePopup()
                bf:MoveToBack()
                local bf_w, bf_h = bf:GetWide(), bf:GetTall()
                --* 
                local fused_preview = vgui.Create("DPanel", nil, gl .. "fused_preview_panel")
                fused_preview:SetName(gl .. "fused_preview") 
                fused_preview:SetSize(W * 0.6 * 0.25, H * 0.65 * 0.8) 
                fused_preview:Center() 
                fused_preview:SetX(W * 0.05)  
                --* 
                local weapons_stored = vgui.Create("DPanel")
                weapons_stored:MakePopup()
                weapons_stored:SetSize(W * 0.23, H * 0.85)
                weapons_stored:Center()
                weapons_stored:MoveRightOf(bf, W * 0.01)
                -- weapons_stored:Hide() 
                --*
                local weapons_stored_dscrollpanel = vgui.Create("DScrollPanel", weapons_stored)
                wsd = weapons_stored_dscrollpanel
                wsd:Dock(FILL)
                wsd:SetMouseInputEnabled(true)
                --*
                local label_weapons = wsd:Add("DLabel")
                label_weapons:SetSize(W * 0.4, H * 0.05)
                label_weapons:Dock(TOP)
                label_weapons:SetText("") 
                --*
                local button_fuse = vgui.Create("DButton", bf)
                button_fuse:SetSize(bf_w * 0.5, bf_h * 0.1)
                button_fuse:Center()
                button_fuse:SetY(bf_h * 0.75)
                button_fuse:SetText("")
                --*
                local label_price = vgui.Create("DLabel", bf)
                label_price:SetFont(gl .. "font_subtitle")
                label_price:SetSize(bf_w, bf_h * 0.05)  
                label_price:MoveBelow(button_fuse, 1)      
                label_price:CenterHorizontal()
                label_price:SetText("")
                --*
                local buttons_total_width = 3 * (bf_w * 0.15 * 1.1)

                for i = 1, 3 do 
                    local button_item_to_fuse = vgui.Create("DButton", bf)            
                    button_item_to_fuse:SetSize(bf_w * 0.15, bf_w * 0.15)
                    button_item_to_fuse:Center()
                    button_item_to_fuse:SetX(bf_w * 0.51 + ((i - 1) * button_item_to_fuse:GetWide() * 1.1) - buttons_total_width / 2)
                    button_item_to_fuse:SetY(bf_h * 0.15)
                    button_item_to_fuse:SetText("") 
                    button_item_to_fuse.slot_num = i
                    button_item_to_fuse.tbl_item = nil 
                    button_item_to_fuse.border_color = Color(255, 255, 255)
                    --
                    button_item_to_fuse.DoClick = function(self) 
                        -- if not weapons_stored:IsVisible() then  
                        --     weapons_stored:Show()
                        -- else 
                        --     weapons_stored:Hide()
                        -- end

                        currently_chosen_fuse_slot = self.slot_num 
                    end

                    button_item_to_fuse.DoRightClick = function(self) 
                        for k2, panel in pairs(tbl_weapon_boxes) do 
                            if self.tbl_item and panel.wep_name == self.tbl_item.name then 
                                panel:DoClick()
                            end
                        end 
                    end

                    button_item_to_fuse.Paint = function(self, w, h) 
                        draw.RoundedBox(4, 0, 0, w, h, self.border_color)
                        draw.RoundedBox(4, w * 0.02, h * 0.02, w * 0.96, h * 0.96, color_black)

                        if self:IsHovered() then 
                            draw.RoundedBox(4, 0, 0, w, h, color_white_100)
                        end

                        if currently_chosen_fuse_slot == self.slot_num then 
                            draw.RoundedBox(4, 0, 0, w, h, color_white_40)
                        end

                        if self.tbl_item then 
                            surface.SetDrawColor(255, 255, 255) 
                            surface.SetMaterial(self.tbl_item.mat) 
                            surface.DrawTexturedRect(0, 0, w, h)
                        end
                    end
                    --
                    table.insert(tbl_bt_item_to_fuse, button_item_to_fuse)
                end
                --*
                local button_result = vgui.Create("DButton", bf)
                button_result:SetSize(bf_w * 0.15, bf_w * 0.15)
                button_result:Center()
                button_result:SetY(bf_h * 0.45)
                button_result:SetText("") 
                button_result.border_color = Color(0, 0, 0, 0)
                --*
                local dpanel_material_showcase = vgui.Create("DPanel", bf)
                dms = dpanel_material_showcase
                dms:SetSize(bf_w * 0.95, bf_h * 0.125)
                dms:Center()
                dms:MoveBelow(button_fuse, bf_h * 0.015)
                --*
                local button_exit = vgui.Create("DButton", bf)
                button_exit:SetSize(bf_w * 0.1, bf_h * 0.05)
                button_exit:SetText("EXIT")
                button_exit:SetY(bf_h * 0.025)
                button_exit:SetX(bf_w * 0.025)

                --* WEAPONS SCROLL PANEL
                local function create_scroll_panel() 
                    if #tbl_weapon_boxes > 0 then 
                        for k, panel in pairs(tbl_weapon_boxes) do 
                            SafeRemovePanel(panel)
                        end

                        tbl_weapon_boxes = {}
                    end

                    timer.Simple(0.25, function()
                        if not bf then return end 
                        
                        for k, wep in pairs(ply:GetWeapons()) do
                            if not wep:IsScripted() or  FROZE_GL.gl_stored_bonused_weapons[wep.ClassName] == nil then continue end
                            if  FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity == "god" then continue end
                            --
                            local mat_wep_icon
                            local mat_wep_icon_texture
                            local weapon_box = wsd:Add("DButton")
                            weapon_box:SetSize(wsd:GetWide(), H * 0.4)
                            weapon_box:Dock(TOP)
                            weapon_box:DockMargin(W * 0.01, W * 0.01, W * 0.01, 0)
                            weapon_box:SetText("")
                            weapon_box.wep_class = wep.ClassName
                            weapon_box.wep_name = wep.PrintName
                            local str_1, str_2 = garlic_like_is_arccw_wep(wep)
            
                            if str_1 ~= nil then
                                mat_wep_icon = Material("arccw/weaponicons/" .. wep.ClassName)
            
                                if not mat_wep_icon:IsError() then
                                    mat_wep_icon_texture = surface.GetTextureID(mat_wep_icon:GetTexture("$basetexture"):GetName())
                                end
                            else
                                mat_wep_icon = Material(surface.GetTextureNameByID(wep.WepSelectIcon)) or Material(surface.GetTextureNameByID(weapons.Get(weapons.Get(wep.ClassName)).WepSelectIcon))
                            end
            
                            weapon_box.DoClick = function(self, w, h)
                                -- button_weapon_slot.gl_chosen_weapon = wep.ClassName
                                if hasfused then 
                                    hasfused = false
                                end

                                button_fuse.enough_materials = nil
                                local mat_wep_icon
                                local str_1, str_2 = garlic_like_is_arccw_wep(wep)
                                weapon_tbl =  FROZE_GL.gl_stored_bonused_weapons[wep.ClassName]
                                weapon_rarity = weapon_tbl.rarity 
                                weapon_rarity_num = garlic_like_rarity_to_num(weapon_rarity) 
            
                                mat_wep_icon = Material("arccw/weaponicons/" .. wep.ClassName) 
                            
                                if mat_wep_icon:IsError() then 
                                    mat_wep_icon = Material(surface.GetTextureNameByID(wep.WepSelectIcon)) or Material(surface.GetTextureNameByID(weapons.Get(weapons.Get(wep.ClassName)).WepSelectIcon))
                                end
            
                                --* CHECKS IF THE SELECTED WEAPON IS ALREADY INSERTED   
                                if self.item_used then  
                                    surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                                    -- print("WP BOX USED")
                                    for k2, panel in ipairs(tbl_bt_item_to_fuse) do 
                                        if panel.tbl_item and panel.tbl_item.name == wep.PrintName then 
                                            panel.tbl_item = nil
                                            panel.border_color = color_white
                                            self.item_used = false 
                                        end
                                    end   
                                    
                                    isfusable = false
                                    fused_rarity = nil  
                                    
                                    button_result.border_color = Color(0, 0, 0, 0)
                                    button_result.wep_icon = nil
                                elseif not self.item_used and not tbl_bt_item_to_fuse[currently_chosen_fuse_slot].tbl_item then 
                                    -- print("WP BOX NOT USED")
                                    local num_filled = 1
                                    surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
            
                                    for k2, panel in ipairs(tbl_bt_item_to_fuse) do                                                         
                                        if panel.slot_num == currently_chosen_fuse_slot then  
                                            panel.border_color = FROZE_GL.tbl_rarity_colors[string.lower(weapon_rarity)]
            
                                            panel.tbl_item = {
                                                name = wep.PrintName,
                                                class = wep.ClassName,
                                                mat = mat_wep_icon,
                                                rarity = string.lower(weapon_rarity)
                                            }
            
                                            self.item_used = true 
                                        end
            
                                        --* IF EVERY SLOT IS THE SAME RARITY THEN ALLOW FUSING
                                        if panel.tbl_item and tbl_bt_item_to_fuse[k2 - 1] and tbl_bt_item_to_fuse[k2 - 1].tbl_item and tbl_bt_item_to_fuse[k2 - 1].tbl_item.rarity == panel.tbl_item.rarity then 
                                            num_filled = num_filled + 1
                                            -- print(num_filled .. " num_filled!")
            
                                            if num_filled == 3 then 
                                                isfusable = true
                                                fused_rarity = table.KeyFromValue(FROZE_GL.tbl_rarity_to_number, FROZE_GL.tbl_rarity_to_number[panel.tbl_item.rarity] + 1)
                                                button_result.border_color = FROZE_GL.tbl_rarity_colors[fused_rarity]
                                                button_result.wep_icon = Material("garlic_like/question_mark_white_sizefit.png")
                                            end
                                        end
                                    end
            
                                    currently_chosen_fuse_slot = math.min(3, currently_chosen_fuse_slot + 1)
                                end
            
                                -- PrintTable(weapon_tbl)
                            end
            
                            weapon_box.Paint = function(self, w, h)
                                if not  FROZE_GL.gl_stored_bonused_weapons[wep.ClassName] then return end 
                                --
                                draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 35))
                                surface.SetDrawColor(255, 255, 255)
                                surface.DrawCircle(w * 0.5, w * 0.2, w * 0.15, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity])
                                gl_cse(ply, w * 0.5, h * 0.375, string.upper( FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity), "", "", true, false, "", false, gl .. "font_subtitle", FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity], true)
                                gl_cse(ply, w * 0.5, h * 0.425, "", "", wep.PrintName, true, false, "", false, gl .. "font_title_3", nil, true)
                                draw.DrawText("LEVEL " ..  FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].level, gl .. "font_subtitle", w * 0.5, h * 0.46, color_white, TEXT_ALIGN_CENTER)
                                surface.SetDrawColor(255, 255, 255)
                                surface.SetMaterial(mat_wep_icon)
                                surface.DrawTexturedRect(w * 0.5 - w * 0.225, h * 0.1, w * 0.45, h * 0.2)
            
                                for k, bonus in pairs( FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].bonuses) do
                                    gl_cse(ply, w * 0.5, (h * 0.5) + (k * h * 0.06), 100 * bonus.modifier, "%", bonus.desc, true, false, "", false, gl .. "font_subtitle", nil, true)
                                end
            
                                if self:IsHovered() and not self:IsDown() then
                                    draw.RoundedBox(8, 0, 0, w, h, Color(FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].r, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].g, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].b, 10))
                                end
            
                                if self:IsDown() then
                                    draw.RoundedBox(8, 0, 0, w, h, Color(FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].r, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].g, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity].b, 30))
                                end
            
                                if self.item_used then 
                                    draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 200))  
                                    draw.DrawText("USED", gl .. "font_title", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER)
                                end
                            end
            
                            table.insert(tbl_weapon_boxes, weapon_box)
                        end 
                    end)
                end  
                
                create_scroll_panel() 

                --* DOCLICKS
                button_fuse.DoClick = function(self)
                    if not isfusable then return end 
                    --
                    local tbl_of_weps_to_remove = {}
                    hasfused = true
                    isfusable = false
                    currently_chosen_fuse_slot = 1

                    for k2, v2 in pairs( FROZE_GL.gl_stored_bonused_weapons) do 
                        for k3, panel in ipairs(tbl_bt_item_to_fuse) do 
                            if k2 == panel.tbl_item.class then 
                                -- print("FOUND IT !!!!")
                                FROZE_GL.gl_stored_bonused_weapons[k2] = nil 
                                --  FROZE_GL.gl_stored_bonused_weapons = table.ClearKeys( FROZE_GL.gl_stored_bonused_weapons) 
                            end
                        end
                    end

                    for k2, panel in pairs(tbl_bt_item_to_fuse) do 
                        table.insert(tbl_of_weps_to_remove, panel.tbl_item.class)
                        panel.tbl_item = nil
                    end
                    -- 
                    garlic_like_get_weapon(button_result, FROZE_GL.tbl_valid_weapons, "ROLL", fused_rarity)
                    --
                    surface.PlaySound("items/gift_pickup.wav")

                    if button_result.wep_bonuses_amount > 0 then
                        FROZE_GL.gl_stored_bonused_weapons[button_result.wep.ClassName] = {
                            bonuses = {},
                            bonus_amount = 0,
                            name = "",
                            rarity = "",
                            level = 1
                        }

                        FROZE_GL.gl_stored_bonused_weapons[button_result.wep.ClassName].bonuses = button_result.wep_bonuses
                        FROZE_GL.gl_stored_bonused_weapons[button_result.wep.ClassName].name = button_result.wep.PrintName
                        FROZE_GL.gl_stored_bonused_weapons[button_result.wep.ClassName].rarity = button_result.wep_rarity
                        FROZE_GL.gl_stored_bonused_weapons[button_result.wep.ClassName].element = button_result.wep_element.name
                        FROZE_GL.gl_stored_bonused_weapons[button_result.wep.ClassName].bonus_amount = button_result.wep_bonuses_amount
                        FROZE_GL.gl_stored_bonused_weapons[button_result.wep.ClassName].level = 1
                    end

                    fused_preview.wep = button_result.wep                    

                    if garlic_like_is_arccw_wep(fused_preview.wep) then
                        fused_preview.wep_icon = Material("arccw/weaponicons/" .. fused_preview.wep.ClassName)

                        if not fused_preview.wep_icon:IsError() then
                            fused_preview.wep_icon = surface.GetTextureID(fused_preview.wep_icon:GetTexture("$basetexture"):GetName())
                            -- print("ICON " .. fused_preview.wep_icon)
                        end
                    end

                    button_result.wep_icon = fused_preview.wep_icon 
                    -- PrintTable( FROZE_GL.gl_stored_bonused_weapons)
                    --  
                    net.Start(gl .. "choose_weapon")
                    net.WriteString(button_result.wep.ClassName)
                    net.WriteString("PICK_WEAPON")
                    net.WriteTable( FROZE_GL.gl_stored_bonused_weapons)
                    net.WriteTable(tbl_of_weps_to_remove)
                    net.SendToServer()
                    --
                    garlic_like_update_money(price, "BOUGHT_ITEM")
                    -- 
                    -- button_exit:DoClick()
                    create_scroll_panel()
                end 

                button_exit.DoClick = function(self) 
                    if IsValid(bf) then
                        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                        SafeRemovePanel(bf) 
                        SafeRemovePanel(weapons_stored)
                        SafeRemovePanel(fused_preview)

                        if ply.gl_panels then 
                            for k, panel in pairs(ply.gl_panels) do 
                                if IsValid(panel) and panel:GetName() == gl .. "shop_base_dpanel" then 
                                    panel:Show()
                                end
                            end
                        end
                    end
                end

                --* PAINTS 
                button_result.Paint = function(self, w, h) 
                    draw.RoundedBox(4, 0, 0, w, h, self.border_color)
                    draw.RoundedBox(4, w * 0.02, h * 0.02, w * 0.96, h * 0.96, color_black)

                    if self:IsHovered() then 
                        draw.RoundedBox(4, 0, 0, w, h, color_white_100)
                    end

                    -- print(self.wep_icon)

                    if self.wep_icon then 
                        surface.SetDrawColor(255, 255, 255) 

                        if isnumber(self.wep_icon) then 
                            surface.SetTexture(self.wep_icon)
                        else
                            surface.SetMaterial(self.wep_icon) 
                        end

                        surface.DrawTexturedRect(w * 0.1, h * 0.1, w * 0.8, h * 0.8)
                    end 
                end

                dms.Paint = function(self, w, h) end

                button_fuse.Paint = function(self, w, h) 
                    local up_text_width = w * 0.35
                    local up_text_height = h * 0.5
                    
                    if isfusable then
                        if not self:IsHovered() and not self:IsDown() then
                            draw.RoundedBox(6, w * 0.015, h * 0.015, w * 0.97, h * 0.97, color_button_orange)
                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(Material("garlic_like/ui_text/FUSE.png"))
                            surface.DrawTexturedRect(w * 0.5 - up_text_width / 2, h * 0.5 - up_text_height / 2, up_text_width, up_text_height)
                        end

                        if self:IsHovered() and not self:IsDown() then
                            draw.RoundedBox(6, 0, 0, w, h, color_button_orange)
                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(Material("garlic_like/ui_text/FUSE.png"))
                            surface.DrawTexturedRect(w * 0.5 - up_text_width / 0.95 / 2, h * 0.5 - up_text_height / 0.95 / 2, up_text_width / 0.95, up_text_height / 0.95)
                        end

                        if self:IsDown() then
                            draw.RoundedBox(6, w * 0.015, h * 0.015, w * 0.97, h * 0.97, color_button_orange_pressed)
                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(Material("garlic_like/ui_text/FUSE.png"))
                            surface.DrawTexturedRect(w * 0.5 - up_text_width / 2, h * 0.5 - up_text_height / 2, up_text_width, up_text_height)
                        end
                    else
                        draw.RoundedBox(6, w * 0.015, h * 0.015, w * 0.97, h * 0.97, color_button_grey)
                        surface.SetDrawColor(255, 255, 255)
                        surface.SetMaterial(Material("garlic_like/ui_text/FUSE_black.png"))
                        surface.DrawTexturedRect(w * 0.5 - w * 0.015 - up_text_width / 2, h * 0.3 - h * 0.015, up_text_width + w * 0.03, h * 0.35 + h * 0.03)
                    end
                end  
                
                bf.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50)) 
                    surface.SetDrawColor(255, 255, 255) 
                end

                weapons_stored.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50))
                end

                label_price.Paint = function(self, w, h) 
                    -- outline_box(w, h)
                    if not fused_rarity then return end 
                    if hasfused then return end
                    --
                    gold = tonumber(ply:GetNWInt(gl .. "money", 0))
                    price = math.Round(25 * FROZE_GL.tbl_rarity_to_number[fused_rarity]^4.5)
                    local color_price = color_white 
                    
                    if gold < price then
                        color_price = color_red
                    end
                    --
                    gl_cse(ply, w * 0.5, h * 0.5, price, "", "", true, false, "", false, gl .. "font_subtitle_3", color_price, true)
                    --
                    local t_w, t_h = surface.GetTextSize(price)
                    local screenscale_8 = ScreenScale(8)
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(FROZE_GL.mat_hl)
                    surface.DrawTexturedRect(w * 0.5 + t_w / 2, h * 0.5 - screenscale_8 / 2, screenscale_8, screenscale_8)
                end

                fused_preview.Paint = function(self, w, h)
                    if not self.wep then return end
                    --
                    draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 35))
                    surface.SetDrawColor(255, 255, 255)
                    surface.DrawCircle(w * 0.5, w * 0.2, w * 0.15, FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[self.wep.ClassName].rarity])
                    gl_cse(ply, w * 0.5, h * 0.375, string.upper( FROZE_GL.gl_stored_bonused_weapons[self.wep.ClassName].rarity), "", "", true, false, "", false, gl .. "font_subtitle", FROZE_GL.tbl_rarity_colors[ FROZE_GL.gl_stored_bonused_weapons[self.wep.ClassName].rarity], true)
                    gl_cse(ply, w * 0.5, h * 0.425, "", "", self.wep.PrintName, true, false, "", false, gl .. "font_title_3", nil, true)
                    draw.DrawText("LEVEL " ..  FROZE_GL.gl_stored_bonused_weapons[self.wep.ClassName].level, gl .. "font_subtitle", w * 0.5, h * 0.46, color_white, TEXT_ALIGN_CENTER)
                    surface.SetDrawColor(255, 255, 255)

                    if isnumber(self.wep_icon ) then 
                        surface.SetTexture(self.wep_icon)
                    else
                        surface.SetMaterial(self.wep_icon)
                    end

                    surface.DrawTexturedRect(w * 0.5 - w * 0.225, h * 0.03, w * 0.45, h * 0.15)

                    for k, bonus in pairs( FROZE_GL.gl_stored_bonused_weapons[self.wep.ClassName].bonuses) do
                        gl_cse(ply, w * 0.5, (h * 0.5) + (k * h * 0.06), 100 * bonus.modifier, "%", bonus.desc, true, false, "", false, gl .. "font_subtitle", nil, true)
                    end
                end
                -- timer.Simple(5, function()
                --     if IsValid(bf) then
                --         bf:Remove()
                --         weapons_stored:Remove()
                --     end
                -- end)
                do 
                end
            end
        end)

        concommand.Add(gl .. "debug_open_weapon_chest", function(ply, cmd, args, argStr)
            garlic_like_open_weapon_crate_menu()
        end)

        concommand.Add(gl .. "debug_getstored_test", function(ply, cmd, args, argStr)
            local weap = weapons.Get("arccw_go_famas")
            local icon = weap.WepSelectIcon or weapons.Get(weap.Base).WepSelectIcon
            -- print(icon)
        end)

        concommand.Add(gl .. "debug_create_weapon_table_filtered", function(ply, cmd, args, argStr)
            for k, wep in pairs(weapons.GetList()) do
                if wep.Base == "mg_base" then
                    FROZE_GL.weapons_table_filtered[#FROZE_GL.weapons_table_filtered + 1] = wep
                end
            end

            timer_run_num = 0

            timer.Create("weapon_image_randomize_" .. ply:Nick(), 0.05, 50, function()
                timer_run_num = timer_run_num + 1
                -- print(timer_run_num)
                wep = FROZE_GL.weapons_table_filtered[math.random(#FROZE_GL.weapons_table_filtered)]
                FROZE_GL.weapon_image = "vgui/entities/" .. wep.ClassName
                FROZE_GL.weapon_rarity_random = "TEST "
                FROZE_GL.weapon_name_random = wep.PrintName
            end)
        end)

        concommand.Add(gl .. "debug_give_money", function(ply, cmd, args, argStr)
            local money_amount = 5000

            if argStr ~= nil then
                money_amount = tonumber(argStr)
            end

            if argStr == "" then
                money_amount = 1000
            end

            garlic_like_update_money(money_amount, "GAIN_MONEY")         
        end)

        concommand.Add(gl .. "debug_wipe_json_table", function(ply, cmd, args, argStr)
            garlic_like_create_upgrade_table()
            garlic_like_save_table_to_json(ply, FROZE_GL.garlic_like_upgrades, gl .. "upgrades")
        end)

        concommand.Add(gl .. "debug_print_garlic_like_items_held", function(ply, cmd, args, argStr)
            PrintTable(FROZE_GL.items_held)
        end)

        concommand.Add(gl .. "debug_open_shop", function(ply, cmd, args, argStr)
            garlic_like_open_main_menu()
        end)

        concommand.Add(gl .. "level_up_cl", function(ply, cmd, args, argStr)
            if FROZE_GL.pending_level_ups > 0 then
                FROZE_GL.pending_level_ups = FROZE_GL.pending_level_ups - 1
                garlic_like_show_level_up_screen(ply)
            end
        end)

        concommand.Add(gl .. "debug_animate_enemies_empowered_text", function(ply, cmd, args, argStr)
            garlic_like_enemies_empowered_hud_show()
        end)

        concommand.Add(gl .. "debug_show_level_up_screen", function(ply, cmd, args, argStr)
            garlic_like_show_level_up_screen(ply)
        end)

        concommand.Add(gl .. "print_cl_inventory", function(ply, cmd, args, argStr)
            -- print("\nGARLIC LIKE PRINTING CLIENTSIDE INVENTORY")
            -- PrintTable(FROZE_GL.items_held)
        end)  
    end
end)
--
    -- local rainbowRT = GetRenderTarget("rainbowRT", 1024, 1024)
    -- local rt = GetRenderTarget("rainbowRT2", 1024, 1024)

    -- render.PushRenderTarget(rainbowRT)
    --     render.Clear(0, 0, 0, 0, true, true)
    --     cam.Start2D()
    --         for i=1, 1024 do
    --             local color = HSVToColor(i*.3515625, 1, 1)
    --             surface.SetDrawColor(color.r, color.g, color.b, 255)
    --             surface.DrawRect(i-1, 0, 1, 1024)
    --         end
    --     cam.End2D()
    -- render.PopRenderTarget()

    -- surface.CreateFont("MyFont", {
    --     font = "Arial",
    --     size = 36,
    -- })

    -- local rainbowMat = CreateMaterial( "aRainbowMat", "UnLitGeneric", {
    --     ["$basetexture"] = "rainbowRT",
    --     ["$model"] = 1,
    --     ["$translucent"] = 1
    -- } )

    -- local textMat = CreateMaterial( "RainbowTextMat", "UnLitGeneric", {
    --     ["$basetexture"] = "rainbowRT2",
    --     ["$translucent"] = 1,
    -- } )

    -- local gradient1 = Material("vgui/gradient-u")

    -- hook.Add("HUDPaint", "RainboxText", function()
    --     local h, w = ScrH(),ScrW()

    --     render.PushRenderTarget(rt)
    --         render.Clear( 0, 0, 0, 0, true, true)

    --         render.OverrideAlphaWriteEnable(true, true)
    --         cam.Start2D()
    --             draw.SimpleText("Sample Text", "MyFont", 512, 512, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    --         cam.End2D()
            
    --         render.OverrideAlphaWriteEnable(true, false)
            
    --         cam.Start2D() 
    --             surface.SetDrawColor(0, 60, 255)
    --             surface.SetMaterial(gradient1)
    --             surface.DrawTexturedRectUV(0, 500, 1024, 32, RealTime()*0.5, 0, RealTime()*0.5+1, 0.65)
    --         cam.End2D()
 
    --     render.PopRenderTarget()
    --     --
    --     surface.SetDrawColor(255, 255, 255)
    --     surface.SetMaterial(textMat)
    --     surface.DrawTexturedRect(0, 0, 1280, 720)
    -- end)
    --  