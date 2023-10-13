local gl = "garlic_like_"

if SERVER then 
    CreateConVar(gl .. "enable", 1, FCVAR_ARCHIVE, "enables / disables all of garlic-like's systems.", 0, 1)
    CreateConVar(gl .. "enemy_preset", "preset_1.txt", FCVAR_ARCHIVE, "", 0, 0)
    CreateConVar(gl .. "mana_usage_mul", 0.75, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar(gl .. "reset_stats_after_dying", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar(gl .. "enable_timer", 0, FCVAR_NONE, "", 0, 1)
    CreateConVar(gl .. "timer_speed_mult", 1, FCVAR_ARCHIVE, "", 0, 10)
    CreateConVar(gl .. "damage_random_min_maxes_enable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar(gl .. "max_enemies_spawned", 25, FCVAR_ARCHIVE, "", 1, 100)
    CreateConVar(gl .. "debug_crate_drops", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar(gl .. "debug_gem_crate_drops", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar(gl .. "global_enemy_hp_mod_num", 1, FCVAR_ARCHIVE, "", 0, 100)
    CreateConVar(gl .. "global_enemy_dmg_mod_num", 1, FCVAR_ARCHIVE, "", 0, 100)
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
    CreateConVar("dota2_damage_lightning_bolt", 105, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1000)
    CreateConVar("dota2_stun_lightning_bolt", 0.2, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 100)
    CreateConVar("dota2_radius_lightning_bolt", 1500, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 10000)
    CreateConVar("dota2_auto_cast_lightning_bolt_sv", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 1)
    CreateConVar("dota2_damage_magic_missile", 115, FCVAR_ARCHIVE, "", 1, 1000)
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
end

game.AddParticles("particles/garlic_like_particles_1.pcf")
game.AddParticles("particles/garlic_like_trails_1.pcf")
game.AddParticles("particles/vgui_menu_particles.pcf")
game.AddParticles("particles/units/heroes/hero_viper.pcf")
game.AddParticles("particles/units/heroes/hero_stormspirit.pcf")
game.AddParticles("particles/units/heroes/hero_huskar.pcf")
game.AddParticles("particles/units/heroes/hero_jakiro.pcf")
game.AddParticles("particles/units/heroes/hero_disruptor.pcf")
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
PrecacheParticleSystem("viper_poison_attack_explosion") 
PrecacheParticleSystem("viper_viper_strike_debuff")
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
tbl_gl_valid_entities = {gl .. "crystal_cluster", gl .. "item_barrel"} 

tbl_gl_character_stats = {
    [1] = { 
        name = "Max HP Boost",
        id = gl .. "hp_boost",
        upgrade_type = "INT",
        stat_type = "STR",
        weapon_upgrade_id = "",
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
        shop_upgrade_amount = 0.1,
        shop_upgrade_base_price = 10000,
        shop_upgrade_price_increase = 20000,
    }, 
    [3] = {
        name = "Bonus Damage",
        id = gl .. "bonus_damage",
        upgrade_type = "Float",
        stat_type = "STR",
        weapon_upgrade_id = "damage",
        shop_upgrade_amount = 0.05,
        shop_upgrade_base_price = 2500,
        shop_upgrade_price_increase = 7500,
    }, 
    [4] = {
        name = "Block Damage Reduction",
        id = gl .. "bonus_block_resistance",
        upgrade_type = "Float",
        stat_type = "STR",
        operation_type = "reducing_mult",
        weapon_upgrade_id = "resistance_block",
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
        shop_upgrade_amount = 1,
        shop_upgrade_base_price = 25000,
        shop_upgrade_price_increase = 45000,
    }, 
    [6] = {
        name = "Critical Damage",
        id = gl .. "bonus_critical_damage",
        upgrade_type = "Float",
        stat_type = "STR",
        weapon_upgrade_id = "crit_damage",
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
        shop_upgrade_amount = 3,
        shop_upgrade_base_price = 2500,
        shop_upgrade_price_increase = 7500,
    }, 
    [9] = {
        name = "Block Chance",
        id = gl .. "bonus_block_chance",
        upgrade_type = "Float",
        stat_type = "AGI",
        weapon_upgrade_id = "block_chance",
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
        shop_upgrade_amount = 0.1,
        shop_upgrade_base_price = 10000,
        shop_upgrade_price_increase = 60000,
    }, 
    [12] = {
        name = "Multi Hit Chance",
        id = gl .. "bonus_multihit_chance",
        upgrade_type = "Float",
        stat_type = "AGI",
        weapon_upgrade_id = "multihit",
        shop_upgrade_amount = 0.1,
        shop_upgrade_base_price = 15000,
        shop_upgrade_price_increase = 45000,
    }, 
    [13] = {
        name = "Max Mana",
        id = gl .. "max_mana",
        upgrade_type = "INT",
        stat_type = "INT",
        weapon_upgrade_id = "",
        shop_upgrade_amount = 30,
        shop_upgrade_base_price = 10000,
        shop_upgrade_price_increase = 20000,
    }, 
    [14] = {
        name = "Mana Regen",
        id = gl .. "mana_regen",
        upgrade_type = "INT",
        stat_type = "INT",
        weapon_upgrade_id = "",
        shop_upgrade_amount = 1,
        shop_upgrade_base_price = 30000,
        shop_upgrade_price_increase = 80000,
    }, 
    [15] = {
        name = "Bonus Mana Damage",
        id = gl .. "bonus_mana_damage",
        upgrade_type = "Float",
        stat_type = "INT",
        weapon_upgrade_id = "damage_mana",
        shop_upgrade_amount = 0.15,
        shop_upgrade_base_price = 5000,
        shop_upgrade_price_increase = 15000,
    }, 
    [16] = {
        name = "Mana Damage Reduction",
        id = gl .. "bonus_mana_resistance",
        upgrade_type = "Float",
        stat_type = "INT",
        operation_type = "reducing_mult",
        weapon_upgrade_id = "",
        max_stat = 0.85,
        shop_upgrade_amount = 0.05,
        shop_upgrade_base_price = 10000,
        shop_upgrade_price_increase = 5000,
    }, 
    [17] = {
        name = "XP Gain",
        id = gl .. "bonus_xp_gain",
        upgrade_type = "Float",
        stat_type = "INT",
        weapon_upgrade_id = "xp_gain",
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
        shop_upgrade_amount = 0.035,
        shop_upgrade_base_price = 25000,
        shop_upgrade_price_increase = 35000, 
        unlock_condition = "Obtain 4 rare or above skills in a run.",
    },
    [500] = {
        name = "Gold Gain", 
        id = gl .. "bonus_gold_gain",
        upgrade_type = "Float",
        stat_type = "EXTRA",
        shop_upgrade_amount = 0.2,
        shop_upgrade_base_price = 10000,
        shop_upgrade_price_increase = 50000,
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

tbl_gl_bonuses_weapons = {
    [1] = {
        name = "damage",
        modifier = 0.155,
        upgrade_mul = 1.11,
        max_mul = 9999,
        desc = " Damage Multiplier",
        type_mul = 1
    },
    [2] = {
        name = "resistance",
        modifier = 0.08,
        upgrade_mul = 1.09,
        max_mul = 0.95,
        desc = " Damage Reduction Multiplier",
        type_mul = -1
    },
    [3] = {
        name = "crit_chance",
        modifier = 0.07,
        upgrade_mul = 1.08,
        max_mul = 9999,
        desc = " Critical Chance Multiplier",
        type_mul = 1
    },
    [4] = {
        name = "crit_damage",
        modifier = 0.1,
        upgrade_mul = 1.09,
        max_mul = 9999,
        desc = " Critical Damage Multiplier",
        type_mul = 1
    },
    [5] = {
        name = "cooldown_speed",
        modifier = 0.14,
        upgrade_mul = 1.06,
        max_mul = 9999,
        desc = " Cooldown Speed Multiplier",
        type_mul = 1
    },
    [6] = {
        name = "damage_mana",
        modifier = 0.25,
        upgrade_mul = 1.1,
        max_mul = 9999,
        desc = " Mana Damage Multiplier",
        type_mul = 1
    },
    [7] = {
        name = "xp_gain",
        modifier = 0.04,
        upgrade_mul = 1.11,
        max_mul = 9999,
        desc = " XP Gain Multiplier",
        type_mul = 1
    },
    [8] = {
        name = "gold_gain",
        modifier = 0.06,
        upgrade_mul = 1.12,
        max_mul = 9999,
        desc = " Gold Gain Increase",
        type_mul = 1
    },
    [9] = {
        name = "multihit",
        modifier = 0.07,
        upgrade_mul = 1.085,
        max_mul = 9999,
        desc = " Multi Hit Multiplier",
        type_mul = 1
    },
    [10] = {
        name = "resistance_flatdmg",
        modifier = 0.1,
        upgrade_mul = 1.11,
        max_mul = 9999,
        desc = " Flat DMG Res Multiplier",
        type_mul = 1
    },
    [11] = {
        name = "hp_regen",
        modifier = 0.08,
        upgrade_mul = 1.1,
        max_mul = 9999,
        desc = " HP Regen Multiplier",
        type_mul = 1
    },
    [12] = {
        name = "max_overheal",
        modifier = 0.08,
        upgrade_mul = 1.11,
        max_mul = 9999,
        desc = " Max Overheal Multiplier",
        type_mul = 1
    },
    [13] = {
        name = "resistance_block",
        modifier = 0.08,
        upgrade_mul = 1.08,
        max_mul = 0.95,
        desc = " Block Damage Reduction",
        type_mul = -1
    },
    [14] = {
        name = "block_chance",
        modifier = 0.07,
        upgrade_mul = 1.07,
        max_mul = 9999,
        desc = " Block Chance Multiplier",
        type_mul = 1
    },
    [15] = {
        name = "evasion_chance",
        modifier = 0.05,
        upgrade_mul = 1.06,
        max_mul = 9999,
        desc = " Additional Evasion Chance",
        type_mul = 1
    },
    [16] = {
        name = "lifesteal",
        modifier = 0.01,
        upgrade_mul = 1.14,
        max_mul = 0.15,
        desc = " Lifesteal",
        type_mul = 1
    },
}
 
tbl_gl_rarity_to_number = {
    ["poor"] = 1,
    ["common"] = 2,
    ["uncommon"] = 3,
    ["rare"] = 4,
    ["epic"] = 5,
    ["legendary"] = 6,
    ["god"] = 7,
}

tbl_gl_enemy_modifiers = { 
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
            [1] = "Enemy gives 200% more gold. and takes reduced damage",            
            [2] = "based on current health. Every 1% health the enemy has",
            [3] = "reduces damage taken by %0.667.",
            w = 0, 
            h = 0,
        },
        color = Color(187, 161, 79),
        length = 0, 
    },
}

tbl_gl_elements = {
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
        mat_2 = Material("garlic_like/icon_elements/Burning.png")            
    },
    [2] = {
        name = "poison",
        tbl_txt = {
            [1] = "Weapons poison enemies, poison deals damage every 2 seconds.",
            [2] = "50% of the player's damage turns into the poison's damage and",
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
        mat_2 = Material("garlic_like/icon_elements/Corrosion.png")              
    },
    [3] = {
        name = "lightning",
        tbl_txt = {
            [1] = "Weapons have a 13% chance to cause the enemy to emit a lightning shockwave,",
            [2] = "The shockwave deals 300% of the damage and is capable of creating another",
            [3] = "shockwave. The initial shockwave has a 50% chance of emitting another shockwave ",
            [4] = "that deals 75% of it's original damage. The following shockwave is also capable",
            [5] = "of chaining more shockwaves, though with 10% reduced chance and 5% reduced damage",
            [6] = "for every chain.",
            [7] = "",
            [8] = "Enemy that gets hit by a shockwave briefly receives 25% more damage + (number of hits",
            [9] = "it took / 15). For every shockwave, whether it be the initial or",
            [10] = "a chain, gives the player a buff stack and increases the player's damage by",
            [11] = "(1.045^buff stacks) up to +500% damage. one buff stack disappears every 12 seconds.",
            w = 0, 
            h = 0,
        },
        color = Color(0, 151, 221),
        mat_1 = Material("garlic_like/icon_elements/Lightning.png"),
        mat_2 = Material("garlic_like/icon_elements/Shock.png")              
    }
}

garlic_like_upgrades = {}

if IsMounted("tf") then
    local tf2PCFs = {"tf2rockets.pcf", "bigboom.pcf", "bl_killtaunt.pcf", "blood_impact.pcf", "blood_trail.pcf", "bombinomicon.pcf", "buildingdamage.pcf", "bullet_tracers.pcf", "burningplayer.pcf", "cig_smoke.pcf", "cinefx.pcf", "class_fx.pcf", "classic_rocket_trail.pcf", "coin_spin.pcf", "conc_stars.pcf", "crit.pcf", "default.pcf", "dirty_explode.pcf", "disguise.pcf", "doomsday_fx.pcf", "drg_bison.pcf", "drg_cowmangler.pcf", "drg_engineer.pcf", "drg_pyro.pcf", "dxhr_fx.pcf", "explosion.pcf", "eyeboss.pcf", "firstperson_weapon_fx.pcf", "flag_particles.pcf", "flamethrower.pcf", "flamethrower_mvm.pcf", "halloween.pcf", "harbor_fx.pcf", "item_fx.pcf", "items_demo.pcf", "items_engineer.pcf", "killstreak.pcf", "level_fx.pcf", "medicgun_attrib.pcf", "medicgun_beam.pcf", "muzzle_flash.pcf", "mvm.pcf", "nailtrails.pcf", "nemesis.pcf", "npc_fx.pcf", "player_recent_teleport.pcf", "rain_custom.pcf", "rocketbackblast.pcf", "rocketjumptrail.pcf", "rockettrail.pcf", "rps.pcf", "scary_ghost.pcf", "shellejection.pcf", "smoke_blackbillow.pcf", "smoke_blackbillow_hoodoo.pcf", "soldierbuff.pcf", "sparks.pcf", "speechbubbles.pcf", "stamp_spin.pcf", "stickybomb.pcf", "stormfront.pcf", "taunt_fx.pcf", "teleport_status.pcf", "teleported_fx.pcf", "training.pcf", "urban_fx.pcf", "water.pcf", "xms.pcf"}

    for k, pcf in pairs(tf2PCFs) do
        game.AddParticles("particles/" .. pcf)
    end 
end

function IsNumBetween(x, min, max)
    return x >= min and x <= max
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function garlic_like_create_upgrade_table()
    --* STAT UPGRADES
    garlic_like_upgrades[11] = {
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

    garlic_like_upgrades[12] = {
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

    garlic_like_upgrades[13] = {
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
    garlic_like_upgrades[100] = {
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
        statboost = 0.085,
        icon = "garlic_like/icon_orb_xp.png",
        number_addition = 1
    }

    garlic_like_upgrades[110] = {
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
        statboost = 0.05,
        icon = "garlic_like/icon_armor.png",
        number_addition = -1
    }

    garlic_like_upgrades[120] = {
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
        statboost = 0.1,
        icon = "garlic_like/icon_muscles.png",
        number_addition = 1
    }

    garlic_like_upgrades[130] = {
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
        statboost = 0.15,
        icon = "garlic_like/icon_sword.png",
        number_addition = 1
    }

    garlic_like_upgrades[140] = {
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
        statboost = 0.07,
        icon = "garlic_like/icon_crystal.png",
        number_addition = 1
    }

    garlic_like_upgrades[150] = {
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
        statboost = 0.075,
        icon = "garlic_like/icon_glasses_crit.png",
        number_addition = 1
    }

    garlic_like_upgrades[160] = {
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
        statboost = 0.075,
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

    garlic_like_upgrades[300] = {
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

    garlic_like_upgrades[310] = {
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

    garlic_like_upgrades[320] = {
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

    garlic_like_upgrades[330] = {
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
    garlic_like_upgrades[500] = {
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

    garlic_like_upgrades[510] = {
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

    garlic_like_upgrades[520] = {
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

    garlic_like_upgrades[530] = {
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

    garlic_like_upgrades[540] = {
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
        mul = 0.85,
        mul_is_second = true,
        icon = "garlic_like/icon_relics/deft-hands.png"
    }

    garlic_like_upgrades[550] = {
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

    garlic_like_upgrades[560] = {
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
        mul = 1.15,
        mul_2 = 1.35,
        icon = "garlic_like/icon_relics/hawkeye-sight.png"
    }

    garlic_like_upgrades[570] = {
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
        mul = 1.4,
        icon = "garlic_like/icon_relics/blade-mail.png"
    }

    garlic_like_upgrades[580] = {
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
        mul = 0.3,
        icon = "garlic_like/icon_relics/advanced-jogger.png"
    }

    garlic_like_upgrades[590] = {
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

    garlic_like_upgrades[600] = {
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
        mul = 0.7,
        mul_2 = 0.3,
        icon = "garlic_like/icon_relics/preemptive-strike.png"
    } 
end
  
garlic_like_create_upgrade_table() 