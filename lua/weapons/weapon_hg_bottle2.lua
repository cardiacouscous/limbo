-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Whiskey bottle"
SWEP.Instructions = "A glass beer bottle. Will break if hit too hard.\n\nLMB to attack.\nRMB to block.\nRMB + LMB to throw."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "melee"

SWEP.WorldModel = "models/props_junk/glassjug01.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_hatchet.mdl"
SWEP.WorldModelExchange = "models/props_junk/glassjug01.mdl"

SWEP.BreakBoneMul = 0.2

SWEP.HoldPos = Vector(-11,1,5)
SWEP.HoldAng = Angle(5, 0, -2)
SWEP.weaponAng = Angle(180,160,-5)
SWEP.basebone = 94
SWEP.weaponPos = Vector(0, 1, 6)
SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Attack_Quick",
}
SWEP.AnimTime1 = 1.2
SWEP.AttackTime = 0.3
SWEP.WaitTime1 = 0.9

SWEP.AttackPos = Vector(-2,-5,-10)

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/bottle2.png")
	SWEP.IconOverride = "melgun/bottle2.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.NoHolster = true

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 10

SWEP.PenetrationPrimary = 1.3

SWEP.MaxPenLen = 1.5

SWEP.PainMultiplier = 0.45

SWEP.PenetrationSizePrimary = 0.8

SWEP.StaminaPrimary = 8

SWEP.AttackLen1 = 45

SWEP.AttackHit = "GlassBottle.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "GlassBottle.ImpactSoft"

function SWEP:CustomAttack2()
    local ent = ents.Create("ent_throwable")
    ent.WorldModel = self.WorldModelExchange or self.WorldModel

    local ply = self:GetOwner()

    ent:SetPos(select(1, hg.eye(ply,60,hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
    ent:SetAngles(ply:EyeAngles())
    ent:SetOwner(self:GetOwner())
    ent:Spawn()

    ent.localshit = Vector(0,0,0)
    ent.wep = self:GetClass()
    ent.owner = ply
    ent.damage = 13
    ent.MaxSpeed = 1300
    ent.DamageType = DMG_CLUB
    ent.AttackHit = "GlassBottle.ImpactHard"
    ent.AttackHitFlesh = "GlassBottle.ImpactHard"
    ent:PrecacheGibs()

    ent.func = function(data)
        if ent.removed then return end
        ent.removed = true
        timer.Simple(0, function()
            ent:GibBreakServer(vector_origin)
            ent:EmitSound("physics/glass/glass_pottery_break"..math.random(1,4)..".wav")
            ent:Remove()
        end)
    end

    ent.noStuck = true

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(VectorRand() * 500)
    end

    //ply:EmitSound("weapons/slam/throw.wav",50,math.random(95,105))
    ply:ViewPunch(Angle(0, 0, -8))
    ply:SelectWeapon("weapon_hands_sh")

    self:Remove()

    return true
end

local JUG_CHUNKS = {
	"models/props_junk/glassjug01_chunk01.mdl",
	"models/props_junk/glassjug01_chunk03.mdl",
}

function SWEP:CreateBottle(pos)
	for _, mdl in ipairs(JUG_CHUNKS) do
		local chunk = ents.Create("prop_physics")
		if IsValid(chunk) then
			chunk:SetPos(pos)
			chunk:SetAngles(AngleRand(-90, 90))
			chunk:SetModel(mdl)
			chunk:Spawn()
			chunk:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			local phys = chunk:GetPhysicsObject()
			if IsValid(phys) then
				phys:AddVelocity(VectorRand(-90, 90))
				phys:Wake()
			end
			SafeRemoveEntityDelayed(chunk, 15)
		end
	end
end

function SWEP:PrimaryAttackAdd(ent,trace)
    if ent and math.random(1, 2) == 2 then
		self:CreateBottle(trace.HitPos)

		local owner = self:GetOwner()
		owner:EmitSound("physics/glass/glass_pottery_break"..math.random(1,4)..".wav")
        owner:Give("weapon_hg_bottlebroken2")
        owner:SelectWeapon("weapon_hg_bottlebroken2")
        self:Remove()
    end
end

function SWEP:CanSecondaryAttack()
    return true
end

function SWEP:SecondaryAttackAdd(ent,trace)
    if ent and math.random(1, 2) == 2 then
        self:CreateBottle(trace.HitPos)

		local owner = self:GetOwner()
		owner:EmitSound("physics/glass/glass_pottery_break"..math.random(1,4)..".wav")
        owner:Give("weapon_hg_bottlebroken2")
        owner:SelectWeapon("weapon_hg_bottlebroken2")
        self:Remove()
    end
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 65
SWEP.AttackRads2 = 0

SWEP.SwingAng = -85
SWEP.SwingAng2 = 0

local JUG_MODEL = "models/props_junk/glassjug01.mdl"
local JUG_CLASS = "weapon_hg_bottle2"

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end
        if string.lower(ent:GetModel() or "") ~= JUG_MODEL then return false end

        if (ply.NextJugPickup or 0) > CurTime() then return false end
        ply.NextJugPickup = CurTime() + 0.5

        if ply:HasWeapon(JUG_CLASS) then return false end

        local wep = ply:Give(JUG_CLASS)
        if not IsValid(wep) then return false end

        ent:Remove()
        ply:SelectWeapon(JUG_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_JugPickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_JugPickupKey", function(ply, key)
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
--//
