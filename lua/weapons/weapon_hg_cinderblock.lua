-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Cinderblock"
SWEP.Instructions = "A Cinderblock, used for building and construction.\n\nLMB to attack.\nRMB to block.\nRMB + LMB (tap) for a second strike.\nHold RMB + LMB to throw."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Weight = 0
SWEP.WorldModel = "models/props_junk/cinderblock01a.mdl"
SWEP.WorldModelReal = "models/viper/mw/weapons/v_cinderblock.mdl"
SWEP.WorldModelExchange = "models/props_junk/cinderblock01a.mdl"
SWEP.ViewModel = ""

SWEP.HoldType = "camera"

SWEP.HoldPos = Vector(-5,1,0)

SWEP.AttackTime = 0.45
SWEP.AnimTime1 = 2.15
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 2
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 115

SWEP.weaponPos = Vector(-0.5,0,0.5)
SWEP.weaponAng = Angle(0,0,-75)
SWEP.modelscale = 0.71

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 25
SWEP.DamageSecondary = 20

SWEP.PenetrationPrimary = 2.5
SWEP.PenetrationSecondary = 2

SWEP.BlockTier = 3
SWEP.MaxPenLen = 5

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 30
SWEP.StaminaSecondary = 20

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
	SWEP.WepSelectIcon = Material("melgun/Cinder.png")
	SWEP.IconOverride = "melgun/Cinder.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.AttackHit = "cinderblock/hit1.ogg"
SWEP.Attack2Hit = "cinderblock/hit1.ogg"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.BlockHoldPos = Vector(-7.5,1,10)
SWEP.BlockHoldAng = Angle(18, 15, -20)

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.BreakBoneMul = 1.1
SWEP.PainMultiplier = 1.5

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
    self.AttackHit = self:GetRandomCinderHitSound()
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
    "cinderblock/cinderhit1.ogg",
    "cinderblock/cinderhit2.ogg",
    "cinderblock/cinderhit3.ogg",
    "cinderblock/cinderhit4.ogg",
}

function SWEP:GetRandomCinderHitSound()
    return self.CinderHitSounds[math.random(#self.CinderHitSounds)]
end

function SWEP:InitAdd()
    util.PrecacheSound("cinderblock/cinderhit1.ogg")
    util.PrecacheSound("cinderblock/cinderhit2.ogg")
    util.PrecacheSound("cinderblock/cinderhit3.ogg")
    util.PrecacheSound("cinderblock/cinderhit4.ogg")
end

function SWEP:PrimaryAttackAdd(ent, trace)
    if SERVER and IsValid(ent) and self:IsEntSoft(ent) then
        local owner = self:GetOwner()
        if IsValid(owner) then
            owner:EmitSound(self:GetRandomCinderHitSound(), 50, math.random(95,105))
        end
    end
end

function SWEP:SecondaryAttackAdd(ent, trace)
    if SERVER and IsValid(ent) and self:IsEntSoft(ent) then
        local owner = self:GetOwner()
        if IsValid(owner) then
            owner:EmitSound(self:GetRandomCinderHitSound(), 50, math.random(95,105))
        end
    end
end

local CINDER_MODEL = "models/props_junk/cinderblock01a.mdl"
local HELD_SCALE = SWEP.modelscale

SWEP.ThrowHoldTime = 0.5
SWEP.ThrowDamage = 20
SWEP.ThrowSpeed = 900

function SWEP:GetWorldModelExchange()
    self.modelscale = IsValid(self:GetOwner()) and HELD_SCALE or 1
    return CINDER_MODEL
end

function SWEP:SecondaryAttack(override)
    if override and not self.tapOverride then
        if not self.comboStart then self.comboStart = CurTime() end
        return
    end

    self.BaseClass.SecondaryAttack(self, override)
end

function SWEP:CustomAttack2()
    if not self.doThrow then return false end
    if not SERVER then return true end

    local ply = self:GetOwner()
    local ent = ents.Create("ent_throwable")
    ent.WorldModel = self.WorldModelExchange or self.WorldModel

    ent:SetPos(select(1, hg.eye(ply, 60, hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
    ent:SetAngles(ply:EyeAngles())
    ent:SetOwner(ply)
    ent:Spawn()

    ent.localshit = Vector(0, 0, 0)
    ent.wep = self:GetClass()
    ent.owner = ply
    ent.damage = self.ThrowDamage
    ent.MaxSpeed = self.ThrowSpeed
    ent.DamageType = DMG_CLUB
    ent.AttackHit = "cinderblock/hit1.ogg"
    ent.AttackHitFlesh = "Flesh.ImpactHard"
    ent.noStuck = true

    local sounds = self.CinderHitSounds
    ent.func = function(data)
        if (ent.nextImpact or 0) > CurTime() then return end
        ent.nextImpact = CurTime() + 0.15

        ent:EmitSound(sounds[math.random(#sounds)], 75, math.random(95, 105))
    end

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(VectorRand() * 300)
    end

    ply:ViewPunch(Angle(0, 0, -8))
    ply:SelectWeapon("weapon_hands_sh")

    self:Remove()

    return true
end

function SWEP:ComboThink()
    if not self.comboStart then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or owner:GetActiveWeapon() ~= self then
        self.comboStart = nil
        return
    end

    local lmb = hg.KeyDown(owner, IN_ATTACK)
    local rmb = hg.KeyDown(owner, IN_ATTACK2)
    local held = CurTime() - self.comboStart

    if lmb and rmb then
        if held >= self.ThrowHoldTime then
            self.comboStart = nil

            if SERVER then
                self.doThrow = true
                self:CustomAttack2()
                self.doThrow = nil
            end
        end
    else
        self.comboStart = nil

        if held < self.ThrowHoldTime then
            self.tapOverride = true
            self:SecondaryAttack(true)
            self.tapOverride = nil
        end
    end
end

function SWEP:Think()
    self.BaseClass.Think(self)
    self:ComboThink()
end

local ITEM_MODEL = CINDER_MODEL
local ITEM_CLASS = string.StripExtension(string.GetFileFromFilename(debug.getinfo(1, "S").short_src))
local ITEM_NAME = SWEP.PrintName

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end
        if string.lower(ent:GetModel() or "") ~= ITEM_MODEL then return false end

        if (ply.NextCinderblockPickup or 0) > CurTime() then return false end
        ply.NextCinderblockPickup = CurTime() + 0.5

        if ply:HasWeapon(ITEM_CLASS) then return false end

        local wep = ply:Give(ITEM_CLASS)
        if not IsValid(wep) then return false end

        ent:Remove()
        ply:SelectWeapon(ITEM_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_CinderblockPickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_CinderblockPickupKey", function(ply, key)
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

    hook.Add("Think", "HG_CinderblockHint", function()
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
