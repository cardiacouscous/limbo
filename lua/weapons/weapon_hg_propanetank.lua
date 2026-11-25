-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Propane tank"
SWEP.Instructions = "A tank of compressed propane.\n\nLMB to attack.\nR to switch to gas mode.\nIn gas mode LMB releases gas (5 sec).\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Weight = 0
SWEP.WorldModel = "models/props_junk/propane_tank001a.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_tool_extinguisher.mdl"
SWEP.WorldModelExchange = "models/props_junk/propane_tank001a.mdl"
SWEP.DontChangeDropped = false
SWEP.ViewModel = ""

SWEP.bloodID = 3

SWEP.HoldType = "revolver"

SWEP.DamageType = DMG_SLASH
SWEP.weight = 4

SWEP.HoldPos = Vector(-15,1,2)
SWEP.HoldAng = Angle()

SWEP.AttackTime = 0.45
SWEP.AnimTime1 = 1.9
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1,2,0)
SWEP.modelscale = 0.9

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 93

SWEP.weaponPos = Vector(0.7,0,0.3)
SWEP.weaponAng = Angle(-110,10,-90)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 38
SWEP.DamageSecondary = 15

SWEP.PenetrationPrimary = 6
SWEP.PenetrationSecondary = 4

SWEP.MaxPenLen = 5

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 45
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 30

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "HoseSpray",
    ["equip"] = "HoseEquip",
    ["holster"] = "HoseUnquip",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/Propanet.png")
	SWEP.IconOverride = "melgun/Propanet.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.SwingAng = -30
SWEP.SwingAng2 = 0
SWEP.NextChangeMode = 0

SWEP.GasTime = 5
SWEP.GasPush = 75
SWEP.ColdRate = 1
SWEP.GasO2Rate = 0.8
SWEP.GasSoundPitch = 95
SWEP.GasSoundPitch2 = 8000
SWEP.GasSoundLevel = 100
SWEP.GasSoundVolume = 1

local PROPANE_MODEL = "models/props_junk/propane_tank001a.mdl"
local PROPANE_CLASS = string.StripExtension(string.GetFileFromFilename(debug.getinfo(1, "S").short_src))
local PROPANE_NAME = SWEP.PrintName

local function FirstExisting(list)
    for _, path in ipairs(list) do
        if file.Exists("sound/" .. path, "GAME") then return path end
    end
end

local GAS_LOOPS = {
    {"ambient/gas/cannister_loop.wav", "ambient/gas/steam_loop1.wav"},
    {"ambient/gas/steam_loop1.wav"},
}

local OPEN_CLICK = {"physics/metal/metal_solid_impact_soft1.wav", "physics/metal/metal_barrel_impact_soft1.wav"}
local OPEN_BURST = {"ambient/machines/steam_release_1.wav", "ambient/machines/steam_release_2.wav", "ambient/gas/steam2.wav"}

function SWEP:Reload()
	if self:GetOwner():KeyPressed(IN_RELOAD) and self.NextChangeMode < CurTime() then
		if SERVER then
			self:SetNetVar("extinguishermode", not self:GetNetVar("extinguishermode"))
		end
		self:PlayAnim(self:GetNetVar("extinguishermode") and "equip" or "unequip",1,false,nil,false,true)
		self.NextChangeMode = CurTime() + 1
	end
end

hook.Add("OnNetVarSet", "AsdGuilt",function(index, key, var)
    if key == "extinguishermode" then
        local self = Entity(index)
        if not IsValid(self) or not self.AnimList then return end
        self.AnimList["deploy"] = self:GetNetVar("extinguishermode") and "HoseEquip" or "Draw"
    end
end)

function SWEP:ModelAnimAdd(model, pos, ang)
    self.CustomLerpMode = LerpFT(0.1,self.CustomLerpMode or 0, self:GetNetVar("extinguishermode") and 1 or 0)
    pos = pos + ((ang:Up() * -11 + ang:Forward() * 3 + ang:Right() * -1) * self.CustomLerpMode)
    ang:RotateAroundAxis(ang:Forward(), 7 * self.CustomLerpMode)
    ang:RotateAroundAxis(ang:Up(), 3 * self.CustomLerpMode)
    ang:RotateAroundAxis(ang:Right(), 10 * self.CustomLerpMode)

    return pos, ang
end

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    if not self.allowsec then return end

    if self:GetNWFloat("amountspray", 100) <= 0 then return end

    if CLIENT then
        self:PlayAnim("attack2",1,false,nil,false)
        self.animtime = CurTime() + CurTime() % 1
    end

    return false
end

function SWEP:CanPrimaryAttack()
    if IsValid(self:GetOwner()) and hg.KeyDown(self:GetOwner(), IN_RELOAD) then return end
    if not self:GetNetVar("extinguishermode") then
        return true
    else
        self.allowsec = true
        self:SecondaryAttack(true)
        self.allowsec = nil
        return false
    end
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    addPosLerp.z = addPosLerp.z + (self:GetBlocking() and -5 or 0)
    addPosLerp.x = addPosLerp.x + (self:GetBlocking() and 0 or 0)
    addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -5 or 0)
    addAngLerp.y = addAngLerp.y + (self:GetBlocking() and 30 or 0)
    addAngLerp.r = addAngLerp.r + (self:GetBlocking() and -60 or 0)

    return true
end

SWEP.NoHolster = true
SWEP.MinSensivity = 0.75

if CLIENT then
    function SWEP:DrawPostWorldModel()
        if not self:GetNetVar("gasflow", false) then
            if self.sound then
                self:StopLoopingSound(self.sound)
                self.sound = nil
            end
            return
        end

        if (self.nextGas or 0) > CurTime() then return end
        self.nextGas = CurTime() + 0.02

        local pos, dir
        local wm = self:GetWM()
        if not IsValid(wm) then return end

        pos = wm:GetPos()
        dir = wm:GetAngles():Forward()

        local forward_offset = 11
        local right_offset   = 6
        local up_offset      = -0.5

        pos = pos + wm:GetAngles():Forward() * forward_offset
        pos = pos + wm:GetAngles():Right() * right_offset
        pos = pos + wm:GetAngles():Up() * up_offset

        local emitter = ParticleEmitter(pos, false)
        if not IsValid(emitter) then return end

        for i = 1, 10 do
            local p = emitter:Add("particle/smokesprites_000" .. math.random(1, 4), pos)
            if p then
                p:SetVelocity(dir * math.Rand(1800, 2800) + VectorRand() * 90)
                p:SetAirResistance(40)
                p:SetGravity(Vector(0, 0, -10))
                p:SetDieTime(math.Rand(0.3, 0.3))
                p:SetStartAlpha(255)
                p:SetEndAlpha(0)
                p:SetStartSize(math.Rand(2, 2))
                p:SetEndSize(math.Rand(100, 140))
                p:SetRoll(math.Rand(0, 360))
                p:SetRollDelta(math.Rand(-3, 3))
                p:SetColor(255, 255, 255)
            end
        end

        emitter:Finish()

        if not self.sound then
            self.sound = self:StartLoopingSound("fire_extinguisher/fire_extinguisger_startloop.wav")
        end
    end
end

if SERVER then
    local gasSounds = {}

    local function Holding(wep)
        local owner = wep:GetOwner()
        return IsValid(owner) and owner:IsPlayer() and owner:Alive() and owner:GetActiveWeapon() == wep
    end

    function SWEP:StopGasSound()
        local sounds = gasSounds[self]
        if sounds then
            for _, snd in ipairs(sounds) do snd:Stop() end
            gasSounds[self] = nil
        end
    end

    function SWEP:SetGasFlow(state)
        if self.gasFlow == state then return end
        self.gasFlow = state
        self:SetNetVar("gasflow", state)

        local owner = self:GetOwner()
        if IsValid(owner) then
            local click = FirstExisting(OPEN_CLICK)
            if click then owner:EmitSound(click, 80, 80) end
        end

        if state then
            if IsValid(owner) and not gasSounds[self] then
                local burst = FirstExisting(OPEN_BURST)
                if burst then owner:EmitSound(burst, self.GasSoundLevel, 100) end

                local sounds = {}
                local pitches = {self.GasSoundPitch, self.GasSoundPitch2}

                for i, list in ipairs(GAS_LOOPS) do
                    local path = FirstExisting(list)
                    if path then
                        local snd = CreateSound(owner, path)
                        snd:SetSoundLevel(self.GasSoundLevel)
                        snd:PlayEx(self.GasSoundVolume, pitches[i])
                        sounds[#sounds + 1] = snd
                    end
                end

                gasSounds[self] = sounds
            end
        else
            self:StopGasSound()
        end
    end

    function SWEP:GasTick()
        local owner = self:GetOwner()
        if not IsValid(owner) then
            self:SetGasFlow(false)
            return
        end

        self.GasLeft = self.GasLeft or self.GasTime
        if self.GasLeft <= 0 then
            self:SetGasFlow(false)
            return
        end

        local dt = 0.1
        self.GasLeft = math.max(self.GasLeft - dt, 0)
        self:SetNWFloat("amountspray", self.GasLeft / self.GasTime * 100)

        local push = -owner:GetAimVector()
        push.z = push.z * 0.3
        owner:SetVelocity(push * self.GasPush)

        local tr = hg.eyeTrace(owner, 256)
        local affected = {}

        for _, ent in ipairs(ents.FindInSphere(tr.HitPos, 32)) do
            local ply = ent:IsPlayer() and ent or (hg.RagdollOwner and hg.RagdollOwner(ent))

            if IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply ~= owner and not affected[ply] then
                affected[ply] = true

                local org = ply.organism
                if org then
                    org.temperature = math.max((org.temperature or 36.7) - self.ColdRate * dt, 26)

                    if not org.holdingbreath then
                        org.o2[1] = math.max(0, org.o2[1] - self.GasO2Rate * dt)
                        org.is_sprayed_at = true

                        if not org.otrub and math.random(1, 8) == 1 then
                            ply:Notify("", 5, "coughing", nil, function() hg.organism.module.random_events.TriggerRandomEvent(ply,"Cough") end, color_white)
                        end
                    end
                end
            end
        end

        if self.GasLeft <= 0 then
            self:SetGasFlow(false)
        end
    end

    function SWEP:GasThink()
        local owner = self:GetOwner()

        if not Holding(self) then
            self.lmbDown = false
            if self.gasFlow then self:SetGasFlow(false) end
            return
        end

        local down = hg.KeyDown(owner, IN_ATTACK) and not hg.KeyDown(owner, IN_RELOAD)

        if down and not self.lmbDown and self:GetNetVar("extinguishermode") then
            if not self.gasFlow then
                if (self.GasLeft or self.GasTime) > 0 then
                    self.nextGasTick = 0
                    self:SetGasFlow(true)
                end
            else
                self:SetGasFlow(false)
            end
        end

        self.lmbDown = down

        if self.gasFlow and CurTime() >= (self.nextGasTick or 0) then
            self.nextGasTick = CurTime() + 0.1
            self:GasTick()
        end
    end

    function SWEP:Think()
        self.BaseClass.Think(self)
        self:GasThink()
    end

    function SWEP:OnRemove()
        self:StopGasSound()
        if self.BaseClass and self.BaseClass.OnRemove then
            self.BaseClass.OnRemove(self)
        end
    end

    function SWEP:OwnerChanged()
        self:SetGasFlow(false)
        if self.BaseClass and self.BaseClass.OwnerChanged then
            self.BaseClass.OwnerChanged(self)
        end
    end

    function SWEP:OnDrop()
        self:SetGasFlow(false)
    end

    hook.Add("Think", "HG_PropaneTankGasGuard", function()
        for wep, sounds in pairs(gasSounds) do
            if not IsValid(wep) then
                for _, snd in ipairs(sounds) do snd:Stop() end
                gasSounds[wep] = nil
            elseif not Holding(wep) then
                wep:SetGasFlow(false)
            end
        end
    end)
end

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end
        if string.lower(ent:GetModel() or "") ~= PROPANE_MODEL then return false end

        if (ply.NextPropanePickup or 0) > CurTime() then return false end
        ply.NextPropanePickup = CurTime() + 0.5

        if ply:HasWeapon(PROPANE_CLASS) then return false end

        local wep = ply:Give(PROPANE_CLASS)
        if not IsValid(wep) then return false end

        ent:Remove()
        ply:SelectWeapon(PROPANE_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_PropanePickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_PropanePickupKey", function(ply, key)
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
    local propaneHint

    hook.Add("Think", "HG_PropaneTankHint", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() or not hg or not hg.eyeTrace then return end

        local tr = hg.eyeTrace(lply)
        if not tr then return end

        local ent = tr.Entity
        if not IsValid(ent) or ent.HudHintMarkup then return end
        if ent:GetClass() ~= "prop_physics" or string.lower(ent:GetModel() or "") ~= PROPANE_MODEL then return end

        if not propaneHint then
            local key = string.upper(input.LookupBinding("+use") or "E")
            propaneHint = markup.Parse(
                "<font=ZCity_Tiny>" .. PROPANE_NAME .. "\n<colour=170,170,170>Melee weapon - press " .. key .. " to pick up</colour></font>",
                500
            )
        end

        ent.HudHintMarkup = propaneHint
    end)
end
