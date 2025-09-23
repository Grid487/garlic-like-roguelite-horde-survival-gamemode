if SERVER then return end 
  
FROZE_GL = FROZE_GL or {}
--
local gl = "garlic_like_"
local rh = "relic_held_"

--* hooks 
hook.Add("InitPostEntity", gl .. "initialize", function()
    timer.Simple(0.25, function() 
        -- print("INITPOSTENTITY CLIENT")
        garlic_like_init()                

        local ply = LocalPlayer()
        
        FROZE_GL.tbl_run_end_screen_2.rank_num = tonumber(ply:GetPData(gl .. "rank_num", 0))
        FROZE_GL.tbl_run_end_screen_2.rank_xp_current = tonumber(ply:GetPData(gl .. "rank_xp_current", 0))
        FROZE_GL.tbl_run_end_screen_2.rank_xp_to_rank_up = tonumber(ply:GetPData(gl .. "rank_xp_to_rank_up", 30)) 

        timer.Simple(3, function() 
            -- print("MAKE THINK HOOK FOR WEAPON INVENTORY!")
            garlic_like_create_wep_power_tbl() 
        end)
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
 
do  
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

            if ent:IsWeapon() and ent.IsTFA then 
                table.insert(FROZE_GL.tbl_tfa_wep_ents, ent)
            end

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

        if ent.IsTFA then 
            for k, v in pairs(FROZE_GL.tbl_tfa_wep_ents) do 
                if v == ent then                         
                    table.remove(FROZE_GL.tbl_tfa_wep_ents, k)
                end
            end
        end

        if #FROZE_GL.garlic_like_item_drops_entities > 0 then
            FROZE_GL.garlic_like_item_drops_entities = table.ClearKeys(FROZE_GL.garlic_like_item_drops_entities)
        end
    end)

    hook.Add("PostDrawTranslucentRenderables", gl .. "item_floating_labels", function()
        --
        -- PrintTable(FROZE_GL.garlic_like_item_drops_entities)
        local ply = LocalPlayer() 

        garlic_like_draw_item_label(FROZE_GL.tbl_tfa_wep_ents)

        if #FROZE_GL.garlic_like_item_drops_entities > 0 then 
            garlic_like_draw_item_label(FROZE_GL.garlic_like_item_drops_entities)
        end

        -- for k, ent in pairs(FROZE_GL.garlic_like_item_drops_entities) do
        --     if not ent:GetNWBool(gl .. "settled_2") then continue end
        --     if ent:GetNWBool(gl .. "is_being_picked_up") then continue end
        --     --
        --     local angles = ply:EyeAngles()
        --     local obbcenter = ent:LocalToWorld(ent:OBBCenter())
        --     local basepos = ent:GetPos()
        --     local pos = Vector(basepos.x, basepos.y, basepos.z)
        --     local rarity = ent:GetNWString(gl .. "item_rarity")
        --     local rarity_color = FROZE_GL.tbl_rarity_colors[rarity]
        --     local beam_start = pos + Vector(0, 0, 10)
        --     local beam_end = pos + Vector(0, 0, math.Remap(garlic_like_rarity_to_num(rarity), 1, 7, 100, 175))
        --     --
        --     render.SetMaterial(FROZE_GL.mat_beam)

        --     if ent:GetClass() == "garlic_like_station_weapon_upgrade" or ent:GetClass() == gl .. "station_item_fusing" then 
        --         -- do nothing
        --     else
        --         render.DrawBeam(beam_start, beam_end, 1, 0, 1, rarity_color)
        --     end

        --     if not rarity then 
        --         rarity = "common"
        --     end
            
        --     cam.Start3D2D(Vector(obbcenter.x, obbcenter.y, ent:LocalToWorld(ent:OBBMaxs()).z + 40), Angle(0, angles.y - 90, 90), 0.5)  
            
        --     if ent:GetClass() == gl .. "wep_crystal" then 
        --         local amount = " x" .. ent:GetNWInt(gl .. "item_amount", 1)

        --         if ent:GetNWBool(gl .. "is_food") or ent:GetNWBool(gl .. "is_powerup") then 
        --             amount = ""
        --         end

        --         if rarity_color == nil then 
        --             rarity_color = color_white
        --         end

        --         draw.WordBox(4, 0, 0, ent:GetNWString(gl .. "item_name") .. amount, gl .. "font_subtitle", color_black_alpha_200, rarity_color, TEXT_ALIGN_CENTER)
        --     else 
        --         if not rarity_color then 
        --             rarity_color = color_white
        --         end
                
        --         local name = ent:GetNWString(gl .. "item_name")

        --         if (not name or name == "") and ent.PrintName then 
        --             name = ent.PrintName
        --         end

        --         if not ent:IsScripted() then 
        --             name = language.GetPhrase(ent:GetClass())
        --         end

        --         draw.WordBox(4, 0, 0, name, gl .. "font_subtitle", color_black_alpha_200, rarity_color, TEXT_ALIGN_CENTER)
        --     end

        --     cam.End3D2D()
        -- end
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

    hook.Add("PostDrawHUD", gl .. "xp_bar", function() 
        if GetConVar(gl .. "hud_enable"):GetInt() == 0 then return end
        if GetConVar(gl .. "enable"):GetInt() == 0 then return end
        local ply = LocalPlayer()
        local convar_font_2 = GetConVar(gl .. "hud_font_2"):GetString()

        if ply.gl_has_menu_open then return end 
        if not FROZE_GL.run_end_screen_stop_showing then return end 
        if FROZE_GL.tbl_run_end_screen_2.is_running then return end 
        
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
                -- draw.DrawText("Held: " .. FROZE_GL.WepCrystalsInventory[FROZE_GL.tbl_rarity_to_number[data.rarity]].held_num, gl .. "item_pickup_held_num", (data.pos_x - W * 0.005) + FROZE_GL.glips.bg_width, data.pos_y + H * 0.03, data.color_text_held, TEXT_ALIGN_RIGHT)            
                draw.DrawText("Held: " .. ply:GetGLMaterialNum(data.rarity, "nwint"), gl .. "item_pickup_held_num", (data.pos_x - W * 0.005) + FROZE_GL.glips.bg_width, data.pos_y + H * 0.03, data.color_text_held, TEXT_ALIGN_RIGHT)            
            elseif data.item_type == "material" then 
                -- draw.DrawText("Held: " .. FROZE_GL.tbl_materials_inventory[data.text].held_num, gl .. "item_pickup_held_num", (data.pos_x - W * 0.005) + FROZE_GL.glips.bg_width, data.pos_y + H * 0.03, data.color_text_held, TEXT_ALIGN_RIGHT)            
                -- print("data.text", data.text)
                draw.DrawText("Held: " .. ply:GetGLMaterialNum(FROZE_GL.tbl_item_name_to_id[data.text], "nwint"), gl .. "item_pickup_held_num", (data.pos_x - W * 0.005) + FROZE_GL.glips.bg_width, data.pos_y + H * 0.03, data.color_text_held, TEXT_ALIGN_RIGHT)            
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
                        FROZE_GL.tbl_run_end_screen_2.rank_xp_gained_2 = tbl.rank_xp_gained
                        FROZE_GL.tbl_run_end_screen_2.time_elapsed_hold_rmb = 0
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
                    speed_mod = 5
                end
            else 
                speed_mod = 1
                tbl2.time_elapsed_hold_rmb = 0
            end

            tbl2.rank_xp_gained = math.max(0, tbl2.rank_xp_gained - math.min(tbl2.rank_xp_to_rank_up, RFT * tbl2.rank_xp_to_rank_up * speed_mod)) 

            if tbl2.rank_xp_gained > 0 then 
                tbl2.rank_xp_current = tbl2.rank_xp_current + math.min(tbl2.rank_xp_to_rank_up, RFT * tbl2.rank_xp_to_rank_up * speed_mod)  
            end

            --! MAKE THE CLIENTSIDE RANK PERSISTENT AND LINK IT WITH SERVER
            if tbl2.rank_xp_current >= tbl2.rank_xp_to_rank_up then 
                surface.PlaySound("garlic_like/mm_rank_up_achieved.wav")                    

                tbl2.color_xp_bar_highlight.a = 200
                tbl2.rank_xp_to_rank_up = math.min(150, tbl2.rank_xp_to_rank_up + 3)
                tbl2.rank_num = tbl2.rank_num + 1
                tbl2.rank_xp_current = 0

                local weight_rolled = math.random(1, FROZE_GL.valid_inventory_items_max_weight)
                -- print("weight rolled: " .. weight_rolled)

                for k, v in ipairs(FROZE_GL.tbl_valid_inventory_items) do 
                    if not v.ru_reward then continue end 

                    if IsNumBetween(weight_rolled, v.drop_weight_min_ru, v.drop_weight_max_ru) then 
                        garlic_like_add_inventory_item(v.name, 1) 

                        tbl2.tbl_gained_chests[#tbl2.tbl_gained_chests + 1] = {
                            name = v.name, 
                            desc = v.desc,
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

                        garlic_like_save_menu_inventory()
                    end
                end 

                -- PrintTable(FROZE_GL.tbl_menu_inventory.consumables)
                -- print("------------------------------------------------------------------------------------------------------")
                -- print("------------------------------------------------------------------------------------------------------")
                -- PrintTable(tbl2.tbl_gained_chests)
                -- print("------------------------------------------------------------------------------------------------------")
            end
        elseif tbl2.rank_xp_gained <= 0 then 
            if not ply.gl_close_end_screen_2_time then 
                ply.gl_close_end_screen_2_time = CurTime() + 2
                -- print("SET TIMER FOR END 2")
            end

            if ply.gl_close_end_screen_2_time and ply.gl_close_end_screen_2_time < CurTime() then 
                ply.gl_close_end_screen_2_time = nil
                tbl2.stop_running = true
                tbl2.is_running = false 
                tbl2.tbl_gained_chests = {}
                tbl2.rank_xp_gained = 0 

                net.Start(gl .. "update_rank_cl_to_sv")
                net.WriteInt(tbl2.rank_num, 32)
                net.WriteInt(tbl2.rank_xp_current, 32)
                net.WriteInt(tbl2.rank_xp_to_rank_up, 32)
                net.SendToServer()

                ply:SetPData(gl .. "rank_num", tbl2.rank_num)
                ply:SetPData(gl .. "rank_xp_current", tbl2.rank_xp_current)
                ply:SetPData(gl .. "rank_xp_to_rank_up", tbl2.rank_xp_to_rank_up)
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

        draw.SimpleText("HOLD RIGHT MOUSE BUTTON TO FAST FORWARD!", gl .. "font_subtitle_2", W * 0.5, H * 0.85, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
                surface.SetMaterial(FROZE_GL.mat_icon_ult)
                surface.DrawTexturedRect(W * 0.655, H * 0.89, W * 0.04, W * 0.04)
                draw.SimpleText(math.Truncate(FROZE_GL.tbl_ult.ult_cooldown, 1), gl .. "font_title_2", W * 0.675, H * 0.92, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(FROZE_GL.mat_icon_ult)
                surface.DrawTexturedRect(W * 0.655, H * 0.89, W * 0.04, W * 0.04)
                
                draw.SimpleText("Ctrl + LMB + RMB", gl .. "font_subtitle_2", W * 0.655 + (W * 0.04) / 2, H * 0.89 + W * 0.04, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            if ply:GetNWBool(gl .. "dash_available") then
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(FROZE_GL.mat_icon_dash)
                surface.DrawTexturedRect(W * 0.3, H * 0.88, W * 0.05, W * 0.05)

                draw.SimpleText("G", gl .. "font_subtitle_2", W * 0.3 + (W * 0.05) / 2, H * 0.88 + W * 0.05, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                surface.SetDrawColor(125, 125, 125)
                surface.SetMaterial(FROZE_GL.mat_icon_dash)
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
            local y_mod1 = H * 0.025
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
                    surface.DrawTexturedRect(FROZE_GL.line_length, H * 0.48 - W * 0.015 / 2 - y_mod1, W * 0.015, W * 0.015)
                end
            end

            -- surface.SetMaterial()
            gl_cse(ply, FROZE_GL.line_length, H * 0.45 - y_mod1, string.upper(rarity), "", "", true, false, "", false, gl .. "font_title_3", FROZE_GL.tbl_rarity_colors[rarity], false)
            gl_cse(ply, FROZE_GL.line_length + W * 0.017, H * 0.48 - y_mod1, "", "", weapon_name, true, false, "", false, gl .. "font_title_2", FROZE_GL.tbl_rarity_colors[rarity], false)

            --* stars
            local obtained_wep_data = {}

            for k2, wep_data in pairs(FROZE_GL.tbl_menu_inventory.obtained_weapons) do 
                if wep_data.classname == ply_wep:GetClass() then 
                    obtained_wep_data = wep_data
                    break
                end
            end

            if not table.IsEmpty(obtained_wep_data) then 
                for i = 1, 5 do  
                    surface.SetDrawColor(255, 255, 255) 

                    if obtained_wep_data.stars >= i then
                        surface.SetMaterial(FROZE_GL.mat_star_yellow)
                    else
                        surface.SetMaterial(FROZE_GL.mat_star_gray)
                    end

                    surface.DrawTexturedRect((W * 0.017 * (i - 1)) + FROZE_GL.line_length, H_half_screen - W * 0.017, W * 0.017, W * 0.017)  
                end
            end

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
                local dmg_melee_2 = 1                            
                local range_1
                local range_2 = 1
                local aspd_1
                local aspd_2 = 1
                local numshot
                local rpm 
                local magcap
                local recoil 
                local text_numshot
                
                local wep_tbl = weapons.Get(wep:GetClass())
                local tbl_wep_primary = (wep_tbl.Primary)  
                local tbl_wep_secondary = (wep_tbl.Secondary)  
                
                if garlic_like_is_arccw_wep(wep) then 
                    dmg = wep.Damage * base_mod_num
                    rpm = (60 / wep.Delay) * base_mod_num
                    numshot = wep.Num
                    magcap = tbl_wep_primary.ClipSize * base_mod_num
                    recoil = 1 / base_mod_num
                elseif garlic_like_is_tfa_wep(wep) then 
                    if is_tfa_melee then 
                        if tbl_wep_primary.Attacks then 
                            dmg_melee_1 = tbl_wep_primary.Attacks[1].dmg * base_mod_num
                            aspd_1 = 1 / tbl_wep_primary.Attacks[1]['end'] * base_mod_num
                            range_1 = tbl_wep_primary.Attacks[1].len * base_mod_num
                        elseif tbl_wep_primary.Damage then 
                            dmg_melee_1 = tbl_wep_primary.Damage 
                            aspd_1 = tbl_wep_priamry.RPM
                            range_1 = 1
                        end

                        if tbl_wep_secondary.Attacks then 
                            dmg_melee_2 = tbl_wep_secondary.Attacks[1].dmg * base_mod_num
                            aspd_2 = 1 / tbl_wep_secondary.Attacks[1]['end'] * base_mod_num
                            range_2 = tbl_wep_secondary.Attacks[1].len * base_mod_num 
                        elseif tbl_wep_secondary.BashDamage then  
                            dmg_melee_2 = tbl_wep_secondary.BashDamage
                            aspd_2 = 1
                        end
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
                    gl_cse(ply, FROZE_GL.line_length, (H * 0.53) + ((7) * H * 0.035), "", range_2, " RMB RANGE", true, false, "", false, gl .. "font_subtitle_2", color_text, false)
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
                    
                    -- print("entry name: " .. entry.name)
                    -- print("stat type: " .. entry.stat_type)
                    -- print("index for pos: " .. index_for_pos)
                    -- PrintTable(FROZE_GL.heights_stat_menu_desc)
                    -- print("y pos: " .. FROZE_GL.heights_stat_menu_desc[index_for_pos])
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

            --* info to switch pages
            draw.SimpleText("[WALK KEY] + E - Switch Pages", gl .. "font_subtitle", FROZE_GL.tbl_glss.glss_mid_pos_base, H * 0.035, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

    hook.Add("DrawOverlay", gl .. "tooltip_overlays", function() 
        -- if IsValid(vgui.GetHoveredPanel()) then 
        --     -- print(vgui.GetHoveredPanel())
        -- end

        for k, v in pairs(vgui.GetAll()) do 
            if v.gl_tooltip and v.gl_tooltip_text then 
                local x, y = input.GetCursorPos() 

                if v.gl_tooltip_mod_pos then 
                    x = x + v.gl_tooltip_mod_pos.x
                    y = y + v.gl_tooltip_mod_pos.y
                end

                garlic_like_draw_wmt2(v.gl_tooltip_text, gl .. "font_subtitle", x - W * 0.25 / 2, y - H * 0.02, W * 0.25, color_white, {bgColor = color_black, textAlign = "center"})
            end
        end
    end)

    hook.Add("PreDrawHalos", gl .. "draw_halo", function()
        if not GetConVar(gl .. "enable"):GetBool() then return end 
        
        outline.Add(ents.FindByClass(gl .. "weapon_crate_entity"), color_yellow, 0) 
        outline.Add(ents.FindByClass(gl .. "station_item_fusing"), color_blue, 0)
        outline.Add(ents.FindByClass(gl .. "station_weapon_upgrade"), color_blue, 0)
        outline.Add(ents.FindByClass(gl .. "item_barrel"), color_yellow, 0) 
        
        for rarity, color in SortedPairs(FROZE_GL.tbl_rarity_colors) do  
            if FROZE_GL.tbl_crystal_clusters and #FROZE_GL.tbl_crystal_clusters[rarity] > 0 then 
                outline.Add(FROZE_GL.tbl_crystal_clusters[rarity], color, 0)
            end
        end      
    end)

    hook.Add("HUDShouldDraw", gl .. "HideHUD", function( name )
        if not GetConVar(gl .. "enable"):GetBool() then return end

        if FROZE_GL.hide and ( FROZE_GL.hide[ name ] ) then
            return false
        end

        -- if name == "CHudHealth" then 
        --     return false
        -- end

        -- Don't return anything here, it may break other addons that rely on this hook.
    end)

    hook.Add( "PlayerButtonDown", "PlayerButtonDownWikiExample", function( ply, button )            
        if ( IsFirstTimePredicted() ) and button == KEY_N then 
            -- print( ply:Nick() .. " pressed " .. input.GetKeyName( button ) ) 
            -- print("CLICKED N BUTTON!")
            ply:ConCommand("garlic_like_level_up_cl")
        end 
    end)
end
