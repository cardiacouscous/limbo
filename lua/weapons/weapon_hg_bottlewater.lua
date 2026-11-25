-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Water bottle"
SWEP.Instructions = "A plastic water bottle.\n\nLMB to attack.\nRMB to block.\nRMB + LMB to throw."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "melee"

SWEP.WorldModel = "models/props_junk/garbage_plasticbottle003a.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_hatchet.mdl"
SWEP.WorldModelExchange = "models/props_junk/garbage_plasticbottle003a.mdl"

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
	SWEP.WepSelectIcon = Material("melgun/plastic.png")
	SWEP.IconOverride = "melgun/plastic.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.NoHolster = true

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 2

SWEP.PenetrationPrimary = 0.3

SWEP.MaxPenLen = 0.5

SWEP.PainMultiplier = 0.10

SWEP.PenetrationSizePrimary = 0.3

SWEP.StaminaPrimary = 5

SWEP.AttackLen1 = 45

SWEP.AttackHit = "Plastic_Barrel.ImpactHard"
SWEP.AttackHitFlesh = "Plastic_Box.ImpactSoft"
SWEP.DeploySnd = "Plastic_Box.ImpactSoft"

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
    ent.damage = 2
    ent.MaxSpeed = 1300
    ent.DamageType = DMG_CLUB
    ent.AttackHit = "Plastic_Barrel.ImpactHard"
    ent.AttackHitFlesh = "Plastic_Box.ImpactSoft"

    ent.func = function(data)
        if ent.hitPlayed then return end
        ent.hitPlayed = true
        ent:EmitSound("physics/plastic/plastic_barrel_impact_hard" .. math.random(1, 3) .. ".wav")
    end

    ent.noStuck = true

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

function SWEP:CanSecondaryAttack()
    return true
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 65
SWEP.AttackRads2 = 0

SWEP.SwingAng = -85
SWEP.SwingAng2 = 0

local BOTTLE_MODEL = "models/props_junk/garbage_plasticbottle003a.mdl"
local BOTTLE_CLASS = string.StripExtension(string.GetFileFromFilename(debug.getinfo(1, "S").short_src))
local ITEM_NAME = SWEP.PrintName

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end
        if string.lower(ent:GetModel() or "") ~= BOTTLE_MODEL then return false end

        if (ply.NextPlasticBottlePickup or 0) > CurTime() then return false end
        ply.NextPlasticBottlePickup = CurTime() + 0.5

        if ply:HasWeapon(BOTTLE_CLASS) then return false end

        local wep = ply:Give(BOTTLE_CLASS)
        if not IsValid(wep) then return false end

        ent:Remove()
        ply:SelectWeapon(BOTTLE_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_PlasticBottlePickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_PlasticBottlePickupKey", function(ply, key)
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

    hook.Add("Think", "HG_PlasticBottleHint", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() or not hg or not hg.eyeTrace then return end

        local tr = hg.eyeTrace(lply)
        if not tr then return end

        local ent = tr.Entity
        if not IsValid(ent) or ent.HudHintMarkup then return end
        if ent:GetClass() ~= "prop_physics" or string.lower(ent:GetModel() or "") ~= BOTTLE_MODEL then return end

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
