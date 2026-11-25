-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Chair"
SWEP.Instructions = "A wooden chair. Breaks after a number of hits.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

local CHAIR_MODEL  = "models/props_c17/furniturechair001a.mdl"
local CHAIR_CLASS  = "weapon_hg_chair" 
local BROKEN_CLASS = "weapon_hg_chairbroken"

SWEP.Weight = 0
SWEP.WorldModel = CHAIR_MODEL
SWEP.WorldModelExchange = CHAIR_MODEL
SWEP.WorldModelReal = "models/viper/mw/weapons/v_cinderblock.mdl"
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

SWEP.weaponPos = Vector(8,-1,9)
SWEP.weaponAng = Angle(190,-180,9)
SWEP.modelscale = 0.9

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 16
SWEP.DamageSecondary = 9

SWEP.PenetrationPrimary = 2.5
SWEP.PenetrationSecondary = 2

SWEP.BlockTier = 3
SWEP.MaxPenLen = 5

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 20
SWEP.StaminaSecondary = 12

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
	SWEP.WepSelectIcon = Material("melgun/chair.png")
	SWEP.IconOverride = "melgun/chair.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.AttackHit = "physics/wood/wood_plank_impact_hard1.wav"
SWEP.Attack2Hit = "physics/wood/wood_box_impact_hard1.wav"
SWEP.AttackHitFlesh = "physics/wood/wood_box_impact_hard1.wav"
SWEP.Attack2HitFlesh = "physics/wood/wood_box_impact_hard1.wav"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft1.wav"


SWEP.AttackPos = Vector(0,0,0)


SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.BlockHoldPos = Vector(-7.5,1,10)
SWEP.BlockHoldAng = Angle(18, 15, -20)

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.BreakBoneMul = 0.9
SWEP.PainMultiplier = 1.3

SWEP.SwingAng = -30
SWEP.SwingAng2 = 0

SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis" 
SWEP.holsteredPos = Vector(-1.1, -9, -5.3)
SWEP.holsteredAng = Angle(195, 75, 230) 
SWEP.Concealed = false 
SWEP.HolsterIgnored = true 
SWEP.Ignorebelt = true

SWEP.ChairMaxHits = math.random(10, 15)

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
    util.PrecacheModel("models/props_c17/furniturechair001a_chunk01.mdl")
    util.PrecacheModel("models/props_c17/furniturechair001a_chunk02.mdl")
    util.PrecacheModel("models/props_c17/furniturechair001a_chunk03.mdl")
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
        phys:AddVelocity(VectorRand(-120, 120))
        phys:Wake()
    end
    SafeRemoveEntityDelayed(chunk, 30)
end

function SWEP:BreakChair(trace)
    if not SERVER or self.ChairBroken then return end
    self.ChairBroken = true

    local owner = self:GetOwner()
    local pos = trace.HitPos + (trace.HitNormal or vector_origin) * 4

    CreateChunk("models/props_c17/furniturechair001a_chunk02.mdl", pos)
    CreateChunk("models/props_c17/furniturechair001a_chunk03.mdl", pos + Vector(0, 0, 3))

    sound.Play("physics/wood/wood_furniture_break" .. math.random(1, 2) .. ".wav", pos, 75, math.random(95, 105))

    timer.Simple(0, function()
        if IsValid(owner) then
            owner:Give(BROKEN_CLASS)
            owner:SelectWeapon(BROKEN_CLASS)
        end
        if IsValid(self) then self:Remove() end
    end)
end

function SWEP:RegisterChairHit(ent, trace)
    if not SERVER then return end
    if not (trace and trace.Hit) then return end

    self.ChairHits = (self.ChairHits or 0) + 1
    if self.ChairHits >= self.ChairMaxHits then
        self:BreakChair(trace)
    end
end

function SWEP:PrimaryAttackAdd(ent, trace)
    if SERVER and IsValid(ent) and self:IsEntSoft(ent) then
        local owner = self:GetOwner()
        if IsValid(owner) then
            owner:EmitSound("physics/wood/wood_box_impact_hard1.wav", 50, math.random(95,105))
        end
    end
    self:RegisterChairHit(ent, trace)
end

function SWEP:SecondaryAttackAdd(ent, trace)
    if SERVER and IsValid(ent) and self:IsEntSoft(ent) then
        local owner = self:GetOwner()
        if IsValid(owner) then
            owner:EmitSound(self:GetRandomCinderHitSound(), 50, math.random(95,105))
        end
    end
    self:RegisterChairHit(ent, trace)
end

local PICKUP_NEEDS_ALT = true

if SERVER then
    hook.Add("PlayerUse", "HG_ChairPickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if not IsValid(ent) or ent:GetClass() ~= "prop_physics" then return end
        if string.lower(ent:GetModel() or "") ~= CHAIR_MODEL then return end
        if PICKUP_NEEDS_ALT and not ply:KeyDown(IN_WALK) then return end

        if (ply.NextChairPickup or 0) > CurTime() then return false end
        ply.NextChairPickup = CurTime() + 0.5

        if ply:HasWeapon(CHAIR_CLASS) then return false end

        local wep = ply:Give(CHAIR_CLASS)
        if IsValid(wep) then
            ent:Remove()
            ply:SelectWeapon(CHAIR_CLASS)
        end

        return false
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
