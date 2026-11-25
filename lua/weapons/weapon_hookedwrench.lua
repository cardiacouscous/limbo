-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_melee"
SWEP.PrintName = "Hooked-Wrench"
SWEP.Instructions = "A modified pipe wrench fitted with twin razor-sharp sickles. Used to fix broken pipes, now it just breaks people."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/mosi/fallout4/props/weapons/melee/pipewrench.mdl"
SWEP.BodyGroups = {
    [0] = 6
}

SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_wrench.mdl"
SWEP.WorldModelExchange = "models/mosi/fallout4/props/weapons/melee/pipewrench.mdl"
SWEP.ViewModel = "models/mosi/fallout4/props/weapons/melee/pipewrench.mdl"

SWEP.SuicidePos = Vector(29, -9, -29)
SWEP.SuicideAng = Angle(-90, -150, 50)
SWEP.SuicideCutVec = Vector(3, -6, 3)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.SuicideSound = "player/flesh/flesh_bullet_impact_03.wav"
SWEP.CanSuicide = true
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)

SWEP.HoldType = "melee"
SWEP.bloodID = 3
SWEP.weight = 2

SWEP.HoldPos = Vector(-15, 0, 0)
SWEP.HoldAng = Angle(8, 6, -12)

SWEP.AttackTime = 0.6
SWEP.AnimTime1 = 1.6
SWEP.WaitTime1 = 1
SWEP.ViewPunch1 = Angle(0, -5, 3)

SWEP.PainMultiplier = 1.3
SWEP.BreakBoneMul = 0.7

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0, 0, -4)

SWEP.sprint_ang = Angle(15, 0, 0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0, 0, -8)
SWEP.weaponAng = Angle(0, 0, 0)

SWEP.DamageType = DMG_CLUB
SWEP.ExtraDamageType = DMG_SLASH
SWEP.ExtraDamageMul = 0.5
SWEP.DamagePrimary = 23
SWEP.DamageSecondary = 13

SWEP.BlockHoldPos = Vector(-15, 7, -11)
SWEP.BlockHoldAng = Angle(-5, 0, -45)

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 3

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 30
SWEP.StaminaSecondary = 8

SWEP.AttackLen1 = 100
SWEP.AttackLen2 = 30

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}

if CLIENT then
    SWEP.WepSelectIcon = Material("melgun/hook.png")
    SWEP.IconOverride = "melgun/hook.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false
SWEP.BlockTier = 2


SWEP.AttackHit = "SolidMetal.ImpactHard"
SWEP.Attack2Hit = "SolidMetal.ImpactHard"
SWEP.AttackHitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "SolidMetal.ImpactSoft"

SWEP.AttackPos = Vector(0, 0, 0)

function SWEP:CanSecondaryAttack()
    return true
end

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 100
SWEP.AttackRads2 = 0

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.NoHolster = true