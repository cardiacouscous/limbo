-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Breen Bust"
SWEP.Instructions = "A heavy stone bust of Dr. Breen. Breaks after 5 hits.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

local BUST_MODEL = "models/props_combine/breenbust.mdl"

SWEP.Weight = 0
SWEP.weight = 2.0
SWEP.WorldModel = BUST_MODEL
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_tool_extinguisher.mdl"
SWEP.WorldModelExchange = BUST_MODEL
SWEP.ViewModel = ""

SWEP.HoldType = "camera"

SWEP.DamageType = DMG_CLUB

SWEP.HoldPos = Vector(-13,1,2)

SWEP.AttackTime = 0.49
SWEP.AnimTime1 = 1.9
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(2,3,0)

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-3)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 93

SWEP.weaponPos = Vector(-0.5,9,4)
SWEP.weaponAng = Angle(0,0,-62)
SWEP.modelscale = 0.9

SWEP.DamagePrimary = 32
SWEP.DamageSecondary = 10

SWEP.PenetrationPrimary = 4.5
SWEP.PenetrationSecondary = 2.5

SWEP.MaxPenLen = 5

SWEP.PenetrationSizePrimary = 3.5
SWEP.PenetrationSizeSecondary = 1.5

SWEP.StaminaPrimary = 30
SWEP.StaminaSecondary = 18

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
	SWEP.WepSelectIcon = Material("melgun/like/bree2.png")
	SWEP.IconOverride = "melgun/like/bree2.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.BlockTier = 2
SWEP.AttackHit = "Concrete.ImpactHard"
SWEP.Attack2Hit = "Concrete.ImpactHard"
SWEP.AttackHitFlesh = "Concrete.ImpactHard"
SWEP.Attack2HitFlesh = "Concrete.ImpactHard"
SWEP.DeploySnd = "physics/concrete/rock_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.BlockHoldPos = Vector(-15,1,7)
SWEP.BlockHoldAng = Angle(18, 15, -20)

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.BreakBoneMul = 1.8
SWEP.PainMultiplier = 2.1

SWEP.SwingAng = -30
SWEP.SwingAng2 = 0

SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis"
SWEP.holsteredPos = Vector(-1.1, -9, -5.3)
SWEP.holsteredAng = Angle(195, 75, 230)
SWEP.Concealed = false
SWEP.HolsterIgnored = true
SWEP.Ignorebelt = true

SWEP.CanHeavyAttack = true
SWEP.HeavyAttackDamageMul = 2.0
SWEP.HeavyAttackWaitTime = 1.7
SWEP.HeavyAttackAnimTimeBegin = 1.0
SWEP.HeavyAttackAnimTimeIdle = 1
SWEP.HeavyAttackAnimTimeEnd = 1.85
SWEP.HeavyAttackDelay = 0.3
SWEP.HeavyAttackTimeLength = 0.4
SWEP.HeavyAttackViewPunch = Angle(6, 0, 0)
SWEP.HeavyAttackMaxChargeTime = 2.0
SWEP.HeavyAttackSwingAng = -90
SWEP.HeavyAttackRads = 95
SWEP.HeavyChargeHoldPos = Vector(6, 5, 1)

SWEP.BustHP = 5

local BUST_CHUNKS = {
    "models/props_combine/breenbust_chunk01.mdl",
    "models/props_combine/breenbust_chunk02.mdl",
    "models/props_combine/breenbust_chunk04.mdl",
    "models/props_combine/breenbust_chunk05.mdl",
    "models/props_combine/breenbust_chunk07.mdl",
}

function SWEP:InitAdd()
    for _, mdl in ipairs(BUST_CHUNKS) do
        util.PrecacheModel(mdl)
    end
end

if SERVER then
    function SWEP:BreakBust(pos)
        for _, mdl in ipairs(BUST_CHUNKS) do
            local chunk = ents.Create("prop_physics")
            if IsValid(chunk) then
                chunk:SetModel(mdl)
                chunk:SetPos(pos + VectorRand() * 6)
                chunk:SetAngles(AngleRand())
                chunk:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                chunk:Spawn()
                chunk:Activate()

                local phys = chunk:GetPhysicsObject()
                if IsValid(phys) then
                    phys:Wake()
                    phys:SetVelocity(Vector(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(80, 220)))
                    phys:AddAngleVelocity(VectorRand() * 300)
                end

                SafeRemoveEntityDelayed(chunk, 15)
            end
        end
    end

    function SWEP:HandleBustHit(trace)
        if not trace or not trace.Hit then return end
        if (self.nextBustHit or 0) > CurTime() then return end
        self.nextBustHit = CurTime() + 0.45

        self.BustHP = (self.BustHP or 5) - 1
        if self.BustHP <= 0 then
            local pos = trace.HitPos
            local owner = self:GetOwner()
            if IsValid(owner) then
                owner:EmitSound("physics/concrete/concrete_break" .. math.random(2, 3) .. ".wav", 75, 100)
            end
            self:BreakBust(pos)
            self:Remove()
        end
    end

    function SWEP:PrimaryAttackAdd(ent, trace)
        self:HandleBustHit(trace)
    end

    function SWEP:SecondaryAttackAdd(ent, trace)
        self:HandleBustHit(trace)
    end
end

function SWEP:SecondaryAttack()
    self.BaseClass.SecondaryAttack(self)
end

function SWEP:PrimaryAttack()
    self.BaseClass.PrimaryAttack(self)
end

SWEP.NoHolster = true
SWEP.MinSensivity = 0.75

local PICKUP_MODEL = string.lower(BUST_MODEL)
local ITEM_CLASS = string.StripExtension(string.GetFileFromFilename(debug.getinfo(1, "S").short_src))
local ITEM_NAME = SWEP.PrintName

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end
        if string.lower(ent:GetModel() or "") ~= PICKUP_MODEL then return false end

        if (ply.NextBustPickup or 0) > CurTime() then return false end
        ply.NextBustPickup = CurTime() + 0.5

        if ply:HasWeapon(ITEM_CLASS) then return false end

        local wep = ply:Give(ITEM_CLASS)
        if not IsValid(wep) then return false end

        ent:Remove()
        ply:SelectWeapon(ITEM_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_BreenBustPickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_BreenBustPickupKey", function(ply, key)
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

    hook.Add("Think", "HG_BreenBustHint", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() or not hg or not hg.eyeTrace then return end

        local tr = hg.eyeTrace(lply)
        if not tr then return end

        local ent = tr.Entity
        if not IsValid(ent) or ent.HudHintMarkup then return end
        if ent:GetClass() ~= "prop_physics" or string.lower(ent:GetModel() or "") ~= PICKUP_MODEL then return end

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
