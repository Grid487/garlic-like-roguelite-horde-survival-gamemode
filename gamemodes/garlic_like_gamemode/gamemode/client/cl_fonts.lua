if SERVER then return end 

FROZE_GL = FROZE_GL or {}
--
local gl = "garlic_like_"
gold_notification_font = "Default"

timer.Simple(0.5, function()
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

        surface.CreateFont(gl .. "font_element_tiers_tooltip", {
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

        surface.CreateFont(gl .. "font_element_tier_indicator", {
            font = GetConVar(gl .. "hud_font"):GetString(),
            extended = false,
            size = H * 0.015,
            weight = 800,
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

    garlic_like_create_fonts()
end)