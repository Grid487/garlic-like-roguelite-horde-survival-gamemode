include("shared.lua")

if SERVER then
    print("[GAMEMODE] Loading server files...")
    AddCSLuaFile("cl_init.lua") 
    AddCSLuaFile("shared.lua")
    AddCSLuaFile("shared/sh_garlic_like.lua") 
    AddCSLuaFile("shared/sh_garlic_like_scripted_ents.lua") 
    AddCSLuaFile("client/cl_garlic_like.lua")
    AddCSLuaFile("client/cl_concommands.lua")
    AddCSLuaFile("client/cl_fonts.lua")
    AddCSLuaFile("client/cl_hooks.lua")
    AddCSLuaFile("client/cl_menus1.lua")
    AddCSLuaFile("client/cl_multicolor_text.lua")
    AddCSLuaFile("client/cl_networking.lua")
    AddCSLuaFile("client/cl_outline.lua")
    AddCSLuaFile("client/cl_utils.lua")

    AddCSLuaFile("client/weaponselector/hooks.lua")
    AddCSLuaFile("shared/weaponselector/config.lua") 
    include("shared/weaponselector/config.lua")

    include("shared/sh_garlic_like.lua")  
    include("shared/sh_garlic_like_scripted_ents.lua") 
    include("server/sv_garlic_like.lua") 
end

