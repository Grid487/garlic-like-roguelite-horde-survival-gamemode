if SERVER then return end 

timer.Simple(2, function()
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
    local color_empowered_text = Color(255, 255, 255, 0)
    local show_empowered_text = false
    local fading_out = false
    --
    local mat_beam = Material("effects/ihalo_haze.vmt")
    local mat_hl = Material("garlic_like/icon_hl.png")
    local mat_heart = Material("garlic_like/icon_ui/heart.png")
    local mat_gradient_l = Material("vgui/gradient-l")
    local mat_gradient_r = Material("vgui/gradient-r")
    local mat_padlock = Material("garlic_like/icon_ui/padlock.png")
    local mat_icon_str = Material("garlic_like/icon_str.png")
    local mat_icon_agi = Material("garlic_like/icon_agi.png")
    local mat_icon_int = Material("garlic_like/icon_int.png")
    -- 

    local level = 1
    local xp = 0
    local xp_text
    local xp_numbers = {}
    local xp_texts = {}
    local xp_text_W = W * 0.55
    local xp_total = 0
    local xp_to_next_level = 500
    local xp_bar_width = 0
    local xp_cumulative = 0
    local pending_level_ups = 0
    local xp_notification_font
    --
    local start, oldxp, newxp = 0, -1, -1
    local barW = W * 0.5
    local animationTime = 0.1
    local minutes = 0
    local seconds = 0
    local addedzero = 0
    
    local tbl_glss = {
        glss_left_pos = W * 0.25 - W * 0.025,
        glss_mid_pos = W * 0.5 - W * 0.025,
        glss_right_pos = W * 0.75 - W * 0.025,
        glss_left_pos_base = W * 0.25,
        glss_mid_pos_base = W * 0.5,
        glss_right_pos_base = W * 0.75,
        glss_height_1 = H * 0.15,
    }
            
    local stats_menu = "STATS"
    local heights_stat_menu_desc = {}
    --
    local tbl_ult = {
        ult_cooldown = 60,
        ult_num_cooldown = 60,
        ult_starttime = RealTime(),
        ult_clicked = false,
        ult_key_combo_activated = false,
    }
    --
    local show_weapon_stats = true
    local line_length = W * 0.75
    local line_alpha_mul = 1
    --
    local weapons_table = {}
    local weapons_table_filtered = {}
    local weapon_image = "entities/weapon_fists.png"
    local weapon_rarity_random = "Sample Rarity "
    local weapon_name_random = "Sample Name"

    for i = 1, 6 do
        heights_stat_menu_desc[#heights_stat_menu_desc + 1] = H * (0.31 + (0.025 * i))
    end

    local choice_panels = {}
    local garlic_like_items_held = {}
    local garlic_like_skills_held = {}
    local garlic_like_relics_held = {}
    local tbl_id_upgrades_statboost = {}
    local tbl_id_upgrades_item_statboost = {}
    local tbl_id_upgrades_skill = {}
    local tbl_id_upgrades_relic = {}

    local tbl_valid_weapons = {}
    local tbl_damage_numbers = {}  
    local tbl_gl_unlockables = {}

    --* GLOBAL ITEM DROPS TABLE
    garlic_like_item_drops_entities = {}

    local tbl_gl_entities = {
        gl .. "wep_crystal", gl .. "weapon_crate_entity", gl .. "station_item_fusing", gl .. "station_weapon_upgrade"
    }
    
    local rarities = {"poor", "common", "uncommon", "rare", "epic", "legendary", "god"} 

    local item_circle_colors = {
        [1] = color_white,
        [2] = color_white,
        [3] = color_white,
        [4] = color_white
    }

    local skill_circle_colors = {
        [1] = color_white,
        [2] = color_white,
        [3] = color_white,
        [4] = color_white
    }

    local relic_circle_colors = {
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

    local skill_cooldown_dark = {
        [1] = color_black_alpha_150,
        [2] = color_black_alpha_150,
        [3] = color_black_alpha_150,
        [4] = color_black_alpha_150
    }

    local skill_cooldown_numbers = {
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = ""
    }

    tbl_gl_rarity_colors = {
        ["poor"] = Color(189, 189, 189),
        ["common"] = Color(255, 255, 255),
        ["uncommon"] = Color(111, 221, 255),
        ["rare"] = Color(0, 132, 255),
        ["epic"] = Color(195, 0, 255),
        ["legendary"] = Color(255, 72, 0),
        ["god"] = Color(255, 0, 0),
    }

    --* RARITY CHANCES TESTING
    local rarity_wep = {
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
    local rarity_starting_num = 1

    for k, entry in SortedPairs(rarity_wep) do
        entry.min = rarity_starting_num
        entry.max = rarity_starting_num + entry.weight
        rarity_starting_num = rarity_starting_num + entry.weight
    end

    -- create sum
    local rarity_weights_sum = 0

    for k, rarity in pairs(rarity_wep) do
        rarity_weights_sum = rarity_weights_sum + rarity.weight
    end 

    local cleared_rarities = table.ClearKeys(rarities)
    -- PrintTable(cleared_rarities)
    --* RARITY CHANCES TESTING END
    tbl_gl_stored_bonused_weapons = {}
    -- 
    local skills = {}

    local FormatColors = {
        [1] = Color(122, 122, 122),
        [2] = Color(146, 58, 58),
        [3] = Color(35, 125, 199),
        [4] = Color(204, 44, 138),
        [5] = Color(158, 41, 226),
        [6] = Color(195, 231, 33),
    }

    --* MATERIALS INVENTORY
    local WepCrystalsInventory = {
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

    local MaterialsInventory = {
        ["Reroll Crystal"] = {
            material = Material("garlic_like/icon_materials/icon_reroll_crystal.png"),
            held_num = 0,
        },
    }

    local tbl_gold_popups = {}

    local tbl_gold_hud = {
        scale_vector = Vector(2, 2, 2),
        scale_num = 1,
        scale_mod = 0,
        bounce = false,
    }

    local glips = {
        entries = {},
        bg_height = H * 0.055,
        bg_width = W * 0.2,
        color_bg = Color(0, 0, 0, 200),
    }

    local tbl_crystal_clusters = {}

    for k, v in pairs(tbl_gl_rarity_colors) do 
        tbl_crystal_clusters[k] = {}
    end
    
    local tbl_unlocks_queue = {}

    local tbl_unlocks_hud = {
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

    local tbl_break_hud = {
        text_break = "BREAK TIME!",
        text_time = 0,
        tb_pos_x = W * 0.5,
        tb_pos_y = H * 0.2,
    }

    local tbl_hud_elements = {
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

    local hide = {
        ["CHudHealth"] = true,
        ["CHudBattery"] = true
    }

    local tbl_run_end_screen = { 
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
        sound_played = false, 
    }
    
    local run_end_screen_stop_showing = true
    local run_end_screen_progress_num = 0

    for id, upgrade in SortedPairs(garlic_like_upgrades) do
        if upgrade.upgrade_type == "statboost" then
            table.insert(tbl_id_upgrades_statboost, id)
        elseif upgrade.upgrade_type == "item_statboost" then
            table.insert(tbl_id_upgrades_item_statboost, id)
        elseif upgrade.upgrade_type == "skill" then
            table.insert(tbl_id_upgrades_skill, id)
        elseif upgrade.upgrade_type == "relic" then
            table.insert(tbl_id_upgrades_relic, id)
        end
    end

    cvars.AddChangeCallback(gl .. "hud_font", function(name, old, new)
        garlic_like_create_fonts()
    end)

    cvars.AddChangeCallback(gl .. "hud_font_2", function(name, old, new)
        garlic_like_create_fonts()
    end) 
    
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
    
    function garlic_like_init_unlockables() 
        --* CREATE UNLOCKABLES FOR CHAR UPGRADES
        for k, stat in pairs(tbl_gl_character_stats) do 
            if stat.unlock_condition then             
                tbl_gl_unlockables[stat.id] = {
                    unlock_status = false, 
                    unlock_condition = stat.unlock_condition,
                    unlock_text = "Unlocks " .. stat.name .. " Char Upgrade",
                }

                if ply:GetPData(gl .. stat.id .. "_unlocked") == "true" then 
                    tbl_gl_unlockables[stat.id].unlock_status = true
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

            tbl_gl_unlockables[gl .. "relic_slot_" .. i] = {
                unlock_status = false, 
                unlock_condition = unlock_condition,
                unlock_text = "Unlocks a Relic Slot",
            }

            if tobool(ply:GetPData(gl .. "relic_slot_" .. i .. "_unlocked")) then 
                tbl_gl_unlockables[gl .. "relic_slot_" .. i].unlock_status = true

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

        weapons_table = weapons.GetList()
        
        for k, wep in SortedPairs(weapons.GetList()) do
            str_1, str_2 = string.find(wep.ClassName, "base") 

            if (string.match(wep.ClassName, "arccw") and not string.match(wep.ClassName, "base") and not string.find(wep.ClassName, "arccw_g18_garlic_like")) then 
                table.insert(tbl_valid_weapons, wep)
            end

            if wep.ClassName == "weapon_fists" then
                tbl_fallback_weapon = wep
            end
        end
    end

    local function outline_box(wide, height) 
        surface.SetDrawColor(255, 0, 0)
        surface.DrawOutlinedRect(0, 0, wide, height, 1)
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

        --! WORK ON CRIT TIERS
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
            size = H * 0.02,
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

        xp_notification_font = gl .. "xp_notification"
        xp_notification_font_extra = gl .. "xp_notification_extra"
        gold_notification_font = gl .. "font_money"
    end

    function garlic_like_get_weapon(wep_choice, tbl_valid_weapons, get_type, rarity)
        wep_choice.wep_rarity = rarity
        wep_choice.wep_rarity_color = tbl_gl_rarity_colors[wep_choice.wep_rarity]
        wep_choice.wep_element = tbl_gl_elements[math.random(1, #tbl_gl_elements)]
        wep_choice.wep_bonuses_amount = garlic_like_determine_weapon_bonuses_amount(wep_choice.wep_rarity)
        wep_choice.wep_bonuses_modifier = garlic_like_determine_weapon_bonuses_modifiers(wep_choice.wep_rarity)
        wep_choice.wep_bonuses = {}

        if wep_choice.wep_bonuses_amount > 0 then
            local rarity_rand_modifier = math.Remap(garlic_like_rarity_to_num(wep_choice.wep_rarity), 1, 7, 1.5, 2)

            for i = 1, wep_choice.wep_bonuses_amount do
                local get_tbl_bonus = tbl_gl_bonuses_weapons[math.random(1, #tbl_gl_bonuses_weapons)]

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
            wep_choice.wep = tbl_valid_weapons[math.random(1, #tbl_valid_weapons)]
        end

        if get_type == "FALLBACK" or wep_choice.wep == nil then
            wep_choice.wep = tbl_fallback_weapon
        end

        wep_choice.wep_name = wep_choice.wep.PrintName
        wep_choice.wep_stored = weapons.Get(wep_choice.wep.ClassName)
        wep_choice.wep_icon = wep_choice.wep_stored.WepSelectIcon or weapons.Get(wep_choice.wep_stored.Base).WepSelectIcon
        local str_1, str_2 = string.find(wep_choice.wep.ClassName, "arccw")

        if str_1 ~= nil then
            local mat = Material("arccw/weaponicons/" .. wep_choice.wep.ClassName)

            if not mat:IsError() then
                wep_choice.wep_icon = surface.GetTextureID(mat:GetTexture("$basetexture"):GetName())
                -- print("ICON " .. wep_choice.wep_icon)
            end
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
            garlic_like_get_weapon(wep_choice, tbl_valid_weapons, "ROLL", rarity)

            if wep_choice.loop > 50 then
                garlic_like_get_weapon(wep_choice, tbl_valid_weapons, "FALLBACK", rarity)
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
        for k, upgrade in SortedPairs(table.ClearKeys(garlic_like_skills_held)) do
            if upgrade.name2 == skill_name then
                local cd_number = GetConVar("dota2_auto_cast_" .. upgrade.name2 .. "_delay"):GetFloat()
                -- local cd_number = upgrade.cooldown
                -- print("UPDATE HUD SKILLS")
                skill_cooldown_numbers[k] = nil
                skill_cooldown_dark[k] = color_black_alpha_150
                skill_cooldown_numbers[k] = cd_number

                for i = 1, cd_number * 100 do
                    timer.Simple(i / 100, function()
                        skill_cooldown_numbers[k] = cd_number - i / 100

                        if skill_cooldown_numbers[k] <= 0 then
                            skill_cooldown_numbers[k] = 0

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
        local picker = math.random(1, rarity_weights_sum)
        local rarity = "poor"

        for name, rarity_entry in SortedPairs(rarity_wep) do
            if IsNumBetween(picker, rarity_entry.min, rarity_entry.max) then
                -- print("RARITY GET:" .. name)
                rarity = name
            end
        end

        return rarity
    end

    function garlic_like_determine_stats(chance, upgrade, upgrade_type)
        local rarity
        local statboost_num

        -- 10%
        if chance <= 0.1 then
            rarity = "poor"
            num_modifier = 1
        elseif chance <= 0.5 then
            -- 40% 
            rarity = "common"
            num_modifier = 2
        elseif chance <= 0.7 then
            -- 20% 
            rarity = "uncommon"
            num_modifier = 3
        elseif chance <= 0.82 then
            -- 12%
            rarity = "rare"
            num_modifier = 4
        elseif chance <= 0.91 then
            -- 9%
            rarity = "epic"
            num_modifier = 5
        elseif chance <= 0.97 then
            -- 6%
            rarity = "legendary"
            num_modifier = 6
        elseif chance <= 1 then
            -- 3% 
            rarity = "god"
            num_modifier = 7
        end

        if upgrade_type == "statboost" then
            statboost_num = math.Round(1 + 2 * num_modifier * (1 + upgrade.upgrade_level * 0.08))
            -- print("DETERMINED STAT BOOST RARITY " .. rarity)
            --* IF CARNAGE
            if GetGlobalInt(gl .. "minutes", 1) >= 20 and ply:GetNWInt(gl .. string.upper(upgrade.name), 1) >= 150 then 
                statboost_num = statboost_num * 3
            end

            return rarity, statboost_num
        elseif upgrade_type == "item_statboost" then
            statboost_num = math.Truncate(upgrade.statboost * num_modifier * (1 + upgrade.upgrade_level * 0.1), 3)
            -- print("DETERMINE ITEM RARITY " .. upgrade.name)
            -- print("DETERIMEND STATBOOST: " .. statboost_num)

            return rarity, statboost_num
        elseif upgrade_type == "skill" then
            damage = math.Round(upgrade.damage * math.Remap(num_modifier, 1, 7, 1, 1.3) * (1 + upgrade.upgrade_level * 0.05))
            cooldown = tonumber(string.format("%.2f", GetConVar("dota2_auto_cast_" .. upgrade.name2 .. "_delay"):GetFloat() * math.Remap(num_modifier, 1, 7, 1, 0.7) * (1 + upgrade.upgrade_level * 0.05)))

            if type(upgrade.area) == "string" then
                -- print("DETERMINED SKILL RARITY")

                return rarity, damage, cooldown
            elseif type(upgrade.area) == "number" then
                area = math.Round(upgrade.area * math.Remap(num_modifier, 1, 7, 1, 1.5))

                return rarity, damage, cooldown, area
            end
        elseif upgrade_type == "relic" then
            if not upgrade.mul_is_debuff then
                mul = math.Truncate(upgrade.mul * math.Remap(num_modifier, 1, 7, 1, 1.5), 2)
            else
                mul = math.Truncate(upgrade.mul * math.Remap(num_modifier, 1, 7, 1, 0.65), 2)
            end

            if upgrade.mul_2 == nil then
                return rarity, mul
            elseif upgrade.mul_2 ~= nil then
                mul_2 = math.Truncate(upgrade.mul_2 * math.Remap(num_modifier, 1, 7, 1, 1.5), 2)

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
            surface.SetMaterial(mat_hl) 
            surface.DrawTexturedRect(w * 0.93, h * 0.45 - w * 0.07 / 2, w * 0.07, w * 0.07)
            draw.DrawText(tostring(money), gl .. "font_title_2", w * 0.91, h * 0.45 - money_h / 2, color_white, TEXT_ALIGN_RIGHT)        
        end

        local dsp = vgui.Create( "DScrollPanel", bf )
        dsp:Dock( FILL )

        for k, entry in SortedPairs(tbl_gl_character_stats) do                         
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
                surface.SetMaterial(mat_hl) 
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

        for id, data in SortedPairs(tbl_gl_unlockables) do 
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
        
        for modifier_name, v in pairs(tbl_gl_enemy_modifiers) do
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

        for k, v in pairs(tbl_gl_elements) do
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

                    for k, upgrade in SortedPairs(garlic_like_upgrades) do
                        local list_item = upgrades_list:Add("DButton")
                        list_item:SetText("")
                        list_item:SetSize(frame:GetWide() * 0.3, frame:GetWide() * 0.2)
                        list_item.upgrade = garlic_like_upgrades[k]
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
                                surface.SetMaterial(mat_hl)
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
                            garlic_like_upgrades[i].upgrade_level = garlic_like_upgrades[i].upgrade_level + 1
                            list_item.upgrade = garlic_like_upgrades[i]
                            list_item.item_price = list_item.upgrade.upgrade_price + list_item.upgrade.upgrade_price_increase * list_item.upgrade.upgrade_level
                            list_item.item_price_tw, list_item.item_price_th = surface.GetTextSize(list_item.item_price)
                            garlic_like_upgrades[i] = list_item.upgrade
                            -- 
                            garlic_like_save_table_to_json(ply, garlic_like_upgrades, gl .. "upgrades")
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
            rarity = "poor"
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

        -- PrintTable( tbl_gl_stored_bonused_weapons)
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
                surface.SetTexture(self.wep_icon)
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
        wep_already_held_text:Hide()  

        for k, wep_choice in pairs(tbl_wep_choice) do
            timer.Simple((k - 1) * 0.2, function()
                surface.PlaySound("garlic_like/mm_rank_up_achieved.wav")

                if wep_choice.fade_in_transparency == nil then
                    wep_choice.fade_in_transparency = 255
                    wep_choice.highlight_transparency = 10
                    wep_choice.icon_set = false
                    --
                    garlic_like_get_weapon(wep_choice, tbl_valid_weapons, "ROLL", rarity)

                    -- print("WEP RARITY: " .. wep_choice.wep_rarity)
                end

                wep_choice:Show()

                wep_choice.Paint = function(self, w, h)
                    wep_choice.fade_in_transparency = math.Approach(wep_choice.fade_in_transparency, 0, 30)
                    local element = string.upper(wep_choice.wep_element.name)
                    local mat_element = wep_choice.wep_element.mat_1
                    --
                    draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 35, 255))
                    surface.SetDrawColor(255, 255, 255)
                    surface.DrawCircle(w * 0.5, h * 0.2, w * 0.25, wep_choice.wep_rarity_color)
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetTexture(wep_choice.wep_icon)
                    surface.DrawTexturedRect(w * 0.15, h * 0.1, w * 0.7, w * 0.4)
                    draw.DrawText(string.upper(wep_choice.wep_rarity), gl .. "font_subtitle", w * 0.5, h * 0.35, wep_choice.wep_rarity_color, TEXT_ALIGN_CENTER)
                    -- draw.DrawText(element, gl .. "font_subtitle", w * 0.5, h * 0.4, wep_choice.wep_element.color, TEXT_ALIGN_CENTER)
                    -- local element_w, element_h = surface.GetTextSize(element)
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(mat_element)
                    surface.DrawTexturedRect(w * 0.5 - W * 0.0055, h * 0.41, W * 0.011, W * 0.011)
                    
                    draw.DrawText(wep_choice.wep_name, gl .. "font_title_3", w * 0.5, h * 0.45, color_white, TEXT_ALIGN_CENTER)
                    draw.RoundedBox(6, 0, 0, w, h, Color(wep_choice.wep_rarity_color.r, wep_choice.wep_rarity_color.g, wep_choice.wep_rarity_color.b, wep_choice.fade_in_transparency))                    

                    if wep_choice.wep_bonuses_amount > 0 then
                        draw.DrawText("When held :", gl .. "font_subtitle", w * 0.5, h * 0.52, color_white, TEXT_ALIGN_CENTER)

                        for i = 1, wep_choice.wep_bonuses_amount do
                            gl_cse(ply, w * 0.5, (h * 0.55) + (i * h * 0.05), 100 * wep_choice.wep_bonuses[i].modifier, "%", wep_choice.wep_bonuses[i].desc, true, false, "", false, gl .. "font_subtitle", nil, true)
                        end
                    end

                    if not self:IsHovered() and not self:IsDown() then
                        wep_choice.highlight_transparency = math.Approach(wep_choice.highlight_transparency, 0, 3)
                    end

                    if k == 1 then 
                        wep_already_held:Hide()
                        wep_already_held_text:Hide() 
                    end

                    if self:IsHovered() then  
                        --! FIND A WAY TO HIDE wep_already_held WHEN NO WEAPON IS BEING HOVERED
                        --* Shows a preview of the already held weapon of the same class
                        if  tbl_gl_stored_bonused_weapons[self.wep.ClassName] then 
                            --* If the shown owned weapon isn't the same as the one being hovered, reset
                            if wep_already_held.wep_name ~= self.wep_name then 
                                wep_already_held.initialized = false
                                wep_already_held:Hide()
                                wep_already_held_text:Hide()
                            end 
                                
                            self.sbw =  tbl_gl_stored_bonused_weapons[self.wep.ClassName]
                            wep_already_held:Show()
                            wep_already_held_text:Show()

                            -- INITIALIZE THE PANEL, GIVE IT THE SAME PROPERTIES AS wep_choice
                            if not wep_already_held.initialized then 
                                wep_already_held.initialized = true 
                                -- 
                                wep_already_held.wep_rarity =  self.sbw.rarity
                                wep_already_held.wep_rarity_color =  tbl_gl_rarity_colors[self.sbw.rarity]  
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
                            wep_choice.highlight_transparency = 20
                        else 
                            wep_choice.highlight_transparency = 10 
                        end 
                    end

                    draw.RoundedBox(6, 0, 0, w, h, Color(wep_choice.wep_rarity_color.r, wep_choice.wep_rarity_color.g, wep_choice.wep_rarity_color.b, wep_choice.highlight_transparency))
                end

                wep_choice.DoClick = function(self)   
                    if not ready_to_click then return end             
                    surface.PlaySound("items/gift_pickup.wav")

                    if wep_choice.wep_bonuses_amount > 0 then
                        tbl_gl_stored_bonused_weapons[wep_choice.wep.ClassName] = {
                            bonuses = {},
                            bonus_amount = 0,
                            name = "",
                            rarity = "",
                            level = 1
                        }

                        tbl_gl_stored_bonused_weapons[wep_choice.wep.ClassName].bonuses = wep_choice.wep_bonuses
                        tbl_gl_stored_bonused_weapons[wep_choice.wep.ClassName].name = wep_choice.wep.PrintName
                        tbl_gl_stored_bonused_weapons[wep_choice.wep.ClassName].rarity = wep_choice.wep_rarity
                        tbl_gl_stored_bonused_weapons[wep_choice.wep.ClassName].element = wep_choice.wep_element.name
                        tbl_gl_stored_bonused_weapons[wep_choice.wep.ClassName].bonus_amount = wep_choice.wep_bonuses_amount
                        tbl_gl_stored_bonused_weapons[wep_choice.wep.ClassName].level = 1 
                    end

                    -- PrintTable( tbl_gl_stored_bonused_weapons)
                    --
                    net.Start(gl .. "choose_weapon")
                    net.WriteString(wep_choice.wep.ClassName)
                    net.WriteString("PICK_WEAPON")
                    net.WriteTable( tbl_gl_stored_bonused_weapons)
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
        for k, v in SortedPairs(garlic_like_upgrades) do
            if v.name == upgrade.name and upgrade.upgrade_type == "item_statboost" then
                garlic_like_upgrades[k].disable_picking_up = true
                garlic_like_items_held[upgrade.name] = v
                garlic_like_items_held[upgrade.name].rarity = item_rarity
                garlic_like_items_held[upgrade.name].statboost = statboost_num

                for k2, v2 in SortedPairs(table.ClearKeys(garlic_like_items_held)) do
                    item_circle_colors[k2] = tbl_gl_rarity_colors[v2.rarity]
                end

                garlic_like_net_start_chose_upgrade(ply, upgrade, statboost_num)
                --
                -- PrintTable(garlic_like_upgrades)
            elseif v.name == upgrade.name and upgrade.upgrade_type == "skill" then
                garlic_like_upgrades[k].disable_picking_up = true
                garlic_like_skills_held[upgrade.name] = v
                garlic_like_skills_held[upgrade.name].rarity = item_rarity
                garlic_like_skills_held[upgrade.name].damage = damage
                garlic_like_skills_held[upgrade.name].cooldown = cooldown
                garlic_like_skills_held[upgrade.name].area = area

                if type(upgrade.area) == "string" then
                    garlic_like_start_auto_cast(ply, v, damage, cooldown)
                elseif type(upgrade.area) == "number" then
                    garlic_like_start_auto_cast(ply, v, damage, cooldown, area)
                end

                for k3, v3 in SortedPairs(table.ClearKeys(garlic_like_skills_held)) do
                    skill_circle_colors[k3] = tbl_gl_rarity_colors[v3.rarity]
                end

                garlic_like_net_start_chose_upgrade(ply, upgrade, statboost_num)
                --
                -- PrintTable(garlic_like_upgrades)
            elseif v.name == upgrade.name and upgrade.upgrade_type == "relic" then
                garlic_like_upgrades[k].disable_picking_up = true
                garlic_like_relics_held[upgrade.name] = v
                garlic_like_relics_held[upgrade.name].rarity = item_rarity
                garlic_like_relics_held[upgrade.name].mul = relic_mul

                if v.mul_2 then
                    garlic_like_relics_held[upgrade.name].mul_2 = relic_mul_2
                end

                for k3, v3 in SortedPairs(table.ClearKeys(garlic_like_relics_held)) do
                    relic_circle_colors[k3] = tbl_gl_rarity_colors[v3.rarity]
                end

                garlic_like_net_start_chose_upgrade(ply, upgrade, statboost_num)
                --
                -- PrintTable(garlic_like_upgrades)
            end
        end
        -- PrintTable(garlic_like_upgrades)
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
        choice_panels = {} 
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
                garlic_like_upgrades_cleared = table.ClearKeys(garlic_like_upgrades)
                Chance_upgrade_choice = math.random(1, 100)
                local loop = 1
                local chance_stats = (0.5 * 100)
                local chance_items = chance_stats + (0.25 * 100)
                local chance_skills = chance_items + (0.1 * 100)
                local chance_relics = chance_skills + (0.15 * 100)

                -- print("CHANCE UPGRADE CHOICE " .. Chance_upgrade_choice)
                if Chance_upgrade_choice <= chance_stats then
                    choice_panel.upgrade = garlic_like_upgrades[table.Random(tbl_id_upgrades_statboost)]
                elseif Chance_upgrade_choice <= chance_items and table.Count(garlic_like_items_held) < 4 then                
                    choice_panel.upgrade = garlic_like_upgrades[table.Random(tbl_id_upgrades_item_statboost)]

                    while choice_panel.upgrade == nil or choice_panel.upgrade.disable_picking_up do
                        loop = loop + 1
                        -- print("Loop A " .. loop)

                        if loop > 50 then
                            choice_panel.upgrade = garlic_like_upgrades[table.Random(tbl_id_upgrades_statboost)]
                        end

                        choice_panel.upgrade = garlic_like_upgrades[table.Random(tbl_id_upgrades_item_statboost)]
                    end
                elseif Chance_upgrade_choice <= chance_skills and table.Count(garlic_like_skills_held) < 4 then                
                    choice_panel.upgrade = garlic_like_upgrades[table.Random(tbl_id_upgrades_skill)]

                    while choice_panel.upgrade == nil or choice_panel.upgrade.disable_picking_up do
                        loop = loop + 1
                        -- print("Loop B " .. loop)

                        if loop > 50 then
                            choice_panel.upgrade = garlic_like_upgrades[table.Random(tbl_id_upgrades_statboost)]
                        end

                        choice_panel.upgrade = garlic_like_upgrades[table.Random(tbl_id_upgrades_skill)]
                    end
                elseif Chance_upgrade_choice <= chance_relics and table.Count(garlic_like_relics_held) < 4 + ply:GetNWInt(gl .. "relic_slots_unlocked", 0) then                
                    choice_panel.upgrade = garlic_like_upgrades[table.Random(tbl_id_upgrades_relic)]

                    while choice_panel.upgrade == nil or choice_panel.upgrade.disable_picking_up do
                        loop = loop + 1
                        -- print("Loop C " .. loop)

                        if loop > 50 then
                            choice_panel.upgrade = garlic_like_upgrades[table.Random(tbl_id_upgrades_statboost)]
                        end

                        choice_panel.upgrade = garlic_like_upgrades[table.Random(tbl_id_upgrades_relic)]
                    end
                else
                    choice_panel.upgrade = garlic_like_upgrades[table.Random(tbl_id_upgrades_statboost)]
                end

                Chance = math.random()

                if choice_panel.upgrade.upgrade_type == "statboost" then
                    choice_panel.rarity, choice_panel.statboost = garlic_like_determine_stats(Chance, choice_panel.upgrade, choice_panel.upgrade.upgrade_type)
                    --* CARNAGE STAT UPGRADES 
                    -- PrintTable(choice_panel.upgrade)
                    if GetGlobalInt(gl .. "minutes", 1) >= 20 and ply:GetNWInt(gl .. string.upper(choice_panel.upgrade.name), 1) >= 100 then  
                        choice_panel.upgrade.icon = "garlic_like/icon_" .. choice_panel.upgrade.name .. "_carnage.png"
                        -- choice_panel.upgrade.name = "carnage " .. choice_panel.upgrade.name
                    end
                elseif choice_panel.upgrade.upgrade_type == "item_statboost" then
                    choice_panel.rarity, choice_panel.statboost = garlic_like_determine_stats(Chance, choice_panel.upgrade, choice_panel.upgrade.upgrade_type)
                elseif choice_panel.upgrade.upgrade_type == "skill" then
                    if type(choice_panel.upgrade.area) == "string" then
                        choice_panel.rarity, choice_panel.statboost, choice_panel.cooldown = garlic_like_determine_stats(Chance, choice_panel.upgrade, choice_panel.upgrade.upgrade_type)
                        choice_panel.damage = math.Round(choice_panel.statboost * (1 + ply:GetNWFloat(gl .. "bonus_damage")))
                        choice_panel.area = choice_panel.upgrade.area
                    elseif type(choice_panel.upgrade.area) == "number" then
                        choice_panel.rarity, choice_panel.statboost, choice_panel.cooldown, choice_panel.area = garlic_like_determine_stats(Chance, choice_panel.upgrade, choice_panel.upgrade.upgrade_type)
                        choice_panel.damage = choice_panel.statboost
                    end
                elseif choice_panel.upgrade.upgrade_type == "relic" then
                    choice_panel.rarity, choice_panel.mul, choice_panel.mul_2 = garlic_like_determine_stats(Chance, choice_panel.upgrade, choice_panel.upgrade.upgrade_type)
                end

                choice_panel.upgrade_type = choice_panel.upgrade.upgrade_type
                --
                choice_panel.color_rarity_border = tbl_gl_rarity_colors[choice_panel.rarity]
            end

            timer.Create(gl .. "lower_transparency", 0.5, 1, function()
                lower_highlight_transparency()
            end)

            -- PrintTable(tbl_id_upgrades_statboost)
            -- PrintTable(garlic_like_upgrades[tbl_id_upgrades_statboost[math.random(1, #tbl_id_upgrades_statboost)]])

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
                        surface.SetMaterial(Material(Choice.upgrade.icon))
                        surface.DrawTexturedRect(w * 0.25, h * 0.25, w * 0.5, h * 0.5)
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.DrawCircle(w * 0.5, h * 0.5, W * 0.04, Choice.color_rarity_border)
                    end

                    local name = vgui.Create("DLabel", Choice, gl .. "name_" .. i)
                    name:SetPos(0, Choice:GetTall() * 0.1)
                    name:SetSize(Choice:GetWide(), Choice:GetTall() * 0.5)
                    name:SetFont("Default")
                    name:SetText("")
                    name.text = string.upper(Choice.upgrade.name)
                    name.color = color_white
                    name.color_carnage = Color(221, 0, 0)

                    -- print("ICON " .. Choice.upgrade.icon)

                    if string.find(Choice.upgrade.icon, "carnage") then 
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
                        draw.DrawText(Choice.upgrade.desc, gl .. "font_subtitle", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER)
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

                    if Choice.upgrade.upgrade_type == "statboost" then
                        statboost_num.sb_type = string.upper(Choice.upgrade.name)
                        statboost_num.STR_Plus = math.Round(ply:GetNWInt(gl .. "STR", 1) / ply:GetNWFloat(gl .. "bonus_stat_mult_crystal", 1)) + statboost_num.num
                        statboost_num.AGI_Plus = math.Round(ply:GetNWInt(gl .. "AGI", 1) / ply:GetNWFloat(gl .. "bonus_stat_mult_crystal", 1)) + statboost_num.num
                        statboost_num.INT_Plus = math.Round(ply:GetNWInt(gl .. "INT", 1) / ply:GetNWFloat(gl .. "bonus_stat_mult_crystal", 1)) + statboost_num.num
                    elseif Choice.upgrade.upgrade_type == "item_statboost" and Choice.upgrade.item_type == "reducing_mult" then
                        statboost_num.num = Choice.statboost
                        statboost_num.item_modifier = 1
                        statboost_num.item_additive = -1
                        statboost_num.item_string_operator = "x"
                    elseif Choice.upgrade.upgrade_type == "item_statboost" and Choice.upgrade.item_type == "increasing_mult" then
                        statboost_num.num = Choice.statboost
                        statboost_num.item_modifier = 1
                        statboost_num.item_additive = 1
                        statboost_num.item_string_operator = "x"
                    elseif Choice.upgrade.upgrade_type == "skill" then
                        statboost_num.num = Choice.damage

                        if type(Choice.area) ~= "string" then
                            Choice.area_shortdesc = " AREA"
                        else
                            Choice.area_shortdesc = ""
                        end
                    elseif Choice.upgrade.upgrade_type == "relic" then
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
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 1), "", math.Round(math.max(0, statboost_num.num * 3) * ply:GetNWFloat(gl .. "bonus_hp_boost_mult", 1)), " HP BOOST", true, true, "+" .. ply:GetNWInt(gl .. "hp_boost", 0) .. " + " )
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 2), "%", math.Truncate(statboost_num.num * 0.005, 3) * 100, " MAX HP Regen Overheal", true, true, "%" .. math.Truncate(ply:GetNWFloat(gl .. "max_overheal", 1.5), 2) * 100 .. " + " )
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 3), "%", string.format("%.1f", statboost_num.num * 0.005 * ply:GetNWFloat(gl .. "bonus_damage_mult", 0) * 100), " DMG Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_damage", 0) * 100) .. " + " )
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 4), "%", string.format("%.1f", math.min(0.75, statboost_num.num * 0.005) * 100), " BLOCK DMG Reduction", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_block_resistance", 0) * 100) .. " + " )
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 5), "", math.Truncate(math.max(0, statboost_num.num / 40), 2), " HP REGEN/ s", true, true, ply:GetNWInt(gl .. "bonus_hp_regen", 1) .. " + " )
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 6), "%", string.format("%.1f", (statboost_num.num * 0.015) * 100), " CRITICAL DMG", true, true, "%" .. string.format("%.1f", (1 + ply:GetNWFloat(gl .. "bonus_critical_damage", 0)) * 100) .. " + " )
                            elseif statboost_num.sb_type == "AGI" then
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 1), "%", string.format("%.1f", math.min(0.95, statboost_num.num * 0.004) * 100), " DMG Reduction", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_resistance", 0) * 100) .. " + " )
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 2), "", math.max(0, math.Round(statboost_num.num / 4)), " FLAT DMG Reduction", true, true, "+" .. ply:GetNWInt(gl .. "bonus_resistance_flat", 0) .. " + " )
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 3), "%", string.format("%.1f", math.min(1, statboost_num.num * 0.005) * 100), " BLOCK Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_block_chance", 0) * 100) .. " + " )
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 4), "%", string.format("%.1f", math.min(0.5, statboost_num.num * 0.0025) * 100), " EVASION Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_evasion_chance", 0) * 100) .. " + " )
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 5), "%", string.format("%.1f", statboost_num.num * 0.007 * ply:GetNWFloat(gl .. "bonus_critical_chance_mult", 1) * 100), " CRITICAL Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_critical_chance", 0) * 100) .. " + " )
                                gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 6), "%", string.format("%.1f", math.min(5, statboost_num.num * 0.005) * 100), " MULTI HIT Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_multihit_chance", 0) * 100) .. " + " )
                            elseif statboost_num.sb_type == "INT" then
                                gl_cse(ply, pos_x_mid, h * 0.625, "", math.max(0, statboost_num.num * 2), " MAX MANA", true, true, "+" .. ply:GetNWInt(gl .. "max_mana", 0) - 100 .. " + " )
                                gl_cse(ply, pos_x_mid, h * 0.675, "", math.Truncate(statboost_num.num / 50, 3), " MANA REGEN/ 0.1s", true, true, "" .. ply:GetNWInt(gl .. "mana_regen", 1) .. " + " )
                                gl_cse(ply, pos_x_mid, h * 0.725, "%", string.format("%.1f", math.max(0, statboost_num.num * 0.01) * 100), " MANA DMG Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_mana_damage", 0) * 100) .. " + " )
                                gl_cse(ply, pos_x_mid, h * 0.775, "%", string.format("%.1f", math.min(0.85, statboost_num.num * 0.005) * 100), " MANA DMG Reduction", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_mana_resistance", 0) * 100) .. " + " )
                                gl_cse(ply, pos_x_mid, h * 0.825, "%", string.format("%.1f", statboost_num.num * 0.003 * ply:GetNWFloat(gl .. "bonus_xp_mult", 1) * 100), " XP GAIN Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_xp_gain", 0) * 100) .. " + " )
                                gl_cse(ply, pos_x_mid, h * 0.875, "%", string.format("%.1f", (1 - math.max(0.1, 1 - statboost_num.num * 0.0015)) * 100), " COOLDOWN Reduction", true, true, "%" .. string.format("%.1f", (1 - ply:GetNWFloat(gl .. "bonus_cooldown_mult", 0)) * 100) .. " + " )
                            end
                        elseif Choice.upgrade_type == "item_statboost" then
                            if string.lower(name.text) == "sword" then
                                gl_cse(ply, pos_x_mid, h * 0.625, "%", string.format("%.1f", (1 + statboost_num.num) * ply:GetNWFloat(gl .. "bonus_damage", 0) * 100), " DMG Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_damage", 0) * 100) .. " > ")
                            elseif string.lower(name.text) == "crystal" then
                                gl_cse(ply, pos_x_mid, h * 0.625, "", math.Round(ply:GetNWInt(gl .. "STR") * (1 + statboost_num.num)), " STR", true, true, "" .. ply:GetNWInt(gl .. "STR") .. " > ")
                                gl_cse(ply, pos_x_mid, h * 0.675, "", math.Round(ply:GetNWInt(gl .. "AGI") * (1 + statboost_num.num)), " AGI", true, true, "" .. ply:GetNWInt(gl .. "AGI") .. " > ")
                                gl_cse(ply, pos_x_mid, h * 0.725, "", math.Round(ply:GetNWInt(gl .. "INT") * (1 + statboost_num.num)), " INT", true, true, "" .. ply:GetNWInt(gl .. "INT") .. " > ")
                            elseif string.lower(name.text) == "glasses" then
                                gl_cse(ply, pos_x_mid, h * 0.625, "%", string.format("%.1f", ply:GetNWFloat(gl .. "bonus_critical_chance", 0) * (1 + statboost_num.num) * 100), " CRITICAL Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_critical_chance", 0) * 100) .. " > ")
                            elseif string.lower(name.text) == "xp orb" then
                                gl_cse(ply, pos_x_mid, h * 0.625, "%", string.format("%.1f", ply:GetNWFloat(gl .. "bonus_xp_gain", 0) * (1 + statboost_num.num) * 100), " XP GAIN Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_xp_gain", 0) * 100) .. " > ")
                            elseif string.lower(name.text) == "muscles" then
                                gl_cse(ply, pos_x_mid, h * 0.625, "+", math.Round(ply:GetNWInt(gl .. "hp_boost", 0) * (1 + statboost_num.num)), " HP BOOST", true, true, "+" .. ply:GetNWInt(gl .. "hp_boost", 0) .. " > ")
                            end

                            gl_cse(ply, pos_x_mid, h * 0.5, statboost_num.item_string_operator, math.abs(statboost_num.item_additive + statboost_num.num) * statboost_num.item_modifier, "", true)
                        elseif Choice.upgrade_type == "relic" then
                            if Choice.upgrade.mul_2 == nil then
                                -- function gl_cse(ply, pos_x, pos_y, front_operator, numbers, short_desc, align_center_y, additional_front_text, front_text, rainbow, font, color)
                                if Choice.upgrade.mul_is_debuff then
                                    gl_cse(ply, pos_x_mid, h * 0.625, Choice.mul * 100 .. "%", "", Choice.upgrade.shortdesc, false, false, "", false, nil, color_red)
                                elseif Choice.upgrade.mul_is_second then
                                    gl_cse(ply, pos_x_mid, h * 0.625, Choice.mul .. "s", "", Choice.upgrade.shortdesc, false, false, "", false, nil)
                                else
                                    gl_cse(ply, pos_x_mid, h * 0.625, Choice.mul * 100 .. "%", "", Choice.upgrade.shortdesc)
                                end
                            elseif Choice.upgrade.mul_2 ~= nil then
                                gl_cse(ply, pos_x_mid, h * 0.625, Choice.mul * 100 .. "%", "", Choice.upgrade.shortdesc)
                                gl_cse(ply, pos_x_mid, h * 0.675, Choice.mul_2 * 100 .. "%", "", Choice.upgrade.shortdesc_2)
                            end
                        end
                    end

                    Choice.ishovered_transparency = 10

                    Choice.Paint = function(self, w, h)
                        draw.RoundedBox(6, w * 0.02, h * 0.013, w * 0.98, h * 0.98, color_black_alpha_100)
                        draw.RoundedBox(6, w * 0.01, h * 0.007, w * 0.98, h * 0.985, Color(35, 35, 35))

                        for i = 1, 5 do
                            surface.SetDrawColor(255, 255, 255)

                            if Choice.upgrade.upgrade_level >= i then
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
                        garlic_like_choose_upgrade(ply, true, name.text, statboost_num.num, Choice.rarity, Choice.upgrade, Choice.damage, Choice.cooldown, Choice.area, Choice.mul, Choice.mul_2)
                        BASEPANEL:Remove()

                        for k, v in pairs(choice_panels) do
                            v:Remove()
                        end
                    end

                    table.insert(choice_panels, Choice)
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
                -- PrintTable(choice_panels)

                -- for k, panel in pairs(choice_panels) do 
                --     create_upgrade_choice(panel)
                -- end

                -- lower_highlight_transparency()

                self:Hide()
                self:SetY(H + H * 0.05)
                BlackBG:Remove()

                for k, v in pairs(choice_panels) do
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
        --     for k, v in pairs(choice_panels) do
        --         v:Remove()
        --     end
        -- end)
        do
        end
    end

    function garlic_like_enemies_empowered_hud_show()
        show_empowered_text = true
        color_empowered_text = color_white

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
                                color_empowered_text = Color(255, 255, 255, 255 - transparency)

                                if transparency == 255 then
                                    show_empowered_text = false
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

        for k, rarity_entry in pairs(cleared_rarities) do
            if rarity == rarity_entry then
                rarity_num = k
                modifier = math.Truncate(modifier * math.Remap(rarity_num, 1, 7, 1, 3), 1)
            end
        end

        return modifier
    end

    function garlic_like_rarity_to_num(rarity)
        local num = 0

        for k, rarity_entry in pairs(rarities) do
            if rarity == rarity_entry then
                num = k
            end
        end

        return num
    end

    function garlic_like_update_cooldowns_weapon(ply, wep_name)
        for k, skill in pairs(skills) do
            RunConsoleCommand("dota2_auto_cast_" .. skill.name .. "_delay", skill.cooldown)
        end

        timer.Simple(0.1, function()
            for k, skill in pairs(skills) do
                -- RunConsoleCommand("dota2_auto_cast_" .. skill.name .. "_delay", skill.cooldown / ply:GetNWFloat(gl .. wep_name .. "cooldown_speed", 1))
                --! this is wrong because when you upgrade INT, it takes the _delay convar value, increases it with cdr temp without taking account the decrease made with the wep modifier.
            end
        end)
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

    local function garlic_like_create_point_bar(type, bar_x, bar_y, bar_w, bar_h, bar_t_x, bar_t_y, bar_color, bar_color_gradient) 
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
        surface.SetMaterial(mat_gradient_r) 
        surface.DrawTexturedRectUV(points_x + points_width * 0.2, points_y, points_width * 0.8 - 1, points_height, 0, 0, 1, 1)
        -- small line under
        draw.RoundedBox(0, points_x, points_y + points_height * 0.8, math.max(0, points_width - 1), points_height * 0.2, bar_color_gradient)
        surface.SetDrawColor(bar_color:Unpack())
        surface.SetMaterial(mat_gradient_r) 
        surface.DrawTexturedRectUV(points_x + points_width * 0.2, points_y + points_height * 0.8, points_width * 0.8 - 1, points_height * 0.2, 0, 0, 1, 1)

        -- overheal for hp
        if type == "HP" and cur_points > max_points then 
            local points_width_2 = math.min(bar_w * 0.985, math.Remap(cur_points, max_points, max_points * ply:GetNWFloat(gl .. "max_overheal", 1), 0, bar_w * 0.985))
            -- the bigger shape
            draw.RoundedBox(0, points_x, points_y, points_width_2, points_height, tbl_hud_elements.hpbar_color_2)
            surface.SetDrawColor(tbl_hud_elements.hpbar_color_gradient_2:Unpack())
            surface.SetMaterial(mat_gradient_r) 
            surface.DrawTexturedRectUV(points_x + points_width_2 * 0.2, points_y, points_width_2 * 0.8 - 1, points_height, 0, 0, 1, 1)
            -- small line under
            draw.RoundedBox(0, points_x, points_y + points_height * 0.8, math.max(0, points_width_2 - 1), points_height * 0.2, tbl_hud_elements.hpbar_color_gradient_2)
            surface.SetDrawColor(tbl_hud_elements.hpbar_color_2:Unpack())
            surface.SetMaterial(mat_gradient_r) 
            surface.DrawTexturedRectUV(points_x + points_width_2 * 0.2, points_y + points_height * 0.8, points_width_2 * 0.8 - 1, points_height * 0.2, 0, 0, 1, 1)
        end

        -- local points_text = cur_points  
        surface.SetFont(gl .. "font_subtitle_2") 
        local points_t_w, points_t_h = surface.GetTextSize(points_text)

        draw.DrawText(points_text, gl .. "font_subtitle_2", points_x + bar_w * 0.97, points_y - H * 0.007, color_white, TEXT_ALIGN_RIGHT)
    end

    garlic_like_init() 
    garlic_like_create_fonts()
    garlic_like_animated_xp_fonts_create()

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
        skills = temp_skills
        garlic_like_update_cooldowns_weapon(ply, ply:GetActiveWeapon():GetClass())
        -- PrintTable(skills)
    end)

    net.Receive(gl .. "cooldown_speed_increase", function(len, ply)
        local ply = LocalPlayer()
        local wep_name = net.ReadString()
        garlic_like_update_cooldowns_weapon(ply, wep_name)
    end)
    
    net.Receive(gl .. "update_database_sv_to_cl", function(len, ply)
        local ply = net.ReadEntity()
        local order_type = net.ReadString()
        local item_name = net.ReadString()
        local item_rarity = net.ReadString()
        local item_increase_num = net.ReadInt(32) 

        if order_type == "food" then return end 

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
            -- temp_table = garlic_like_load_json_to_table(ply, gl .. "upgrades.json", garlic_like_upgrades)
            -- for k, upgrade in SortedPairs(garlic_like_upgrades) do
            --     upgrade.upgrade_level = temp_table[k].upgrade_level
            -- end
            return
        elseif order_type == "update_held_num_ores" then 
            -- print("updated " .. item_name .. " amount!")

            for k, entry in ipairs(WepCrystalsInventory) do
                if entry.rarity == item_rarity or entry.name == item_name then
                    entry.held_num = entry.held_num + item_increase_num
                    -- print(gl .. "held_num_material_" .. rarities[k]) 
                    RunConsoleCommand(gl .. "debug_item_pickup_test", entry.name, item_increase_num, item_rarity, "ore")
                end
            end  
        elseif order_type == "update_held_num_materials" then 
            for name, entry in pairs(MaterialsInventory) do
                if name == item_name then
                    entry.held_num = entry.held_num + item_increase_num 
                    RunConsoleCommand(gl .. "debug_item_pickup_test", item_name, item_increase_num, item_rarity, "material")
                end
            end
        elseif order_type == "load_saved_held_num_material" then
            for k, entry in pairs(WepCrystalsInventory) do
                entry.held_num = ply:GetNWInt(gl .. "held_num_material_" .. string.lower(entry.rarity))
            end
        end

        --! add rarrities to WepCrystalsInventory !--
        -- PrintTable(WepCrystalsInventory)
    end)

    net.Receive(gl .. "update_skills_held_table", function(len, ply)
        local upgrade_name = net.ReadString()
        local new_cooldown = net.ReadFloat()

        for k, upgrade in SortedPairs(garlic_like_skills_held) do
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
        -- PrintTable(tbl_gl_unlockables)
        -- 
        ply:SetPData(id .. "_unlocked", true)

        tbl_gl_unlockables[id].unlock_status = true
    end)

    net.Receive(gl .. "reset_cl", function(len, ply)
        local ply = LocalPlayer()
        garlic_like_create_upgrade_table()
        xp = 0
        xp_total = 0
        xp_to_next_level = 500
        pending_level_ups = 0
        garlic_like_items_held = {}
        garlic_like_skills_held = {}
        item_circle_colors[1] = color_white
        item_circle_colors[2] = color_white
        item_circle_colors[3] = color_white
        item_circle_colors[4] = color_white
        skill_circle_colors = {
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
        surface.PlaySound("garlic_like/mm_xp_chime.wav")
        xp = math.Round(net.ReadInt(32) * (1 + ply:GetNWFloat(gl .. "bonus_xp_gain", 0)))
        xp_cumulative = xp_cumulative + xp
        xp_type = net.ReadString()
        xp_total = xp_total + xp

        if xp_type == "HEADSHOT" then
            xp_text = "HEADSHOT!"
            table.insert(xp_texts, 1, xp_text)
            -- xp_texts[1] = xp_text
            -- xp_texts[1] = xp_text
            -- timer.Simple(0.5, function()
            --     xp_texts[#xp_texts] = ""
            -- end)
        elseif xp_type == "KILL" then
        end

        -- table.insert(xp_texts, 1, "")
        local function garlic_like_level_up_cl(ply, level, xp_to_next_level)
            -- garlic_like_show_level_up_screen(ply)
            -- surface.PlaySound("garlic_like/mm_rank_up_achieved.wav")
            -- surface.PlaySound("garlic_like/level_up_skyrim.wav")
            surface.PlaySound("garlic_like/level_up_disgaea_2.wav")
            ply:ScreenFade(SCREENFADE.IN, Color(252, 255, 98, 30), 0.3, 0)
            net.Start(gl .. "update_ply_info")
            net.WriteEntity(ply)
            net.WriteInt(level, 32)
            net.WriteInt(xp_to_next_level, 32)
            net.SendToServer()
        end

        -- LEVEL UP
        print("xp_total: " .. xp_total)
        print("xp_to_next_level: " .. xp_to_next_level)

        if xp_total >= xp_to_next_level then
            local i = 1

            while xp_total >= xp_to_next_level do
                level = level + 1
                pending_level_ups = pending_level_ups + 1
                xp_total = xp_total - xp_to_next_level
                xp_to_next_level = math.Round(xp_to_next_level * 1.09 + 600 * (1.1 + level / 8))

                if i == 1 then
                elseif i >= 2 then
                    garlic_like_level_up_cl(ply, level, xp_to_next_level)

                    timer.Simple(i / 3, function()
                        level = level + 1
                    end)
                end

                garlic_like_level_up_cl(ply, level, xp_to_next_level)
                i = i + 1
            end
        end

        xp_bar_width = math.Remap(xp_total, 0, xp_to_next_level, 0, W * 0.5)
        color_yellow = Color(255, 238, 0, 255)
        -- table.insert(xp_numbers, 1, xp)
        xp_numbers[1] = xp_cumulative

        if #xp_numbers > 6 then
            xp_numbers[#xp_numbers] = nil
        end

        if #xp_texts > 6 then
            xp_texts[#xp_texts] = nil
        end

        -- PrintTable(xp_numbers)
        fading_out = false

        if GetConVar(gl .. "hud_xp_notification_animation"):GetInt() > 0 then
            for i = 1, 30 do
                timer.Simple(i / 300, function()
                    xp_notification_font = gl .. "xp_notification_" .. i
                    xp_notification_font_extra = gl .. "xp_notification_extra_" .. i
                end)
            end
        end

        timer.Create(gl .. "fade_out_text", 1.5, 1, function()
            fading_out = true

            for i = 1, 255 do
                timer.Simple(i / 900, function()
                    if not fading_out then return end
                    color_yellow = Color(255, 238, 0, 255 - i)

                    if i == 255 then
                        xp_numbers = {}
                        xp_texts = {}
                        xp_cumulative = 0
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
        tbl_gold_popups[#tbl_gold_popups + 1] = {
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
        
        for k, v in pairs(tbl_gl_character_stats) do 
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
        tbl_run_end_screen = { 
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
            total_dmg_dealt = net.ReadInt(32),
            total_dmg_taken = net.ReadInt(32),
            highest_dmg = net.ReadInt(32),    
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
            sound_played = false, 
        }

        local tbl = tbl_run_end_screen 
        tbl.total_seconds = tbl.total_seconds + tbl.time_survived_min * 60 + tbl.time_survived_seconds 
        
        run_end_screen_stop_showing = false

        -- PrintTable(tbl_run_end_screen)
    end)

    net.Receive(gl .. "send_damage_numbers_sv_to_cl", function(len, ply)   
        local pos = net.ReadVector() 
        local dmg = net.ReadInt(32) 
        local ent = net.ReadEntity()  
        local maxdamage = net.ReadInt(32)  
        local customtype = net.ReadInt(32)

        if dmg <= 0 then return end

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
        
        table.insert(tbl_damage_numbers, #tbl_damage_numbers + 1, data)

        timer.Simple(2, function() 
            tbl_damage_numbers[1] = nil 
            tbl_damage_numbers = table.ClearKeys(tbl_damage_numbers)
        end)
    end)

    hook.Add("Initialize", gl .. "initialize", function()
        timer.Simple(0.25, function() 
            garlic_like_init()
        end)
    end)

    hook.Add("Initialize", gl .. "initialize_cooldowns", function()
        --* used for weapon cooldown increase
        timer.Simple(3, function()
            skills = {
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
                if ent:GetClass() == gl .. "crystal_cluster" and tbl_crystal_clusters[ent:GetNWString(gl .. "item_rarity")] then 
                    table.insert(tbl_crystal_clusters[ent:GetNWString(gl .. "item_rarity")], 1, ent)
                    -- PrintTable(tbl_crystal_clusters)
                end
            end)

            if table.HasValue(tbl_gl_entities, ent:GetClass()) or string.find(class, "acwatt") or string.find(class, "item_") then  
                if #garlic_like_item_drops_entities > 0 then
                    garlic_like_item_drops_entities = table.ClearKeys(garlic_like_item_drops_entities)
                end

                table.insert(garlic_like_item_drops_entities, ent)
            end
        end)
    end)

    hook.Add("EntityRemoved", gl .. "item_drop_remove_from_table", function(ent)
        if not GetConVar(gl .. "enable"):GetBool() then return end 

        if ent:GetClass() == gl .. "crystal_cluster" then  
            for k, v in pairs(tbl_crystal_clusters) do 
                for k2, v2 in pairs(v) do 
                    if v2 == ent then 
                        tbl_crystal_clusters[ent:GetNWString(gl .. "item_rarity")][k2] = nil
                        tbl_crystal_clusters[ent:GetNWString(gl .. "item_rarity")] = table.ClearKeys(tbl_crystal_clusters[ent:GetNWString(gl .. "item_rarity")])
                    end
                end
            end
            -- PrintTable(tbl_crystal_clusters)
        end

        for k, ent_entry in pairs(garlic_like_item_drops_entities) do
            if ent_entry == ent then
                garlic_like_item_drops_entities[k] = nil
            end
        end

        if #garlic_like_item_drops_entities > 0 then
            garlic_like_item_drops_entities = table.ClearKeys(garlic_like_item_drops_entities)
        end
    end)

    hook.Add("PostDrawTranslucentRenderables", gl .. "item_floating_labels", function()
        if #garlic_like_item_drops_entities < 1 then return end
        --
        -- PrintTable(garlic_like_item_drops_entities)
        local ply = LocalPlayer()
        --! FIX REROLL CRYSTALS OVERRIDING LEGENDARY CRYSTALS OVER AT SCRIPTED_ENTS LUA

        for k, ent in pairs(garlic_like_item_drops_entities) do
            if not ent:GetNWBool(gl .. "settled_2") then continue end
            --
            local angles = ply:EyeAngles()
            local obbcenter = ent:LocalToWorld(ent:OBBCenter())
            local basepos = ent:GetPos()
            local pos = Vector(basepos.x, basepos.y, basepos.z)
            local rarity = ent:GetNWString(gl .. "item_rarity")
            local rarity_color = tbl_gl_rarity_colors[rarity]
            local beam_start = pos + Vector(0, 0, 10)
            local beam_end = pos + Vector(0, 0, math.Remap(garlic_like_rarity_to_num(rarity), 1, 7, 100, 175))
            --
            render.SetMaterial(mat_beam)

            if ent:GetClass() == "garlic_like_station_weapon_upgrade" or ent:GetClass() == gl .. "station_item_fusing" then 

            else
                render.DrawBeam(beam_start, beam_end, 1, 0, 1, rarity_color)
            end

            if not rarity then 
                rarity = "common"
            end
            
            cam.Start3D2D(Vector(obbcenter.x, obbcenter.y, ent:LocalToWorld(ent:OBBMaxs()).z + 40), Angle(0, angles.y - 90, 90), 0.5)  
            
            if ent:GetClass() == gl .. "wep_crystal" then 
                local amount = " x" .. ent:GetNWInt(gl .. "item_amount", 1)

                if ent:GetNWBool(gl .. "is_food") then 
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
            print("EXECUTING ULT")
            if tbl_ult.ult_cooldown > 0 and (tbl_ult.ult_clicked == nil or not tbl_ult.ult_clicked) then
                tbl_ult.ult_clicked = true
                -- print("ULTIMATE STILL ON COOLDOWN!")
                surface.PlaySound("garlic_like/deny_cooldown.wav")

                timer.Simple(0.75, function()
                    tbl_ult.ult_clicked = false
                end)

                return
            elseif tbl_ult.ult_cooldown <= 0 and not tbl_ult.ult_clicked then
                tbl_ult.ult_clicked = true
                tbl_ult.ult_key_combo_activated = true
                tbl_ult.ult_cooldown = 300
                tbl_ult.ult_starttime = RealTime()
                ply:ConCommand(gl .. "spawn_tf2_ultimate_base_entity")

                timer.Simple(0.75, function()
                    tbl_ult.ult_clicked = false
                end)

                timer.Simple(0.75, function()
                    tbl_ult.ult_key_combo_activated = false
                end)
            end
        end
    end)   

    hook.Add("HUDPaint", gl .. "test", function() 
        if not b then return end 

        -- garlic_like_draw_multi_line(sample_tbl, W * 0.5, H * 0.5, color_black_alpha_200)
    end)

    hook.Add("HUDPaint", gl .. "unlockables_popups", function() 
        if not GetConVar(gl .. "enable"):GetBool() then return end  
        if table.IsEmpty(tbl_unlocks_queue) then return end 
        local ply = LocalPlayer() 
        local RFT = RealFrameTime()  

        tbl_unlocks_hud.text = tbl_unlocks_queue[1]
        -- print(tbl_unlocks_hud.text)

        draw.RoundedBox(4, tbl_unlocks_hud.pos_x_bg, tbl_unlocks_hud.pos_y_bg, tbl_unlocks_hud.w_bg, tbl_unlocks_hud.h_bg, color_black_alpha_200)
        draw.RoundedBoxEx(4, tbl_unlocks_hud.pos_x_bg, tbl_unlocks_hud.pos_y_bg, tbl_unlocks_hud.w_bg, tbl_unlocks_hud.h_bg * 0.3, color_black, true, true, false, false)
        draw.DrawText("UNLOCKED!", gl .. "font_title_3", tbl_unlocks_hud.pos_x_bg + tbl_unlocks_hud.w_bg / 2, tbl_unlocks_hud.pos_y_bg, color_white, TEXT_ALIGN_CENTER)
        draw.DrawText(tbl_unlocks_hud.text, gl .. "font_subtitle_2", tbl_unlocks_hud.pos_x_bg + tbl_unlocks_hud.w_bg / 2, tbl_unlocks_hud.pos_y_bg + H * 0.06, color_white, TEXT_ALIGN_CENTER)

        if tbl_unlocks_hud.lifetime > 3 then 
            tbl_unlocks_hud.pos_y_bg = math.Approach(tbl_unlocks_hud.pos_y_bg, -H * 0.12, RFT * H * 0.3)

            if tbl_unlocks_hud.pos_y_bg <= -H * 0.12 then 
                tbl_unlocks_hud.isrunning = false
                tbl_unlocks_queue[1] = nil 
                tbl_unlocks_queue = table.ClearKeys(tbl_unlocks_queue)
                
                tbl_unlocks_hud = {
                    pos_x_bg = W * 0.77, 
                    pos_y_bg = -H * 0.12, 
                    target_pos_x_bg = W * 0.77, 
                    target_pos_y_bg = H * 0.01, 
                    w_bg = W * 0.22, 
                    h_bg = H * 0.12,
                    lifetime = 0,
                    text = tbl_unlocks_queue[1],
                    show = true,
                    isrunning = true,
                    audioplayed = false,
                } 
                -- print("RETURNED TO ORIGINAL POS!!!")
            end
        else 
            if not tbl_unlocks_hud.audioplayed then 
                tbl_unlocks_hud.audioplayed = true
                surface.PlaySound("garlic_like/achievement_sound.wav")
            end

            tbl_unlocks_hud.isrunning = true
            tbl_unlocks_hud.pos_y_bg = math.Approach(tbl_unlocks_hud.pos_y_bg, tbl_unlocks_hud.target_pos_y_bg, RFT * H * 0.3)
        end

        tbl_unlocks_hud.lifetime = tbl_unlocks_hud.lifetime + RFT  
        -- print(tbl_unlocks_hud.lifetime) 
    end)

    hook.Add("HUDPaint", gl .. "gold_popups", function() 
        if not GetConVar(gl .. "enable"):GetBool() then return end 
        if #tbl_gold_popups < 1 then return end 
        --
        local RFT = RealFrameTime()

        -- PrintTable(tbl_gold_popups)
        
        for k, data in pairs(tbl_gold_popups) do  
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
            surface.SetMaterial(mat_hl)
            surface.DrawTexturedRect(data.pos_2d.x - ScreenScale(12), data.pos_2d.y - data.pos_y_mod + ScreenScale(1), ScreenScale(12), ScreenScale(12))
            draw.DrawText(data.gold_shown, gl .. "gold_popup", data.pos_2d.x, data.pos_2d.y - data.pos_y_mod, data.color, TEXT_ALIGN_LEFT)
            
            if tbl_gold_popups[1] and tbl_gold_popups[1].lifetime >= 2.5 and tbl_gold_popups[1].combined_distance <= 8 then
                net.Start(gl .. "update_gold_from_anim_cl_to_sv")
                net.WriteInt(data.gold_amount, 32)
                net.SendToServer()

                surface.PlaySound("dota2/coins.wav")

                tbl_gold_popups[1] = nil 
                tbl_gold_popups = table.ClearKeys(tbl_gold_popups) 
                tbl_gold_hud.scale_mod = 0

                timer.Create(gl .. "gold_bounce", 0.02, 10, function() 
                    local repsleft = timer.RepsLeft(gl .. "gold_bounce") 

                    if repsleft > 5 then 
                        tbl_gold_hud.scale_mod = tbl_gold_hud.scale_mod + 0.08
                    else 
                        tbl_gold_hud.scale_mod = math.max(0, tbl_gold_hud.scale_mod - 0.08)
                    end
                end)
            end

            -- if data.lifetime >= 3 and data.pos_2d.x + W * 0.001 >= W * 0.735 then 
                -- print("DESTROY")
                -- table.remove(tbl_gold_popups, k)
                -- table.ClearKeys(tbl_gold_popups)
            -- end

            surface.SetDrawColor(255, 255, 255, 255)
        end  
    end)

    hook.Add("HUDPaint", gl .. "xp_number_notifications", function()
        if GetConVar(gl .. "enable"):GetInt() == 0 then return end
        if #xp_numbers < 1 then return end

        for i = 2, #xp_numbers do
            draw.SimpleText("+" .. xp_numbers[i] .. " XP", gl .. "xp_notification_settled", xp_text_W, H * 0.43 + i * H * 0.022, color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        for i = 2, #xp_texts do
            draw.SimpleText(xp_texts[i], gl .. "xp_notification_extra_settled", xp_text_W * 1.15, H * 0.43 + i * H * 0.022, color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        draw.SimpleText("+" .. xp_numbers[1] .. " XP", xp_notification_font, xp_text_W, H * 0.45, color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        if #xp_texts > 0 then
            draw.SimpleText(xp_texts[1], xp_notification_font_extra, xp_text_W * 1.15, H * 0.45, color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end)

    hook.Add("HUDPaint", gl .. "xp_bar", function() 
        if GetConVar(gl .. "hud_enable"):GetInt() == 0 then return end
        if GetConVar(gl .. "enable"):GetInt() == 0 then return end
        if ply.gl_has_menu_open then return end 
        if not run_end_screen_stop_showing then return end
        
        if gl_weapon_selector_showing then 
            surface.SetAlphaMultiplier(0.3)
        end
        -- if GetGlobalBool(gl .. "show_end_screen") then return end

        level = ply:GetNWInt(gl .. "level", 1)
        local xp = xp_total
        local maxxp = ply:GetNWInt(gl .. "xp_to_next_level", 500)
        local RFT = RealFrameTime()

        if oldxp == -1 and newxp == -1 then
            oldxp = xp
            newxp = xp
        end

        local smoothXP = Lerp((SysTime() - start) / animationTime, oldxp, newxp)

        if newxp ~= xp then
            if smoothXP ~= xp then
                newxp = smoothXP
            end

            oldxp = newxp
            start = SysTime()
            newxp = xp
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
        draw.SimpleText("LV " .. level, gl .. "xp_level", W * 0.5, H * 0.08, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(xp_total .. "/" .. maxxp, gl .. "xp_numbers", W * 0.5, H * 0.11, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

        tbl_gold_hud.scale_num = 1 + tbl_gold_hud.scale_mod

        tbl_gold_hud.scale_vector.x = tbl_gold_hud.scale_num
        tbl_gold_hud.scale_vector.y = tbl_gold_hud.scale_num
        tbl_gold_hud.scale_vector.z = tbl_gold_hud.scale_num

        m:Translate( center )
        -- m:Rotate( Angle( 0, t, 0 ) )
        m:Scale( tbl_gold_hud.scale_vector )
        m:Translate( -center )
        --
        cam.PushModelMatrix( m )
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(mat_hl)
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
        draw.SimpleText("x" .. 1 + math.Truncate(GetGlobalFloat(gl .. "enemy_modifier_hp", 0), 1), gl .. "font_empowered_numbers", W * 0.318, H * 0.085, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        -- 
        surface.SetMaterial(Material("garlic_like/icon_empowered_damage.png"))
        surface.DrawTexturedRect(W * 0.36, H * 0.074, W * 0.016, W * 0.016)
        draw.SimpleText("x" .. 1 + math.Truncate(GetGlobalFloat(gl .. "enemy_modifier_damage", 0), 1), gl .. "font_empowered_numbers", W * 0.378, H * 0.085, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        --
        surface.SetMaterial(Material("garlic_like/icon_empowered_resistance.png"))
        surface.DrawTexturedRect(W * 0.42, H * 0.074, W * 0.016, W * 0.016)
        draw.SimpleText("x" .. 1 - math.Truncate(GetGlobalFloat(gl .. "enemy_modifier_resistance", 0), 2), gl .. "font_empowered_numbers", W * 0.438, H * 0.085, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        --
        local pending_text = "PENDING LEVEL UPS"

        if not GetConVar(gl .. "enable_timer"):GetBool() then 
            pending_text = "PRESS " .. "L" .. " TO OPEN GAME MENU"
        end

        if pending_level_ups > 0 or (not GetConVar(gl .. "enable_timer"):GetBool() and not ply.gl_has_menu_open) then
            
            surface.SetAlphaMultiplier(1)
            -- draw.RoundedBox(4, W * 0.5 - W * 0.08, H * 0.125, W * 0.16, H * 0.085, color_black_alpha_150)
            if pending_level_ups > 0 then 
                gl_cse(ply, W * 0.5, H * 0.125, pending_level_ups, "", "", false, false, "", true, gl .. "font_title")
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
        if not show_empowered_text then return end
        draw.SimpleText("ENEMIES EMPOWERED!", gl .. "empowered_text", W * 0.5, H * 0.2, color_empowered_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("HP x" .. string.format("%.2f", 1 + GetGlobalFloat(gl .. "enemy_modifier_hp", 0)) .. " DMG x" .. string.format("%.2f", 1 + GetGlobalFloat(gl .. "enemy_modifier_damage", 0)) .. " RES x" .. string.format("%.2f", 1 - GetGlobalFloat(gl .. "enemy_modifier_resistance", 0)), gl .. "empowered_text_sub", W * 0.5, H * 0.25, color_empowered_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)

    hook.Add("HUDPaint", gl .. "item_pickup", function() 
        if not GetConVar(gl .. "enable"):GetBool() then return end 
        local RFT = RealFrameTime() 
        -- PrintTable(glips.entries)
        for k, data in pairs (glips.entries) do  
            data.lifetime = data.lifetime + RFT * 1000 

            if data.pos_y == 0 then 
                data.pos_y = H * 0.82 - k * glips.bg_height * 1.05 
            end 

            data.pos_y = math.Approach(data.pos_y, H * 0.82 - k * glips.bg_height * 1.05, RFT * H * 0.8)

            if data.lifetime >= 2500 or k > 6 then 
                data.color_text.a = data.color_text.a - RFT * 900
                data.color_text_held.a = data.color_text_held.a - RFT * 900
                data.color_bg.a = data.color_bg.a - RFT * 900
                data.pos_x = data.pos_x - W * 0.001 * RFT * 550

                if data.color_bg.a < 0 then 
                    glips.entries[k] = nil
                    glips.entries = table.ClearKeys(glips.entries)
                end
            else 
                data.pos_x = math.min(W * 0.02, data.pos_x + W * 0.001 * RFT * 350)
                data.color_highlight.a = data.color_highlight.a - RFT * 850 
            end 
            
            draw.RoundedBox(8, data.pos_x, data.pos_y, glips.bg_width, glips.bg_height, data.color_bg)
            draw.DrawText(data.text .. " x" .. data.amount, gl .. "item_pickup_name", data.pos_x + W * 0.035, data.pos_y + H * 0.01, data.color_text, TEXT_ALIGN_LEFT)

            if data.item_type == "ore" then 
                draw.DrawText("Held: " .. WepCrystalsInventory[tbl_gl_rarity_to_number[data.rarity]].held_num, gl .. "item_pickup_held_num", (data.pos_x - W * 0.005) + glips.bg_width, data.pos_y + H * 0.03, data.color_text_held, TEXT_ALIGN_RIGHT)            
            elseif data.item_type == "material" then 
                draw.DrawText("Held: " .. MaterialsInventory[data.text].held_num, gl .. "item_pickup_held_num", (data.pos_x - W * 0.005) + glips.bg_width, data.pos_y + H * 0.03, data.color_text_held, TEXT_ALIGN_RIGHT)            
            end

            draw.RoundedBox(8, data.pos_x, data.pos_y, glips.bg_width, glips.bg_height, data.color_highlight)
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

    hook.Add("HUDPaint", gl .. "run_end_screen", function() 
        if not GetConVar(gl .. "enable"):GetBool() then return end 
        local RFT = RealFrameTime()  

        if run_end_screen_stop_showing then return end

        local tbl = tbl_run_end_screen
        
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
    
                    tbl.shown_time_survived_seconds = math.min(tbl.total_seconds, tbl.shown_time_survived_seconds + math.Round(RFT * math.max(1, tbl.total_seconds)))
                    tbl.shown_gold_gained = math.Approach(tbl.shown_gold_gained, tbl.gold_gained, math.Round(RFT * math.max(1, tbl.gold_gained)))
                    tbl.shown_level_reached = math.Approach(tbl.shown_level_reached, tbl.level_reached, math.Round(RFT * 5 * math.max(1, tbl.level_reached)))
                    tbl.shown_enemy_hp_mult = math.Truncate(math.Approach(tbl.shown_enemy_hp_mult, tbl.enemy_hp_mult, RFT * math.max(0.1, tbl.enemy_hp_mult)), 2)
                    tbl.shown_enemy_dmg_mult = math.Truncate(math.Approach(tbl.shown_enemy_dmg_mult, tbl.enemy_dmg_mult, RFT * math.max(0.1, tbl.enemy_dmg_mult)), 2)
                    tbl.shown_enemy_dr_mult = math.Truncate(math.Approach(tbl.shown_enemy_dr_mult, tbl.enemy_dr_mult, RFT * math.max(0.1, tbl.enemy_dr_mult)), 2)
                    tbl.shown_total_dmg_dealt = math.Approach(tbl.shown_total_dmg_dealt, tbl.total_dmg_dealt, math.Round(RFT * math.max(1, tbl.total_dmg_dealt)))
                    tbl.shown_total_dmg_taken = math.Approach(tbl.shown_total_dmg_taken, tbl.total_dmg_taken, math.Round(RFT * math.max(1, tbl.total_dmg_taken)))
                    tbl.shown_highest_dmg = math.Approach(tbl.highest_dmg, tbl.highest_dmg, math.Round(RFT * math.max(1, tbl.highest_dmg)))

                    draw.SimpleText(": " .. string.FormattedTime( tbl.shown_time_survived_seconds, "%02i:%02i" ), gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 1, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(": " .. tbl.shown_gold_gained, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 2, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(": " .. tbl.shown_level_reached, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 3, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(": " .. tbl.shown_enemy_hp_mult, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 4, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(": " .. tbl.shown_enemy_dmg_mult, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 5, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(": " .. tbl.shown_enemy_dr_mult, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 6, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(": " .. tbl.shown_total_dmg_dealt, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 7, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(": " .. tbl.shown_total_dmg_taken, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 8, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(": " .. tbl.shown_highest_dmg, gl .. "font_subtitle_3", W * 0.28, stat_y + stat_y_diff * 9, tbl.color_yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                    draw.SimpleText("HOLD RIGHT MOUSE BUTTON TO EXIT!", gl .. "font_subtitle_2", W * 0.5, H * 0.85, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    if input.IsMouseDown(MOUSE_RIGHT) then 
                        run_end_screen_progress_num = run_end_screen_progress_num + RFT * 100
                        draw.SimpleText(math.min(100, math.Round(run_end_screen_progress_num)) .. "%", gl .. "font_subtitle_2", W * 0.5, H * 0.9, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    else 
                        run_end_screen_progress_num = 0
                        run_end_screen_stop_showing = false
                    end

                    if math.Round(run_end_screen_progress_num) >= 100 then 
                        run_end_screen_stop_showing = true

                        tbl_run_end_screen = { 
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
                            sound_played = false,
                        }
                    end
                end

                draw.SimpleText("RESULTS!", gl .. "font_title_result_screen_" .. math.Round(tbl.res_size_num), W * 0.5, H * 0.1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                surface.SetDrawColor(255, 255, 255, 255) 
            end
        end
    end)

    hook.Add("PostDrawHUD", "damage_numbers", function() 
        if not GetConVar(gl .. "enable"):GetBool() then return end 
        local tbl = tbl_damage_numbers
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
        -- 
        draw.DrawText(tbl_break_hud.text_break, gl .. "font_title", tbl_break_hud.tb_pos_x, tbl_break_hud.tb_pos_y, color_white, TEXT_ALIGN_CENTER)
        draw.DrawText(GetGlobalInt(gl .. "breaktime_seconds"), gl .. "font_title", tbl_break_hud.tb_pos_x, tbl_break_hud.tb_pos_y + H * 0.05, color_white, TEXT_ALIGN_CENTER)
    end)

    hook.Add("PostDrawHUD", gl .. "hud_elements", function()
        if GetConVar(gl .. "hud_enable"):GetInt() == 0 then return end
        if GetConVar(gl .. "enable"):GetInt() == 0 or (ply.garlic_like_is_opening_stats_screen ~= nil and ply.garlic_like_is_opening_stats_screen) then return end        
        -- if not GetConVar(gl .. "enable_timer"):GetBool() then return end  
        if ply.gl_has_menu_open then return end
        if not IsValid(ply) or not ply:Alive() then return end
        if not run_end_screen_stop_showing then return end
        -- if GetGlobalBool(gl .. "show_end_screen") then return end
        --
        local ply = LocalPlayer()
        local ply_wep = ply:GetActiveWeapon() 
        --
        if not IsValid(ply_wep) then return end
        --
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
        surface.SetMaterial(mat_heart) 

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
        
        garlic_like_create_point_bar("AP", tbl_hud_elements.apbar_x, tbl_hud_elements.apbar_y - 1, tbl_hud_elements.apbar_w, tbl_hud_elements.apbar_h, tbl_hud_elements.apbar_t_x, tbl_hud_elements.apbar_t_y - 1, tbl_hud_elements.apbar_color, tbl_hud_elements.apbar_color_gradient) 
        garlic_like_create_point_bar("HP", tbl_hud_elements.hpbar_x, tbl_hud_elements.hpbar_y - 1, tbl_hud_elements.hpbar_w, tbl_hud_elements.hpbar_h, tbl_hud_elements.hpbar_t_x, tbl_hud_elements.hpbar_t_y - 1, tbl_hud_elements.hpbar_color, tbl_hud_elements.hpbar_color_gradient) 
        garlic_like_create_point_bar("MP", tbl_hud_elements.mpbar_x, tbl_hud_elements.mpbar_y, tbl_hud_elements.mpbar_w, tbl_hud_elements.mpbar_h, tbl_hud_elements.mpbar_t_x, tbl_hud_elements.mpbar_t_y, tbl_hud_elements.mpbar_color, tbl_hud_elements.mpbar_color_gradient)      
    
        if GetConVar(gl .. "hud_show_abilities"):GetInt() > 0 then
            draw.RoundedBox(4, W * 0.375, H * 0.86, W * 0.25, H * 0.125, color_black_alpha_150)

            for i = 1, 4 do
                draw.RoundedBox(0, (i * W * 0.06) - W * 0.06 + W * 0.385, H * 0.88, W * 0.05, W * 0.05, Color(0, 0, 0, 200))
            end

            for k, upgrade in SortedPairs(table.ClearKeys(garlic_like_skills_held)) do
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(Material(upgrade.icon))
                surface.DrawTexturedRect((k * W * 0.06) - W * 0.06 + W * 0.385, H * 0.88, W * 0.05, W * 0.05)

                if type(skill_cooldown_numbers[k]) ~= "string" and skill_cooldown_numbers[k] > 0 then
                    surface.SetDrawColor(skill_cooldown_dark[k])
                    surface.DrawRect((k * W * 0.06) - W * 0.06 + W * 0.385, H * 0.88, W * 0.05, W * 0.05)
                    draw.SimpleText(string.format("%.1f", skill_cooldown_numbers[k]), gl .. "font_title_2", (k * W * 0.06) + W * 0.35, H * 0.925, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end

            for i = 1, 4 do
                surface.SetDrawColor(skill_circle_colors[i])
                surface.DrawOutlinedRect((i * W * 0.06) - W * 0.06 + W * 0.385, H * 0.88, W * 0.05, W * 0.05, 1)
            end

            draw.RoundedBox(4, W * 0.3, H * 0.88, W * 0.05, W * 0.05, color_black_alpha_150)
            --
            draw.RoundedBox(4, W * 0.65, H * 0.88, W * 0.05, W * 0.05, color_black_alpha_150) -- TF2 ULTIMATE SKILL ICON

            if tbl_ult.ult_cooldown > 0 then
                -- tbl_ult.ult_cooldown = math.max(0, math.Approach(tbl_ult.ult_cooldown, 0, 0.03)) 
                if GetGlobalBool(gl .. "match_running", false) then 
                    tbl_ult.ult_cooldown = math.Clamp(tbl_ult.ult_num_cooldown * (1 - (RealTime() - tbl_ult.ult_starttime) / tbl_ult.ult_num_cooldown), 0, tbl_ult.ult_num_cooldown)
                end
            
                surface.SetDrawColor(125, 125, 125)
                surface.SetMaterial(Material("garlic_like/icon_tf2_ult.png"))
                surface.DrawTexturedRect(W * 0.655, H * 0.89, W * 0.04, W * 0.04)
                draw.SimpleText(math.Truncate(tbl_ult.ult_cooldown, 1), gl .. "font_title_2", W * 0.675, H * 0.92, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

        if tbl_ult.ult_clicked and tbl_ult.ult_cooldown > 0 and not tbl_ult.ult_key_combo_activated then
            draw.SimpleText("ULTIMATE STILL ON COOLDOWN!", gl .. "font_title_2", W * 0.5, H_half_screen, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if show_weapon_stats then
            line_length = W * 0.8
            line_alpha_mul = 1
        else
            line_length = math.Approach(line_length, W, W * 0.015)
            line_alpha_mul = math.Approach(line_alpha_mul, 0, 0.15)
        end

        if line_alpha_mul > 0 and IsValid(ply_wep) and  tbl_gl_stored_bonused_weapons[ply_wep_class] ~= nil then
            if ply:Alive() then
                weapon_name = ply_wep:GetPrintName()
            else
                weapon_name = ""
            end

            -- PrintTable( tbl_gl_stored_bonused_weapons[ply_wep_class])

            local rarity =  tbl_gl_stored_bonused_weapons[ply_wep_class].rarity
            local element =  tbl_gl_stored_bonused_weapons[ply_wep_class].element
            surface.SetAlphaMultiplier(line_alpha_mul)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetDrawColor(tbl_gl_rarity_colors[rarity].r, tbl_gl_rarity_colors[rarity].g, tbl_gl_rarity_colors[rarity].b)
            surface.DrawLine(line_length, H_half_screen, W, H_half_screen)
            surface.DrawLine(line_length, H_half_screen + 1, W, H_half_screen + 1)
            surface.DrawLine(line_length, H_half_screen + 2, W, H_half_screen + 2)
            surface.DrawLine(line_length, H_half_screen + 3, W, H_half_screen + 3)
            surface.DrawLine(line_length, H_half_screen + 4, W, H_half_screen + 4)            

            for k, v in pairs(tbl_gl_elements) do 
                if v.name == element then 
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(v.mat_1)
                    surface.DrawTexturedRect(line_length, H * 0.48 - W * 0.015 / 2, W * 0.015, W * 0.015)
                end
            end

            -- surface.SetMaterial()
            gl_cse(ply, line_length, H * 0.45, string.upper(rarity), "", "", true, false, "", false, gl .. "font_title_3", tbl_gl_rarity_colors[rarity], false)
            gl_cse(ply, line_length + W * 0.017, H * 0.48, "", "", weapon_name, true, false, "", false, gl .. "font_title_2", tbl_gl_rarity_colors[rarity], false)

            if  tbl_gl_stored_bonused_weapons[ply_wep_class].bonus_amount > 0 then
                for k, bonus in pairs( tbl_gl_stored_bonused_weapons[ply_wep_class].bonuses) do
                    gl_cse(ply, line_length, (H * 0.53) + ((k - 1) * H * 0.035), "", 100 * bonus.modifier .. "%", " " .. bonus.desc, true, false, "", false, gl .. "font_subtitle_2", nil, false)
                end
            end
        end

        surface.SetAlphaMultiplier(1)
        cam.End2D()

        -- weapon_image = "vgui/entities/" .. weapons_table_filtered[math.random(#weapons_table_filtered)].ClassName
        -- surface.SetDrawColor(255, 255, 255)
        -- surface.SetMaterial(Material(weapon_image))
        -- surface.DrawTexturedRect(up_text_width, H * 0.5 - W * 0.05, W * 0.1, W * 0.1)
        -- -- function gl_cse(ply, pos_x, pos_y, front_operator, numbers, short_desc, align_center_y, additional_front_text, front_text, rainbow, font, color, align_center_x)
        -- gl_cse(ply, W * 0.5, H * 0.62, weapon_rarity_random, "", weapon_name_random, true, false, "", false, gl .. "font_title_3", nil, true)
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
            show_weapon_stats = true

            timer.Create("show_stats_" .. ply:Nick(), 2, 1, function()
                show_weapon_stats = false
            end)
        end

        ply_wep_2 = ply_wep

        cam.Start2D()
        if ply:KeyDown(IN_WALK) then
            ply.garlic_like_is_opening_stats_screen = true
            show_weapon_stats = true

            if stats_menu == "STATS" then
                if ply:KeyPressed(IN_USE) then
                    stats_menu = "SKILLS"
                end

                draw.RoundedBox(0, 0, 0, W, H, color_black_alpha_150)
                draw.RoundedBox(8, W * 0.15, H * 0.1, W * 0.7, H * 0.4, Color(0, 0, 0, 200))
                draw.SimpleText("STATS", gl .. "font_title", tbl_glss.glss_mid_pos_base, H * 0.1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.RoundedBox(4, tbl_glss.glss_left_pos, tbl_glss.glss_height_1, W * 0.05, H * 0.1, color_black_alpha_150)
                draw.RoundedBox(4, tbl_glss.glss_mid_pos, tbl_glss.glss_height_1, W * 0.05, H * 0.1, color_black_alpha_150)
                draw.RoundedBox(4, tbl_glss.glss_right_pos, tbl_glss.glss_height_1, W * 0.05, H * 0.1, color_black_alpha_150)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(mat_icon_str)
                surface.DrawTexturedRect(tbl_glss.glss_left_pos, tbl_glss.glss_height_1, W * 0.05, H * 0.1)
                surface.SetMaterial(mat_icon_agi)
                surface.DrawTexturedRect(tbl_glss.glss_mid_pos, tbl_glss.glss_height_1, W * 0.05, H * 0.1)
                surface.SetMaterial(mat_icon_int)
                surface.DrawTexturedRect(tbl_glss.glss_right_pos, tbl_glss.glss_height_1, W * 0.05, H * 0.1)
                -- 
                draw.SimpleText("STR", gl .. "font_subtitle", tbl_glss.glss_left_pos_base, tbl_glss.glss_height_1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("AGI", gl .. "font_subtitle", tbl_glss.glss_mid_pos_base, tbl_glss.glss_height_1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("INT", gl .. "font_subtitle", tbl_glss.glss_right_pos_base, tbl_glss.glss_height_1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(math.Truncate(ply:GetNWInt(gl .. "STR", 0), 1), gl .. "font_title", tbl_glss.glss_left_pos_base, H * 0.29, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(math.Truncate(ply:GetNWInt(gl .. "AGI", 0), 1), gl .. "font_title", tbl_glss.glss_mid_pos_base, H * 0.29, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(math.Truncate(ply:GetNWInt(gl .. "INT", 0), 1), gl .. "font_title", tbl_glss.glss_right_pos_base, H * 0.29, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                for k, entry in ipairs(tbl_gl_character_stats) do  
                    if entry.stat_type == "EXTRA" then continue end 
                    --
                    local prefix_symbol 
                    local value
                    local index_for_pos
                    local x_pos
                    local added_value = 0 --* added value depends on if the upgrade is reductive or multiplicative.
                    
                    if entry.stat_type == "STR" then 
                        index_for_pos = k
                        x_pos = tbl_glss.glss_left_pos_base
                    elseif entry.stat_type == "AGI" then 
                        index_for_pos = k - 6
                        x_pos = tbl_glss.glss_mid_pos_base
                    elseif entry.stat_type == "INT" then 
                        index_for_pos = k - 12
                        x_pos = tbl_glss.glss_right_pos_base
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

                        --! FINISH BY CHECKING MAG AMOUNT
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
                     
                    gl_cse(ply, x_pos, heights_stat_menu_desc[index_for_pos], prefix_symbol, value, " " .. (entry.name), false, false, "", false, gl .. "font_stat_entry")     
                end    
                
                -- ITEMS BOX
                draw.RoundedBox(8, W * 0.15, H * 0.595, W * 0.7, H * 0.235, Color(0, 0, 0, 200))
                draw.SimpleText("ITEMS", gl .. "font_title", W * 0.5, H * 0.595, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                -- draw.RoundedBox(4, W * 0.15, H * 0.8, W * 0.7, H * 0.15, color_black_alpha_150)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawCircle(W * 0.25, H * 0.7, W * 0.035, item_circle_colors[1])
                surface.DrawCircle(W * 0.417, H * 0.7, W * 0.035, item_circle_colors[2])
                surface.DrawCircle(W * 0.584, H * 0.7, W * 0.035, item_circle_colors[3])
                surface.DrawCircle(W * 0.75, H * 0.7, W * 0.035, item_circle_colors[4])
                -- DRAW ITEMS
                surface.SetDrawColor(255, 255, 255, 255)

                -- for i = 1, 4 do
                for i, upgrade in SortedPairs(table.ClearKeys(garlic_like_items_held)) do
                    -- surface.SetMaterial(Material("garlic_like/icon_orb_xp.png"))
                    surface.SetMaterial(Material(upgrade.icon))
                    surface.DrawTexturedRect(W * (0.084 + i * 0.167) - W * 0.03, H * 0.65, W * 0.06, H * 0.1)
                    --
                    -- draw.SimpleText("SAMPLE ITEM", gl .. "font_subtitle", W * (0.112 + i * 0.167) - W * 0.03, H * 0.6, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(string.upper(upgrade.name), gl .. "font_subtitle", W * (0.112 + i * 0.167) - W * 0.03, H * 0.62, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    -- draw.SimpleText("SAMPLE DESC", gl .. "font_subtitle", W * (0.112 + i * 0.167) - W * 0.03, H * 0.77, Color(0, 219, 37), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(string.upper(upgrade.rarity), gl .. "font_subtitle", W * (0.112 + i * 0.167) - W * 0.03, H * 0.78, item_circle_colors[i], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    gl_cse(ply, W * (0.112 + i * 0.167) - W * 0.03, H * 0.81, "x", math.abs(upgrade.number_addition + upgrade.statboost), " " .. upgrade.desc_short, true)
                    -- draw.SimpleText("x" .. math.abs(upgrade.number_addition + upgrade.statboost) .. " " .. upgrade.desc_short, gl .. "font_subtitle", W * (0.112 + i * 0.167) - W * 0.03, H * 0.81, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            elseif stats_menu == "SKILLS" then
                if ply:KeyPressed(IN_USE) then
                    stats_menu = "RELICS"
                end

                draw.RoundedBox(0, 0, 0, W, H, color_black_alpha_150)
                -- draw.RoundedBox(8, W * 0.05, H * 0.1, W * 0.9, H * 0.85, Color(0, 0, 0, 200))
                draw.SimpleText("SKILLS", gl .. "font_title", tbl_glss.glss_mid_pos_base, H * 0.06, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                for i = 1, 4 do
                    draw.RoundedBox(8, (i * W * 0.2) - W * 0.092, H * 0.095, W * 0.19, H * 0.4, Color(0, 0, 0, 200))
                    draw.RoundedBox(0, (i * W * 0.2) - W * 0.032, H * 0.15, W * 0.07, W * 0.07, Color(0, 0, 0, 200))
                end

                for i, skill in SortedPairs(table.ClearKeys(garlic_like_skills_held)) do
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
                    draw.DrawText(string.upper(skill.rarity), gl .. "font_subtitle", (i * W * 0.2) + W * 0.0025, H * 0.295, skill_circle_colors[i], TEXT_ALIGN_CENTER)
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
                    surface.SetDrawColor(skill_circle_colors[i])
                    surface.DrawOutlinedRect((i * W * 0.2) - W * 0.032, H * 0.15, W * 0.07, W * 0.07, 1)
                end

                -- RELICS HUD
                draw.SimpleText("RELICS", gl .. "font_title", tbl_glss.glss_mid_pos_base, H * 0.53, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                for i = 1, 4 do
                    draw.RoundedBox(8, (i * W * 0.2) - W * 0.092, H * 0.565, W * 0.19, H * 0.4, Color(0, 0, 0, 200))
                    draw.RoundedBox(0, (i * W * 0.2) - W * 0.032, H * 0.62, W * 0.07, W * 0.07, Color(0, 0, 0, 200))
                end

                for i, relic in SortedPairs(table.ClearKeys(garlic_like_relics_held)) do
                    if i > 4 then continue end
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(Material(relic.icon))
                    surface.DrawTexturedRect((i * W * 0.2) - W * 0.032, H * 0.62, W * 0.07, W * 0.07) 
                    draw.DrawText(string.upper(relic.name), gl .. "font_title_2", (i * W * 0.2) + W * 0.0025, H * 0.5725, color_white, TEXT_ALIGN_CENTER)
                    draw.DrawText(string.upper(relic.rarity), gl .. "font_subtitle", (i * W * 0.2) + W * 0.0025, H * 0.765, skill_circle_colors[i], TEXT_ALIGN_CENTER)
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
                    surface.SetDrawColor(relic_circle_colors[i])
                    surface.DrawOutlinedRect((i * W * 0.2) - W * 0.032, H * 0.62, W * 0.07, W * 0.07, 1)
                end
            elseif stats_menu == "RELICS" then 
                if ply:KeyPressed(IN_USE) then
                    stats_menu = "STATS"
                end
 
                local mod_y_1 = H * 0.47
                local i_x = 0
                
                draw.RoundedBox(0, 0, 0, W, H, color_black_alpha_150) 
                draw.SimpleText("RELICS", gl .. "font_title", tbl_glss.glss_mid_pos_base, H * 0.53 - mod_y_1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

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

                -- PrintTable(garlic_like_relics_held)  
                local mod_y_1 = H * 0.47
                local i_x = 0

                for i, relic in SortedPairs(table.ClearKeys(garlic_like_relics_held)) do
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
                        draw.DrawText(string.upper(relic.rarity), gl .. "font_subtitle", ((i - 4) * W * 0.2) + W * 0.0025, H * 0.765 - mod_y_1, skill_circle_colors[(i - 4)], TEXT_ALIGN_CENTER)
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

                    surface.SetDrawColor(relic_circle_colors[i + 4])
                    surface.DrawOutlinedRect((i_x * W * 0.2) - W * 0.032, H * 0.62 - mod_y_1, W * 0.07, W * 0.07, 1)

                    if i > ply:GetNWInt(gl .. "relic_slots_unlocked", 0) then 
                        draw.RoundedBox(8, (i_x * W * 0.2) - W * 0.092, H * 0.565 - mod_y_1, W * 0.19, H * 0.4, Color(111, 111, 111, 55))
                        draw.RoundedBox(0, (i_x * W * 0.2) - W * 0.032, H * 0.62 - mod_y_1, W * 0.07, W * 0.07, Color(111, 111, 111, 55))
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(mat_padlock)
                        surface.DrawTexturedRect((i_x * W * 0.2) - W * 0.032, H * 0.62 - mod_y_1, W * 0.07, W * 0.07) 
                    end
                end 
            end
        end

        if ply:KeyReleased(IN_WALK) then
            ply.garlic_like_is_opening_stats_screen = false

            timer.Create("show_stats_" .. ply:Nick(), 2, 1, function()
                show_weapon_stats = false
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
        
        for rarity, color in SortedPairs(tbl_gl_rarity_colors) do  
            if #tbl_crystal_clusters[rarity] > 0 then 
                outline.Add(tbl_crystal_clusters[rarity], color, 0)
            end
        end      
    end)

    hook.Add( "HUDShouldDraw", gl .. "HideHUD", function( name )
        if ( hide[ name ] ) then
            return false
        end

        -- if name == "CHudHealth" then 
        --     return false
        -- end

        -- Don't return anything here, it may break other addons that rely on this hook.
    end )

    concommand.Add(gl .. "debug_show_achievement_unlock", function(ply, cmd, args, argStr)
        table.insert(tbl_unlocks_queue, #tbl_unlocks_queue + 1, args[1])

        -- if not tbl_unlocks_hud.isrunning then  
        --     tbl_unlocks_hud = {
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
        -- glips.entries[#glips.entries + 1] = "entry" .. math.random() * 10000
        -- PrintTable(args)
        --! POLISH THE CODE!!!

        local rarity_color = tbl_gl_rarity_colors[string.lower(args[3])]
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
                icon = WepCrystalsInventory[tbl_gl_rarity_to_number[string.lower(args[3])]].material,
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
                icon = MaterialsInventory[args[1]].material,
                color_bg = Color(29, 27, 27, 200),
                color_text = Color(rarity_color.r, rarity_color.g, rarity_color.b, 255),
                color_text_held = Color(255, 255, 255, 255),
                color_highlight = Color(rarity_color.r, rarity_color.g, rarity_color.b, 255),
            }
            --! CREATE TBL FOR MATERIALS
        end

        if glips.entries then 
            for k, v in pairs(glips.entries) do 
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
            table.insert(glips.entries, 1, entry_data)
        end
    end)

    concommand.Add(gl .. "debug_open_weapon_upgrade_menu", function(ply, cmd, args, argStr)
        local menu_type = argStr

        if argStr == nil then 
            menu_type = "BLACKSMITH"
        end

        local mat_dice = Material("garlic_like/icon_ui/reset3.png")
        local mat_padlock = Material("garlic_like/icon_ui/padlock.png")
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
            --! NEW FINISH STAT REROLL CURSOR TOOLTIP TO SHOW HELD NUM OF REROLL CRYSTALS
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
                reroll_button:SetTooltip(required_reroll_crystals .. " Reroll Crystals required." .. " Owned: " .. MaterialsInventory["Reroll Crystal"].held_num)
                reroll_button.mat_dice = Material("garlic_like/icon_ui/dice2.png")
                reroll_button.potency_potential = 0
                -- reroll_button:SetImage("garlic_like/icon_ui/dice2.png")            

                -- local bonus_reroll_button = vgui.Create("DImageButton", bf)
                -- brb = bonus_reroll_button
                -- brb:SetSize(bf_w * 0.055, bf_h * 0.045)
                -- brb:SetX(bf_w * 0.025)
                -- brb:SetY(bf_h * 0.3 + i * bf_h * 0.05)
                --* 
                --* functions 
                -- brb.Paint = function(self, w, h)
                --     draw.RoundedBoxEx(6, 0, 0, w, h, color_button_orange, true, false, true, false)
                --     surface.SetDrawColor(255, 255, 255)
                --     surface.SetMaterial(mat_dice)
                --     surface.DrawTexturedRect(w * 0.125, h * 0.125, w * 0.8, h * 0.8)
                -- end
                reroll_button.DoClick = function(self) 
                    -- PrintTable( tbl_gl_stored_bonused_weapons)
                    if MaterialsInventory["Reroll Crystal"].held_num < required_reroll_crystals then 
                        return
                    end

                    if  tbl_gl_stored_bonused_weapons[button_weapon_slot.gl_chosen_weapon] then 
                        --*
                        self:SetTooltip(false)
                        MaterialsInventory["Reroll Crystal"].held_num = MaterialsInventory["Reroll Crystal"].held_num - required_reroll_crystals
                        local weapon_tbl =  tbl_gl_stored_bonused_weapons[button_weapon_slot.gl_chosen_weapon]  
                        local get_tbl_bonus = tbl_gl_bonuses_weapons[math.random(1, #tbl_gl_bonuses_weapons)]
                        local rarity_rand_modifier = math.Remap(garlic_like_rarity_to_num(weapon_tbl.rarity), 1, 7, 1, 2)  
                        local potency_rand_min = 0.25 * rarity_rand_modifier
                        local potency_rand_max = 0.5 * rarity_rand_modifier
                        local potency = math.Rand(potency_rand_min, potency_rand_max)
                        reroll_button.potency_potential = math.Truncate(math.Remap(potency, potency_rand_min, potency_rand_max, 0, 1), 3)
                        bonus_label.color_potency.a = 50 * reroll_button.potency_potential

                        -- print("potency: " .. potency .. " min pot: " .. potency_rand_min .. " max pot: " .. potency_rand_max .. " pot range in: %" .. reroll_button.potency_potential)

                        weapon_tbl.bonuses[i] = {
                            id = i,
                            name = get_tbl_bonus.name,
                            modifier = math.Truncate(get_tbl_bonus.modifier * get_tbl_bonus.upgrade_mul^weapon_tbl.level * garlic_like_determine_weapon_bonuses_modifiers(weapon_tbl.rarity) * potency, 3),
                            desc = get_tbl_bonus.desc,
                            upgrade_mul = get_tbl_bonus.upgrade_mul,
                            max_mul = get_tbl_bonus.max_mul,
                            type_mul = get_tbl_bonus.type_mul,
                        }

                        net.Start(gl .. "choose_weapon")
                        net.WriteString(button_weapon_slot.gl_chosen_weapon)
                        net.WriteString("UPGRADE_WEAPON")
                        net.WriteTable( tbl_gl_stored_bonused_weapons)
                        net.WriteTable({})
                        net.SendToServer()

                        for k, bonus in pairs(weapon_tbl.bonuses) do
                            tbl_bonus_labels[k].bonus_text_front = tostring(bonus.modifier * 100) .. "% " .. "-> " .. tostring(math.Truncate(math.min(bonus.max_mul, bonus.modifier * bonus.upgrade_mul) * 100, 1)) .. "% "
                            tbl_bonus_labels[k].bonus_text = bonus.desc
                        end

                        -- PrintTable(weapon_tbl.bonuses)
                        surface.PlaySound("garlic_like/slot_beep.wav")
                    end
                end

                reroll_button.Paint = function(self, w, h) 
                    if bonus_label.bonus_text ~= "" then 
                        local color = 255

                        if MaterialsInventory["Reroll Crystal"].held_num < required_reroll_crystals then 
                            color = 125
                        end

                        if self:IsHovered() then 
                            self:SetTooltip(required_reroll_crystals .. " Reroll Crystals required." .. " Owned: " .. MaterialsInventory["Reroll Crystal"].held_num)
                        end

                        surface.SetDrawColor(color, color, color, 255) 
                        surface.SetMaterial(self.mat_dice) 
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
                if not wep:IsScripted() or  tbl_gl_stored_bonused_weapons[wep.ClassName] == nil then continue end
                --
                local mat_wep_icon
                local mat_wep_icon_texture
                local weapon_box = wsd:Add("DButton")
                weapon_box:SetSize(wsd:GetWide(), H * 0.4)
                weapon_box:Dock(TOP)
                weapon_box:DockMargin(W * 0.01, W * 0.01, W * 0.01, 0)
                weapon_box:SetText("")
                local str_1, str_2 = string.find(wep.ClassName, "arccw")

                if str_1 ~= nil then
                    mat_wep_icon = Material("arccw/weaponicons/" .. wep.ClassName)

                    if not mat_wep_icon:IsError() then
                        mat_wep_icon_texture = surface.GetTextureID(mat_wep_icon:GetTexture("$basetexture"):GetName())
                    end
                else
                    mat_wep_icon = Material(surface.GetTextureNameByID(wep.WepSelectIcon)) or Material(surface.GetTextureNameByID(weapons.Get(weapons.Get(wep.ClassName)).WepSelectIcon))
                end

                --*
                --! FINISH WEAPON UPGRADE MENU
                --*
                weapon_box.DoClick = function(self, w, h)
                    surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
                    button_weapon_slot.gl_chosen_weapon = wep.ClassName
                    button_upgrade.enough_materials = nil
                    local mat_wep_icon
                    local str_1, str_2 = string.find(wep.ClassName, "arccw")
                    weapon_tbl =  tbl_gl_stored_bonused_weapons[button_weapon_slot.gl_chosen_weapon]
                    weapon_rarity = weapon_tbl.rarity 
                    weapon_rarity_num = garlic_like_rarity_to_num(weapon_rarity) 
                    required_reroll_crystals = math.Round(math.Remap((tbl_gl_rarity_to_number[weapon_rarity] + 1) / 2, 1, 4, 1, 50))

                    --* SET THE NEW REROLL CRYSTAL VALUE
                    for k, panel in ipairs(tbl_reroll_buttons) do 
                        panel:SetTooltip(required_reroll_crystals .. " Reroll Crystals required")
                    end

                    if str_1 ~= nil then
                        mat_wep_icon = Material("arccw/weaponicons/" .. wep.ClassName)

                        if not mat_wep_icon:IsError() then
                            mat_wep_icon_texture = surface.GetTextureID(mat_wep_icon:GetTexture("$basetexture"):GetName())
                        end
                    else
                        mat_wep_icon = Material(surface.GetTextureNameByID(wep.WepSelectIcon)) or Material(surface.GetTextureNameByID(weapons.Get(weapons.Get(wep.ClassName)).WepSelectIcon))
                    end

                    button_weapon_slot.gl_chosen_weapon_mat = mat_wep_icon

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
                    surface.DrawCircle(w * 0.5, w * 0.2, w * 0.15, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity])
                    gl_cse(ply, w * 0.5, h * 0.375, string.upper( tbl_gl_stored_bonused_weapons[wep.ClassName].rarity), "", "", true, false, "", false, gl .. "font_subtitle", tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity], true)
                    gl_cse(ply, w * 0.5, h * 0.425, "", "", wep.PrintName, true, false, "", false, gl .. "font_title_3", nil, true)
                    draw.DrawText("LEVEL " ..  tbl_gl_stored_bonused_weapons[wep.ClassName].level, gl .. "font_subtitle", w * 0.5, h * 0.46, color_white, TEXT_ALIGN_CENTER)
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(mat_wep_icon)
                    surface.DrawTexturedRect(w * 0.5 - w * 0.225, h * 0.1, w * 0.45, h * 0.2)

                    for k, bonus in pairs( tbl_gl_stored_bonused_weapons[wep.ClassName].bonuses) do
                        gl_cse(ply, w * 0.5, (h * 0.5) + (k * h * 0.06), 100 * bonus.modifier, "%", bonus.desc, true, false, "", false, gl .. "font_subtitle", nil, true)
                    end

                    if self:IsHovered() and not self:IsDown() then
                        draw.RoundedBox(8, 0, 0, w, h, Color(tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].r, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].g, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].b, 10))
                    end

                    if self:IsDown() then
                        draw.RoundedBox(8, 0, 0, w, h, Color(tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].r, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].g, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].b, 30))
                    end
                end
            end

            --* MATERIALS ON THE BOTTOM DISPLAY
            for k, ore in pairs(WepCrystalsInventory) do
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
                        ore.num_needed_material = weapon_tbl.level * 5

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

                    for k, ore in pairs(WepCrystalsInventory) do
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
                    net.WriteTable( tbl_gl_stored_bonused_weapons)
                    net.WriteTable({})
                    net.SendToServer()

                    garlic_like_update_money(price, "BOUGHT_ITEM")

                    -- PrintTable( tbl_gl_stored_bonused_weapons[button_weapon_slot.gl_chosen_weapon])
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

            --* PAINTS
            dms.Paint = function(self, w, h) end

            label_weapon_name.Paint = function(self, w, h)
                -- surface.SetDrawColor(255, 255, 255) 
                -- surface.DrawOutlinedRect(0, 0, w, h, 1)            
                if button_weapon_slot.gl_chosen_weapon == "NONE" then
                    draw.DrawText("WEAPON NAME", gl .. "font_title_2", w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)
                else
                    local wep_name = button_weapon_slot.gl_chosen_weapon
                    gl_cse(ply, w * 0.5, h * 0.15, string.upper( tbl_gl_stored_bonused_weapons[wep_name].rarity), "", "", true, false, "", false, gl .. "font_title_3", tbl_gl_rarity_colors[string.lower( tbl_gl_stored_bonused_weapons[wep_name].rarity)], true)
                    gl_cse(ply, w * 0.5, h * 0.5, string.upper( tbl_gl_stored_bonused_weapons[wep_name].name), "", "", true, false, "", false, gl .. "font_title_2", color_white, true)
                    draw.DrawText("LEVEL " .. weapon_tbl.level, gl .. "font_subtitle_2", w * 0.5, h * 0.6, color_white, TEXT_ALIGN_CENTER)
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
                surface.SetMaterial(mat_hl)
                surface.DrawTexturedRect(w * 0.5 + t_w / 2, h * 0.5 - screenscale_8 / 2, screenscale_8, screenscale_8)
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
                    surface.DrawCircle(w * 0.5, w * 0.105, w * 0.085, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[button_weapon_slot.gl_chosen_weapon].rarity])
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
                        if not wep:IsScripted() or  tbl_gl_stored_bonused_weapons[wep.ClassName] == nil then continue end
                        if  tbl_gl_stored_bonused_weapons[wep.ClassName].rarity == "god" then continue end
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
                        local str_1, str_2 = string.find(wep.ClassName, "arccw")
        
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
                            local str_1, str_2 = string.find(wep.ClassName, "arccw")
                            weapon_tbl =  tbl_gl_stored_bonused_weapons[wep.ClassName]
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
                                        panel.border_color = tbl_gl_rarity_colors[string.lower(weapon_rarity)]
        
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
                                            fused_rarity = table.KeyFromValue(tbl_gl_rarity_to_number, tbl_gl_rarity_to_number[panel.tbl_item.rarity] + 1)
                                            button_result.border_color = tbl_gl_rarity_colors[fused_rarity]
                                            button_result.wep_icon = Material("garlic_like/question_mark_white_sizefit.png")
                                        end
                                    end
                                end
        
                                currently_chosen_fuse_slot = math.min(3, currently_chosen_fuse_slot + 1)
                            end
        
                            -- PrintTable(weapon_tbl)
                        end
        
                        weapon_box.Paint = function(self, w, h)
                            if not  tbl_gl_stored_bonused_weapons[wep.ClassName] then return end 
                            --
                            draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 35))
                            surface.SetDrawColor(255, 255, 255)
                            surface.DrawCircle(w * 0.5, w * 0.2, w * 0.15, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity])
                            gl_cse(ply, w * 0.5, h * 0.375, string.upper( tbl_gl_stored_bonused_weapons[wep.ClassName].rarity), "", "", true, false, "", false, gl .. "font_subtitle", tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity], true)
                            gl_cse(ply, w * 0.5, h * 0.425, "", "", wep.PrintName, true, false, "", false, gl .. "font_title_3", nil, true)
                            draw.DrawText("LEVEL " ..  tbl_gl_stored_bonused_weapons[wep.ClassName].level, gl .. "font_subtitle", w * 0.5, h * 0.46, color_white, TEXT_ALIGN_CENTER)
                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(mat_wep_icon)
                            surface.DrawTexturedRect(w * 0.5 - w * 0.225, h * 0.1, w * 0.45, h * 0.2)
        
                            for k, bonus in pairs( tbl_gl_stored_bonused_weapons[wep.ClassName].bonuses) do
                                gl_cse(ply, w * 0.5, (h * 0.5) + (k * h * 0.06), 100 * bonus.modifier, "%", bonus.desc, true, false, "", false, gl .. "font_subtitle", nil, true)
                            end
        
                            if self:IsHovered() and not self:IsDown() then
                                draw.RoundedBox(8, 0, 0, w, h, Color(tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].r, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].g, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].b, 10))
                            end
        
                            if self:IsDown() then
                                draw.RoundedBox(8, 0, 0, w, h, Color(tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].r, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].g, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[wep.ClassName].rarity].b, 30))
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

                for k2, v2 in pairs( tbl_gl_stored_bonused_weapons) do 
                    for k3, panel in ipairs(tbl_bt_item_to_fuse) do 
                        if k2 == panel.tbl_item.class then 
                            -- print("FOUND IT !!!!")
                             tbl_gl_stored_bonused_weapons[k2] = nil 
                            --  tbl_gl_stored_bonused_weapons = table.ClearKeys( tbl_gl_stored_bonused_weapons) 
                        end
                    end
                end

                for k2, panel in pairs(tbl_bt_item_to_fuse) do 
                    table.insert(tbl_of_weps_to_remove, panel.tbl_item.class)
                    panel.tbl_item = nil
                end
                -- 
                garlic_like_get_weapon(button_result, tbl_valid_weapons, "ROLL", fused_rarity)
                --
                surface.PlaySound("items/gift_pickup.wav")

                if button_result.wep_bonuses_amount > 0 then
                     tbl_gl_stored_bonused_weapons[button_result.wep.ClassName] = {
                        bonuses = {},
                        bonus_amount = 0,
                        name = "",
                        rarity = "",
                        level = 1
                    }

                     tbl_gl_stored_bonused_weapons[button_result.wep.ClassName].bonuses = button_result.wep_bonuses
                     tbl_gl_stored_bonused_weapons[button_result.wep.ClassName].name = button_result.wep.PrintName
                     tbl_gl_stored_bonused_weapons[button_result.wep.ClassName].rarity = button_result.wep_rarity
                     tbl_gl_stored_bonused_weapons[button_result.wep.ClassName].element = button_result.wep_element.name
                     tbl_gl_stored_bonused_weapons[button_result.wep.ClassName].bonus_amount = button_result.wep_bonuses_amount
                     tbl_gl_stored_bonused_weapons[button_result.wep.ClassName].level = 1
                end

                fused_preview.wep = button_result.wep

                local str_1, str_2 = string.find(fused_preview.wep.ClassName, "arccw")

                if str_1 ~= nil then
                    fused_preview.wep_icon = Material("arccw/weaponicons/" .. fused_preview.wep.ClassName)

                    if not fused_preview.wep_icon:IsError() then
                        fused_preview.wep_icon = surface.GetTextureID(fused_preview.wep_icon:GetTexture("$basetexture"):GetName())
                        -- print("ICON " .. fused_preview.wep_icon)
                    end
                end

                button_result.wep_icon = fused_preview.wep_icon 
                -- PrintTable( tbl_gl_stored_bonused_weapons)
                --  
                net.Start(gl .. "choose_weapon")
                net.WriteString(button_result.wep.ClassName)
                net.WriteString("PICK_WEAPON")
                net.WriteTable( tbl_gl_stored_bonused_weapons)
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
                price = math.Round(25 * tbl_gl_rarity_to_number[fused_rarity]^4.5)
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
                surface.SetMaterial(mat_hl)
                surface.DrawTexturedRect(w * 0.5 + t_w / 2, h * 0.5 - screenscale_8 / 2, screenscale_8, screenscale_8)
            end

            fused_preview.Paint = function(self, w, h)
                if not self.wep then return end
                --
                draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 35))
                surface.SetDrawColor(255, 255, 255)
                surface.DrawCircle(w * 0.5, w * 0.2, w * 0.15, tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[self.wep.ClassName].rarity])
                gl_cse(ply, w * 0.5, h * 0.375, string.upper( tbl_gl_stored_bonused_weapons[self.wep.ClassName].rarity), "", "", true, false, "", false, gl .. "font_subtitle", tbl_gl_rarity_colors[ tbl_gl_stored_bonused_weapons[self.wep.ClassName].rarity], true)
                gl_cse(ply, w * 0.5, h * 0.425, "", "", self.wep.PrintName, true, false, "", false, gl .. "font_title_3", nil, true)
                draw.DrawText("LEVEL " ..  tbl_gl_stored_bonused_weapons[self.wep.ClassName].level, gl .. "font_subtitle", w * 0.5, h * 0.46, color_white, TEXT_ALIGN_CENTER)
                surface.SetDrawColor(255, 255, 255)

                if isnumber(self.wep_icon ) then 
                    surface.SetTexture(self.wep_icon)
                else
                    surface.SetMaterial(self.wep_icon)
                end

                surface.DrawTexturedRect(w * 0.5 - w * 0.225, h * 0.03, w * 0.45, h * 0.15)

                for k, bonus in pairs( tbl_gl_stored_bonused_weapons[self.wep.ClassName].bonuses) do
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
                weapons_table_filtered[#weapons_table_filtered + 1] = wep
            end
        end

        timer_run_num = 0

        timer.Create("weapon_image_randomize_" .. ply:Nick(), 0.05, 50, function()
            timer_run_num = timer_run_num + 1
            -- print(timer_run_num)
            wep = weapons_table_filtered[math.random(#weapons_table_filtered)]
            weapon_image = "vgui/entities/" .. wep.ClassName
            weapon_rarity_random = "TEST "
            weapon_name_random = wep.PrintName
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
        garlic_like_save_table_to_json(ply, garlic_like_upgrades, gl .. "upgrades")
    end)

    concommand.Add(gl .. "debug_open_shop", function(ply, cmd, args, argStr)
        garlic_like_open_main_menu()
    end)

    concommand.Add(gl .. "level_up_cl", function(ply, cmd, args, argStr)
        if pending_level_ups > 0 then
            pending_level_ups = pending_level_ups - 1
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
        -- PrintTable(garlic_like_items_held)
    end)  
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