-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Wheelbarrow"
SWEP.Instructions = "A wheelbarrow. Hold it with both hands and run into people to knock them down.\n\nE on a wheelbarrow prop to grab it."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

local WB_MODEL = "models/props_junk/wheebarrow01a.mdl"

SWEP.Weight = 0
SWEP.WorldModel = "models/props_junk/wheebarrow01a.mdl"
SWEP.WorldModelExchange = "models/props_junk/wheebarrow01a.mdl"
SWEP.WorldModelReal = "models/weapons/wee/mw/weapons/v_wheelbarrow.mdl"
SWEP.ViewModel = "models/props_junk/wheebarrow01a.mdl"

SWEP.HoldType = "duel"

SWEP.HoldPos = Vector(0,1,0)
SWEP.HoldAng = Angle(-10,5,-5.5)

SWEP.AttackTime = 0.45
SWEP.AnimTime1 = 2.15
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 2
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(0,0,0)

SWEP.basebone = 115

SWEP.weaponPos = Vector(19, -3, -40)
SWEP.weaponAng = Angle(25, 0, 0)
SWEP.HeldScale = 1
SWEP.modelscale = 1

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 10
SWEP.DamageSecondary = 8

SWEP.PenetrationPrimary = 2
SWEP.PenetrationSecondary = 2

SWEP.BlockTier = 3
SWEP.MaxPenLen = 5

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 10
SWEP.StaminaSecondary = 10

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
	SWEP.WepSelectIcon = Material("melgun/Wheel.png")
	SWEP.IconOverride = "melgun/Wheel.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "physics/metal/metal_barrel_impact_hard1.wav"
SWEP.Attack2Hit = "physics/metal/metal_barrel_impact_hard2.wav"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/metal/metal_barrel_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.BlockHoldPos = Vector(-7.5,1,10)
SWEP.BlockHoldAng = Angle(18, 15, -20)

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.BreakBoneMul = 0.6
SWEP.PainMultiplier = 1.2

SWEP.SwingAng = -30
SWEP.SwingAng2 = 0

SWEP.NoHolster = true
SWEP.MouseSensitivity = 0.45

if CLIENT then
    function SWEP:AdjustMouseSensitivity()
        return self.MouseSensitivity
    end
end

function SWEP:CanPrimaryAttack() return false end
function SWEP:CanSecondaryAttack() return false end

SWEP.IsWheelbarrow = true

SWEP.RamMinSpeed = 170
SWEP.RamDamage = 28
SWEP.RamPush = 420
SWEP.RamStun = 2
SWEP.RamCooldown = 1.2

SWEP.WheelSound = "physics/metal/metal_box_scrape_smooth_loop1.wav"

function SWEP:GetWorldModelExchange()
    self.modelscale = IsValid(self:GetOwner()) and self.HeldScale or 1
    return WB_MODEL
end

function SWEP:ModelAnimAdd(model, pos, ang)
    local owner = self:GetOwner()
    if not IsValid(owner) then return pos, ang end

    local speed = owner:GetVelocity():Length2D()

    self.WBSway = Lerp(math.min(FrameTime() * 8, 1), self.WBSway or 0, math.Clamp(speed / 250, 0, 1))
    local s = self.WBSway
    local t = CurTime() * 9

    pos = pos + ang:Up() * (math.abs(math.sin(t)) * 0.8 * s)
    ang:RotateAroundAxis(ang:Forward(), math.sin(t) * 3 * s)
    ang:RotateAroundAxis(ang:Right(), math.sin(t * 2) * 1.5 * s)

    if CLIENT then
        local currentYaw = owner:EyeAngles().y
        self.LastYaw = self.LastYaw or currentYaw
        local diff = math.AngleDifference(currentYaw, self.LastYaw)
        self.LastYaw = currentYaw

        self.TurnInertia = Lerp(FrameTime() * 10, self.TurnInertia or 0, diff)

        pos = pos - ang:Right() * (self.TurnInertia * 0.4)
        ang:RotateAroundAxis(ang:Up(), self.TurnInertia * 1.2)
    end

    return pos, ang
end

if SERVER then
        local wheelSounds = {}

        local function Holding(wep)
            local owner = wep:GetOwner()
            return IsValid(owner) and owner:IsPlayer() and owner:Alive()
                and owner:GetActiveWeapon() == wep and not IsValid(owner.FakeRagdoll)
        end

        function SWEP:StopWheelSound()
            local snd = wheelSounds[self]
            if snd then
                snd:Stop()
                wheelSounds[self] = nil
            end
        end

        hook.Add("Think", "HG_WheelbarrowSoundGuard", function()
            for wep, snd in pairs(wheelSounds) do
                if not IsValid(wep) then
                    snd:Stop()
                    wheelSounds[wep] = nil
                elseif not Holding(wep) then
                    wep:StopWheelSound()
                end
            end
        end)

        local function PushRagdoll(target, vel)
            local rag = target.FakeRagdoll
            if not IsValid(rag) then return end

            for i = 0, rag:GetPhysicsObjectCount() - 1 do
                local phys = rag:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    phys:Wake()
                    phys:SetVelocity(vel)
                end
            end
        end

        function SWEP:Ram(owner, dir, speed)
            local start = owner:GetPos() + vector_up * 20
            local tr = util.TraceHull({
                start = start,
                endpos = start + dir * 55,
                mins = Vector(-20, -20, -10),
                maxs = Vector(20, 20, 45),
                filter = {owner, self},
            })

            local target = tr.Entity
            if not IsValid(target) or target == owner then return end
            if not (target:IsPlayer() or target:IsNPC()) then return end
            if target:IsPlayer() and not target:Alive() then return end
            if (target.WBRamCD or 0) > CurTime() then return end
            target.WBRamCD = CurTime() + self.RamCooldown

            local push = dir * self.RamPush + vector_up * 150

            local dmg = DamageInfo()
            dmg:SetAttacker(owner)
            dmg:SetInflictor(self)
            dmg:SetDamage(self.RamDamage)
            dmg:SetDamageType(DMG_CRUSH)
            dmg:SetDamagePosition(tr.HitPos)
            dmg:SetDamageForce(push)
            target:TakeDamageInfo(dmg)

            if target:IsPlayer() then
                if hg and hg.LightStunPlayer then hg.LightStunPlayer(target, self.RamStun) end
                target:SetVelocity(push)
                timer.Simple(0.05, function()
                    if IsValid(target) then PushRagdoll(target, push) end
                end)
            else
                target:SetVelocity(push)
            end

            target:EmitSound("physics/metal/metal_barrel_impact_hard" .. math.random(1, 3) .. ".wav", 70, math.random(90, 110))

            owner:SetVelocity(-owner:GetVelocity() * 0.35)
        end

        function SWEP:WheelThink()
            local owner = self:GetOwner()

            if not Holding(self) then
                self:StopWheelSound()
                return
            end

            local vel = owner:GetVelocity()
            local speed = vel:Length2D()
            local moving = owner:OnGround() and speed > 40

            if moving then
                local snd = wheelSounds[self]
                if not snd then
                    snd = CreateSound(owner, self.WheelSound)
                    snd:PlayEx(0, 80)
                    wheelSounds[self] = snd
                end

                local f = math.Clamp(speed / 250, 0, 1)
                snd:ChangeVolume(f * 0.8, 0.1)
                snd:ChangePitch(70 + f * 60, 0.1)
            else
                self:StopWheelSound()
            end

            if owner:OnGround() and speed >= self.RamMinSpeed then
                local dir = vel
                dir.z = 0
                dir:Normalize()
                self:Ram(owner, dir, speed)
            end
        end

        function SWEP:Think()
            self.BaseClass.Think(self)
            self:WheelThink()
        end

        function SWEP:OnRemove()
            self:StopWheelSound()
            if self.BaseClass and self.BaseClass.OnRemove then
                self.BaseClass.OnRemove(self)
            end
        end

        function SWEP:OwnerChanged()
            self:StopWheelSound()
            if self.BaseClass and self.BaseClass.OwnerChanged then
                self.BaseClass.OwnerChanged(self)
            end
        end

        function SWEP:OnDrop()
            self:StopWheelSound()
        end
end

local WB_CLASS = string.StripExtension(string.GetFileFromFilename(debug.getinfo(1, "S").short_src))
local WB_NAME = SWEP.PrintName

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end
        if string.lower(ent:GetModel() or "") ~= WB_MODEL then return false end

        if (ply.NextWheelbarrowPickup or 0) > CurTime() then return false end
        ply.NextWheelbarrowPickup = CurTime() + 0.5

        if ply:HasWeapon(WB_CLASS) then return false end

        local wep = ply:Give(WB_CLASS)
        if not IsValid(wep) then return false end

        ent:Remove()
        ply:SelectWeapon(WB_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_WheelbarrowPickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_WheelbarrowPickupKey", function(ply, key)
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
    local wbHint

    hook.Add("Think", "HG_WheelbarrowHint", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() or not hg or not hg.eyeTrace then return end

        local tr = hg.eyeTrace(lply)
        if not tr then return end

        local ent = tr.Entity
        if not IsValid(ent) or ent.HudHintMarkup then return end
        if ent:GetClass() ~= "prop_physics" or string.lower(ent:GetModel() or "") ~= WB_MODEL then return end

        if not wbHint then
            local key = string.upper(input.LookupBinding("+use") or "E")
            wbHint = markup.Parse(
                "<font=ZCity_Tiny>" .. WB_NAME .. "\n<colour=170,170,170>Press " .. key .. " to grab it with both hands</colour></font>",
                500
            )
        end

        ent.HudHintMarkup = wbHint
    end)

    hook.Add("CreateMove", "HG_WheelbarrowLockPitch", function(cmd)
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() or IsValid(ply.FakeRagdoll) then return end

        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not wep.IsWheelbarrow then return end

        local ang = cmd:GetViewAngles()
        ang.p = 0
        cmd:SetViewAngles(ang)
    end)
end
