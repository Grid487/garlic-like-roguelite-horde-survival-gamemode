local gl = "garlic_like_"
local clientFolder = "client/"
local serverFolder = "server/"

FROZE_GL = FROZE_GL or {}
 
CreateConVar(gl .. "preset_name", "preset_brainrot", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 0)
  
if SERVER then 
    CreateConVar(gl .. "enable", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "enables / disables all of garlic-like's systems.", 0, 1)
    CreateConVar(gl .. "enemy_preset", "preset_1.txt", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 0)
    CreateConVar(gl .. "mana_usage_mul", 0.75, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 1)
    CreateConVar(gl .. "reset_stats_after_dying", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 1)
    CreateConVar(gl .. "enable_timer", 0, FCVAR_NONE, "", 0, 1)
    CreateConVar(gl .. "timer_speed_mult", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 10)
    CreateConVar(gl .. "damage_random_min_maxes_enable", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 1)
    CreateConVar(gl .. "max_enemies_spawned", 25, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 1, 100)
    CreateConVar(gl .. "debug_crate_drops", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 1)
    CreateConVar(gl .. "debug_gem_crate_drops", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 1)
    CreateConVar(gl .. "global_enemy_hp_mod_num", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 100)
    CreateConVar(gl .. "global_enemy_dmg_mod_num", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "", 0, 100)
    -- dota2 convars
    CreateConVar("dota2_affect_players", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1)
    CreateConVar("dota2_cooldown_diabolic_edict", 10, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_numhits_diabolic_edict", 40, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_damage_diabolic_edict", 13, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_radius_diabolic_edict", 500, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_interval_diabolic_edict", 0.25, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1)
    CreateConVar("dota2_cooldown_torrent", 3.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_damage_torrent", 20, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_stun_torrent", 2.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_radius_torrent", 225, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_cooldown_life_break", 5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_damage_life_break", 0.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_damage_self_life_break", 0.25, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_radius_life_break", 300, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_cooldown_lightning_bolt", 3, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_damage_lightning_bolt", 120, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_stun_lightning_bolt", 0.2, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_radius_lightning_bolt", 1500, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 10000)
    CreateConVar("dota2_auto_cast_lightning_bolt_sv", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1)
    CreateConVar("dota2_damage_magic_missile", 100, FCVAR_ARCHIVE, "", 1, 1000)
end

if CLIENT then 
    -- dota 2 convars so that the code down below wont give an error
    CreateClientConVar("dota2_auto_cast_diabolic_edict", 0, true, true, "", 0, 1)
    CreateClientConVar("dota2_auto_cast_diabolic_edict_delay", 0.25, true, true, "", 0.01, 99)
    CreateClientConVar("dota2_auto_cast_torrent", 0, true, true, "", 0, 1)
    CreateClientConVar("dota2_auto_cast_torrent_delay", 1, true, true, "", 0.1, 99)
    CreateClientConVar("dota2_auto_cast_lightning_bolt", 0, true, true, "", 0, 1)
    CreateClientConVar("dota2_auto_cast_lightning_bolt_delay", 1, true, true, "", 0.1, 99)
    CreateClientConVar("dota2_auto_cast_magic_missile", 0, true, true, "", 0, 1)
    CreateClientConVar("dota2_auto_cast_magic_missile_delay", 1, true, true, "", 0.1, 99)

    CreateConVar("dota2_affect_players", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1)
    CreateConVar("dota2_cooldown_diabolic_edict", 10, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_numhits_diabolic_edict", 40, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_damage_diabolic_edict", 13, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_radius_diabolic_edict", 500, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_interval_diabolic_edict", 0.25, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1)
    CreateConVar("dota2_cooldown_torrent", 3.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_damage_torrent", 20, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_stun_torrent", 2.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_radius_torrent", 225, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_cooldown_life_break", 5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_damage_life_break", 0.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_damage_self_life_break", 0.25, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_radius_life_break", 300, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_cooldown_lightning_bolt", 3, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_damage_lightning_bolt", 120, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_stun_lightning_bolt", 0.2, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_radius_lightning_bolt", 1500, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 10000)
    CreateConVar("dota2_auto_cast_lightning_bolt_sv", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1)
    CreateConVar("dota2_damage_magic_missile", 100, FCVAR_ARCHIVE, "", 1, 1000)
end

--* particles 
do 
    game.AddParticles("particles/garlic_like_particles_1.pcf")
    game.AddParticles("particles/garlic_like_trails_1.pcf")
    game.AddParticles("particles/vgui_menu_particles.pcf")
    game.AddParticles("particles/units/heroes/hero_viper.pcf")
    game.AddParticles("particles/units/heroes/hero_stormspirit.pcf")
    game.AddParticles("particles/units/heroes/hero_bounty_hunter.pcf")
    game.AddParticles("particles/units/heroes/hero_huskar.pcf")
    game.AddParticles("particles/units/heroes/hero_jakiro.pcf")
    game.AddParticles("particles/units/heroes/hero_bristleback.pcf")
    game.AddParticles("particles/units/heroes/hero_crystalmaiden.pcf")
    game.AddParticles("particles/units/heroes/hero_disruptor.pcf")
    game.AddParticles("particles/units/heroes/hero_gyrocopter.pcf")
    game.AddParticles("particles/units/heroes/hero_ember_spirit.pcf")
    game.AddParticles("particles/item_fx.pcf")
    PrecacheParticleSystem("superrare_plasma2") 
    PrecacheParticleSystem("loot_beam_rarity_legendary")
    PrecacheParticleSystem("loot_beam_rarity_god")
    PrecacheParticleSystem("loot_beam_rarity_epic")
    PrecacheParticleSystem("loot_beam_rarity_rare")
    PrecacheParticleSystem("loot_beam_rarity_uncommon")
    PrecacheParticleSystem("loot_beam_rarity_common")
    PrecacheParticleSystem("loot_beam_rarity_poor")
    PrecacheParticleSystem("loot_trail_god")
    PrecacheParticleSystem("loot_trail_legendary")
    PrecacheParticleSystem("loot_trail_epic")
    PrecacheParticleSystem("loot_trail_rare")
    PrecacheParticleSystem("loot_trail_uncommon")
    PrecacheParticleSystem("loot_trail_common")
    PrecacheParticleSystem("loot_trail_poor")
    PrecacheParticleSystem("versus_door_slam") 
    PrecacheParticleSystem("maiden_crystal_nova") --! make ability
    PrecacheParticleSystem("bounty_hunter_jinda_slow_tgt") --! make ability
    PrecacheParticleSystem("bristleback_quill_spray") --! make ability
    PrecacheParticleSystem("viper_poison_attack_explosion") 
    PrecacheParticleSystem("viper_viper_strike_impact")
    PrecacheParticleSystem("viper_viper_strike_debuff")
    PrecacheParticleSystem("viper_viper_strike_debuff_drips")
    PrecacheParticleSystem("viper_viper_strike_beam_parent")
    PrecacheParticleSystem("viper_poison_attack_")
    PrecacheParticleSystem("viper_poison_attack")
    PrecacheParticleSystem("stormspirit_overload_discharge")
    PrecacheParticleSystem("stormspirit_electric_vortex_debuff")
    PrecacheParticleSystem("huskar_burning_spear_debuff")
    PrecacheParticleSystem("jakiro_base_attack_fire")
    PrecacheParticleSystem("jakiro_base_attack_fire_launch")
    PrecacheParticleSystem("jakiro_liquid_fire_explosion")
    PrecacheParticleSystem("disruptor_thunder_strike_buff")
    PrecacheParticleSystem("disruptor_thuderstrike_aoe_area")
    PrecacheParticleSystem("disruptor_base_attack")
    PrecacheParticleSystem("disruptor_base_attack_explosion_b")
    PrecacheParticleSystem("disruptor_base_attack_explosion_trails") 
    PrecacheParticleSystem("disruptor_staticstrom_inits")
    PrecacheParticleSystem("gyro_guided_missile_explosion")
    PrecacheParticleSystem("ember_spirit_flameGuard")
end 

game.AddAmmoType( {
	name = gl .. "pistol_ammo", -- Note that whenever picked up, the localization string will be '#BULLET_PLAYER_556MM_ammo'
	dmgtype = DMG_BULLET, 
	tracer = TRACER_LINE,
	plydmg = 0, -- This can either be a number or a ConVar name.
	npcdmg = 0, -- Ditto.
	force = 2000,
	maxcarry = 9999, -- Ditto.
	minsplash = 10,
	maxsplash = 5
} )

--========================================================================================================
--Loads the Team Fortress 2 particles into Garry's Mod
--========================================================================================================
--* variables
do
    FROZE_GL.rarities = {"poor", "common", "uncommon", "rare", "epic", "legendary", "ultimate"} 
    
    FROZE_GL.tbl_valid_entities = {gl .. "crystal_cluster", gl .. "item_barrel"} 
    
    FROZE_GL.tbl_wep_power = {}

    FROZE_GL.tbl_wep_blacklist = {
        "tfa_cso_guilotine",
        "tfa_cso_basketball",
        "tfa_cso_c4",
        "tfa_cso_chaingrenade",
        "tfa_cso_cake",
        "tfa_cso_cartfrag",
        "tfa_cso_flashbang",
        "tfa_cso_guilotine",
        "tfa_cso_guilotine",
        "tfa_cso_guilotine",
        "tfa_cso_guilotine",
        "tfa_cso_guilotine",
        "tfa_cso_guilotine",
        "tfa_cso_guilotine",
        "tfa_cso_guilotine", 
    }

    FROZE_GL.tbl_character_stats = {
        [1] = { 
            name = "Max HP Boost",
            id = gl .. "hp_boost",
            upgrade_type = "INT",
            stat_type = "STR",
            weapon_upgrade_id = "",
            base_value = 0,
            shop_upgrade_amount = 20,
            shop_upgrade_base_price = 3000,
            shop_upgrade_price_increase = 7000,
            unlock_condition = nil,
        },
        [2] = {
            name = "Max Overheal",
            id = gl .. "max_overheal",
            upgrade_type = "Float",
            stat_type = "STR",
            weapon_upgrade_id = "max_overheal",
            base_value = 1.5,
            shop_upgrade_amount = 0.1,
            shop_upgrade_base_price = 10000,
            shop_upgrade_price_increase = 20000,
            tbl_txt = {
                [1] = "When the player reaches max health, the player's regeneration is",
                [2] = "still able to regenerate up to [MAX_HP * MAX_OVERHEAL] overheal HP. ",
                [3] = "Lifesteal does not give overheal HP.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        }, 
        [3] = {
            name = "Bonus Damage",
            id = gl .. "bonus_damage",
            upgrade_type = "Float",
            stat_type = "STR",
            weapon_upgrade_id = "damage",
            base_value = 0,
            shop_upgrade_amount = 0.05,
            shop_upgrade_base_price = 2500,
            shop_upgrade_price_increase = 7500,
            tbl_txt = {
                [1] = "Increases every type of damage you do.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        }, 
        [4] = {
            name = "Block Damage Reduction",
            id = gl .. "bonus_block_resistance",
            upgrade_type = "Float",
            stat_type = "STR",
            operation_type = "reducing_mult",
            weapon_upgrade_id = "resistance_block",
            base_value = 0.35,
            max_stat = 0.95,
            shop_upgrade_amount = 0.02,
            shop_upgrade_base_price = 2500,
            shop_upgrade_price_increase = 5000,
        }, 
        [5] = {
            name = "HP Regeneration",
            id = gl .. "bonus_hp_regen",
            upgrade_type = "INT",
            stat_type = "STR",
            weapon_upgrade_id = "hp_regen",
            base_value = 1,
            shop_upgrade_amount = 1,
            shop_upgrade_base_price = 25000,
            shop_upgrade_price_increase = 45000,
            tbl_txt = {
                [1] = "Amount of health recovered per second.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        }, 
        [6] = {
            name = "Critical Damage",
            id = gl .. "bonus_critical_damage",
            upgrade_type = "Float",
            stat_type = "STR",
            weapon_upgrade_id = "crit_damage",
            base_value = 2,
            shop_upgrade_amount = 0.1,
            shop_upgrade_base_price = 15000,
            shop_upgrade_price_increase = 50000,
        }, 
        [7] = {
            name = "Damage Reduction",
            id = gl .. "bonus_resistance",
            upgrade_type = "Float",
            stat_type = "AGI",
            operation_type = "reducing_mult",
            weapon_upgrade_id = "resistance",
            base_value = 0,
            max_stat = 0.95,
            shop_upgrade_amount = 0.03,
            shop_upgrade_base_price = 5000,
            shop_upgrade_price_increase = 10000,
        }, 
        [8] = {
            name = "Flat Damage Reduction",
            id = gl .. "bonus_resistance_flat",
            upgrade_type = "INT",
            stat_type = "AGI",
            weapon_upgrade_id = "resistance_flatdmg",
            base_value = 0,
            shop_upgrade_amount = 3,
            shop_upgrade_base_price = 2500,
            shop_upgrade_price_increase = 7500,
            tbl_txt = {
                [1] = "Reduces damage by a flat amount instead of a percentage.", 
                [2] = "Calculation is done after % damage reductions.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        }, 
        [9] = {
            name = "Block Chance",
            id = gl .. "bonus_block_chance",
            upgrade_type = "Float",
            stat_type = "AGI",
            weapon_upgrade_id = "block_chance",
            base_value = 0,
            shop_upgrade_amount = 0.03,
            shop_upgrade_base_price = 10000,
            shop_upgrade_price_increase = 10000,
        }, 
        [10] = {
            name = "Evasion Chance",
            id = gl .. "bonus_evasion_chance",
            upgrade_type = "Float",
            stat_type = "AGI",
            weapon_upgrade_id = "evasion_chance",
            base_value = 0,
            max_stat = 0.8,
            shop_upgrade_amount = 0.02,
            shop_upgrade_base_price = 10000,
            shop_upgrade_price_increase = 5000,
        }, 
        [11] = {
            name = "Critical Chance",
            id = gl .. "bonus_critical_chance",
            upgrade_type = "Float",
            stat_type = "AGI",
            weapon_upgrade_id = "crit_chance",
            base_value = 0,
            shop_upgrade_amount = 0.05,
            shop_upgrade_base_price = 10000,
            shop_upgrade_price_increase = 60000,
            tbl_txt = {
                [1] = "Chance to deal critical damage.", 
                [2] = "Every 100% of critical chance multiplies the crit damage by 2.", 
                [3] = "For example, a 250% crit chance with 200% crit damage means the final", 
                [4] = "crit damage would be 400% with a 50% chance of it being 600%.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        }, 
        [12] = {
            name = "Multi Hit Chance",
            id = gl .. "bonus_multihit_chance",
            base_value = 0,
            upgrade_type = "Float",
            stat_type = "AGI",
            weapon_upgrade_id = "multihit",
            shop_upgrade_amount = 0.1,
            shop_upgrade_base_price = 15000,
            shop_upgrade_price_increase = 45000,
            tbl_txt = {
                [1] = "Chance for an attack to damage the enemy again for 50% damage.", 
                [2] = "Every 100% of multihit chance creates multiple hits.", 
                [3] = "For example, a 250% multihit chance means your attack will hit", 
                [4] = "the enemy 2 times with a 50% chance for another hit.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        }, 
        [13] = {
            name = "Accuracy",
            id = gl .. "bonus_accuracy",
            upgrade_type = "Float",
            stat_type = "AGI",
            weapon_upgrade_id = "accuracy",
            base_value = 1,
            shop_upgrade_amount = 0.1,
            shop_upgrade_base_price = 25000,
            shop_upgrade_price_increase = 50000,
            tbl_txt = {
                [1] = "Dictates whether or not your attacks harm the enemy.", 
                [2] = "Final hit chance is [ACCURACY * ENEMY_EVASION].", 
                [3] = "For example, with a 250% accuracy and x0.4 enemy hit chance", 
                [4] = "you have a 100% chance of hitting the enemy.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        }, 
        [14] = {
            name = "Max Mana",
            id = gl .. "max_mana",
            upgrade_type = "INT",
            stat_type = "INT",
            weapon_upgrade_id = "",
            base_value = 100,
            shop_upgrade_amount = 30,
            shop_upgrade_base_price = 10000,
            shop_upgrade_price_increase = 20000,
            shop_upgrade_price_increase = 80000,
        }, 
        [15] = {
            name = "Bonus Mana Damage",
            id = gl .. "bonus_mana_damage",
            upgrade_type = "Float",
            stat_type = "INT",
            weapon_upgrade_id = "damage_mana",
            base_value = 0.1,
            shop_upgrade_amount = 0.15,
            shop_upgrade_base_price = 5000,
            shop_upgrade_price_increase = 15000,
            tbl_txt = {
                [1] = "Attacks reduce mana by it's unmodified damage and in turn", 
                [2] = "increases the attack damage.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        }, 
        [16] = {
            name = "Mana Damage Reduction",
            id = gl .. "bonus_mana_resistance",
            upgrade_type = "Float",
            stat_type = "INT",
            operation_type = "reducing_mult",
            weapon_upgrade_id = "",
            base_value = 0.05,
            max_stat = 0.85,
            shop_upgrade_amount = 0.05,
            shop_upgrade_base_price = 10000,
            shop_upgrade_price_increase = 5000,
            tbl_txt = {
                [1] = "Reduces your mana by the enemy's damage", 
                [2] = "and in turn reduce the damage you take.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        }, 
        [17] = {
            name = "XP Gain",
            id = gl .. "bonus_xp_gain",
            upgrade_type = "Float",
            stat_type = "INT",
            weapon_upgrade_id = "xp_gain",
            base_value = 1,
            shop_upgrade_amount = 0.1,
            shop_upgrade_base_price = 25000,
            shop_upgrade_price_increase = 75000,
            unlock_condition = "Reach level 30 in a run.",
        }, 
        [18] = {
            name = "Cooldown Reduction", 
            stat_name = "Cooldown Duration",
            id = gl .. "bonus_cooldown_mult",   
            upgrade_type = "Float",
            stat_type = "INT",
            weapon_upgrade_id = "cooldown_speed",
            base_value = 1,
            shop_upgrade_amount = 0.035,
            shop_upgrade_base_price = 25000,
            shop_upgrade_price_increase = 35000, 
            unlock_condition = "Obtain 4 rare or above skills in a run.",
        },
        [19] = {
            name = "Mana Regen",
            id = gl .. "mana_regen",
            upgrade_type = "INT",
            stat_type = "INT",
            weapon_upgrade_id = "",
            base_value = 1,
            shop_upgrade_amount = 1,
            shop_upgrade_base_price = 30000,
            shop_upgrade_price_increase = 150000, 
            tbl_txt = {
                [1] = "Recovers mana every 0.2 second.",  
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        },
        [20] = {
            name = "Multicast",
            id = gl .. "multicast",
            upgrade_type = "Float",
            stat_type = "INT",
            weapon_upgrade_id = "",
            base_value = 0,
            shop_upgrade_amount = 0.03,
            shop_upgrade_base_price = 17500,
            shop_upgrade_price_increase = 87500, 
            tbl_txt = {
                [1] = "Chance for an ability to cast repeatedly.",  
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        },
        [500] = {
            name = "Gold Gain", 
            id = gl .. "bonus_gold_gain",
            upgrade_type = "Float",
            stat_type = "EXTRA",
            shop_upgrade_amount = 0.15,
            shop_upgrade_base_price = 10000,
            shop_upgrade_price_increase = 25000,
            unlock_condition = "Gain a total of 100000 gold.",
        },
        [510] = {
            name = "Enemy Gem Drops Amount", 
            id = gl .. "bonus_gem_drops",
            upgrade_type = "Float",
            stat_type = "EXTRA",
            shop_upgrade_amount = 0.3,
            shop_upgrade_base_price = 30000,
            shop_upgrade_price_increase = 170000,
            unlock_condition = "Gain a total of 300 weapon gems in a single run.",
        },
        [520] = {
            name = "Enemy Reroll Crystals Drops Amount", 
            id = gl .. "bonus_reroll_gem_drops",
            upgrade_type = "Float",
            stat_type = "EXTRA",
            shop_upgrade_amount = 0.1,
            shop_upgrade_base_price = 20000,
            shop_upgrade_price_increase = 40000,
            unlock_condition = "Gain a total of 400 reroll gems in a single run.",
        },
        [1000] = {
            name = "Starting STR", 
            id = gl .. "bonus_starting_str",
            upgrade_type = "INT",
            stat_type = "EXTRA",
            shop_upgrade_amount = 5,
            shop_upgrade_base_price = 10000,
            shop_upgrade_price_increase = 20000,
            unlock_condition = "Reach 40 strength points on a run.",
        },
        [1010] = {
            name = "Starting AGI", 
            id = gl .. "bonus_starting_agi",
            upgrade_type = "INT",
            stat_type = "EXTRA",
            shop_upgrade_amount = 5,
            shop_upgrade_base_price = 10000,
            shop_upgrade_price_increase = 20000,
            unlock_condition = "Reach 40 agility points on a run.",
        },
        [1020] = {
            name = "Starting INT", 
            id = gl .. "bonus_starting_int",
            upgrade_type = "INT",
            stat_type = "EXTRA",
            shop_upgrade_amount = 5,
            shop_upgrade_base_price = 10000,
            shop_upgrade_price_increase = 20000,
            unlock_condition = "Reach 40 intelligence points on a run.",
        },
        [1021] = {
            name = "Melee DMG Reduction", 
            id = gl .. "dmg_reduction_melee",
            upgrade_type = "Float",
            stat_type = "EXTRA",
            shop_upgrade_amount = 0.075,
            shop_upgrade_base_price = 7500,
            shop_upgrade_price_increase = 7500,
            unlock_condition = "Deal a total of 50000 damage with a melee weapon.",
            tbl_txt = {
                [1] = "Reduces the damage you take when wielding a melee weapon.",  
                w = 0, 
                h = 0,
            },
            color = Color(255, 255, 255, 255),
        },
        [1030] = {
            name = "Lives", 
            id = gl .. "max_deaths",
            upgrade_type = "INT",
            stat_type = "EXTRA",
            shop_upgrade_amount = 1,
            shop_upgrade_base_price = 50000,
            shop_upgrade_price_increase = 50000,
            unlock_condition = "Die 3 times after the timer has reached past 10 minutes.",
        },
    } 

    FROZE_GL.tbl_bonuses_weapons = {
        [1] = {
            name = "damage",
            modifier = 0.2,
            upgrade_mul = 1.11,
            max_mul = 9999,
            desc = " Damage Multiplier",
            type_mul = 1
        },
        [2] = {
            name = "resistance",
            modifier = 0.1,
            upgrade_mul = 1.09,
            max_mul = 0.95,
            desc = " Damage Reduction Multiplier",
            type_mul = -1
        },
        [3] = {
            name = "crit_chance",
            modifier = 0.13,
            upgrade_mul = 1.09,
            max_mul = 9999,
            desc = " Critical Chance Multiplier",
            type_mul = 1
        },
        [4] = {
            name = "crit_damage",
            modifier = 0.15,
            upgrade_mul = 1.09,
            max_mul = 9999,
            desc = " Critical Damage Multiplier",
            type_mul = 1
        },
        [5] = {
            name = "cooldown_speed",
            modifier = 0.15,
            upgrade_mul = 1.06,
            max_mul = 9999,
            desc = " Cooldown Speed Multiplier",
            type_mul = 1
        },
        [6] = {
            name = "damage_mana",
            modifier = 0.35,
            upgrade_mul = 1.1,
            max_mul = 9999,
            desc = " Mana Damage Multiplier",
            type_mul = 1
        },
        [7] = {
            name = "xp_gain",
            modifier = 0.09,
            upgrade_mul = 1.11,
            max_mul = 9999,
            desc = " XP Gain Multiplier",
            type_mul = 1
        },
        [8] = {
            name = "gold_gain",
            modifier = 0.12,
            upgrade_mul = 1.12,
            max_mul = 9999,
            desc = " Gold Gain Increase",
            type_mul = 1
        },
        [9] = {
            name = "multihit",
            modifier = 0.09,
            upgrade_mul = 1.085,
            max_mul = 9999,
            desc = " Multi Hit Multiplier",
            type_mul = 1
        },
        [10] = {
            name = "resistance_flatdmg",
            modifier = 0.12,
            upgrade_mul = 1.11,
            max_mul = 9999,
            desc = " Flat DMG Res Multiplier",
            type_mul = 1
        },
        [11] = {
            name = "hp_regen",
            modifier = 0.1,
            upgrade_mul = 1.1,
            max_mul = 9999,
            desc = " HP Regen Multiplier",
            type_mul = 1
        },
        [12] = {
            name = "max_overheal",
            modifier = 0.11,
            upgrade_mul = 1.11,
            max_mul = 9999,
            desc = " Max Overheal Multiplier",
            type_mul = 1
        },
        [13] = {
            name = "resistance_block",
            modifier = 0.1,
            upgrade_mul = 1.085,
            max_mul = 0.95,
            desc = " Block Damage Reduction",
            type_mul = -1
        },
        [14] = {
            name = "block_chance",
            modifier = 0.09,
            upgrade_mul = 1.08,
            max_mul = 9999,
            desc = " Block Chance Multiplier",
            type_mul = 1
        },
        [15] = {
            name = "evasion_chance",
            modifier = 0.07,
            upgrade_mul = 1.07,
            max_mul = 9999,
            desc = " Additional Evasion Chance",
            type_mul = 1
        },
        [16] = {
            name = "lifesteal",
            modifier = 0.01,
            upgrade_mul = 1.1,
            max_mul = 0.08,
            desc = " Lifesteal",
            type_mul = 1
        },
        [17] = {
            name = "attack_speed",
            modifier = 0.12,
            upgrade_mul = 1.04,
            max_mul = 9999,
            desc = " Attack Speed / RPM Increase",
            type_mul = 1
        },
        [18] = {
            name = "reload_speed",
            modifier = 0.17,
            upgrade_mul = 1.05,
            max_mul = 9999,
            desc = " Reload Speed Increase",
            type_mul = 1
        },
        [19] = {
            name = "bash_damage",
            modifier = 0.75,
            upgrade_mul = 1.11,
            max_mul = 9999,
            desc = " Bash Damage Increase",
            type_mul = 1
        },
        [20] = {
            name = "bash_speed",
            modifier = 0.15,
            upgrade_mul = 1.1,
            max_mul = 9999,
            desc = " Bash Frequency Increase",
            type_mul = 1
        },
        [21] = {
            name = "mag_upgrade",
            modifier = 0.3,
            upgrade_mul = 1.12,
            max_mul = 9999,
            desc = " Mag Capacity Increase",
            type_mul = 1
        },
    }
    
    FROZE_GL.tbl_rarity_to_number = {
        ["poor"] = 1,
        ["common"] = 2,
        ["uncommon"] = 3,
        ["rare"] = 4,
        ["epic"] = 5,
        ["legendary"] = 6,
        ["ultimate"] = 7,
    }

    FROZE_GL.tbl_enemy_modifiers = { 
        ["FIERY"] = {
            name = "Fiery",
            tbl_txt = {
                [1] = "Enemy regularly spawns a fireball on top of their head which launches at a nearby player,",
                [2] = "exploding and igniting the player.",
                w = 0, 
                h = 0,
            },
            color = Color(255, 0, 0, 255),
            length = 0, 
        },
        ["LIGHTNING"] = {
            name = "Lightning",
            tbl_txt = {
                [1] = "Enemy regularly emits an electric explosion, dealing damage to nearby players.", 
                w = 0, 
                h = 0,
            },
            color = Color(60, 60, 255),
            length = 0, 
        },
        ["POISONBALL"] = {
            name = "Corrosive",
            tbl_txt = {
                [1] = "Enemy regularly spawns a poison fireball on top of their head which launches and",
                [2] = "slightly tracks at a nearby player, exploding and poisoning the player.",
                w = 0, 
                h = 0,
            },
            color = Color(0, 255, 0, 255),
            length = 0, 
        },
        ["BLEED"] = {
            name = "Bleed",
        
            tbl_txt = {
                [1] = "Enemy hits deal 14% of the damage originally dealt every 0.5 second over 10 seconds.",
                [2] = "Duration refreshed by new hits.",
                w = 0, 
                h = 0,
            },
            color = Color(231, 49, 25),
            length = 0, 
        },
        ["HEALING"] = {
            name = "Healing",
            tbl_txt = {
                [1] = "Enemy heals other nearby allies every timer tick, healing is based on distance from the healer,",
                [2] = "with 5% of their max health at most and 1% at the least.",
                w = 0, 
                h = 0,
            },
            color = Color(23, 196, 0, 255),
            length = 0, 
        },
        ["IMMORTAL"] = {
            name = "Immortal",
            tbl_txt = {
                [1] = "Enemy takes 0 damage for 7 seconds after initially getting damaged by the player.", 
                w = 0, 
                h = 0,
            },
            color = Color(121, 54, 0, 255),
            length = 0, 
        },
        ["DEFENSIVE"] = {
            name = "Defensive",
        
            tbl_txt = {
                [1] = "Enemy grants nearby enemies damage reduction,",
                [2] = "ranging from 65% DR to 15% DR based on distance.",
                w = 0, 
                h = 0,
            },
            color = Color(184, 165, 0),
            length = 0, 
        },
        ["LOYAL"] = {
            name = "Loyal",
            tbl_txt = {
                [1] = "Enemy grants nearby enemies 50% damage reduction regardless of distance.", 
                w = 0, 
                h = 0,
            },
            color = Color(199, 163, 65),
            length = 0, 
        },
        ["RESISTIVE"] = {
            name = "Resistive",
            tbl_txt = {
                [1] = "Enemy only takes 50% of the player's critical chance and 75% of the player's critical damage.", 
                w = 0, 
                h = 0,
            },
            color = Color(0, 94, 170),
            length = 0, 
        },
        ["ARMORED"] = {
            name = "Armored",
        
            tbl_txt = {
                [1] = "Enemy only takes 35% damage when health is above 50% and every hit the enemy takes additionaly",
                [2] = "reduces damage taken by 0.3% (maximum of 75% damage reduction).",
                w = 0, 
                h = 0,
            },
            color = Color(255, 251, 0),
            length = 0, 
        },
        ["AGGRESSIVE"] = {
            name = "Aggressive",
            tbl_txt = {
                [1] = "Enemy deals 25% increased damage and has 3x more max health.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 0, 106),
            length = 0, 
        },
        ["AGILE"] = {
            name = "Agile",
            tbl_txt = {
                [1] = "Enemy has 2x more max health and a 33% chance to evade damage.", 
                [2] = "Ignores 50% of the player's Multi Hit chance.", 
                w = 0, 
                h = 0,
            },
            color = Color(115, 255, 0),
            length = 0, 
        },
        ["POWERFUL"] = {
            name = "Powerful",
            tbl_txt = {
                [1] = "Enemy deals 75% increased damage and has 3x more max health.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 72, 0),
            length = 0, 
        },
        ["ROBUST"] = {
            name = "Robust",
            tbl_txt = {
                [1] = "Enemy deals 25% incresed damage and has 4x more max health.", 
                w = 0, 
                h = 0,
            },
            color = Color(255, 153, 0),
            length = 0, 
        },
        ["SHIELDING"] = {
            name = "Shielding",
            tbl_txt = {
                [1] = "Enemy gets a shield that takes damage instead of health.",
                [2] = "Shield scales from hp by 75% up to 125% of the max health.",
                w = 0, 
                h = 0,
            },
            color = Color(0, 174, 255),
            length = 0, 
        },
        ["WEAKENING"] = {
            name = "Weakening",
            tbl_txt = {
                [1] = "Enemy reduces the player's damage for every hit the player takes.",
                [2] = "The damage dealt debuff is based on [Damage Taken] / [Player Max Health].",
                w = 0, 
                h = 0,
            },
            color = Color(107, 107, 107),
            length = 0, 
        },
        ["GOLDEN"] = {
            name = "GOLDEN",
            tbl_txt = {
                [1] = "Enemy gives 1000% more gold. and takes reduced damage",            
                [2] = "based on current health. Every 1% health the enemy has",
                [3] = "reduces damage taken by %0.667.",
                w = 0, 
                h = 0,
            },
            color = Color(187, 161, 79),
            length = 0, 
        },
    }

    FROZE_GL.tbl_elements = {
        [1] = {
            name = "fire",
            tbl_txt = {
                [1] = "Weapons ignite enemies and deal damage over time.",
                [2] = "Enemy gets ignited for 10 seconds, shooting an ignited enemy with a",
                [3] = "fire element weapon increases the burn duration by 0.5 second, up to 60 seconds.",
                [4] = "",
                [5] = "Damage of the fire is calculated as following:",
                [5] = "DMG = math.min(HIGHEST_DMG_TAKEN * 5, math.Round((AVERAGE_DMG_TAKEN + math.ceil(HEALTH * 0.01))^(1 + SECONDS LEFT / 2 * 0.01)))",            
                [7] = "every damage tick increases chance for the enemy to miss by %0.75 up to 90%. Enemy deals 20% reduced damage while ignited,",
                [8] = "every tick further reduces enemy damage dealt by %1 up to 85%.",
                w = 0, 
                h = 0,
            },
            color = Color(235, 86, 0),
            mat_1 = Material("garlic_like/icon_elements/Fire.png"),
            mat_2 = Material("garlic_like/icon_elements/Burning.png"),
            mat_white = Material("garlic_like/icon_elements/Fire_white.png"),            
        },
        [2] = {
            name = "poison",
            tbl_txt = {
                [1] = "Weapons poison enemies, poison deals damage every 1.5 seconds.",
                [2] = "75% of the player's damage turns into the poison's damage and",
                [3] = "every time the poison deals damage, it loses 30% of it's damage but",
                [4] = "applies a stacking damage taken multiplier to the enemy,",
                [5] = "[DMG Mult = (DMG Mult + 0.1) * 1.05] up to +1000% damage taken multiplier.",
                [6] = "",
                [7] = "The poison deals 50% of it's damage to enemies next to the poisoned enemy and", 
                [8] = "on death, deals 100% of the remaining poison damage to nearby enemies.", 
                w = 0, 
                h = 0,
            },
            color = Color(99, 221, 0),
            mat_1 = Material("garlic_like/icon_elements/Decay.png"),
            mat_2 = Material("garlic_like/icon_elements/Corrosion.png"),
            mat_white = Material("garlic_like/icon_elements/Decay_white.png"),           
        },
        [3] = {
            name = "lightning",
            tbl_txt = {
                [1] = "Weapons have a 9% chance to cause the enemy to emit a lightning shockwave,",
                [2] = "The shockwave deals 300% of the damage and is capable of creating another",
                [3] = "shockwave. The initial shockwave has a 50% chance of emitting another shockwave ",
                [4] = "that deals 75% of it's original damage. The following shockwave is also capable",
                [5] = "of chaining more shockwaves, though with 10% reduced chance and 5% reduced damage",
                [6] = "for every chain.",
                [7] = "",
                [8] = "Enemy that gets hit by a shockwave briefly receives 25% more damage and 1 debuff.", 
                [10] = "stack (1.25 + (debuff stacks / 15)) [up to +200% damage from debuff stacks]. For every ",
                [11] = "shockwave, whether it be the initial or a chain, gives the player a buff stack and increases",
                [12] = "the player's damage by (1.045^buff stacks) up to +500% damage. one buff stack disappears",
                [12] = "every 12 seconds.",
                w = 0, 
                h = 0,
            },
            color = Color(0, 151, 221),
            mat_1 = Material("garlic_like/icon_elements/Lightning.png"),
            mat_2 = Material("garlic_like/icon_elements/Shock.png"), 
            mat_white = Material("garlic_like/icon_elements/Lightning_white.png"),              
        }
    }

    FROZE_GL.tbl_elements_tiers = {
        [1] = {
            name = "fire",
            info = {
                [1] = "Burn damage increases by 70%. Every burn tick has a 15% chance to deal 100% more damage.",
                [2] = "When the fire runs out or the enemy dies, create an explosion dealing 1000% of the last burn tick damage.",
                [3] = "Deal 10% more burn damage after each burn tick. Hurting the enemy in this duration will reset the bonus damage.",
                [4] = "Enemies emit a burning aura that increases the burn damage it receives by 100% (multiplicative) and damages nearby enemies for 50% of its damage.",
                [5] = "The player gets a +700% damage buff after the fire explosion and the burning aura reduces the enemy's and nearby enemies' attack by 75% (multiplicative)."
            }
        },
        [2] = {
            name = "poison",
            info = {
                [1] = "90% of the player's damage turns into poison damage and only lose 25% poison damage/tick.",
                [2] = "Every 1% of the enemy's max HP you deal as RAW DAMAGE (pre damage reduction calculations) from the poison tick additively increases the poison damage mult by 0.2% and increases the damage mult cap to 3000%.",
                [3] = "Deals 25% of the current total poison's damage every 0.3 second to the enemy.",
                [4] = "Poison ticks every second and Every 3 poison ticks, create a stronger poison explosion that deals 200% of the poison damage tick. This explosion deals 50% damage to nearby enemies. (use viper_viper_strike_beam_parent particle)", 
                [5] = "The stronger explosion gives a debuff to the enemy for 15 seconds that increases the damage that it takes by 150%. (use viper_viper_strike_debuff_drips particle). Any non elemental damage during this gives a debuff that increases the damage they take by (DMG RECEIVED/MAX HP)% (no cap) as long as the enemy is under the poison debuff.", 
            }
        },
        [3] = {
            name = "lightning",
            info = {
                [1] = "15% Chance for a lightning shockwave and raises shockwave damage to 900% damage. Subsequent shockwaves now deal 85% damage.", 
                [2] = "Enemy that gets hit by a shockwave take 100% more damage for 0.5s. Gain 3 debuff stacks per proc and increases the debuff damage mult cap to 500%.", 
                [3] = "77% Chance to get 2 player buff stacks, 47% chance to get 3 player buff stacks, and 27% chance to get 4 player buff stacks. Increases the damage mult cap to 1500%.", 
                [4] = "10% chance for any enemy hit by a lightning shockwave to trigger a \"Shockwave Emitter\" that causes the enemy and other nearby enemies to emit a special shockwave dealing 150% of the shockwave's damage once every 2 seconds for 9 seconds (stackable).", 
                [5] = "Every shockwave emitter increases the player's damage by 25% for 25 seconds. (777% damage mult cap)", 
            }
        },
    }


    FROZE_GL.tbl_materials_inventory = {
        ["Reroll Crystal"] = {
            id = "reroll_crystal",
            material = Material("garlic_like/icon_materials/icon_reroll_crystal.png"),
            rarity = "common",
            held_num = 0,
        },
        ["Power Cell"] = {
            id = "power_cell",
            material = Material("garlic_like/icon_materials/icon_powercell.png"),
            rarity = "rare",
            held_num = 0,
        },
        ["Element Crystal"] = {
            id = "element_crystal",
            material = Material("garlic_like/icon_materials/icon_element_crystal.png"),
            rarity = "legendary",
            held_num = 0,
        },
        ["Crate Key"] = {
            id = "crate_key",
            material = Material("garlic_like/icon_materials/icon_crate_key.png"),
            rarity = "common",
            held_num = 0,
        },
    }

    FROZE_GL.tbl_melee_holdtypes = {
        ["melee"] = true,
        ["melee2"] = true,
        ["fist"] = true,
        ["knife"] = true,    
    }

    FROZE_GL.tbl_tfa_wep_ents = {}

    FROZE_GL.tbl_wep_rarity_base_stat_modifier_nums = {
        [1] = 0.5,
        [2] = 1,
        [3] = 1.15,
        [4] = 1.3,
        [5] = 1.5,
        [6] = 1.75,
        [7] = 2,
    }

    FROZE_GL.valid_inventory_items_max_weight = 0

    FROZE_GL.tbl_menu_inventory_items_data = {
        ["gold"] = {
            name = "Gold",
            desc = "A currency used for various things.",
            icon_mat = Material("garlic_like/icon_hl.png"),
            rarity = "common",
            is_currency = true,
            material = true,
        },
        ["ore_poor"] = {
            name = "Poor Ore",
            desc = "A poor quality ore for various usage.",
            icon_mat = Material("garlic_like/icon_materials/icon_poor_ore.png"),
            rarity = "poor",
            is_ore = true,
            material = true,
        },
        ["ore_common"] = {
            name = "Common Ore",
            desc = "A common quality ore for various usage.",
            icon_mat = Material("garlic_like/icon_materials/icon_common_ore.png"),
            rarity = "common",
            is_ore = true,
            material = true,
        },
        ["ore_uncommon"] = {
            name = "Uncommon Ore",
            desc = "An uncommon quality ore for various usage.",
            icon_mat = Material("garlic_like/icon_materials/icon_uncommon_ore.png"),
            rarity = "uncommon",
            is_ore = true,
            material = true,
        },
        ["ore_rare"] = {
            name = "Rare Ore",
            desc = "A rare quality ore for various usage.",
            icon_mat = Material("garlic_like/icon_materials/icon_rare_ore.png"),
            rarity = "rare",
            is_ore = true,
            material = true,
        },
        ["ore_epic"] = {
            name = "Epic Crystal",
            desc = "An epic quality ore for various usage.",
            icon_mat = Material("garlic_like/icon_materials/icon_epic_crystal.png"),
            rarity = "epic",
            is_ore = true,
            material = true,
        },
        ["ore_legendary"] = {
            name = "Legendary Crystal",
            desc = "A legendary quality ore for various usage.",
            icon_mat = Material("garlic_like/icon_materials/icon_legendary_crystal.png"),
            rarity = "legendary",
            is_ore = true,
            material = true,
        },
        ["ore_ultimate"] = {
            name = "Ultimate Crystal",
            desc = "An ultimate quality ore for various usage.",
            icon_mat = Material("garlic_like/icon_materials/icon_god_crystal.png"),
            rarity = "ultimate",
            is_ore = true,
            material = true,
        },
        ["crate_key"] = {
            name = "Crate Key",
            desc = "Used for opening crates dropped by enemies.",
            icon_mat = Material("garlic_like/icon_materials/icon_crate_key.png"),
            rarity = "rare",
            is_material = true,
            material = true,
        },
        ["element_crystal"] = {
            name = "Element Crystal",
            desc = "Used for various element related things.",
            icon_mat = Material("garlic_like/icon_materials/icon_element_crystal.png"),
            rarity = "legendary",
            is_material = true,
            material = true,
        },
        ["reroll_crystal"] = {
            name = "Reroll Crystal",
            desc = "Used for rerolling weapon stats.",
            icon_mat = Material("garlic_like/icon_materials/icon_reroll_crystal.png"),
            rarity = "uncommon",
            is_material = true,
            material = true,
        },
        ["power_cell"] = {
            name = "Power Cell",
            desc = "Used for summoning equipment.",
            icon_mat = Material("garlic_like/icon_materials/icon_powercell.png"),
            rarity = "rare",
            is_material = true,
            material = true,
        },
        ["stat_scroll"] = {
            name = "Stat Increase Scroll",
            desc = "Used for multiplying stat upgrades by x2.",
            icon_mat = Material("garlic_like/icon_consumables/stat_scroll.png"),
            rarity = "epic",
            is_material = true,
            material = true,
        },
    }

    FROZE_GL.tbl_item_name_to_id = {
        ["Gold"] = "gold",
        ["Poor Ore"] = "ore_poor",
        ["Common Ore"] = "ore_common", 
        ["Uncommon Ore"] = "ore_uncommon",
        ["Rare Ore"] = "ore_rare",
        ["Epic Crystal"] = "ore_epic",
        ["Legendary Crystal"] = "ore_legendary",
        ["Ultimate Crystal"] = "ore_ultimate",
        ["Crate Key"] = "crate_key",
        ["Element Crystal"] = "element_crystal",
        ["Reroll Crystal"] = "reroll_crystal",
        ["Power Cell"] = "power_cell",
        ["Stat Increase Scroll"] = "stat_scroll"
    }

    --! WORK ON MAKING REROLL CRYSTALS AND ELEMENT CRYSTALS DROP FROM CHESTS

    FROZE_GL.tbl_valid_inventory_items = { 
        [100] = {
            name = "Common Chest",
            desc = "A chest that contains various useful items.",
            icon_mat = Material("garlic_like/icon_chests/chest_2.png"),
            rarity = "common",
            ru_reward = true,
            drop_weight_max_ru = 0,
            drop_weight_min_ru = 0,
            drop_weight_ru = 10000,
            chest_drops = {
                gold = {
                    min = 50000,
                    max = 100000,
                },
                stat_scroll = {
                    min = 1,
                    max = 2,
                }, 
                material_drop_amount = {
                    min = 25,            
                    max = 50,
                },     
                drop_weights = {},
            },
        },
        [200] = {
            name = "Uncommon Chest",
            desc = "A chest that contains various useful items.",
            icon_mat = Material("garlic_like/icon_chests/chest_3.png"),
            rarity = "uncommon",
            ru_reward = true,
            drop_weight_max_ru = 0,
            drop_weight_min_ru = 0,
            drop_weight_ru = 4000,
            chest_drops = {
                gold = {
                    min = 100000,
                    max = 200000,
                },
                stat_scroll = {
                    min = 2,
                    max = 4,
                },
                material_drop_amount = {
                    min = 50,            
                    max = 100,
                },  
                drop_weights = {},      
            },
        },
        [300] = {
            name = "Rare Chest",
            desc = "A chest that contains various useful items.",
            icon_mat = Material("garlic_like/icon_chests/chest_4.png"),
            rarity = "rare",
            ru_reward = true,
            drop_weight_max_ru = 0,
            drop_weight_min_ru = 0,
            drop_weight_ru = 1600,
            chest_drops = {
                gold = {
                    min = 200000,
                    max = 450000,
                },
                stat_scroll = {
                    min = 4,
                    max = 8,
                },
                material_drop_amount = {
                    min = 100,            
                    max = 200,
                },
                drop_weights = {},
            },
        },
        [400] = {
            name = "Epic Chest",
            desc = "A chest that contains various useful items.",
            icon_mat = Material("garlic_like/icon_chests/chest_5.png"),
            rarity = "epic",
            ru_reward = true,
            drop_weight_max_ru = 0,
            drop_weight_min_ru = 0,
            drop_weight_ru = 640,
            chest_drops = {
                gold = {
                    min = 450000,
                    max = 1125000,
                },
                stat_scroll = {
                    min = 4,
                    max = 8,
                },
                material_drop_amount = {
                    min = 200,            
                    max = 400,
                },     
                drop_weights = {},
            },
        },
        [500] = {
            name = "Legendary Chest",
            desc = "A chest that contains various useful items.",
            icon_mat = Material("garlic_like/icon_chests/chest_6.png"),
            rarity = "legendary",
            ru_reward = true,
            drop_weight_max_ru = 0,
            drop_weight_min_ru = 0,
            drop_weight_ru = 256,
            chest_drops = {
                gold = {
                    min = 1125000,
                    max = 3093750,
                },
                stat_scroll = {
                    min = 16,
                    max = 32,
                },
                material_drop_amount = {
                    min = 400,            
                    max = 800,
                }, 
                drop_weights = {},      
            },
        },
        [600] = {
            name = "Ultimate Chest",
            desc = "A chest that contains various useful items.",
            icon_mat = Material("garlic_like/icon_chests/chest_7.png"),
            rarity = "ultimate",
            ru_reward = true,
            drop_weight_max_ru = 0,
            drop_weight_min_ru = 0,
            drop_weight_ru = 103,
            chest_drops = {
                gold = {
                    min = 3093750,
                    max = 9281250,
                },
                stat_scroll = {
                    min = 32,
                    max = 64,
                },
                material_drop_amount = {
                    min = 800,            
                    max = 1600,
                },   
                drop_weights = {},     
            },
        }, 
    }

    do
        FROZE_GL.rarity_weights = {
            ["poor"] = {
                min = 0,
                max = 0,
                weight = 2000
            },
            ["common"] = {
                min = 0,
                max = 0,
                weight = 1000
            },
            ["uncommon"] = {
                min = 0,
                max = 0,
                weight = 500
            },
            ["rare"] = {
                min = 0,
                max = 0,
                weight = 250
            },
            ["epic"] = {
                min = 0,
                max = 0,
                weight = 125
            },
            ["legendary"] = {
                min = 0,
                max = 0,
                weight = 60
            },
            ["ultimate"] = {
                min = 0,
                max = 0,
                weight = 20
            }
        }

        FROZE_GL.rarity_starting_num = 1
        FROZE_GL.rarity_weights_sum_gems = 0

        for k, entry in SortedPairs(FROZE_GL.rarity_weights) do
            entry.min = FROZE_GL.rarity_starting_num
            entry.max = FROZE_GL.rarity_starting_num + entry.weight
            FROZE_GL.rarity_starting_num = FROZE_GL.rarity_starting_num + entry.weight
        end

        for k, entry in pairs(FROZE_GL.rarity_weights) do
            FROZE_GL.rarity_weights_sum_gems = FROZE_GL.rarity_weights_sum_gems + entry.weight
        end
    end 

    -- print("FROZE_GL.rarity_weights_sum_gems " .. FROZE_GL.rarity_weights_sum_gems)

    FROZE_GL.garlic_like_upgrades = {}

    FROZE_GL.tbl_drops = {}

    FROZE_GL.rarity_weights_new = {}
    FROZE_GL.rarity_weights_weapons = {}
 
    FROZE_GL.default_gun = "tfa_cso_gl_glock"

    --* tfa cso weapons
    do  
        FROZE_GL.wep_cso = {
            ["tfa_cso_leapstrikegunex"] = {
                printname = "Abyss Repulsor",
                rarity_num = 6,
            },
            ["tfa_cso_aeolis"] = {
                printname = "Aeolis",
                rarity_num = 5,
            },
            ["tfa_cso_as50"] = {
                printname = "AI AS50",
                rarity_num = 4,
            },
            ["tfa_cso_as50_expert"] = {
                printname = "AI AS50 Expert",
                rarity_num = 5,
            },
            ["tfa_cso_as50_master"] = {
                printname = "AI AS50 Master",
                rarity_num = 6,
            },
            ["tfa_cso_as50g"] = {
                printname = "AI AS50 Pink Gold",
                rarity_num = 5,
            },
            ["tfa_cso_aw50"] = {
                printname = "AI AW50F",
                rarity_num = 4,
            },
            ["tfa_cso_airburster"] = {
                printname = "Air Burster",
                rarity_num = 5,
            },
            ["tfa_cso_ak47"] = {
                printname = "AK-47",
                rarity_num = 1,
            },
            ["tfa_cso_ak_long"] = {
                printname = "AK-47 60R",
                rarity_num = 2,
            },
            ["tfa_cso_ak4713"] = {
                printname = "AK-47 60R Classic",
                rarity_num = 2,
            },
            ["tfa_cso_ak4713_v6"] = {
                printname = "AK-47 60R Classic Expert",
                rarity_num = 3,
            },
            ["tfa_cso_ak4713_v8"] = {
                printname = "AK-47 60R Classic Master",
                rarity_num = 4,
            },
            ["tfa_cso_ak47_hq"] = {
                printname = "AK-47 Camouflage",
                rarity_num = 2,
            },
            ["tfa_cso_ak47_dragon"] = {
                printname = "AK-47 Dragon",
                rarity_num = 4,
            },
            ["tfa_cso_g_ak47"] = {
                printname = "AK-47 Gold",
                rarity_num = 3,
            },
            ["tfa_cso_paladin"] = {
                printname = "AK-47 Paladin",
                rarity_num = 5,
            },
            ["tfa_cso_paladin_v8"] = {
                printname = "AK-47 Paladin Expert",
                rarity_num = 6,
            },
            ["tfa_cso_ak47red"] = {
                printname = "AK-47 Red",
                rarity_num = 2,
            },
            ["tfa_cso_paladin_v6"] = {
                printname = "AK-47 Royal Knight",
                rarity_num = 6,
            },
            ["tfa_cso_ak47wg"] = {
                printname = "AK-47 White Gold",
                rarity_num = 3,
            },
            ["tfa_cso_ak74u"] = {
                printname = "AK-74U",
                rarity_num = 1,
            },
            ["tfa_cso_akm"] = {
                printname = "AKM",
                rarity_num = 1,
            },
            ["tfa_cso_an94"] = {
                printname = "AN 94",
                rarity_num = 2,
            },
            ["tfa_cso_anaconda"] = {
                printname = "Anaconda",
                rarity_num = 3,
            },
            ["tfa_cso_ancientberserker"] = {
                printname = "Ancient Berserker",
                rarity_num = 6,
            },
            ["tfa_cso_ancientbringer"] = {
                printname = "Ancient Bringer",
                rarity_num = 6,
            },
            ["tfa_cso_ancientkeeper"] = {
                printname = "Ancient Keeper",
                rarity_num = 6,
            },
            ["tfa_cso_halogun"] = {
                printname = "Arbalest",
                rarity_num = 5,
            },
            ["tfa_cso_arcana_i"] = {
                printname = "Arcana I",
                rarity_num = 7,
            },
            ["tfa_cso_arcana_ii"] = {
                printname = "Arcana II",
                rarity_num = 7,
            },
            ["tfa_cso_arcana_iii"] = {
                printname = "Arcana III",
                rarity_num = 7,
            },
            ["tfa_cso_ascalon"] = {
                printname = "Ascalon",
                rarity_num = 6,
            },
            ["tfa_cso_wondercannonex"] = {
                printname = "Asura Hell Splitter",
                rarity_num = 6,
            },
            ["tfa_cso_guardian"] = {
                printname = "AUG Guardian",
                rarity_num = 5,
            },
            ["tfa_cso_aug_guardians"] = {
                printname = "AUG Guardians",
                rarity_num = 6,
            },
            ["tfa_cso_automagv"] = {
                printname = "AutoMag V",
                rarity_num = 3,
            },
            ["tfa_cso_avalanche"] = {
                printname = "Avalanche",
                rarity_num = 5,
            },
            ["tfa_cso_awp"] = {
                printname = "AWP",
                rarity_num = 1,
            },
            ["tfa_cso_awpcamo"] = {
                printname = "AWP Camouflage",
                rarity_num = 2,
            },
            ["tfa_cso_elvenranger"] = {
                printname = "AWP Elven Ranger",
                rarity_num = 4,
            },
            ["tfa_cso_awp_red"] = {
                printname = "AWP Red",
                rarity_num = 2,
            },
            ["tfa_cso_awpz"] = {
                printname = "AWP-Z",
                rarity_num = 4,
            },
            ["tfa_cso_butterflyknife"] = {
                printname = "Balisong",
                rarity_num = 3,
            },
            ["tfa_cso_ballista"] = {
                printname = "Ballista",
                rarity_num = 6,
            },
            ["tfa_cso_balrog1"] = {
                printname = "BALROG-I",
                rarity_num = 5,
            },
            ["tfa_cso_balrog3"] = {
                printname = "BALROG-III",
                rarity_num = 5,
            },
            ["tfa_cso_balrog9"] = {
                printname = "BALROG-IX",
                rarity_num = 5,
            },
            ["tfa_cso_balrog5"] = {
                printname = "BALROG-V",
                rarity_num = 5,
            },
            ["tfa_cso_balrog7"] = {
                printname = "BALROG-VII",
                rarity_num = 5,
            },
            ["tfa_cso_balrog11"] = {
                printname = "BALROG-XI",
                rarity_num = 5,
            },
            ["tfa_cso_m95"] = {
                printname = "Barrett M95",
                rarity_num = 3,
            },
            ["tfa_cso_m95desert"] = {
                printname = "Barrett M95 Desert",
                rarity_num = 4,
            },
            ["tfa_cso_m95_expert"] = {
                printname = "Barrett M95 Expert",
                rarity_num = 5,
            },
            ["tfa_cso_m95_master"] = {
                printname = "Barrett M95 Master",
                rarity_num = 6,
            },
            ["tfa_cso_m95_xmas"] = {
                printname = "Barrett M95 XMAS",
                rarity_num = 4,
            },
            ["tfa_cso_basketball"] = {
                printname = "Basketball Grenade",
                rarity_num = 2,
            },
            ["tfa_cso_batista"] = {
                printname = "Batista",
                rarity_num = 5,
            },
            ["tfa_cso_bpython"] = {
                printname = "Battle Colt Python",
                rarity_num = 3,
            },
            ["tfa_cso_bfamas"] = {
                printname = "Battle FAMAS F1",
                rarity_num = 2,
            },
            ["tfa_cso_bfnp45"] = {
                printname = "Battle FNP-45",
                rarity_num = 2,
            },
            ["tfa_cso_bgalil"] = {
                printname = "Battle Galil",
                rarity_num = 2,
            },
            ["tfa_cso_bglock"] = {
                printname = "Battle Glock 18",
                rarity_num = 2,
            },
            ["tfa_cso_bhdagger"] = {
                printname = "Battle Hunting Dagger",
                rarity_num = 2,
            },
            ["tfa_cso_bmk3a1"] = {
                printname = "Battle MK3A1",
                rarity_num = 3,
            },
            ["tfa_cso_bmp5"] = {
                printname = "Battle MP5",
                rarity_num = 2,
            },
            ["tfa_cso_bnegev"] = {
                printname = "Battle Negev",
                rarity_num = 3,
            },
            ["tfa_cso_bpgm"] = {
                printname = "Battle PGM Hécate II",
                rarity_num = 4,
            },
            ["tfa_cso_bbizon"] = {
                printname = "Battle PP-19 Bizon",
                rarity_num = 3,
            },
            ["tfa_cso_bqbb95"] = {
                printname = "Battle QBB-95",
                rarity_num = 3,
            },
            ["tfa_cso_bqbs09"] = {
                printname = "Battle QBS-09",
                rarity_num = 3,
            },
            ["tfa_cso_bultimax100"] = {
                printname = "Battle Ultimax 100",
                rarity_num = 3,
            },
            ["tfa_cso_busp"] = {
                printname = "Battle USP45",
                rarity_num = 2,
            },
            ["tfa_cso_bazooka"] = {
                printname = "Bazooka",
                rarity_num = 4,
            },
            ["tfa_cso_beam_sword"] = {
                printname = "Beam Sword",
                rarity_num = 5,
            },
            ["tfa_cso_bearbuster"] = {
                printname = "Bear Buster",
                rarity_num = 4,
            },
            ["tfa_cso_bearfurymk1"] = {
                printname = "Bear Fury MK-1",
                rarity_num = 5,
            },
            ["tfa_cso_bearfurymk2"] = {
                printname = "Bear Fury MK-2",
                rarity_num = 6,
            },
            ["tfa_cso_bearfurymk3"] = {
                printname = "Bear Fury MK-3",
                rarity_num = 7,
            },
            ["tfa_cso_belial"] = {
                printname = "Belial",
                rarity_num = 6,
            },
            ["tfa_cso_bendita"] = {
                printname = "Bendita",
                rarity_num = 4,
            },
            ["tfa_cso_bendita_v6"] = {
                printname = "Bendita Expert",
                rarity_num = 5,
            },
            ["tfa_cso_m3"] = {
                printname = "Benelli M3",
                rarity_num = 1,
            },
            ["tfa_cso_xm1014"] = {
                printname = "Benelli XM1014",
                rarity_num = 1,
            },
            ["tfa_cso_xm1014red"] = {
                printname = "Benelli XM1014 Red Edition",
                rarity_num = 2,
            },
            ["tfa_cso_elite"] = {
                printname = "Beretta 92G Elite II",
                rarity_num = 2,
            },
            ["tfa_cso_arx160"] = {
                printname = "Beretta ARX-160",
                rarity_num = 3,
            },
            ["tfa_cso_arx160_expert"] = {
                printname = "Beretta ARX-160 Expert",
                rarity_num = 4,
            },
            ["tfa_cso_arx160_master"] = {
                printname = "Beretta ARX-160 Master",
                rarity_num = 5,
            },
            ["tfa_cso_dragoncannon"] = {
                printname = "Black Dragon Cannon",
                rarity_num = 6,
            },
            ["tfa_cso_dragoncannon_v6"] = {
                printname = "Black Dragon Cannon Expert",
                rarity_num = 7,
            },
            ["tfa_cso_r93"] = {
                printname = "Blaser R93 Tactical",
                rarity_num = 3,
            },
            ["tfa_cso_blaster"] = {
                printname = "Blaster",
                rarity_num = 4,
            },
            ["tfa_cso_blazenova"] = {
                printname = "Blaze Nova",
                rarity_num = 6,
            },
            ["tfa_cso_guilotine"] = {
                printname = "Blood Dripper",
                rarity_num = 5,
            },
            ["tfa_cso_jetgunex"] = {
                printname = "Blue Storm",
                rarity_num = 5,
            },
            ["tfa_cso_bouncer"] = {
                printname = "Bouncer",
                rarity_num = 4,
            },
            ["tfa_cso_m777"] = {
                printname = "Brick Piece M777 (A Mode)",
                rarity_num = 5,
            },
            ["tfa_cso_howitzer"] = {
                printname = "Brick Piece M777 (B Mode)",
                rarity_num = 5,
            },
            ["tfa_cso_s1451"] = {
                printname = "Brick Piece S1451 (A Mode)",
                rarity_num = 5,
            },
            ["tfa_cso_katyusha"] = {
                printname = "Brick Piece S1451 (B Mode)",
                rarity_num = 5,
            },
            ["tfa_cso_t50"] = {
                printname = "Brick Piece T50 (A Mode)",
                rarity_num = 5,
            },
            ["tfa_cso_tank"] = {
                printname = "Brick Piece T50 (B Mode)",
                rarity_num = 5,
            },
            ["tfa_cso_brickpiecev2"] = {
                printname = "Brick Piece V2 (A Mode)",
                rarity_num = 6,
            },
            ["tfa_cso_v2rocket"] = {
                printname = "Brick Piece V2 (B Mode)",
                rarity_num = 6,
            },
            ["tfa_cso_brionac"] = {
                printname = "Brionac",
                rarity_num = 6,
            },
            ["tfa_cso_broad"] = {
                printname = "Broad Divine",
                rarity_num = 7,
            },
            ["tfa_cso_bunkerbuster"] = {
                printname = "Bunker Buster LTD",
                rarity_num = 4,
            },
            ["tfa_cso_burningaug"] = {
                printname = "Burning AUG",
                rarity_num = 4,
            },
            ["tfa_cso_c4"] = {
                printname = "C4",
                rarity_num = 1,
            },
            ["tfa_cso_cake"] = {
                printname = "Cake Grenade",
                rarity_num = 2,
            },
            ["tfa_cso_m950"] = {
                printname = "Calico M950",
                rarity_num = 2,
            },
            ["tfa_cso_m950_v6"] = {
                printname = "Calico M950 Expert",
                rarity_num = 3,
            },
            ["tfa_cso_m950_v8"] = {
                printname = "Calico M950 Master",
                rarity_num = 4,
            },
            ["tfa_cso_chaingrenade"] = {
                printname = "Chain Grenade",
                rarity_num = 3,
            },
            ["tfa_cso_charger5"] = {
                printname = "CHARGER-5",
                rarity_num = 5,
            },
            ["tfa_cso_charger7"] = {
                printname = "CHARGER-7",
                rarity_num = 5,
            },
            ["tfa_cso_m200"] = {
                printname = "Cheytac Intervention M200",
                rarity_num = 4,
            },
            ["tfa_cso_mooncake"] = {
                printname = "Chuseok",
                rarity_num = 2,
            },
            ["tfa_cso_clawhammer"] = {
                printname = "Claw Hammer",
                rarity_num = 2,
            },
            ["tfa_cso_coilmg"] = {
                printname = "Coil Machine Gun",
                rarity_num = 5,
            },
            ["tfa_cso_coldsteelblade"] = {
                printname = "Cold Steel Knife",
                rarity_num = 3,
            },
            ["tfa_cso_python"] = {
                printname = "Colt Python",
                rarity_num = 2,
            },
            ["tfa_cso_bow"] = {
                printname = "Compound Bow",
                rarity_num = 4,
            },
            ["tfa_cso_bow_v6"] = {
                printname = "Compound Bow Expert",
                rarity_num = 5,
            },
            ["tfa_cso_crossbow"] = {
                printname = "Crossbow",
                rarity_num = 2,
            },
            ["tfa_cso_crossbowex"] = {
                printname = "Crossbow Advance",
                rarity_num = 3,
            },
            ["tfa_cso_crossbowex_v6"] = {
                printname = "Crossbow Advance Expert",
                rarity_num = 4,
            },
            ["tfa_cso_crossbowcls"] = {
                printname = "Crossbow Classic",
                rarity_num = 2,
            },
            ["tfa_cso_crossbowcls_v6"] = {
                printname = "Crossbow Classic Expert",
                rarity_num = 3,
            },
            ["tfa_cso_crossbowcls_v8"] = {
                printname = "Crossbow Classic Master",
                rarity_num = 4,
            },
            ["tfa_cso_crow1"] = {
                printname = "CROW-1",
                rarity_num = 5,
            },
            ["tfa_cso_crow11"] = {
                printname = "CROW-11",
                rarity_num = 5,
            },
            ["tfa_cso_crow3"] = {
                printname = "CROW-3",
                rarity_num = 5,
            },
            ["tfa_cso_crow5"] = {
                printname = "CROW-5",
                rarity_num = 5,
            },
            ["tfa_cso_crow7"] = {
                printname = "CROW-7",
                rarity_num = 5,
            },
            ["tfa_cso_crow9"] = {
                printname = "CROW-9",
                rarity_num = 5,
            },
            ["tfa_cso_crowbar"] = {
                printname = "Crowbar",
                rarity_num = 1,
            },
            ["tfa_cso_crowbarcraft"] = {
                printname = "Crowbar Maverick",
                rarity_num = 3,
            },
            ["tfa_cso_cyclone"] = {
                printname = "Cyclone",
                rarity_num = 4,
            },
            ["tfa_cso_cyclops"] = {
                printname = "Cyclops",
                rarity_num = 5,
            },
            ["tfa_cso_k1a"] = {
                printname = "Daewoo K1A",
                rarity_num = 1,
            },
            ["tfa_cso_k1ase"] = {
                printname = "Daewoo K1A Special Edition",
                rarity_num = 2,
            },
            ["tfa_cso_k3"] = {
                printname = "Daewoo K3",
                rarity_num = 2,
            },
            ["tfa_cso_cartfrag"] = {
                printname = "Dao Grenade",
                rarity_num = 2,
            },
            ["tfa_cso_luger_legacy"] = {
                printname = "Dark Legacy Luger",
                rarity_num = 4,
            },
            ["tfa_cso_gungnirex"] = {
                printname = "Dark Star",
                rarity_num = 6,
            },
            ["tfa_cso_dartpistol"] = {
                printname = "Dart Pistol",
                rarity_num = 3,
            },
            ["tfa_cso_death_eater"] = {
                printname = "Death Eater",
                rarity_num = 6,
            },
            ["tfa_cso_dvhammer"] = {
                printname = "Demolition Hammer",
                rarity_num = 3,
            },
            ["tfa_cso_scarlet_rose"] = {
                printname = "Demonic Scarlet Rose",
                rarity_num = 6,
            },
            ["tfa_cso_deagle"] = {
                printname = "Desert Eagle",
                rarity_num = 1,
            },
            ["tfa_cso_crimson_hunter"] = {
                printname = "Desert Eagle Crimson Hunter",
                rarity_num = 4,
            },
            ["tfa_cso_crimson_hunter_expert"] = {
                printname = "Desert Eagle Crimson Hunter Expert",
                rarity_num = 5,
            },
            ["tfa_cso_g_deagle"] = {
                printname = "Desert Eagle Gold",
                rarity_num = 3,
            },
            ["tfa_cso_deaglered"] = {
                printname = "Desert Eagle Red",
                rarity_num = 2,
            },
            ["tfa_cso_deaglewg"] = {
                printname = "Desert Eagle White Gold",
                rarity_num = 3,
            },
            ["tfa_cso_destroyer"] = {
                printname = "Destroyer",
                rarity_num = 4,
            },
            ["tfa_cso_destroyer_v6"] = {
                printname = "Destroyer Expert",
                rarity_num = 5,
            },
            ["tfa_cso_destroyer_v8"] = {
                printname = "Destroyer Master",
                rarity_num = 6,
            },
            ["tfa_cso_destroyer_v4"] = {
                printname = "Destroyer Refine",
                rarity_num = 5,
            },
            ["tfa_cso_divine_blaster"] = {
                printname = "Divine Blaster",
                rarity_num = 7,
            },
            ["tfa_cso_musket"] = {
                printname = "Divine Lock",
                rarity_num = 7,
            },
            ["tfa_cso_doom_blaster"] = {
                printname = "Doom Blaster",
                rarity_num = 6,
            },
            ["tfa_cso_dualtacknife"] = {
                printname = "Double Tactical Knife",
                rarity_num = 4,
            },
            ["tfa_cso_dbarrel"] = {
                printname = "Double-barreled shotgun",
                rarity_num = 2,
            },
            ["tfa_cso_dbarrel_v6"] = {
                printname = "Double-barreled shotgun Expert",
                rarity_num = 3,
            },
            ["tfa_cso_dbarrel_g"] = {
                printname = "Double-barreled shotgun Gold Edition",
                rarity_num = 3,
            },
            ["tfa_cso_dbarrel_v8"] = {
                printname = "Double-barreled shotgun Master",
                rarity_num = 4,
            },
            ["tfa_cso_dragonknife"] = {
                printname = "Dragon Knife",
                rarity_num = 4,
            },
            ["tfa_cso_svd"] = {
                printname = "Dragunov SVD",
                rarity_num = 2,
            },
            ["tfa_cso_drakar1"] = {
                printname = "Drakar-I",
                rarity_num = 5,
            },
            ["tfa_cso_drakar_base"] = {
                printname = "Drakar-I",
                rarity_num = 5,
            },
            ["tfa_cso_drakar2"] = {
                printname = "Drakar-II",
                rarity_num = 5,
            },
            ["tfa_cso_drakar3"] = {
                printname = "Drakar-III",
                rarity_num = 5,
            },
            ["tfa_cso_dreadnova"] = {
                printname = "Dread Nova",
                rarity_num = 6,
            },
            ["tfa_cso_drillgun"] = {
                printname = "Drill Gun",
                rarity_num = 4,
            },
            ["tfa_cso_gunkata"] = {
                printname = "Dual Beretta Gunslinger",
                rarity_num = 5,
            },
            ["tfa_cso_rainbowkata"] = {
                printname = "Dual Beretta Gunslinger Global Showcase 2018",
                rarity_num = 6,
            },
            ["tfa_cso_windrider"] = {
                printname = "Dual Beretta Windrider",
                rarity_num = 5,
            },
            ["tfa_cso_ddeagle"] = {
                printname = "Dual Desert Eagle",
                rarity_num = 3,
            },
            ["tfa_cso_dualinfinity"] = {
                printname = "Dual Infinity",
                rarity_num = 4,
            },
            ["tfa_cso_infinityex1"] = {
                printname = "Dual Infinity Custom",
                rarity_num = 5,
            },
            ["tfa_cso_dualinfinityfinal"] = {
                printname = "Dual Infinity Final",
                rarity_num = 6,
            },
            ["tfa_cso_infinityex2desert"] = {
                printname = "Dual Infinity Final Desert",
                rarity_num = 6,
            },
            ["tfa_cso_dualkriss"] = {
                printname = "Dual Kriss",
                rarity_num = 3,
            },
            ["tfa_cso_dualkrisshero"] = {
                printname = "Dual Kriss Custom",
                rarity_num = 4,
            },
            ["tfa_cso_dualkriss_v6"] = {
                printname = "Dual Kriss Expert",
                rarity_num = 4,
            },
            ["tfa_cso_dualkriss_v8"] = {
                printname = "Dual Kriss Master",
                rarity_num = 5,
            },
            ["tfa_cso_dualkriss_v4"] = {
                printname = "Dual Kriss Refine",
                rarity_num = 4,
            },
            ["tfa_cso_dmp7a1"] = {
                printname = "Dual MP7A1",
                rarity_num = 3,
            },
            ["tfa_cso_dualnata"] = {
                printname = "Dual Nata Knives",
                rarity_num = 3,
            },
            ["tfa_cso_budgetsword"] = {
                printname = "Dual Sword Hellfire",
                rarity_num = 5,
            },
            ["tfa_cso_dualsword"] = {
                printname = "Dual Sword Phantom Slayer",
                rarity_num = 6,
            },
            ["tfa_cso_dualsword_rb"] = {
                printname = "Dual Sword Rainbow Caster",
                rarity_num = 6,
            },
            ["tfa_cso_dualuzi"] = {
                printname = "Dual Uzi",
                rarity_num = 2,
            },
            ["tfa_cso_dualuzi_v6"] = {
                printname = "Dual Uzi Expert",
                rarity_num = 3,
            },
            ["tfa_cso_dualkatana"] = {
                printname = "Dual Wakizashi",
                rarity_num = 4,
            },
            ["tfa_cso_electron3"] = {
                printname = "Electron-III",
                rarity_num = 5,
            },
            ["tfa_cso_electronv"] = {
                printname = "Electron-V",
                rarity_num = 5,
            },
            ["tfa_cso_electron11"] = {
                printname = "Electron-XI",
                rarity_num = 5,
            },
            ["tfa_cso_elementaltracker"] = {
                printname = "Elemental Tracker",
                rarity_num = 6,
            },
            ["tfa_cso_eruptor"] = {
                printname = "Eruptor",
                rarity_num = 5,
            },
            ["tfa_cso_laserfistex"] = {
                printname = "Eternity Laser Fist",
                rarity_num = 6,
            },
            ["tfa_cso_ethereal"] = {
                printname = "Ethereal",
                rarity_num = 5,
            },
            ["tfa_cso_failnaught"] = {
                printname = "Failnaught",
                rarity_num = 6,
            },
            ["tfa_cso_falcon"] = {
                printname = "Falcon",
                rarity_num = 4,
            },
            ["tfa_cso_famas"] = {
                printname = "FAMAS F1",
                rarity_num = 1,
            },
            ["tfa_cso_fglauncher"] = {
                printname = "FG-Launcher",
                rarity_num = 4,
            },
            ["tfa_cso_bisonfox"] = {
                printname = "Fire Fox",
                rarity_num = 4,
            },
            ["tfa_cso_firetracker"] = {
                printname = "Fire Tracker",
                rarity_num = 6,
            },
            ["tfa_cso_fire_vulcan"] = {
                printname = "Fire Vulcan",
                rarity_num = 5,
            },
            ["tfa_cso_firebomb"] = {
                printname = "Firebomb",
                rarity_num = 2,
            },
            ["tfa_cso_flashbang"] = {
                printname = "Flashbang",
                rarity_num = 1,
            },
            ["tfa_cso_f2000"] = {
                printname = "FN F2000",
                rarity_num = 2,
            },
            ["tfa_cso_fiveseven"] = {
                printname = "FN Five-seveN",
                rarity_num = 1,
            },
            ["tfa_cso_mk48"] = {
                printname = "FN MK48",
                rarity_num = 3,
            },
            ["tfa_cso_mk48_expert"] = {
                printname = "FN MK48 - Expert",
                rarity_num = 4,
            },
            ["tfa_cso_mk48_master"] = {
                printname = "FN MK48 - Master",
                rarity_num = 5,
            },
            ["tfa_cso_p90"] = {
                printname = "FN P90",
                rarity_num = 1,
            },
            ["tfa_cso_pchan"] = {
                printname = "FN P90 Lapin",
                rarity_num = 4,
            },
            ["tfa_cso_p90rabbit"] = {
                printname = "FN P90 Turtle Rabbit",
                rarity_num = 4,
            },
            ["tfa_cso_fnc"] = {
                printname = "FNC",
                rarity_num = 2,
            },
            ["tfa_cso_fnp45"] = {
                printname = "FNP-45",
                rarity_num = 2,
            },
            ["tfa_cso_frostbite"] = {
                printname = "Frost Viper",
                rarity_num = 5,
            },
            ["tfa_cso_speargun"] = {
                printname = "Gae Bolg",
                rarity_num = 5,
            },
            ["tfa_cso_speargun_v6"] = {
                printname = "Gae Bolg Chimera",
                rarity_num = 6,
            },
            ["tfa_cso_galil"] = {
                printname = "Galil",
                rarity_num = 1,
            },
            ["tfa_cso_galilcraft"] = {
                printname = "Galil Maverick",
                rarity_num = 3,
            },
            ["tfa_cso_bird_canon_mk1"] = {
                printname = "Gear Bird Cannon MK-1",
                rarity_num = 5,
            },
            ["tfa_cso_bird_canon_mk2"] = {
                printname = "Gear Bird Cannon MK-2",
                rarity_num = 6,
            },
            ["tfa_cso_bird_canon_mk3"] = {
                printname = "Gear Bird Cannon MK-3",
                rarity_num = 7,
            },
            ["tfa_cso_bird_canon_mk4"] = {
                printname = "Gear Bird Cannon MK-4",
                rarity_num = 7,
            },
            ["tfa_cso_magnumdrillex"] = {
                printname = "Gigantic Drill",
                rarity_num = 5,
            },
            ["tfa_cso_gilboa"] = {
                printname = "Gilboa Carbine",
                rarity_num = 3,
            },
            ["tfa_cso_gilboa_viper"] = {
                printname = "Gilboa Viper",
                rarity_num = 4,
            },
            ["tfa_cso_glock"] = {
                printname = "Glock 18",
                rarity_num = 1,
            },
            ["tfa_cso_gl_glock"] = {
                printname = "Glock 18 Garlic Like",
                rarity_num = 3,
            },
            ["tfa_cso_glock_red"] = {
                printname = "Glock 18 Red",
                rarity_num = 2,
            },
            ["tfa_cso_leapstrikegun"] = {
                printname = "Gravity Repulsor",
                rarity_num = 5,
            },
            ["tfa_cso_dragonblade"] = {
                printname = "Green Dragon Blade",
                rarity_num = 5,
            },
            ["tfa_cso_dragonblade_expert"] = {
                printname = "Green Dragon Blade - Expert",
                rarity_num = 6,
            },
            ["tfa_cso_gungnir"] = {
                printname = "Gungnir",
                rarity_num = 6,
            },
            ["tfa_cso_hammer"] = {
                printname = "Hammer",
                rarity_num = 2,
            },
            ["tfa_cso_hammerdesert"] = {
                printname = "Hammer Desert",
                rarity_num = 3,
            },
            ["tfa_cso_hauteclere"] = {
                printname = "Hauteclere",
                rarity_num = 6,
            },
            ["tfa_cso_hegrenade"] = {
                printname = "HE Grenade",
                rarity_num = 1,
            },
            ["tfa_cso_heartbomb"] = {
                printname = "Heart Bomb",
                rarity_num = 2,
            },
            ["tfa_cso_heavenscorcher"] = {
                printname = "Heaven Splitter",
                rarity_num = 6,
            },
            ["tfa_cso_hzknife"] = {
                printname = "Heavy Zombie Knife",
                rarity_num = 3,
            },
            ["tfa_cso_hellhound"] = {
                printname = "Hellhound",
                rarity_num = 5,
            },
            ["tfa_cso_hk_g11"] = {
                printname = "HK G11",
                rarity_num = 3,
            },
            ["tfa_cso_g11_v6"] = {
                printname = "HK G11 Expert",
                rarity_num = 4,
            },
            ["tfa_cso_g11g"] = {
                printname = "HK G11 Gold Edition",
                rarity_num = 4,
            },
            ["tfa_cso_g11_v8"] = {
                printname = "HK G11 Master",
                rarity_num = 5,
            },
            ["tfa_cso_g3sg1"] = {
                printname = "HK G3SG-1",
                rarity_num = 1,
            },
            ["tfa_cso_hk121"] = {
                printname = "HK121",
                rarity_num = 3,
            },
            ["tfa_cso_hk121_custom"] = {
                printname = "HK121 Custom",
                rarity_num = 4,
            },
            ["tfa_cso_hk23"] = {
                printname = "HK23E",
                rarity_num = 2,
            },
            ["tfa_cso_hk23_expert"] = {
                printname = "HK23E Expert",
                rarity_num = 3,
            },
            ["tfa_cso_hk23g"] = {
                printname = "HK23E Gold",
                rarity_num = 3,
            },
            ["tfa_cso_hk23_master"] = {
                printname = "HK23E Master",
                rarity_num = 4,
            },
            ["tfa_cso_hk416"] = {
                printname = "HK416",
                rarity_num = 2,
            },
            ["tfa_cso_holybomb"] = {
                printname = "Holy Bomb",
                rarity_num = 3,
            },
            ["tfa_cso_holybomb_refined"] = {
                printname = "Holy Bomb Refined",
                rarity_num = 4,
            },
            ["tfa_cso_holysword"] = {
                printname = "Holy Sword Divine Crusader",
                rarity_num = 7,
            },
            ["tfa_cso_sheepsword"] = {
                printname = "Horn Kujang",
                rarity_num = 4,
            },
            ["tfa_cso_horseaxe"] = {
                printname = "Horse Axe",
                rarity_num = 3,
            },
            ["tfa_cso_x-12"] = {
                printname = "Hunter Killer X-12",
                rarity_num = 5,
            },
            ["tfa_cso_x-15"] = {
                printname = "Hunter Killer X-15",
                rarity_num = 5,
            },
            ["tfa_cso_x-45"] = {
                printname = "Hunter Killer X-45",
                rarity_num = 5,
            },
            ["tfa_cso_x-7"] = {
                printname = "Hunter Killer X-7",
                rarity_num = 5,
            },
            ["tfa_cso_x-90"] = {
                printname = "Hunter Killer X-90",
                rarity_num = 5,
            },
            ["tfa_cso_hdagger"] = {
                printname = "Hunting Dagger",
                rarity_num = 2,
            },
            ["tfa_cso_hdagger_v6"] = {
                printname = "Hunting Dagger Expert",
                rarity_num = 3,
            },
            ["tfa_cso_hdagger_v8"] = {
                printname = "Hunting Dagger Master",
                rarity_num = 4,
            },
            ["tfa_cso_hdagger_v4"] = {
                printname = "Hunting Dagger Refined",
                rarity_num = 3,
            },
            ["tfa_cso_hwando"] = {
                printname = "Hwando",
                rarity_num = 3,
            },
            ["tfa_cso_speargunex"] = {
                printname = "Hyper Gaebolg",
                rarity_num = 6,
            },
            ["tfa_cso_chainsr"] = {
                printname = "Hécate II Umbra",
                rarity_num = 5,
            },
            ["tfa_cso_icecreamblade"] = {
                printname = "Ice Cream Blade",
                rarity_num = 3,
            },
            ["tfa_cso_ignitebomb"] = {
                printname = "IGNITE-10",
                rarity_num = 5,
            },
            ["tfa_cso_ignitemg"] = {
                printname = "IGNITE-7",
                rarity_num = 5,
            },
            ["tfa_cso_volcanoex"] = {
                printname = "Inferno Cannon",
                rarity_num = 6,
            },
            ["tfa_cso_infinite_black"] = {
                printname = "Infinity Black",
                rarity_num = 4,
            },
            ["tfa_cso_laserfist"] = {
                printname = "Infinity Laser Fist",
                rarity_num = 5,
            },
            ["tfa_cso_infinite_red"] = {
                printname = "Infinity Red",
                rarity_num = 4,
            },
            ["tfa_cso_infinite_silver"] = {
                printname = "Infinity Silver",
                rarity_num = 4,
            },
            ["tfa_cso_pumpkin"] = {
                printname = "Jack-o'-Lantern",
                rarity_num = 3,
            },
            ["tfa_cso_janus1"] = {
                printname = "JANUS-1",
                rarity_num = 6,
            },
            ["tfa_cso_janus11"] = {
                printname = "JANUS-11",
                rarity_num = 6,
            },
            ["tfa_cso_janus3"] = {
                printname = "JANUS-3",
                rarity_num = 6,
            },
            ["tfa_cso_janus5"] = {
                printname = "JANUS-5",
                rarity_num = 6,
            },
            ["tfa_cso_janus7"] = {
                printname = "JANUS-7",
                rarity_num = 6,
            },
            ["tfa_cso_janus7xmas"] = {
                printname = "JANUS-7 Xmas",
                rarity_num = 6,
            },
            ["tfa_cso_janus9"] = {
                printname = "JANUS-9",
                rarity_num = 6,
            },
            ["tfa_cso_jaydagger"] = {
                printname = "Jay's Dagger",
                rarity_num = 3,
            },
            ["tfa_cso_joker"] = {
                printname = "Joker's Staff",
                rarity_num = 5,
            },
            ["tfa_cso_k1a_maverick"] = {
                printname = "K1A Maverick",
                rarity_num = 3,
            },
            ["tfa_cso_kh2002"] = {
                printname = "KH-2002",
                rarity_num = 2,
            },
            ["tfa_cso_kingcobra"] = {
                printname = "King Cobra",
                rarity_num = 3,
            },
            ["tfa_cso_kingcobra_v6"] = {
                printname = "King Cobra Expert",
                rarity_num = 4,
            },
            ["tfa_cso_kingcobragold"] = {
                printname = "King Cobra Gold Edition",
                rarity_num = 4,
            },
            ["tfa_cso_kingcobra_v8"] = {
                printname = "King Cobra Master",
                rarity_num = 5,
            },
            ["tfa_cso_kingdombow"] = {
                printname = "Kingdom Bow",
                rarity_num = 5,
            },
            ["tfa_cso_kriss_v"] = {
                printname = "Kriss Super V",
                rarity_num = 2,
            },
            ["tfa_cso_ksg12"] = {
                printname = "KSG-12",
                rarity_num = 3,
            },
            ["tfa_cso_ksg12_expert"] = {
                printname = "KSG-12 Expert",
                rarity_num = 4,
            },
            ["tfa_cso_ksg12_gold"] = {
                printname = "KSG-12 Gold",
                rarity_num = 4,
            },
            ["tfa_cso_ksg12_master"] = {
                printname = "KSG-12 Master",
                rarity_num = 5,
            },
            ["tfa_cso_kujang"] = {
                printname = "Kujang",
                rarity_num = 3,
            },
            ["tfa_cso_l85a2"] = {
                printname = "L85A2",
                rarity_num = 2,
            },
            ["tfa_cso_laevatein"] = {
                printname = "Laevatein",
                rarity_num = 6,
            },
            ["tfa_cso_laserminigun"] = {
                printname = "Laser Minigun",
                rarity_num = 5,
            },
            ["tfa_cso_laserchainsaw"] = {
                printname = "Laser Ripper",
                rarity_num = 5,
            },
            ["tfa_cso_laser_storm"] = {
                printname = "Laser Storm",
                rarity_num = 6,
            },
            ["tfa_cso_herochainsaw"] = {
                printname = "Last Stand Chainsaw",
                rarity_num = 5,
            },
            ["tfa_cso_watercannon"] = {
                printname = "Leviathan",
                rarity_num = 6,
            },
            ["tfa_cso_guitar"] = {
                printname = "Lightning AR-1",
                rarity_num = 4,
            },
            ["tfa_cso_violingun"] = {
                printname = "Lightning AR-2",
                rarity_num = 4,
            },
            ["tfa_cso_cartred_a"] = {
                printname = "Lightning Bazzi-1",
                rarity_num = 4,
            },
            ["tfa_cso_waterpistol"] = {
                printname = "Lightning BIG-EYE",
                rarity_num = 4,
            },
            ["tfa_cso_cartblue_a"] = {
                printname = "Lightning Dao-1",
                rarity_num = 4,
            },
            ["tfa_cso_jetgun"] = {
                printname = "Lightning Fury",
                rarity_num = 5,
            },
            ["tfa_cso_cameragun"] = {
                printname = "Lightning HMG-1",
                rarity_num = 4,
            },
            ["tfa_cso_heavyzg"] = {
                printname = "Lightning HZ-1",
                rarity_num = 4,
            },
            ["tfa_cso_lightzg"] = {
                printname = "Lightning LZ-1",
                rarity_num = 4,
            },
            ["tfa_cso_lightning_rail"] = {
                printname = "Lightning Rail",
                rarity_num = 5,
            },
            ["tfa_cso_lightning_rail_v6"] = {
                printname = "Lightning Rail Expert",
                rarity_num = 6,
            },
            ["tfa_cso_lightning_rail_v8"] = {
                printname = "Lightning Rail Master",
                rarity_num = 7,
            },
            ["tfa_cso_lightning_rail_v4"] = {
                printname = "Lightning Rail Refine",
                rarity_num = 6,
            },
            ["tfa_cso_umbrella"] = {
                printname = "Lightning SG-1",
                rarity_num = 4,
            },
            ["tfa_cso_watergun"] = {
                printname = "Lightning SMG-1",
                rarity_num = 4,
            },
            ["tfa_cso_lightningtracker"] = {
                printname = "Lightning Tracker",
                rarity_num = 6,
            },
            ["tfa_cso_luger"] = {
                printname = "Luger P08",
                rarity_num = 2,
            },
            ["tfa_cso_luger_expert"] = {
                printname = "Luger P08 - Expert",
                rarity_num = 3,
            },
            ["tfa_cso_luger_gold"] = {
                printname = "Luger P08 - Gold",
                rarity_num = 3,
            },
            ["tfa_cso_luger_master"] = {
                printname = "Luger P08 - Master",
                rarity_num = 4,
            },
            ["tfa_cso_luger_silver"] = {
                printname = "Luger P08 - Silver",
                rarity_num = 3,
            },
            ["tfa_cso_lunarcannon"] = {
                printname = "Lunar Cannon",
                rarity_num = 6,
            },
            ["tfa_cso_m1garand"] = {
                printname = "M1 Garand",
                rarity_num = 2,
            },
            ["tfa_cso_m134"] = {
                printname = "M134 Minigun",
                rarity_num = 3,
            },
            ["tfa_cso_m134b"] = {
                printname = "M134 Minigun Blank",
                rarity_num = 4,
            },
            ["tfa_cso_chainmg"] = {
                printname = "M134 Minigun Umbra",
                rarity_num = 5,
            },
            ["tfa_cso_m134_predator"] = {
                printname = "M134 Predator",
                rarity_num = 5,
            },
            ["tfa_cso_m134_vulcan"] = {
                printname = "M134 Vulcan",
                rarity_num = 5,
            },
            ["tfa_cso_m134_xmas"] = {
                printname = "M134 X-Mas",
                rarity_num = 4,
            },
            ["tfa_cso_at4"] = {
                printname = "M136 AT4",
                rarity_num = 4,
            },
            ["tfa_cso_at4ex"] = {
                printname = "M136 AT4 CS",
                rarity_num = 5,
            },
            ["tfa_cso_m14ebr"] = {
                printname = "M14 EBR",
                rarity_num = 3,
            },
            ["tfa_cso_m14ebr_expert"] = {
                printname = "M14 EBR Expert",
                rarity_num = 4,
            },
            ["tfa_cso_m14ebrg"] = {
                printname = "M14 EBR Gold",
                rarity_num = 4,
            },
            ["tfa_cso_m14ebr_master"] = {
                printname = "M14 EBR Master",
                rarity_num = 5,
            },
            ["tfa_cso_m16a1"] = {
                printname = "M16A1",
                rarity_num = 1,
            },
            ["tfa_cso_m16a1ep"] = {
                printname = "M16A1 Veteran",
                rarity_num = 2,
            },
            ["tfa_cso_m16a4"] = {
                printname = "M16A4",
                rarity_num = 2,
            },
            ["tfa_cso_m1887_maverick"] = {
                printname = "M1887 Maverick",
                rarity_num = 4,
            },
            ["tfa_cso_m1887_maverick_v6"] = {
                printname = "M1887 Maverick Expert",
                rarity_num = 5,
            },
            ["tfa_cso_m1887_maverick_v8"] = {
                printname = "M1887 Maverick Master",
                rarity_num = 6,
            },
            ["tfa_cso_m1887_maverick_v4"] = {
                printname = "M1887 Maverick Refine",
                rarity_num = 5,
            },
            ["tfa_cso_m1911a1"] = {
                printname = "M1911 A1",
                rarity_num = 2,
            },
            ["tfa_cso_m1918bar"] = {
                printname = "M1918 BAR",
                rarity_num = 3,
            },
            ["tfa_cso_m2"] = {
                printname = "M2",
                rarity_num = 4,
            },
            ["tfa_cso_m2_base"] = {
                printname = "M2",
                rarity_num = 4,
            },
            ["tfa_cso_m2desert"] = {
                printname = "M2 Desert",
                rarity_num = 5,
            },
            ["tfa_cso_m2_devastator"] = {
                printname = "M2 Devastator",
                rarity_num = 6,
            },
            ["tfa_cso_m2_v6"] = {
                printname = "M2 Expert",
                rarity_num = 5,
            },
            ["tfa_cso_m2_v8"] = {
                printname = "M2 Master",
                rarity_num = 6,
            },
            ["tfa_cso_m24grenade"] = {
                printname = "M24 Grenade",
                rarity_num = 2,
            },
            ["tfa_cso_m249"] = {
                printname = "M249",
                rarity_num = 2,
            },
            ["tfa_cso_m249camo"] = {
                printname = "M249 Camouflage",
                rarity_num = 3,
            },
            ["tfa_cso_m249phoenix"] = {
                printname = "M249 Phoenix",
                rarity_num = 5,
            },
            ["tfa_cso_m249ra"] = {
                printname = "M249 Ra",
                rarity_num = 5,
            },
            ["tfa_cso_m249_xmas"] = {
                printname = "M249 Red",
                rarity_num = 3,
            },
            ["tfa_cso_m249ep"] = {
                printname = "M249 Veteran",
                rarity_num = 3,
            },
            ["tfa_cso_m3dragonex"] = {
                printname = "M3 Azhi Dahaka",
                rarity_num = 5,
            },
            ["tfa_cso_m3shark"] = {
                printname = "M3 Big Shark",
                rarity_num = 4,
            },
            ["tfa_cso_m3dragon"] = {
                printname = "M3 Black Dragon",
                rarity_num = 5,
            },
            ["tfa_cso_m32_venom"] = {
                printname = "M32 MGL Venom",
                rarity_num = 5,
            },
            ["tfa_cso_m4a1"] = {
                printname = "M4A1",
                rarity_num = 1,
            },
            ["tfa_cso_m4a1_hq"] = {
                printname = "M4A1 Camouflage",
                rarity_num = 2,
            },
            ["tfa_cso_darkknight"] = {
                printname = "M4A1 Dark Knight",
                rarity_num = 6,
            },
            ["tfa_cso_darkknight_v8"] = {
                printname = "M4A1 Dark Knight Expert",
                rarity_num = 7,
            },
            ["tfa_cso_m4a1dragon"] = {
                printname = "M4A1 Dragon",
                rarity_num = 4,
            },
            ["tfa_cso_m4a1gold"] = {
                printname = "M4A1 Gold",
                rarity_num = 3,
            },
            ["tfa_cso_m4a1red"] = {
                printname = "M4A1 Red",
                rarity_num = 2,
            },
            ["tfa_cso_m4a1g"] = {
                printname = "M4A1 Scope",
                rarity_num = 2,
            },
            ["tfa_cso_darkknight_v6"] = {
                printname = "M4A1 Shadow Knight",
                rarity_num = 7,
            },
            ["tfa_cso_m4a1wg"] = {
                printname = "M4A1 White Gold",
                rarity_num = 3,
            },
            ["tfa_cso_m60"] = {
                printname = "M60E4",
                rarity_num = 2,
            },
            ["tfa_cso_m60desert"] = {
                printname = "M60E4 Desert",
                rarity_num = 3,
            },
            ["tfa_cso_m60_v6"] = {
                printname = "M60E4 Expert",
                rarity_num = 4,
            },
            ["tfa_cso_m60g"] = {
                printname = "M60E4 Gold",
                rarity_num = 3,
            },
            ["tfa_cso_m60_v8"] = {
                printname = "M60E4 Master",
                rarity_num = 5,
            },
            ["tfa_cso_m60craft"] = {
                printname = "M60E4 Maverick",
                rarity_num = 4,
            },
            ["tfa_cso_fragnade"] = {
                printname = "M67 Frag Grenade",
                rarity_num = 1,
            },
            ["tfa_cso_m79"] = {
                printname = "M79",
                rarity_num = 2,
            },
            ["tfa_cso_m79_gold"] = {
                printname = "M79 Gold",
                rarity_num = 3,
            },
            ["tfa_cso_m95ghost"] = {
                printname = "M95 Ghost Knight",
                rarity_num = 5,
            },
            ["tfa_cso_m95tiger"] = {
                printname = "M95 White Tiger",
                rarity_num = 5,
            },
            ["tfa_cso_m950_attack"] = {
                printname = "M950 Attack",
                rarity_num = 4,
            },
            ["tfa_cso_mac10_v2"] = {
                printname = "MAC-10",
                rarity_num = 1,
            },
            ["tfa_cso_machete"] = {
                printname = "Machete",
                rarity_num = 2,
            },
            ["tfa_cso_magnumdrill"] = {
                printname = "Magnum Drill",
                rarity_num = 4,
            },
            ["tfa_cso_magnumdrill_expert"] = {
                printname = "Magnum Drill Expert",
                rarity_num = 5,
            },
            ["tfa_cso_magnumdrillg"] = {
                printname = "Magnum Drill Gold",
                rarity_num = 5,
            },
            ["tfa_cso_magnum_lancer"] = {
                printname = "Magnum Launcher",
                rarity_num = 6,
            },
            ["tfa_cso_magnumlauncher_gs18"] = {
                printname = "Magnum Launcher Global Showcase 2018",
                rarity_num = 7,
            },
            ["tfa_cso_magnum_shooter"] = {
                printname = "Magnum Shooter",
                rarity_num = 5,
            },
            ["tfa_cso_mauser_c96"] = {
                printname = "Mauser C96",
                rarity_num = 2,
            },
            ["tfa_cso_mechasaurus_mk1"] = {
                printname = "Mechasaurus MK-1",
                rarity_num = 5,
            },
            ["tfa_cso_mechasaurus_mk2"] = {
                printname = "Mechasaurus MK-2",
                rarity_num = 6,
            },
            ["tfa_cso_mechasaurus_mk3"] = {
                printname = "Mechasaurus MK-3",
                rarity_num = 7,
            },
            ["tfa_cso_mechasaurus_mk4"] = {
                printname = "Mechasaurus MK-4",
                rarity_num = 7,
            },
            ["tfa_cso_mg3"] = {
                printname = "MG3",
                rarity_num = 2,
            },
            ["tfa_cso_mg3desert"] = {
                printname = "MG3 Desert",
                rarity_num = 3,
            },
            ["tfa_cso_mg3_v6"] = {
                printname = "MG3 Expert",
                rarity_num = 4,
            },
            ["tfa_cso_mg3g"] = {
                printname = "MG3 Gold",
                rarity_num = 3,
            },
            ["tfa_cso_mg3_v8"] = {
                printname = "MG3 Master",
                rarity_num = 5,
            },
            ["tfa_cso_mg3xmas"] = {
                printname = "MG3 XMAS",
                rarity_num = 3,
            },
            ["tfa_cso_mg36"] = {
                printname = "MG36",
                rarity_num = 3,
            },
            ["tfa_cso_mg36_v6"] = {
                printname = "MG36 Expert",
                rarity_num = 4,
            },
            ["tfa_cso_mg36g"] = {
                printname = "MG36 Gold Edition",
                rarity_num = 4,
            },
            ["tfa_cso_mg36_v8"] = {
                printname = "MG36 Master",
                rarity_num = 5,
            },
            ["tfa_cso_mg36_v4"] = {
                printname = "MG36 Refine",
                rarity_num = 4,
            },
            ["tfa_cso_mg36_xmas"] = {
                printname = "MG36 XMAS",
                rarity_num = 4,
            },
            ["tfa_cso_mg42"] = {
                printname = "MG42",
                rarity_num = 3,
            },
            ["tfa_cso_milkorm32"] = {
                printname = "Milkor M32 MGL",
                rarity_num = 4,
            },
            ["tfa_cso_magicknife"] = {
                printname = "Miracle Prism Sword",
                rarity_num = 5,
            },
            ["tfa_cso_mk3a1"] = {
                printname = "MK3A1",
                rarity_num = 2,
            },
            ["tfa_cso_mk3a1_flame"] = {
                printname = "MK3A1 Flame",
                rarity_num = 3,
            },
            ["tfa_cso_dragonsword"] = {
                printname = "Moon Glaive",
                rarity_num = 5,
            },
            ["tfa_cso_mosin"] = {
                printname = "Mosin Nagant",
                rarity_num = 3,
            },
            ["tfa_cso_mountedgun"] = {
                printname = "Mounted Machine Gun",
                rarity_num = 3,
            },
            ["tfa_cso_mp40"] = {
                printname = "MP40",
                rarity_num = 2,
            },
            ["tfa_cso_mp5"] = {
                printname = "MP5",
                rarity_num = 1,
            },
            ["tfa_cso_mp5g"] = {
                printname = "MP5 Gold",
                rarity_num = 2,
            },
            ["tfa_cso_mp5tiger"] = {
                printname = "MP5 White Tiger",
                rarity_num = 4,
            },
            ["tfa_cso_mp7a1"] = {
                printname = "MP7A1",
                rarity_num = 2,
            },
            ["tfa_cso_mp7a160r"] = {
                printname = "MP7A1 60R",
                rarity_num = 3,
            },
            ["tfa_cso_mp7unicorn"] = {
                printname = "MP7A1 Unicorn",
                rarity_num = 4,
            },
            ["tfa_cso_soulreaper"] = {
                printname = "Naberius",
                rarity_num = 6,
            },
            ["tfa_cso_nata"] = {
                printname = "Nata Knife",
                rarity_num = 2,
            },
            ["tfa_cso_needler"] = {
                printname = "Needler",
                rarity_num = 5,
            },
            ["tfa_cso_negev"] = {
                printname = "Negev",
                rarity_num = 2,
            },
            ["tfa_cso_negev_ajax"] = {
                printname = "Negev NG-7 Ajax",
                rarity_num = 5,
            },
            ["tfa_cso_newcomen"] = {
                printname = "Newcomen",
                rarity_num = 5,
            },
            ["tfa_cso_newcomen_v6"] = {
                printname = "Newcomen Expert",
                rarity_num = 6,
            },
            ["tfa_cso_norinco_86s"] = {
                printname = "Norinco Type 86S",
                rarity_num = 2,
            },
            ["tfa_cso_oicw"] = {
                printname = "OICW",
                rarity_num = 3,
            },
            ["tfa_cso_shiftexpar"] = {
                printname = "OICW Hellfire",
                rarity_num = 5,
            },
            ["tfa_cso_groza"] = {
                printname = "OTs-14 Groza",
                rarity_num = 3,
            },
            ["tfa_cso_groza_expert"] = {
                printname = "OTs-14 Groza Expert",
                rarity_num = 4,
            },
            ["tfa_cso_groza_master"] = {
                printname = "OTs-14 Groza Master",
                rarity_num = 5,
            },
            ["tfa_cso_ozwpnset2"] = {
                printname = "Oz Lion Pistol",
                rarity_num = 4,
            },
            ["tfa_cso_ozwpnset3"] = {
                printname = "Oz Scarecrow Pickaxe",
                rarity_num = 4,
            },
            ["tfa_cso_ozwpnset1"] = {
                printname = "Oz Tin Robot Machine Gun",
                rarity_num = 4,
            },
            ["tfa_cso_p228_v2"] = {
                printname = "P228",
                rarity_num = 1,
            },
            ["tfa_cso_m82"] = {
                printname = "Parker Hale M82",
                rarity_num = 3,
            },
            ["tfa_cso_m82_v6"] = {
                printname = "Parker Hale M82 Expert",
                rarity_num = 4,
            },
            ["tfa_cso_m82_v8"] = {
                printname = "Parker Hale M82 Master",
                rarity_num = 5,
            },
            ["tfa_cso_petrolboomer"] = {
                printname = "Petrol Boomer",
                rarity_num = 4,
            },
            ["tfa_cso_pgm"] = {
                printname = "PGM Hécate II",
                rarity_num = 3,
            },
            ["tfa_cso_pgm_v6"] = {
                printname = "PGM Hécate II Expert",
                rarity_num = 4,
            },
            ["tfa_cso_pgm_v8"] = {
                printname = "PGM Hécate II Master",
                rarity_num = 5,
            },
            ["tfa_cso_pgm_v4"] = {
                printname = "PGM Hécate II Refined",
                rarity_num = 4,
            },
            ["tfa_cso_photonlauncher"] = {
                printname = "Photon Launcher",
                rarity_num = 5,
            },
            ["tfa_cso_blessingsword"] = {
                printname = "Pierrot Blessing Sword",
                rarity_num = 5,
            },
            ["tfa_cso_chameleongun"] = {
                printname = "Pierrot Chameleon Gun",
                rarity_num = 5,
            },
            ["tfa_cso_magicbow"] = {
                printname = "Pierrot Magic Bow",
                rarity_num = 5,
            },
            ["tfa_cso_pkm"] = {
                printname = "PKM",
                rarity_num = 3,
            },
            ["tfa_cso_pkm_expert"] = {
                printname = "PKM Expert",
                rarity_num = 4,
            },
            ["tfa_cso_pkm_gold"] = {
                printname = "PKM Gold",
                rarity_num = 4,
            },
            ["tfa_cso_pkm_master"] = {
                printname = "PKM Master",
                rarity_num = 5,
            },
            ["tfa_cso_sfgrenade"] = {
                printname = "Plasma Grenade",
                rarity_num = 4,
            },
            ["tfa_cso_plasmagun"] = {
                printname = "Plasma Gun",
                rarity_num = 5,
            },
            ["tfa_cso_plasmagun_v6"] = {
                printname = "Plasma Gun Chimera",
                rarity_num = 6,
            },
            ["tfa_cso_plasmagunexa"] = {
                printname = "Plasma Rifle MK-1",
                rarity_num = 6,
            },
            ["tfa_cso_plasmagunexb"] = {
                printname = "Plasma Rifle MK-2",
                rarity_num = 6,
            },
            ["tfa_cso_poisongun"] = {
                printname = "Poison Launcher",
                rarity_num = 4,
            },
            ["tfa_cso_falconex"] = {
                printname = "Power Falcon",
                rarity_num = 5,
            },
            ["tfa_cso_bizon"] = {
                printname = "PP-19 Bizon",
                rarity_num = 2,
            },
            ["tfa_cso_bizon_v6"] = {
                printname = "PP-19 Bizon Expert",
                rarity_num = 3,
            },
            ["tfa_cso_bizon_v8"] = {
                printname = "PP-19 Bizon Master",
                rarity_num = 4,
            },
            ["tfa_cso_bizon_v4"] = {
                printname = "PP-19 Bizon Refined",
                rarity_num = 3,
            },
            ["tfa_cso_pp2000"] = {
                printname = "PP2000",
                rarity_num = 2,
            },
            ["tfa_cso_pp2000_v6"] = {
                printname = "PP2000 Expert",
                rarity_num = 3,
            },
            ["tfa_cso_pp2000_v8"] = {
                printname = "PP2000 Master",
                rarity_num = 4,
            },
            ["tfa_cso_pp2000_v4"] = {
                printname = "PP2000 Refine",
                rarity_num = 3,
            },
            ["tfa_cso_prometheus"] = {
                printname = "Prometheus",
                rarity_num = 6,
            },
            ["tfa_cso_psg1"] = {
                printname = "PSG-1",
                rarity_num = 2,
            },
            ["tfa_cso_harmonium"] = {
                printname = "Psychic Harmonium",
                rarity_num = 5,
            },
            ["tfa_cso_pianogunex"] = {
                printname = "Psychic Sizer",
                rarity_num = 6,
            },
            ["tfa_cso_pulse_reactor"] = {
                printname = "Pulse Reactor",
                rarity_num = 5,
            },
            ["tfa_cso_desperado"] = {
                printname = "Python Desperado",
                rarity_num = 4,
            },
            ["tfa_cso_desperado_v6"] = {
                printname = "Python Desperado Expert",
                rarity_num = 5,
            },
            ["tfa_cso_qbb95"] = {
                printname = "QBB-95",
                rarity_num = 2,
            },
            ["tfa_cso_qbb95ex"] = {
                printname = "QBB-95EX",
                rarity_num = 3,
            },
            ["tfa_cso_qbs09"] = {
                printname = "QBS-09",
                rarity_num = 2,
            },
            ["tfa_cso_qbs09_v6"] = {
                printname = "QBS-09 Expert",
                rarity_num = 3,
            },
            ["tfa_cso_qbs09_v8"] = {
                printname = "QBS-09 Master",
                rarity_num = 4,
            },
            ["tfa_cso_qbs09_v4"] = {
                printname = "QBS-09 Refine",
                rarity_num = 3,
            },
            ["tfa_cso_qbz95b"] = {
                printname = "QBZ-95B",
                rarity_num = 2,
            },
            ["tfa_cso_qbarrel"] = {
                printname = "Quad-Barreled Shotgun",
                rarity_num = 4,
            },
            ["tfa_cso_quantum_horizon"] = {
                printname = "Quantum Horizon",
                rarity_num = 6,
            },
            ["tfa_cso_rail_buster"] = {
                printname = "Rail Buster",
                rarity_num = 5,
            },
            ["tfa_cso_railcannon"] = {
                printname = "Rail Cannon",
                rarity_num = 6,
            },
            ["tfa_cso_cannonex"] = {
                printname = "Red Dragon Cannon",
                rarity_num = 5,
            },
            ["tfa_cso_cannonex_v6"] = {
                printname = "Red Dragon Cannon Expert",
                rarity_num = 6,
            },
            ["tfa_cso_cannonexgold"] = {
                printname = "Red Dragon Cannon Gold",
                rarity_num = 6,
            },
            ["tfa_cso_m24"] = {
                printname = "Remington M24",
                rarity_num = 2,
            },
            ["tfa_cso_xm2010"] = {
                printname = "Remington XM2010 ESR",
                rarity_num = 4,
            },
            ["tfa_cso_xm2010_v6"] = {
                printname = "Remington XM2010 ESR Expert",
                rarity_num = 5,
            },
            ["tfa_cso_xm2010_v8"] = {
                printname = "Remington XM2010 ESR Master",
                rarity_num = 6,
            },
            ["tfa_cso_chainsaw"] = {
                printname = "Ripper",
                rarity_num = 4,
            },
            ["tfa_cso_chainsaw_base"] = {
                printname = "Ripper",
                rarity_num = 4,
            },
            ["tfa_cso_chainsaw_v6"] = {
                printname = "Ripper Expert",
                rarity_num = 5,
            },
            ["tfa_cso_rockbreaker"] = {
                printname = "Rock Breaker",
                rarity_num = 4,
            },
            ["tfa_cso_rollingvulcan"] = {
                printname = "Rolling Vulcan",
                rarity_num = 5,
            },
            ["tfa_cso_rpg7"] = {
                printname = "RPG-7",
                rarity_num = 3,
            },
            ["tfa_cso_rpg7_v6"] = {
                printname = "RPG-7 Expert",
                rarity_num = 4,
            },
            ["tfa_cso_rpg7_v8"] = {
                printname = "RPG-7 Master",
                rarity_num = 5,
            },
            ["tfa_cso_frostbreaker"] = {
                printname = "Runebreaker",
                rarity_num = 6,
            },
            ["tfa_cso_runebreaker"] = {
                printname = "Runebreaker",
                rarity_num = 6,
            },
            ["tfa_cso_runebreaker_expert"] = {
                printname = "Runebreaker - Expert",
                rarity_num = 7,
            },
            ["tfa_cso_ruyi"] = {
                printname = "Ruyi Stick",
                rarity_num = 5,
            },
            ["tfa_cso_trg42"] = {
                printname = "SAKO TRG-42",
                rarity_num = 3,
            },
            ["tfa_cso_trg42g"] = {
                printname = "SAKO TRG-42 White Gold",
                rarity_num = 4,
            },
            ["tfa_cso_flamethrower"] = {
                printname = "Salamander",
                rarity_num = 5,
            },
            ["tfa_cso_sandalphon"] = {
                printname = "Sandalphon",
                rarity_num = 6,
            },
            ["tfa_cso_sapientia"] = {
                printname = "Sapientia",
                rarity_num = 5,
            },
            ["tfa_cso_savery"] = {
                printname = "Savery",
                rarity_num = 5,
            },
            ["tfa_cso_savery_v6"] = {
                printname = "Savery Expert",
                rarity_num = 6,
            },
            ["tfa_cso_scarh"] = {
                printname = "SCAR",
                rarity_num = 2,
            },
            ["tfa_cso_scar_oza"] = {
                printname = "SCAR OZ-A",
                rarity_num = 4,
            },
            ["tfa_cso_scar_ozb"] = {
                printname = "SCAR OZ-B",
                rarity_num = 4,
            },
            ["tfa_cso_scar_ozc"] = {
                printname = "SCAR OZ-C",
                rarity_num = 4,
            },
            ["tfa_cso_scar_ozd"] = {
                printname = "SCAR OZ-D",
                rarity_num = 4,
            },
            ["tfa_cso_scythe"] = {
                printname = "Scythe",
                rarity_num = 4,
            },
            ["tfa_cso_sealknife"] = {
                printname = "Seal Knife",
                rarity_num = 3,
            },
            ["tfa_cso_serpent_blade"] = {
                printname = "Serpent Blade",
                rarity_num = 5,
            },
            ["tfa_cso_cerberus"] = {
                printname = "SG552 Cerberus",
                rarity_num = 5,
            },
            ["tfa_cso_lycanthrope"] = {
                printname = "SG552 Lycanthrope",
                rarity_num = 5,
            },
            ["tfa_cso_lycanthrope_expert"] = {
                printname = "SG552 Lycanthrope Expert",
                rarity_num = 6,
            },
            ["tfa_cso_dualshawujing"] = {
                printname = "Sha Wujing Dual Handgun",
                rarity_num = 5,
            },
            ["tfa_cso_shelteraxe"] = {
                printname = "Shelter Axe",
                rarity_num = 4,
            },
            ["tfa_cso_magic_rod"] = {
                printname = "Shining Heart Rod",
                rarity_num = 5,
            },
            ["tfa_cso_shooting_star"] = {
                printname = "Shooting Star",
                rarity_num = 5,
            },
            ["tfa_cso_sg550"] = {
                printname = "SIG SG550 Sniper",
                rarity_num = 2,
            },
            ["tfa_cso_sg552"] = {
                printname = "SIG SG552 Commando",
                rarity_num = 1,
            },
            ["tfa_cso_skull1"] = {
                printname = "SKULL-1",
                rarity_num = 5,
            },
            ["tfa_cso_skull11"] = {
                printname = "SKULL-11",
                rarity_num = 5,
            },
            ["tfa_cso_skull2"] = {
                printname = "SKULL-2",
                rarity_num = 5,
            },
            ["tfa_cso_skull3_a"] = {
                printname = "SKULL-3",
                rarity_num = 5,
            },
            ["tfa_cso_skull4"] = {
                printname = "SKULL-4",
                rarity_num = 5,
            },
            ["tfa_cso_skull5"] = {
                printname = "SKULL-5",
                rarity_num = 5,
            },
            ["tfa_cso_skull6"] = {
                printname = "SKULL-6",
                rarity_num = 5,
            },
            ["tfa_cso_m249ex"] = {
                printname = "SKULL-7",
                rarity_num = 5,
            },
            ["tfa_cso_skull8"] = {
                printname = "SKULL-8",
                rarity_num = 5,
            },
            ["tfa_cso_skull9"] = {
                printname = "SKULL-9",
                rarity_num = 5,
            },
            ["tfa_cso_sl8"] = {
                printname = "SL8",
                rarity_num = 3,
            },
            ["tfa_cso_sl8ex"] = {
                printname = "SL8 Custom",
                rarity_num = 4,
            },
            ["tfa_cso_sl8g"] = {
                printname = "SL8 Gold",
                rarity_num = 4,
            },
            ["tfa_cso_chainsawm"] = {
                printname = "Slasher",
                rarity_num = 5,
            },
            ["tfa_cso_smokegrenade"] = {
                printname = "Smoke Grenade",
                rarity_num = 1,
            },
            ["tfa_cso_snap_blade"] = {
                printname = "Snap Blade",
                rarity_num = 4,
            },
            ["tfa_sword_advanced_base"] = {
                printname = "Snowflake Katana",
                rarity_num = 4,
            },
            ["tfa_cso_combatknife"] = {
                printname = "Soul Bane Dagger",
                rarity_num = 4,
            },
            ["tfa_cso_mastercombatknife"] = {
                printname = "Soul Bane Serrated Blade",
                rarity_num = 5,
            },
            ["tfa_cso_halogunex"] = {
                printname = "Space Arbalest",
                rarity_num = 6,
            },
            ["tfa_cso_spas12"] = {
                printname = "SPAS-12",
                rarity_num = 2,
            },
            ["tfa_cso_spas12ex"] = {
                printname = "SPAS-12 Deluxe",
                rarity_num = 3,
            },
            ["tfa_cso_spas12desert"] = {
                printname = "SPAS-12 Desert",
                rarity_num = 3,
            },
            ["tfa_cso_spas12maverick"] = {
                printname = "SPAS-12 Maverick",
                rarity_num = 4,
            },
            ["tfa_cso_spas12superior"] = {
                printname = "SPAS-12 Superior",
                rarity_num = 4,
            },
            ["tfa_cso_duckgun"] = {
                printname = "Special Duck Foot Gun",
                rarity_num = 3,
            },
            ["tfa_cso_spectre"] = {
                printname = "Spectre M4",
                rarity_num = 2,
            },
            ["tfa_cso_starchaserar"] = {
                printname = "Star Chaser AR",
                rarity_num = 5,
            },
            ["tfa_cso_starchasersr"] = {
                printname = "Star Chaser SR",
                rarity_num = 5,
            },
            ["tfa_cso_forgesword"] = {
                printname = "Star Forge",
                rarity_num = 6,
            },
            ["tfa_cso_star_taylor"] = {
                printname = "Star Tail",
                rarity_num = 5,
            },
            ["tfa_cso_magicsg"] = {
                printname = "Starlight Rolling Shooter",
                rarity_num = 5,
            },
            ["tfa_cso_starlight_sword"] = {
                printname = "Starlight Sword",
                rarity_num = 5,
            },
            ["tfa_cso_sten_mk2"] = {
                printname = "Sten Mk2",
                rarity_num = 2,
            },
            ["tfa_cso_sterling"] = {
                printname = "Sterling L2A3",
                rarity_num = 2,
            },
            ["tfa_cso_aug"] = {
                printname = "Steyr AUG A1",
                rarity_num = 1,
            },
            ["tfa_cso_scout"] = {
                printname = "Steyr Scout",
                rarity_num = 1,
            },
            ["tfa_cso_scout_red"] = {
                printname = "Steyr Scout Red",
                rarity_num = 2,
            },
            ["tfa_cso_stg44"] = {
                printname = "STG44",
                rarity_num = 2,
            },
            ["tfa_cso_stg44_expert"] = {
                printname = "STG44 Expert",
                rarity_num = 3,
            },
            ["tfa_cso_stg44g"] = {
                printname = "STG44 Gold Edition",
                rarity_num = 3,
            },
            ["tfa_cso_stg44_master"] = {
                printname = "STG44 Master",
                rarity_num = 4,
            },
            ["tfa_cso_stinger"] = {
                printname = "Stinger",
                rarity_num = 4,
            },
            ["tfa_cso_stunrifle"] = {
                printname = "Stun Rifle",
                rarity_num = 4,
            },
            ["tfa_cso_voidpistolex"] = {
                printname = "Supreme Sentinel",
                rarity_num = 6,
            },
            ["tfa_cso_svdex"] = {
                printname = "SVD Custom",
                rarity_num = 3,
            },
            ["tfa_cso_jumpspirit"] = {
                printname = "Sylphid",
                rarity_num = 5,
            },
            ["tfa_cso_tacticalknife"] = {
                printname = "Tactical Knife",
                rarity_num = 3,
            },
            ["tfa_cso_tar_21"] = {
                printname = "TAR-21",
                rarity_num = 2,
            },
            ["tfa_cso_tempest"] = {
                printname = "Tempest",
                rarity_num = 5,
            },
            ["tfa_3dbash_base"] = {
                printname = "tfa_3dbash_base",
                rarity_num = 0,
            },
            ["tfa_3dscoped_base"] = {
                printname = "tfa_3dscoped_base",
                rarity_num = 0,
            },
            ["tfa_akimbo_base"] = {
                printname = "tfa_akimbo_base",
                rarity_num = 0,
            },
            ["tfa_bash_base"] = {
                printname = "tfa_bash_base",
                rarity_num = 0,
            },
            ["tfa_bow_base"] = {
                printname = "tfa_bow_base",
                rarity_num = 0,
            },
            ["tfa_cso_crow_base"] = {
                printname = "tfa_cso_crow_base",
                rarity_num = 0,
            },
            ["tfa_cso_melee_base"] = {
                printname = "tfa_cso_melee_base",
                rarity_num = 0,
            },
            ["tfa_cssnade_base"] = {
                printname = "tfa_cssnade_base",
                rarity_num = 0,
            },
            ["tfa_gun_base"] = {
                printname = "tfa_gun_base",
                rarity_num = 0,
            },
            ["tfa_knife_base"] = {
                printname = "tfa_knife_base",
                rarity_num = 0,
            },
            ["tfa_melee_base"] = {
                printname = "tfa_melee_base",
                rarity_num = 0,
            },
            ["tfa_nade_base"] = {
                printname = "tfa_nade_base",
                rarity_num = 0,
            },
            ["tfa_scoped_base"] = {
                printname = "tfa_scoped_base",
                rarity_num = 0,
            },
            ["tfa_shotty_base"] = {
                printname = "tfa_shotty_base",
                rarity_num = 0,
            },
            ["tfa_cso_thanatos1"] = {
                printname = "THANATOS-1",
                rarity_num = 6,
            },
            ["tfa_cso_thanatos11"] = {
                printname = "THANATOS-11",
                rarity_num = 6,
            },
            ["tfa_cso_thanatos3"] = {
                printname = "THANATOS-3",
                rarity_num = 6,
            },
            ["tfa_cso_thanatos5"] = {
                printname = "THANATOS-5",
                rarity_num = 6,
            },
            ["tfa_cso_thanatos7"] = {
                printname = "THANATOS-7",
                rarity_num = 6,
            },
            ["tfa_cso_thanatos9"] = {
                printname = "THANATOS-9",
                rarity_num = 6,
            },
            ["tfa_cso_thompson_expert"] = {
                printname = "Thompson - Expert",
                rarity_num = 3,
            },
            ["tfa_cso_thompson_gold"] = {
                printname = "Thompson - Gold",
                rarity_num = 3,
            },
            ["tfa_cso_thompson_master"] = {
                printname = "Thompson - Master",
                rarity_num = 4,
            },
            ["tfa_cso_thompson_chicago"] = {
                printname = "Thompson Chicago",
                rarity_num = 2,
            },
            ["tfa_cso_thunder_force"] = {
                printname = "Thunder Force",
                rarity_num = 5,
            },
            ["tfa_cso_thunderpistol"] = {
                printname = "Thunder Ghost Walker",
                rarity_num = 5,
            },
            ["tfa_cso_thunderbolt"] = {
                printname = "Thunderbolt",
                rarity_num = 5,
            },
            ["tfa_cso_thunderbolt_v6"] = {
                printname = "Thunderbolt Expert",
                rarity_num = 6,
            },
            ["tfa_cso_thunderstorm"] = {
                printname = "Thunderstorm",
                rarity_num = 5,
            },
            ["tfa_cso_plasmagunexc"] = {
                printname = "Tiamat MK-3",
                rarity_num = 7,
            },
            ["tfa_cso_plasmagunexd"] = {
                printname = "Tiamat MK-4",
                rarity_num = 7,
            },
            ["tfa_cso_tmp"] = {
                printname = "TMP",
                rarity_num = 1,
            },
            ["tfa_cso_tmpdragon"] = {
                printname = "TMP Dragon",
                rarity_num = 3,
            },
            ["tfa_cso_tomahawk"] = {
                printname = "Tomahawk",
                rarity_num = 3,
            },
            ["tfa_cso_tomahawk_xmas"] = {
                printname = "Tomahawk Christmas",
                rarity_num = 3,
            },
            ["tfa_cso_tornado"] = {
                printname = "Tornado",
                rarity_num = 5,
            },
            ["tfa_cso_trinity_flame"] = {
                printname = "Trinity - Flame",
                rarity_num = 5,
            },
            ["tfa_cso_trinity_knockback"] = {
                printname = "Trinity - Knockback",
                rarity_num = 5,
            },
            ["tfa_cso_trinity_stun"] = {
                printname = "Trinity - Stun",
                rarity_num = 5,
            },
            ["tfa_cso_tritacknife"] = {
                printname = "Triple Tactical Knife",
                rarity_num = 4,
            },
            ["tfa_cso_tbarrel"] = {
                printname = "Triple-barreled shotgun",
                rarity_num = 4,
            },
            ["tfa_cso_turbulent1"] = {
                printname = "TURBULENT-1",
                rarity_num = 5,
            },
            ["tfa_cso_turbulent11"] = {
                printname = "TURBULENT-11",
                rarity_num = 5,
            },
            ["tfa_cso_turbulent3"] = {
                printname = "TURBULENT-3",
                rarity_num = 5,
            },
            ["tfa_cso_turbulent5"] = {
                printname = "TURBULENT-5",
                rarity_num = 5,
            },
            ["tfa_cso_turbulent7"] = {
                printname = "TURBULENT-7",
                rarity_num = 5,
            },
            ["tfa_cso_turbulent9"] = {
                printname = "TURBULENT-9",
                rarity_num = 5,
            },
            ["tfa_cso_rocketpistol"] = {
                printname = "Twin Hawk",
                rarity_num = 5,
            },
            ["tfa_cso_dgaxeex"] = {
                printname = "Twin Light Axes",
                rarity_num = 5,
            },
            ["tfa_cso_dark_spirit"] = {
                printname = "Twin Shadow Axes",
                rarity_num = 5,
            },
            ["tfa_cso_tyrantmace"] = {
                printname = "Tyrant Mace",
                rarity_num = 5,
            },
            ["tfa_cso_ultimax100"] = {
                printname = "Ultimax 100",
                rarity_num = 2,
            },
            ["tfa_cso_ump45"] = {
                printname = "UMP45",
                rarity_num = 1,
            },
            ["tfa_cso_snakegun"] = {
                printname = "UMP45 Snake",
                rarity_num = 4,
            },
            ["tfa_cso_usas12"] = {
                printname = "USAS-12",
                rarity_num = 3,
            },
            ["tfa_cso_usas12camo"] = {
                printname = "USAS-12 Camouflage",
                rarity_num = 4,
            },
            ["tfa_cso_usas12conquer"] = {
                printname = "USAS-12 Conqueror",
                rarity_num = 5,
            },
            ["tfa_cso_usp"] = {
                printname = "USP45",
                rarity_num = 1,
            },
            ["tfa_cso_usp_red"] = {
                printname = "USP45 Red",
                rarity_num = 2,
            },
            ["tfa_cso_uts15"] = {
                printname = "UTS-15",
                rarity_num = 3,
            },
            ["tfa_cso_uts15_v6"] = {
                printname = "UTS-15 Expert",
                rarity_num = 4,
            },
            ["tfa_cso_uts15_v8"] = {
                printname = "UTS-15 Master",
                rarity_num = 5,
            },
            ["tfa_cso_uts15g"] = {
                printname = "UTS-15 Pink Gold",
                rarity_num = 4,
            },
            ["tfa_cso_uzi"] = {
                printname = "UZI",
                rarity_num = 1,
            },
            ["tfa_cso_voidpistol"] = {
                printname = "Void Avenger",
                rarity_num = 5,
            },
            ["tfa_cso_volcano"] = {
                printname = "Volcano",
                rarity_num = 5,
            },
            ["tfa_cso_volcano_v6"] = {
                printname = "Volcano Expert",
                rarity_num = 6,
            },
            ["tfa_cso_vsk94"] = {
                printname = "VSK-94",
                rarity_num = 2,
            },
            ["tfa_cso_vulcanus1"] = {
                printname = "VULCANUS-1",
                rarity_num = 5,
            },
            ["tfa_cso_vulcanus11"] = {
                printname = "VULCANUS-11",
                rarity_num = 5,
            },
            ["tfa_cso_vulcanus3"] = {
                printname = "VULCANUS-3",
                rarity_num = 5,
            },
            ["tfa_cso_vulcanus5"] = {
                printname = "VULCANUS-5",
                rarity_num = 5,
            },
            ["tfa_cso_vulcanus7"] = {
                printname = "VULCANUS-7",
                rarity_num = 5,
            },
            ["tfa_cso_vulcanus9"] = {
                printname = "VULCANUS-9",
                rarity_num = 5,
            },
            ["tfa_cso_wa2000desert"] = {
                printname = "WA2000 Desert",
                rarity_num = 3,
            },
            ["tfa_cso_katana"] = {
                printname = "Wakizashi",
                rarity_num = 3,
            },
            ["tfa_cso_wa2000"] = {
                printname = "Walther WA2000",
                rarity_num = 2,
            },
            ["tfa_cso_wa2000_expert"] = {
                printname = "Walther WA2000 - Expert",
                rarity_num = 3,
            },
            ["tfa_cso_wa2000_gold"] = {
                printname = "Walther WA2000 - Gold",
                rarity_num = 3,
            },
            ["tfa_cso_wa2000_master"] = {
                printname = "Walther WA2000 - Master",
                rarity_num = 4,
            },
            ["tfa_cso_ironfan"] = {
                printname = "War Fan",
                rarity_num = 4,
            },
            ["tfa_cso_stormgiant"] = {
                printname = "Warhammer Storm Giant",
                rarity_num = 6,
            },
            ["tfa_cso_stormgiant_tw"] = {
                printname = "Warhammer Storm Giant Bloodlord",
                rarity_num = 7,
            },
            ["tfa_cso_stormgiant_v8"] = {
                printname = "Warhammer Storm Giant Expert",
                rarity_num = 7,
            },
            ["tfa_cso_waterballoon"] = {
                printname = "Water Balloon",
                rarity_num = 2,
            },
            ["tfa_cso_whipsword"] = {
                printname = "Whip Sword",
                rarity_num = 4,
            },
            ["tfa_cso_wild_wing"] = {
                printname = "Wild Wing",
                rarity_num = 5,
            },
            ["tfa_cso_m1887"] = {
                printname = "Winchester M1887",
                rarity_num = 2,
            },
            ["tfa_cso_m1887_expert"] = {
                printname = "Winchester M1887 - Expert",
                rarity_num = 3,
            },
            ["tfa_cso_m1887_gold"] = {
                printname = "Winchester M1887 - Gold",
                rarity_num = 3,
            },
            ["tfa_cso_m1887_master"] = {
                printname = "Winchester M1887 - Master",
                rarity_num = 4,
            },
            ["tfa_cso_m1887xmas"] = {
                printname = "Winchester M1887 Christmas Edition",
                rarity_num = 3,
            },
            ["tfa_cso_windtracker"] = {
                printname = "Wind Tracker",
                rarity_num = 6,
            },
            ["tfa_cso_xtracker"] = {
                printname = "X-Tracker",
                rarity_num = 6,
            },
            ["tfa_cso_xm8"] = {
                printname = "XM8",
                rarity_num = 1,
            },
            ["tfa_cso_m134_zhubajie"] = {
                printname = "Zhu Bajie Minigun",
                rarity_num = 5,
            },
            ["tfa_cso_zongzi"] = {
                printname = "Zongzi",
                rarity_num = 2,
            },
        } 
    end
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetGLMaterialNum(id, get_type)
    if not id then return 0 end
     
    if string.lower(get_type) == "pdata" then 
        return tonumber(self:GetPData(gl .. "held_num_material_" .. id, 0))
    elseif string.lower(get_type) == "nwint" then 
        return tonumber(self:GetNWInt(gl .. "held_num_material_" .. id, 0))
    end
end

function PLAYER:GLSaveObtainedWeapons() 
    if not file.Exists("garlic_like", "DATA") then
        file.CreateDir("garlic_like")
    end

    local tbl_temp = table.Copy(FROZE_GL.tbl_menu_inventory.obtained_weapons)

    for k, v in pairs(tbl_temp) do
        if v.icon_mat and type(v.icon_mat) == "IMaterial" then
            v.icon_mat = ""
        end
    end

    local tbl = util.TableToJSON(tbl_temp, true)
    file.Write("garlic_like/obtained_weapons.json", tbl)
end

function PLAYER:GLLoadObtainedWeapons()
    if not file.Exists("garlic_like", "DATA") then
        return
    end

    if not file.Exists("garlic_like/obtained_weapons.json", "DATA") then
        return
    end

    local json = file.Read("garlic_like/obtained_weapons.json", "DATA")
    local tbl = util.JSONToTable(json)

    if not tbl then return end

    FROZE_GL.tbl_menu_inventory.obtained_weapons = tbl

    -- Reload all weapon icon materials after loading the obtained weapons table
    for _, weapon in pairs(FROZE_GL.tbl_menu_inventory.obtained_weapons) do
        weapon.icon_mat = Material("entities/" .. weapon.classname .. ".png")
    end
end

-- for k, v in ipairs(FROZE_GL.tbl_bonuses_weapons) do 
--     v.name = "_" .. v.name
-- end

if IsMounted("tf") then
    local tf2PCFs = {"tf2rockets.pcf", "bigboom.pcf", "bl_killtaunt.pcf", "blood_impact.pcf", "blood_trail.pcf", "bombinomicon.pcf", "buildingdamage.pcf", "bullet_tracers.pcf", "burningplayer.pcf", "cig_smoke.pcf", "cinefx.pcf", "class_fx.pcf", "classic_rocket_trail.pcf", "coin_spin.pcf", "conc_stars.pcf", "crit.pcf", "default.pcf", "dirty_explode.pcf", "disguise.pcf", "doomsday_fx.pcf", "drg_bison.pcf", "drg_cowmangler.pcf", "drg_engineer.pcf", "drg_pyro.pcf", "dxhr_fx.pcf", "explosion.pcf", "eyeboss.pcf", "firstperson_weapon_fx.pcf", "flag_particles.pcf", "flamethrower.pcf", "flamethrower_mvm.pcf", "halloween.pcf", "harbor_fx.pcf", "item_fx.pcf", "items_demo.pcf", "items_engineer.pcf", "killstreak.pcf", "level_fx.pcf", "medicgun_attrib.pcf", "medicgun_beam.pcf", "muzzle_flash.pcf", "mvm.pcf", "nailtrails.pcf", "nemesis.pcf", "npc_fx.pcf", "player_recent_teleport.pcf", "rain_custom.pcf", "rocketbackblast.pcf", "rocketjumptrail.pcf", "rockettrail.pcf", "rps.pcf", "scary_ghost.pcf", "shellejection.pcf", "smoke_blackbillow.pcf", "smoke_blackbillow_hoodoo.pcf", "soldierbuff.pcf", "sparks.pcf", "speechbubbles.pcf", "stamp_spin.pcf", "stickybomb.pcf", "stormfront.pcf", "taunt_fx.pcf", "teleport_status.pcf", "teleported_fx.pcf", "training.pcf", "urban_fx.pcf", "water.pcf", "xms.pcf"}

    for k, pcf in pairs(tf2PCFs) do
        game.AddParticles("particles/" .. pcf)
    end 
end

function IsNumBetween(x, min, max)
    return x >= min and x <= max
end

function gl_deepCopy(orig) 
    local copy 
    
    copy = orig 

    return copy
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function boolToNumber(bool) 
    return (bool == true) and 1 or 0 
end

function garlic_like_rarity_to_num(rarity)
    local num = 0

    for k, rarity_entry in pairs(FROZE_GL.rarities) do
        if rarity == rarity_entry then
            num = k
        end
    end

    return num
end

function garlic_like_num_to_rarity(num)
    if num == 1 then
        return "poor"
    elseif num == 2 then
        return "common"
    elseif num == 3 then
        return "uncommon"
    elseif num == 4 then
        return "rare"
    elseif num == 5 then
        return "epic"
    elseif num == 6 then
        return "legendary"
    elseif num == 7 then
        return "ultimate"
    else
        return "common"
    end
end

function garlic_like_create_upgrade_table()
    --* STAT UPGRADES
    FROZE_GL.garlic_like_upgrades[11] = {
        name = "str",
        upgrade_type = "statboost",
        desc = "Increases Strength",
        rarity = "poor",
        disable_picking_up = false,
        statboost = 3,
        upgrade_level = 0,
        upgrade_price = 10000,
        upgrade_price_increase = 20000,
        icon = "garlic_like/icon_str.png"
    }

    FROZE_GL.garlic_like_upgrades[12] = {
        name = "agi",
        upgrade_type = "statboost",
        desc = "Increases Agility",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 10000,
        upgrade_price_increase = 20000,
        statboost = 3,
        icon = "garlic_like/icon_agi.png"
    }

    FROZE_GL.garlic_like_upgrades[13] = {
        name = "int",
        upgrade_type = "statboost",
        desc = "Increases Intelligence",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 10000,
        upgrade_price_increase = 20000,
        statboost = 3,
        icon = "garlic_like/icon_int.png"
    }
    --* ITEMS
    FROZE_GL.garlic_like_upgrades[100] = {
        name = "xp orb",
        upgrade_type = "item_statboost",
        item_type = "increasing_mult",
        desc = "Multiplies XP Gain",
        desc_short = "XP Gain",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 8000,
        upgrade_price_increase = 8000,
        statboost = 0.125,
        icon = "garlic_like/icon_orb_xp.png",
        number_addition = 1
    }

    FROZE_GL.garlic_like_upgrades[110] = {
        name = "armor",
        upgrade_type = "item_statboost",
        item_type = "reducing_mult",
        desc = "Reduces DMG Taken",
        desc_short = "DMG Taken",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 9000,
        upgrade_price_increase = 9000,
        statboost = 0.035,
        icon = "garlic_like/icon_armor.png",
        number_addition = -1
    }

    FROZE_GL.garlic_like_upgrades[120] = {
        name = "muscles",
        upgrade_type = "item_statboost",
        item_type = "increasing_mult",
        desc = "Increases HP Bonus",
        desc_short = "HP Bonus",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 9000,
        upgrade_price_increase = 9000,
        statboost = 0.085,
        icon = "garlic_like/icon_muscles.png",
        number_addition = 1
    }

    FROZE_GL.garlic_like_upgrades[130] = {
        name = "sword",
        upgrade_type = "item_statboost",
        item_type = "increasing_mult",
        desc = "Increases DMG Bonus",
        desc_short = "DMG Increase",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 10000,
        upgrade_price_increase = 10000,
        statboost = 0.1,
        icon = "garlic_like/icon_sword.png",
        number_addition = 1
    }

    FROZE_GL.garlic_like_upgrades[140] = {
        name = "crystal",
        upgrade_type = "item_statboost",
        item_type = "increasing_mult",
        desc = "Multiplies All 3 Stats",
        desc_short = "Multiplied Stats",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 12500,
        upgrade_price_increase = 12500,
        statboost = 0.03,
        icon = "garlic_like/icon_crystal.png",
        number_addition = 1
    }

    FROZE_GL.garlic_like_upgrades[150] = {
        name = "glasses",
        upgrade_type = "item_statboost",
        item_type = "increasing_mult",
        desc = "Multiplies Crit Chance",
        desc_short = "Crit Chance",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 10000,
        upgrade_price_increase = 10000,
        statboost = 0.07,
        icon = "garlic_like/icon_glasses_crit.png",
        number_addition = 1
    }

    FROZE_GL.garlic_like_upgrades[160] = {
        name = "shield",
        upgrade_type = "item_statboost",
        item_type = "reducing_mult",
        desc = "Reduces BLOCK DMG",
        desc_short = "BLOCK DMG Taken",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 10000,
        upgrade_price_increase = 10000,
        statboost = 0.05,
        icon = "garlic_like/icon_shield.png",
        number_addition = -1
    }
    --* ABILITIES
 
    local damage  
    local cooldown  

    if SERVER then 
        damage = 0
        cooldown = 0
    end

    if CLIENT then 
        damage = GetConVar("dota2_damage_lightning_bolt"):GetInt() or 0
        cooldown = GetConVar("dota2_auto_cast_lightning_bolt_delay"):GetFloat() or 0
    end

    FROZE_GL.garlic_like_upgrades[300] = {
        name = "lightning bolt",
        name2 = "lightning_bolt",
        upgrade_type = "skill",
        desc = "Periodically summons a lightning\nbolt on a random enemy.",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 20000,
        upgrade_price_increase = 20000,
        damage = damage,
        cooldown = cooldown,
        area = "GLOBAL",
        icon = "garlic_like/icon_dota2_lightning_bolt.png"
    }
    
    if CLIENT then 
         damage = GetConVar("dota2_damage_diabolic_edict"):GetInt() or 0
         cooldown = GetConVar("dota2_auto_cast_diabolic_edict_delay"):GetFloat() or 0
    end

    FROZE_GL.garlic_like_upgrades[310] = {
        name = "diabolic edict",
        name2 = "diabolic_edict",
        upgrade_type = "skill",
        desc = "Periodically summons explosions\non a random nearby enemy.",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 20000,
        upgrade_price_increase = 20000,
        damage = damage,
        cooldown = cooldown,
        area = GetConVar("dota2_radius_diabolic_edict"):GetInt(),
        icon = "garlic_like/icon_dota2_diabolic_edict.png"
    }

    if CLIENT then 
         damage = GetConVar("dota2_damage_torrent"):GetInt() or 0
         cooldown = GetConVar("dota2_auto_cast_torrent_delay"):GetFloat() or 0
    end

    FROZE_GL.garlic_like_upgrades[320] = {
        name = "torrent",
        name2 = "torrent",
        upgrade_type = "skill",
        desc = "Periodically summons a rapidly\ndamaging water torrent on\na random enemy.",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 20000,
        upgrade_price_increase = 20000,
        damage = damage,
        cooldown = cooldown,
        area = "GLOBAL",
        icon = "garlic_like/icon_dota2_torrent.png"
    }

    if CLIENT then 
         damage = GetConVar("dota2_damage_magic_missile"):GetInt() or 0
         cooldown = GetConVar("dota2_auto_cast_magic_missile_delay"):GetFloat() or 0
    end

    FROZE_GL.garlic_like_upgrades[330] = {
        name = "magic missile",
        name2 = "magic_missile",
        upgrade_type = "skill",
        desc = "Periodically shoot a magic missile\nat a random reachable enemy.",
        rarity = "poor",
        disable_picking_up = false,
        upgrade_level = 0,
        upgrade_price = 20000,
        upgrade_price_increase = 20000,
        damage = damage,
        cooldown = cooldown,
        area = "GLOBAL",
        icon = "garlic_like/icon_dota2_magic_missile.png"
    }
    
    --* RELICS
    FROZE_GL.garlic_like_upgrades[500] = {
        name = "advanced depot",
        name2 = "advanced_depot",
        upgrade_type = "relic",
        upgrade_level = 0,
        upgrade_price = 15000,
        upgrade_price_increase = 15000,
        desc = "Reduces damage but weapons uses reserves first.",
        shortdesc = " Reduced DMG",
        shortdesc_2 = "",
        rarity = "poor",
        mul = 0.3,
        mul_is_debuff = true,
        icon = "garlic_like/icon_relics/advanced-depot.png"
    }

    FROZE_GL.garlic_like_upgrades[510] = {
        name = "veteran",
        name2 = "veteran",
        upgrade_type = "relic",
        upgrade_level = 0,
        upgrade_price = 15000,
        upgrade_price_increase = 15000,
        desc = "85% chance to increase MAX HP by 1 every kill.\nChance to gain an extra max hp.",
        shortdesc = " MAX HP Extra Gain Chance",
        shortdesc_2 = "",
        rarity = "poor",
        mul = 0.17,
        icon = "garlic_like/icon_relics/veteran.png"
    }

    FROZE_GL.garlic_like_upgrades[520] = {
        name = "silver medal",
        name2 = "silver_medal",
        upgrade_type = "relic",
        upgrade_level = 0,
        upgrade_price = 15000,
        upgrade_price_increase = 15000,
        desc = "Chance to recover 2 armor on kill.",
        shortdesc = " Armor Recovery Chance",
        -- shortdesc_2 = " Armor Recover Amount",
        rarity = "poor",
        mul = 0.45,
        -- mul_2 = 2,
        icon = "garlic_like/icon_relics/silver-medal.png"
    }

    FROZE_GL.garlic_like_upgrades[530] = {
        name = "genesis",
        name2 = "genesis",
        upgrade_type = "relic",
        upgrade_level = 0,
        upgrade_price = 15000,
        upgrade_price_increase = 15000,
        desc = "Chance to add ammo to the magazine when firing.",
        shortdesc = " Ammo Gain Chance",
        shortdesc_2 = " of Magazine Size",
        rarity = "poor",
        mul = 0.1,
        mul_2 = 0.1,
        icon = "garlic_like/icon_relics/genesis.png"
    }

    FROZE_GL.garlic_like_upgrades[540] = {
        name = "deft hands",
        name2 = "deft_hands",
        upgrade_type = "relic",
        upgrade_level = 0,
        upgrade_price = 15000,
        upgrade_price_increase = 15000,
        desc = "Shooting won't consume ammo for a duration\nafter killing an enemy.",
        shortdesc = " Duration",
        shortdesc_2 = "",
        rarity = "poor",
        mul = 1,
        mul_is_second = true,
        icon = "garlic_like/icon_relics/deft-hands.png"
    }

    FROZE_GL.garlic_like_upgrades[550] = {
        name = "bloody ammo",
        name2 = "bloody_ammo",
        upgrade_type = "relic",
        upgrade_level = 0,
        upgrade_price = 15000,
        upgrade_price_increase = 15000,
        desc = "Some weapons can continue firing without emptying\nthe magazine but every 6 shots reduce health.",
        shortdesc = " of Current Health",
        shortdesc_2 = "",
        rarity = "poor",
        mul = 0.1,
        mul_is_debuff = true,
        icon = "garlic_like/icon_relics/bloody-ammo.png"
    }

    FROZE_GL.garlic_like_upgrades[560] = {
        name = "hawkeye sight",
        name2 = "hawkeye_sight",
        upgrade_type = "relic",
        upgrade_level = 0,
        upgrade_price = 15000,
        upgrade_price_increase = 15000,
        desc = "Increases crit chance and crit damage but\nhalves base damage.",
        shortdesc = " Crit Chance Multiplier",
        shortdesc_2 = " Crit Damage Multiplier",
        rarity = "poor",
        mul = 1.25,
        mul_2 = 1.35,
        icon = "garlic_like/icon_relics/hawkeye-sight.png"
    }

    FROZE_GL.garlic_like_upgrades[570] = {
        name = "blade mail",
        name2 = "blade_mail",
        upgrade_type = "relic",
        upgrade_level = 0,
        upgrade_price = 15000,
        upgrade_price_increase = 15000,
        desc = "Returns damage to enemy based on current hp.",
        shortdesc = " of Current HP",
        shortdesc_2 = "",
        rarity = "poor",
        mul = 1.35,
        icon = "garlic_like/icon_relics/blade-mail.png"
    }

    FROZE_GL.garlic_like_upgrades[580] = {
        name = "advanced jogger",
        name2 = "advanced_jogger",
        upgrade_type = "relic",
        upgrade_level = 0,
        upgrade_price = 15000,
        upgrade_price_increase = 15000,
        desc = "Reduces dash cooldown.",
        shortdesc = " Dash Cooldown Reduction",
        shortdesc_2 = "",
        rarity = "poor",
        mul = 0.35,
        icon = "garlic_like/icon_relics/advanced-jogger.png"
    }

    FROZE_GL.garlic_like_upgrades[590] = {
        name = "brutal gloves",
        name2 = "brutal_gloves",
        upgrade_type = "relic",
        upgrade_level = 0,
        upgrade_price = 15000,
        upgrade_price_increase = 15000,
        desc = "Every crit increases crit damage for 5 seconds.",
        shortdesc = " Crit Damage Increase",
        shortdesc_2 = "",
        rarity = "poor",
        mul = 0.04,
        icon = "garlic_like/icon_relics/brutal-gloves.png"
    }

    FROZE_GL.garlic_like_upgrades[600] = {
        name = "preemptive strike",
        name2 = "preemptive_strike",
        upgrade_type = "relic",
        upgrade_level = 0,
        upgrade_price = 15000,
        upgrade_price_increase = 15000,
        desc = "Deal increased damage and increased\ncrit chance at 100% ammo.",
        shortdesc = " Damage Multiplier",
        shortdesc_2 = " Crit Chance Multiplier",
        rarity = "poor",
        mul = 0.5,
        mul_2 = 0.35,
        icon = "garlic_like/icon_relics/preemptive-strike.png"
    } 
end

function garlic_like_is_tfa_melee(wep)  
    return (wep.IsMelee) and true or false
end

function garlic_like_is_arccw_melee(wep) 
    return (wep.Base == "arccw_base_melee" or string.find(wep.Base, "melee")) and true or false
end

function garlic_like_is_tfa_wep(wep) 
    return string.find(wep.ClassName, "tfa") and not string.find(wep.ClassName, "base") and not string.find(wep.Base, "nade_base")
end

function garlic_like_is_arccw_wep(wep) 
    return string.find(wep.ClassName, "arccw") and not string.find(wep.ClassName, "base")
end

function garlic_like_get_wep_power(ply, wep) 
    local power = 0
    local mod_power = 1

    if IsValid(ply) then 
        local tbl_stored_wep 
        local tbl_gl_stored_bonused_weapons        
        -- print("PLAYER IS VALID FOR MEASUIRNG POWER")

        if SERVER then 
            tbl_gl_stored_bonused_weapons = ply.gl_stored_bonused_weapons 

            if tbl_gl_stored_bonused_weapons and tbl_gl_stored_bonused_weapons[wep.ClassName] then  
                mod_power = tbl_gl_stored_bonused_weapons[wep.ClassName].base_rarity_mod_num
                -- print("mod power is: " .. mod_power)
            end
        end

        if CLIENT then 
            tbl_gl_stored_bonused_weapons = FROZE_GL.gl_stored_bonused_weapons 

            if tbl_gl_stored_bonused_weapons and tbl_gl_stored_bonused_weapons[wep.ClassName] then 
                mod_power = tbl_gl_stored_bonused_weapons[wep.ClassName].base_rarity_mod_num
            end

            if wep.cl_wep_base_rarity_mod_num then 
                mod_power = wep.cl_wep_base_rarity_mod_num
            end

            -- print("clientside!!!")
            -- PrintTable(FROZE_GL.gl_stored_bonused_weapons) 
            -- print("mod power is: " .. mod_power)
        end
    end 

    if garlic_like_is_arccw_wep(wep) then 
        if garlic_like_is_arccw_melee(wep) then 
            if not wep.Damage then print(wep.ClassName .. " has no wep.Damage !!!") return 0 end
            power = (wep.Damage * (1 / wep.MeleeTime) * 60) * 0.85
        else 
            if not wep.Damage then print(wep.ClassName .. " has no wep.Damage !!!") return 0 end
            -- power = (wep.Damage * wep.Num * (60 / wep.Delay)) + (wep.Primary.ClipSize / ((60 / wep.Delay) / 30)) * wep.Primary.Damage
            power = (wep.Damage * wep.Num * (60 / wep.Delay)) + (wep.Primary.ClipSize * wep.Damage)
            
            if wep.Primary.ClipSize == -1 then 
                power = power 
            end
        end
    end

    if garlic_like_is_tfa_wep(wep) then  
        if garlic_like_is_tfa_melee(wep) or (wep.Primary.Attacks and wep.Primary.Attacks[1]) then 
            local divisor = (wep.Secondary.Attacks) and 2 or 1
            local secondary_num = 0

            if wep.Secondary and wep.Secondary.Attacks and wep.Secondary.Attacks[1] then 
                secondary_num = (wep.Secondary.Attacks) and (wep.Secondary.Attacks[1].dmg * (1 / wep.Secondary.Attacks[1]['end']) * 60) or 0
            end

            --* for tfa cso chainsaws 
            if wep.Primary.Damage then 
                power = wep.Primary.Damage * wep.Primary.NumShots * wep.Primary.RPM + (wep.Primary.ClipSize * wep.Primary.Damage)
            end

            if wep.Primary.Attacks then 
                power = (((wep.Primary.Attacks[1].dmg * (1 / wep.Primary.Attacks[1]['end']) * 60) + secondary_num) / divisor) * 0.85
            end
        else 
            if not wep.Primary.Damage then print(wep.ClassName .. " has no wep.Primary.Damage !!!") return 0 end
            if not wep.Primary.ClipSize then print(wep.ClassName .. " has no wep.Primary.ClipSize !!!") return 0 end
            if not wep.Primary.NumShots then print(wep.ClassName .. " has no wep.Primary.NumShots !!!") return 0 end
            if not wep.Primary.NumShots then print(wep.ClassName .. " has no wep.Primary.NumShots !!!") return 0 end            
            -- power = wep.Primary.Damage * wep.Primary.NumShots * wep.Primary.RPM + (wep.Primary.ClipSize / (wep.Primary.RPM / 30)) * wep.Primary.Damage
            power = wep.Primary.Damage * wep.Primary.NumShots * wep.Primary.RPM + (wep.Primary.ClipSize * wep.Primary.Damage)

            if wep.Secondary.Damage and wep.Secondary.RPM and wep.Secondary.Damage > 0 then 
                -- power = (power + (wep.Secondary.Damage * wep.Secondary.NumShots + (wep.Primary.ClipSize / (wep.Primary.RPM / 30)) * wep.Primary.Damage)) / 2
                if not wep.Secondary.NumShots then 
                    wep.Secondary.NumShots = 1
                end

                power = power + wep.Secondary.Damage * wep.Secondary.NumShots + (wep.Secondary.ClipSize * wep.Secondary.Damage)
            end 

            if wep.Primary.ClipSize == -1 then 
                power = power 
            end
        end
    end
    -- print("mod power is: " .. mod_power)

    return math.Round(power * mod_power)
end

function garlic_like_ply_unlocked(ply, name) 
    return tobool(ply:GetPData(gl .. name .. "_unlocked"))
end

function garlic_like_create_drop_table(name)
    if FROZE_GL.tbl_drops[name] then
        -- error("Drop table '" .. name .. "' already exists!")
        -- print("TABLE ALREADY EXISTS, DELETING AND RECREATING!")
        FROZE_GL.tbl_drops[name] = nil
    end

    local dropTable = {
        items = {},
        totalWeight = 0
    }

    function dropTable:AddItem(itemName, weight, data)
        weight = weight or 1
        self.items[#self.items + 1] = {
            name = itemName,
            weight = weight,
            data = data
        }
        self.totalWeight = self.totalWeight + weight
    end

    function dropTable:Roll()
        local roll = math.random() * self.totalWeight
        local currentWeight = 0

        for _, item in ipairs(self.items) do
            currentWeight = currentWeight + item.weight
            if roll <= currentWeight then
                return item
            end
        end

        return self.items[#self.items]
    end

    function dropTable:GetDropChance(itemName)
        for _, item in ipairs(self.items) do
            if item.name == itemName then
                return (item.weight / self.totalWeight) * 100
            end
        end
        return nil
    end

    function dropTable:ListChances()
        local chances = {}
        for _, item in ipairs(self.items) do
            chances[item.name] = (item.weight / self.totalWeight) * 100
        end
        return chances
    end

    FROZE_GL.tbl_drops[name] = dropTable
    return dropTable
end

function garlic_like_calc_valid_item_weights()  
    --* insert chest drop weights here using the new system
    do  
        local drops_data = {
            [100] = {ore_poor=10000, ore_common=5000, ore_uncommon=2500, ore_rare=1250, ore_epic=625, ore_legendary=315, ore_ultimate=50, reroll_crystal=1500, power_cell=3000, element_crystal=325, crate_key = 75},
            [200] = {ore_poor=9500, ore_common=5000, ore_uncommon=2600, ore_rare=1350, ore_epic=725, ore_legendary=415, ore_ultimate=75, reroll_crystal=1750, power_cell=3300, element_crystal=400, crate_key = 115},
            [300] = {ore_poor=9000, ore_common=5000, ore_uncommon=2700, ore_rare=1450, ore_epic=825, ore_legendary=515, ore_ultimate=100, reroll_crystal=2000, power_cell=3600, element_crystal=475, crate_key = 155},
            [400] = {ore_poor=8500, ore_common=5000, ore_uncommon=2800, ore_rare=1550, ore_epic=925, ore_legendary=615, ore_ultimate=125, reroll_crystal=2250, power_cell=3900, element_crystal=550, crate_key = 195},
            [500] = {ore_poor=8000, ore_common=5000, ore_uncommon=2900, ore_rare=1650, ore_epic=1025, ore_legendary=715, ore_ultimate=150, reroll_crystal=2500, power_cell=4200, element_crystal=625, crate_key = 235},
            [600] = {ore_poor=7500, ore_common=5000, ore_uncommon=3000, ore_rare=1750, ore_epic=1125, ore_legendary=815, ore_ultimate=175, reroll_crystal=2750, power_cell=4500, element_crystal=700, crate_key = 275}
        }

        for k2, v2 in pairs(FROZE_GL.tbl_valid_inventory_items) do             
            v2.chest_drops.drop_weights = garlic_like_create_drop_table("chest_drops_weights")             

            for k3, v3 in pairs(drops_data[k2]) do 
                v2.chest_drops.drop_weights:AddItem(k3, v3)
            end
        end
        
        -- sample
        -- FROZE_GL.rarity_weights_new = garlic_like_create_drop_table("rarity_weights")
        -- FROZE_GL.rarity_weights_new:AddItem("poor", 10000)
    end

    -- PrintTable(FROZE_GL.tbl_valid_inventory_items)

    FROZE_GL.tbl_valid_inventory_items = table.ClearKeys(FROZE_GL.tbl_valid_inventory_items)
    local tbl = FROZE_GL.tbl_valid_inventory_items    

    for k, v in ipairs(tbl) do 
        if not istable(v) then continue end 
        if not v.ru_reward then continue end 

        if k == 1 then 
            v.drop_weight_max_ru = v.drop_weight_ru
            v.drop_weight_min_ru = 0
        else 
            v.drop_weight_min_ru = tbl[k - 1].drop_weight_max_ru + 1
            v.drop_weight_max_ru = v.drop_weight_min_ru + v.drop_weight_ru
        end

        FROZE_GL.valid_inventory_items_max_weight = FROZE_GL.valid_inventory_items_max_weight + v.drop_weight_ru 
    end    

    for k, v in ipairs(tbl) do 
        -- print(v.name .. " chance: " .. (v.drop_weight_ru / FROZE_GL.valid_inventory_items_max_weight) * 100 .. "%")
    end

    -- PrintTable(tbl)
end

function garlic_like_create_wep_power_tbl() 
    for k, wep in pairs(weapons.GetList()) do 
        if garlic_like_is_tfa_wep(wep) and wep.ClassName ~= "tfa_cso_c4" and wep.ClassName ~= "tfa_cso_gl_glock" and wep.ClassName ~= "tfa_cso_mountedgun" then 
            -- print("added", tostring(wep.ClassName))
            FROZE_GL.tbl_wep_power[wep.ClassName] = garlic_like_get_wep_power(NULL, wep)
            -- print("FROZE_GL.tbl_wep_power[wep.ClassName]", FROZE_GL.tbl_wep_power[wep.ClassName])
        end
    end
end

function garlic_like_multicast_calculate(ply) 
    local cast_amount = 0
    local val = ply:GetNWFloat(gl .. "multicast", 0)
    local int_val = math.floor(val)
    local frac_val = val - int_val 

    if int_val > 0 then 
        for i = 1, int_val do 
            cast_amount = cast_amount + 1
        end
    end

    if math.random() <= frac_val then 
        cast_amount = cast_amount + 1
    end

    return cast_amount
end  

function garlic_like_get_drop_table(name)
    return FROZE_GL.tbl_drops[name]
end
 
garlic_like_create_wep_power_tbl()

FROZE_GL.rarity_weights_new = garlic_like_create_drop_table("rarity_weights")
FROZE_GL.rarity_weights_new:AddItem("poor", 10000)
FROZE_GL.rarity_weights_new:AddItem("common", 6500)
FROZE_GL.rarity_weights_new:AddItem("uncommon", 3250)
FROZE_GL.rarity_weights_new:AddItem("rare", 1625)
FROZE_GL.rarity_weights_new:AddItem("epic", 815)
FROZE_GL.rarity_weights_new:AddItem("legendary", 272)
FROZE_GL.rarity_weights_new:AddItem("ultimate", 91) 

FROZE_GL.rarity_weights_weapons = garlic_like_create_drop_table("rarity_weights")
FROZE_GL.rarity_weights_weapons:AddItem("poor", 100000)
FROZE_GL.rarity_weights_weapons:AddItem("common", 100000)
FROZE_GL.rarity_weights_weapons:AddItem("uncommon", 50000)
FROZE_GL.rarity_weights_weapons:AddItem("rare", 25000)
FROZE_GL.rarity_weights_weapons:AddItem("epic", 12500)
FROZE_GL.rarity_weights_weapons:AddItem("legendary", 2500)
FROZE_GL.rarity_weights_weapons:AddItem("ultimate", 250) 

FROZE_GL.tbl_menu_inventory = FROZE_GL.tbl_menu_inventory or {
        consumables = {},
        materials = {}, 
        obtained_weapons = {},
    } 
  
hook.Add("InitPostEntity", gl .. "sh_InitPostEntity", function() 
    garlic_like_create_wep_power_tbl()

    --* create base form of tbl_menu_inventory.obtained_weapons 
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

    -- timer.Simple(1, function()

    --     timer.Simple(1, function()
    --         -- recursiveInclusion( GM.FolderName .. "/gamemode", true )

    --         -- print("garlic_like_gamemode: InitPostEntity hook called (SERVER-SIDE)")

    --         -- print("garlic_like_gamemode: Loading server files...")
    --         local serverFiles, _ = file.Find(serverFolder .. "*.lua", "LUA", "GAME")
    --         for _, fName in ipairs(serverFiles) do
    --             local fullPath = serverFolder .. fName
    --             include(fullPath)
    --             -- print("garlic_like_gamemode: Included server file: " .. fullPath)
    --         end

    --         -- print("garlic_like_gamemode: Queuing client files for download...")
    --         local clientFilesForSending, _ = file.Find(clientFolder .. "*.lua", "LUA", "GAME")
    --         for _, fName in ipairs(clientFilesForSending) do
    --             local fullPath = clientFolder .. fName
    --             AddCSLuaFile(fullPath)
    --             -- print("garlic_like_gamemode: Added client file to send: " .. fullPath)
    --         end

    --         -- print("garlic_like_gamemode: Server-side loading in InitPostEntity complete.")

    --         if CLIENT then
    --             -- print("garlic_like_gamemode: Client is now including its designated files...")             
    
    --             -- print("garlic_like_gamemode: CLIENT - Attempting to load client-specific Lua files.")
    --             local clientFilesToInclude, _ = file.Find(clientFolder .. "*.lua", "LUA", "GAME")
    --             if clientFilesToInclude then
    --                 for _, fName in ipairs(clientFilesToInclude) do
    --                     local fullPath = clientFolder .. fName
    --                     include(fullPath)
    --                     -- print("garlic_like_gamemode: Included client file: " .. fullPath)
    --                 end
    --             else
    --                 -- print("garlic_like_gamemode: CLIENT - No client files found to include in " .. clientFolder)
    --             end
    --             -- print("garlic_like_gamemode: Client-side file inclusion attempt finished.") 
    --         end
    --     end)
    -- end)
end) 

hook.Add("TFA_GetStat", gl .. "tfa_dmg_hook_test", function(weapon, stat, value)
	-- if stat == "Primary.Damage" then -- We want to modify SWEP.Primary.ClipSize which is a cached stat
    --     -- print("weapon: " .. tostring(weapon))
    --     -- print("stat: " .. tostring(stat))
    --     -- print("value: " .. tostring(value))
	-- 	return value + 20 -- We add 10 to it's current (number) value
	-- end
end)

garlic_like_create_wep_power_tbl() 
garlic_like_calc_valid_item_weights() 
garlic_like_create_upgrade_table() 
 
