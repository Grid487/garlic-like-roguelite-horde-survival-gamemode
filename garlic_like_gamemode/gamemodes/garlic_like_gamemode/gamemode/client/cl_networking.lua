if SERVER then return end 
  
FROZE_GL = FROZE_GL or {}
--
local gl = "garlic_like_"
local rh = "relic_held_"

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
                if entry.rarity == item_rarity or entry.name == item_name or entry.rarity == item_name then
                    entry.held_num = math.max(0, entry.held_num + item_num)
                    -- entry.held_num = ply:GetNWInt(gl .. "held_num_material_" .. string.lower(entry.rarity), 0)
                    -- print(gl .. "held_num_material_" .. FROZE_GL.rarities[k])  

                    --* these set as two because the ore rarity/name can come from either item_name or item_rarity
                    ply:SetPData(gl .. "held_num_material_" .. string.lower(entry.rarity), entry.held_num)
                    -- ply:SetPData(gl .. "held_num_material_" .. string.lower(item_name), entry.held_num)

                    if show_notification then 
                        RunConsoleCommand(gl .. "debug_item_pickup_test", entry.name, item_num, item_rarity, "ore")
                    end
                end
            end  
        elseif order_type == "update_held_num_materials" then 
            for name, entry in pairs(FROZE_GL.tbl_materials_inventory) do
                -- print("item_name", item_name)
                -- print("name", name)
                if name == item_name then
                    entry.held_num = math.max(0, entry.held_num + item_num)
                    -- print("show_notification", show_notification)

                    if show_notification then 
                        RunConsoleCommand(gl .. "debug_item_pickup_test", item_name, item_num, item_rarity, "material")
                    end
                end
            end

            -- PrintTable(FROZE_GL.tbl_materials_inventory)
        elseif order_type == "load_saved_held_num_material" then
            -- print("ORDER TYPE IS TO LOAD MATERIALS!!!")
            -- print("ORDER TYPE IS TO LOAD MATERIALS!!!")
            -- print("ORDER TYPE IS TO LOAD MATERIALS!!!")
            -- print("ORDER TYPE IS TO LOAD MATERIALS!!!")
            -- print("ORDER TYPE IS TO LOAD MATERIALS!!!")
            -- print("ITEM NUM IS: " .. item_num)

            -- print("name is ", item_name)
            -- print("item_rarity is", item_rarity)

            for k, entry in ipairs(FROZE_GL.WepCrystalsInventory) do
                if entry.rarity == item_rarity then 
                    -- print(ply:GetPData("garlic_like_held_num_material_common", 0))
                    ply:SetPData(gl .. "held_num_material_" .. string.lower(entry.rarity), item_num)
                    ply:SetNWInt(gl .. "held_num_material_" .. string.lower(entry.rarity), item_num)
                    entry.held_num = tonumber(ply:GetPData(gl .. "held_num_material_" .. string.lower(entry.rarity)))
                    -- entry.held_num = ply:GetNWInt(gl .. "held_num_material_" .. string.lower(entry.rarity))
                    -- PrintTable(entry)
                    -- print("ore rarity ", item_rarity, "loaded!")
                end
            end

            for name, entry in pairs(FROZE_GL.tbl_materials_inventory) do
                if entry.id == item_name then 
                    ply:SetPData(gl .. "held_num_material_" .. entry.id, item_num)
                    ply:SetNWInt(gl .. "held_num_material_" .. entry.id, item_num)
                    entry.held_num = tonumber(ply:GetPData(gl .. "held_num_material_" .. entry.id))
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

        -- LEVEL UP
        -- print("FROZE_GL.xp_total: " .. FROZE_GL.xp_total)
        -- print("FROZE_GL.xp_to_next_level: " .. FROZE_GL.xp_to_next_level)

        if FROZE_GL.xp_total >= FROZE_GL.xp_to_next_level then
            local i = 1

            while FROZE_GL.xp_total >= FROZE_GL.xp_to_next_level do
                FROZE_GL.ply_level = FROZE_GL.ply_level + 1
                FROZE_GL.pending_level_ups = FROZE_GL.pending_level_ups + 1
                FROZE_GL.xp_total = FROZE_GL.xp_total - FROZE_GL.xp_to_next_level
                FROZE_GL.xp_to_next_level = math.Round((FROZE_GL.xp_to_next_level * 1.05 + 100 * (1.1 + FROZE_GL.ply_level / 10))^1.002)

                -- if i == 1 then
                -- elseif i >= 2 then
                --     garlic_like_level_up_cl(ply, FROZE_GL.ply_level, FROZE_GL.xp_to_next_level)

                --     timer.Simple(i / 3, function()
                --         FROZE_GL.ply_level = FROZE_GL.ply_level + 1
                --     end)
                -- end

                i = i + 1
            end

            timer.Simple(0.01, function() 
                garlic_like_level_up_cl(ply, FROZE_GL.ply_level, FROZE_GL.xp_to_next_level) 
            end)
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
        garlic_like_update_tbl_valid_weapons()
    end)

    net.Receive(gl .. "send_damage_numbers_sv_to_cl", function(len, ply)   
        local pos = net.ReadVector() 
        local dmg = net.ReadInt(32) 
        local ent = net.ReadEntity()  
        local maxdamage = net.ReadInt(32)  
        local customtype = net.ReadInt(32)

        if dmg <= 0 and customtype ~= 1853 then return end

        -- print("customtye: " .. customtype)

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