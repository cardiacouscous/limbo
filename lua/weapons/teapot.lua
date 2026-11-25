-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then
    AddCSLuaFile()
end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Teapot"
SWEP.Instructions = "Teapot. Container with a spout, lid, and handle used for brewing and serving tea. (look down to pour out the water) \n\nLMB to attack.\nRMB to block.\nRMB + LMB to throw.\nLook straight down to pour water."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.WorldModel = "models/props_interiors/pot01a.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_hatchet.mdl"
SWEP.WorldModelExchange = "models/props_interiors/pot01a.mdl"
SWEP.weaponPos = Vector(4, 0, -5)
SWEP.weaponAng = Angle(0, -270, -85)
SWEP.attack_ang = Angle(0, 0, 0)
SWEP.sprint_ang = Angle(15, 0, 0)
SWEP.basebone = 94
SWEP.BreakBoneMul = .26
SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}
if CLIENT then
    SWEP.WepSelectIcon = Material("melgun/Teapot.png")
    SWEP.IconOverride = "melgun/Teapot.png"
    SWEP.BounceWeaponIcon = false
end
SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false
SWEP.NoHolster = true
SWEP.HoldPos = Vector(-12, 0, 5)
SWEP.HoldAng = Angle(0,0,0)
SWEP.AttackPos = Vector(0, 0, 0)
SWEP.HoldType = "melee"
SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 14
SWEP.DamageSecondary = 8
SWEP.PenetrationPrimary = 1.3
SWEP.PenetrationSecondary = 0.9
SWEP.MaxPenLen = 4
SWEP.PainMultiplier = .5
SWEP.PenetrationSizePrimary = 1
SWEP.PenetrationSizeSecondary = 2
SWEP.StaminaPrimary = 15
SWEP.StaminaSecondary = 7
SWEP.AttackLen1 = 45
SWEP.AttackLen2 = 35
SWEP.AttackHit = "SolidMetal.ImpactHard"
SWEP.Attack2Hit = "SolidMetal.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "SolidMetal.ImpactHard"
SWEP.weight = 2
SWEP.BlockTier = 2
SWEP.BleedMultiplier = 1

local BurnTarget

function SWEP:CanSecondaryAttack()
    return true
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1

SWEP.AttackTime = 0.4
SWEP.AnimTime1 = 1
SWEP.WaitTime1 = 1
SWEP.ViewPunch1 = Angle(0, -5, 3)

SWEP.AttackRads = 30
SWEP.AttackRads2 = 65

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

function SWEP:CustomAttack2()
    local ply = self:GetOwner()
    self:EnsureWater()
    local boiling = self.Boiling and self.WaterLeft > 0

    local ent = ents.Create("ent_throwable")
    ent.WorldModel = self.WorldModelExchange or self.WorldModel

    ent:SetPos(select(1, hg.eye(ply, 60, hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
    ent:SetAngles(ply:EyeAngles())
    ent:SetOwner(ply)
    ent:Spawn()

    ent.localshit = Vector(0, 0, 0)
    ent.wep = self:GetClass()
    ent.owner = ply
    ent.damage = 12
    ent.MaxSpeed = 1200
    ent.DamageType = DMG_CLUB
    ent.AttackHit = "SolidMetal.ImpactHard"
    ent.AttackHitFlesh = "SolidMetal.ImpactHard"
    ent.noStuck = true

    ent.func = function(data)
        if (ent.nextImpact or 0) > CurTime() then return end
        ent.nextImpact = CurTime() + 0.15

        ent:EmitSound("SolidMetal.ImpactHard")

        if boiling and BurnTarget and data and IsValid(data.HitEntity) then
            boiling = false
            BurnTarget(data.HitEntity, ply, ent)
        end
    end

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(VectorRand() * 500)
    end

    ply:ViewPunch(Angle(0, 0, -8))
    ply:SelectWeapon("weapon_hands_sh")

    if self.TrackThrown then self:TrackThrown(ent) end

    self:Remove()

    return true
end

local TEAPOT_MODEL = "models/props_interiors/pot01a.mdl"
local TEAPOT_CLASS = string.StripExtension(string.GetFileFromFilename(debug.getinfo(1, "S").short_src))
local TEAPOT_NAME = SWEP.PrintName

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end
        if string.lower(ent:GetModel() or "") ~= TEAPOT_MODEL then return false end

        if (ply.NextTeapotPickup or 0) > CurTime() then return false end
        ply.NextTeapotPickup = CurTime() + 0.5

        if ply:HasWeapon(TEAPOT_CLASS) then return false end

        local wep = ply:Give(TEAPOT_CLASS)
        if not IsValid(wep) then return false end

        ent:Remove()
        ply:SelectWeapon(TEAPOT_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_TeapotPickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_TeapotPickupKey", function(ply, key)
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
    local teapotHint

    hook.Add("Think", "HG_TeapotHint", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() or not hg or not hg.eyeTrace then return end

        local tr = hg.eyeTrace(lply)
        if not tr then return end

        local ent = tr.Entity
        if not IsValid(ent) or ent.HudHintMarkup then return end
        if ent:GetClass() ~= "prop_physics" or string.lower(ent:GetModel() or "") ~= TEAPOT_MODEL then return end

        if not teapotHint then
            local key = string.upper(input.LookupBinding("+use") or "E")
            teapotHint = markup.Parse(
                "<font=ZCity_Tiny>" .. TEAPOT_NAME .. "\n<colour=170,170,170>Melee weapon - press " .. key .. " to pick up</colour></font>",
                500
            )
        end

        ent.HudHintMarkup = teapotHint
    end)
end

SWEP.WaterTime = 6
SWEP.PourPitch = 80
SWEP.SpoutPos = Vector(5, -7, 1)
SWEP.EmptyChance = 0.25
SWEP.BoilingChance = 0.25
SWEP.ScaldPain = 22
SWEP.ScaldTemperature = 0.25
SWEP.ScaldDamage = 1
SWEP.ScaldFaceRadius = 14
SWEP.ScaldBlurTime = 60

local WATER_SPRITES = {
    "effects/splash1",
    "effects/splash2",
    "effects/splash4",
}

local STEAM_SPRITES = {
    "particle/smokesprites_0001",
    "particle/smokesprites_0002",
    "particle/smokesprites_0003",
    "particle/smokesprites_0004",
}

local BOIL_PAIN = 30
local BOIL_TEMPERATURE = 1.5
local BOIL_FEAR = 0.5

if CLIENT then
    local cv = {
        x = CreateClientConVar("teapot_spout_x", tostring(SWEP.SpoutPos.x)),
        y = CreateClientConVar("teapot_spout_y", tostring(SWEP.SpoutPos.y)),
        z = CreateClientConVar("teapot_spout_z", tostring(SWEP.SpoutPos.z)),
    }

    concommand.Add("teapot_spout_print", function()
        print(string.format("SWEP.SpoutPos = Vector(%g, %g, %g)", cv.x:GetFloat(), cv.y:GetFloat(), cv.z:GetFloat()))
    end)

    function SWEP:DrawPostWorldModel()
        local pouring = self:GetNetVar("pouring", false)
        local steaming = self:GetNetVar("tpboil", false) and self:GetNetVar("tphas", false)
        if not pouring and not steaming then return end

        local wm = self.worldModel2
        if not IsValid(wm) then return end

        local pos = wm:LocalToWorld(Vector(cv.x:GetFloat(), cv.y:GetFloat(), cv.z:GetFloat()))

        if steaming and (self.nextSteam or 0) <= CurTime() then
            self.nextSteam = CurTime() + (pouring and 0.04 or 0.1)

            local steamEmitter = ParticleEmitter(pos, false)
            if IsValid(steamEmitter) then
                local p = steamEmitter:IsValid() and steamEmitter:Add(STEAM_SPRITES[math.random(#STEAM_SPRITES)], pos)
                if p then
                    p:SetVelocity(Vector(0, 0, 35) + VectorRand() * 8)
                    p:SetAirResistance(40)
                    p:SetGravity(Vector(0, 0, 15))
                    p:SetDieTime(math.Rand(0.8, 1.4))
                    p:SetStartAlpha(70)
                    p:SetEndAlpha(0)
                    p:SetStartSize(math.Rand(2, 4))
                    p:SetEndSize(math.Rand(10, 16))
                    p:SetRoll(math.Rand(0, 360))
                    p:SetRollDelta(math.Rand(-1, 1))
                    p:SetColor(240, 240, 240)
                end
                if steamEmitter:IsValid() then steamEmitter:Finish() end
            end
        end

        if not pouring then return end

        if (self.nextWater or 0) > CurTime() then return end
        self.nextWater = CurTime() + 0.02

        local emitter = ParticleEmitter(pos, false)
        if not IsValid(emitter) then return end

        for i = 1, 3 do
            if not IsValid(emitter) or not emitter:IsValid() then break end

            local p = emitter:Add(WATER_SPRITES[math.random(#WATER_SPRITES)], pos + VectorRand() * 0.5)
            if p then
                p:SetVelocity(Vector(0, 0, -40) + VectorRand() * 12)
                p:SetGravity(Vector(0, 0, -600))
                p:SetDieTime(math.Rand(0.5, 0.8))
                p:SetStartAlpha(200)
                p:SetEndAlpha(60)
                p:SetStartSize(math.Rand(1.5, 2.5))
                p:SetEndSize(math.Rand(1, 1.5))
                p:SetRoll(math.Rand(0, 360))
                p:SetColor(200, 225, 255)
                p:SetCollide(true)
                p:SetCollideCallback(function(part, hitpos, normal)
                    part:SetDieTime(0)

                    if not IsValid(emitter) or not emitter:IsValid() then return end

                    local splash = emitter:Add(WATER_SPRITES[math.random(#WATER_SPRITES)], hitpos + normal)
                    if splash then
                        splash:SetVelocity(normal * 20 + VectorRand() * 10)
                        splash:SetGravity(Vector(0, 0, -200))
                        splash:SetDieTime(0.25)
                        splash:SetStartAlpha(150)
                        splash:SetEndAlpha(0)
                        splash:SetStartSize(2)
                        splash:SetEndSize(6)
                        splash:SetColor(200, 225, 255)
                    end
                end)
            end
        end

        if IsValid(emitter) and emitter:IsValid() then emitter:Finish() end
    end
end

if SERVER then
    util.AddNetworkString("hg_teapot_scald_blur")

    local pourSounds = {}
    local pourSoundPath

    local function GetPourSound()
        if pourSoundPath ~= nil then return pourSoundPath end

        pourSoundPath = false
        for _, path in ipairs({
            "ambient/water/water_flow_loop1.wav",
            "ambient/water/water_run1.wav",
            "ambient/water/water_spray1.wav",
        }) do
            if file.Exists("sound/" .. path, "GAME") then
                pourSoundPath = path
                break
            end
        end

        return pourSoundPath
    end

    local burnSounds = {}
    for _, path in ipairs({
        "player/pl_burnpain1.wav",
        "player/pl_burnpain2.wav",
        "player/pl_burnpain3.wav",
        "ambient/levels/canals/toxic_slime_sizzle2.wav",
    }) do
        if file.Exists("sound/" .. path, "GAME") then
            burnSounds[#burnSounds + 1] = path
        end
    end

    local function GetVictim(target)
        if not IsValid(target) then return end
        if target:IsPlayer() then return target end

        local owner = hg and hg.RagdollOwner and hg.RagdollOwner(target)
        if IsValid(owner) then return owner end
    end

    local function ScreamSound(ply)
        local mdl = string.lower(ply:GetModel() or "")
        local female = string.find(mdl, "female", 1, true) or string.find(mdl, "alyx", 1, true) or string.find(mdl, "mossman", 1, true)
        return string.format("vo/npc/%s01/pain0%d.wav", female and "female" or "male", math.random(7, 9))
    end

    BurnTarget = function(target, attacker, inflictor)
        local ply = GetVictim(target)

        if ply then
            local org = ply.organism
            if org then
                org.painadd = (org.painadd or 0) + BOIL_PAIN
                org.temperature = math.min((org.temperature or 36.7) + BOIL_TEMPERATURE, 42)
                org.adrenalineAdd = (org.adrenalineAdd or 0) + 0.3
                org.fearadd = (org.fearadd or 0) + BOIL_FEAR
            end

            local character = hg and hg.GetCurrentCharacter and hg.GetCurrentCharacter(ply) or ply
            if not IsValid(character) then character = ply end

            if #burnSounds > 0 then
                character:EmitSound(burnSounds[math.random(#burnSounds)], 75, math.random(95, 105))
            end

            if not (org and org.otrub) then
                timer.Simple(0.15, function()
                    if IsValid(character) and IsValid(ply) then
                        character:EmitSound(ScreamSound(ply), 90, math.random(95, 105))
                    end
                end)
            end
        elseif IsValid(target) and target:IsNPC() then
            local dmg = DamageInfo()
            dmg:SetDamage(10)
            dmg:SetDamageType(DMG_BURN)
            dmg:SetAttacker(IsValid(attacker) and attacker or game.GetWorld())
            dmg:SetInflictor(IsValid(inflictor) and inflictor or game.GetWorld())
            target:TakeDamageInfo(dmg)

            if #burnSounds > 0 then
                target:EmitSound(burnSounds[math.random(#burnSounds)], 75)
            end
        end
    end

    function SWEP:EnsureWater()
        if self.rolled then return end

        if self.restoreUntil and CurTime() < self.restoreUntil then
            self.WaterLeft = self.WaterLeft or 0
            self.Boiling = self.Boiling or false
            return
        end

        self.rolled = true

        local roll = math.Rand(0, 1)
        self.Boiling = false
        self.WaterLeft = self.WaterTime

        if roll < self.EmptyChance then
            self.WaterLeft = 0
        elseif roll < self.EmptyChance + self.BoilingChance then
            self.Boiling = true
        end

        self.hasWaterNet = self.WaterLeft > 0
        self:SetNetVar("tpboil", self.Boiling)
        self:SetNetVar("tphas", self.hasWaterNet)
    end

    function SWEP:PrimaryAttackAdd(ent, trace)
        self:EnsureWater()

        if self.Boiling and self.WaterLeft > 0 and IsValid(ent) then
            BurnTarget(ent, self:GetOwner(), self)
        end
    end

    local function Holding(wep)
        local owner = wep:GetOwner()
        return IsValid(owner) and owner:IsPlayer() and owner:Alive()
            and owner:GetActiveWeapon() == wep and not IsValid(owner.FakeRagdoll)
    end

    function SWEP:StopPourSound()
        local snd = pourSounds[self]
        if snd then
            snd:Stop()
            pourSounds[self] = nil
        end
    end

    function SWEP:SetPouring(state)
        if self.pouringState == state then return end
        self.pouringState = state
        self:SetNetVar("pouring", state)

        if state then
            local path = GetPourSound()
            local owner = self:GetOwner()
            if path and IsValid(owner) and not pourSounds[self] then
                local snd = CreateSound(owner, path)
                snd:PlayEx(0.7, 100)
                pourSounds[self] = snd
            end
        else
            self:StopPourSound()
        end
    end

    function SWEP:ScaldPlayer(owner, ply, hitpos, step)
        print("[teapot] victim:", ply, "owner:", owner, ply == owner)
        local org = ply.organism
        local character = hg and hg.GetCurrentCharacter and hg.GetCurrentCharacter(ply) or ply
        if not IsValid(character) then character = ply end

        local face = false
        local bone = character:LookupBone("ValveBiped.Bip01_Head1")
        if bone then
            local m = character:GetBoneMatrix(bone)
            if m and hitpos:DistToSqr(m:GetTranslation()) < self.ScaldFaceRadius ^ 2 then
                face = true
            end
        end

        if org then
            org.painadd = (org.painadd or 0) + self.ScaldPain * step * (face and 1.5 or 1)
            org.temperature = math.min((org.temperature or 36.7) + self.ScaldTemperature * step, 42)
            org.adrenalineAdd = (org.adrenalineAdd or 0) + 0.2 * step
            org.fearadd = math.max(org.fearadd or 0, 1)
        end

        local now = CurTime()
        local soundPos = character:GetPos() + Vector(0, 0, 60)

        if now >= (ply.nextScaldDamage or 0) then
    ply.nextScaldDamage = now + 0.5

    if org then org.burns = (org.burns or 0) + 1 end
end

        if now >= (ply.nextScaldSound or 0) and #burnSounds > 0 then
            ply.nextScaldSound = now + 0.6
            sound.Play(burnSounds[math.random(#burnSounds)], soundPos, 75, math.random(95, 105))
        end

        if now >= (ply.nextScaldScream or 0) and not (org and org.otrub) then
            ply.nextScaldScream = now + 1.3
            sound.Play(ScreamSound(ply), soundPos, 90, math.random(95, 105))
        end

        if face and now >= (ply.nextScaldBlurSend or 0) then
            ply.nextScaldBlurSend = now + 1

            net.Start("hg_teapot_scald_blur")
                net.WriteFloat(self.ScaldBlurTime)
            net.Send(ply)
        end
    end

    function SWEP:ScaldThink(owner, dt)
        self.scaldAcc = (self.scaldAcc or 0) + dt
        if self.scaldAcc < 0.25 then return end

        local step = self.scaldAcc
        self.scaldAcc = 0

        local tr = hg.eyeTrace(owner, 150)
        if not tr then return end

        local done = {}

        for _, ent in ipairs(ents.FindInSphere(tr.HitPos, 28)) do
            local ply = GetVictim(ent)

            if ply then
                if ply ~= owner and ply:Alive() and not done[ply] then
                    done[ply] = true
                    self:ScaldPlayer(owner, ply, tr.HitPos, step)
                end
            elseif IsValid(ent) and ent:IsNPC() and not done[ent] then
                done[ent] = true

                local dmg = DamageInfo()
                dmg:SetDamage(self.ScaldDamage)
                dmg:SetDamageType(DMG_BURN)
                dmg:SetAttacker(IsValid(owner) and owner or game.GetWorld())
                dmg:SetInflictor(self)
                ent:TakeDamageInfo(dmg)

                if #burnSounds > 0 then
                    ent:EmitSound(burnSounds[math.random(#burnSounds)], 75)
                end
            end
        end
    end

    function SWEP:WaterThink()
        local now = CurTime()
        local dt = math.min(now - (self.lastWaterThink or now), 0.2)
        self.lastWaterThink = now

        self:EnsureWater()

        if not Holding(self) then
            self:SetPouring(false)
            return
        end

        local pouring = self.WaterLeft > 0 and self:GetOwner():EyeAngles().p >= self.PourPitch

        if pouring then
            self.WaterLeft = math.max(self.WaterLeft - dt, 0)
        end

        if self.WaterLeft <= 0 and self.hasWaterNet then
            self.hasWaterNet = false
            self:SetNetVar("tphas", false)
        end

        if pouring and self.Boiling then
            self:ScaldThink(self:GetOwner(), dt)
        end

        self:SetPouring(pouring and self.WaterLeft > 0)
    end

    function SWEP:Think()
        self.BaseClass.Think(self)
        self:WaterThink()
    end

    function SWEP:OnRemove()
        self:StopPourSound()
        if self.BaseClass and self.BaseClass.OnRemove then
            self.BaseClass.OnRemove(self)
        end
    end

    function SWEP:OwnerChanged()
        self:SetPouring(false)
        if self.BaseClass and self.BaseClass.OwnerChanged then
            self.BaseClass.OwnerChanged(self)
        end
    end

    function SWEP:OnDrop()
        self:SetPouring(false)
    end

    hook.Add("Think", "HG_TeapotPourGuard", function()
        for wep, snd in pairs(pourSounds) do
            if not IsValid(wep) then
                snd:Stop()
                pourSounds[wep] = nil
            elseif not Holding(wep) then
                wep:SetPouring(false)
            end
        end
    end)
end

if SERVER then
    SWEP.IsTeapot = true

    local removedThrown = {}

    local function Restore(wep, ply, tries)
        if not IsValid(wep) or not IsValid(ply) then return end

        for i = #removedThrown, 1, -1 do
            local entry = removedThrown[i]

            if CurTime() - entry.time > 1 then
                table.remove(removedThrown, i)
            elseif entry.pos:DistToSqr(ply:GetPos()) < 90000 then
                wep.rolled = true
                wep.WaterLeft = entry.state.left
                wep.Boiling = entry.state.boiling
                wep.hasWaterNet = wep.WaterLeft > 0
                wep:SetNetVar("tpboil", wep.Boiling)
                wep:SetNetVar("tphas", wep.hasWaterNet)
                table.remove(removedThrown, i)
                return
            end
        end

        if tries > 0 then
            timer.Simple(0.05, function()
                Restore(wep, ply, tries - 1)
            end)
        end
    end

    hook.Add("WeaponEquip", "HG_TeapotRestoreState", function(wep, ply)
        if not wep.IsTeapot then return end

        wep.restoreUntil = CurTime() + 0.4
        Restore(wep, ply, 6)
    end)

    function SWEP:TrackThrown(ent)
        self:EnsureWater()

        local state = {left = self.WaterLeft, boiling = self.Boiling}

        ent:CallOnRemove("HG_TeapotState", function(e)
            removedThrown[#removedThrown + 1] = {state = state, pos = e:GetPos(), time = CurTime()}
        end)
    end
end

if CLIENT then
    local blurEnd = 0
    local blurTotal = 60
    local blurMat = Material("pp/blurscreen")

    net.Receive("hg_teapot_scald_blur", function()
        blurTotal = math.max(net.ReadFloat(), 1)
        blurEnd = CurTime() + blurTotal
    end)

    hook.Add("RenderScreenspaceEffects", "HG_TeapotScaldBlur", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() then
            blurEnd = 0
            return
        end

        local remaining = blurEnd - CurTime()
        if remaining <= 0 then return end

        local k = math.Clamp(remaining / blurTotal, 0, 1)
        k = k * k * (3 - 2 * k)

        for i = 1, 3 do
            blurMat:SetFloat("$blur", (i / 3) * 6 * k)
            blurMat:Recompute()
            render.UpdateScreenEffectTexture()
            surface.SetMaterial(blurMat)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        end

        surface.SetDrawColor(255, 255, 255, 40 * k)
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end)
end
