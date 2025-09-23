if SERVER then return end 
  
FROZE_GL = FROZE_GL or {}
--
local gl = "garlic_like_"
local rh = "relic_held_"
 
timer.Simple(1, function()
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

    function GetWeaponIcon(weapon)
        -- Check direct WepSelectIcon
        if weapon.WepSelectIcon then
            return weapon.WepSelectIcon
        end
        
        -- Check killicon
        local kiIcon = killicon.GetIcon(weapon.ClassName)
        if kiIcon then
            return kiIcon
        end
        
        -- Try standard path
        local standardPath = "vgui/hud/" .. weapon.ClassName
        local icon = surface.GetTextureID(standardPath)
        if icon then
            return icon
        end
        
        -- Check for IconLetter (CSS weapons)
        if weapon.IconLetter then
            return surface.GetTextureID("hl2_weapons/w_icons/" .. weapon.IconLetter)
        end
        
        -- Fallback to default weapon icon
        return surface.GetTextureID("weapons/swep")
    end

    function garlic_like_num_to_roman(num)
        if type(num) ~= "number" or num < 1 or num > 3999 or math.floor(num) ~= num then
            return ""
        end

        local romanMap = {
            { value = 1000, numeral = "M" }, { value = 900, numeral = "CM" },
            { value = 500,  numeral = "D" }, { value = 400, numeral = "CD" },
            { value = 100,  numeral = "C" }, { value = 90,  numeral = "XC" },
            { value = 50,   numeral = "L" }, { value = 40,  numeral = "XL" },
            { value = 10,   numeral = "X" }, { value = 9,   numeral = "IX" },
            { value = 5,    numeral = "V" }, { value = 4,   numeral = "IV" },
            { value = 1,    numeral = "I" }
        }

        local result = ""

        for _, pair in ipairs(romanMap) do
            while num >= pair.value do
                result = result .. pair.numeral
                num = num - pair.value
            end
        end

        return result
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

    function garlic_like_draw_wmt(text, font, x, y, maxWidth, defaultColor)
        surface.SetFont(font)
        local lineHeight = select(2, surface.GetTextSize("W"))
        local curY = y
        local curX = x
        
        -- Parse text into segments with color information
        local function parseText(str)
            local segments = {}
            local currentPos = 1
            
            while true do
                -- Find next color tag
                local tagStart, tagEnd = string.find(str, "<c=[^>]+>", currentPos)
                
                if not tagStart then
                    -- Add remaining text as a segment with default color
                    if currentPos <= #str then
                        table.insert(segments, {
                            text = string.sub(str, currentPos),
                            color = defaultColor
                        })
                    end
                    break
                end
                
                -- Add text before tag with default color
                if tagStart > currentPos then
                    table.insert(segments, {
                        text = string.sub(str, currentPos, tagStart - 1),
                        color = defaultColor
                    })
                end
                
                -- Parse color from tag
                local colorStr = string.match(str, "<c=([^>]+)>", currentPos)
                local color = defaultColor
                
                if string.find(colorStr, ",") then
                    -- RGB color
                    local r, g, b = string.match(colorStr, "(%d+),(%d+),(%d+)")
                    color = Color(tonumber(r), tonumber(g), tonumber(b))
                else
                    -- Named color
                    color = FROZE_GL.tbl_named_colors[colorStr] or defaultColor
                end
                
                -- Find closing tag
                local contentStart = tagEnd + 1
                local contentEnd = string.find(str, "</c>", contentStart)
                
                if not contentEnd then
                    -- No closing tag found, treat rest of string as content
                    contentEnd = #str
                end
                
                -- Add colored segment
                table.insert(segments, {
                    text = string.sub(str, contentStart, contentEnd - 1),
                    color = color
                })
                
                currentPos = contentEnd + 4 -- Skip </c>
            end
            
            return segments
        end
        
        local segments = parseText(text)
        local currentLine = {}
        local currentLineWidth = 0
        
        local function drawCurrentLine()
            local drawX = x
            for _, segment in ipairs(currentLine) do
                surface.SetTextColor(segment.color)
                surface.SetTextPos(drawX, curY)
                surface.DrawText(segment.text)
                drawX = drawX + surface.GetTextSize(segment.text)
            end
            curY = curY + lineHeight
            currentLine = {}
            currentLineWidth = 0
        end
        
        -- Process each segment
        for _, segment in ipairs(segments) do
            local words = string.Explode(" ", segment.text)
            
            for i, word in ipairs(words) do
                local wordWidth = surface.GetTextSize(word)
                
                if currentLineWidth + wordWidth > maxWidth then
                    drawCurrentLine()
                end
                
                if #currentLine > 0 then
                    -- Add space between words
                    local spaceWidth = surface.GetTextSize(" ")
                    if currentLineWidth + spaceWidth + wordWidth <= maxWidth then
                        table.insert(currentLine, {text = " ", color = segment.color})
                        currentLineWidth = currentLineWidth + spaceWidth
                    else
                        drawCurrentLine()
                    end
                end
                
                table.insert(currentLine, {text = word, color = segment.color})
                currentLineWidth = currentLineWidth + wordWidth
            end
        end
        
        -- Draw final line
        if #currentLine > 0 then
            drawCurrentLine()
        end
        
        return curY - y -- Return total height
    end

    do 
        local TEXT_ALIGN_LEFT = "left"
        local TEXT_ALIGN_CENTER = "center"
        local TEXT_ALIGN_RIGHT = "right"

        function garlic_like_draw_wmt2(text, font, x, y, maxWidth, defaultColor, options)
            options = options or {}
            local textAlign = options.textAlign or TEXT_ALIGN_LEFT
            local bgColor = options.bgColor

            surface.SetFont(font)
            local _, lineHeight = surface.GetTextSize("W")
            local curY = y
            
            local function parseText(str)
                local segments = {}
                local currentPos = 1
                
                local namedColorsTable = {}
                if FROZE_GL and FROZE_GL.tbl_named_colors then
                    namedColorsTable = FROZE_GL.tbl_named_colors
                end

                while true do
                    local tagStart, tagEndMatchPos = string.find(str, "<c=[^>]+>", currentPos)
                    
                    if not tagStart then
                        if currentPos <= #str then
                            table.insert(segments, {
                                text = string.sub(str, currentPos),
                                color = defaultColor
                            })
                        end
                        break
                    end
                    
                    if tagStart > currentPos then
                        table.insert(segments, {
                            text = string.sub(str, currentPos, tagStart - 1),
                            color = defaultColor
                        })
                    end
                    
                    local colorStr = string.match(str, "<c=([^>]+)>", tagStart)
                    local segmentColor = defaultColor
                    
                    if string.find(colorStr, ",") then
                        local r, g, b = string.match(colorStr, "(%d+),(%d+),(%d+)")
                        if r and g and b then
                            segmentColor = Color(tonumber(r), tonumber(g), tonumber(b))
                        end
                    else
                        segmentColor = namedColorsTable[colorStr] or defaultColor
                    end
                    
                    local contentStart = tagEndMatchPos + 1
                    local closeTagStart = string.find(str, "</c>", contentStart)
                    
                    local textContent
                    if not closeTagStart then
                        textContent = string.sub(str, contentStart)
                        currentPos = #str + 1
                    else
                        textContent = string.sub(str, contentStart, closeTagStart - 1)
                        currentPos = closeTagStart + #("</c>")
                    end

                    table.insert(segments, {
                        text = textContent,
                        color = segmentColor
                    })
                    
                    if currentPos > #str then break end
                end
                return segments
            end
            
            local parsedSegments = parseText(text)
            
            local lines = {}
            local currentLineSegments = {}
            local currentLineWidth = 0
            local spaceWidth = surface.GetTextSize(" ")

            for _, segment in ipairs(parsedSegments) do
                local words = string.Explode(" ", segment.text) 
                
                for wordIndex, word in ipairs(words) do
                    if word == "" then
                        if #currentLineSegments > 0 then
                            local lastSeg = currentLineSegments[#currentLineSegments]
                            if lastSeg.text ~= " " then
                                if currentLineWidth + spaceWidth <= maxWidth then
                                    table.insert(currentLineSegments, {text = " ", color = segment.color, isSpace = true})
                                    currentLineWidth = currentLineWidth + spaceWidth
                                else
                                    table.insert(lines, {segments = currentLineSegments, width = currentLineWidth})
                                    currentLineSegments = {}
                                    currentLineWidth = 0
                                end
                            end
                        end
                        goto continue_word_loop
                    end

                    local wordText = word
                    local wordWidth = surface.GetTextSize(wordText)
                    
                    local needsSpaceBeforeWord = (#currentLineSegments > 0)
                    if needsSpaceBeforeWord then
                        local lastSeg = currentLineSegments[#currentLineSegments]
                        if lastSeg.isSpace then needsSpaceBeforeWord = false end
                    end

                    local testWidth = currentLineWidth
                    if needsSpaceBeforeWord then testWidth = testWidth + spaceWidth end
                    testWidth = testWidth + wordWidth

                    if testWidth > maxWidth and #currentLineSegments > 0 then
                        table.insert(lines, {segments = currentLineSegments, width = currentLineWidth})
                        currentLineSegments = {}
                        currentLineWidth = 0
                        needsSpaceBeforeWord = false
                    end
                    
                    if needsSpaceBeforeWord then
                        table.insert(currentLineSegments, {text = " ", color = segment.color, isSpace = true})
                        currentLineWidth = currentLineWidth + spaceWidth
                    end
                    
                    if currentLineWidth + wordWidth <= maxWidth or #currentLineSegments == 0 then
                        table.insert(currentLineSegments, {text = wordText, color = segment.color})
                        currentLineWidth = currentLineWidth + wordWidth
                    else 
                        if #currentLineSegments > 0 then
                            table.insert(lines, {segments = currentLineSegments, width = currentLineWidth})
                        end
                        currentLineSegments = {{text = wordText, color = segment.color}}
                        currentLineWidth = wordWidth
                    end
                    ::continue_word_loop::
                end
            end
            
            if #currentLineSegments > 0 then
                table.insert(lines, {segments = currentLineSegments, width = currentLineWidth})
            end

            if #lines == 0 and text ~= "" and string.Trim(text) == "" then
                table.insert(lines, {segments = {}, width = 0})
            end
            
            local totalHeight = 0
            for _, lineInfo in ipairs(lines) do
                local lineSegmentsToDraw = lineInfo.segments
                local actualTextContentWidth = lineInfo.width 

                local currentLineDrawableSegments = {}
                for _, s in ipairs(lineSegmentsToDraw) do table.insert(currentLineDrawableSegments, s) end
                
                local tempActualTextContentWidth = actualTextContentWidth
                while #currentLineDrawableSegments > 0 do
                    local lastSegment = currentLineDrawableSegments[#currentLineDrawableSegments]
                    if lastSegment.isSpace or lastSegment.text == " " then
                        tempActualTextContentWidth = tempActualTextContentWidth - surface.GetTextSize(lastSegment.text)
                        table.remove(currentLineDrawableSegments)
                    else
                        break
                    end
                end
                actualTextContentWidth = math.max(0, tempActualTextContentWidth)

                if bgColor then
                    surface.SetDrawColor(bgColor)
                    surface.DrawRect(x, curY, maxWidth, lineHeight)
                end

                if #currentLineDrawableSegments == 0 then
                    curY = curY + lineHeight
                    totalHeight = totalHeight + lineHeight
                    goto continue_drawing_lines
                end
                
                local textRenderStartX = x
                if textAlign == TEXT_ALIGN_CENTER then
                    textRenderStartX = x + (maxWidth - actualTextContentWidth) / 2
                elseif textAlign == TEXT_ALIGN_RIGHT then
                    textRenderStartX = x + maxWidth - actualTextContentWidth
                end
                
                local currentSegmentX = textRenderStartX
                for _, segment in ipairs(currentLineDrawableSegments) do
                    surface.SetTextColor(segment.color)
                    surface.SetTextPos(math.Round(currentSegmentX), math.Round(curY))
                    surface.DrawText(segment.text)
                    currentSegmentX = currentSegmentX + surface.GetTextSize(segment.text)
                end
                
                curY = curY + lineHeight
                totalHeight = totalHeight + lineHeight
                ::continue_drawing_lines::
            end
            
            return totalHeight
        end
    end

    function garlic_like_draw_item_label(tbl_ents) 
        for k, ent in pairs(tbl_ents) do 
            local iswep = ent:IsWeapon()
            
            if not iswep and not ent:GetNWBool(gl .. "settled_2") then continue end
            if not iswep and ent:GetNWBool(gl .. "is_being_picked_up") then continue end
            if iswep and IsValid(ent:GetOwner()) then continue end
            if iswep and not ent.IsTFA then continue end 

            -- print("ASDASDASD")
            
            local class = ent:GetClass()
            local angles = ply:EyeAngles()
            local obbcenter = ent:LocalToWorld(ent:OBBCenter())
            local basepos = ent:GetPos()
            local pos = Vector(basepos.x, basepos.y, basepos.z)
            local item_name = ent:GetNWString(gl .. "item_name", "")
            local rarity = ent:GetNWString(gl .. "item_rarity")
            local beam_start = pos + Vector(0, 0, 10)
            local beam_end = pos + Vector(0, 0, math.Remap(garlic_like_rarity_to_num(rarity), 1, 7, 100, 175))
            local tbl_wep = {}

            if iswep then 
                rarity = 1

                if FROZE_GL.gl_stored_bonused_weapons[class] then 
                    tbl_wep = FROZE_GL.gl_stored_bonused_weapons[class]
                    rarity = tbl_wep.rarity 
                end

                item_name = ent:GetPrintName() or class
            end
            
            local rarity_color = FROZE_GL.tbl_rarity_colors[rarity]

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

                draw.WordBox(4, 0, 0, item_name .. amount, gl .. "font_subtitle", color_black_alpha_200, rarity_color, TEXT_ALIGN_CENTER)
            else 
                if not rarity_color then 
                    rarity_color = color_white
                end
                
                local name = item_name

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

            -- PrintTable(FROZE_GL.tbl_anim_frame_id)
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

    function gl_get_text_size(text, font) 
        surface.SetFont(font)
        return surface.GetTextSize(text)
    end

    garlic_like_draw_animated_border_2dhook(w, h, mod_w, mod_h, mod_x, mod_y, "id_dota2_default", "dota2_default", 150, true) 
    garlic_like_draw_animated_border_2dhook(w, h, mod_w, mod_h, mod_x, mod_y, "id_dota2_god_rarity", "dota2_god_rarity", 150, true) 

    function tonumber_bool(bool) 
        if bool then 
            return 1
        else
            return 0
        end
    end 

    function outline_box(wide, height) 
        surface.SetDrawColor(255, 0, 0)
        surface.DrawOutlinedRect(0, 0, wide, height, 1)
    end 
end)

