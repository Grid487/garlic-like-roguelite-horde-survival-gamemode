local W = ScrW() 
local H = ScrH()
local size = math.Clamp(7.5, 5, 15) * 0.1
local scale = (ScrW() >= 2560 and size + 0.1) or (ScrW() / 175 >= 6 and size + 0.1) or 0.8
local CurTb = 0
local CurSlt = 1
local alpha = 0
local lastAction = -math.huge
local tblLoad = {}
local slide = {}
local newinv
local CurSwep = {}
local width = 200 * scale
local height = 25 * scale
local Marge = height / 4

local grad_h = 0

local x = 0
local hideElements = {
    ["CHudWeaponSelection"] = true
}
local tblFont = {}

gl_weapon_selector_showing = false

for _, y in pairs(file.Find("scripts/weapon_*.txt", "MOD")) do
    local t = util.KeyValuesToTable(file.Read("scripts/" .. y, "MOD"))

    CurSwep[y:match("(.+)%.txt")] = {
        Slot = t.bucket,
        SlotPos = t.bucket_position,
        TextureData = t.texturedata
    }
end

function WeaponSelector.Font(scales)
    local name = ("WeaponSelector.Fonts." .. tostring(scales))
    if tblFont[name] then return name end

    surface.CreateFont(name, {
        font = "Roboto",
        size = scales * scale,
        weight = 500 * scale,
        antialias = true,
        blursize = 0
    })

    tblFont[name] = true

    return name
end

local function GetCurSwep()
    if alpha <= 0 then 
        table.Empty(slide)
        local class = IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass()

        for k1, v1 in pairs(tblLoad) do
            for k2, v2 in pairs(v1) do
                if v2.classname == class then
                    CurTb = k1
                    CurSlt = k2

                    return
                end
            end
        end
    end
end

local function update()
    table.Empty(tblLoad)

    for k, v in pairs(LocalPlayer():GetWeapons()) do
        local classname = v:GetClass()
        local Slot = CurSwep[classname] and CurSwep[classname].Slot - 1 or v.Slot or 1
        tblLoad[Slot] = tblLoad[Slot] or {}

        table.insert(tblLoad[Slot], {
            classname = classname,
            name = v:GetPrintName(), 
            slotpos = CurSwep[classname] and CurSwep[classname].SlotPos - 1 or v.SlotPos or 1
        })
    end

    for k, v in pairs(tblLoad) do
        table.sort(v, function(a, b) return a.slotpos < b.slotpos end)
    end
end

hook.Add("OnScreenSizeChanged", "WeaponSelector.Hooks.OnScreenSizeChanged", function(oldWidth, oldHeight)
    scale = (ScrW() >= 2560 and size + 0.1) or (ScrW() / 175 >= 6 and size + 0.1) or 0.8
end)

hook.Add("CreateMove", "WeaponSelector.Hooks.CreateMove", function(cmd)
    if newinv then
        local wep = LocalPlayer():GetWeapon(newinv)

        if wep:IsValid() and LocalPlayer():GetActiveWeapon() ~= wep then
            cmd:SelectWeapon(wep)
        else
            newinv = nil
        end
    end
end)

hook.Add("PlayerBindPress", "WeaponSelector.Hooks.PlayerBindPress", function(ply, bind, pressed)
    if not pressed then return end
    bind = bind:lower() -- this takes binds, if you roll the mwheel down then you get invnext, if up then invprev
    if ply:InVehicle() then return end

    -- PrintTable(tblLoad) 
    -- tblLoad consists of your inventory / held weapons
    -- print("bind " .. bind)

    if string.sub(bind, 1, 4) == "slot" and not ply:KeyDown(IN_ATTACK) then
        local n = tonumber(string.sub(bind, 5, 5) or 1) or 1
        if n < 1 or n > 6 then return true end
        n = n - 1
        update()
        if not tblLoad[n] then return true end
        grad_h = 0

        GetCurSwep()

        if CurTb == n and tblLoad[CurTb] and (alpha > 0 or GetConVarNumber("hud_fastswitch") > 0) then
            CurSlt = CurSlt + 1

            if CurSlt > #tblLoad[CurTb] then
                CurSlt = 1
            end
        else
            CurTb = n
            CurSlt = 1
        end

        if GetConVarNumber("hud_fastswitch") > 0 then
            newinv = tblLoad[CurTb][CurSlt].classname
        else
            lastAction = RealTime()
            alpha = 1
        end

        return true
    elseif bind == "invnext" and not ply:KeyDown(IN_ATTACK) then
        update()
        if #tblLoad < 1 then return true end
        grad_h = 0

        GetCurSwep() -- getcurswep makes it so that when invnext is inputted, the highlight starts at your currently held weapon
        CurSlt = CurSlt + 1

        -- CurTb is the category / column 

        if CurSlt > (tblLoad[CurTb] and #tblLoad[CurTb] or -1) then -- if current highlighted slot moves over to the next column
            
            repeat
                CurTb = CurTb + 1

                if CurTb > 5 then
                    CurTb = 0
                end
            until tblLoad[CurTb]
            CurSlt = 1
        end

        if GetConVarNumber("hud_fastswitch") > 0 then
            newinv = tblLoad[CurTb][CurSlt].classname
        else
            lastAction = RealTime()
            alpha = 1
        end

        return true
    elseif bind == "invprev" and not ply:KeyDown(IN_ATTACK) then
        update()
        if #tblLoad < 1 then return true end
        grad_h = 0

        GetCurSwep()
        CurSlt = CurSlt - 1

        if CurSlt < 1 then
            repeat
                CurTb = CurTb - 1

                if CurTb < 0 then
                    CurTb = 5
                end
            until tblLoad[CurTb]
            CurSlt = #tblLoad[CurTb]
        end

        if GetConVarNumber("hud_fastswitch") > 0 then
            newinv = tblLoad[CurTb][CurSlt].classname
        else
            lastAction = RealTime()
            alpha = 1
        end

        return true
    elseif bind == "+attack" and alpha > 0 then
        if tblLoad[CurTb] and tblLoad[CurTb][CurSlt] and not bind == "+attack2" then
            newinv = tblLoad[CurTb][CurSlt].classname
        end

        if ply:GetActiveWeapon() and tblLoad[CurTb][CurSlt] then 
            for key, wep in pairs(ply:GetWeapons()) do  
                if wep:GetClass() == tblLoad[CurTb][CurSlt].classname then 
                    ply.gl_last_wep = ply:GetActiveWeapon()
                    ply.gl_last_wep_lastinv = nil

                    input.SelectWeapon(wep)                    
                end
            end
        end

        alpha = 0

        return true
    elseif bind == "lastinv" then   
        input.SelectWeapon(ply:GetInternalVariable("m_hLastWeapon")) 
    end
end)

hook.Add("HUDPaint", "WeaponSelector.Hooks.HUDPaint", function()
    if not IsValid(LocalPlayer()) then return end
 
    local RFT = RealFrameTime()

    if alpha < 0.01 then -- prevents alpha from going into the negatives
        if alpha ~= 0 then
            alpha = 0
        end

        gl_weapon_selector_showing = false

        return
    end

    -- print("OYOYOYO")
    gl_weapon_selector_showing = true 

    update()

    if RealTime() - lastAction > 2 then
        alpha = Lerp(FrameTime() * 4, alpha, 0)
    end

    surface.SetAlphaMultiplier(alpha)
    surface.SetDrawColor(WeaponSelector.Colors.BG)
    surface.SetTextColor(WeaponSelector.Colors.TextColor)
    surface.SetFont(WeaponSelector.Font(20))
    local thisWidth = 0

    for i, v in pairs(tblLoad) do
        thisWidth = thisWidth + width + Marge
    end

    x = (ScrW() - thisWidth) / 2

    local pos = x

    for i, v in SortedPairs(tblLoad) do
        local y = Marge

        pos = x + thisWidth * 0.1

        for j, wep in pairs(v) do
            local selected = CurTb == i and CurSlt == j
            local height = height + (height + Marge) * 1
            local is_gl_wep = false
            local tbl

            local color_rarity = WeaponSelector.Colors.BG

            -- if selected then 
            --     PrintTable(wep)
            -- end

            if tbl_gl_stored_bonused_weapons and tbl_gl_stored_bonused_weapons[wep.classname] then 
                is_gl_wep = true
                tbl = tbl_gl_stored_bonused_weapons[wep.classname] 

                color_rarity = tbl_gl_rarity_colors[tbl.rarity]
                -- color_rarity.a = 100
            end

            draw.RoundedBox(0, x, y, width, height, selected and WeaponSelector.Colors.Select or WeaponSelector.Colors.BG)
            surface.SetTextColor(selected and WeaponSelector.Colors.TextColor or WeaponSelector.Colors.TextColor_Unselected)

            if is_gl_wep then        
                local alpha_element = 100

                if selected then 
                    -- color_rarity.a = 200
                    alpha_element = 255
 
                    -- print("grad_h " .. grad_h)
                    grad_h = math.Approach(grad_h, height * 0.6, RFT * H * 0.25)

                    surface.SetDrawColor(color_rarity.r, color_rarity.g, color_rarity.b, 150) 
                    surface.SetMaterial(WeaponSelector.Mats.gradient_up)
                    -- surface.DrawTexturedRect(x, y + height * 0.125, width, grad_h * 0.8) 
                    surface.DrawTexturedRectUV(x, y + height * 0.125, width, grad_h, 0, 0.3, 1, 1)
                end

                draw.RoundedBox(0, x, y, width, height * 0.13, color_rarity)

                local element_name = tbl.element
                local mat_element 

                for key, element in pairs(tbl_gl_elements) do 
                    -- PrintTable(element)
                    -- print(element.name)
                    -- print(element_name)
                    if element.name == element_name then 
                        mat_element = element.mat_1
                    end
                end

                surface.SetDrawColor(255, 255, 255, alpha_element)
                surface.SetMaterial(mat_element)
                surface.DrawTexturedRect(x + width * 0.89, y + height - width * 0.12, width * 0.1, width * 0.1)
 
                wep.name = wep.name .. " [" .. tbl.level .. "]"
            end 

            local w, h = surface.GetTextSize(wep.name)

            if w > width - 10 then
                surface.SetFont(WeaponSelector.Font(16))
                w, h = surface.GetTextSize(wep.name)
            else
                surface.SetFont(WeaponSelector.Font(20))
                w, h = surface.GetTextSize(wep.name)
            end

            surface.SetTextPos(x + (width - w) / 2, y + (height - h) / 2)
            surface.DrawText(wep.name)
            y = y + height + Marge 
        end

        x = x + width + Marge
    end

    surface.SetAlphaMultiplier(1)
end)

hook.Add("HUDShouldDraw", "WeaponSelector.Hooks.HUDShouldDraw", function(elementName)
    if hideElements[elementName] then return false end
end)