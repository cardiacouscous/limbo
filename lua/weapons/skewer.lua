-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Skewer"
SWEP.Instructions = "A sharp cooking skewer built for roasting meat and veggies. In a pinch, it functions like a basic dagger."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/rshk/skewer.mdl"
SWEP.WorldModelReal = "models/zac/c_kitchenknife.mdl"
SWEP.WorldModelExchange = "models/rshk/skewer.mdl"

SWEP.SuicidePos = Vector(-6, -2, -12)
SWEP.SuicideAng = Angle(-30, 0, 0)
SWEP.SuicideCutVec = Vector(-1, 0, -3)
SWEP.SuicideCutAng = Angle(0, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.CanSuicide = true
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)

SWEP.basebone = 39


SWEP.weaponPos = Vector(-0.5,1,-3)
SWEP.weaponAng = Angle(70,100,100)

SWEP.BreakBoneMul = 0.35

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "attack_stab",
    ["attack2"] = "attack",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/skewer.png")
	SWEP.IconOverride = "melgun/skewer.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true

SWEP.HoldType = "knife"

SWEP.DeploySnd = ""

SWEP.AttackHit = "weapons/knife/knife_hitwall1.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"


SWEP.AttackPos = Vector(0,0,0)
SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 16

SWEP.PenetrationPrimary = 4
SWEP.PenetrationSecondary = 3
SWEP.BleedMultiplier = 3

SWEP.MaxPenLen = 3

SWEP.PainMultiplier = 1.3

SWEP.PenetrationSizePrimary = 1.5
SWEP.PenetrationSizeSecondary = 1

SWEP.StaminaPrimary = 10
SWEP.StaminaSecondary = 10

SWEP.AttackLen1 = 55
SWEP.AttackLen2 = 35



function SWEP:CanPrimaryAttack()
    return true
end

function SWEP:CanSecondaryAttack()
    return true
end


SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 80
SWEP.AttackRads2 = 55

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = false
SWEP.MultiDmg2 = true

SWEP.BlockHoldPos = Vector(-9.5, 15, -0.95)
SWEP.BlockHoldAng = Angle(-5, 0, -45)
SWEP.BlockSound = "physics/metal/metal_solid_impact_bullet3.wav"

-- IED defusing functionality
function SWEP:PrimaryAttackAdd(ent, trace)
	if not SERVER then return end
	if not IsValid(ent) then return end
	
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	
	-- Check if hitting an IED weapon
	if ent:GetClass() == "weapon_traitor_ied" and ent.OnDefuseHit then
		ent:OnDefuseHit(owner)
		return
	end
	
	-- Check if hitting a planted IED bomb (cardboard box model)
	if ent:GetModel() == "models/props_junk/cardboard_jox004a.mdl" then
		-- Initialize defusing variables if not present
		if not ent.IEDDefuseHits then
			ent.IEDDefuseHits = 0
			ent.IEDDefused = false
		end
		
		if ent.IEDDefused then return end -- Already defused
		
		ent.IEDDefuseHits = ent.IEDDefuseHits + 1
		
		-- Play electric sound
		ent:EmitSound("ambient/energy/spark" .. math.random(1,6) .. ".wav", 60, math.random(90, 110))
		
		if ent.IEDDefuseHits >= 2 then
			-- Defuse the bomb
			ent.IEDDefused = true
			ent:EmitSound("ambient/energy/electric_loop.wav", 70, 80)
		end
	end
end