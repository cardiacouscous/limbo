-- Limbo: from MeleeCity weapons (Workshop 3671336279) by agaf and kazoo, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Skateboard"
SWEP.Instructions = "A Skateboard with BAKER design, quite slick and good for smashing heads in."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Weight = 0
SWEP.weight = 1.75
SWEP.WorldModel = "models/skateboard5pack/baker_board.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_tool_extinguisher.mdl"
SWEP.WorldModelExchange =  "models/skateboard5pack/baker_board.mdl"
SWEP.ViewModel = ""

SWEP.HoldType = "camera"

SWEP.DamageType = DMG_SLASH

SWEP.HoldPos = Vector(-15,1,2)

SWEP.AttackTime = 0.27
SWEP.AnimTime1 = 1.3
SWEP.WaitTime1 = 1
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 93

SWEP.weaponPos = Vector(0,0,0)
SWEP.weaponAng = Angle(65,0,-15)
SWEP.modelscale = 0.63

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 20
SWEP.DamageSecondary = 15

SWEP.PenetrationPrimary = 4
SWEP.PenetrationSecondary = 2

SWEP.MaxPenLen = 5

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 20
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 30

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Attack_Quick",
    ["holster"] = "Draw",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/skateboard.png")
	SWEP.IconOverride = "vgui/skateboard.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true


SWEP.AttackHit = "physics/wood/wood_plank_impact_hard1.wav"
SWEP.Attack2Hit = "physics/wood/wood_plank_impact_hard1.wav"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.BlockHoldPos = Vector(-15,1,7)
SWEP.BlockHoldAng = Angle(18, 15, -20)
SWEP.BlockSound = "physics/wood/wood_plank_impact_hard1.wav"
SWEP.BlockTier = 2
SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.BreakBoneMul = 0.65
SWEP.PainMultiplier = 0.8

SWEP.SwingAng = -30
SWEP.SwingAng2 = 0

SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis" -- Different attachment point
SWEP.holsteredPos = Vector(-1.1, -9, -5.3) -- Adjust position
SWEP.holsteredAng = Angle(195, 75, 230) -- Adjust rotation
SWEP.Concealed = false -- wont show up on the body
SWEP.HolsterIgnored = true -- the holster system will ignore
SWEP.Ignorebelt = true

SWEP.HeavyAttackDamageMul = 1.7 -- Max damage multiplier at full charge
SWEP.HeavyAttackWaitTime = 1.5 -- Time before you can attack again
SWEP.HeavyAttackAnimTimeBegin = 1.0 -- Duration of the wind-up/start animation
SWEP.HeavyAttackAnimTimeIdle = 1 -- Duration of the idle loop
SWEP.HeavyAttackAnimTimeEnd = 2 -- Duration of the attack animation
SWEP.HeavyAttackDelay = 0.4 -- Time delay before the hit actually connects (during attack anim)
SWEP.HeavyAttackTimeLength = 0.4 -- Duration of the active hit window
SWEP.HeavyAttackViewPunch = Angle(5, 0, 0) -- View punch angle on hit
SWEP.HeavyAttackMaxChargeTime = 2.0 -- Time in seconds to reach max damage/shake
SWEP.HeavyAttackSwingAng = -90 -- Custom swing angle for heavy attack
SWEP.HeavyAttackRads = 80 -- Custom radius/arc for heavy attack
SWEP.HeavyAttackStamina = 22
SWEP.HeavyChargeHoldPos = Vector(6, 5, 1)

SWEP.CanHeavyAttack = true -- Set to true to enable

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    return true
end

function SWEP:PrimaryAttack()
    self.BaseClass.PrimaryAttack(self)
end



SWEP.NoHolster = true
SWEP.MinSensivity = 0.75

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
