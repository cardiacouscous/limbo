-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Cash Register"
SWEP.Instructions = "Here comes the moneeey.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

local CASH_MODEL  = "models/props_c17/cashregister01a.mdl"
local CASH_CLASS  = "weapon_hg_cash" 

SWEP.Weight = 0
SWEP.WorldModel = CASH_MODEL
SWEP.WorldModelExchange = CASH_MODEL
SWEP.WorldModelReal = "models/viper/mw/weapons/v_cinderblock.mdl"
SWEP.ViewModel = ""

SWEP.HoldType = "camera"

SWEP.HoldPos = Vector(-5,1,0)

SWEP.AttackTime = 0.50
SWEP.AnimTime1 = 2.60
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 2
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 115

SWEP.weaponPos = Vector(2,-3,2)
SWEP.weaponAng = Angle(0,90,9)
SWEP.modelscale = 0.9

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 20
SWEP.DamageSecondary = 12

SWEP.PenetrationPrimary = 2.5
SWEP.PenetrationSecondary = 2

SWEP.BlockTier = 3
SWEP.MaxPenLen = 5

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 29
SWEP.StaminaSecondary = 16

SWEP.AttackLen1 = 70
SWEP.AttackLen2 = 65

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "melee_miss_01",
    ["attack2"] = "melee_miss_02",
    ["holster"] = "holster",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/Money.png")
	SWEP.IconOverride = "melgun/Money.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.AttackHit = "physics/metal/metal_solid_impact_hard4.wav"
SWEP.Attack2Hit = "physics/metal/metal_solid_impact_hard5.wav"
SWEP.AttackHitFlesh = "physics/metal/metal_solid_impact_hard4.wav"
SWEP.Attack2HitFlesh = "physics/metal/metal_solid_impact_hard5.wav"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.BlockHoldPos = Vector(-7.5,1,10)
SWEP.BlockHoldAng = Angle(18, 15, -20)

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.BreakBoneMul = 1.5
SWEP.PainMultiplier = 1.3

SWEP.SwingAng = -30
SWEP.SwingAng2 = 0

SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis"
SWEP.holsteredPos = Vector(-1.1, -9, -5.3)
SWEP.holsteredAng = Angle(195, 75, 230)
SWEP.Concealed = false
SWEP.HolsterIgnored = true
SWEP.Ignorebelt = true

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    return true
end

function SWEP:PrimaryAttack()
    self.BaseClass.PrimaryAttack(self)
end

SWEP.AnimList["Attack_Charge_End"] = SWEP.AnimList["attack"]

SWEP.CanHeavyAttack = true
SWEP.HeavyAttackDamageMul = 2.5          
SWEP.HeavyAttackWaitTime = 2.0
SWEP.HeavyAttackAnimTimeBegin = 0.7
SWEP.HeavyAttackAnimTimeIdle = 0.8
SWEP.HeavyAttackAnimTimeEnd = 2.5
SWEP.HeavyAttackDelay = 0.4
SWEP.HeavyAttackTimeLength = 0.25
SWEP.HeavyAttackMaxChargeTime = 1.5
SWEP.HeavyAttackSwingAng = -45
SWEP.HeavyAttackRads = 110
SWEP.HeavyChargeHoldPos = Vector(-13,0,7)
SWEP.HeavyChargeHoldAng = Angle(-30, 0, 0) 

SWEP.NoHolster = true
SWEP.MinSensivity = 0.75
SWEP.CinderHitSounds = {
    "cash/kassa_rJFy4PK9.wav",
    "cash/kassa_rJFy4PK9.wav",
    "cash/kassa_rJFy4PK9.wav",
    "cash/kassa_rJFy4PK9.wav",
}

function SWEP:GetRandomCinderHitSound()
    return self.CinderHitSounds[math.random(#self.CinderHitSounds)]
end

function SWEP:InitAdd()
    util.PrecacheSound("physics/metal/metal_solid_impact_hard4.wav")
    util.PrecacheSound("cash/kassa_rJFy4PK9.wav")
    util.PrecacheModel("models/props/cs_assault/dollar.mdl")
    util.PrecacheModel("models/props_c17/furniturechair001a_chunk01.mdl")
    util.PrecacheModel("models/props_c17/furniturechair001a_chunk02.mdl")
    util.PrecacheModel("models/props_c17/furniturechair001a_chunk03.mdl")
end

SWEP.MaxDollarSplashes = 5

if SERVER then
    function SWEP:SplashDollars(trace)
        if not trace or not trace.Hit then return end
        if (self.nextDollarSplash or 0) > CurTime() then return end
        self.nextDollarSplash = CurTime() + 0.5

        self.DollarSplashesLeft = self.DollarSplashesLeft or self.MaxDollarSplashes
        if self.DollarSplashesLeft <= 0 then return end

        if math.random(4) ~= 1 then return end

        self.DollarSplashesLeft = self.DollarSplashesLeft - 1

        local pos = trace.HitPos + (trace.HitNormal or vector_up) * 5
        local count = math.random(1, 10)

        for i = 1, count do
            local dollar = ents.Create("prop_physics")
            if IsValid(dollar) then
                dollar:SetModel("models/props/cs_assault/dollar.mdl")
                dollar:SetPos(pos + VectorRand() * 6)
                dollar:SetAngles(AngleRand())
                dollar:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                dollar:Spawn()
                dollar:Activate()

                local phys = dollar:GetPhysicsObject()
                if IsValid(phys) then
                    phys:Wake()
                    phys:SetVelocity(Vector(math.Rand(-150, 150), math.Rand(-150, 150), math.Rand(100, 250)))
                    phys:AddAngleVelocity(VectorRand() * 300)
                end

                SafeRemoveEntityDelayed(dollar, 15)
            end
        end
    end

    function SWEP:PrimaryAttackAdd(ent, trace)
        self:SplashDollars(trace)
    end

    function SWEP:SecondaryAttackAdd(ent, trace)
        self:SplashDollars(trace)
    end
end

local ITEM_MODEL = "models/props_c17/cashregister01a.mdl"
local ITEM_CLASS = string.StripExtension(string.GetFileFromFilename(debug.getinfo(1, "S").short_src))
local ITEM_NAME = SWEP.PrintName

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end
        if string.lower(ent:GetModel() or "") ~= ITEM_MODEL then return false end

        if (ply.NextCashPickup or 0) > CurTime() then return false end
        ply.NextCashPickup = CurTime() + 0.5

        if ply:HasWeapon(ITEM_CLASS) then return false end

        local wep = ply:Give(ITEM_CLASS)
        if not IsValid(wep) then return false end

        ent:Remove()
        ply:SelectWeapon(ITEM_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_CashPickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_CashPickupKey", function(ply, key)
        if key ~= IN_USE then return end
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab

        local start = ply:GetShootPos()
        local aim = ply:GetAimVector()

        local tr = util.TraceHull({
            start = start,
            endpos = start + aim * 90,
            mins = Vector(-6, -6, -6),
            maxs = Vector(6, 6, 6),
            filter = ply,
        })

        if IsValid(tr.Entity) then
            TryPickup(ply, tr.Entity)
        end
    end)
end

if CLIENT then
    local itemHint

    hook.Add("Think", "HG_CashHint", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() or not hg or not hg.eyeTrace then return end

        local tr = hg.eyeTrace(lply)
        if not tr then return end

        local ent = tr.Entity
        if not IsValid(ent) or ent.HudHintMarkup then return end
        if ent:GetClass() ~= "prop_physics" or string.lower(ent:GetModel() or "") ~= ITEM_MODEL then return end

        if not itemHint then
            local key = string.upper(input.LookupBinding("+use") or "E")
            itemHint = markup.Parse(
                "<font=ZCity_Tiny>" .. ITEM_NAME .. "\n<colour=170,170,170>Melee weapon - press " .. key .. " to pick up</colour></font>",
                500
            )
        end

        ent.HudHintMarkup = itemHint
    end)
end

hook.Add("EntityEmitSound", "HG_CashRegisterHitSound", function(data)
    local ent = data.Entity
    if not IsValid(ent) then return end

    local wep = ent:IsWeapon() and ent or (ent:IsPlayer() and ent:GetActiveWeapon())
    if not IsValid(wep) or wep:GetClass() ~= "weapon_hg_cash" then return end

    local snd = string.lower(data.SoundName or "")
    if string.find(snd, "metal_solid_impact_hard") then
        ent:EmitSound("cash/kassa_rJFy4PK9.wav", 75, 100, 1, CHAN_STATIC)
    end
end)


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
