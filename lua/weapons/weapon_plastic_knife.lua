-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Plastic knife"
SWEP.Instructions = "A plastic knife, affordable cutting tool made from plastic.\n\nLMB to attack.\nR + LMB to change attack mode.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/w_plastix_bicax.mdl"
SWEP.WorldModelReal = "models/weapons/salat/reanim/c_s&wch0014.mdl"
SWEP.WorldModelExchange = "models/weapons/w_plastix_bicax.mdl"

SWEP.HoldPos = Vector(-4,0,-1)
SWEP.HoldAng = Angle(0,0,0)

SWEP.SuicidePos = Vector(-10, 5, -7)
SWEP.SuicideAng = Angle(-30, 0, 0)
SWEP.SuicideCutVec = Vector(-1, -5, 1)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.CanSuicide = true
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)

SWEP.BreakBoneMul = 0.2

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "stab",
    ["attack2"] = "midslash1",
    ["duct_cut"] = "cut",
    ["inspect"] = "inspect"
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/plastick.png")
	SWEP.IconOverride = "melgun/plastick.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.AttackHit = "physics/plastic/plastic_box_impact_soft1.wav"
SWEP.Attack2Hit = "physics/plastic/plastic_box_impact_soft1.wav"
SWEP.AttackHitFlesh = "physics/plastic/plastic_box_impact_soft2.wav"
SWEP.Attack2HitFlesh = "physics/plastic/plastic_box_impact_soft2.wav"
SWEP.DeploySnd = "physics/plastic/plastic_box_impact_soft2.wav"

SWEP.basebone = 39
SWEP.weaponPos = Vector(4.1,-2,-0.1)
SWEP.weaponAng = Angle(0,162,90)

SWEP.AttackPos = Vector(0,0,0)
SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 0.2
SWEP.DamageSecondary = 0.1

SWEP.PenetrationPrimary = 0
SWEP.PenetrationSecondary = 0
SWEP.BleedMultiplier = -1

SWEP.MaxPenLen = 0

SWEP.PainMultiplier = 0.3

SWEP.PenetrationSizePrimary = 1.5
SWEP.PenetrationSizeSecondary = 1

SWEP.StaminaPrimary = 2
SWEP.StaminaSecondary = 1

SWEP.AttackLen1 = 42
SWEP.AttackLen2 = 35

function SWEP:Reload()
    if SERVER then
        if self:GetOwner():KeyPressed(IN_ATTACK) then
            self:SetNetVar("mode", not self:GetNetVar("mode"))
            self:GetOwner():ChatPrint("Changed mode to "..(self:GetNetVar("mode") and "slash." or "stab."))
        end
    end
end

function SWEP:CanPrimaryAttack()
    if self:GetOwner():KeyDown(IN_RELOAD) then return end
    if not self:GetNetVar("mode") then
        return true
    else
        self.allowsec = true
        self:SecondaryAttack(true)
        self.allowsec = nil
        return false
    end
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    local check = self:GetBlocking() and self:GetWM():GetSequenceName(self:GetWM():GetSequence()) != "cut"
    addPosLerp.z = addPosLerp.z + (check and 2 or 0)
    addPosLerp.x = addPosLerp.x + (check and 0 or 0)
    addPosLerp.y = addPosLerp.y + (check and 3 or 0)
    addAngLerp.r = addAngLerp.r + (check and -15 or 0)
    addAngLerp.y = addAngLerp.y + (check and 8 or 0)
    
    return true
end

function SWEP:CanSecondaryAttack()
    return self.allowsec and true or false
end

SWEP.AttackPos = Vector(0,0,0)
SWEP.AttackingPos = Vector(0,0,0)

SWEP.AttackTime = 0.2
SWEP.AnimTime1 = 0.8
SWEP.WaitTime1 = 0.5

SWEP.Attack2Time = 0.1
SWEP.AnimTime2 = 0.5
SWEP.WaitTime2 = 0.4

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 3
SWEP.AttackRads2 = 55

SWEP.SwingAng = 90
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = false
SWEP.MultiDmg2 = true

SWEP.SuicideStageDrop = 8
SWEP.SuicideStageBleed = 15
SWEP.SuicideStageFull = 30

function SWEP:SuicideFunc()
    local owner = self:GetOwner()
    local org = owner.organism
    if not org then return end

    self.SuicideCount = (self.SuicideCount or 0) + 1 -- счётчик хранится на самом ноже
    local count = self.SuicideCount

    local ent = hg.GetCurrentCharacter(owner)
    local bone = ent:LookupBone("ValveBiped.Bip01_Neck1")
    local ang = ent:GetBoneMatrix(bone):GetAngles()
    local _, ang = LocalToWorld(vector_origin, Angle(0, -60, 0), vector_origin, ang)

    owner:EmitSound(self.SuicideSound or self.Attack2HitFlesh, 50)

    if count < self.SuicideStageDrop then
        return
    end

    if count < self.SuicideStageBleed then
        hg.organism.AddWoundManual(owner, 3, VectorRand(-1, 1), ang, "ValveBiped.Bip01_Neck1", CurTime())
        return
    end

    if count < self.SuicideStageFull then
        local t = (count - self.SuicideStageBleed) / (self.SuicideStageFull - 1 - self.SuicideStageBleed)
        local wounds = 3 + math.floor(t * 2)
        local size = Lerp(t, 15, 40)

        for i = 1, wounds do
            hg.organism.AddWoundManual(owner, size, VectorRand(-2, 2), ang, "ValveBiped.Bip01_Neck1", CurTime() + math.Rand(0, 1))
        end
        return
    end

    local dmgInfo = DamageInfo()
    dmgInfo:SetDamageType(DMG_SLASH)

    hg.organism.input_list["arteria"](org, 0, 5, dmgInfo, nil, -ang:Forward())

    for i = 1, 5 do
        hg.organism.AddWoundManual(owner, 50, VectorRand(-2, 2), ang, "ValveBiped.Bip01_Neck1", CurTime() + math.Rand(0, 2))
    end

    owner:AddNaturalAdrenaline(math.max(2 - org.adrenaline, 0))
    org.fear = math.max(org.fear, 1)

    hook.Run("HomigradDamage", owner, dmgInfo, HITGROUP_HEAD, hg.GetCurrentCharacter(org.owner), 15)
end

