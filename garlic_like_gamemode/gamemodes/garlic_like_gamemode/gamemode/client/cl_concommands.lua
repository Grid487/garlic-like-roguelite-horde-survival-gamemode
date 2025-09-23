if SERVER then return end 

FROZE_GL = FROZE_GL or {}
--
local gl = "garlic_like_"

--* concommands
do  
    concommand.Add(gl .. "debug_reset_cooldown", function(ply, cmd, args, argStr) 
        FROZE_GL.tbl_ult.ult_cooldown = 0
    end)

    concommand.Add(gl .. "debug_add_material", function(ply, cmd, args, argStr) 
        local id, num = args[1], args[2]

        garlic_like_update_materials(id, num)
    end)

    concommand.Add(gl .. "roulette_open_test", function()
        local function DrawCircle(x, y, radius)
            local points = {}
            local segments = 30
            
            for i = 0, segments do
                local angle = math.rad((i / segments) * 360)
                points[#points + 1] = {
                    x = x + math.cos(angle) * radius,
                    y = y + math.sin(angle) * radius
                }
            end
            
            surface.DrawPoly(points)
        end 

        local currentRotation = 0
        local isSpinning = false
        
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Roulette")
        frame:SetSize(ScrW() * 0.5, ScrW() * 0.5)
        frame:Center()
        frame:MakePopup()
    
        local roulette = vgui.Create("DPanel", frame)
        roulette:Dock(FILL)
        
        local spinButton = vgui.Create("DButton", frame)
        spinButton:SetText("SPIN")
        spinButton:SetSize(100, 30)
        spinButton:SetPos(frame:GetWide() / 2 - 50, frame:GetTall() - 40)
        
        local function GetNumberAtPointer()
            local normalizedRotation = (currentRotation + 90) % 360
            local section = math.floor(normalizedRotation / 30)
            return ((11 - section) % 12 + 1) * 2
        end
        
        spinButton.DoClick = function()
            if isSpinning then return end
            
            -- Reset state
            isSpinning = true
            local startRotation = currentRotation
            local targetRotation = startRotation + math.random(360, 720)
            
            -- Remove any existing animation
            if roulette.ActiveAnimation then
                roulette.ActiveAnimation:Stop()
            end
            
            local anim = roulette:NewAnimation(1.5, 0, 0.5)
            roulette.ActiveAnimation = anim
            
            anim.Think = function(anim, pnl, fraction)
                currentRotation = Lerp(fraction, startRotation, targetRotation)
                
                -- print("startRotation: " .. startRotation)
                -- print("currentRotation: " .. currentRotation)
                -- print("targetRotation: " .. targetRotation)

                if fraction >= 0.999 then 
                    currentRotation = targetRotation
                    anim:OnComplete()
                end
            end
            
            anim.OnComplete = function()
                isSpinning = false
                roulette.ActiveAnimation = nil
                local result = GetNumberAtPointer()
                -- print("Roulette landed on: " .. result)
            end
        end
    
        roulette.Paint = function(self, w, h)
            draw.NoTexture()
            
            local centerX, centerY = w / 2, h / 2
            local radius = math.min(w, h) / 2 - 20
            local sections = 12
            local angleStep = 360 / sections
    
            -- Draw sections
            for i = 0, sections - 1 do
                local startAngle = math.rad(i * angleStep + currentRotation)
                local endAngle = math.rad((i + 1) * angleStep + currentRotation)
                local number = (i + 1) * 2
    
                surface.SetDrawColor(i % 2 == 0 and color_black_alpha_150 or color_black_alpha_100)
                surface.DrawPoly({
                    { x = centerX, y = centerY },
                    { x = centerX + math.cos(startAngle) * radius, y = centerY + math.sin(startAngle) * radius },
                    { x = centerX + math.cos(endAngle) * radius, y = centerY + math.sin(endAngle) * radius }
                })
    
                local textAngle = startAngle + (endAngle - startAngle) / 2
                local textX = centerX + math.cos(textAngle) * (radius * 0.7)
                local textY = centerY + math.sin(textAngle) * (radius * 0.7)
    
                draw.SimpleText(number, "DermaLarge", textX, textY, color_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)                    
            end
    
            -- Draw center point
            surface.SetDrawColor(color_black_alpha_200)
            DrawCircle(centerX, centerY, 10)
            
            -- Draw arrow
            surface.SetDrawColor(255, 0, 0, 255) -- Red arrow
            surface.DrawLine(centerX, centerY - radius, centerX, centerY - 20)
            surface.DrawLine(centerX, centerY - radius, centerX - 10, centerY - radius + 10)
            surface.DrawLine(centerX, centerY - radius, centerX + 10, centerY - radius + 10)
        end
    end) 

    concommand.Add(gl .. "debug_print_held_mats", function(ply, cmd, args, argStr)
        -- PrintTable(FROZE_GL.tbl_materials_inventory)
        -- PrintTable(FROZE_GL.WepCrystalsInventory)
    end)

    concommand.Add(gl .. "debug_open_gem_conversion", function(ply, cmd, args, argStr)
        if ply.gl_has_gem_conversion_panel_open then return end 
        ply.gl_has_gem_conversion_panel_open = true
        --! make gem conversion panel
        local tbl_gcurs, tbl_gcdr = {}, {}            
        
        local bf = vgui.Create("DPanel", nil, gl .. "bf_gem_conversion")
        ply.gl_gem_conversion_bf_panel = bf
        bf:SetSize(W * 0.55, H * 0.55)
        bf:Center()
        bf:CenterVertical(0.55) 
        bf:MakePopup()
        bf.color = Color(50, 50, 50)
        bf.color2 = Color(50, 50, 50)
        bf.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, self.color)
            draw.RoundedBox(8, 0, h * 0.875, w, h * 0.125, self.color2)
            -- draw.SimpleText("GEM CONVERSION", gl .. "font_title", w * 0.5, h * 0.05, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end       

        local bt_exit = vgui.Create("DButton") 
        bt_exit:SetY(bf:GetY())
        bt_exit:MoveRightOf(bf, W * 0.01)
        bt_exit:SetText("") 
        bt_exit:SetSize(W * 0.03, W * 0.03)
        bt_exit.Paint = function(self, w, h) 
            draw.RoundedBox(6, 0, 0, w, h, color_black_alpha_150) 
            draw.DrawText("X", gl .. "font_title", w * 0.5, 0, color_white, TEXT_ALIGN_CENTER) 
            garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
        end

        bt_exit.DoClick = function(self) 
            SafeRemovePanelDelayed(bf, 0) 
            SafeRemovePanelDelayed(bt_exit, 0) 
            ply.gl_has_gem_conversion_panel_open = false
            ply.gl_gem_conversion_bf_panel = nil
            
            if ply.gl_inventory_bf_panel then 
                ply.gl_inventory_bf_panel:Show()
                ply.gl_inventory_bt_exit_panel:Show()
            end
        end

        bf.bt_exit = bt_exit

        -- SafeRemovePanelDelayed(bf, 10) 
        -- SafeRemovePanelDelayed(bt_exit, 10) 

        local title = vgui.Create("DPanel", bf) 
        title:SetSize(bf:GetWide() * 0.4, bf:GetTall() * 0.2)
        title:Center()
        title:SetY(0)
        title.Paint = function(self, w, h) 
            surface.SetDrawColor(255, 255, 255)
            -- surface.DrawOutlinedRect(0, 0, w, h, 1)

            draw.DrawText("Gem Conversion", gl .. "font_title", w * 0.5, h * 0.25, color_white, TEXT_ALIGN_CENTER)
        end

        local but_help = vgui.Create("DButton", bf)
        but_help:SetSize(W * 0.025, W * 0.025)
        but_help:SetText("")
        but_help:SetY(title:GetY() + H * 0.03)
        but_help:MoveRightOf(title, 0)
        but_help.color = Color(255, 166, 0, 255)
        but_help.Paint = function(self, w, h) 
            draw.RoundedBox(8, 0, 0, w, h, self.color)       
            draw.DrawText("?", gl .. "font_title_2", w * 0.5, h * 0.05, color_white, TEXT_ALIGN_CENTER)         

            if self:IsHovered() then 
                self.gl_tooltip = true 
                self.gl_tooltip_text = "Left click a gem icon to get gems through conversion. scroll up and scroll down to increase or decrease conversion count."
                self.gl_tooltip_mod_pos = {x = 0, y = -H * 0.03}
            else 
                self.gl_tooltip = false
            end
        end

        local dist_between_rows = H * 0.05277
        
        for i = 1, 6 do 
            local tbl_gems = FROZE_GL.WepCrystalsInventory

            --* gcur = gem conversion up row
            local but_gcur = vgui.Create("DButton", bf) 
            local x_indent_for_centering = (W * 0.55 - (W * 0.05 * 6 + W * 0.025 * 5)) / 2
            but_gcur:SetSize(W * 0.05, W * 0.05)
            but_gcur:SetPos(x_indent_for_centering + (W * 0.05 + W * 0.025) * (i - 1), H * 0.16018)
            but_gcur:SetText("")
            but_gcur.color_hover = Color(255, 255, 255, 0)
            but_gcur.color_hover2 = Color(255, 0, 0, 0)
            but_gcur.convert_count = 3  

            table.insert(tbl_gcurs, #tbl_gcurs + 1, but_gcur)
            
            --* gcdr = hem conversion down row
            local but_gcdr = vgui.Create("DButton", bf) 
            local x_indent_for_centering = (W * 0.55 - (W * 0.05 * 6 + W * 0.025 * 5)) / 2
            but_gcdr:SetSize(W * 0.05, W * 0.05)
            but_gcdr:SetPos(x_indent_for_centering + (W * 0.05 + W * 0.025) * (i - 1), H * 0.16018 + dist_between_rows + W * 0.05)
            but_gcdr:SetText("")
            but_gcdr.color_hover = Color(255, 255, 255, 0)
            but_gcdr.color_hover2 = Color(255, 0, 0, 0)
            but_gcdr.convert_count = 1

            but_gcur.Paint = function(self, w, h) 
                draw.RoundedBox(8, 0, 0, w, h, color_black)

                paint.startPanel(self)
                paint.outlines.drawOutline(8, 0, 0, w, h, FROZE_GL.tbl_rarity_colors[tbl_gems[i].rarity], nil, 2)
                paint.endPanel()

                surface.SetDrawColor(255, 255, 255) 
                surface.SetMaterial(tbl_gems[i].material)
                surface.DrawTexturedRect(w * 0.1, h * 0.1, w * 0.8, h * 0.8)

                if self:IsHovered() then 
                    self.color_hover.a = self.color_hover.a + RealFrameTime() * 255
                    but_gcdr.color_hover2.a = but_gcdr.color_hover2.a + RealFrameTime() * 255 * 6
                else 
                    self.color_hover.a = self.color_hover.a - RealFrameTime() * 255
                    but_gcdr.color_hover2.a = but_gcdr.color_hover2.a - RealFrameTime() * 255 * 6
                end

                self.color_hover.a = math.Clamp(self.color_hover.a, 0, 25)
                but_gcdr.color_hover2.a = math.Clamp(but_gcdr.color_hover2.a, 0, 150)

                -- draw number of gems needed on bottom right
                draw.SimpleText(but_gcur.convert_count, gl .. "font_subtitle", w * 0.9, h * 0.9, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                -- draw number of gems held on top left
                draw.SimpleText("(x" .. ply:GetGLMaterialNum(tbl_gems[i].rarity, "nwint") .. ")", gl .. "font_subtitle", w * 0.05, h * 0.05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                draw.RoundedBox(8, 0, 0, w, h, self.color_hover)
                draw.RoundedBox(8, 0, 0, w, h, self.color_hover2)

                draw.SimpleText("+", gl .. "font_title", w * 0.5, h * 0.5, ColorAlpha(color_white, self.color_hover.a * 6), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("-", gl .. "font_title", w * 0.5, h * 0.5, ColorAlpha(color_white, self.color_hover2.a * 1), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            but_gcdr.Paint = function(self, w, h) 
                draw.RoundedBox(8, 0, 0, w, h, color_black)

                paint.startPanel(self)
                paint.outlines.drawOutline(8, 0, 0, w, h, FROZE_GL.tbl_rarity_colors[tbl_gems[i + 1].rarity], nil, 2)
                paint.endPanel()

                surface.SetDrawColor(255, 255, 255) 
                surface.SetMaterial(tbl_gems[i + 1].material)
                surface.DrawTexturedRect(w * 0.1, h * 0.1, w * 0.8, h * 0.8)

                if self:IsHovered() then 
                    self.color_hover.a = self.color_hover.a + RealFrameTime() * 255
                    but_gcur.color_hover2.a = but_gcur.color_hover2.a + RealFrameTime() * 255 * 6
                else 
                    self.color_hover.a = self.color_hover.a - RealFrameTime() * 255
                    but_gcur.color_hover2.a = but_gcur.color_hover2.a - RealFrameTime() * 255 * 6
                end

                self.color_hover.a = math.Clamp(self.color_hover.a, 0, 25)
                but_gcur.color_hover2.a = math.Clamp(but_gcur.color_hover2.a, 0, 150) 

                draw.SimpleText(but_gcdr.convert_count, gl .. "font_subtitle", w * 0.9, h * 0.9, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)-- draw number of gems held on top left
                draw.SimpleText("(x" .. ply:GetGLMaterialNum(tbl_gems[i + 1].rarity, "nwint") .. ")", gl .. "font_subtitle", w * 0.05, h * 0.05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                draw.RoundedBox(8, 0, 0, w, h, self.color_hover)
                draw.RoundedBox(8, 0, 0, w, h, self.color_hover2)

                draw.SimpleText("+", gl .. "font_title", w * 0.5, h * 0.5, ColorAlpha(color_white, self.color_hover.a * 6), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("-", gl .. "font_title", w * 0.5, h * 0.5, ColorAlpha(color_white, self.color_hover2.a * 1), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            but_gcur.DoClick = function(self) 
                if tbl_gems[i + 1].held_num < but_gcdr.convert_count then return end 
                -- PrintTable(tbl_gems[i])
                surface.PlaySound("garlic_like/slot_beep.wav") 

                garlic_like_update_ores(tbl_gems[i + 1].rarity, -but_gcdr.convert_count)
                garlic_like_update_ores(tbl_gems[i].rarity, but_gcur.convert_count)
            end

            but_gcdr.DoClick = function(self) 
                if ply:GetGLMaterialNum(tbl_gems[i].rarity, "nwint") < but_gcur.convert_count then return end 
                surface.PlaySound("garlic_like/slot_beep.wav") 

                garlic_like_update_ores(tbl_gems[i + 1].rarity, but_gcdr.convert_count)
                garlic_like_update_ores(tbl_gems[i].rarity, -but_gcur.convert_count)
            end

            table.insert(tbl_gcdr, #tbl_gcdr + 1, but_gcdr)
             
            but_gcur.OnMouseWheeled = function(self, delta) 
                if delta > 0 then 
                    -- print("scroll up")
                    but_gcur.convert_count = but_gcur.convert_count + 3
                    but_gcdr.convert_count = but_gcdr.convert_count + 1
                else 
                    but_gcur.convert_count = math.max(3, but_gcur.convert_count - 3)
                    but_gcdr.convert_count = math.max(1, but_gcdr.convert_count - 1)
                end
            end

            but_gcdr.OnMouseWheeled = function(self, delta) 
                if delta > 0 then 
                    -- print("scroll up")
                    but_gcur.convert_count = but_gcur.convert_count + 3
                    but_gcdr.convert_count = but_gcdr.convert_count + 1
                else 
                    but_gcur.convert_count = math.max(3, but_gcur.convert_count - 3)
                    but_gcdr.convert_count = math.max(1, but_gcdr.convert_count - 1)
                end
            end
            
            local img_exchange = vgui.Create("DPanel", bf) 
            local x_indent_for_centering = (W * 0.55 - (W * 0.05 * 6 + W * 0.025 * 5)) / 2
            img_exchange:SetSize(W * 0.05 * 0.5, dist_between_rows * 0.5)
            img_exchange:SetPos((W * 0.05) / 4 + x_indent_for_centering + (W * 0.05 + W * 0.025) * (i - 1), H * 0.16018 + W * 0.05 + (dist_between_rows - img_exchange:GetTall()) / 2)                 
            img_exchange.Paint = function(self, w, h) 
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(FROZE_GL.mat_exchange_rotated)
                surface.DrawTexturedRect(0, 0, w, h)
            end
        end
    end)

    concommand.Add(gl .. "debug_populate_menu_inventory", function(ply, cmd, args, argStr) 
        for i = 1, 15 do 
            local weight_rolled = math.random(1, FROZE_GL.valid_inventory_items_max_weight)
            -- print("weight rolled: " .. weight_rolled)

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

    concommand.Add(gl .. "debug_reset_rank_cl", function(ply, cmd, args, argStr)
        ply:SetPData(gl .. "rank_num", 0) 
        ply:SetPData(gl .. "rank_xp_current", 0)
        ply:SetPData(gl .. "rank_xp_to_rank_up", 30)
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
            -- PrintTable(FROZE_GL.tbl_materials_inventory)
            -- print("ARGS 1 IS", args[1])
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
            local btierup = vgui.Create("DImageButton", bf) 
            btierup:SetSize(bf_w * 0.03, bf_h * 0.04) 
            btierup:MoveRightOf(label_weapon_name, 0)
            btierup:SetY(label_weapon_name:GetY() + bf_h * 0.03) 
            btierup:Hide()
            btierup.color_bg = Color(77, 77, 77)
            btierup.color_bg2 = Color(41, 41, 41)
            btierup.color_bg3 = Color(245, 193, 83)
            btierup.required_element_crystals = 0
            btierup.gl_tooltip_text = ""
            btierup.limit_element_tier = 0

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
            
            local function update_serverside_wep_sbw_tbl() 
                net.Start(gl .. "choose_weapon")
                net.WriteString(button_weapon_slot.gl_chosen_weapon)
                net.WriteString("UPGRADE_WEAPON")
                net.WriteTable( FROZE_GL.gl_stored_bonused_weapons)
                net.WriteTable({})
                net.SendToServer()
            end

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
                -- reroll_button:SetTooltip(required_reroll_crystals .. " Reroll Crystals required. x3 for right click / potency rolling." .. " Owned: " .. FROZE_GL.tbl_materials_inventory["Reroll Crystal"].held_num)                
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

                        update_serverside_wep_sbw_tbl()

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
                            -- self:SetTooltip(required_reroll_crystals .. "/" .. required_reroll_crystals * 3 .. " Reroll Crystals required." .. " Owned: " .. FROZE_GL.tbl_materials_inventory["Reroll Crystal"].held_num)
                            self.gl_tooltip_text = required_reroll_crystals .. "/" .. required_reroll_crystals * 3 .. " Reroll Crystals required." .. " Owned: " .. FROZE_GL.tbl_materials_inventory["Reroll Crystal"].held_num
                            self.gl_tooltip = true 
                        else 
                            self.gl_tooltip = false
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
                    btierup:Show()
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

                    --* draw element tier 
                    draw.DrawText(garlic_like_num_to_roman(weapon_tbl.element_tier), gl .. "font_element_tier_indicator", w * 0.505 + t_w * 0.5 + w * 0.05, h * 0.425 - h * 0.05 / 2, color_white, TEXT_ALIGN_RIGHT)

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
                    local held_num = 0

                    if ore.held_num ~= nil then
                        held_num = ply:GetGLMaterialNum(ore.rarity, "nwint")
                        if held_num < ore.num_needed_material then
                            color_held_material_num = color_red
                            button_upgrade.enough_materials = false
                        else
                            color_held_material_num = color_white 
                        end
                    end

                    gl_cse(ply, w * 0.5, h * 0.25, "", held_num, "/" .. ore.num_needed_material, true, false, nil, false, gl .. "font_subtitle_2", color_held_material_num, true)
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

                        if ply:GetGLMaterialNum(ore.rarity, "nwint") >= ore.num_needed_material then
                            garlic_like_update_materials(ore.rarity, -ore.num_needed_material)
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

                    hook.Remove("DrawOverlay", gl .. "weapon_upgrade_tooltips")

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
                -- if self.erc_needed < FROZE_GL.tbl_materials_inventory["Element Crystal"].held_num then return end 
                surface.PlaySound("garlic_like/slot_beep.wav")

                self.alpha_element = 255

                for k, v in RandomPairs(FROZE_GL.tbl_elements) do 
                    weapon_tbl.element = v.name
                end

                update_serverside_wep_sbw_tbl()
            end

            btierup.DoClick = function(self)  
                if FROZE_GL.tbl_materials_inventory["Element Crystal"].held_num < self.required_element_crystals then 
                    return 
                end

                FROZE_GL.tbl_materials_inventory["Element Crystal"].held_num = FROZE_GL.tbl_materials_inventory["Element Crystal"].held_num - self.required_element_crystals
 
                surface.PlaySound("garlic_like/slot_beep.wav")

                weapon_tbl.element_tier = math.min(5, weapon_tbl.element_tier + 1)
                btierup.required_element_crystals = garlic_like_rarity_to_num(weapon_tbl.rarity) * weapon_tbl.element_tier
                garlic_like_update_materials("element_crystal", -self.required_element_crystals)

                update_serverside_wep_sbw_tbl()
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
                            break                                                  
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

                    --* draw element tier 
                    draw.DrawText(garlic_like_num_to_roman(weapon_tbl.element_tier), gl .. "font_element_tier_indicator", w * 0.505 + t_w * 0.5 + w * 0.03, h * 0.5 - w * 0.03 / 2, color_white, TEXT_ALIGN_RIGHT)

                    rbe:SetX(bf_w * 0.5 + t_w * 0.5 + rbe:GetWide() + w * 0.01)
                    btierup:SetX(bf_w * 0.5 + t_w * 0.5 + rbe:GetWide() * 2 + w * 0.02)
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
                    -- self:SetTooltip(self.erc_needed .. " Element Crystals required." .. " Owned: " .. FROZE_GL.tbl_materials_inventory["Element Crystal"].held_num)
                    self.gl_tooltip_text = self.erc_needed .. " Element Crystals required." .. " Owned: " .. FROZE_GL.tbl_materials_inventory["Element Crystal"].held_num
                    self.gl_tooltip = true 
                else 
                    self.gl_tooltip = false
                end

                if not self:IsMouseInputEnabled() then 
                    self:SetMouseInputEnabled(true)
                end 
            end

            btierup.Paint = function(self, w, h) 
                local color = 255      

                if FROZE_GL.tbl_materials_inventory["Element Crystal"].held_num < self.required_element_crystals then 
                    color = 125
                end

                surface.SetDrawColor(color, color, color, 255) 
                surface.SetMaterial(FROZE_GL.mat_anvil) 
                surface.DrawTexturedRect(0, 0, w, h) 

                if self:IsHovered() then 
                    if weapon_tbl.element_tier < 5 then 
                        btierup.required_element_crystals = garlic_like_rarity_to_num(weapon_tbl.rarity) * (weapon_tbl.element_tier + 1)
                    else 
                        btierup.required_element_crystals = 0
                    end

                    self.gl_tooltip = true        
                    self.gl_tooltip_text = "[Upgrade Element Tier] " .. self.required_element_crystals .. " Element Crystals required. Owned: " .. FROZE_GL.tbl_materials_inventory["Element Crystal"].held_num             
                else 
                    self.gl_tooltip = false
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

                    if isnumber(self.gl_chosen_weapon_mat) then 
                        surface.SetTexture(self.gl_chosen_weapon_mat)
                    else
                        surface.SetMaterial(self.gl_chosen_weapon_mat)
                    end

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

            local color_overlay_bg = Color(0, 0, 0, 150)

            --* drawoverlay for tooltips
            hook.Add("DrawOverlay", gl .. "weapon_upgrade_tooltips", function() 
                if btierup:IsHovered() then 
                    -- print("hovering btierup!")
                    local element = string.lower(weapon_tbl.element)  
                    local totalW = W * 0.144 * 5
                    local indentToCenter = (W - totalW) / 2
                
                    btierup.limit_element_tier = math.max(0, garlic_like_rarity_to_num(weapon_tbl.rarity) - 2)
                    -- print("btierup.limit_element_tier: " .. btierup.limit_element_tier)

                    draw.RoundedBox(0, 0, 0, W, H, color_overlay_bg)

                    for k, v in ipairs(FROZE_GL.tbl_elements_tiers) do 
                        if v.name == element then 
                            for k2, v2 in ipairs(v.info) do 
                                local x, y, title_h, color_bg, same_tier = indentToCenter + (W * 0.144 * (k2 - 1)), H * 0.4, select(2, gl_get_text_size("TIER " .. k2, gl .. "font_subtitle")), btierup.color_bg2, false

                                if weapon_tbl.element_tier > 0 and k2 <= weapon_tbl.element_tier then 
                                    color_bg = btierup.color_bg3
                                    same_tier = true 
                                else 
                                    color_bg = btierup.color_bg2
                                end

                                draw.RoundedBox(0, x, y - title_h * 2, W * 0.14, title_h * 2, color_bg)

                                if same_tier then 
                                    local alpha = 15 + math.abs(math.sin(CurTime() * 2)) * 25
                                    draw.RoundedBox(0, x, y - title_h * 2, W * 0.14, title_h * 2, ColorAlpha(color_white, alpha))
                                end

                                draw.SimpleText("TIER " .. k2, gl .. "font_subtitle", x + W * 0.07, y - title_h, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                local wmt2_h = garlic_like_draw_wmt2(v2, gl .. "font_element_tiers_tooltip", x, y, W * 0.14, color_white, {textAlign = "center", bgColor = btierup.color_bg})

                                if k2 > btierup.limit_element_tier then 
                                    draw.RoundedBox(0, x, y - title_h * 2, W * 0.14, title_h * 2 + wmt2_h, ColorAlpha(color_bg, 225))
                                    surface.SetDrawColor(255, 255, 255, 255) 
                                    surface.SetMaterial(FROZE_GL.mat_padlock) 
                                    surface.DrawTexturedRect(x + W * 0.05, y - title_h * 2.2 + W * 0.02, W * 0.04, W * 0.04)
                                    draw.SimpleText("HIGHER RARITY REQUIRED", gl .. "font_subtitle", x + W * 0.07, y - title_h, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)                                    
                                end
                            end
                        end
                    end
                end 
            end)

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
                        if  FROZE_GL.gl_stored_bonused_weapons[wep.ClassName].rarity == "ultimate" then continue end
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

    concommand.Add(gl .. "debug_print_garlic_like_upgrades_tbl", function(ply, cmd, args, argStr)
        -- PrintTable(FROZE_GL.garlic_like_upgrades)
    end)

    concommand.Add(gl .. "debug_print_garlic_like_skills_held", function(ply, cmd, args, argStr)
        -- PrintTable(FROZE_GL.skills_held)
    end)

    concommand.Add(gl .. "debug_print_garlic_like_items_held", function(ply, cmd, args, argStr)
        -- PrintTable(FROZE_GL.items_held)
    end)

    concommand.Add(gl .. "debug_print_valid_weps", function(ply, cmd, args, argStr)
        -- PrintTable(FROZE_GL.tbl_valid_weapons)
    end)

    concommand.Add(gl .. "debug_get_wep_func_test", function(ply, cmd, args, argStr)
        local wep_choice = {}

        wep_choice.wep = weapons.Get(GetConVar(gl .. "starting_weapon"):GetString())

        garlic_like_get_weapon(wep_choice, FROZE_GL.tbl_valid_weapons, GetConVar(gl .. "starting_weapon"):GetString(), garlic_like_num_to_rarity( math.max(2, FROZE_GL.wep_cso[GetConVar(gl .. "starting_weapon"):GetString()].rarity_num) ))

        surface.PlaySound("items/gift_pickup.wav") 

        garlic_like_store_wep_bonuses(ply, wep_choice)

        -- PrintTable(wep_choice)
    end)

    concommand.Add(gl .. "debug_print_valid_weapons_table_cl", function(ply, cmd, args, argStr)
        -- PrintTable(FROZE_GL.tbl_valid_weapons)
    end)

    concommand.Add(gl .. "debug_print_obtained_weapons_cl", function(ply, cmd, args, argStr)
        -- PrintTable(FROZE_GL.tbl_menu_inventory.obtained_weapons)
    end)

    concommand.Add(gl .. "debug_create_obtained_weapons_tbl2", function(ply, cmd, args, argStr)
            -- PrintTable(wep)
        FROZE_GL.tbl_menu_inventory.obtained_weapons = {}
        
        for k, wep in pairs(weapons.GetList()) do 
            if wep.PrintName and FROZE_GL.tbl_wep_power[wep.ClassName] and (wep.Base == "tfa_gun_base" or wep.Base == "tfa_melee_base" or string.find(wep.Base or "", "tfa")) then
                -- print("INSERTING WEAPON: " .. wep.PrintName .. " | " .. wep.ClassName)

                local owned1, owned_fragments1, rarity1, rarity_num1 = false, 0, "common", 2
                -- if math.random() <= 0.35 then 
                --     owned1 = true 
                --     owned_fragments1 = math.random(0, 125)
                -- end

                if FROZE_GL.wep_cso[wep.ClassName] then 
                    rarity1 = garlic_like_num_to_rarity(FROZE_GL.wep_cso[wep.ClassName].rarity_num)
                    rarity_num1 = FROZE_GL.wep_cso[wep.ClassName].rarity_num
                end

                if rarity_num1 <= 1 then 
                    owned1 = true
                    rarity1 = "common"
                    rarity_num1 = 2
                end

                table.insert(FROZE_GL.tbl_menu_inventory.obtained_weapons, {
                    name = wep.PrintName,
                    classname = wep.ClassName,
                    desc = "A weapon.",
                    rarity = rarity1,
                    rarity_num = rarity_num1,
                    icon_mat = Material("entities/" .. wep.ClassName .. ".png"),
                    power = FROZE_GL.tbl_wep_power[wep.ClassName],
                    owned = owned1,
                    owned_fragments = owned_fragments1,
                    equipped = false,
                    stars = 0,
                })
            end
        end

        table.SortByMember(FROZE_GL.tbl_menu_inventory.obtained_weapons, "rarity_num", true)

        timer.Simple(0.25, function()
            -- PrintTable(FROZE_GL.tbl_menu_inventory.obtained_weapons)
        end)
    end)

    concommand.Add(gl .. "debug_rewards_screen", function(ply, cmd, args, argStr)
        -- do something
        do
            ply.gl_temp_chest_rewards = {}

            --* test weapon pulling 
            garlic_like_summon("weapon", 5)
        end 
    end)

    concommand.Add("copy_tfa_weapons_table", function()
        local collected = {}
        for _, wep in ipairs(weapons.GetList()) do
            local cls = wep.ClassName
            local is_tfa = false
            if cls and string.sub(cls, 1, 4) == "tfa_" then
                is_tfa = true
            elseif type(wep.Base) == "string" and string.sub(wep.Base, 1, 4) == "tfa_" then
                is_tfa = true
            end
            if is_tfa and cls then
                local pn = wep.PrintName or cls
                if pn == "" then pn = cls end
                pn = language.GetPhrase(pn)
                table.insert(collected, { printname = pn, classname = cls })
            end
        end
        table.sort(collected, function(a, b)
            if a.printname ~= b.printname then
                return string.lower(a.printname) < string.lower(b.printname)
            end
            return string.lower(a.classname) < string.lower(b.classname)
        end)
        local lines = {}
        table.insert(lines, "tbl = {")
        for i, v in ipairs(collected) do
            table.insert(lines, "\n[" .. i .. "] = {")
            table.insert(lines, "\nprintname = " .. string.format("%q", v.printname) .. ",")
            table.insert(lines, "\nclassname = " .. string.format("%q", v.classname) .. ",")
            table.insert(lines, "\n},")
        end
        table.insert(lines, "\n}")
        local out = table.concat(lines)
        SetClipboardText(out)
        chat.AddText(Color(100, 220, 100), "Copied TFA weapons table to clipboard (" .. #collected .. ").")
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

    concommand.Add(gl .. "debug_clear_all_vgui", function()  
        for _, vguiElement in pairs(vgui.GetWorldPanel():GetChildren()) do
            if vguiElement.is_gl_panel then 
                vguiElement:Remove()
            end
        end
     
        RunConsoleCommand("spawnmenu_reload")
    end)

    concommand.Add(gl .. "print_cl_inventory", function(ply, cmd, args, argStr)
        -- print("\nGARLIC LIKE PRINTING CLIENTSIDE INVENTORY")
        -- PrintTable(FROZE_GL.items_held)
    end)  
end  