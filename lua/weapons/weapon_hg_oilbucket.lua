-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Oil bucket"
SWEP.Instructions = "A bucket of motor oil. Splashes oil on whatever it hits. Oil on the floor makes people slip.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

local BUCKET_MODEL = "models/props_junk/plasticbucket001a.mdl"

SWEP.Weight = 0
SWEP.WorldModel = BUCKET_MODEL
SWEP.WorldModelExchange = BUCKET_MODEL
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/tool_extinguisher/v_tool_extinguisherwile.mdl"
SWEP.ViewModel = ""

SWEP.HoldType = "revolver"

SWEP.HoldPos = Vector(-10,1,0)

SWEP.AttackTime = 0.45
SWEP.AnimTime1 = 1.9
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.30
SWEP.AnimTime2 = 1.5
SWEP.WaitTime2 = 1.3
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 93

SWEP.weaponPos = Vector(0.1,-4,0.3)
SWEP.weaponAng = Angle(0,10,-90)
SWEP.modelscale = 0.8
SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 8
SWEP.DamageSecondary = 4

SWEP.PenetrationPrimary = 1
SWEP.PenetrationSecondary = 0.5

SWEP.BlockTier = 1
SWEP.MaxPenLen = 2

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 1

SWEP.StaminaPrimary = 12
SWEP.StaminaSecondary = 6

SWEP.AttackLen1 = 60
SWEP.AttackLen2 = 55

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["walk"] = "Idle",
    ["sprint"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Attack_Quick",
    ["holster"] = "HoseUnequip",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/oil.png")
	SWEP.IconOverride = "melgun/oil.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

local function FirstExisting(list)
    for _, path in ipairs(list) do
        if file.Exists("sound/" .. path, "GAME") then return path end
    end
end

local HIT_SOUNDS = {}
for _, group in ipairs({
    {"physics/plastic/plastic_barrel_impact_hard1.wav", "physics/plastic/plastic_box_impact_hard1.wav"},
    {"physics/plastic/plastic_barrel_impact_hard2.wav", "physics/plastic/plastic_box_impact_hard2.wav"},
    {"physics/plastic/plastic_barrel_impact_hard3.wav", "physics/plastic/plastic_box_impact_hard3.wav"},
}) do
    local path = FirstExisting(group)
    if path then HIT_SOUNDS[#HIT_SOUNDS + 1] = path end
end
if #HIT_SOUNDS == 0 then HIT_SOUNDS[1] = "physics/plastic/plastic_box_impact_hard1.wav" end

SWEP.AttackHit = HIT_SOUNDS[1]
SWEP.Attack2Hit = HIT_SOUNDS[#HIT_SOUNDS]
SWEP.AttackHitFlesh = HIT_SOUNDS[1]
SWEP.Attack2HitFlesh = HIT_SOUNDS[#HIT_SOUNDS]
SWEP.DeploySnd = "physics/plastic/plastic_box_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.BlockHoldPos = Vector(-7.5,1,10)
SWEP.BlockHoldAng = Angle(18, 15, -20)

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.BreakBoneMul = 0.3
SWEP.PainMultiplier = 0.6

SWEP.SwingAng = -30
SWEP.SwingAng2 = 0

SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis"
SWEP.holsteredPos = Vector(-1.1, -9, -5.3)
SWEP.holsteredAng = Angle(195, 75, 230)
SWEP.Concealed = false
SWEP.HolsterIgnored = true
SWEP.Ignorebelt = true

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    return true
end

function SWEP:PrimaryAttack()
    self.AttackHit = self:GetRandomCinderHitSound()
    self.BaseClass.PrimaryAttack(self)
end

SWEP.AnimList["Attack_Charge_End"] = SWEP.AnimList["attack"]

SWEP.NoHolster = true
SWEP.MinSensivity = 0.75
SWEP.CinderHitSounds = HIT_SOUNDS

function SWEP:GetRandomCinderHitSound()
    return self.CinderHitSounds[math.random(#self.CinderHitSounds)]
end

function SWEP:InitAdd()
    for _, path in ipairs(HIT_SOUNDS) do
        util.PrecacheSound(path)
    end
end

SWEP.OilCharges = 5

local OIL_DECALS = {"Oil", "Dark", "Scorch", "FadingScorch"}

local SPLASH_SPRITES = {
    "effects/splash1",
    "effects/splash2",
    "effects/splash4",
}

local oilDecal

local function GetOilDecal()
    if oilDecal then return oilDecal end

    for _, name in ipairs(OIL_DECALS) do
        local mat = util.DecalMaterial(name)
        if mat and mat ~= "" then
            oilDecal = name
            return oilDecal
        end
    end

    oilDecal = "Scorch"
    return oilDecal
end

if CLIENT then
    local EFFECT = {}

    function EFFECT:Init(data)
        local pos = data:GetOrigin()
        local normal = data:GetNormal()

        local decal = GetOilDecal()
        for i = 1, 3 do
            local offset = VectorRand() * 8
            util.Decal(decal, pos + normal * 6 + offset, pos - normal * 10 + offset)
        end

        if data:GetFlags() == 1 then return end

        local emitter = ParticleEmitter(pos, false)
        if not IsValid(emitter) then return end

        for i = 1, 16 do
            local p = emitter:Add(SPLASH_SPRITES[math.random(#SPLASH_SPRITES)], pos)
            if p then
                p:SetVelocity(normal * math.Rand(60, 200) + VectorRand() * 80)
                p:SetGravity(Vector(0, 0, -600))
                p:SetAirResistance(20)
                p:SetDieTime(math.Rand(0.4, 0.8))
                p:SetStartAlpha(255)
                p:SetEndAlpha(220)
                p:SetStartSize(math.Rand(1.5, 3.5))
                p:SetEndSize(math.Rand(1, 2.5))
                p:SetRoll(math.Rand(0, 360))
                p:SetColor(15, 12, 10)
                p:SetLighting(false)
                p:SetCollide(true)
                p:SetCollideCallback(function(part)
                    part:SetDieTime(0)
                end)
            end
        end

        emitter:Finish()
    end

    function EFFECT:Think()
        return false
    end

    function EFFECT:Render()
    end

    effects.Register(EFFECT, "hg_oilsplash")
end

if SERVER then
    util.AddNetworkString("hg_oil_face")

    local FACE_TIME = 10
    local puddles = {}
    local PUDDLE_RADIUS = 28
    local PUDDLE_LIFE = 120
    local MAX_PUDDLES = 40

    local function IsSoft(ent)
        if not IsValid(ent) then return false end
        if ent:IsPlayer() or ent:IsNPC() or ent:IsRagdoll() then return true end

        local owner = hg and hg.RagdollOwner and hg.RagdollOwner(ent)
        return IsValid(owner)
    end

    local function AddPuddle(pos)
        puddles[#puddles + 1] = {pos = pos, expire = CurTime() + PUDDLE_LIFE}
        if #puddles > MAX_PUDDLES then table.remove(puddles, 1) end
    end

    local function SendEffect(pos, normal, decalOnly)
        local ed = EffectData()
        ed:SetOrigin(pos + normal * 2)
        ed:SetNormal(normal)
        ed:SetFlags(decalOnly and 1 or 0)
        util.Effect("hg_oilsplash", ed, true, true)
    end

    local function GetVictim(ent)
        if not IsValid(ent) then return end
        if ent:IsPlayer() then return ent end

        local owner = hg and hg.RagdollOwner and hg.RagdollOwner(ent)
        if IsValid(owner) and owner:IsPlayer() then return owner end
    end

    local function IsHeadHit(victim, ent, trace)
        if ent == victim and trace.HitGroup == HITGROUP_HEAD then return true end

        local character = hg and hg.GetCurrentCharacter and hg.GetCurrentCharacter(victim) or victim
        if not IsValid(character) then return false end

        local bone = character:LookupBone("ValveBiped.Bip01_Head1")
        if not bone then return false end

        local m = character:GetBoneMatrix(bone)
        return m and trace.HitPos:DistToSqr(m:GetTranslation()) < 144
    end

    function SWEP:OilHit(ent, trace)
        if not trace or not trace.Hit then return end

        if (self.nextOil or 0) > CurTime() then return end
        self.nextOil = CurTime() + 0.6

        if self.OilLeft == nil then
            self.OilLeft = (math.random(2) == 1) and self.OilCharges or 0
        end

        if self.OilLeft <= 0 then return end
        self.OilLeft = self.OilLeft - 1

        local owner = self:GetOwner()
        local pos = trace.HitPos
        local hitNormal = trace.HitNormal or vector_up
        local soft = IsSoft(ent)

        local normal = hitNormal
        if soft and IsValid(owner) then
            normal = -owner:GetAimVector()
        end

        SendEffect(pos, normal, false)

        local floorPos

        if hitNormal.z > 0.7 then
            floorPos = pos
        elseif soft then
            local down = util.TraceLine({
                start = pos,
                endpos = pos - Vector(0, 0, 120),
                mask = MASK_SOLID_BRUSHONLY,
            })

            if down.Hit and down.HitNormal.z > 0.7 then
                floorPos = down.HitPos
                SendEffect(floorPos, down.HitNormal, true)
            end
        end

        if floorPos then AddPuddle(floorPos) end

        local victim = GetVictim(ent)
        if victim and victim ~= owner and IsHeadHit(victim, ent, trace) then
            net.Start("hg_oil_face")
                net.WriteFloat(FACE_TIME)
            net.Send(victim)
        end
    end

    function SWEP:PrimaryAttackAdd(ent, trace)
        self:OilHit(ent, trace)
    end

    function SWEP:SecondaryAttackAdd(ent, trace)
        self:OilHit(ent, trace)
    end

    local slipBones = {
        {"ValveBiped.Bip01_L_Foot", 1.3, 260}, {"ValveBiped.Bip01_R_Foot", 1.3, 260},
        {"ValveBiped.Bip01_L_Calf", 1.2, 220}, {"ValveBiped.Bip01_R_Calf", 1.2, 220},
        {"ValveBiped.Bip01_L_Thigh", 1.0, 140}, {"ValveBiped.Bip01_R_Thigh", 1.0, 140},
        {"ValveBiped.Bip01_Pelvis", 0.8, 60},
        {"ValveBiped.Bip01_Spine", 0.5, 0}, {"ValveBiped.Bip01_Spine2", 0.35, -30},
        {"ValveBiped.Bip01_Head1", 0.25, -40},
        {"ValveBiped.Bip01_L_Hand", 0.6, 120}, {"ValveBiped.Bip01_R_Hand", 0.6, 120},
    }

    local function IsFemale(ply)
        if ThatPlyIsFemale then return ThatPlyIsFemale(ply) end

        local mdl = string.lower(ply:GetModel() or "")
        return string.find(mdl, "female", 1, true) or string.find(mdl, "alyx", 1, true) or string.find(mdl, "mossman", 1, true)
    end

    local function Slip(ply, vel)
        if not (hg and hg.Fake) then return end

        ply.nextOilSlip = CurTime() + 4

        local dir = vel:GetNormalized()
        local speed = math.max(vel:Length(), 160)
        local pos = ply:GetPos()

        hg.Fake(ply)

        timer.Simple(0.05, function()
            if not IsValid(ply) then return end

            local rag = ply.FakeRagdoll
            if not IsValid(rag) then return end

            for i = 0, rag:GetPhysicsObjectCount() - 1 do
                local phys = rag:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    phys:Wake()
                    phys:SetVelocity(dir * speed * 0.6)
                end
            end

            for _, info in ipairs(slipBones) do
                local bone = rag:LookupBone(info[1])
                local physBone = bone and rag:TranslateBoneToPhysBone(bone)
                local phys = physBone and rag:GetPhysicsObjectNum(physBone)

                if IsValid(phys) then
                    phys:SetVelocity(dir * speed * info[2] + Vector(0, 0, info[3]))
                end
            end
        end)

        local voice = FirstExisting(IsFemale(ply)
            and {"vo/npc/female01/ow01.wav", "vo/npc/female01/ow02.wav"}
            or {"vo/npc/male01/ow01.wav", "vo/npc/male01/ow02.wav"})
        if voice then sound.Play(voice, pos + Vector(0, 0, 60), 75, math.random(95, 105)) end

        timer.Simple(0.35, function()
            local impact = FirstExisting({"physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", "physics/body/body_medium_impact_hard1.wav"})
            if impact then sound.Play(impact, pos, 75, math.random(90, 105)) end
        end)
    end

    local nextCheck = 0

    hook.Add("Think", "HG_OilBucketSlip", function()
        local now = CurTime()
        if now < nextCheck then return end
        nextCheck = now + 0.1

        if #puddles == 0 then return end

        for i = #puddles, 1, -1 do
            if puddles[i].expire <= now then table.remove(puddles, i) end
        end

        for _, ply in ipairs(player.GetAll()) do
            if ply:Alive() and ply:OnGround() and ply:GetMoveType() == MOVETYPE_WALK
                and not IsValid(ply.FakeRagdoll) and (ply.nextOilSlip or 0) <= now then

                local vel = ply:GetVelocity()
                vel.z = 0

                if vel:Length() > 60 then
                    local pos = ply:GetPos()

                    for _, puddle in ipairs(puddles) do
                        local dx, dy = pos.x - puddle.pos.x, pos.y - puddle.pos.y

                        if dx * dx + dy * dy < PUDDLE_RADIUS * PUDDLE_RADIUS and math.abs(pos.z - puddle.pos.z) < 24 then
                            Slip(ply, vel)
                            break
                        end
                    end
                end
            end
        end
    end)
end

local PICKUP_MODELS = {
    ["models/props_junk/plasticbucket001a.mdl"] = true,
}
local ITEM_CLASS = string.StripExtension(string.GetFileFromFilename(debug.getinfo(1, "S").short_src))
local ITEM_NAME = SWEP.PrintName

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end
        if not PICKUP_MODELS[string.lower(ent:GetModel() or "")] then return false end

        if (ply.NextOilBucketPickup or 0) > CurTime() then return false end
        ply.NextOilBucketPickup = CurTime() + 0.5

        if ply:HasWeapon(ITEM_CLASS) then return false end

        local wep = ply:Give(ITEM_CLASS)
        if not IsValid(wep) then return false end

        ent:Remove()
        ply:SelectWeapon(ITEM_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_OilBucketPickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_OilBucketPickupKey", function(ply, key)
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

    hook.Add("Think", "HG_OilBucketHint", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() or not hg or not hg.eyeTrace then return end

        local tr = hg.eyeTrace(lply)
        if not tr then return end

        local ent = tr.Entity
        if not IsValid(ent) or ent.HudHintMarkup then return end
        if ent:GetClass() ~= "prop_physics" or not PICKUP_MODELS[string.lower(ent:GetModel() or "")] then return end

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

if CLIENT then
    local faceEnd = 0
    local faceTotal = 10
    local blobs = {}
    local blobMat = Material("particle/particle_smokegrenade")

    net.Receive("hg_oil_face", function()
        faceTotal = math.max(net.ReadFloat(), 1)
        faceEnd = CurTime() + faceTotal

        blobs = {}
        local w, h = ScrW(), ScrH()
        for i = 1, 14 do
            blobs[i] = {
                x = math.Rand(0.1, 0.9) * w,
                y = math.Rand(0.05, 0.75) * h,
                size = math.Rand(0.15, 0.35) * h,
                rot = math.Rand(0, 360),
                drip = math.Rand(6, 24),
            }
        end
    end)

    hook.Add("HUDPaint", "HG_OilFace", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() then
            faceEnd = 0
            return
        end

        local remaining = faceEnd - CurTime()
        if remaining <= 0 then return end

        local k = math.Clamp(remaining / (faceTotal * 0.6), 0, 1)
        local elapsed = faceTotal - remaining

        surface.SetMaterial(blobMat)

        for _, b in ipairs(blobs) do
            surface.SetDrawColor(10, 8, 6, 235 * k)
            surface.DrawTexturedRectRotated(b.x, b.y + elapsed * b.drip, b.size, b.size, b.rot)
        end
    end)
end
