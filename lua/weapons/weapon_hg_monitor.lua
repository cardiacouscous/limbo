-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Computer Monitor"
SWEP.Instructions = "An old CRT computer monitor. Cracks on the first hit and shatters after two more.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

local MONITOR_MODEL = "models/props/cs_office/computer_monitor.mdl"
local MONITOR_CRACKED = "models/props/cs_office/computer_monitor_p1.mdl"

SWEP.Weight = 0
SWEP.weight = 1.5
SWEP.WorldModel = MONITOR_MODEL
SWEP.WorldModelReal = "models/viper/mw/weapons/v_cinderblock.mdl"
SWEP.WorldModelExchange = MONITOR_MODEL
SWEP.ViewModel = ""

SWEP.HoldType = "camera"

SWEP.HoldPos = Vector(-4,2,2)

SWEP.AttackTime = 0.49
SWEP.AnimTime1 = 2.3
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 93

SWEP.weaponPos = Vector(-1,13,-5)
SWEP.weaponAng = Angle(-60,30,100)
SWEP.modelscale = 0.8,9

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 16
SWEP.DamageSecondary = 7

SWEP.PenetrationPrimary = 4
SWEP.PenetrationSecondary = 2

SWEP.MaxPenLen = 5

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 21
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 30

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "melee_miss_01",
    ["attack2"] = "melee_miss_01",
    ["holster"] = "holster",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/moneto.png")
	SWEP.IconOverride = "melgun/moneto.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.BlockTier = 2
SWEP.AttackHit = "Computer.ImpactHard"
SWEP.Attack2Hit = "Computer.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/plastic/plastic_box_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.BlockHoldPos = Vector(-15,1,7)
SWEP.BlockHoldAng = Angle(18, 15, -20)

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.BreakBoneMul = 1.0
SWEP.PainMultiplier = 1.2

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
SWEP.HeavyAttackViewPunch = Angle(5, 0, 0)
SWEP.HeavyAttackMaxChargeTime = 2.0
SWEP.HeavyAttackSwingAng = -90
SWEP.HeavyAttackRads = 95
SWEP.HeavyChargeHoldPos = Vector(6, 5, 1)

local MONITOR_GIBS_FIRST = {
    "models/props/cs_office/computer_monitor_p1a.mdl",
}

local MONITOR_GIBS_FINAL = {
    "models/props/cs_office/computer_monitor_p2a.mdl",
    "models/props/cs_office/computer_monitor_p2.mdl",
}

function SWEP:InitAdd()
    util.PrecacheModel(MONITOR_MODEL)
    util.PrecacheModel(MONITOR_CRACKED)
    for _, mdl in ipairs(MONITOR_GIBS_FIRST) do
        util.PrecacheModel(mdl)
    end
    for _, mdl in ipairs(MONITOR_GIBS_FINAL) do
        util.PrecacheModel(mdl)
    end
end

function SWEP:SetCrackedState(isCracked)
    self.IsCracked = isCracked
    local mdl = isCracked and MONITOR_CRACKED or MONITOR_MODEL
    self.WorldModel = mdl
    self.WorldModelExchange = mdl
    if SERVER then
        self:SetModel(mdl)
        self:SetNWBool("MonitorCracked", isCracked)
    end
end

if CLIENT then
    function SWEP:Think()
        if self.BaseClass and self.BaseClass.Think then
            self.BaseClass.Think(self)
        end
        local cracked = self:GetNWBool("MonitorCracked", false)
        if self.LastCrackedState ~= cracked then
            self.LastCrackedState = cracked
            local mdl = cracked and MONITOR_CRACKED or MONITOR_MODEL
            self.WorldModel = mdl
            self.WorldModelExchange = mdl
            self:SetModel(mdl)
        end
    end
end

if SERVER then
    function SWEP:SpawnMonitorGibs(pos, list)
        for _, mdl in ipairs(list) do
            local gib = ents.Create("prop_physics")
            if IsValid(gib) then
                gib:SetModel(mdl)
                gib:SetPos(pos + VectorRand() * 6)
                gib:SetAngles(AngleRand())
                gib:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                gib:Spawn()
                gib:Activate()

                local phys = gib:GetPhysicsObject()
                if IsValid(phys) then
                    phys:Wake()
                    phys:SetVelocity(Vector(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(80, 220)))
                    phys:AddAngleVelocity(VectorRand() * 300)
                end

                SafeRemoveEntityDelayed(gib, 15)
            end
        end
    end

    function SWEP:HandleMonitorHit(trace)
        if not trace or not trace.Hit then return end
        if (self.nextMonitorHit or 0) > CurTime() then return end
        self.nextMonitorHit = CurTime() + 0.45

        local pos = trace.HitPos
        local owner = self:GetOwner()

        if not self.IsCracked then
            self:SetCrackedState(true)
            self.CrackedHitsLeft = 2
            if IsValid(owner) then
                owner:EmitSound("physics/glass/glass_impact_bullet" .. math.random(1, 4) .. ".wav", 75, 100)
            end
            self:SpawnMonitorGibs(pos, MONITOR_GIBS_FIRST)
            return
        end

        self.CrackedHitsLeft = (self.CrackedHitsLeft or 2) - 1
        if self.CrackedHitsLeft <= 0 then
            if IsValid(owner) then
                owner:EmitSound("physics/glass/glass_sheet_break" .. math.random(1, 3) .. ".wav", 75, 100)
                owner:EmitSound("physics/plastic/plastic_box_break" .. math.random(1, 2) .. ".wav", 75, 100)
            end
            self:SpawnMonitorGibs(pos, MONITOR_GIBS_FINAL)
            self:Remove()
        end
    end

    function SWEP:PrimaryAttackAdd(ent, trace)
        self:HandleMonitorHit(trace)
    end

    function SWEP:SecondaryAttackAdd(ent, trace)
        self:HandleMonitorHit(trace)
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

local PICKUP_MODELS = {
    [string.lower(MONITOR_MODEL)] = false,
    [string.lower(MONITOR_CRACKED)] = true,
}
local ITEM_CLASS = string.StripExtension(string.GetFileFromFilename(debug.getinfo(1, "S").short_src))
local ITEM_NAME = SWEP.PrintName

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end

        local mdl = string.lower(ent:GetModel() or "")
        local isCrackedProp = PICKUP_MODELS[mdl]
        if isCrackedProp == nil then return false end

        if (ply.NextMonitorPickup or 0) > CurTime() then return false end
        ply.NextMonitorPickup = CurTime() + 0.5

        if ply:HasWeapon(ITEM_CLASS) then return false end

        local wep = ply:Give(ITEM_CLASS)
        if not IsValid(wep) then return false end

        if isCrackedProp then
            wep:SetCrackedState(true)
            wep.CrackedHitsLeft = 2
        end

        ent:Remove()
        ply:SelectWeapon(ITEM_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_ComputerMonitorPickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_ComputerMonitorPickupKey", function(ply, key)
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
    local crackedHint

    hook.Add("Think", "HG_ComputerMonitorHint", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() or not hg or not hg.eyeTrace then return end

        local tr = hg.eyeTrace(lply)
        if not tr then return end

        local ent = tr.Entity
        if not IsValid(ent) or ent.HudHintMarkup then return end
        if ent:GetClass() ~= "prop_physics" then return end

        local mdl = string.lower(ent:GetModel() or "")
        local isCrackedProp = PICKUP_MODELS[mdl]
        if isCrackedProp == nil then return end

        local key = string.upper(input.LookupBinding("+use") or "E")

        if isCrackedProp then
            if not crackedHint then
                crackedHint = markup.Parse(
                    "<font=ZCity_Tiny>Cracked " .. ITEM_NAME .. "\n<colour=170,170,170>Melee weapon - press " .. key .. " to pick up</colour></font>",
                    500
                )
            end
            ent.HudHintMarkup = crackedHint
        else
            if not itemHint then
                itemHint = markup.Parse(
                    "<font=ZCity_Tiny>" .. ITEM_NAME .. "\n<colour=170,170,170>Melee weapon - press " .. key .. " to pick up</colour></font>",
                    500
                )
            end
            ent.HudHintMarkup = itemHint
        end
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
