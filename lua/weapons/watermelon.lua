-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Watermelon"
SWEP.Instructions = "A Watermelon.\n\nLMB to attack.\nRMB to block.\nRMB + LMB to throw."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Weight = 3
SWEP.WorldModel = "models/props_junk/watermelon01.mdl"
SWEP.WorldModelReal = "models/viper/mw/weapons/v_cinderblock.mdl"
SWEP.WorldModelExchange = "models/props_junk/watermelon01.mdl"
SWEP.ViewModel = ""

SWEP.HoldType = "camera"

SWEP.HoldPos = Vector(-5,1,0)

SWEP.AttackTime = 0.35
SWEP.AnimTime1 = 2.15
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.23
SWEP.AnimTime2 = 1.5
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 115

SWEP.weaponPos = Vector(1,0,0.5)
SWEP.weaponAng = Angle(0,0,1)
SWEP.modelscale = 1

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 9
SWEP.DamageSecondary = 8

SWEP.PenetrationPrimary = 2.5
SWEP.PenetrationSecondary = 2

SWEP.BlockTier = 0
SWEP.MaxPenLen = 5

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 15
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 50
SWEP.AttackLen2 = 45

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "melee_miss_01",
    ["attack2"] = "melee_miss_02",
    ["holster"] = "holster",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/watermelon.png")
	SWEP.IconOverride = "melgun/watermelon.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.AttackHit = "physics/flesh/flesh_squishy_impact_hard1.wav"
SWEP.Attack2Hit = "physics/flesh/flesh_squishy_impact_hard2.wav"
SWEP.AttackHitFlesh = "physics/flesh/flesh_squishy_impact_hard3.wav"
SWEP.Attack2HitFlesh = "physics/flesh/flesh_squishy_impact_hard4.wav"
SWEP.DeploySnd = "physics/flesh/flesh_squishy_impact_hard1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.BlockHoldPos = Vector(-7.5,1,10)
SWEP.BlockHoldAng = Angle(18, 15, -20)

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.BreakBoneMul = 0
SWEP.PainMultiplier = 1

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
SWEP.HeavyAttackDamageMul = 1.0
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
    "physics/flesh/flesh_squishy_impact_hard1.wav",
    "physics/flesh/flesh_squishy_impact_hard2.wav",
    "physics/flesh/flesh_squishy_impact_hard3.wav",
    "physics/flesh/flesh_squishy_impact_hard4.wav",
}

function SWEP:GetRandomCinderHitSound()
    return self.CinderHitSounds[math.random(#self.CinderHitSounds)]
end

local MELON_CHUNKS = {
    "models/props_junk/watermelon01_chunk01a.mdl",
    "models/props_junk/watermelon01_chunk01b.mdl",
    "models/props_junk/watermelon01_chunk01c.mdl",
    "models/props_junk/watermelon01_chunk02a.mdl",
    "models/props_junk/watermelon01_chunk02b.mdl",
    "models/props_junk/watermelon01_chunk02c.mdl",
}

SWEP.MelonMinHits = 1
SWEP.MelonMaxHits = 2
SWEP.MelonBreakSound = "physics/flesh/flesh_bloody_break.wav"
SWEP.MelonJuiceDecal = "Blood"

local MELON_BREAK_SOUND = SWEP.MelonBreakSound
local MELON_DECAL = SWEP.MelonJuiceDecal
local THROW_DAMAGE = 12
local THROW_SPEED = 1100

function SWEP:InitAdd()
    for _, mdl in ipairs(MELON_CHUNKS) do
        util.PrecacheModel(mdl)
    end
end

local function CreateChunk(model, pos)
    local chunk = ents.Create("prop_physics")
    if not IsValid(chunk) then return end

    chunk:SetModel(model)
    chunk:SetPos(pos)
    chunk:SetAngles(AngleRand(-90, 90))
    chunk:Spawn()
    chunk:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = chunk:GetPhysicsObject()
    if IsValid(phys) then
        phys:AddVelocity(VectorRand(-150, 150))
        phys:Wake()
    end

    SafeRemoveEntityDelayed(chunk, 20)
end

local function IsSoft(ent)
    if not IsValid(ent) then return false end
    if ent:IsPlayer() or ent:IsNPC() or ent:IsRagdoll() then return true end

    local owner = hg and hg.RagdollOwner and hg.RagdollOwner(ent)
    return IsValid(owner)
end

local function SplashJuice(pos, normal)
    for i = 1, 8 do
        local offset = VectorRand() * 10
        util.Decal(MELON_DECAL, pos + normal * 8 + offset, pos - normal * 8 + offset)
    end
end

local function BreakMelonAt(hitpos, normal, target)
    local pos = hitpos + normal * 4

    for _, mdl in ipairs(MELON_CHUNKS) do
        CreateChunk(mdl, pos + VectorRand() * 3)
    end

    sound.Play(MELON_BREAK_SOUND, pos, 75, math.random(90, 110))

    if IsSoft(target) then
        SplashJuice(hitpos, normal)
    end
end

function SWEP:BreakMelon(ent, trace)
    if not SERVER or self.MelonBroken then return end
    self.MelonBroken = true

    local owner = self:GetOwner()
    local normal = trace and trace.HitNormal or vector_up
    local hitpos = trace and trace.HitPos or (IsValid(owner) and owner:EyePos() or self:GetPos())

    BreakMelonAt(hitpos, normal, ent)

    timer.Simple(0, function()
        if IsValid(owner) then owner:SelectWeapon("weapon_hands_sh") end
        if IsValid(self) then self:Remove() end
    end)
end

function SWEP:RegisterMelonHit(ent, trace)
    if not SERVER or self.MelonBroken then return end

    if (self.nextMelonHit or 0) > CurTime() then return end
    self.nextMelonHit = CurTime() + 0.6

    self.MelonHitsLeft = self.MelonHitsLeft or math.random(self.MelonMinHits, self.MelonMaxHits)
    self.MelonHitsLeft = self.MelonHitsLeft - 1

    if self.MelonHitsLeft <= 0 then
        self:BreakMelon(ent, trace)
    end
end

function SWEP:CustomAttack2()
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
    ent.damage = THROW_DAMAGE
    ent.MaxSpeed = THROW_SPEED
    ent.DamageType = DMG_CLUB
    ent.AttackHit = "physics/flesh/flesh_squishy_impact_hard1.wav"
    ent.AttackHitFlesh = "physics/flesh/flesh_squishy_impact_hard3.wav"
    ent.noStuck = true

    ent.func = function(data)
        if ent.removed then return end
        if (ent.nextImpact or 0) > CurTime() then return end
        ent.nextImpact = CurTime() + 0.2

        if math.random(1, 2) == 2 then
            ent.removed = true

            local pos = data and data.HitPos or ent:GetPos()
            local normal = data and data.HitNormal or vector_up
            local target = data and data.HitEntity

            timer.Simple(0, function()
                if not IsValid(ent) then return end
                BreakMelonAt(pos, normal, target)
                ent:Remove()
            end)
        else
            ent:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", 70, math.random(95, 105))
        end
    end

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(VectorRand() * 500)
    end

    ply:ViewPunch(Angle(0, 0, -8))
    ply:SelectWeapon("weapon_hands_sh")

    self:Remove()

    return true
end

function SWEP:PrimaryAttackAdd(ent, trace)
    if SERVER and IsValid(ent) and self:IsEntSoft(ent) then
        local owner = self:GetOwner()
        if IsValid(owner) then
            owner:EmitSound(self:GetRandomCinderHitSound(), 50, math.random(95,105))
        end
    end

    self:RegisterMelonHit(ent, trace)
end

function SWEP:SecondaryAttackAdd(ent, trace)
    if SERVER and IsValid(ent) and self:IsEntSoft(ent) then
        local owner = self:GetOwner()
        if IsValid(owner) then
            owner:EmitSound(self:GetRandomCinderHitSound(), 50, math.random(95,105))
        end
    end

    self:RegisterMelonHit(ent, trace)
end

local MELON_MODEL = "models/props_junk/watermelon01.mdl"
local MELON_CLASS = string.StripExtension(string.GetFileFromFilename(debug.getinfo(1, "S").short_src))
local MELON_NAME = SWEP.PrintName

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end
        if string.lower(ent:GetModel() or "") ~= MELON_MODEL then return false end

        if (ply.NextMelonPickup or 0) > CurTime() then return false end
        ply.NextMelonPickup = CurTime() + 0.5

        if ply:HasWeapon(MELON_CLASS) then return false end

        local wep = ply:Give(MELON_CLASS)
        if not IsValid(wep) then return false end

        ent:Remove()
        ply:SelectWeapon(MELON_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_MelonPickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_MelonPickupKey", function(ply, key)
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
    local melonHint

    hook.Add("Think", "HG_MelonHint", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() or not hg or not hg.eyeTrace then return end

        local tr = hg.eyeTrace(lply)
        if not tr then return end

        local ent = tr.Entity
        if not IsValid(ent) or ent.HudHintMarkup then return end
        if ent:GetClass() ~= "prop_physics" or string.lower(ent:GetModel() or "") ~= MELON_MODEL then return end

        if not melonHint then
            local key = string.upper(input.LookupBinding("+use") or "E")
            melonHint = markup.Parse(
                "<font=ZCity_Tiny>" .. MELON_NAME .. "\n<colour=170,170,170>Melee weapon - press " .. key .. " to pick up</colour></font>",
                500
            )
        end

        ent.HudHintMarkup = melonHint
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
