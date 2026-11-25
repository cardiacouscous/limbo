-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_melee"
SWEP.PrintName = "Morning star"
SWEP.Instructions = "Morning star is a blunt, crushing weapon consisting of a metal ball studded with spikes"
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/grognakbattlemace.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_sledge.mdl"
SWEP.WorldModelExchange = "models/weapons/grognakbattlemace.mdl"
SWEP.ViewModel = ""
SWEP.weight = 3.15

SWEP.SuicidePos = Vector(9, -17, 15)
SWEP.SuicideAng = Angle(60, 30, 0)
SWEP.SuicideCutVec = Vector(1, 5, 1)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 2
SWEP.SuicideSound = "player/flesh/flesh_bullet_impact_03.wav"
SWEP.CanSuicide = true
SWEP.SuicideNoLH = false
SWEP.SuicideHoldType = "slam"

SWEP.NoHolster = true
SWEP.HoldType = "camera"

SWEP.DamageType = bit.bor(DMG_BULLET, DMG_CLUB)

SWEP.HoldPos = Vector(-11, 0, 0)

SWEP.AttackTime = 1
SWEP.AnimTime1 = 2.7
SWEP.WaitTime1 = 2.7
SWEP.ViewPunch1 = Angle(1, 2, 0)

SWEP.Attack2Time = 0.9
SWEP.AnimTime2 = 2
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0, 0, -2)

SWEP.attack_ang = Angle(0, 0, 0)
SWEP.sprint_ang = Angle(15, 0, 0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0, 0, -11)
SWEP.weaponAng = Angle(0, -70, -1)

SWEP.DamagePrimary = 68
SWEP.DamageSecondary = 20

SWEP.PenetrationPrimary = 4
SWEP.PenetrationSecondary = 6

SWEP.MaxPenLen = 4

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 65
SWEP.StaminaSecondary = 30

SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 45

SWEP.BlockHoldPos = Vector(-11, 0, 0)
SWEP.BlockHoldAng = Angle(0, 9, -25)
SWEP.BlockSound = "physics/metal/metal_solid_impact_bullet1.wav"

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}

if CLIENT then
    SWEP.WepSelectIcon = Material("melgun/Morningstar.png")
    SWEP.IconOverride = "melgun/Morningstar.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.HeavyAttackDamageType = DMG_CLUB
SWEP.HeavyAttackDamageMul = 2.0
SWEP.HeavyAttackWaitTime = 1.0
SWEP.HeavyAttackAnimTimeBegin = 1.0
SWEP.HeavyAttackAnimTimeIdle = 1
SWEP.HeavyAttackAnimTimeEnd = 1.85
SWEP.HeavyAttackDelay = 0.5
SWEP.HeavyAttackTimeLength = 0.4
SWEP.HeavyAttackViewPunch = Angle(5, 0, 0)
SWEP.HeavyAttackMaxChargeTime = 2.0
SWEP.HeavyAttackSwingAng = -90
SWEP.HeavyAttackRads = 75

SWEP.CanHeavyAttack = true

SWEP.BreakBoneMul = 0.55
SWEP.PainMultiplier = 0.9

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft2.wav"

if SERVER then
    util.PrecacheSound("shovelhit.mp3")
    util.PrecacheSound("heavyshovel/hit1.mp3")
    util.PrecacheSound("heavyshovel/hit2.mp3")
    util.PrecacheSound("heavyshovel/hit3.mp3")
end

SWEP.AttackPos = Vector(0, 0, 0)

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    return true
end

function SWEP:CanPrimaryAttack()
    self.DamageType = bit.bor(DMG_BULLET, DMG_CLUB)
    self.AttackHit = "Concrete.ImpactHard"
    self.Attack2Hit = "Concrete.ImpactHard"
    return true
end

SWEP.AttackTimeLength = 0.10
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 65
SWEP.AttackRads2 = 0

SWEP.SwingAng = -15
SWEP.SwingAng2 = 0
SWEP.BlockTier = 3

function SWEP:PrimaryAttack()
    if hg.KeyDown(self:GetOwner(), IN_USE) then
        local tr = self.Owner:GetEyeTrace()

        if IsValid(tr.Entity)
        and string.find(string.lower(tr.Entity:GetClass()), "door")
        and self:GetOwner():GetPos():Distance(tr.Entity:GetPos()) <= 80 then

            local locked = false

            if tr.Entity.GetInternalVariable then
                locked = tr.Entity:GetInternalVariable("m_bLocked")
            end

            if not locked then
                return
            end

            if not self.BreakingDoor then
                self.BreakingDoor = true
                self.BreakStartTime = CurTime()
                self.BreakDuration = math.random(15, 20)
                self.DoorEntity = tr.Entity
                self.NextBreakSound = CurTime() + math.Rand(1, 2)
            end

            return
        end
    end

    self.BaseClass.PrimaryAttack(self)
end

function SWEP:Think()
    if self.BreakingDoor then
        if not (
            hg.KeyDown(self:GetOwner(), IN_USE)
            and hg.KeyDown(self:GetOwner(), IN_ATTACK)
        ) then
            self.BreakingDoor = false

        elseif not (
            IsValid(self.DoorEntity)
            and self:GetOwner():GetPos():Distance(self.DoorEntity:GetPos()) <= 80
        ) then
            self.BreakingDoor = false

        else
            if not self.NextBreakSound then
                self.NextBreakSound = CurTime() + math.Rand(1, 2)
            end

            if CurTime() >= self.NextBreakSound then
                if IsValid(self.DoorEntity) then
                    self.DoorEntity:EmitSound(
                        "physics/wood/wood_crate_break2.wav",
                        75,
                        100
                    )
                end

                self.NextBreakSound = CurTime() + math.Rand(1, 2)
            end

            if CurTime() >= self.BreakStartTime + self.BreakDuration then
                if IsValid(self.DoorEntity) then
                    self.DoorEntity:Fire("Unlock", "", 0)
                    self.DoorEntity:Fire("Open", "", 0)
                end

                self.BreakingDoor = false
            end
        end
    end

    self.BaseClass.Think(self)
end

SWEP.MinSensivity = 0.6

function SWEP:PrimaryAttackAdd(ent, trace)
    if SERVER and IsValid(ent) and self:IsEntSoft(ent) then
        self:GetOwner():EmitSound(
            "shovelhit.mp3",
            50,
            math.random(95, 115)
        )

        self:GetOwner():EmitSound(
            "heavyshovel/hit" .. math.random(1, 3) .. ".mp3",
            50,
            math.random(95, 115)
        )
    end
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
