-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Broken Vintage Chair"
SWEP.Instructions = "The remains of a wooden chair."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

local CHUNK_MODEL = "models/gibs/furniture_gibs/furniture_chair01a_gib01.mdl"

SWEP.Weight = 0
SWEP.WorldModel = CHUNK_MODEL
SWEP.WorldModelExchange = CHUNK_MODEL
SWEP.WorldModelReal = "models/viper/mw/weapons/v_cinderblock.mdl"
SWEP.ViewModel = ""

SWEP.HoldType = "camera"

SWEP.HoldPos = Vector(-5,1,0)

SWEP.AttackTime = 0.4
SWEP.AnimTime1 = 2.15
SWEP.WaitTime1 = 1.1
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 2
SWEP.WaitTime2 = 0.7
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 115

SWEP.weaponPos = Vector(5,-1,1)
SWEP.weaponAng = Angle(190,-210,15)
SWEP.modelscale = 1.1

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 9
SWEP.DamageSecondary = 6

SWEP.PenetrationPrimary = 2
SWEP.PenetrationSecondary = 1.5

SWEP.BlockTier = 0
SWEP.MaxPenLen = 4

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 1

SWEP.StaminaPrimary = 13
SWEP.StaminaSecondary = 5

SWEP.AttackLen1 = 60
SWEP.AttackLen2 = 55

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "melee_miss_01",
    ["attack2"] = "melee_miss_02",
    ["holster"] = "holster",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/chairb2.png")
	SWEP.IconOverride = "melgun/chairb2.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.AttackHit = "physics/wood/wood_solid_impact_hard1.wav"
SWEP.Attack2Hit = "physics/wood/wood_solid_impact_hard2.wav"
SWEP.AttackHitFlesh = "physics/wood/wood_solid_impact_hard3.wav"
SWEP.Attack2HitFlesh = "physics/wood/wood_solid_impact_hard4.wav"
SWEP.DeploySnd = "physics/wood/wood_plank_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.BlockHoldPos = Vector(-7.5,1,10)
SWEP.BlockHoldAng = Angle(18, 15, -20)

SWEP.AttackRads = 55
SWEP.AttackRads2 = 0

SWEP.BreakBoneMul = 0.8
SWEP.PainMultiplier = 1.1

SWEP.SwingAng = -30
SWEP.SwingAng2 = 0

SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis"
SWEP.holsteredPos = Vector(-1.1, -9, -5.3)
SWEP.holsteredAng = Angle(195, 75, 230)
SWEP.Concealed = false
SWEP.HolsterIgnored = true
SWEP.Ignorebelt = true

SWEP.AnimList["Attack_Charge_End"] = SWEP.AnimList["attack"]

SWEP.CanHeavyAttack = true
SWEP.HeavyAttackDamageMul = 2
SWEP.HeavyAttackWaitTime = 1.6
SWEP.HeavyAttackAnimTimeBegin = 0.7
SWEP.HeavyAttackAnimTimeIdle = 0.8
SWEP.HeavyAttackAnimTimeEnd = 2.2
SWEP.HeavyAttackDelay = 0.4
SWEP.HeavyAttackTimeLength = 0.25
SWEP.HeavyAttackMaxChargeTime = 1.3
SWEP.HeavyAttackSwingAng = -45
SWEP.HeavyAttackRads = 100
SWEP.HeavyChargeHoldPos = Vector(-13,0,7)
SWEP.HeavyChargeHoldAng = Angle(-30, 0, 0)

SWEP.NoHolster = true
SWEP.MinSensivity = 0.8

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    return true
end

function SWEP:InitAdd()
    util.PrecacheModel(CHUNK_MODEL)
end


-- Limbo: this weapon's heavy attack, in the names Limbo's melee base reads (hold R + click)
SWEP.canchargeattack = true
SWEP.ChargeDamageMul = SWEP.HeavyAttackDamageMul or 1.85
SWEP.ChargeBreakBoneMul = SWEP.ChargeBreakBoneMul or 1.5
SWEP.ChargeWaitTime = SWEP.HeavyAttackWaitTime or 2
SWEP.ChargeAnimTimeBegin = SWEP.HeavyAttackAnimTimeBegin or 0.8
SWEP.ChargeAnimTimeIdle = SWEP.HeavyAttackAnimTimeIdle or 0.8
SWEP.ChargeAnimTimeEnd = SWEP.HeavyAttackAnimTimeEnd or (SWEP.AnimTime1 or 1.5)
SWEP.ChargeFullTime = math.min(SWEP.HeavyAttackMaxChargeTime or 0.8, 0.9)
SWEP.ChargeAttackTime = SWEP.HeavyAttackDelay or SWEP.AttackTime or 0.35
SWEP.ChargeAttackTimeLength = SWEP.HeavyAttackTimeLength or 0.25
SWEP.ChargeAttackRads = SWEP.HeavyAttackRads or 85
SWEP.ChargeSwingAng = SWEP.HeavyAttackSwingAng or -60
SWEP.ChargeAttackLen = SWEP.AttackLen1 or 70
SWEP.ChargeStamina = (SWEP.StaminaPrimary or 20) * 2
SWEP.ChargeTapCancelTime = 1
SWEP.ChargeViewPunch = Angle(6, 0, 0)
SWEP.ChargeHoldPos = SWEP.HeavyChargeHoldPos
SWEP.ChargeHoldAng = SWEP.HeavyChargeHoldAng
if SWEP.AnimList then
    -- no wind-up animation on these models: hold the idle pose while pulling back, then swing
    SWEP.AnimList["charge_begin"] = SWEP.AnimList["charge_begin"] or SWEP.AnimList["idle"]
    SWEP.AnimList["charge_idle"] = SWEP.AnimList["charge_idle"] or SWEP.AnimList["idle"]
    SWEP.AnimList["charge_end"] = SWEP.AnimList["charge_end"] or SWEP.AnimList["Attack_Charge_End"] or SWEP.AnimList["attack"]
end
