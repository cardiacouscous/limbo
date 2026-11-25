-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Old Lead Pipe"
SWEP.Instructions = "The old, rusty lead pipe breaks after a couple of hits.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/slusher/pipe/w_pipe.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_pipe_lead.mdl"
SWEP.WorldModelExchange = "models/slusher/pipe/w_pipe.mdl"
SWEP.ViewModel = ""

SWEP.bloodID = 3

SWEP.HoldType = "melee"
SWEP.weight = 1.5

SWEP.HoldPos = Vector(-13,0,0)
SWEP.HoldAng = Angle(0,0,0)

SWEP.AttackTime = 0.35
SWEP.AnimTime1 = 1.3
SWEP.WaitTime1 = 0.95
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,-3)
SWEP.weaponAng = Angle(0,100,0)

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/Old_lead.png")
	SWEP.IconOverride = "melgun/Old_lead.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/wood/wood_plank_impact_soft2.wav"
SWEP.BreakSnd = "Plastic_Barrel.Break"

SWEP.AttackPos = Vector(0,0,0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 15
SWEP.DamageSecondary = 9

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 3

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 25
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 55
SWEP.AttackLen2 = 30

SWEP.NoHolster = true

function SWEP:CanSecondaryAttack()
    return false
end

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 85
SWEP.AttackRads2 = 0

SWEP.SwingAng = 180
SWEP.SwingAng2 = 0

SWEP.MinSensivity = 0.5

SWEP.HitsPerLevel = 3
SWEP.BodyGroups = {[0] = 0}

function SWEP:InitAdd()
	self.Hits = self.HitsPerLevel * 4
	if SERVER then
		self:SetNWInt("PipeHits", self.Hits)
	end
	self.BodyGroups = {[0] = 0}
	self:SetBodygroup(0, 0)
end

function SWEP:GetPipeHits()
	return self:GetNWInt("PipeHits", self.Hits or (self.HitsPerLevel * 4))
end

function SWEP:UpdatePipeBodygroup()
	local hits = self:GetPipeHits()
	local bg = math.Clamp(4 - math.ceil(hits / self.HitsPerLevel), 0, 3)
	self.BodyGroups = {[0] = bg}
	self:SetBodygroup(0, bg)
	if IsValid(self.worldModel2) then
		self.worldModel2:SetBodygroup(0, bg)
	end
end

function SWEP:ThinkAdd()
	self:UpdatePipeBodygroup()
end

function SWEP:HandlePipeHit()
	if not SERVER then return end
	if self.LastPipeHit and CurTime() - self.LastPipeHit < 0.25 then return end
	self.LastPipeHit = CurTime()

	local hits = self:GetPipeHits() - 1
	self.Hits = hits
	self:SetNWInt("PipeHits", hits)
	self:UpdatePipeBodygroup()

	if hits <= 0 then
		local owner = self:GetOwner()
		if IsValid(owner) then
			owner:EmitSound(self.BreakSnd, 75, 100)
			owner:SelectWeapon("weapon_hands_sh")
		else
			sound.Play(self.BreakSnd, self:GetPos(), 75, 100)
		end
		self:Remove()
	end
end

function SWEP:PrimaryAttackAdd(ent, trace)
	self:HandlePipeHit()
end

function SWEP:SecondaryAttackAdd(ent, trace)
	self:HandlePipeHit()
end

function SWEP:OnDrop()
	if self:GetPipeHits() <= 0 and SERVER then
		self:Remove()
	end
end
