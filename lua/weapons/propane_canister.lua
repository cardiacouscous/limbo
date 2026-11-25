-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Propane canister"
SWEP.Instructions = "This is a hand-held cylindrical pressure vessel containing gas.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Weight = 0
SWEP.WorldModel = "models/props_c17/canister01a.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_tool_extinguisher.mdl"
SWEP.ViewModel = ""
SWEP.WorldModelExchange = "models/props_c17/canister01a.mdl"

SWEP.bloodID = 3

SWEP.HoldType = "revolver"

SWEP.DamageType = DMG_SLASH
SWEP.weight = 15

SWEP.HoldPos = Vector(-15,1,2)
SWEP.HoldAng = Angle()

SWEP.AttackTime = 0.45
SWEP.AnimTime1 = 1.9
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 93

SWEP.weaponPos = Vector(1,3,0.2)
SWEP.weaponAng = Angle(-50,0,-90)
SWEP.modelscale = 0.8

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
    ["attack2"] = "Attack_Quick",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/Propane_canister.png")
	SWEP.IconOverride = "melgun/Propane_canister.png"
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

function SWEP:CanSecondaryAttack()
    return false
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

SWEP.IsPropaneCanister = true

SWEP.CanisterModels = {
    "models/props_c17/canister01a.mdl",
    "models/props_c17/canister02a.mdl",
}

local heldScale = SWEP.modelscale

SWEP.HitsToLeak = 6
SWEP.GasTime = 10
SWEP.GasThrust = 600
SWEP.GasMaxSpeed = 900
SWEP.GasUp = 0.35

SWEP.FuseTime = 5
SWEP.ExplodeChance = 0.05
SWEP.ExplosionDamage = 150
SWEP.ExplosionRadius = 200
SWEP.ExplosionEffectScale = 1.3
SWEP.ExplosionFireRadius = 150
SWEP.ExplosionSmokeScale = 7

local STEAM_SOUND = "ambient/gas/steam_loop1.wav"

function SWEP:GetCanisterIndex()
    local idx = self:GetNetVar("canmodel", 1)
    return self.CanisterModels[idx] and idx or 1
end

function SWEP:GetWorldModelExchange()
    self.modelscale = IsValid(self:GetOwner()) and heldScale or 1
    return self.CanisterModels[self:GetCanisterIndex()]
end

if CLIENT then
        local STEAM_SPRITES = {
            "particle/smokesprites_0001",
            "particle/smokesprites_0002",
            "particle/smokesprites_0003",
            "particle/smokesprites_0004",
        }

        function SWEP:DrawPostWorldModel()
            if not self:GetNetVar("propanegas", false) then return end

            local wm = self.worldModel2
            if not IsValid(wm) then return end

            if (self.nextSteam or 0) > CurTime() then return end
            self.nextSteam = CurTime() + 0.02

            local fuseStart = self:GetNetVar("propanefuse", 0)
            local k = fuseStart > 0 and math.Clamp((CurTime() - fuseStart) / self.FuseTime, 0, 1) or 0

            local _, maxs = wm:GetModelBounds()
            local top = wm:LocalToWorld(Vector(0, 0, maxs.z * wm:GetModelScale()))
            local dir = wm:GetUp()

            local emitter = ParticleEmitter(top, false)
            if not IsValid(emitter) then return end

            for i = 1, 2 + math.floor(k * 4) do
                local p = emitter:Add(STEAM_SPRITES[math.random(#STEAM_SPRITES)], top)
                if p then
                    p:SetVelocity(dir * math.Rand(220, 360) * (1 + k) + VectorRand() * 35)
                    p:SetAirResistance(90)
                    p:SetGravity(Vector(0, 0, 25))
                    p:SetDieTime(math.Rand(0.5, 0.9))
                    p:SetStartAlpha(150)
                    p:SetEndAlpha(0)
                    p:SetStartSize(math.Rand(3, 6) * (1 + k))
                    p:SetEndSize(math.Rand(24, 38) * (1 + k))
                    p:SetRoll(math.Rand(-3, 3))
                    p:SetRollDelta(math.Rand(-1, 1))
                    p:SetColor(235, 235, 235)
                end
            end

            emitter:Finish()
        end
end

if SERVER then
    local CANISTER_CLASS = "propane_canister"

        local dbg = CreateConVar("propane_debug", "0", FCVAR_NONE, "Debug output for the propane canister")
        local function Dbg(ply, ...)
            if dbg:GetBool() and IsValid(ply) then ply:ChatPrint("[propane] " .. table.concat({...}, " ")) end
        end

        local modelIndex = {}
        for i, mdl in ipairs(SWEP.CanisterModels) do modelIndex[mdl] = i end

        local propClasses = {
            ["prop_physics"] = true,
            ["prop_physics_multiplayer"] = true,
        }

        local function TryPickup(ply, ent)
            if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
            if not propClasses[ent:GetClass()] then return false end

            local idx = modelIndex[string.lower(ent:GetModel() or "")]
            if not idx then return false end

            if (ply.NextPropanePickup or 0) > CurTime() then return false end
            ply.NextPropanePickup = CurTime() + 0.5

            for _, w in ipairs(ply:GetWeapons()) do
                if w.IsPropaneCanister then Dbg(ply, "баллон уже есть") return false end
            end

            local wep = ply:Give(CANISTER_CLASS)
            if not IsValid(wep) then
                Dbg(ply, "Give(" .. CANISTER_CLASS .. ") не сработал: неверный класс или запретил PlayerCanPickupWeapon")
                return false
            end

            wep:SetNetVar("canmodel", idx)
            ent:Remove()
            ply:SelectWeapon(CANISTER_CLASS)
            Dbg(ply, "подобран")

            return true
        end

        hook.Add("PlayerUse", "PropaneCanister_Pickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
            if TryPickup(ply, ent) then return false end
        end)

        local function FindCanisterProp(ply)
            local start = ply:GetShootPos()
            local aim = ply:GetAimVector()

            local tr = util.TraceHull({
                start = start,
                endpos = start + aim * 90,
                mins = Vector(-6, -6, -6),
                maxs = Vector(6, 6, 6),
                filter = ply,
            })

            if IsValid(tr.Entity) and modelIndex[string.lower(tr.Entity:GetModel() or "")] then
                return tr.Entity
            end

            for _, ent in ipairs(ents.FindInSphere(start + aim * 50, 45)) do
                if propClasses[ent:GetClass()] and modelIndex[string.lower(ent:GetModel() or "")] then
                    return ent
                end
            end
        end

        hook.Add("KeyPress", "PropaneCanister_PickupKey", function(ply, key)
            if key ~= IN_USE then return end
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab

            local ent = FindCanisterProp(ply)
            Dbg(ply, "E, баллон перед игроком:", ent and "найден" or "не найден")
            if ent then TryPickup(ply, ent) end
        end)

        function SWEP:ApplyDroppedModel()
            if IsValid(self:GetOwner()) then return end

            local mdl = self.CanisterModels[self:GetCanisterIndex()]
            if self:GetModel() == mdl then return end

            self:SetModel(mdl)
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)

            local phys = self:GetPhysicsObject()
            if IsValid(phys) then phys:Wake() end
        end

        function SWEP:OwnerChanged()
            self.BaseClass.OwnerChanged(self)

            if not IsValid(self:GetOwner()) then
                local old = self.gasOwner
                if IsValid(old) and old.PropaneGasWep == self then
                    old.PropaneGasWep = nil
                end

                timer.Simple(0, function()
                    if IsValid(self) then self:ApplyDroppedModel() end
                end)
            end
        end

        function SWEP:OnDrop()
            self:ApplyDroppedModel()
        end

        local leaking = {}

        function SWEP:UpdateSteamSound()
            local owner = self:GetOwner()
            local rag = IsValid(owner) and owner:IsPlayer() and owner.FakeRagdoll
            local src = IsValid(rag) and rag or self

            if self.steamSound and self.steamSoundEnt == src then return end

            self:StopSteamSound()
            self.steamSoundEnt = src

            local snd = CreateSound(src, STEAM_SOUND)

            if self.gasState == "fuse" then
                local left = math.max(self.fuseEnd - CurTime(), 0.1)
                local frac = math.Clamp(1 - left / self.FuseTime, 0, 1)
                snd:PlayEx(Lerp(frac, 0.3, 1), Lerp(frac, 80, 170))
                snd:ChangePitch(170, left)
                snd:ChangeVolume(1, left)
            else
                snd:Play()
            end

            self.steamSound = snd
        end

        function SWEP:StopSteamSound()
            if self.steamSound then
                self.steamSound:Stop()
                self.steamSound = nil
            end
            self.steamSoundEnt = nil
        end

        function SWEP:StartLeak()
            local owner = self:GetOwner()

            self.gasState = "leaking"
            self.gasEnd = CurTime() + self.GasTime
            self.gasOwner = owner
            leaking[self] = true
            self:SetNetVar("propanegas", true)

            if IsValid(owner) and owner:IsPlayer() then
                owner.PropaneGasWep = self
            end

            timer.Simple(0, function()
                if not IsValid(self) or self.gasState ~= "leaking" then return end

                if IsValid(owner) and owner:IsPlayer() and owner:Alive() and not IsValid(owner.FakeRagdoll) then
                    hg.Fake(owner)
                end
            end)
        end

        function SWEP:StopLeak()
            leaking[self] = nil
            self.gasState = "empty"
            self:StopSteamSound()
            self:SetNetVar("propanegas", false)

            local owner = self.gasOwner
            if IsValid(owner) and owner.PropaneGasWep == self then
                owner.PropaneGasWep = nil
            end
        end

        function SWEP:StartFuse()
            if self.exploded or self.gasState == "fuse" then return end

            local owner = self.gasOwner
            if IsValid(owner) and owner.PropaneGasWep == self then
                owner.PropaneGasWep = nil
            end
            self:StopSteamSound()

            self.gasState = "fuse"
            self.fuseEnd = CurTime() + self.FuseTime
            leaking[self] = true

            self:SetNetVar("propanegas", true)
            self:SetNetVar("propanefuse", CurTime())
        end

        function SWEP:OnRemove()
            self.BaseClass.OnRemove(self)

            leaking[self] = nil
            self:StopSteamSound()

            local owner = self.gasOwner
            if IsValid(owner) and owner.PropaneGasWep == self then
                owner.PropaneGasWep = nil
            end
        end

        function SWEP:GasThrustTick()
            local owner = self:GetOwner()
            local rag = IsValid(owner) and owner:IsPlayer() and owner.FakeRagdoll

            if IsValid(owner) and owner.organism and owner.organism.otrub then
                self:RemoveFake()
                hg.drop(owner)
                return
            end

            if IsValid(rag) then
                local aim = owner:GetAimVector()
                aim.z = 0
                if aim:LengthSqr() < 0.01 then aim = Vector(1, 0, 0) end
                aim:Normalize()

                local dir = -aim * (1 - self.GasUp) + vector_up * self.GasUp
                dir:Normalize()

                local first = rag:GetPhysicsObjectNum(0)
                if IsValid(first) and first:GetVelocity():Length() > self.GasMaxSpeed then return end

                for i = 0, rag:GetPhysicsObjectCount() - 1 do
                    local phys = rag:GetPhysicsObjectNum(i)
                    if IsValid(phys) then
                        phys:Wake()
                        phys:ApplyForceCenter(dir * phys:GetMass() * self.GasThrust)
                    end
                end
            elseif not IsValid(owner) then
                local phys = self:GetPhysicsObject()
                if IsValid(phys) and phys:GetVelocity():Length() < self.GasMaxSpeed then
                    phys:Wake()
                    phys:ApplyForceCenter(-self:GetUp() * phys:GetMass() * self.GasThrust * 0.6)
                end
            end
        end

        hook.Add("Think", "PropaneCanister_GasThrust", function()
            for wep in pairs(leaking) do
                if not IsValid(wep) then
                    leaking[wep] = nil
                elseif wep.gasState == "fuse" then
                    if wep.fuseEnd <= CurTime() then
                        leaking[wep] = nil
                        wep:Explode()
                    else
                        wep:UpdateSteamSound()
                    end
                elseif wep.gasEnd <= CurTime() then
                    wep:StopLeak()
                else
                    wep:UpdateSteamSound()
                    wep:GasThrustTick()
                end
            end
        end)

        hook.Add("Should Fake Up", "PropaneCanister_NoGetUp", function(ply)
            local wep = ply.PropaneGasWep
            if not IsValid(wep) or wep.gasState ~= "leaking" or wep:GetOwner() ~= ply then return end
            if ply.organism and ply.organism.otrub then return end

            return false
        end)

        local function ChunkModels(idx)
            local models = {}
            for i = string.byte("a"), string.byte("m") do
                local mdl = string.format("models/props_c17/canisterchunk%02d%s.mdl", idx, string.char(i))
                if util.IsValidModel(mdl) then models[#models + 1] = mdl end
            end
            return models
        end

        function SWEP:Explode()
            if self.exploded then return end
            self.exploded = true

            local owner = self:GetOwner()
            local idx = self:GetCanisterIndex()

            local pos
            if IsValid(owner) and owner:IsPlayer() then
                local rag = owner.FakeRagdoll
                pos = IsValid(rag) and rag:GetPos() or (owner:GetShootPos() + owner:GetAimVector() * 20 - vector_up * 10)
            else
                pos = self:WorldSpaceCenter()
            end

            local boom = EffectData()
            boom:SetOrigin(pos)
            boom:SetNormal(vector_up)
            boom:SetScale(self.ExplosionEffectScale)
            util.Effect("eff_jack_genericboom", boom, true, true)

            local fire = EffectData()
            fire:SetOrigin(pos)
            fire:SetRadius(self.ExplosionFireRadius)
            util.Effect("eff_hg_fire", fire, true, true)

            local poof = EffectData()
            poof:SetOrigin(pos)
            poof:SetScale(self.ExplosionSmokeScale)
            util.Effect("eff_jack_hmcd_poof", poof, true, true)

            sound.Play("ambient/explosions/explode_" .. math.random(1, 5) .. ".wav", pos, 140, math.random(90, 110), 1)

            util.BlastDamage(self, IsValid(owner) and owner or self, pos, self.ExplosionRadius, self.ExplosionDamage)

            for _, mdl in ipairs(ChunkModels(idx)) do
                local chunk = ents.Create("prop_physics")
                if IsValid(chunk) then
                    chunk:SetModel(mdl)
                    chunk:SetPos(pos + VectorRand() * 10)
                    chunk:SetAngles(AngleRand())
                    chunk:Spawn()
                    chunk:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

                    local phys = chunk:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:Wake()
                        phys:SetVelocity(VectorRand() * 500 + Vector(0, 0, 250))
                        phys:AddAngleVelocity(VectorRand() * 400)
                    end

                    SafeRemoveEntityDelayed(chunk, 30)
                end
            end

            self:StopSteamSound()
            self:SetNetVar("propanegas", false)
            SafeRemoveEntityDelayed(self, 0.1)
        end

        function SWEP:CountHit()
            if self.exploded or self.gasState == "fuse" then return end

            if (self.nextHitCount or 0) > CurTime() then return end
            self.nextHitCount = CurTime() + 0.8

            if self.gasState ~= "empty" and math.Rand(0, 1) < self.ExplodeChance then
                self:StartFuse()
                return
            end

            if self.gasState then return end

            self.hitCount = (self.hitCount or 0) + 1
            if self.hitCount >= self.HitsToLeak then
                self:StartLeak()
            end
        end

        function SWEP:PrimaryAttackAdd(ent, trace)
            self:CountHit()
        end

        function SWEP:SecondaryAttackAdd(ent, trace)
            self:CountHit()
        end
end

local HINT_MODELS = {}
for _, mdl in ipairs(SWEP.CanisterModels) do
    HINT_MODELS[string.lower(mdl)] = true
end
local HINT_NAME = SWEP.PrintName

if CLIENT then
    local itemHint

    hook.Add("Think", "HG_PropaneCanisterHint", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() or not hg or not hg.eyeTrace then return end

        local tr = hg.eyeTrace(lply)
        if not tr then return end

        local ent = tr.Entity
        if not IsValid(ent) or ent.HudHintMarkup then return end
        if ent:GetClass() ~= "prop_physics" or not HINT_MODELS[string.lower(ent:GetModel() or "")] then return end

        if not itemHint then
            local key = string.upper(input.LookupBinding("+use") or "E")
            itemHint = markup.Parse(
                "<font=ZCity_Tiny>" .. HINT_NAME .. "\n<colour=170,170,170>Melee weapon - press " .. key .. " to pick up</colour></font>",
                500
            )
        end

        ent.HudHintMarkup = itemHint
    end)
end
