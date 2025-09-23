if SERVER then return end 
  
FROZE_GL = FROZE_GL or {}
--
local gl = "garlic_like_"
local rh = "relic_held_"
local W, H = ScrW(), ScrH()

function garlic_like_open_char_upgrades_menu(shop_base_panel) 
    local tbl_upgrade_panels = {}
    --
    local bf = vgui.Create("DPanel") 
    bf:SetSize(W * 0.4, H * 0.9)
    bf:Center()
    -- bf:CenterVertical(0.55)

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
        surface.PlaySound("garlic_like/disgaea_butback.wav") 
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
        surface.DrawTexturedRect(w * 0.93, h * 0.05 - h * 0.02, w * 0.07, w * 0.07)
        draw.DrawText(tostring(money), gl .. "font_title_2", w * 0.91, h * 0.05, color_white, TEXT_ALIGN_RIGHT)  
        -- outline_box(w, h)      
    end

    local dsp = vgui.Create( "DScrollPanel", bf )
    dsp:Dock( FILL )

    for k, entry in SortedPairs(FROZE_GL.tbl_character_stats) do                         
        local uframe = dsp:Add("DPanel") 
        uframe.panel_color = Color(161, 161, 161)
        uframe:SetTall(H * 0.5 * 0.4)
        uframe:Dock(TOP)
        uframe:DockMargin(bf_w * 0.05, H * 0.5 * 0.025, bf_w * 0.05, H * 0.5 * 0.005)
        uframe.upgrade_level = 0
        uframe.color_yellow = Color(255, 208, 0)

        local pdata_name = entry.name .. "_base_level"

        if ply:GetPData(pdata_name, nil) then 
            uframe.upgrade_level = tonumber(ply:GetPData(pdata_name))
        end 

        local bt_plus = vgui.Create("DButton", uframe) 
        btp = bt_plus
        btp:SetText("")
        btp:SetSize(H * 0.5 * 0.1, H * 0.5 * 0.1) 
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
                local money_back = (entry.shop_upgrade_base_price + entry.shop_upgrade_price_increase * uframe.upgrade_level) * (uframe.upgrade_level + 1)
                -- print("money_back", money_back)
                garlic_like_update_money(money_back, "GAIN_MONEY")     
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
        btm:SetSize(H * 0.5 * 0.1, H * 0.5 * 0.1) 
        btm:SetX(bf_w * 0.7 + H * 0.5 * 0.11)
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

            self.price = (entry.shop_upgrade_base_price + entry.shop_upgrade_price_increase * self.upgrade_level) * (self.upgrade_level + 1)
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
            surface.DrawTexturedRect(w * 0.9, h * 0.74, H * 0.5 * 0.1, H * 0.5 * 0.1) 
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

function garlic_like_open_summoning_menu(shop_base_panel) 
    --! make power cell indicator top right
    --! make power cell mat count sync with this
    local ply = LocalPlayer()   
    -- print("OPEN SUMMONING MENU") 
    local bf = vgui.Create("DPanel") 
    bf:SetSize(W * 0.5, H * 0.5) 
    bf:Center() 
    bf.is_gl_panel = true
    bf.hover_color = Color(0, 0, 0, 50)

    local bf_w, bf_h = bf:GetWide(), bf:GetTall()
    bf.panel_color = FROZE_GL.tbl_menu_colors["color_base"]

    bf.Paint = function(self, w, h) 
        draw.RoundedBox(6, 0, 0, w, h, self.panel_color)
    end

    --* title 
    local title = vgui.Create("DPanel", bf) 
    title:SetSize(W * 0.15, H * 0.1)
    title:CenterHorizontal() 

    title.Paint = function(self, w, h) 
        draw.DrawText("SUMMONING", gl .. "font_title", w * 0.5, h * 0.1, color_white, TEXT_ALIGN_CENTER)
        -- outline_box(w, h)
    end 

    --* buttons
    local bt_s20 = vgui.Create("DButton", bf) 
    bt_s20:SetSize(W * 0.13125, H * 0.049074)
    bt_s20:CenterHorizontal()
    bt_s20:SetY(bf_h - bt_s20:GetTall() - H * 0.025)
    bt_s20:SetText("")
    bt_s20.numsum = 20
    -- do something

    local bt_s10 = vgui.Create("DButton", bf) 
    bt_s10:SetSize(W * 0.13125, H * 0.049074)
    bt_s10:SetY(bt_s20:GetY())
    bt_s10:MoveLeftOf(bt_s20, W * 0.014583)
    bt_s10:SetText("")
    bt_s10.numsum = 10

    local bt_s40 = vgui.Create("DButton", bf) 
    bt_s40:SetSize(W * 0.13125, H * 0.049074)
    bt_s40:SetY(bt_s20:GetY())
    bt_s40:MoveRightOf(bt_s20, W * 0.014583)
    bt_s40:SetText("")
    bt_s40.numsum = 40

    local bt_skippa = vgui.Create("DButton", bf)
    bt_skippa:SetSize(W * 0.025, H * 0.02)
    bt_skippa:SetY(bt_s20:GetY() + bt_s20:GetTall() / 2 - bt_skippa:GetTall() / 2)
    bt_skippa:MoveRightOf(bt_s40, (bf:GetWide() - (bt_s40:GetX() + bt_s40:GetWide()) - bt_skippa:GetWide()) / 2)
    bt_skippa:SetText("") 
    bt_skippa.colors = {
        ["bg_inactive"] = Color(85, 85, 85),
        ["bg_active"] = Color(114, 114, 114),
        ["overlay_active"] = Color(255, 251, 0, 50),
    }

    if ply.summon_skippa then 
        bt_skippa.active_time = CurTime()
        bt_skippa.active = true
    end

    bt_skippa.Paint = function(self, w, h) 
        if not self.active then 
            draw.RoundedBox(4, 0, 0, w, h, self.colors.bg_inactive)
        else 
            draw.RoundedBox(4, 0, 0, w, h, self.colors.bg_active)            
            draw.RoundedBox(4, 0, 0, w, h, self.colors.overlay_active)                        

            self.colors.overlay_active.a = 50 + math.abs(math.cos((CurTime() - self.active_time) * 1.5)) * 100
        end

        draw.SimpleText("SKIP", gl .. "font_subtitle_small", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    bt_skippa.DoClick = function(self)  
        surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
        self.active = not self.active
        ply.summon_skippa = self.active
        self.active_time = CurTime()
    end

    local bt_exit = vgui.Create("DButton") 
    bt_exit:SetY(bf:GetY())
    bt_exit:MoveRightOf(bf, W * 0.01)
    bt_exit:SetText("") 
    bt_exit:SetSize(W * 0.03, W * 0.03) 

    local sum_buts = {[1] = bt_s10, [2] = bt_s20, [3] = bt_s40}

    for k, but in ipairs(sum_buts) do 
        but.req_pcell = but.numsum * 2.5
        -- print("REQ PCELL IS:", but.req_pcell)
        but.Paint = function(self, w, h) 
            local req_pcell = ply:GetGLMaterialNum("power_cell", "nwint") 

            if (req_pcell >= but.req_pcell) then 
                --! FINISH NUMSUM STUFF AND GREY OUT WHEN TOTAL IS LOWER
                -- print("sumunlocked20", ply:GetPData(gl .. "summon20_unlocked", "false"))
                -- print("issum20", but.numsum == 20)
                -- print("CHECK1:", (but.numsum == 20 and not tobool(ply:GetPData(gl .. "summon20_unlocked", "false"))))
                if (but.numsum == 20 and not tobool(ply:GetPData(gl .. "summon20_unlocked"))) or (but.numsum == 40 and not tobool(ply:GetPData(gl .. "summon40_unlocked"))) then 
                    -- print("OKAYONE1")
                    draw.RoundedBox(4, 0, 0, w, h, FROZE_GL.tbl_menu_colors["color_but_grey"])
                    draw.RoundedBox(4, 0, 0, w, h, color_black_alpha_100)
                else 
                    draw.RoundedBox(4, 0, 0, w, h, FROZE_GL.tbl_menu_colors["color_but1"])
                end
            else 
                draw.RoundedBox(4, 0, 0, w, h, FROZE_GL.tbl_menu_colors["color_but_grey"])
                draw.RoundedBox(4, 0, 0, w, h, color_black_alpha_100)
            end 

            draw.SimpleText("SUMMON x" .. but.numsum, gl .. "font_subtitle", w * 0.5, h * 0.25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
 
            local cost_text = "x" .. but.req_pcell
            local t_w, t_h = surface.GetTextSize(cost_text)
            local t_x = w * 0.5 - (t_w + W * 0.013) / 2
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetFont(gl .. "font_subtitle")
            surface.SetTextColor(255, 255, 255, 255)
            surface.SetTextPos(t_x, h * 0.5)
            surface.DrawText(cost_text)
            surface.SetMaterial(FROZE_GL.mat_icon_powercell)
            surface.DrawTexturedRect(t_x + t_w, h * 0.5, W * 0.013, W * 0.013)

            if but.numsum == 10 or (but.numsum == 20 and tobool(ply:GetPData(gl .. "summon20_unlocked"))) or (but.numsum == 40 and tobool(ply:GetPData(gl .. "summon40_unlocked"))) then
                if self:IsDown() then 
                    draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(bf.hover_color, 100))            
                elseif self:IsHovered() and not self:IsDown() then 
                    draw.RoundedBox(4, 0, 0, w, h, bf.hover_color)            
                end

                garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
            end

            if (but.numsum == 20 and not tobool(ply:GetPData(gl .. "summon20_unlocked"))) or (but.numsum == 40 and not tobool(ply:GetPData(gl .. "summon40_unlocked"))) then 
                draw.RoundedBox(4, 0, 0, w, h, color_black_alpha_225)    

                self.gl_tooltip = false 

                if self:IsHovered() then 
                    self.gl_tooltip_text = "Unlock through Unlockables!"
                    self.gl_tooltip = true 
                end
                -- surface.SetDrawColor(255, 255, 255, 255)
                -- surface.SetMaterial(FROZE_GL.mat_padlock)
                -- surface.DrawTexturedRect(w * 0.5 - w * 0.15 / 2, h * 0.5 - w * 0.15 / 2, w * 0.15, w * 0.15)
            end
        end

        but.DoClick = function(self, w, h) 
            if ply:GetGLMaterialNum("power_cell", "nwint") < but.req_pcell then 
                -- do nothing
                return
            end

            ply:SetPData(gl .. "summons_total", tonumber(ply:GetPData(gl .. "summons_total", 0)) + but.numsum)

            timer.Simple(0.5, function()
                if not IsValid(ply) then return end 

                -- print("totsumcount:", tonumber(ply:GetPData(gl .. "summons_total", 0)))

                if tonumber(ply:GetPData(gl .. "summons_total", 0)) >= 200 then 
                    ply:SetPData(gl .. "summon20_unlocked", true)
                end

                if tonumber(ply:GetPData(gl .. "summons_total", 0)) >= 500 then 
                    ply:SetPData(gl .. "summon40_unlocked", true)
                end
            end)

            -- print("REQ PCELL IS:", but.req_pcell)

            surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
            garlic_like_summon("weapon", but.numsum) 
            garlic_like_update_materials("power_cell", -but.req_pcell)
        end
    end

    --* banner 
    local banner = vgui.Create("DPanel", bf) 
    banner:SetSize(W * 0.452083, H * 0.3333)
    banner:SetY(H * 0.071296)
    banner:CenterHorizontal()

    banner.Paint = function(self, w, h) 
        surface.SetDrawColor(255, 255, 255, 255) 
        surface.SetMaterial(FROZE_GL.mat_gacha_banner1)
        surface.DrawTexturedRect(0, 0, w, h) 
    end

    --* help button/tooltip
    local but_help = vgui.Create("DButton", bf)
    but_help:SetSize(W * 0.025, W * 0.025)
    but_help:SetText("")
    but_help:SetY(title:GetY() + (banner:GetY() - but_help:GetTall()) / 2)
    but_help:MoveLeftOf(title, 0)
    but_help.color = Color(255, 166, 0, 255)
    but_help.Paint = function(self, w, h) 
        draw.RoundedBox(8, 0, 0, w, h, self.color)       
        draw.DrawText("?", gl .. "font_title_2", w * 0.5, h * 0.05, color_white, TEXT_ALIGN_CENTER)         

        if self:IsHovered() then 
            self.gl_tooltip = true 
            self.gl_tooltip_text = "Summon weapons to equip and upgrade in the inventory which also expands your random weapon crate selection."
            self.gl_tooltip_mod_pos = {x = 0, y = -H * 0.03}
        else 
            self.gl_tooltip = false
        end
    end 
  
    --* powercell indicator 
    local pcell_ind = vgui.Create("DPanel", bf)
    pcell_ind:SetSize(( bf:GetWide() - (title:GetX() + title:GetWide()) ) - ( bf:GetWide() - (banner:GetWide() + banner:GetX()) ), banner:GetY())
    pcell_ind:MoveRightOf(title)
    pcell_ind:SetY(title:GetY())

    pcell_ind.Paint = function(self, w, h) 
        -- outline_box(w, h)
        
        local pcell = ply:GetGLMaterialNum("power_cell", "nwint")
        surface.SetFont(gl .. "font_title_2")
        local pcell_w, pcell_h = surface.GetTextSize(tostring(pcell))
        local y = h * 0.25
        draw.RoundedBox(6, w * 0.91 - (w * 0.07) - pcell_w - w * 0.02, y, pcell_w + (w * 0.07) + w * 0.1 / 2 + w * 0.02, pcell_h, color_black_alpha_200)
        surface.SetDrawColor(255, 255, 255) 
        surface.SetMaterial(FROZE_GL.mat_icon_powercell) 
        surface.DrawTexturedRect(w * 0.85, (y + h * 0.025), w * 0.15, w * 0.15)
        draw.DrawText(tostring(pcell), gl .. "font_title_2", w * 0.91 - (w * 0.07), y, color_white, TEXT_ALIGN_RIGHT)   
    end
    --
    bt_exit:MakePopup()
    bf:MakePopup()

    bt_exit.DoClick = function(self) 
        SafeRemovePanel(bf)
        SafeRemovePanel(self)
        surface.PlaySound("garlic_like/disgaea_butback.wav") 
        shop_base_panel:Show()
    end

    bt_exit.Paint = function(self, w, h) 
        draw.RoundedBox(6, 0, 0, w, h, color_black_alpha_150) 
        draw.DrawText("X", gl .. "font_title", w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)

        garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
    end 
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
        --         name = FROZE_GL.tbl_menu_inventory_items_data["ore_ultimate"].name,
        --         id = "ore_ultimate",
        --         icon_mat = FROZE_GL.tbl_menu_inventory_items_data["ore_ultimate"].icon_mat,
        --         rarity = FROZE_GL.tbl_menu_inventory_items_data["ore_ultimate"].rarity,
        --         amount = 100,
        --     }, 
        -- }
    end

    local frame_background = vgui.Create("DFrame", nil, "rewards_base_frame") -- frame that covers the whole screen, acts as a base frame and background 
    local fb = frame_background 
    fb:SetPos(0, 0)
    fb:SetSize(W, H)
    fb.color_bg = Color(0, 0, 0, 200)
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
                ply.gl_is_summoning = false
                SafeRemovePanelDelayed(fb, 0.5)
            end

            draw.DrawText("HOLD RMB TO EXIT SCREEN " .. math.Round(math.Remap(self.progress_exit, 0, 1, 0, 100)) .. "%", gl .. "font_title_2", W * 0.5, H * 0.958, color_white, TEXT_ALIGN_CENTER)
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

    local reveal_delay = 0.1

    if ply.summon_skippa and ply.gl_is_summoning then 
        reveal_delay = 0
    end

    for k, v in ipairs(ply.gl_temp_chest_rewards) do 
        timer.Simple(k * reveal_delay, function() 
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

                    if v.is_weapon then 
                        surface.DrawTexturedRect(w * 0.5 - w * 0.35, h * 0.5 - w * 0.35, w * 0.7, w * 0.7)
                    else 
                        surface.DrawTexturedRect(w * 0.5 - w * 0.2, h * 0.5 - w * 0.2, w * 0.4, w * 0.4)
                    end

                    garlic_like_draw_scaled(v.name, w * 0.5, h * 0.15, w * 0.9, gl .. "font_title_3", GetConVar(gl .. "hud_font_2"):GetString(), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "LINES_DISABLED")

                    draw.RoundedBox(0, 0, h * 0.8, w, h * 0.15, self.color_amount_bg)
                    garlic_like_draw_scaled(v.amount, w * 0.5, h * 0.875, w * 0.9, gl .. "font_subtitle", GetConVar(gl .. "hud_font_2"):GetString(), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "LINES_DISABLED")

                    if v.rarity == "ultimate" then 
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

function garlic_like_show_level_up_screen(ply)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end 
    --
    choice_panels_num = 3
    FROZE_GL.choice_panels = {} 
    --
    local BASEPANEL = vgui.Create("DPanel", nil, gl .. "BASEPANEL") 
    BASEPANEL:SetSize(W, H)
    BASEPANEL.is_gl_panel = true
    BASEPANEL.color = Color(0, 0, 0, 0)
    BASEPANEL.reroll_chances = 1 + math.floor(ply:GetNWInt(gl .. "level", 1) / 15)

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
        local xp_button = vgui.Create("DButton", BASEPANEL, gl .. "xp_button") 
        local stat_booster_button = vgui.Create("DButton", BASEPANEL, gl .. "stat_booster_button") 

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

            --* latest drop system start choice
            local upgrade_choices = garlic_like_create_drop_table("Upgrade Choices")
            upgrade_choices:AddItem("statboost", 13000)
            upgrade_choices:AddItem("item_statboost", 1000)
            upgrade_choices:AddItem("skill", 1000)   
            upgrade_choices:AddItem("relic", 1000)
            local final_choice = upgrade_choices:Roll()["name"]   
            
            if final_choice == "statboost" then 
                choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_statboost)]
            elseif final_choice == "skill" then  
                choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_skill)]                     

                if table.Count(FROZE_GL.skills_held) >= 4 then 
                    final_choice = "statboost"
                end
            elseif final_choice == "relic" then 
                choice_panel.tbl_upgrade = FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_relic)]
                -- print("table.Count(FROZE_GL.relics_held)", table.Count(FROZE_GL.relics_held))
                -- print("4 + ply:GetNWInt(gl .. 'relic_slots_unlocked', 0)", 4 + ply:GetNWInt(gl .. "relic_slots_unlocked", 0))

                if table.Count(FROZE_GL.relics_held) >= 4 + ply:GetNWInt(gl .. "relic_slots_unlocked", 0) then 
                    -- print("EXCEED RELIC SLOTS !!!")
                    -- final_choice = "statboost"
                    for k, v in RandomPairs(FROZE_GL.relics_held) do 
                        for k2, v2 in pairs(FROZE_GL.garlic_like_upgrades) do 
                            if v2.name == v.name then 
                                choice_panel.tbl_upgrade = table.Copy(v2)
                                break
                            end
                        end

                        break
                    end
                end
            elseif final_choice == "item_statboost" then  
                choice_panel.tbl_upgrade = table.Copy(FROZE_GL.garlic_like_upgrades[table.Random(FROZE_GL.tbl_id_upgrades_item_statboost)])

                if table.Count(FROZE_GL.items_held) >= 4 then 
                    for k, tbl_upgrade in RandomPairs(FROZE_GL.items_held) do 
                        for k2, v2 in pairs(FROZE_GL.garlic_like_upgrades) do 
                            if v2.name == tbl_upgrade.name then 
                                choice_panel.tbl_upgrade = table.Copy(v2)
                                break
                            end
                        end

                        -- print("chose: ")
                        -- PrintTable(tbl_upgrade)
                        -- choice_panel.tbl_upgrade = table.Copy(tbl_upgrade)
                        
                    end
                end
            end
            --* latest drop system end choice 

            --* determines rarity and stats
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

                --* if the player already has the same upgrade, store a value to indicate this 
                if FROZE_GL.skills_held[choice_panel.tbl_upgrade.name] then 
                    choice_panel.upgrade_already_held = true   
                    
                    if garlic_like_rarity_to_num(FROZE_GL.skills_held[choice_panel.tbl_upgrade.name].rarity) < garlic_like_rarity_to_num(choice_panel.rarity) then  
                        choice_panel.upgrade_lower_rarity = true
                    elseif garlic_like_rarity_to_num(FROZE_GL.skills_held[choice_panel.tbl_upgrade.name].rarity) > garlic_like_rarity_to_num(choice_panel.rarity) then 
                        choice_panel.upgrade_higher_rarity = true
                    elseif garlic_like_rarity_to_num(FROZE_GL.skills_held[choice_panel.tbl_upgrade.name].rarity) == garlic_like_rarity_to_num(choice_panel.rarity) then 
                        choice_panel.upgrade_same_rarity = true
                    end
                end
            elseif choice_panel.tbl_upgrade.upgrade_type == "relic" then
                choice_panel.rarity, choice_panel.mul, choice_panel.mul_2 = garlic_like_determine_stats(choice_panel.tbl_upgrade, choice_panel.tbl_upgrade.upgrade_type)

                if FROZE_GL.relics_held[choice_panel.tbl_upgrade.name] then 
                    choice_panel.upgrade_already_held = true   

                    if garlic_like_rarity_to_num(FROZE_GL.relics_held[choice_panel.tbl_upgrade.name].rarity) < garlic_like_rarity_to_num(choice_panel.rarity) then  
                        choice_panel.upgrade_lower_rarity = true
                    elseif garlic_like_rarity_to_num(FROZE_GL.relics_held[choice_panel.tbl_upgrade.name].rarity) > garlic_like_rarity_to_num(choice_panel.rarity) then 
                        choice_panel.upgrade_higher_rarity = true
                    elseif garlic_like_rarity_to_num(FROZE_GL.relics_held[choice_panel.tbl_upgrade.name].rarity) == garlic_like_rarity_to_num(choice_panel.rarity) then 
                        choice_panel.upgrade_same_rarity = true
                    end
                end
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
            Choice.is_gl_panel = true
            Choice.damage = nil
            Choice.cooldown = nil
            Choice.area = nil
            Choice.isAnimating = true
            Choice.alpha_hl = 255
            Choice.color_tier_up, Choice.color_tier_down = Color(255, 208, 0), Color(240, 48, 34)

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
                    
                    xp_button:Show()      
                    xp_button:MoveTo(xp_button:GetX(), H * 0.925, 0.2, 0, -1, function() 
                        xp_button.on_cooldown = true

                        timer.Simple(0.5, function() 
                            if xp_button and IsValid(xp_button) then 
                                xp_button.on_cooldown = false
                            end
                        end)
                    end) 
                    
                    stat_booster_button:Show()      
                    stat_booster_button:MoveTo(stat_booster_button:GetX(), H * 0.925, 0.2, 0, -1, function() 
                        stat_booster_button.on_cooldown = true

                        timer.Simple(0.5, function() 
                            if stat_booster_button and IsValid(stat_booster_button) then 
                                stat_booster_button.on_cooldown = false
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

                    if Choice.upgrade_lower_rarity then     
                        surface.SetFont(gl .. "font_subtitle")
                        local t_w, white_alpha = select(1, surface.GetTextSize(rarity.tier)), (10 + math.abs(math.cos(CurTime() * 4)) * 175)                 
                        draw.SimpleText("RARITY UP!", gl .. "font_subtitle_2", w * 0.5 + t_w / 2 + W * 0.005, h * 0.5, Choice.color_tier_up, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText("RARITY UP!", gl .. "font_subtitle_2", w * 0.5 + t_w / 2 + W * 0.005, h * 0.5, ColorAlpha(color_white, white_alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    elseif Choice.upgrade_higher_rarity then   
                        surface.SetFont(gl .. "font_subtitle")
                        local t_w, white_alpha = select(1, surface.GetTextSize(rarity.tier)), (10 + math.abs(math.cos(CurTime() * 2)) * 125)                            
                        draw.SimpleText("RARITY DOWN", gl .. "font_subtitle_2", w * 0.5 + t_w / 2 + W * 0.005, h * 0.5, Choice.color_tier_down, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText("RARITY DOWN", gl .. "font_subtitle_2", w * 0.5 + t_w / 2 + W * 0.005, h * 0.5, ColorAlpha(color_white, white_alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    elseif Choice.upgrade_same_rarity then 
                        -- ✓
                        surface.SetFont(gl .. "font_subtitle")
                        local t_w, white_alpha = select(1, surface.GetTextSize(rarity.tier)), (10 + math.abs(math.cos(CurTime() * 2)) * 75)                            
                        draw.SimpleText("OWNED ✓", gl .. "font_subtitle_2", w * 0.5 + t_w / 2 + W * 0.005, h * 0.5, Choice.color_tier_up, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText("OWNED ✓", gl .. "font_subtitle_2", w * 0.5 + t_w / 2 + W * 0.005, h * 0.5, ColorAlpha(color_white, white_alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end
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
                Choice.statboost_num = statboost_num
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
                            gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 4), "%", string.format("%.1f", math.min(0.75, statboost_num.num * 0.005) * 100), " BLOCK DMG Reduction", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_block_resistance", 0) * 100) .. " + " )
                            gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 5), "", math.Truncate(math.max(0, (statboost_num.num / 40) * 3), 2), " HP REGEN/ s", true, true, ply:GetNWInt(gl .. "bonus_hp_regen", 1) .. " + " )
                            gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 6), "%", string.format("%.1f", (statboost_num.num * 0.02754) * 100), " CRITICAL DMG", true, true, "%" .. string.format("%.1f", (1 + ply:GetNWFloat(gl .. "bonus_critical_damage", 0)) * 100) .. " + " )
                        elseif statboost_num.sb_type == "AGI" then
                            gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 1), "%", string.format("%.1f", math.min(0.95, statboost_num.num * 0.002152) * 100), " DMG Reduction", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_resistance", 0) * 100) .. " + " )
                            gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 2), "", math.max(0, math.Round(statboost_num.num / 5)), " FLAT DMG Reduction", true, true, "+" .. ply:GetNWInt(gl .. "bonus_resistance_flat", 0) .. " + " )
                            gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 3), "%", string.format("%.1f", math.min(1, statboost_num.num * 0.006) * 100), " BLOCK Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_block_chance", 0) * 100) .. " + " )
                            gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 4), "%", string.format("%.1f", math.min(0.5, statboost_num.num * 0.0045) * 100), " EVASION Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_evasion_chance", 0) * 100) .. " + " )
                            gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 5), "%", string.format("%.1f", statboost_num.num * 0.0014325 * ply:GetNWFloat(gl .. "bonus_critical_chance_mult", 1) * 100), " CRITICAL Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_critical_chance", 0) * 100) .. " + " )
                            gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 6), "%", string.format("%.1f", math.min(5, statboost_num.num * 0.015) * 100), " MULTI HIT Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_multihit_chance", 0) * 100) .. " + " )
                            gl_cse(ply, pos_x_mid, h * (0.575 + 0.05 * 7), "%", string.format("%.1f", math.min(10, statboost_num.num * 0.004) * 100), " Accuracy", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_accuracy", 0) * 100) .. " + " )
                        elseif statboost_num.sb_type == "INT" then
                            gl_cse(ply, pos_x_mid, h * 0.625, "", math.max(0, statboost_num.num * 2), " MAX MANA", true, true, "+" .. ply:GetNWInt(gl .. "max_mana", 0) - 100 .. " + " )
                            gl_cse(ply, pos_x_mid, h * 0.675, "", math.Truncate(statboost_num.num / 50, 3), " MANA REGEN/ 0.2s", true, true, "" .. ply:GetNWInt(gl .. "mana_regen", 1) .. " + " )
                            gl_cse(ply, pos_x_mid, h * 0.725, "%", string.format("%.1f", math.max(0, statboost_num.num * 0.03) * 100), " MANA DMG Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_mana_damage", 0) * 100) .. " + " )
                            gl_cse(ply, pos_x_mid, h * 0.775, "%", string.format("%.1f", math.min(0.85, statboost_num.num * 0.00563) * 100), " MANA DMG Reduction", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_mana_resistance", 0) * 100) .. " + " )
                            gl_cse(ply, pos_x_mid, h * 0.825, "%", string.format("%.1f", statboost_num.num * 0.0015 * ply:GetNWFloat(gl .. "bonus_xp_mult", 1) * 100), " XP GAIN Increase", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "bonus_xp_gain", 0) * 100) .. " + " )
                            gl_cse(ply, pos_x_mid, h * 0.875, "%", string.format("%.1f", (1 - math.max(0.1, 1 - statboost_num.num * 0.0035)) * 100), " COOLDOWN Reduction", true, true, "%" .. string.format("%.1f", (1 - ply:GetNWFloat(gl .. "bonus_cooldown_mult", 0)) * 100) .. " + " )
                            gl_cse(ply, pos_x_mid, h * 0.925, "%", string.format("%.1f", math.max(0, statboost_num.num * 0.0045) * 100), " MULTICAST Chance", true, true, "%" .. string.format("%.1f", ply:GetNWFloat(gl .. "multicast", 0) * 100) .. " + " )
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

                    -- stars
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

                    draw.RoundedBox(6, w * 0.01, h * 0.007, w * 0.98, h * 0.985, Color(Choice.color_rarity_border.r, Choice.color_rarity_border.g, Choice.color_rarity_border.b, Choice.alpha_hl)) 

                    Choice.alpha_hl = math.max(0, Choice.alpha_hl - RealFrameTime() * 755)
                end

                Choice.DoClick = function(self)                        
                    garlic_like_choose_upgrade(ply, true, name.text, statboost_num.num, Choice.rarity, Choice.tbl_upgrade, Choice.damage, Choice.cooldown, Choice.area, Choice.mul, Choice.mul_2)
                    BASEPANEL:Remove()

                    ply:SetNWInt(gl .. "times_rerolled", 0)

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
        reroll_button:SetX(reroll_button:GetX() - ((W * 0.45 + H * 0.1)) / 2 + W * 0.15 / 2)
        reroll_button:SetText("") 
        reroll_button.but_color = Color(25, 25, 25, 255)
        reroll_button.but_highlight_color = Color(155, 155, 155, 0)
        reroll_button:MakePopup()
        reroll_button:Hide()      

        reroll_button.Paint = function(self, w, h)             
            -- if not self:IsMouseInputEnabled() then 
            --     surface.SetAlphaMultiplier(0.85)
            -- end

            -- draw.RoundedBox(6, 0, 0, w, h, self.but_color)
            -- -- draw.DrawText("REROLL " .. "(x" .. BASEPANEL.reroll_chances .. ")", gl .. "reroll_button_text", w * 0.5, h * 0.24, color_white, TEXT_ALIGN_CENTER)
            -- gl_cse(ply, w * 0.5, h * 0.24, "x", BASEPANEL.reroll_chances, ")", false, "", "REROLL (", false, gl .. "reroll_button_text", nil, true)

            -- if self:IsHovered() then 
            --     reroll_button.but_highlight_color.a = 75            
            -- else 
            --     reroll_button.but_highlight_color.a = math.max(0, reroll_button.but_highlight_color.a - RealFrameTime() * 755)
            -- end

            -- if self:IsDown() then 
            --     reroll_button.but_highlight_color.a = 150
            -- end

            -- draw.RoundedBox(6, 0, 0, w, h, self.but_highlight_color)
            -- surface.SetAlphaMultiplier(1)

            --?
         
            reroll_button.reroll_crystal_amount = FROZE_GL.tbl_materials_inventory["Reroll Crystal"].held_num
            reroll_button.reroll_crystal_amount_req = 2^(ply:GetNWInt(gl .. "times_rerolled", 0) + 1)
            -- print("reroll_button.reroll_crystal_amount_req", reroll_button.reroll_crystal_amount_req)

            if reroll_button.reroll_crystal_amount < reroll_button.reroll_crystal_amount_req then 
                reroll_button:SetMouseInputEnabled(false) 
            end
          
            if not self:IsMouseInputEnabled() then 
                surface.SetAlphaMultiplier(0.85)
            end
            
            draw.RoundedBox(6, 0, 0, w, h, self.but_color)                     
            surface.SetFont(gl .. "reroll_button_text")
            local text = "REROLL [NEEDS] x" .. self.reroll_crystal_amount_req
            local t_w, t_h = surface.GetTextSize(text)                     
            gl_cse(ply, w * 0.5 - H * 0.03 / 2, h * 0.24, "x", self.reroll_crystal_amount_req, "", false, "", "REROLL [NEEDS] ", false, gl .. "reroll_button_text", nil, true)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(FROZE_GL.tbl_menu_inventory_items_data["reroll_crystal"].icon_mat)
            surface.DrawTexturedRect(w * 0.5 + H * 0.002 + t_w * 0.5 - H * 0.03 / 2, h * 0.5 - H * 0.03 / 2, H * 0.03, H * 0.03)

            if self:IsHovered() then 
                reroll_button.but_highlight_color.a = 75            
            else 
                reroll_button.but_highlight_color.a = math.max(0, reroll_button.but_highlight_color.a - RealFrameTime() * 755)
            end

            if self:IsDown() then 
                reroll_button.but_highlight_color.a = 150
            end

            draw.RoundedBox(6, 0, 0, w, h, self.but_highlight_color)
            surface.SetAlphaMultiplier(1)
        end 

        xp_button:SetSize(W * 0.15, H * 0.05)
        xp_button:MoveRightOf(reroll_button, H * 0.05)
        xp_button:SetY(H + H * 0.05) 
        xp_button:SetText("") 
        xp_button.but_color = Color(25, 25, 25, 255)
        xp_button.but_highlight_color = Color(155, 155, 155, 0)
        xp_button:MakePopup()
        xp_button:Hide()

        xp_button.Paint = function(self, w, h)             
            draw.RoundedBox(6, 0, 0, w, h, self.but_color) 
            gl_cse(ply, w * 0.5, h * 0.24, "+", 20 .. "%", " XP)", false, "", "SKIP (", false, gl .. "reroll_button_text", nil, true)

            if self:IsHovered() then 
                xp_button.but_highlight_color.a = 75            
            else 
                xp_button.but_highlight_color.a = math.max(0, xp_button.but_highlight_color.a - RealFrameTime() * 755)
            end

            if self:IsDown() then 
                xp_button.but_highlight_color.a = 150
            end

            draw.RoundedBox(6, 0, 0, w, h, self.but_highlight_color)
        end

        xp_button.DoClick = function(self) 
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
            BASEPANEL:Remove()

            for k, v in pairs(FROZE_GL.choice_panels) do
                v:Remove()
            end

            ply:SetNWInt(gl .. "times_rerolled", 0)

            --* write code to give player 25% of current next lv xp here
            net.Start(gl .. "request_xp_skip_cl_to_sv")
            net.WriteInt(math.Round(tonumber(ply:GetNWInt(gl .. "xp_to_next_level")) * 0.2), 32)                    
            net.SendToServer()
        end

        stat_booster_button:SetSize(W * 0.15, H * 0.05)
        stat_booster_button:MoveRightOf(xp_button, H * 0.05)
        stat_booster_button:SetY(H + H * 0.05) 
        stat_booster_button:SetText("") 
        stat_booster_button.but_color = Color(25, 25, 25, 255)
        stat_booster_button.but_highlight_color = Color(155, 155, 155, 0)
        stat_booster_button.stat_scroll_amount = ply:GetNWInt(gl .. "held_num_material_stat_scroll", 0)
        stat_booster_button:MakePopup()
        stat_booster_button:Hide()

        if stat_booster_button.stat_scroll_amount < 1 then 
            stat_booster_button:SetMouseInputEnabled(false)
        end

        stat_booster_button.Paint = function(self, w, h)    
            if not self:IsMouseInputEnabled() then 
                surface.SetAlphaMultiplier(0.85)
            end
            
            draw.RoundedBox(6, 0, 0, w, h, self.but_color)                     
            surface.SetFont(gl .. "reroll_button_text")
            local text = "USE STAT SCROLL x" .. self.stat_scroll_amount
            local t_w, t_h = surface.GetTextSize(text)                    
            -- draw.DrawText(text, gl .. "reroll_button_text", w * 0.5 - H * 0.03 / 2 - H * 0.005 / 2, h * 0.24, color_white, TEXT_ALIGN_CENTER)
            gl_cse(ply, w * 0.5 - H * 0.03 / 2, h * 0.24, "x", self.stat_scroll_amount, "", false, "", "USE STAT SCROLL ", false, gl .. "reroll_button_text", nil, true)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(FROZE_GL.tbl_menu_inventory_items_data["stat_scroll"].icon_mat)
            surface.DrawTexturedRect(w * 0.5 + H * 0.002 + t_w * 0.5 - H * 0.03 / 2, h * 0.5 - H * 0.03 / 2, H * 0.03, H * 0.03)

            if self:IsHovered() then 
                stat_booster_button.but_highlight_color.a = 75            
            else 
                stat_booster_button.but_highlight_color.a = math.max(0, stat_booster_button.but_highlight_color.a - RealFrameTime() * 755)
            end

            if self:IsDown() then 
                stat_booster_button.but_highlight_color.a = 150
            end

            draw.RoundedBox(6, 0, 0, w, h, self.but_highlight_color)
            surface.SetAlphaMultiplier(1)
        end

        stat_booster_button.DoClick = function(self) 
            if self.on_cooldown then return end 
            if self.stat_scroll_amount < 1 then return end 
                
            for k, v in pairs(FROZE_GL.choice_panels) do
                if v.upgrade_type == "statboost" then 
                    v.statboost_num.num = v.statboost_num.num * 2
                    v.alpha_hl = 255 
                    self:SetMouseInputEnabled(false)     
                end
            end

            if not self:IsMouseInputEnabled() then   
                stat_booster_button.stat_scroll_amount = stat_booster_button.stat_scroll_amount - 1

                garlic_like_update_materials("stat_scroll", -1) 

                surface.PlaySound("garlic_like/mm_rank_up_achieved.wav")
            end
        end

        reroll_button.DoClick = function(self) 
            if reroll_button.reroll_crystal_amount < reroll_button.reroll_crystal_amount_req then 
                -- print("not enough reroll crystals")
                return
            end 

            if self.on_cooldown then return end 
            --if BASEPANEL.reroll_chances < 1 then return end 
            --
            -- PrintTable(FROZE_GL.choice_panels)

            -- for k, panel in pairs(FROZE_GL.choice_panels) do 
            --     create_upgrade_choice(panel)
            -- end

            -- lower_highlight_transparency()

            -- self:Hide()
            -- self:SetY(H + H * 0.05)
            BlackBG:Remove()

            for k, v in pairs(FROZE_GL.choice_panels) do
                v:Remove()
            end

            create_choices() 

            -- BASEPANEL.reroll_chances = BASEPANEL.reroll_chances - 1

            -- if BASEPANEL.reroll_chances < 1 then 
            --     self:SetMouseInputEnabled(false)
            -- end

            self.on_cooldown = true 

            garlic_like_update_materials("Reroll Crystal", -reroll_button.reroll_crystal_amount_req)

            ply:SetNWInt(gl .. "times_rerolled", ply:GetNWInt(gl .. "times_rerolled", 0) + 1)

            timer.Simple(1.75, function() 
                if self and IsValid(self) then 
                    self.on_cooldown = false
                end
            end)
 
            reroll_button:Remove() 
            xp_button:Remove()
            stat_booster_button:Remove()
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

function garlic_like_open_inventory_menu(shop_base_panel)
    local ply = LocalPlayer()  

    --* load obtained weapons
    do  
        ply:GLLoadObtainedWeapons()
    end

    local bf = vgui.Create("DPanel") 
    bf:SetSize(W * 0.55, H * 0.55) 
    bf:CenterHorizontal() 
    bf:CenterVertical(0.55) 
    local bf_w, bf_h = bf:GetWide(), bf:GetTall()
    bf.panel_color = Color(61, 61, 61)

    --? bcXX means buttom category XX

    local but_cat_consumables = vgui.Create("DButton")
    local bcc = but_cat_consumables
    bcc:SetSize(W * 0.12, H * 0.04)
    bcc:MoveLeftOf(bf, W * 0.01)
    bcc:SetY(bf:GetY())
    bcc:SetText("")      
    bcc:SetMouseInputEnabled(true)

    local but_cat_materials = vgui.Create("DButton")
    local bcm = but_cat_materials
    bcm:SetSize(W * 0.12, H * 0.04)
    bcm:MoveLeftOf(bf, W * 0.01)
    bcm:MoveBelow(bcc, W * 0.005)
    bcm:SetText("")  
    bcm:SetMouseInputEnabled(true)

    local but_cat_gem_convert = vgui.Create("DButton")
    local bcgc = but_cat_gem_convert
    bcgc:SetSize(W * 0.12, H * 0.04)
    bcgc:MoveLeftOf(bf, W * 0.01)
    bcgc:MoveBelow(bcm, W * 0.005)
    bcgc:SetText("")  
    bcgc:SetMouseInputEnabled(true)

    local but_cat_weps = vgui.Create("DButton") 
    local bcw = but_cat_weps 
    bcw:SetSize(W * 0.12, H * 0.04)
    bcw:MoveLeftOf(bf, W * 0.01)
    bcw:MoveBelow(bcgc, W * 0.005)
    bcw:SetText("")
    bcw:SetMouseInputEnabled(true)

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
        --     -- print("hovered panel: " .. tostring(vgui.GetHoveredPanel()))
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
                -- PrintTable(FROZE_GL.tbl_menu_inventory.consumables) 
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

            if prompt.button_upgrade then 
                prompt.button_upgrade:Remove()   
                prompt.button_upgrade = nil
            end

            if prompt.button_equip then 
                prompt.button_equip:Remove()   
                prompt.button_equip = nil
            end

            prompt:SetTall(H * 0.035)  
        end
        
        prompt.color = Color(0, 0, 0, 200)

        prompt.Paint = function(self, w, h) 
            -- draw.RoundedBox(0, 0, 0, w, h, self.color)

            if prompt.hoverable_panels then 
                -- PrintTable(prompt.hoverable_panels)
            end

            if prompt.hovered_panel then 
                if prompt.button_open and prompt.button_open:IsHovered() then 
                    -- print("OPEN BUTTON HOVERED!")
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
            draw.RoundedBox(0, 0, 0, w, h, prompt.color)

            -- PrintTable(prompt.hovered_panel.item_data)

            garlic_like_draw_scaled(prompt.hovered_panel.item_data.name, w * 0.05, 0, prompt:GetWide() * 0.9, gl .. "font_title_3", GetConVar(gl .. "hud_font_2"):GetString(), color_white, TEXT_ALIGN_LEFT, NO_ALIGNMENT, "LINES_DISABLED")

            local desc = prompt.hovered_panel.item_data.desc

            if category == "WEAPONS" then 
                desc = "+" .. prompt.hovered_panel.item_data.stars * 12 .. "% Final Stat Modifier"
            end

            local text_wmt = garlic_like_draw_wmt(desc, gl .. "font_subtitle", w * 0.05, H * 0.035, prompt:GetWide() * 0.9, color_white)
            -- print("text_wmt", text_wmt)

            prompt_name:SetTall(H * 0.035 + text_wmt + H * 0.005)

            surface.SetDrawColor(255, 255, 255)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        local tbl_menu_inv

        if category == "CONSUMABLES" then 
            garlic_like_load_menu_inventory()
            tbl_menu_inv = FROZE_GL.tbl_menu_inventory.consumables
        elseif category == "MATERIALS" then 
            tbl_menu_inv = FROZE_GL.tbl_menu_inventory.materials
        elseif category == "WEAPONS" then 
            ply.gl_obtained_weapons = ply.gl_obtained_weapons or {}
            tbl_menu_inv = FROZE_GL.tbl_menu_inventory.obtained_weapons
        end 

        local overlay_sparkles = {}

        hook.Remove("DrawOverlay", gl .. "upgrade_effects")

        hook.Add("DrawOverlay", gl .. "upgrade_effects", function() 
            for k, data in pairs(overlay_sparkles) do 
                if data and data.sparkles then  
                    for k2, data2 in pairs(data.sparkles) do 
                        if data2.alpha > 0 then 
                            data2.alpha = math.max(0, data2.alpha - RealFrameTime() * 400)
                        end

                        if data2.alpha <= 1 then 
                            table.remove(data.sparkles, k2)
                        end 

                        data2.x = data2.x + data2.vel_x
                        data2.y = data2.y - data2.vel_y   

                        data2.vel_y = data2.vel_y - W * 0.00015

                        if k2 == 1 then 
                            -- print("data2.y", data2.y)
                        end

                        surface.SetDrawColor(255, 255, 255, data2.alpha)
                        surface.SetMaterial(FROZE_GL.mat_sparkle)
                        surface.DrawTexturedRectRotated(data2.x, data2.y, W * 0.0075, W * 0.0075, math.cos(CurTime() * math.Rand(2, 3)) * 360)
                    end
                end
            end
        end)
        
        for i = 1, math.max(32, #tbl_menu_inv) do      
            local but = vgui.Create( "DButton" )
            but:SetText( "" )
            but:SetSize( bf_w * 0.11, bf_w * 0.11 )
            but.color_highlight = Color(255, 255, 255, 0)
            but.color_outline = Color(192, 192, 192)
            but.color_item_amount_bg = Color(0, 0, 0, 100)
            but.overlay_upgrade_color = Color(255, 255, 255, 0) 
            but:SetMouseInputEnabled(true)

            if tbl_menu_inv[i] then 
                but.item_data = tbl_menu_inv[i]
                but.color_outline = FROZE_GL.tbl_rarity_colors[but.item_data.rarity]
                but.has_item = true
            end 

            if category == "WEAPONS" then 
                if but.item_data.classname == GetConVar(gl .. "starting_weapon"):GetString() then 
                    but.item_data.equipped = true
                end
            end

            but.Paint = function(self, w, h) 
                local RFT = RealFrameTime() 
                draw.RoundedBox(0, 0, 0, w, h, FROZE_GL.tbl_inventory_menu.color_inventory_box)

                if self.item_data then  
                    surface.SetDrawColor(self.color_outline.r, self.color_outline.g, self.color_outline.b, 155)
                    surface.SetMaterial(FROZE_GL.mat_gradient_u)
                    surface.DrawTexturedRect(0, 0, w, h)

                    surface.SetDrawColor(255, 255, 255, 255)
                    if self.item_data.icon_mat then 
                        surface.SetMaterial(self.item_data.icon_mat)
                    end

                    local label_val1 = self.item_data.amount or 0

                    if category == "CONSUMABLES" then 
                        surface.DrawTexturedRect(0, 0, w, h) 
                    elseif category == "MATERIALS" then 
                        surface.DrawTexturedRect(w * 0.5 - w * 0.25, h * 0.5 - h * 0.25, w * 0.5, h * 0.5)
 
                        if self.item_data.is_ore then 
                            self.item_data.amount = ply:GetNWInt(gl .. "held_num_material_" .. self.item_data.rarity)
                        elseif self.item_data.is_currency then 
                            self.item_data.amount = ply:GetNWInt(gl .. "money", 0)
                        elseif self.item_data.is_material then 
                            self.item_data.amount = ply:GetNWInt(gl .. "held_num_material_" .. self.item_data.id)
                        end

                        label_val1 = self.item_data.amount
                    elseif category == "WEAPONS" then  
                        surface.DrawTexturedRect(0, 0, w, h)  
                        label_val1 = self.item_data.power .. " PWR"
                    end

                    draw.RoundedBox(0, 0, h * 0.8, w, h * 0.2, self.color_item_amount_bg)
                    draw.SimpleText(label_val1, gl .. "font_subtitle", w * 0.5, h * 0.9, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    --* additional drawings for weapons
                    if category == "WEAPONS" then  
                        for i = 1, 5 do  
                            surface.SetDrawColor(255, 255, 255) 

                            if self.item_data.stars >= i then
                                surface.SetMaterial(FROZE_GL.mat_star_yellow)
                            else
                                surface.SetMaterial(FROZE_GL.mat_star_gray)
                            end

                            surface.DrawTexturedRect((w * 0.15 * i) - w * 0.15 / 5, h * 0.03, w * 0.15, h * 0.15) 
                            local cur_needed_stars = 0

                            for i2 = 1 + self.item_data.stars, i do 
                                cur_needed_stars = cur_needed_stars + i2
                            end

                            if self.item_data.owned_fragments >= cur_needed_stars and self.item_data.stars < i then 
                                surface.SetDrawColor(255, 255, 255, math.abs(math.cos(CurTime() * 2) * 200))
                                surface.SetMaterial(FROZE_GL.mat_star_yellow)
                                surface.DrawTexturedRect((w * 0.15 * i) - w * 0.15 / 5, h * 0.03, w * 0.15, h * 0.15)
                            end
                        end
                        --* owned fragments amount 
                        draw.SimpleText("(x" .. self.item_data.owned_fragments .. " Owned)", gl .. "font_subtitle_small", w * 0.5, h * 0.23, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                        if not self.item_data.owned then 
                            draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(color_black, 200)) 
                        end 

                        if self.item_data.equipped then 
                            draw.SimpleText("EQUIPPED", gl .. "font_subtitle_small", w * 0.5, h * 0.72, ColorAlpha(color_yellow, math.abs(math.cos(CurTime() * 1.5) * 80) + 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end

                        if self.overlay_upgrade_color.a > 0 then 
                            draw.RoundedBox(0, 0, 0, w, h, self.overlay_upgrade_color) 
                            self.overlay_upgrade_color.a = math.max(0, self.overlay_upgrade_color.a - RFT * 1020)
                        end
                    end

                    if self:IsHovered() then 
                        prompt:Show()

                        if not prompt.item_clicked then 
                            prompt:SetPos(input.GetCursorPos())
                            prompt:SetX(prompt:GetX() + 10)
                            prompt:SetY(prompt:GetY() + 15)
                        end

                        prompt:SetTall(H * 0.2)
                        prompt:MakePopup()
                        prompt.hovered_panel = self
                    end
                end

                surface.SetDrawColor(self.color_outline.r, self.color_outline.g, self.color_outline.b, self.color_outline.a)
                surface.DrawOutlinedRect(0, 0, w, h, 1)

                if self:IsDown() and self:IsHovered() then  
                    self.color_highlight.a = 100      
                elseif self:IsHovered() and not self:IsDown() then 
                    self.color_highlight.a = math.min(40, self.color_highlight.a + RFT * 455)
                else
                    self.color_highlight.a = math.max(0, self.color_highlight.a - RFT * 455) 
                end 

                draw.RoundedBox(0, 0, 0, w, h, self.color_highlight)
                surface.SetDrawColor(255, 255, 255, 255)
            end

            but.DoClick = function(self, w, h)
                -- print("getting clicekd")   
                if category == "MATERIALS" then return end 
                
                if not prompt.item_clicked then     
                    if category == "CONSUMABLES" then 
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
                            draw.RoundedBox(0, 0, 0, w, h, prompt.color)                    

                            if self:IsHovered() and not self:IsDown() then                                 
                                self.color_highlight.a = math.min(50, self.color_highlight.a + RFT * 355)
                            elseif self:IsDown() then 
                                self.color_highlight.a = math.min(100, self.color_highlight.a + RFT * 555)
                            else
                                self.color_highlight.a = math.max(0, self.color_highlight.a - RFT * 355) 
                            end             

                            draw.SimpleText("OPEN (x" .. prompt.hovered_panel.item_data.amount .. ")", gl .. "font_subtitle", w * 0.05, h * 0.1, color_white, TEXT_ALIGN_LEFT)
                            
                            surface.SetDrawColor(255, 255, 255)
                            surface.DrawOutlinedRect(0, 0, w, h, 1)

                            draw.RoundedBox(0, 0, 0, w, h, self.color_highlight)
                        end

                        prompt.button_open.DoClick = function(self)  
                            local chest_drops = but.item_data.chest_drops 
                            -- PrintTable(chest_drops)
                            -- PrintTable(FROZE_GL.tbl_valid_inventory_items)

                            --? for some reason the :Roll() function doesnt carry over to the item_data tbl after being copied from the original FROZE_GL.tbl_valid_inventory_items somewhere in cl_garlic_like.lua ...
                            --? so lets get the table directly here...
                            for k, v in pairs(FROZE_GL.tbl_valid_inventory_items) do 
                                if v.name == but.item_data.name then 
                                    chest_drops = v.chest_drops
                                    break 
                                end
                            end

                            ply.gl_temp_chest_rewards = {}

                            -- PrintTable(but.item_data)

                            local obtained_gold, obtained_material_num, obtained_stat_scroll_num = 0, 0, 0 

                            for i = 1, but.item_data.amount do 
                                obtained_gold = obtained_gold + math.random(chest_drops.gold.min, chest_drops.gold.max)
                                obtained_stat_scroll_num = obtained_stat_scroll_num + math.random(chest_drops.stat_scroll.min, chest_drops.stat_scroll.max)
                                obtained_material_num = obtained_material_num + math.random(chest_drops.material_drop_amount.min, chest_drops.material_drop_amount.max)
                            end

                            -- print("OBTAINED MAT NUM: ", obtained_material_num)

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

                            --* reset the amount of materials obtained for each material
                            for k, v in pairs(FROZE_GL.tbl_menu_inventory_items_data) do  
                                ply:SetNWInt(gl .. "obtained_mat_" .. k, 0) 
                            end

                            -- print("---") 
                            -- print("FROZE_GL.rarity_weights_sum_gems " .. FROZE_GL.rarity_weights_sum_gems)
                            
                            for i = 1, obtained_material_num do  
                                local drop_name = chest_drops.drop_weights:Roll()["name"] 
                                -- print("DROP NAME:", drop_name)
                                ply:SetNWInt(gl .. "obtained_mat_" .. drop_name, ply:GetNWInt(gl .. "obtained_mat_" .. drop_name, 0) + 1)  
                            end 

                            --* put the amount of mats gathered of each rarity into the table seperately
                            for k, v in pairs(FROZE_GL.tbl_menu_inventory_items_data) do 
                                if ply:GetNWInt(gl .. "obtained_mat_" .. k) > 0 then 
                                    ply.gl_temp_chest_rewards[#ply.gl_temp_chest_rewards + 1] = {
                                        name = v.name, 
                                        id = k,
                                        rarity = v.rarity,
                                        icon_mat = v.icon_mat,
                                        amount = ply:GetNWInt(gl .. "obtained_mat_" .. k),
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
                    elseif category == "WEAPONS" then 
                        prompt.item_clicked = true 
                        prompt:SetTall(prompt:GetTall() + H * 0.025)

                        prompt.button_upgrade = vgui.Create("DButton", prompt, "prompt_button_open") 
                        prompt.button_upgrade:SetText("")
                        prompt.button_upgrade:SetSize(prompt:GetWide(), H * 0.025)
                        prompt.button_upgrade:Dock(TOP)                        
                        prompt.button_upgrade.color_highlight = Color(255, 255, 255, 0) 

                        prompt:SetPos(input.GetCursorPos())
                        prompt:SetX(prompt:GetX() - prompt:GetWide() * 0.5)
                        prompt:SetY(prompt:GetY() - 5)

                        prompt.button_upgrade.Paint = function(self, w, h) 
                            local RFT = RealFrameTime()        
                            draw.RoundedBox(0, 0, 0, w, h, prompt.color)                    

                            if self:IsHovered() and not self:IsDown() then                                 
                                self.color_highlight.a = math.min(50, self.color_highlight.a + RFT * 355)
                            elseif self:IsDown() then 
                                self.color_highlight.a = math.min(100, self.color_highlight.a + RFT * 555)
                            else
                                self.color_highlight.a = math.max(0, self.color_highlight.a - RFT * 355) 
                            end             

                            draw.SimpleText("UPGRADE", gl .. "font_subtitle", w * 0.05, h * 0.1, color_white, TEXT_ALIGN_LEFT)
                            
                            surface.SetDrawColor(255, 255, 255)
                            surface.DrawOutlinedRect(0, 0, w, h, 1)

                            draw.RoundedBox(0, 0, 0, w, h, self.color_highlight)
                        end

                        prompt.button_upgrade.DoClick = function(self)    
                            local upgrade_cost = (but.item_data.stars + 1)
                            
                            if but.item_data.owned_fragments < upgrade_cost or but.item_data.stars >= 5 then 
                                -- print("invalid upgrade!")
                                return 
                            end

                            surface.PlaySound("garlic_like/wep_star_upgrade1.wav")

                            but.item_data.owned_fragments = but.item_data.owned_fragments - upgrade_cost
                            but.item_data.stars = math.min(5, but.item_data.stars + 1)
                            but.overlay_upgrade_color.a = 255

                            but.screen_pos_x, but.screen_pos_y = but:LocalToScreen(0, 0)

                            overlay_sparkles[#overlay_sparkles + 1] = {
                                sparkles = {},
                            }

                            local x_mod = 0

                            x_mod = (but:GetWide() * 0.15 * (but.item_data.stars))

                            for i = 1, 30 do 
                                overlay_sparkles[#overlay_sparkles].sparkles[i] = {
                                    x = but.screen_pos_x + x_mod, 
                                    y = but.screen_pos_y + but:GetTall() * 0.03 + but:GetTall() * 0.15, 
                                    vel_x = math.Rand(-W * 0.0015, W * 0.0015),
                                    vel_y = math.Rand(W * 0.0012, W * 0.0036),
                                    alpha = math.Rand(150, 255),
                                }
                            end
                        end  

                        prompt.button_equip = vgui.Create("DButton", prompt, "prompt_button_equip") 
                        prompt.button_equip:SetText("")
                        prompt.button_equip:SetSize(prompt:GetWide(), H * 0.025)
                        prompt.button_equip:Dock(TOP)                        
                        prompt.button_equip.color_highlight = Color(255, 255, 255, 0)

                        prompt:SetPos(input.GetCursorPos())
                        prompt:SetX(prompt:GetX() - prompt:GetWide() * 0.5)
                        prompt:SetY(prompt:GetY() - 5)

                        prompt.button_equip.Paint = function(self, w, h)
                            local RFT = RealFrameTime()        
                            draw.RoundedBox(0, 0, 0, w, h, prompt.color)                    

                            if self:IsHovered() and not self:IsDown() then                                 
                                self.color_highlight.a = math.min(50, self.color_highlight.a + RFT * 355)
                            elseif self:IsDown() then 
                                self.color_highlight.a = math.min(100, self.color_highlight.a + RFT * 555)
                            else
                                self.color_highlight.a = math.max(0, self.color_highlight.a - RFT * 355) 
                            end             

                            draw.SimpleText("EQUIP", gl .. "font_subtitle", w * 0.05, h * 0.1, color_white, TEXT_ALIGN_LEFT)
                            
                            surface.SetDrawColor(255, 255, 255)
                            surface.DrawOutlinedRect(0, 0, w, h, 1)

                            draw.RoundedBox(0, 0, 0, w, h, self.color_highlight)
                        end

                        prompt.button_equip.DoClick = function(self)
                            GetConVar(gl .. "starting_weapon"):SetString(but.item_data.classname)

                            if but.item_data.owned then 
                                surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")

                                for k, v in pairs(tbl_menu_inv) do 
                                    v.equipped = false 
                                end

                                but.item_data.equipped = true
                            else 
                                surface.PlaySound("garlic_like/disgaea_buterror.wav")
                            end
                        end

                        prompt.hoverable_panels = {
                            [1] = prompt,
                            [2] = prompt.hovered_panel,
                            [3] = prompt.panel_name,
                            [4] = prompt.button_upgrade,
                            [5] = prompt.button_equip,
                        }
                    end
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
        surface.PlaySound("garlic_like/disgaea_butback.wav") 

        ply:GLSaveObtainedWeapons()
        
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
        if not IsValid(bf) or not bf.panel_color then return end 
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

    bcgc.Paint = function(self, w, h) 
        draw_cat_but("GEM CONVERT", w, h)
    end

    bcw.Paint = function(self, w, h) 
        draw_cat_but("WEAPONS", w, h)
    end

    bcc.DoClick = function(self) 
        if IsValid(ply.gl_gem_conversion_bf_panel) then 
            ply.gl_gem_conversion_bf_panel.bt_exit:DoClick()
        end
        
        create_inv_grid("RESET", nil, "CONSUMABLES")
        bf.item_cat = "CONSUMABLES"
    end

    bcm.DoClick = function(self) 
        if IsValid(ply.gl_gem_conversion_bf_panel) then 
            ply.gl_gem_conversion_bf_panel.bt_exit:DoClick()
        end

        create_inv_grid("RESET", nil, "MATERIALS")
        bf.item_cat = "MATERIALS"
    end

    bcgc.DoClick = function(self) 
        ply.gl_inventory_bf_panel = bf
        ply.gl_inventory_bt_exit_panel = bt_exit
        bf:Hide()
        bt_exit:Hide()
        bf.item_cat = "GEM CONVERT"
        RunConsoleCommand("garlic_like_debug_open_gem_conversion")
    end

    bcw.DoClick = function(self) 
        if IsValid(ply.gl_gem_conversion_bf_panel) then 
            ply.gl_gem_conversion_bf_panel.bt_exit:DoClick()
        end

        -- print("WEAPONS TBL OBTAINED !!!")
        -- PrintTable(FROZE_GL.tbl_menu_inventory.obtained_weapons)
 
        --! create weapons inventory

        create_inv_grid("RESET", nil, "WEAPONS")
        bf.item_cat = "WEAPONS" 
    end

    bt_exit.Paint = function(self, w, h) 
        draw.RoundedBox(6, 0, 0, w, h, color_black_alpha_150) 
        draw.DrawText("X", gl .. "font_title", w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)

        garlic_like_save_menu_inventory() 
        garlic_like_give_hover_sounds(self, "garlic_like/disgaea5_item_hovered.wav")
    end
end

function garlic_like_open_unlockables_menu() 
    local bf = vgui.Create("DPanel") 
    bf:SetSize(W * 0.45, H * 0.85) 
    bf:CenterHorizontal() 
    bf:CenterVertical(0.55) 
    local bf_w, bf_h = bf:GetWide(), H * 0.5
    bf.panel_color = Color(61, 61, 61)

    local bt_exit = vgui.Create("DButton") 
    bt_exit:SetY(bf:GetY())
    bt_exit:MoveRightOf(bf, W * 0.01)
    bt_exit:SetText("") 
    bt_exit:SetSize(W * 0.03, W * 0.03)

    bt_exit.DoClick = function(self) 
        SafeRemovePanel(bf)
        SafeRemovePanel(self)
        surface.PlaySound("garlic_like/disgaea_butback.wav") 
        
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
            draw.RoundedBox(0, 0, 0, w, h, color_black)
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
            draw.RoundedBox(0, 0, 0, w, h, color_black)
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
            draw.RoundedBox(0, 0, 0, w, h, color_black)
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
        surface.PlaySound("garlic_like/disgaea_butback.wav") 
        
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
    background.is_gl_panel = true

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
    logo.is_gl_panel = true

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

    local rank_info = vgui.Create("DPanel", nil, gl .. "rank_info_panel") 
    rank_info:SetSize(W * 0.15, H * 0.1) 
    rank_info:SetPos(W * 0.825, -H * 0.1) 
    rank_info:MoveTo(W * 0.825, H * 0.05, 0.25, 0, -1, function() end)
    rank_info.color1 = Color(255, 174, 0)
    rank_info.is_gl_panel = true
    rank_info.Paint = function(self, w, h) 
        draw.RoundedBox(0, 0, 0, w, h, color_black_alpha_200) 
        draw.DrawText("RANK: " .. ply:GetNWInt(gl .. "rank_num", 0), gl .. "font_title", w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)
        draw.RoundedBox(0, w * 0.125, H * 0.047, w * 0.75, H * 0.015, color_black_alpha_150)
        draw.RoundedBox(0, w * 0.125, H * 0.047, math.Remap(ply:GetNWInt(gl .. "rank_xp_current", 0), 0, ply:GetNWInt(gl .. "rank_xp_to_rank_up", 0), 0, w * 0.75), H * 0.015, self.color1)
        draw.DrawText(ply:GetNWInt(gl .. "rank_xp_current", 0) .. "/" .. ply:GetNWInt(gl .. "rank_xp_to_rank_up", 0), gl .. "font_title_3", w * 0.5, H * 0.06, color_white, TEXT_ALIGN_CENTER)
    end 

    local shop_base_panel = vgui.Create("DPanel", nil, gl .. "shop_base_dpanel")
    shop_base_panel:SetName(gl .. "shop_base_dpanel")
    shop_base_panel:MakePopup(true)
    shop_base_panel:SetSize(0, 0)
    shop_base_panel:CenterHorizontal() 
    shop_base_panel:CenterVertical(0.55)
    shop_base_panel.isAnimating = true
    shop_base_panel.is_gl_panel = true

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
 
        rank_info:MoveTo(W * 0.825, -H * 0.1, 0.15, 0, -1, function() end)

        shop_base_panel:SizeTo(0, 0, 0.15, 0, 0.5, function()
            shop_base_panel.isAnimating = false
            SafeRemovePanels(shop_base_panel, background, logo, rank_info)
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
                        -- ply:ConCommand(gl .. "debug_open_weapon_chest") -- disabled now bcs we have weapon inventory system
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
        [gl .. "button_summoning"] = {
            doclick = function(self) 
                surface.PlaySound("garlic_like/disgaea5_item_clicked.wav")
 
                shop_base_panel:Hide()

                garlic_like_open_summoning_menu(shop_base_panel)
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
    create_button("button_summoning", "SUMMONING")
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

            --* setup and weapon getting
            if wep_choice.fade_in_transparency == nil then
                wep_choice.fade_in_transparency = 255
                wep_choice.highlight_transparency = 10
                wep_choice.icon_set = false
                wep_choice.facing = "FRONT"
                wep_choice:SetTooltip("PRESS RMB TO SWAP INFO")
                -- directly manipualtes the panel without returning
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

                local y_mod1 = h * 0.055

                --* draw stars

                local obtained_wep_data = {}

                for k2, wep_data in pairs(FROZE_GL.tbl_menu_inventory.obtained_weapons) do 
                    if wep_data.classname == self.wep.ClassName then 
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

                        surface.DrawTexturedRect((w * 0.1 * (i - 1)) + w * 0.5 - (w * 0.1 * 5) / 2, h * 0.51, w * 0.1, w * 0.1)  
                    end
                end

                if self.facing == "FRONT" and self.wep_bonuses_amount > 0 then
                    draw.DrawText("When held :", gl .. "font_subtitle", w * 0.5, h * 0.52 + y_mod1, color_white, TEXT_ALIGN_CENTER)

                    for i = 1, self.wep_bonuses_amount do
                        gl_cse(ply, w * 0.5, (h * 0.55) + (i * h * 0.05) + y_mod1, 100 * self.wep_bonuses[i].modifier, "%", self.wep_bonuses[i].desc, true, false, "", false, gl .. "font_subtitle", nil, true)
                    end
                elseif self.facing == "BACK" then 
                    draw.DrawText("RARITY BASE STATS MODIFIER", gl .. "font_subtitle", w * 0.5, h * 0.52 + y_mod1, color_white, TEXT_ALIGN_CENTER) 
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

                    -- PrintTable(wep)
                    
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
                    
                    gl_cse(ply, w * 0.5, (h * 0.55) + (1 * h * 0.05) + y_mod1, power, " ", "POWER", true, false, "", false, gl .. "font_subtitle", color_text, true)
                    gl_cse(ply, w * 0.5, (h * 0.55) + (2 * h * 0.05) + y_mod1, "x" .. base_mod_num, " ", "BASE STATS", true, false, "", false, gl .. "font_subtitle", color_text, true)

                    color_text = nil

                    --* if it's a tfa melee
                    if is_tfa_melee then  
                        gl_cse(ply, w * 0.5, (h * 0.55) + (3 * h * 0.05) + y_mod1, "", dmg_melee_1, " LMB DMG", true, false, "", false, gl .. "font_subtitle", color_text, true)
                        gl_cse(ply, w * 0.5, (h * 0.55) + (4 * h * 0.05) + y_mod1, "", aspd_1, " LMB ASPD", true, false, "", false, gl .. "font_subtitle", color_text, true)
                        gl_cse(ply, w * 0.5, (h * 0.55) + (5 * h * 0.05) + y_mod1, "", range_1, " LMB RAMGE", true, false, "", false, gl .. "font_subtitle", color_text, true)
                        gl_cse(ply, w * 0.5, (h * 0.55) + (6 * h * 0.05) + y_mod1, "", dmg_melee_2, " RMB DMG", true, false, "", false, gl .. "font_subtitle", color_text, true)                                
                        gl_cse(ply, w * 0.5, (h * 0.55) + (7 * h * 0.05) + y_mod1, "", aspd_2, " RMB ASPD", true, false, "", false, gl .. "font_subtitle", color_text, true)                                
                        gl_cse(ply, w * 0.5, (h * 0.55) + (8 * h * 0.05) + y_mod1, "", range_2, " RMB RAMGE", true, false, "", false, gl .. "font_subtitle", color_text, true)
                    else --* if it's a gun
                        gl_cse(ply, w * 0.5, (h * 0.55) + (3 * h * 0.05) + y_mod1, "", dmg .. text_numshot, " DMG", true, false, "", false, gl .. "font_subtitle", color_text, true)
                        gl_cse(ply, w * 0.5, (h * 0.55) + (4 * h * 0.05) + y_mod1, "", rpm, " RPM", true, false, "", false, gl .. "font_subtitle", color_text, true)
                        gl_cse(ply, w * 0.5, (h * 0.55) + (5 * h * 0.05) + y_mod1, "", magcap, " MAG CAP", true, false, "", false, gl .. "font_subtitle", color_text, true)
                        gl_cse(ply, w * 0.5, (h * 0.55) + (6 * h * 0.05) + y_mod1, "x", base_mod_num, " RELOAD", true, false, "", false, gl .. "font_subtitle", color_text, true)        
                        gl_cse(ply, w * 0.5, (h * 0.55) + (7 * h * 0.05) + y_mod1, "x", recoil, " RECOIL", true, false, "", false, gl .. "font_subtitle", color_text, true)        
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
                            
                        -- sbw is stored bonus weapon
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
                            wep_already_held.wep_element_tier = self.sbw.element_tier
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

                garlic_like_store_wep_bonuses(ply, wep_choice)

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