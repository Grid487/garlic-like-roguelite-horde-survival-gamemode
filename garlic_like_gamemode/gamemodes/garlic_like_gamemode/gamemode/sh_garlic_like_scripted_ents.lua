game.AddParticles("particles/bullet_tracers.pcf")
game.AddParticles("particles/muzzle_flash.pcf")
game.AddParticles("particles/rockettrail.pcf")
game.AddParticles("particles/flamethrower.pcf")
game.AddParticles("particles/sdk_pmk/explosion/generic_explosions_pak.pcf")
PrecacheParticleSystem("bullet_tracer01")
PrecacheParticleSystem("bullet_shotgun_tracer01_red")
PrecacheParticleSystem("bullet_scattergun_tracer01_red")
PrecacheParticleSystem("tfc_sniper_distortion_trail")
PrecacheParticleSystem("muzzle_smg")
PrecacheParticleSystem("muzzle_pistol")
PrecacheParticleSystem("muzzle_revolver")
PrecacheParticleSystem("muzzle_shotgun")
PrecacheParticleSystem("muzzle_minigun")
PrecacheParticleSystem("muzzle_sniperrifle")
PrecacheParticleSystem("muzzle_grenadelauncher")
PrecacheParticleSystem("crit_text")
PrecacheParticleSystem("rockettrail_!")
PrecacheParticleSystem("rockettrail")
PrecacheParticleSystem("critical_rocket_blue")
PrecacheParticleSystem("critical_rocket_red")
PrecacheParticleSystem("pipebombtrail_red")
PrecacheParticleSystem("_flamethrower_REAL")
PrecacheParticleSystem("explo_tiny_mac_edited")
local gl = "garlic_like_"

if SERVER then 
    function garlic_like_determine_rarity_particles(ent, rarity) 
        -- print("DETEMINING")  
        if not IsValid(ent) then return end
        ParticleEffectAttach("loot_beam_rarity_" .. rarity, PATTACH_POINT_FOLLOW, ent, 1)       
    end
end 

local tbl_rarity_weights = {
    [1] = {
        rarity = "poor", 
        weight = 500, 
        weight_min = 0,
        weight_max = 1200,
        color = Color(122, 122, 122),
    },
    [2] = {
        rarity = "common", 
        weight = 10000, 
        weight_min = 0,
        weight_max = 0,
        color = Color(255, 255, 255),
    },
    [3] = {
        rarity = "uncommon", 
        weight = 5000, 
        weight_min = 0,
        weight_max = 0,
        color = Color(111, 221, 255),
    },
    [4] = {
        rarity = "rare", 
        weight = 2500, 
        weight_min = 0,
        weight_max = 0,
        color = Color(0, 132, 255),
    },
    [5] = {
        rarity = "epic", 
        weight = 1250, 
        weight_min = 0,
        weight_max = 0,
        color = Color(195, 0, 255),
    },
    [6] = {
        rarity = "legendary", 
        weight = 625, 
        weight_min = 0,
        weight_max = 0,
        color = Color(255, 72, 0),
    },
    [7] = {
        rarity = "god", 
        weight = 325, 
        weight_min = 0,
        weight_max = 0,
        color = Color(255, 0, 0),
    },
}

local rarity_weights_max = 0

local tbl_ammo_refill_amount = {
    ["AR2"] = 30,
    ["AR2AltFire"] = 2,
    ["Pistol"] = 30,
    ["SMG1"] = 30,
    ["357"] = 10,
    ["XBowBolt"] = 10,
    ["RPG_Round"] = 2,
    ["SMG1_Grenade"] = 2,
    ["Grenade"] = 2,
    ["357Round"] =  10,
    ["Buckshot"] =  10,
}

for k, v in ipairs(tbl_rarity_weights) do 
    rarity_weights_max = rarity_weights_max + v.weight 

    if k > 1 then 
        v.weight_min = tbl_rarity_weights[k - 1].weight_max + 1
        v.weight_max = v.weight_min + v.weight 
    end
end

do
    local shield_entity = {}
    shield_entity.Type = "anim"
    shield_entity.Base = "base_anim"
    shield_entity.AutomaticFrameAdvance = true

    function shield_entity:Initialize()
        self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        self:SetMaterial("models/props_combine/stasisshield_sheet")
        self.shield_target = self:GetNWEntity("shield_entity")
        -- model = self.shield_target:GetModel()
        -- if model ~= self:GetModel() then
        --     self:SetModel(model)
        -- end
        -- self:AddEffects(EF_BONEMERGE)
        -- self:SetPos(self.shield_target:GetPos())
        -- self:SetParent(self.shield_target)
        -- self:SetRenderMode(RENDERMODE_TRANSALPHA)
        -- self:SetColor(Color(163, 218, 255, 50))
        -- --
        -- for i = 0, self.shield_target:GetBoneCount() - 1 do
        --     name = self.shield_target:GetBoneName(i)
        --     scale = 0.25
        --     if name ~= "__INVALIDBONE__" then
        --         if name == "ValveBiped.Bip01_Head1" then
        --             self:ManipulateBoneScale(i, Vector(1.05 + scale, 1.05 + scale, 1.05 + scale))
        --         else
        --             self:ManipulateBoneScale(i, Vector(1.05 + scale, 1.05 + scale, 1.05 + scale))
        --         end
        --     end
        -- end
    end

    function shield_entity:DrawTranslucent()
        self:Draw()
    end

    function shield_entity:Think()
        if not IsValid(self:GetNWEntity("shield_entity")) then return end

        if self.shield_target == NULL or self.shield_target == nil then
            self.shield_target = self:GetNWEntity("shield_entity")
        end

        if self:GetNWEntity("shield_entity"):GetModel() ~= self:GetModel() then
            self.entity_model = self:GetNWEntity("shield_entity"):GetModel()

            if not self.entity_model then return end

            self:SetModel(self.entity_model)
        end

        self:AddEffects(EF_BONEMERGE)
        self:SetPos(self.shield_target:GetPos())
        self:SetParent(self.shield_target)
        self:SetRenderMode(RENDERMODE_TRANSALPHA)
        self:SetColor(Color(163, 218, 255, 1))

        --
        for i = 0, self.shield_target:GetBoneCount() - 1 do
            name = self.shield_target:GetBoneName(i)
            scale = 0.15

            if name ~= "__INVALIDBONE__" then
                if name == "ValveBiped.Bip01_Head1" then
                    self:ManipulateBoneScale(i, Vector(1.05 + scale, 1.05 + scale, 1.05 + scale))
                else
                    self:ManipulateBoneScale(i, Vector(1.05 + scale, 1.05 + scale, 1.05 + scale))
                end
            end
        end

        if self.shield_target:GetNWInt(gl .. "enemy_shield") < 1 then
            self:SetColor(Color(163, 218, 255, 0))
        end

        self:NextThink(CurTime() + 1)
    end

    scripted_ents.Register(shield_entity, gl .. "shield_entity")
end

-- * weapon crate
do
    local weapon_crate_entity = {}
    weapon_crate_entity.Type = "anim"
    weapon_crate_entity.Base = "base_anim"
    weapon_crate_entity.PrintName = "Garlic Like Weapon Crate"    
    weapon_crate_entity.Category = "Garlic Like"
    weapon_crate_entity.Spawnable = true
 
    -- for k, v in ipairs(tbl_rarity_weights) do 
    --     -- print(v.rarity .. " chance: " .. v.weight / rarity_weights_max)
    -- end

    -- PrintTable(tbl_rarity_weights)

    if SERVER then
        function weapon_crate_entity:Initialize()
            self:SetModel("models/Items/item_item_crate.mdl")
            self:PhysicsInit(SOLID_VPHYSICS) 
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            self:GetPhysicsObject():Wake()
            self:SetCollisionGroup(COLLISION_GROUP_WORLD)
            self:SetUseType(SIMPLE_USE) 
            self:SetMaxHealth(200)
            self:SetHealth(200)
            self.gl_roll_num = math.random(0, rarity_weights_max) 

            for k, v in ipairs(tbl_rarity_weights) do 
                if IsNumBetween(self.gl_roll_num, v.weight_min, v.weight_max) then 
                    self:SetNWString(gl .. "item_rarity", v.rarity)    
                end
            end
 
            self:SetSkin(math.random(0, 4))
            -- ParticleEffectAttach("halloween_pickup_active", PATTACH_POINT_FOLLOW, self, 0)
            timer.Simple(0.1, function() 
                if not IsValid(self) then return end 
                self:SetNWString(gl .. "item_name", firstToUpper(self:GetNWString(gl .. "item_rarity")) .. " Weapon Crate")
                self:SetNWBool(gl .. "settled_2", true)
                garlic_like_determine_rarity_particles(self, self:GetNWString(gl .. "item_rarity", "poor"))
            end) 

            self.GL_is_used = false
            phys = self:GetPhysicsObject()  
        end

        function weapon_crate_entity:Use(ent)
            if not self.GL_is_used then
                net.Start(gl .. "open_weapon_crate")
                net.WriteString(self:GetNWString(gl .. "item_rarity"))
                net.Send(ent)
            end

            SafeRemoveEntity(self)
            self.GL_is_used = true
        end

        function weapon_crate_entity:OnTakeDamage(dmg) 
            if not dmg:GetAttacker():IsPlayer() then return end 
            if not self:GetNWBool(gl .. "settled_2") then return end
            --
            local ply = dmg:GetAttacker() 
            self:SetHealth(self:Health() - dmg:GetDamage())

            if self:Health() <= 0 then  
                self.gem_amount = 2
                self.gem_add_chance = 0.25

                for i2 = 1, 30 + GetGlobalInt(gl .. "minutes", 0) * 5 do 
                    self.gem_rng = math.random() 

                    if self.gem_rng <= self.gem_add_chance then
                        -- print(self.gem_rng)
                        self.gem_add_chance = self.gem_add_chance * 0.9
                        self.gem_amount = self.gem_amount + 1
                    end
                end 
                
                garlic_like_create_material_drop(ply, self, "ore", self:GetNWString(gl .. "item_rarity"), self.gem_amount) 
                
                SafeRemoveEntity(self)
            end
        end
    end

    scripted_ents.Register(weapon_crate_entity, gl .. "weapon_crate_entity")
end

--* tf2 ultimate base
do
    local tf2_ultimate_base = {}
    tub = tf2_ultimate_base
    tub.Type = "anim"
    tub.Base = "base_anim"
    tub.PrintName = "Team Fortress 2 All Out Ultimate Base Entity"
    tub.Spawnable = false

    function tub:Initialize()
        self:SetModel("models/props_c17/FurnitureBathtub001a.mdl")
        self:SetMoveType(MOVETYPE_NOCLIP)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WORLD)
        self:SetRenderMode(RENDERMODE_NONE)
        ply = self:GetOwner()

        timer.Simple(0.25, function()
            if not IsValid(self) then return end
            self:SetMoveParent(ply)
            self:SetAngles(ply:GetAngles())
        end)

        timer.Simple(0.3, function()
            if not IsValid(self) then return end
            
            if SERVER then
                local model_rocket_launcher = ents.Create("base_anim")
                mrl = model_rocket_launcher
                mrl.Type = "anim"
                mrl.is_rocket_launcher = true
                mrl:SetModel("models/weapons/w_models/w_rocketlauncher.mdl")
                mrl:SetCollisionGroup(COLLISION_GROUP_WORLD)
                mrl:SetSolid(SOLID_VPHYSICS)
                mrl:SetMoveType(MOVETYPE_NOCLIP)
                mrl:SetPos(Vector(25, 30, 50))
                mrl:SetMoveParent(self)
                mrl:SetOwner(ply)
                mrl:SetAngles(ply:GetAngles())
                mrl:Spawn()
                mrl:SetNWBool("GL_tub_child", true)

                function mrl:OnRemove()
                    local ed = EffectData()
                    ed:SetEntity(self)
                    util.Effect("entity_remove", ed, true, true)
                end

                -- 
                local model_shotgun = ents.Create("base_anim")
                msg = model_shotgun
                msg.Type = "anim"
                msg.is_shotgun = true
                msg:SetModel("models/weapons/w_models/w_shotgun.mdl")
                msg:SetCollisionGroup(COLLISION_GROUP_WORLD)
                msg:SetSolid(SOLID_VPHYSICS)
                msg:SetMoveType(MOVETYPE_NOCLIP)
                msg:SetPos(Vector(25, 15, 80))
                msg:SetMoveParent(self)
                msg:SetOwner(ply)
                msg:SetAngles(ply:GetAngles())
                msg:Spawn()
                msg:SetNWBool("GL_tub_child", true)

                function msg:OnRemove()
                    local ed = EffectData()
                    ed:SetEntity(self)
                    util.Effect("entity_remove", ed, true, true)
                end

                -- 
                local model_scattergun = ents.Create("base_anim")
                mscg = model_scattergun
                mscg.Type = "anim"
                mscg.is_scattergun = true
                mscg:SetModel("models/weapons/w_models/w_scattergun.mdl")
                mscg:SetCollisionGroup(COLLISION_GROUP_WORLD)
                mscg:SetSolid(SOLID_VPHYSICS)
                mscg:SetMoveType(MOVETYPE_NOCLIP)
                mscg:SetPos(Vector(25, 25, 60))
                mscg:SetMoveParent(self)
                mscg:SetOwner(ply)
                mscg:SetAngles(ply:GetAngles())
                mscg:Spawn()
                mscg:SetNWBool("GL_tub_child", true)

                function mscg:OnRemove()
                    local ed = EffectData()
                    ed:SetEntity(self)
                    util.Effect("entity_remove", ed, true, true)
                end

                -- 
                local model_smg = ents.Create("base_anim")
                smg = model_smg
                smg.Type = "anim"
                smg.is_smg = true
                smg:SetModel("models/weapons/w_models/w_smg.mdl")
                smg:SetCollisionGroup(COLLISION_GROUP_WORLD)
                smg:SetSolid(SOLID_VPHYSICS)
                smg:SetMoveType(MOVETYPE_NOCLIP)
                smg:SetPos(Vector(25, -15, 80))
                smg:SetMoveParent(self)
                smg:SetOwner(ply)
                smg:SetAngles(ply:GetAngles())
                smg:Spawn()
                smg:SetNWBool("GL_tub_child", true)

                function smg:OnRemove()
                    local ed = EffectData()
                    ed:SetEntity(self)
                    util.Effect("entity_remove", ed, true, true)
                end

                -- 
                local model_pistol = ents.Create("base_anim")
                pistol = model_pistol
                pistol.Type = "anim"
                pistol.is_pistol = true
                pistol:SetModel("models/weapons/w_models/w_pistol.mdl")
                pistol:SetCollisionGroup(COLLISION_GROUP_WORLD)
                pistol:SetSolid(SOLID_VPHYSICS)
                pistol:SetMoveType(MOVETYPE_NOCLIP)
                pistol:SetPos(Vector(25, 20, 70))
                pistol:SetMoveParent(self)
                pistol:SetOwner(ply)
                pistol:SetAngles(ply:GetAngles())
                pistol:Spawn()
                pistol:SetNWBool("GL_tub_child", true)

                function pistol:OnRemove()
                    local ed = EffectData()
                    ed:SetEntity(self)
                    util.Effect("entity_remove", ed, true, true)
                end

                -- 
                local model_revolver = ents.Create("base_anim")
                revolver = model_revolver
                revolver.Type = "anim"
                revolver.is_revolver = true
                revolver:SetModel("models/weapons/w_models/w_revolver.mdl")
                revolver:SetCollisionGroup(COLLISION_GROUP_WORLD)
                revolver:SetSolid(SOLID_VPHYSICS)
                revolver:SetMoveType(MOVETYPE_NOCLIP)
                revolver:SetPos(Vector(25, -20, 70))
                revolver:SetMoveParent(self)
                revolver:SetOwner(ply)
                revolver:SetAngles(ply:GetAngles())
                revolver:Spawn()
                revolver:SetNWBool("GL_tub_child", true)

                function revolver:OnRemove()
                    local ed = EffectData()
                    ed:SetEntity(self)
                    util.Effect("entity_remove", ed, true, true)
                end

                -- 
                local model_sniper = ents.Create("base_anim")
                sniper = model_sniper
                sniper.Type = "anim"
                sniper.is_sniper = true
                sniper:SetModel("models/weapons/w_models/w_sniperrifle.mdl")
                sniper:SetCollisionGroup(COLLISION_GROUP_WORLD)
                sniper:SetSolid(SOLID_VPHYSICS)
                sniper:SetMoveType(MOVETYPE_NOCLIP)
                sniper:SetPos(Vector(25, 25, 40))
                sniper:SetMoveParent(self)
                sniper:SetOwner(ply)
                sniper:SetAngles(ply:GetAngles())
                sniper:Spawn()
                sniper:SetNWBool("GL_tub_child", true)

                function sniper:OnRemove()
                    local ed = EffectData()
                    ed:SetEntity(self)
                    util.Effect("entity_remove", ed, true, true)
                end

                -- 
                local model_minigun = ents.Create("base_anim")
                minigun = model_minigun
                minigun.Type = "anim"
                minigun.is_minigun = true
                minigun:SetModel("models/weapons/w_models/w_minigun.mdl")
                minigun:SetCollisionGroup(COLLISION_GROUP_WORLD)
                minigun:SetSolid(SOLID_VPHYSICS)
                minigun:SetMoveType(MOVETYPE_NOCLIP)
                minigun:SetPos(Vector(25, -25, 40))
                minigun:SetMoveParent(self)
                minigun:SetOwner(ply)
                minigun:SetAngles(ply:GetAngles())
                minigun:Spawn()
                minigun:SetNWBool("GL_tub_child", true)

                function minigun:OnRemove()
                    -- print(" MINIGUN REMOVED")
                    local ed = EffectData()
                    ed:SetEntity(self)
                    util.Effect("entity_remove", ed, true, true)
                    self:StopSound("weapons/minigun_shoot.wav")
                end

                -- 
                local model_mgl = ents.Create("base_anim")
                mgl = model_mgl
                mgl.Type = "anim"
                mgl.is_grenade_launcher = true
                mgl:SetModel("models/weapons/w_models/w_grenadelauncher.mdl")
                mgl:SetCollisionGroup(COLLISION_GROUP_WORLD)
                mgl:SetSolid(SOLID_VPHYSICS)
                mgl:SetMoveType(MOVETYPE_NOCLIP)
                mgl:SetPos(Vector(25, -25, 60))
                mgl:SetMoveParent(self)
                mgl:SetOwner(ply)
                mgl:SetAngles(ply:GetAngles())
                mgl:Spawn()
                mgl:SetNWBool("GL_tub_child", true)

                function mgl:OnRemove()
                    local ed = EffectData()
                    ed:SetEntity(self)
                    util.Effect("entity_remove", ed)
                end

                -- 
                local model_flamethrower = ents.Create("base_anim")
                flamethrower = model_flamethrower
                flamethrower.Type = "anim"
                flamethrower.is_flamethrower = true
                flamethrower:SetModel("models/weapons/c_models/c_flamethrower/c_flamethrower.mdl")
                flamethrower:SetCollisionGroup(COLLISION_GROUP_WORLD)
                flamethrower:SetSolid(SOLID_VPHYSICS)
                flamethrower:SetMoveType(MOVETYPE_NOCLIP)
                flamethrower:SetPos(Vector(25, -30, 50))
                flamethrower:SetMoveParent(self)
                flamethrower:SetOwner(ply)
                flamethrower:SetAngles(ply:GetAngles())
                flamethrower:Spawn()
                flamethrower:SetNWBool("GL_tub_child", true)

                function flamethrower:OnRemove()
                    local ed = EffectData()
                    ed:SetEntity(self)
                    util.Effect("entity_remove", ed, true, true)
                    self:StopSound("weapons/flame_thrower_loop.wav")
                end
                -- 
            end
        end)

        timer.Simple(7, function()
            if not IsValid(self) then return end
            self:GetOwner():SetNWBool(gl .. "is_using_tf2_ult", false)
            self:Remove()
        end)
    end

    function tub:Think()
    end

    scripted_ents.Register(tub, gl .. "tf2_ultimate_base")

    --
    -- tf2 rocket
    do
        garlic_like_tf2_rocket = {}
        tf2r = garlic_like_tf2_rocket
        tf2r.Type = "anim"
        tf2r.Base = "base_anim"
        tf2r.PrintName = "Team Fortress 2 All Out Ultimate Base Entity"
        tf2r.Spawnable = false
        tf2r.Damage = 125

        function tf2r:Draw()
            self:DrawModel()
        end

        function tf2r:Initialize()
            self:SetModel("models/weapons/w_models/w_rocket.mdl")
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)

            if SERVER then
                self:SetTrigger(true)
            end

            self:SetCollisionGroup(COLLISION_GROUP_WORLD)

            if IsValid(self:GetOwner()) then
                self.owner = self:GetOwner()
                self:SetPos(self.owner:GetAttachment(self.owner:LookupAttachment("muzzle")).Pos)
                self:SetAngles(self.owner:GetOwner():EyeAngles())
            end

            local phys = self:GetPhysicsObject()

            if phys:IsValid() then
                phys:Wake()
            end

            phys:EnableGravity(false)
            ParticleEffectAttach("rockettrail", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("trail"))

            timer.Simple(0.75, function()
                if not IsValid(self) then return end
                self:Explode()
            end)
        end

        function tf2r:Think()
            local phys = self:GetPhysicsObject()
            phys:ApplyForceCenter(self:GetAngles():Forward() * 5000)
            self:NextThink(CurTime())
        end

        function tf2r:StartTouch(ent)
            if ent:IsNPC() or ent:IsNextBot() or ent:IsWorld() then
                -- print(ent)
                self:Explode()
            end
        end

        function tf2r:PhysicsCollide(data, physobj)
        end

        function tf2r:Explode()
            -- print("EXPLODE")
            local effectdata = EffectData()
            effectdata:SetOrigin(self:GetPos())
            local inflictor = self
            local attacker = self

            if IsValid(self.owner) then
                attacker = self.owner:GetOwner()
            else
                attacker = self
                inflictor = self
            end

            ParticleEffect("explosioncore_midair", self:GetPos(), self:GetAngles())
            self:EmitSound("Weapon_RPG_DirectHit.Explode")
            self:TF2BlastDamage(inflictor, attacker, self:GetPos(), 128, self.Damage)
            self:Remove()
        end

        function tf2r:TF2BlastDamage(infl, atkr, origin, radius, dmg)
            local expd = DamageInfo()
            expd:SetAttacker(atkr)
            expd:SetInflictor(infl)
            expd:SetDamageType(DMG_BLAST)
            expd:SetDamagePosition(origin)
            local subjects = ents.FindInSphere(origin, radius)

            for k, v in pairs(subjects) do
                local dist = v:GetPos():Distance(origin)
                expd:SetDamage((radius - dist) * (dmg / radius))

                local fvTrace = util.TraceLine({
                    start = origin,
                    endpos = v:GetPos()
                })

                local ForceVector = fvTrace.Normal * ((radius - dist) * (40000 / radius))
                expd:SetDamageForce(ForceVector)

                if not v:IsPlayer() then
                    v:TakeDamageInfo(expd)
                end
            end
        end

        scripted_ents.Register(tf2r, gl .. "tf2_ultimate_rocket")
    end

    -- tf2 grenade launcher
    do
        garlic_like_tf2_grenade = {}
        gltg = garlic_like_tf2_grenade
        gltg.Type = "anim"
        gltg.Base = "base_anim"
        gltg.PrintName = "Team Fortress 2 All Out Ultimate Base Entity Grenade"
        gltg.Spawnable = false
        gltg.Damage = 125

        function gltg:Initialize()
            self:SetModel("models/weapons/w_models/w_grenade_grenadelauncher.mdl")
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)

            if SERVER then
                self:SetTrigger(true)
            end

            local phys = self:GetPhysicsObject()

            if phys:IsValid() then
                phys:Wake()
            end

            if IsValid(self:GetOwner()) then
                self.owner = self:GetOwner()
                self:SetPos(self.owner:GetAttachment(self.owner:LookupAttachment("muzzle")).Pos)
                self:SetAngles(self.owner:GetOwner():EyeAngles())
            end

            phys:AddAngleVelocity(Vector(0, -1024, 0))
            phys:ApplyForceCenter((self:GetAngles():Forward() * 6500) + (self:GetAngles():Up() * 1000))
            PrecacheParticleSystem("pipebombtrail_blue")
            PrecacheParticleSystem("pipebombtrail_red")
            PrecacheParticleSystem("crit_text")
            PrecacheParticleSystem("critical_pipe_blue")
            PrecacheParticleSystem("critical_pipe_red")

            timer.Simple(1.5, function()
                if not IsValid(self) then return end
                self:Explode()
            end)
        end

        function gltg:Think()
            local phys = self:GetPhysicsObject()
            --phys:ApplyForceCenter(self:GetAngles():Forward() * 5000)
            self:NextThink(CurTime())
        end

        function gltg:PhysicsCollide(data, physobj)
            -- Play sound on bounce
            if data.Speed > 60 and data.DeltaTime > 0.2 then end --self:Explode()
        end

        function gltg:StartTouch(ent)
            if ent:IsNextBot() or ent:IsNPC() then
                self:Explode()
            end
        end

        function gltg:Explode()
            local effectdata = EffectData()
            effectdata:SetOrigin(self:GetPos())
            local inflictor = self
            local attacker = self

            if IsValid(self.owner) then
                -- print("VALID PLAYER GRENADE")
                attacker = self.owner:GetOwner()
            else
                attacker = self
                inflictor = self
            end

            ParticleEffect("explosioncore_midair", self:GetPos(), self:GetAngles())
            self:EmitSound("Weapon_Grenade_Pipebomb.Explode")
            self:TF2BlastDamage(inflictor, attacker, self:GetPos(), 128, self.Damage)
            self:Remove()
        end

        function gltg:TF2BlastDamage(infl, atkr, origin, radius, dmg)
            local expd = DamageInfo()
            expd:SetAttacker(atkr)
            expd:SetInflictor(infl)
            expd:SetDamageType(DMG_BLAST)
            expd:SetDamagePosition(origin)
            local subjects = ents.FindInSphere(origin, radius)

            for k, v in pairs(subjects) do
                local dist = v:GetPos():Distance(origin)
                expd:SetDamage((radius - dist) * (dmg / radius))

                local fvTrace = util.TraceLine({
                    start = origin,
                    endpos = v:GetPos()
                })

                local ForceVector = fvTrace.Normal * ((radius - dist) * (40000 / radius))
                expd:SetDamageForce(ForceVector)

                if not v:IsPlayer() then
                    v:TakeDamageInfo(expd)
                end
            end
        end

        scripted_ents.Register(gltg, gl .. "tf2_ultimate_grenade")
    end
end

--* weapon materials / gems
do  
    local rarities = {
        [1] = {
            name = "Poor Ore",
            rarity = "poor",
            model = "models/fortnite_crafting/fortnite_crafting_materials/copper_ore.mdl",
            particle_trail = "",
            particle_beam = ""
        },
        [2] = {
            name = "Common Ore",
            rarity = "common",
            model = "models/fortnite_crafting/fortnite_crafting_materials/silver_ore.mdl",
            particle_trail = "",
            particle_beam = ""
        },
        [3] = {
            name = "Uncommon Ore",
            rarity = "uncommon",
            model = "models/fortnite_crafting/fortnite_crafting_materials/malachite_ore.mdl",
            particle_trail = "",
            particle_beam = ""
        },
        [4] = {
            name = "Rare Ore",
            rarity = "rare",
            model = "models/fortnite_crafting/fortnite_crafting_materials/spectrolite_ore.mdl",
            particle_trail = "",
            particle_beam = ""
        },
        [5] = {
            name = "Epic Crystal",
            rarity = "epic",
            model = "models/fortnite_crafting/fortnite_crafting_materials/shadowshard_crystal.mdl",
            particle_trail = "",
            particle_beam = ""
        },
        [6] = {
            name = "Legendary Crystal",
            rarity = "legendary",
            model = "models/fortnite_crafting/fortnite_crafting_materials/sunbeam_crystal.mdl",
            particle_trail = "",
            particle_beam = ""
        },
        [7] = {
            name = "God Crystal",
            rarity = "god",
            model = "models/fortnite_crafting/fortnite_crafting_materials/rainbow_crystal.mdl",
            particle_trail = "",
            particle_beam = ""
        },
    }

    for k, rarity_entry in pairs(rarities) do
        rarity_entry.particle_trail = "loot_trail_" .. rarity_entry.rarity
        rarity_entry.particle_beam = "loot_beam_rarity_" .. rarity_entry.rarity
    end

    local food_items = {
        [1] = { 
            name = "Apple",
            model = "models/apple01.mdl", 
            healing_amount = 0.05,
            mana_healing = 0.17,
            rarity = "common",
        },
        [2] = { 
            name = "Cooked Beef",
            model = "models/beefmeatcooked.mdl", 
            healing_amount = 0.2,
            mana_healing = 0.35,
            rarity = "rare",
        },
        [3] = { 
            name = "Bread",
            model = "models/bread01.mdl", 
            healing_amount = 0.12,
            mana_healing = 0.1,
            rarity = "uncommon",
        },
        [4] = { 
            name = "Half Bread",
            model = "models/bread02.mdl", 
            healing_amount = 0.06,
            mana_healing = 0.05,
            rarity = "common",
        },
        [5] = { 
            name = "Small Cheese",
            model = "models/cheesewedge01.mdl", 
            healing_amount = 0.04,
            mana_healing = 0.04,
            rarity = "common",
        },
        [6] = { 
            name = "Old Cheese",
            model = "models/cheesewedge02.mdl", 
            healing_amount = 0.03,
            mana_healing = 0.03,
            rarity = "poor",
        },
        [7] = { 
            name = "3/4 Cheese Wedge",
            model = "models/cheesewheel01b.mdl", 
            healing_amount = 0.2,
            mana_healing = 0.2,
            rarity = "epic",
        },
        [8] = { 
            name = "Cheese Wedge",
            model = "models/cheesewheel01a.mdl", 
            healing_amount = 0.25,
            mana_healing = 0.25,
            rarity = "legendary",
        },
        [9] = { 
            name = "Cooked Chicken",
            model = "models/cookedchickenmeat01.mdl", 
            healing_amount = 0.15,
            mana_healing = 0.24,
            rarity = "rare",
        },
        [10] = { 
            name = "Sweetroll",
            model = "models/sweetroll01.mdl", 
            healing_amount = 0.12,
            mana_healing = 0.3,
            rarity = "rare",
        },
        [11] = { 
            name = "Pie",
            model = "models/pie01.mdl", 
            healing_amount = 0.15,
            mana_healing = 0.15,
            rarity = "rare",
        },
    }

    local powerups = {
        ["Main"] = {
            name = "Nuke",
            bodygroup_id = 0,
            use_powerup = function(ply, mod) 
                for k, ent in pairs(ents.FindInSphere(ply:GetPos(), 5000)) do 
                    if ent:IsNPC() or ent:IsNextBot() then 
                        ent:TakeDamage(10000, ply, ply)
                        -- ent:SetHealth(ent:Health() * 0.01)
                    end
                end
            end,
        },
        ["MaxAmmo"] = {
            name = "Ammo Refill",
            bodygroup_id = 1,
            use_powerup = function(ply, mod) 
                for k, v in pairs(tbl_ammo_refill_amount) do 
                    ply:GiveAmmo(v * 12 * math.max(1, GetGlobalBool(gl .. "minutes", 1) * 0.8), k, false)
                end
            end,
         },
        ["InstaKill"] = {
            name = "Bonus Damage Increase",
            bodygroup_id = 2,
            use_powerup = function(ply, mod) 
                ply:SetNWFloat(gl .. "powerup_InstaKill", ply:GetNWFloat(gl .. "powerup_InstaKill", 1) + mod) 
                garlic_like_upgrade_str(ply, STR, 0)

                timer.Simple(15, function() 
                    if not IsValid(ply) then return end
                    ply:SetNWFloat(gl .. "powerup_InstaKill", ply:GetNWFloat(gl .. "powerup_InstaKill", 1) - mod) 
                    garlic_like_upgrade_str(ply, STR, 0)
                end)
            end,
         },
        ["FullPower"] = {
            name = "+100% Cooldown Speed Increase",
            bodygroup_id = 3,
            use_powerup = function(ply, mod) 
                ply:SetNWFloat(gl .. "powerup_FullPower", ply:GetNWFloat(gl .. "powerup_FullPower", 1) + 1) 
                garlic_like_upgrade_int(ply, INT, 0)

                timer.Simple(15, function() 
                    ply:SetNWFloat(gl .. "powerup_FullPower", ply:GetNWFloat(gl .. "powerup_FullPower", 1) - 1) 
                    garlic_like_upgrade_int(ply, INT, 0)
                end)
            end,
         },
        ["DoublePoints"] = {
            name = "XP & Gold Gain Multiplier",
            bodygroup_id = 4,
            use_powerup = function(ply, mod) 
                ply:SetNWFloat(gl .. "powerup_DoublePoints", ply:GetNWFloat(gl .. "powerup_DoublePoints", 1) + mod) 
                garlic_like_upgrade_int(ply, INT, 0)

                timer.Simple(15, function() 
                    ply:SetNWFloat(gl .. "powerup_DoublePoints", ply:GetNWFloat(gl .. "powerup_DoublePoints", 1) - mod) 
                    garlic_like_upgrade_int(ply, INT, 0)
                end)
            end, 
        },
        ["ArmorVest"] = {
            name = "Armor Vest",
            bodygroup_id = 5,
            use_powerup = function(ply, mod) 
                ply:SetArmor(ply:Armor() + 200 * math.max(1, GetGlobalInt(gl .. "minutes", 1) * 0.8))                
            end,
        },
    }

    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_anim"
    ENT.PrintName = "Garlic Like Weapon Crystal"
    ENT.Spawnable = false

    if SERVER then
        function ENT:Initialize()
            self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            self:GetPhysicsObject():Wake()
            self:SetCollisionGroup(COLLISION_GROUP_WORLD)
            self:SetUseType(SIMPLE_USE)
            self:SetTrigger(true)
            self:SetNWBool(gl .. "ready_to_settle", false)
            self:SetNWBool(gl .. "settled", false)
            self:SetNWInt(gl .. "item_amount", 1)
            local phys = self:GetPhysicsObject()

            if IsValid(phys) then
                phys:SetMass(20)
            end

            if not IsValid(self:GetOwner()) then
                --* IF CRYSTALS ARE ALL OF GOD RARITY, IT MEANS THE CRYSTAL HAS NO OWNER
                self:DetermineItemDrop("god")

            else
                self:DetermineItemDrop(self:GetNWString(gl .. "assigned_rarity"))
            end

            timer.Simple(0.15, function()
                if IsValid(self) then 
                    self:Launch()
                end
            end)

            timer.Simple(0.5, function()
                if IsValid(self) then
                    self:SetNWBool(gl .. "ready_to_settle", true)
                end
            end)
        end

        function ENT:StartTouch(ply)
            if not ply:IsPlayer() then return end
            if not self:GetNWBool(gl .. "settled") then return end
            if not self:GetNWBool(gl .. "settled_2") then return end
            --
            local rarity = string.lower(self:GetNWString(gl .. "item_rarity"))
            local item_name = self:GetNWString(gl .. "item_name")
            local item_id = self:GetNWString(gl .. "item_id", "SAMPLE_ID")
            local item_amount = self:GetNWInt(gl .. "item_amount", 1)
            local order_type = "update_held_num_ores"
            -- print(gl .. "held_num_material_" .. rarity)
            -- print("HELD ITEM " .. rarity .. " " .. ply:GetPData(gl .. "held_num_material_" .. rarity, ply:GetPData(gl .. "held_num_material_" .. rarity, 0) + 1))
            if self:GetNWBool(gl .. "is_ore") then  
                print("ply:GetNWInt " .. rarity .. " " .. ply:GetNWInt(gl .. "held_num_material_" .. rarity) .. " +" .. item_amount) 
                ply:SetPData(gl .. "held_num_material_" .. rarity, ply:GetPData(gl .. "held_num_material_" .. rarity, 0) + item_amount)
                ply:SetNWInt(gl .. "held_num_material_" .. rarity, tonumber(ply:GetPData(gl .. "held_num_material_" .. rarity, 0)) + item_amount)
                print("ply:GetNWInt " .. rarity .. " " .. ply:GetNWInt(gl .. "held_num_material_" .. rarity)) 

                --* UPDATE PLAYER UNLOCKABLES PROGRESS 
                if not tobool(ply:GetPData(gl .. "bonus_gem_drops_unlocked")) then 
                    ply:SetNWInt(gl .. "gems_collected", ply:GetNWInt(gl .. "gems_collected", 0) + item_amount)

                    if ply:GetNWInt(gl .. "gems_collected", 0) >= 300 then 
                        garlic_like_unlock(ply, gl .. "bonus_gem_drops", "Gem Drops Increase")
                    end
                end
            end

            --* IF IT'S A NON ORE MATERIAL
            if self:GetNWBool(gl .. "is_non_ore_mat") then 
                order_type = "update_held_num_materials"

                ply:SetPData(gl .. "held_num_material_" .. item_id, ply:GetPData(gl .. "held_num_material_" .. item_id, 0) + item_amount)
                ply:SetNWInt(gl .. "held_num_material_" .. item_id, tonumber(ply:GetPData(gl .. "held_num_material_" .. item_id, 0)) + item_amount)  
                print("ply:GetNWInt " .. item_id .. " " .. ply:GetNWInt(gl .. "held_num_material_" .. item_id)) 

                --* UPDATE PLAYER UNLOCKABLES PROGRESS 
                if self:GetNWBool(gl .. "is_reroll_crystal") and not tobool(ply:GetPData(gl .. "bonus_reroll_gem_drops_unlocked")) then 
                    ply:SetNWInt(gl .. "reroll_gems_collected", ply:GetNWInt(gl .. "reroll_gems_collected", 0) + item_amount)

                    if ply:GetNWInt(gl .. "reroll_gems_collected", 0) >= 300 then 
                        garlic_like_unlock(ply, gl .. "bonus_reroll_gem_drops", "Reroll Gem Drops Increase")
                    end
                end
            end
  
            --* IF IT'S A FOOD ITEM
            if self:GetNWBool(gl .. "is_food") then 
                self:Heal(ply)
                order_type = "food"
            end

            if self:GetNWBool(gl .. "is_powerup") then 
                self:Powerup(ply)
                order_type = "powerup"
            end
 
            net.Start(gl .. "update_database_sv_to_cl")
            net.WriteEntity(ply)
            net.WriteString(order_type)
            net.WriteString(self:GetNWString(gl .. "item_name"))
            net.WriteString(rarity)
            net.WriteInt(self:GetNWInt(gl .. "item_amount", 1), 32)
            net.WriteBool(true)
            net.Send(ply)  
 
            ply:EmitSound("ui/item_medal_pickup.wav", 120, 100, 1, CHAN_AUTO) 
            SafeRemoveEntity(self)
        end

        function ENT:Heal(ply) 
            order_type = "eat_food"
            local ply_hp = ply:Health() 
            local ply_maxhp = ply:GetMaxHealth()
            local healing = ply_maxhp * self:GetNWFloat(gl .. "food_hp_heal")
            local excessive_healing = 0
            
            if ply_hp >= ply_maxhp then 
                healing = healing * 0.3
            end

            if ply_hp + healing >= ply_maxhp then 
                excessive_healing = ply_hp + healing - ply_maxhp
            end

            ply:SetArmor(ply:Armor() + 100 * self:GetNWFloat(gl .. "food_hp_heal"))
            ply:SetHealth(ply_hp + math.max(0, healing - excessive_healing))
            ply:EmitSound("items/smallmedkit1.wav", 70, 100, 1, CHAN_AUTO)
        end

        function ENT:Powerup(ply) 
            local id = self:GetNWString(gl .. "powerup_id")  
            print("POWER ID " .. id)

            for powerup_id, data in pairs(powerups) do 
                if powerup_id == id then 
                    data.use_powerup(ply, self:GetNWFloat(gl .. "powerup_mod"))
                    ply:EmitSound("garlic_like/powerup_pickup_" .. id .. ".wav")
                end
            end
        end

        function ENT:Use(ply) 
            self:StartTouch(ply)
        end

        function ENT:DetermineItemDrop(determine_tier)
            -- print("INIT DETERMINED TIER: " .. determine_tier)

            local dropped_ent = {
                name = "",
                id = "",
                rarity = "", 
                model = "", 
                particle_trail = "",
                particle_beam = "",
            }  

            if self:GetNWBool(gl .. "is_reroll_crystal") then 
                dropped_ent.name = "Reroll Crystal"
                dropped_ent.id = "reroll_crystal"
                dropped_ent.rarity = "common"
                dropped_ent.model = "models/fortnite_crafting/fortnite_crafting_materials/quartz_crystal.mdl"
                dropped_ent.particle_trail = "loot_trail_" .. dropped_ent.rarity
                dropped_ent.particle_beam = "loot_beam_rarity_" .. dropped_ent.rarity
            end

            if self:GetNWBool(gl .. "is_element_crystal") then 
                dropped_ent.name = "Element Crystal"
                dropped_ent.id = "element_crystal"
                dropped_ent.rarity = "legendary"
                dropped_ent.model = "models/fortnite_crafting/fortnite_crafting_materials/brightcore_ore.mdl"
                dropped_ent.particle_trail = "loot_trail_" .. dropped_ent.rarity
                dropped_ent.particle_beam = "loot_beam_rarity_" .. dropped_ent.rarity
            end

            if self:GetNWBool(gl .. "is_crate_key") then 
                dropped_ent.name = "Crate Key"
                dropped_ent.id = "crate_key"
                dropped_ent.rarity = "common"
                dropped_ent.model = "models/mannco/mannkey.mdl"
                dropped_ent.particle_trail = "loot_trail_" .. dropped_ent.rarity
                dropped_ent.particle_beam = "loot_beam_rarity_" .. dropped_ent.rarity
            end

            if self:GetNWBool(gl .. "is_food") then 
                local food_item = food_items[math.random(1, #food_items)] 
                dropped_ent.name = food_item.name
                dropped_ent.rarity = food_item.rarity
                dropped_ent.model = food_item.model
                dropped_ent.particle_trail = "loot_trail_" .. dropped_ent.rarity
                dropped_ent.particle_beam = "loot_beam_rarity_" .. dropped_ent.rarity
                --
                self:SetNWFloat(gl .. "food_hp_heal", food_item.healing_amount)  
                self:SetNWFloat(gl .. "food_mana_heal", food_item.mana_healing)   
            end

            if self:GetNWBool(gl .. "is_powerup") then 
                local powerup_id
                local powerup_name
                local bg_id 

                for id, data in RandomPairs(powerups) do 
                    -- if id ~= "InstaKill" then continue end
                    -- if id ~= "FullPower" then continue end
                    -- if id ~= "DoublePoints" then continue end
                    powerup_id = id 
                    powerup_name = data.name
                    bg_id = data.bodygroup_id
                    break  
                end

                dropped_ent.name = powerup_name
                dropped_ent.rarity = "legendary"
                dropped_ent.model = "models/codvanguard/other/powerups.mdl"
                dropped_ent.particle_trail = "loot_trail_" .. dropped_ent.rarity
                dropped_ent.particle_beam = "loot_beam_rarity_" .. dropped_ent.rarity

                self:SetNWString(gl .. "powerup_id", powerup_id)
                self:SetNWInt(gl .. "bodygroup_id", bg_id)

                local multiplier = 1                

                if powerup_id == "InstaKill" then  
                    multiplier = math.Truncate(math.random(1, 3) + math.Rand(0.1, 1), 2) 

                    timer.Simple(0.1, function()
                        if not IsValid(self) then return end
                        self:SetNWString(gl .. "item_name", "+" .. (multiplier) * 100 .. "% " .. self:GetNWString(gl .. "item_name")) 
                    end)
                elseif powerup_id == "DoublePoints" then  
                    multiplier = math.Truncate(math.random(1, 1.5) + math.Rand(0.1, 0.5), 2) 
                    
                    timer.Simple(0.1, function()
                        if not IsValid(self) then return end
                        self:SetNWString(gl .. "item_name", "+" .. (multiplier) * 100 .. "% " .. self:GetNWString(gl .. "item_name")) 
                    end)
                end

                self:SetNWFloat(gl .. "powerup_mod", multiplier) 
            end

            if self:GetNWBool(gl .. "is_ore") then 
                if determine_tier == "RANDOM" then
                    dropped_ent = rarities[math.random(1, #rarities)]
                else
                    -- print("DETERMINED TIER: " .. determine_tier)
                    for k, rarity_entry in pairs(rarities) do
                        if rarity_entry.rarity == determine_tier then
                            dropped_ent = rarities[k]
                        end
                    end
                end
            end

            -- print("CHOSEN RARITY TABLE: ")
            -- PrintTable(dropped_ent)

            if dropped_ent.id then self:SetNWString(gl .. "item_id", dropped_ent.id) end     
            self:SetNWString(gl .. "item_name", dropped_ent.name)        
            self:SetNWString(gl .. "item_rarity", dropped_ent.rarity)
            self:SetNWString(gl .. "item_crystal_model", dropped_ent.model)
            self:SetNWString(gl .. "item_trail", dropped_ent.particle_trail)
            self:SetNWString(gl .. "item_beam", dropped_ent.particle_beam)
            --
            self:ParticleInit("trail")
        end

        function ENT:ParticleInit(particle_type)
            self:StopParticles()

            if particle_type == "trail" then
                ParticleEffectAttach(self:GetNWString(gl .. "item_trail"), PATTACH_POINT_FOLLOW, self, -1)
            end

            if particle_type == "beam" then
                ParticleEffectAttach(self:GetNWString(gl .. "item_beam"), PATTACH_POINT_FOLLOW, self, -1)
            end
        end

        function ENT:Launch()
            local phys = self:GetPhysicsObject()
            self:SetPos(self:GetPos() + Vector(0, 0, 3))
            phys:ApplyForceCenter(self:GetAngles():Up() * 7000)
            phys:ApplyForceCenter(self:GetAngles():Right() * 2500 * math.Rand(-1, 1))
            phys:ApplyForceCenter(self:GetAngles():Forward() * 1250 * math.Rand(-1, 1))
            self:EmitSound("garlic_like/item_drop_sounds/item_launch.wav", 120, 100, 1, CHAN_AUTO)
        end

        function ENT:PhysicsCollide(data, phys)
            if data.Speed > 15 and data.DeltaTime > 0.1 then
                self:SetNWBool(gl .. "collided", true)
            end
        end

        function ENT:MergeDrop() 
            for k, ent in pairs(ents.FindInSphere(self:GetPos(), 200)) do 
                if ent ~= self and self:GetNWInt(gl .. "item_amount") and ent:GetNWBool(gl .. "settled") and ent:GetClass() == self:GetClass() and ent:GetNWString(gl .. "item_name") == self:GetNWString(gl .. "item_name") and ent:GetNWString(gl .. "item_rarity") == self:GetNWString(gl .. "item_rarity") then 
                    self:SetNWInt(gl .. "item_amount", self:GetNWInt(gl .. "item_amount") + ent:GetNWInt(gl .. "item_amount"))
                    SafeRemoveEntity(ent)
                end
            end
        end

        function ENT:Think()
            if not IsValid(self) then return end

            if self:GetNWBool(gl .. "collided") and self:GetNWBool(gl .. "ready_to_settle") and not self:GetNWBool(gl .. "settled") then
                self:SetNWBool(gl .. "settled", true)

                timer.Simple(0.4, function()
                    if not IsValid(self) then return end
                    --
                    -- print("MODEL USED: " .. self:GetNWString(gl .. "item_crystal_model"))
                    self:SetNWBool(gl .. "settled_2", true)

                    if self.ParticleInit then 
                        self:ParticleInit("beam")
                    end 

                    self:MergeDrop()
                    
                    self:EmitSound("garlic_like/item_drop_sounds/item_drop_" .. self:GetNWString(gl .. "item_rarity") .. ".wav", 120, 100, 1, CHAN_AUTO)
                end)
            end

            -- if self:GetNWBool(gl .. "is_powerup") then 
            --     if self:GetNWString(gl .. "powerup_id") == "InstaKill" then 
                    
            --     elseif self:GetNWString(gl .. "powerup_id") == "DoublePoints" then 

            --     end
            -- end
        end
    end

    if CLIENT then
        function ENT:Initialize()
            timer.Simple(0.15, function()
                if not IsValid(self) then return end 

                if self:GetNWString(gl .. "item_rarity") == nil then
                    self:SetNWString(gl .. "item_rarity", "poor")
                end

                -- self.crystal_model = ClientsideModel(self:GetNWString(gl .. "item_crystal_model", "models/fortnite_crafting/fortnite_crafting_materials/copper_ore.mdl"))
                self.gl_model_set = true
            end)
        end

        function ENT:Draw()
            if self.crystal_model == nil then 
                self.crystal_model = ClientsideModel(self:GetNWString(gl .. "item_crystal_model")) 
                
                if self:GetNWBool(gl .. "is_powerup") then 
                    ParticleEffectAttach("superrare_plasma2", PATTACH_ABSORIGIN_FOLLOW, self.crystal_model, 0)
                end
            end

            if self.crystal_model then 
                if self:GetNWInt(gl .. "bodygroup_id") == 0 then 
                    self.crystal_model:SetBodygroup(0, 0)                
                else 
                    self.crystal_model:SetBodygroup(0, 1)               
                    self.crystal_model:SetBodygroup(self:GetNWInt(gl .. "bodygroup_id"), 1)                
                end
            end
            
            if self.gl_model_set and self.crystal_model ~= nil then
                self.crystal_model:SetPos(self:GetPos() + Vector(0, 0, 1) + Vector(0, 0, math.cos(CurTime() * 2.5) * 3))
                self.crystal_model:SetAngles(Angle(0, (CurTime() * 75) % 360, 0))
            end
        end

        function ENT:OnRemove()      
            SafeRemoveEntity(self.crystal_model)      
        end
    end

    scripted_ents.Register(ENT, gl .. "wep_crystal")
end

--* gem crate
do
    local gl_crate = {}
    gl_crate.Type = "anim"
    gl_crate.Base = "base_anim"
    gl_crate.PrintName = "Garlic Like Crate"
    gl_crate.Category = "Garlic Like"
    gl_crate.Spawnable = true 

    if SERVER then
        function gl_crate:Initialize()
            self:SetModel("models/mannco/manncrate.mdl")
            self:PhysicsInit(SOLID_VPHYSICS) 
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            self:GetPhysicsObject():Wake()
            self:SetCollisionGroup(COLLISION_GROUP_WORLD)
            self:SetUseType(SIMPLE_USE) 
            --
            self:SetRenderMode(RENDERMODE_NORMAL)
            self:SetTrigger(true)
            self.IsUsed = false 
            self.seal_top = ents.Create("prop_physics")
            self.seal_top:PhysicsInit(SOLID_VPHYSICS)
            self.seal_top:SetMoveType(MOVETYPE_VPHYSICS)
            self.seal_top:SetSolid(SOLID_VPHYSICS)
            self.seal_top:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            self.seal_top:SetModel("models/mannco/manncratemptycap.mdl")
            self.seal_top:Spawn() 

            timer.Simple(0.1, function()
                if not IsValid(self) then return end
                self.seal_top:SetMoveParent(self)
                self.seal_top:SetPos(Vector(0, 0, 65))
            end) 
        end

        function gl_crate:OpenCrate(ply) 
            self:EmitSound("garlic_like/item_drop_sounds/item_open_crate_short.wav", 120, 100, 1, CHAN_AUTO)

            timer.Simple(4, function()
                if not IsValid(self) then return end
                self:EmitSound("garlic_like/item_drop_sounds/item_open_crate_boom.wav", 120, 100, 1, CHAN_AUTO)
                self.seal_top_pos = self.seal_top:GetPos()
                self.seal_top:SetParent(nil)
                local phys = self.seal_top:GetPhysicsObject()
                self.seal_top:SetPos(self.seal_top_pos)
                phys:SetMass(100)
                phys:ApplyForceCenter(self:GetAngles():Up() * 50000)
                phys:ApplyForceCenter(self:GetAngles():Right() * 2500 * math.Rand(-1, 1))
                phys:ApplyForceCenter(self:GetAngles():Forward() * 1250 * math.Rand(-1, 1))
                phys:AddAngleVelocity(Vector(200, 0, 0))
                self:SetModel("models/mannco/manncratempty.mdl")
                ParticleEffect("versus_door_slam", self.seal_top_pos, Angle(0, 0, 0), self)

                timer.Create(tostring(self:EntIndex() .. "create_drops"), 0.1, math.random(25, 50), function()
                    if not IsValid(self) then return end
                    self:CreateDrop()
                end)
            end)

            SafeRemoveEntityDelayed(self.seal_top, 10)
            SafeRemoveEntityDelayed(self, 10)
        end

        function gl_crate:Use(ply)
            print(ply:GetNWInt(gl .. "held_num_material_Crate Key", 0))
            if not self.IsUsed and ply:GetNWInt(gl .. "held_num_material_Crate Key", 0) > 0 then 
                self.IsUsed = true
                ply:SetPData(gl .. "held_num_material_Crate Key", ply:GetPData(gl .. "held_num_material_Crate Key", 0) - 1)
                ply:SetNWInt(gl .. "held_num_material_Crate Key", tonumber(ply:GetPData(gl .. "held_num_material_Crate Key", 0)))        

                net.Start(gl .. "update_database_sv_to_cl")
                net.WriteEntity(ply)
                net.WriteString("update_held_num_materials")
                net.WriteString("Crate Key")
                net.WriteString("common")
                net.WriteInt(-1, 32)
                net.WriteBool(true)
                net.Send(ply)  

                self:OpenCrate(ply)
            end
        end

        function gl_crate:IsNumBetween(x, min, max)
            return x >= min and x <= max
        end

        function gl_crate:CreateDrop()
            self:EmitSound("garlic_like/item_drop_sounds/item_launch.wav", 100, 100, 0.75, CHAN_AUTO)
            local number = math.random(1, FROZE_GL.rarity_weights_sum_gems)

            for rarity, entry in pairs(FROZE_GL.rarity_weights) do
                if self:IsNumBetween(number, entry.min, entry.max) then 
                    -- print("GEM RARITY FROM CRATE IS: " .. rarity)
                    
                    if rarity == nil or rarity == "" then 
                        rarity = "common"
                    end
                    
                    garlic_like_create_material_drop(self, self, "ore", rarity, math.Round(math.random(1, 3) * (1 + math.max(0, GetGlobalBool(gl .. "minutes", 1) * 0.1))), Vector(0, 0, 65))
                end
            end

            if math.random() <= 0.5 then      
                garlic_like_create_material_drop(self, self, "reroll_crystal", "", math.Round(math.random(1, 3) * (1 + math.max(0, GetGlobalBool(gl .. "minutes", 1) * 0.1))), Vector(0, 0, 65))                 
            end

            if math.random() <= 0.1 then      
                garlic_like_create_material_drop(self, self, "element_crystal", "", math.Round(1 * (1 + math.max(0, GetGlobalBool(gl .. "minutes", 1) * 0.1))), Vector(0, 0, 65))                 
            end
        end
    end

    scripted_ents.Register(gl_crate, gl .. "crate")
end

--* enemy fireball
do 
    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_anim"
    ENT.PrintName = "Garlic Like Enemy Fireball"
    ENT.Spawnable = false

    if SERVER then 
        function ENT:Initialize()
            self:SetModel("models/hunter/misc/sphere025x025.mdl") 
            self:SetSolid(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetColor(Color(255, 255, 255, 0))
            self:SetRenderMode(RENDERMODE_TRANSCOLOR)
            self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
            self:SetTrigger(true)
            self.OwnerPos = self:GetOwner():GetPos()  
            self.WorldMaxs = self:GetOwner():LocalToWorld(self:GetOwner():OBBMaxs())
            self.ThinkCD = 0
            self.Lifetime = 0

            timer.Simple(0.1, function()
                if (IsValid(self) and not IsValid(self:GetOwner())) or not IsValid(self) or not self.OwnerPos then 
                    SafeRemoveEntity(self)
                    return
                end
                
                garlic_like_attach_particle(self, "ATTACH", "jakiro_base_attack_fire") 
                self:SetPos(Vector(self.OwnerPos.x, self.OwnerPos.y, self.WorldMaxs.z + 50))
                self:SetParent(self:GetOwner())
            end)
        end

        function ENT:Shoot()
            timer.Simple(0.1, function() 
                if not IsValid(self) then return end 
                self.Launched = true
                self:SetParent(nil)
                --
                self:EmitSound("dota2/enemy_fireball_shoot.wav", 90, 100, 1, CHAN_AUTO) 
                self:PhysicsInit(SOLID_VPHYSICS) 
                self.phys = self:GetPhysicsObject()
                self.ang = (self:GetPos() - self:GetNWEntity(gl .. "fireball_target"):GetPos()):Angle()
                self:SetAngles(Angle(-self.ang.x, self.ang.y + 180, self.ang.z))
                -- self:SetAngles(self:GetOwner():EyeAngles())
                self.phys:SetMass(5)
                self.phys:EnableGravity(false)
                self.phys:ApplyForceCenter((self:GetAngles():Forward() * 5000))
                -- self.phys:ApplyForceCenter((self:GetAngles():Forward() * 7000) + (self:GetAngles():Up() * 500))
                -- self:GetPhysicsObject():ApplyForceCenter((self.Target:LocalToWorld(self.Target:OBBCenter()) - self:GetPos()) * Vector(3, 3, 3))
                SafeRemoveEntityDelayed(self, 5)
            end)
        end

        function ENT:StartTouch(ent)
            if ent == self:GetOwner() or ent:GetOwner() == self:GetOwner() then return end
            -- print(ent)
            --
            -- print("FIREBALL COLLLDIE TPICJ")
            self:Explode()
        end

        function ENT:PhysicsCollide(data, collider)
            if data.HitEntity:GetClass() == self:GetClass() or data.HitEntity == self:GetOwner() or data.HitEntity:GetOwner() == self:GetOwner() then return end
            -- print("FIREBALL COLLLDIE")
 
            self:Explode() 
        end

        function ENT:Think() 
            if self.ThinkCD < CurTime() and not self.Launched then 
                self.ThinkCD = CurTime() + 0.25
                self.Lifetime = self.Lifetime + 0.25

                for k, ent in pairs(ents.FindInSphere(self:GetOwner():GetPos(), 1000)) do 
                    if self:GetOwner():IsPlayer() and (ent:IsNPC() or ent:IsNextBot()) then 
                        self:SetNWEntity(gl .. "fireball_target", ent)
                    elseif (self:GetOwner():IsNPC() or self:GetOwner():IsNextBot()) and ent:IsPlayer() then 
                        self:SetNWEntity(gl .. "fireball_target", ent)
                    end
                end

                self.Target = self:GetNWEntity(gl .. "fireball_target")
                --
                if not IsValid(self.Target) then return end
                --
                local tr = util.TraceLine( {
                    start = self:GetPos(),
                    endpos = self.Target:LocalToWorld(self.Target:OBBCenter()),
                    filter = {self:GetOwner(), self},
                    ignoreworld = false, 
                    collisiongroup = COLLISION_GROUP_PROJECTILE,
                } )

                if self.Lifetime >= 5 and tr.Entity == self.Target and self:GetPos():DistToSqr(self.Target:GetPos()) < 1000000 then 
                    self:Shoot()
                end
            end
        end

        function ENT:Explode() 
            if IsValid(self:GetOwner()) then 
                self:GetOwner().HasFieryFireball = false
            end 

            self:EmitSound("dota2/liquid_fire.wav", 140, 100, 1, CHAN_AUTO)
            ParticleEffect("jakiro_liquid_fire_explosion", self:GetPos(), Angle(0, 0, 0))

            for k, ent in pairs(ents.FindInSphere(self:GetPos(), 200)) do 
                if (ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer()) and ent ~= self:GetOwner() then 
                    garlic_like_proc_fire(self:GetOwner(), ent, 2)
                end
            end

            SafeRemoveEntity(self)
        end
    end
    
    scripted_ents.Register(ENT, gl .. "enemy_fireball")
end

--* enemy poison attack
do 
    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_anim"
    ENT.PrintName = "Garlic Like Enemy Poison Attack"
    ENT.Spawnable = false

    if SERVER then 
        function ENT:Initialize()
            self:SetModel("models/hunter/misc/sphere025x025.mdl") 
            self:SetSolid(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetColor(Color(255, 255, 255, 0))
            self:SetRenderMode(RENDERMODE_TRANSCOLOR)
            self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
            self:SetTrigger(true)
            self.OwnerPos = self:GetOwner():GetPos()  
            self.WorldMaxs = self:GetOwner():LocalToWorld(self:GetOwner():OBBMaxs())
            self.ThinkCD = 0
            self.Lifetime = 0

            timer.Simple(0.1, function()
                if (IsValid(self) and not IsValid(self:GetOwner())) or not IsValid(self) or not self.OwnerPos then 
                    SafeRemoveEntity(self)
                    return
                end
                
                garlic_like_attach_particle(self, "ATTACH", "viper_poison_attack") 
                self:SetPos(Vector(self.OwnerPos.x, self.OwnerPos.y, self.WorldMaxs.z + 50))
                self:SetParent(self:GetOwner())
            end)
        end

        function ENT:Shoot()
            if self.Launched then return end 

            timer.Simple(0.1, function() 
                if not IsValid(self) then return end 
                self.Launched = true
                self:SetParent(nil)
                --
                -- self:EmitSound("dota2/enemy_poisonball_shoot.wav", 90, 100, 1, CHAN_AUTO) 
                self:PhysicsInit(SOLID_VPHYSICS) 
                self.phys = self:GetPhysicsObject()
                self.ang = (self:GetPos() - self:GetNWEntity(gl .. "poisonball_target"):GetPos()):Angle()
                self:SetAngles(Angle(-self.ang.x, self.ang.y + 180, self.ang.z))
                -- self:SetAngles(self:GetOwner():EyeAngles())
                self.phys:SetMass(5)
                self.phys:EnableGravity(false)
                self.phys:ApplyForceCenter((self:GetAngles():Forward() * 3000))
                -- self.phys:ApplyForceCenter((self:GetAngles():Forward() * 7000) + (self:GetAngles():Up() * 500))
                -- self:GetPhysicsObject():ApplyForceCenter((self.Target:LocalToWorld(self.Target:OBBCenter()) - self:GetPos()) * Vector(3, 3, 3))
                SafeRemoveEntityDelayed(self, 5)
            end)
        end

        function ENT:StartTouch(ent)
            if ent == self:GetOwner() or ent:GetOwner() == self:GetOwner() then return end
            -- print(ent)
            -- 
            self:Explode()
        end

        function ENT:PhysicsCollide(data, collider)
            if data.HitEntity:GetClass() == self:GetClass() or data.HitEntity == self:GetOwner() or data.HitEntity:GetOwner() == self:GetOwner() then return end
            
            self:Explode() 
        end

        function ENT:Think() 
            if self.LifetimeAfterShot and self.LifetimeAfterShot < 1 and self.phys then  
                -- print("TRACKIGN")
                self.phys = self:GetPhysicsObject()
                self.ang = (self:GetPos() - self:GetNWEntity(gl .. "poisonball_target"):GetPos()):Angle()
                self:SetAngles(Angle(-self.ang.x, self.ang.y + 180, self.ang.z))
                self.phys:ApplyForceCenter((self:GetAngles():Forward() * 2500))
            end

            if self.ThinkCD < CurTime() then 
                self.ThinkCD = CurTime() + 0.25

                if self.LifetimeAfterShot then 
                    self.LifetimeAfterShot = self.LifetimeAfterShot + 0.25 
                end

                if not self.Launched then 
                    self.Lifetime = self.Lifetime + 0.25

                    for k, ent in pairs(ents.FindInSphere(self:GetOwner():GetPos(), 1000)) do 
                        if self:GetOwner():IsPlayer() and (ent:IsNPC() or ent:IsNextBot()) then 
                            self:SetNWEntity(gl .. "poisonball_target", ent)
                        elseif (self:GetOwner():IsNPC() or self:GetOwner():IsNextBot()) and ent:IsPlayer() then 
                            self:SetNWEntity(gl .. "poisonball_target", ent)
                        end
                    end

                    self.Target = self:GetNWEntity(gl .. "poisonball_target")
                    --
                    if not IsValid(self.Target) then return end
                    --
                    local tr = util.TraceLine( {
                        start = self:GetPos(),
                        endpos = self.Target:LocalToWorld(self.Target:OBBCenter()),
                        filter = {self:GetOwner(), self},
                        ignoreworld = false, 
                        collisiongroup = COLLISION_GROUP_PROJECTILE,
                    } )

                    if self.Lifetime >= 3 and tr.Entity == self.Target and self:GetPos():DistToSqr(self.Target:GetPos()) < 1000000 then 
                        -- print("SHOOT PROJETILE")
                        self:Shoot()

                        if not self.LifetimeAfterShot then 
                            self.LifetimeAfterShot = 0
                        end 
                    end
                end
            end
        end

        function ENT:Explode() 
            if IsValid(self:GetOwner()) then 
                self:GetOwner().HasPoisonBall = false
            end 

            -- self:EmitSound("dota2/liquid_fire.wav", 140, 100, 1, CHAN_AUTO)
            ParticleEffect("viper_poison_attack_explosion", self:GetPos(), Angle(0, 0, 0))

            for k, ent in pairs(ents.FindInSphere(self:GetPos(), 75)) do 
                if (ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer()) and ent ~= self:GetOwner() then 
                    garlic_like_proc_poison(self:GetOwner(), ent, 20, nil) 
                end
            end

            SafeRemoveEntity(self)
        end

        function ENT:OnRemove() 
            if IsValid(self:GetOwner()) then 
                self:GetOwner().HasPoisonBall = false
            end 
        end
    end
    
    scripted_ents.Register(ENT, gl .. "enemy_poisonball")
end

--* enemy lightning attack 
do  
    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_anim"
    ENT.PrintName = "Garlic Like Enemy Thunder Attack"
    ENT.Spawnable = false
    
    if SERVER then 
        function ENT:Initialize()
            self:SetModel("models/hunter/misc/sphere025x025.mdl") 
            self:SetSolid(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetColor(Color(255, 255, 255, 0))
            self:SetRenderMode(RENDERMODE_TRANSCOLOR)
            self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
            self:SetTrigger(true)
            self.OwnerPos = self:GetOwner():GetPos()  
            self.WorldMaxs = self:GetOwner():LocalToWorld(self:GetOwner():OBBMaxs())
            self.ThinkCD = 0
            self.Lifetime = 0

            timer.Simple(0.1, function()
                if (IsValid(self) and not IsValid(self:GetOwner())) or not IsValid(self) or not self.OwnerPos then 
                    SafeRemoveEntity(self)
                    return
                end
                
                garlic_like_attach_particle(self, "ATTACH", "disruptor_thunder_strike_buff") 
                self:SetPos(Vector(self.OwnerPos.x, self.OwnerPos.y, self.WorldMaxs.z + 50))
                self:SetParent(self:GetOwner())
            end)
        end

        function ENT:Shoot()
            --* DOES NOTHING
            if self.Launched then return end 

            timer.Simple(0.1, function() 
                if not IsValid(self) then return end  
            end)
        end

        function ENT:StartTouch(ent)
            if ent == self:GetOwner() or ent:GetOwner() == self:GetOwner() then return end 
            -- 
            self:Explode()
        end

        function ENT:PhysicsCollide(data, collider)
            if data.HitEntity:GetClass() == self:GetClass() or data.HitEntity == self:GetOwner() or data.HitEntity:GetOwner() == self:GetOwner() then return end
            
            self:Explode() 
        end

        function ENT:Think()   
            if self.ThinkCD < CurTime() then 
                self.ThinkCD = CurTime() + 1
                self.Lifetime = self.Lifetime + 1
                 
                self:Explode()
            end
        end

        function ENT:Explode() 
            if IsValid(self:GetOwner()) then 
                self:GetOwner().HasThunderball = false
            end 

            self:EmitSound("dota2/thunder_strike_target.wav", 140, 100, 1, CHAN_AUTO)
            ParticleEffect("disruptor_thuderstrike_aoe_area", self:GetOwner():GetPos(), Angle(0, 0, 0))

            local TB_dmg = DamageInfo() 
            TB_dmg:SetInflictor(self:GetOwner()) 
            TB_dmg:SetAttacker(self:GetOwner())
            TB_dmg:SetDamageType(DMG_SHOCK)
            TB_dmg:SetDamage(40)

            for k, ent in pairs(ents.FindInSphere(self:GetOwner():GetPos(), 225)) do 
                if ent:IsPlayer() then 
                    ent:TakeDamageInfo(TB_dmg)
                end
            end
 
        end

        function ENT:OnRemove() 
            if IsValid(self:GetOwner()) then 
                self:GetOwner().HasThunderBall = false
            end 
        end
    end

    scripted_ents.Register(ENT, gl .. "enemy_thunderball")
end

--* crystal cluster 
do  
    local rarities = {"poor", "common", "uncommon", "rare", "epic", "legendary", "god"}
    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_anim"
    ENT.PrintName = "Crystal Cluster"
    ENT.Category = "Garlic Like"
    ENT.Spawnable = true
    ENT.GL_HealthbarValid = true

    if SERVER then 
        function ENT:Initialize()
            self:SetModel("models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_huge_a.mdl")
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_FLY)
            self:SetSolid(SOLID_VPHYSICS)
            self:SetUseType(SIMPLE_USE)
            self:SetMaxHealth(200 * math.random(50, 100) / 100 * (1 + GetGlobalFloat(gl .. "enemy_modifier_hp", 0))) 
            self:SetHealth(self:GetMaxHealth())
            self.RarityNum = math.random(1, rarity_weights_max)
            -- print("CLUSTER SPAWNED")

            for k, v in pairs(tbl_rarity_weights) do 
                if IsNumBetween(self.RarityNum, v.weight_min, v.weight_max) then 
                    self:SetNWString(gl .. "item_rarity", v.rarity)    
                    self:SetColor(v.color) 
                end
            end            
        
            local physObj = self:GetPhysicsObject()
            if not physObj:IsValid() then return end
            physObj:Wake()
            physObj:SetMass(physObj:GetMass() * 10)
            --
            self:SetName(gl .. "crystal_cluster_" .. self:GetNWString(gl .. "item_rarity")) 
        end

        function ENT:OnTakeDamage(dmg) 
            if not dmg:GetAttacker():IsPlayer() then return end 
            local mod_timer = 1 + math.max(0, GetGlobalInt(gl .. "minutes", 1) / 10)
            -- print("GETTING HIT")
            --
            local ply = dmg:GetAttacker()
            local dmg_num = dmg:GetDamage()
            -- print(dmg_num)
            local gem_gain = math.Remap(dmg_num, 0, self:GetMaxHealth(), 1, 20 * mod_timer)
            self:SetHealth(self:Health() - dmg_num)  

            net.Start(gl .. "update_database_sv_to_cl")
            net.WriteEntity(ply)
            net.WriteString("update_held_num_ores")
            net.WriteString("Ore")
            net.WriteString(self:GetNWString(gl .. "item_rarity", "poor"))
            net.WriteInt(gem_gain, 32)
            net.WriteBool(true)
            net.Send(ply)
            --
            if self:Health() < 0 then 
                SafeRemoveEntity(self)
            end
        end
        
        function ENT:Use(ply)
        
        end
    end

    scripted_ents.Register(ENT, gl .. "crystal_cluster")
end

--* loot barrel 
do 
    local tbl_ammo = {
        "item_ammo_357",
        "item_ammo_ar2",
        "item_ammo_pistol",
        "item_ammo_smg1",
        "item_ammo_357",
        "item_box_buckshot",
        "item_rpg_round",
        "item_ammo_crossbow", 
    }  

    local tbl_ammo_names = {
        "AR2",
        "AR2AltFire",
        "Pistol",
        "SMG1",
        "357",
        "XBowBolt",
        "RPG_Round",
        "SMG1_Grenade",
        "Grenade",
        "357Round",
        "Buckshot",
    } 

    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_anim"
    ENT.PrintName = "Item Barrel"
    ENT.Category = "Garlic Like"
    ENT.Spawnable = true 
    ENT.GL_HealthbarValid = true
    
    if SERVER then 
        function ENT:Initialize() 
            self:SetModel("models/barrel/barrel.mdl")
            self:PhysicsInit(SOLID_VPHYSICS)
            -- self:SetMoveType(MOVETYPE_FLY)
            self:SetSolid(SOLID_VPHYSICS)
            self:SetUseType(SIMPLE_USE)
            self:SetMaxHealth(5 * math.random(50, 100) / 100 * (1 + GetGlobalFloat(gl .. "enemy_modifier_hp", 0))) 
            self:SetHealth(self:GetMaxHealth()) 
            -- print("CLUSTER SPAWNED")     
        
            local physObj = self:GetPhysicsObject()
            if not physObj:IsValid() then return end
            physObj:Wake()
            physObj:SetMass(physObj:GetMass() * 10)  
        end

        function ENT:OnTakeDamage(dmg) 
            if not dmg:GetAttacker():IsPlayer() then return end  
            --
            local ply = dmg:GetAttacker()
            local dmg_num = dmg:GetDamage() 
            self:SetHealth(self:Health() - dmg_num)  
  
            if self:Health() < 0 then  
                for i = 1, math.random(2, 4) do
                    garlic_like_create_material_drop(ply, self, "food", "common", 1, Vector(0, 0, 30))

                    for i = 3, 4 do 
                        for ammo_name, value in pairs(tbl_ammo_refill_amount) do 
                            ply:GiveAmmo(math.floor(value * math.Rand(0.4, 0.6)), ammo_name, false)
                        end 
                    end
                end 

                if math.random() <= 0.15 then 
                    garlic_like_create_material_drop(ply, self, "powerup", rarity, 1, Vector(0, 0, 30))
                end
         
                SafeRemoveEntity(self)
            end
        end
    end

    scripted_ents.Register(ENT, gl .. "item_barrel")
end

--* station - weapon upgrade
do 
    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_anim"
    ENT.PrintName = "Weapon Upgrade Station"
    ENT.Category = "Garlic Like"
    ENT.Spawnable = true 

    if SERVER then 
        function ENT:Initialize() 
            self:SetModel("models/mosi/fallout4/furniture/workstations/weaponworkbench01.mdl")
            self:PhysicsInit(SOLID_VPHYSICS) 
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS) 
            self:SetUseType(SIMPLE_USE) 
            self:SetNWBool(gl .. "settled_2", true)
            self:SetNWString(gl .. "item_name", self.PrintName)
            self.physObj = self:GetPhysicsObject() 
            if not IsValid(self.physObj) then return end 
            self.physObj:Wake()
            SafeRemoveEntityDelayed(self, 180)
        end

        function ENT:Use(ply) 
            if not ply:IsPlayer() then return end 
            --             
            ply:ConCommand(gl .. "debug_open_weapon_upgrade_menu BLACKSMITH") 
        end
    end

    scripted_ents.Register(ENT, gl .. "station_weapon_upgrade")
end

--* station - item fusing
do 
    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_anim"
    ENT.PrintName = "Item Fusing Station"
    ENT.Category = "Garlic Like"
    ENT.Spawnable = true 

    if SERVER then 
        function ENT:Initialize() 
            self:SetModel("models/mosi/fallout76/furniture/workstations/tinkerstation.mdl")
            self:PhysicsInit(SOLID_VPHYSICS) 
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS) 
            self:SetUseType(SIMPLE_USE) 
            self:SetNWBool(gl .. "settled_2", true)
            self:SetNWString(gl .. "item_name", self.PrintName)
            self.physObj = self:GetPhysicsObject() 
            if not IsValid(self.physObj) then return end 
            self.physObj:Wake()
            SafeRemoveEntityDelayed(self, 180)
        end

        function ENT:Use(ply) 
            if not ply:IsPlayer() then return end 
            --             
            ply:ConCommand(gl .. "debug_open_weapon_upgrade_menu FUSION") 
        end
    end

    scripted_ents.Register(ENT, gl .. "station_item_fusing")
end
--
if SERVER then
    local GL_tub_delays = {
        ["delay_smg"] = 0,
        ["delay_pistol"] = 0,
        ["delay_revolver"] = 0,
        ["delay_shotgun"] = 0,
        ["delay_scattergun"] = 0,
        ["delay_sniper"] = 0,
        ["delay_minigun"] = 0,
        ["delay_rocket"] = 0,
        ["delay_grenade_launcher"] = 0,
        ["delay_flamethrower"] = 0,
    }

    local bullet_smg
    local bullet_pistol
    local bullet_revolver
    local bullet_shotgun
    local bullet_scattergun
    local bullet_sniper
    local bullet_minigun
 
    do
        bullet_smg = {}
        bullet_smg.Damage = 24
        bullet_smg.Force = 10
        bullet_smg.Distance = 30000
        bullet_smg.Num = 1
        bullet_smg.Tracer = 1
        bullet_smg.TracerName = "bullet_shotgun_tracer01_red"
        bullet_smg.Spread = Vector(0.09, 0.09, 0)
        bullet_smg.IgnoreEntity = ent
        --
        bullet_pistol = {}
        bullet_pistol.Damage = 33
        bullet_pistol.Force = 10
        bullet_pistol.Distance = 30000
        bullet_pistol.Num = 1
        bullet_pistol.Tracer = 1
        bullet_pistol.TracerName = "bullet_shotgun_tracer01_red"
        bullet_pistol.Spread = Vector(0.08, 0.08, 0)
        bullet_pistol.IgnoreEntity = ent
        --
        bullet_revolver = {}
        bullet_revolver.Damage = 75
        bullet_revolver.Force = 100
        bullet_revolver.Distance = 30000
        bullet_revolver.Num = 1
        bullet_revolver.Tracer = 1
        bullet_revolver.TracerName = "bullet_shotgun_tracer01_red"
        bullet_revolver.Spread = Vector(0.1, 0.1, 0)
        bullet_revolver.IgnoreEntity = ent
        --
        bullet_shotgun = {}
        bullet_shotgun.Damage = 23
        bullet_shotgun.Force = 100
        bullet_shotgun.Distance = 30000
        bullet_shotgun.Num = 9
        bullet_shotgun.Tracer = 1
        bullet_shotgun.TracerName = "bullet_shotgun_tracer01_red"
        bullet_shotgun.Spread = Vector(0.12, 0.12, 0)
        bullet_shotgun.IgnoreEntity = ent
        --
        bullet_scattergun = {}
        bullet_scattergun.Damage = 24
        bullet_scattergun.Force = 100
        bullet_scattergun.Distance = 30000
        bullet_scattergun.Num = 16
        bullet_scattergun.Tracer = 1
        bullet_scattergun.TracerName = "bullet_scattergun_tracer01_red"
        bullet_scattergun.Spread = Vector(0.13, 0.13, 0)
        bullet_scattergun.IgnoreEntity = ent
        --
        bullet_sniper = {}
        bullet_sniper.Damage = 150
        bullet_sniper.Force = 300
        bullet_sniper.Distance = 30000
        bullet_sniper.Num = 1
        bullet_sniper.Tracer = 1
        bullet_sniper.TracerName = "bullet_shotgun_tracer01_red"
        bullet_sniper.Spread = Vector(0.02, 0.02, 0)
        bullet_sniper.IgnoreEntity = ent
        --
        bullet_minigun = {}
        bullet_minigun.Damage = 14
        bullet_minigun.Force = 25
        bullet_minigun.Distance = 30000
        bullet_minigun.Num = 4
        bullet_minigun.Tracer = 1
        bullet_minigun.TracerName = "bullet_shotgun_tracer01_red"
        bullet_minigun.Spread = Vector(0.075, 0.075, 0)
        bullet_minigun.IgnoreEntity = ent
    end

    hook.Add("Think", gl .. "tub_shoot_guns", function()
        entities = ents.GetAll()

        for k, ent in pairs(entities) do
            if ent:GetClass() == "base_anim" and ent:GetNWBool("GL_tub_child") then
                ent.owner = ent:GetOwner()
                local model = ent:GetModel()

                if ent.owner == nil then
                    ent.owner = Entity(1)
                end

                ent.lookup_muzzle = ent:LookupAttachment("muzzle")
                ent.muzzle_pos = ent:GetAttachment(ent.lookup_muzzle).Pos
                ent.end_trace_pos = ent.owner:GetEyeTrace().HitPos
                ent.angles = ent:GetAngles()

                if model == "models/weapons/w_models/w_smg.mdl" and GL_tub_delays["delay_smg"] < CurTime() then
                    ent:EmitSound("weapons/smg_shoot.wav", 120, 100, 1, CHAN_AUTO)
                    bullet_smg.Attacker = ent.owner
                    bullet_smg.Src = ent.muzzle_pos
                    bullet_smg.Dir = ent.owner:GetAimVector()
                    bullet_smg.Trajectory = bullet_smg.Src + (bullet_smg.Dir + Vector(math.Rand(-bullet_smg.Spread.x, bullet_smg.Spread.x), math.Rand(-bullet_smg.Spread.x, bullet_smg.Spread.x), math.Rand(-bullet_smg.Spread.x, bullet_smg.Spread.x))) * 10000
                    ent:FireBullets(bullet_smg)

                    ent.bPath = util.TraceLine({
                        start = bullet_smg.Src,
                        endpos = bullet_smg.Trajectory,
                        filter = ent
                    })

                    ParticleEffectAttach("muzzle_smg", PATTACH_POINT_FOLLOW, ent, ent.lookup_muzzle)
                    util.ParticleTracerEx("bullet_shotgun_tracer01_red", ent.muzzle_pos, ent.bPath.HitPos, false, ent:EntIndex(), ent.lookup_muzzle)
                    GL_tub_delays["delay_smg"] = CurTime() + 0.075
                elseif model == "models/weapons/w_models/w_pistol.mdl" and GL_tub_delays["delay_pistol"] < CurTime() then
                    ent:EmitSound("weapons/pistol_shoot.wav", 120, 100, 1, CHAN_AUTO)
                    bullet_pistol.Attacker = ent.owner
                    bullet_pistol.Src = ent.muzzle_pos
                    bullet_pistol.Dir = ent.owner:GetAimVector()
                    bullet_pistol.Trajectory = bullet_pistol.Src + (bullet_pistol.Dir + Vector(math.Rand(-bullet_pistol.Spread.x, bullet_pistol.Spread.x), math.Rand(-bullet_pistol.Spread.x, bullet_pistol.Spread.x), math.Rand(-bullet_pistol.Spread.x, bullet_pistol.Spread.x))) * 10000
                    ent:FireBullets(bullet_pistol)

                    ent.bPath = util.TraceLine({
                        start = bullet_pistol.Src,
                        endpos = bullet_pistol.Trajectory,
                        filter = ent
                    })

                    ParticleEffectAttach("muzzle_pistol", PATTACH_POINT_FOLLOW, ent, ent.lookup_muzzle)
                    util.ParticleTracerEx("bullet_shotgun_tracer01_red", ent.muzzle_pos, ent.bPath.HitPos, false, ent:EntIndex(), ent.lookup_muzzle)
                    GL_tub_delays["delay_pistol"] = CurTime() + 0.16
                elseif model == "models/weapons/w_models/w_revolver.mdl" and GL_tub_delays["delay_revolver"] < CurTime() then
                    ent:EmitSound("weapons/revolver_shoot.wav", 120, 100, 1, CHAN_AUTO)
                    bullet_revolver.Attacker = ent.owner
                    bullet_revolver.Src = ent.muzzle_pos
                    bullet_revolver.Dir = ent.owner:GetAimVector()
                    bullet_revolver.Trajectory = bullet_revolver.Src + (bullet_revolver.Dir + Vector(math.Rand(-bullet_revolver.Spread.x, bullet_revolver.Spread.x), math.Rand(-bullet_revolver.Spread.x, bullet_revolver.Spread.x), math.Rand(-bullet_revolver.Spread.x, bullet_revolver.Spread.x))) * 10000
                    ent:FireBullets(bullet_revolver)

                    ent.bPath = util.TraceLine({
                        start = bullet_revolver.Src,
                        endpos = bullet_revolver.Trajectory,
                        filter = ent
                    })

                    ParticleEffectAttach("muzzle_revolver", PATTACH_POINT_FOLLOW, ent, ent.lookup_muzzle)
                    util.ParticleTracerEx("bullet_shotgun_tracer01_red", ent.muzzle_pos, ent.bPath.HitPos, false, ent:EntIndex(), ent.lookup_muzzle)
                    GL_tub_delays["delay_revolver"] = CurTime() + 0.5
                elseif model == "models/weapons/w_models/w_shotgun.mdl" and GL_tub_delays["delay_shotgun"] < CurTime() then
                    ent:EmitSound("weapons/shotgun_shoot.wav", 120, 100, 1, CHAN_AUTO)
                    ParticleEffectAttach("muzzle_shotgun", PATTACH_POINT_FOLLOW, ent, ent.lookup_muzzle)
                    bullet_shotgun.Attacker = ent.owner
                    bullet_shotgun.Src = ent.muzzle_pos
                    bullet_shotgun.Dir = ent.owner:GetAimVector()
                    ent:FireBullets(bullet_shotgun)

                    for i = 1, bullet_shotgun.Num do
                        bullet_shotgun.Trajectory = bullet_shotgun.Src + (bullet_shotgun.Dir + Vector(math.Rand(-bullet_shotgun.Spread.x, bullet_shotgun.Spread.x), math.Rand(-bullet_shotgun.Spread.x, bullet_shotgun.Spread.x), math.Rand(-bullet_shotgun.Spread.x, bullet_shotgun.Spread.x))) * 10000

                        ent.bPath = util.TraceLine({
                            start = bullet_shotgun.Src,
                            endpos = bullet_shotgun.Trajectory,
                            filter = ent
                        })

                        ent.end_trace_pos_shotgun = ent.muzzle_pos + (ent.angles:Forward() + ent.angles:Up() * math.Rand(-0.05, 0.05) + ent.angles:Right() * math.Rand(-0.05, 0.05)) * 10000
                        util.ParticleTracerEx("bullet_shotgun_tracer01_red", ent.muzzle_pos, ent.bPath.HitPos, false, ent:EntIndex(), ent.lookup_muzzle)
                    end

                    GL_tub_delays["delay_shotgun"] = CurTime() + 0.6
                elseif model == "models/weapons/w_models/w_scattergun.mdl" and GL_tub_delays["delay_scattergun"] < CurTime() then
                    ent:EmitSound("weapons/scatter_gun_shoot.wav", 120, 100, 1, CHAN_AUTO)
                    ParticleEffectAttach("muzzle_scattergun", PATTACH_POINT_FOLLOW, ent, ent.lookup_muzzle)
                    bullet_scattergun.Attacker = ent.owner
                    bullet_scattergun.Src = ent.muzzle_pos
                    bullet_scattergun.Dir = ent.owner:GetAimVector()
                    ent:FireBullets(bullet_scattergun)

                    for i = 1, bullet_scattergun.Num do
                        bullet_scattergun.Trajectory = bullet_scattergun.Src + (bullet_scattergun.Dir + Vector(math.Rand(-bullet_scattergun.Spread.x, bullet_scattergun.Spread.x), math.Rand(-bullet_scattergun.Spread.x, bullet_scattergun.Spread.x), math.Rand(-bullet_scattergun.Spread.x, bullet_scattergun.Spread.x))) * 10000

                        ent.bPath = util.TraceLine({
                            start = bullet_scattergun.Src,
                            endpos = bullet_scattergun.Trajectory,
                            filter = ent
                        })

                        ent.end_trace_pos_scattergun = ent.muzzle_pos + (ent.angles:Forward() + ent.angles:Up() * math.Rand(-0.05, 0.05) + ent.angles:Right() * math.Rand(-0.05, 0.05)) * 10000
                        util.ParticleTracerEx("bullet_scattergun_tracer01_red", ent.muzzle_pos, ent.bPath.HitPos, false, ent:EntIndex(), ent.lookup_muzzle)
                    end

                    GL_tub_delays["delay_scattergun"] = CurTime() + 0.8
                elseif model == "models/weapons/w_models/w_sniperrifle.mdl" and GL_tub_delays["delay_sniper"] < CurTime() then
                    ent:EmitSound("weapons/sniper_shoot.wav", 120, 100, 1, CHAN_AUTO)
                    ParticleEffectAttach("muzzle_sniperrifle", PATTACH_POINT_FOLLOW, ent, ent.lookup_muzzle)
                    bullet_sniper.Attacker = ent.owner
                    bullet_sniper.Src = ent.muzzle_pos
                    bullet_sniper.Dir = ent.owner:GetAimVector()
                    bullet_sniper.Trajectory = bullet_sniper.Src + (bullet_sniper.Dir + Vector(math.Rand(-bullet_sniper.Spread.x, bullet_sniper.Spread.x), math.Rand(-bullet_sniper.Spread.x, bullet_sniper.Spread.x), math.Rand(-bullet_sniper.Spread.x, bullet_sniper.Spread.x))) * 10000
                    ent:FireBullets(bullet_sniper)

                    ent.bPath = util.TraceLine({
                        start = bullet_sniper.Src,
                        endpos = bullet_sniper.Trajectory,
                        filter = ent
                    })

                    util.ParticleTracerEx("bullet_shotgun_tracer01_red", ent.muzzle_pos, ent.bPath.HitPos, false, ent:EntIndex(), ent.lookup_muzzle)
                    GL_tub_delays["delay_sniper"] = CurTime() + 0.8
                elseif model == "models/weapons/w_models/w_minigun.mdl" and GL_tub_delays["delay_minigun"] < CurTime() then
                    if ent.minigun_sound == nil then
                        ent.minigun_sound = true
                        ent:EmitSound("weapons/minigun_shoot.wav", 120, 100, 1, CHAN_AUTO)
                    end

                    ParticleEffectAttach("muzzle_minigun", PATTACH_POINT_FOLLOW, ent, ent.lookup_muzzle)
                    bullet_minigun.Attacker = ent.owner
                    bullet_minigun.Src = ent.muzzle_pos
                    bullet_minigun.Dir = ent.owner:GetAimVector()
                    ent:FireBullets(bullet_minigun)

                    for i = 1, bullet_minigun.Num do
                        bullet_minigun.Trajectory = bullet_minigun.Src + (bullet_minigun.Dir + Vector(math.Rand(-bullet_minigun.Spread.x, bullet_minigun.Spread.x), math.Rand(-bullet_minigun.Spread.x, bullet_minigun.Spread.x), math.Rand(-bullet_minigun.Spread.x, bullet_minigun.Spread.x))) * 10000

                        ent.bPath = util.TraceLine({
                            start = bullet_minigun.Src,
                            endpos = bullet_minigun.Trajectory,
                            filter = ent
                        })

                        util.ParticleTracerEx("bullet_shotgun_tracer01_red", ent.muzzle_pos, ent.bPath.HitPos, false, ent:EntIndex(), ent.lookup_muzzle)
                    end

                    GL_tub_delays["delay_minigun"] = CurTime() + 0.1
                elseif model == "models/weapons/w_models/w_rocketlauncher.mdl" and GL_tub_delays["delay_rocket"] < CurTime() then
                    ent:EmitSound("weapons/rocket_shoot.wav", 120, 100, 1, CHAN_AUTO)
                    ent.rocket = ents.Create(gl .. "tf2_ultimate_rocket")
                    ent.rocket:SetOwner(ent)
                    ent.rocket:Spawn()
                    GL_tub_delays["delay_rocket"] = CurTime() + 0.45
                elseif model == "models/weapons/w_models/w_grenadelauncher.mdl" and GL_tub_delays["delay_grenade_launcher"] < CurTime() then
                    ent:EmitSound("weapons/grenade_launcher_shoot.wav", 120, 100, 1, CHAN_AUTO)
                    ent.lookup_muzzle = ent:LookupAttachment("muzzle")
                    ent.muzzle_pos = ent:GetAttachment(ent.lookup_muzzle).Pos
                    ParticleEffectAttach("muzzle_grenadelauncher", PATTACH_POINT_FOLLOW, ent, ent.lookup_muzzle)
                    ent.grenade = ents.Create(gl .. "tf2_ultimate_grenade")
                    ent.grenade:SetOwner(ent)
                    ent.grenade:Spawn()
                    GL_tub_delays["delay_grenade_launcher"] = CurTime() + 0.4
                elseif model == "models/weapons/c_models/c_flamethrower/c_flamethrower.mdl" and GL_tub_delays["delay_flamethrower"] < CurTime() then
                    if ent.flamethrower_on == nil or not ent.flamethrower_on then
                        ent.flamethrower_on = true
                        ParticleEffectAttach("_flamethrower_REAL", PATTACH_POINT_FOLLOW, ent, ent.lookup_muzzle)
                        ent:EmitSound("weapons/flame_thrower_start.wav", 120, 100, 1, CHAN_AUTO)

                        timer.Simple(3, function()
                            if IsValid(ent) then 
                                ent:EmitSound("weapons/flame_thrower_loop.wav", 120, 100, 1, CHAN_AUTO) 
                            end
                        end)
                    end

                    for i = 1, 5 do
                        local startpoint = ent.muzzle_pos
                        local endpoint = ent.muzzle_pos + ent:GetAttachment(1).Ang:Forward() * 200 + ent:GetAttachment(1).Ang:Up() * math.Rand(-25, 25) + ent:GetAttachment(1).Ang:Right() * math.Rand(-25, 25)

                        local trace = util.TraceLine({
                            start = startpoint,
                            endpos = endpoint,
                            filter = ent
                        })

                        local dmg1 = ent.Damage
                        local target = trace.Entity

                        if IsValid(target) and (target:IsNPC() or target:IsNextBot()) then
                            local burn = DamageInfo()
                            burn:SetAttacker(ent.owner)
                            burn:SetInflictor(ent.owner)
                            burn:SetDamageType(DMG_BURN)
                            burn:SetDamagePosition(trace.HitPos)
                            burn:SetDamage(math.random(1, 5))
                            target:TakeDamageInfo(burn)
                            target:Ignite(6)
                        end
                    end

                    GL_tub_delays["delay_flamethrower"] = CurTime() + 0.1
                end
            end
        end
    end)
end