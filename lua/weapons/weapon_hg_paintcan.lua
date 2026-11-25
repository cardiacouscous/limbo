-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Paint can"
SWEP.Instructions = "A can of paint. Splashes paint on whatever it hits (10 paint hits).\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

local CAN_MODEL = "models/props_junk/metal_paintcan001a.mdl"

SWEP.Weight = 0
SWEP.WorldModel = CAN_MODEL
SWEP.WorldModelExchange = CAN_MODEL
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

SWEP.weaponPos = Vector(0.1,0,0.3)
SWEP.weaponAng = Angle(0,10,-90)
SWEP.modelscale = 1
SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 18
SWEP.DamageSecondary = 6

SWEP.PenetrationPrimary = 1.5
SWEP.PenetrationSecondary = 1

SWEP.BlockTier = 1
SWEP.MaxPenLen = 3

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 1

SWEP.StaminaPrimary = 17
SWEP.StaminaSecondary = 8

SWEP.AttackLen1 = 60
SWEP.AttackLen2 = 55

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Attack_Quick",
    ["holster"] = "HoseUnquip",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/paint.png")
	SWEP.IconOverride = "melgun/paint.png"
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
    {"physics/metal/paintcan_impact_hard1.wav", "physics/metal/metal_canister_impact_hard1.wav", "physics/metal/metal_solid_impact_hard1.wav"},
    {"physics/metal/paintcan_impact_hard2.wav", "physics/metal/metal_canister_impact_hard2.wav", "physics/metal/metal_solid_impact_hard4.wav"},
    {"physics/metal/paintcan_impact_hard3.wav", "physics/metal/metal_canister_impact_hard3.wav", "physics/metal/metal_solid_impact_hard5.wav"},
}) do
    local path = FirstExisting(group)
    if path then HIT_SOUNDS[#HIT_SOUNDS + 1] = path end
end
if #HIT_SOUNDS == 0 then HIT_SOUNDS[1] = "physics/metal/metal_solid_impact_hard1.wav" end

SWEP.AttackHit = HIT_SOUNDS[1]
SWEP.Attack2Hit = HIT_SOUNDS[#HIT_SOUNDS]
SWEP.AttackHitFlesh = HIT_SOUNDS[1]
SWEP.Attack2HitFlesh = HIT_SOUNDS[#HIT_SOUNDS]
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.BlockHoldPos = Vector(-7.5,1,10)
SWEP.BlockHoldAng = Angle(18, 15, -20)

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.BreakBoneMul = 0.7
SWEP.PainMultiplier = 0.9

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

SWEP.PaintCharges = 10

local PAINT_STYLES = {
    {decal = "PaintSplatBlue",   color = Vector(0, 150, 255)},
    {decal = "PaintSplatGreen",  color = Vector(110, 220, 0)},
    {decal = "PaintSplatPink",   color = Vector(255, 80, 170)},
    {decal = "PaintSplatOrange", color = Vector(255, 140, 0)},
}

if SERVER then
    util.AddNetworkString("hg_paintcan_face_paint")

    local validStyles

    local function GetStyles()
        if validStyles then return validStyles end

        validStyles = {}
        for _, style in ipairs(PAINT_STYLES) do
            local mat = util.DecalMaterial(style.decal)
            if mat and mat ~= "" then
                validStyles[#validStyles + 1] = style
            end
        end

        if #validStyles == 0 then
            validStyles[1] = {decal = "Splash.Large", color = Vector(0, 150, 255)}
        end

        return validStyles
    end

    local function GetPaintVictim(ent)
        if not IsValid(ent) then return end
        if ent:IsPlayer() then return ent end

        local owner = hg and hg.RagdollOwner and hg.RagdollOwner(ent)
        if IsValid(owner) and owner:IsPlayer() then return owner end
    end

    local function IsFaceHit(character, trace)
        if not IsValid(character) or not trace or not trace.Hit then return false end

        if trace.HitGroup == HITGROUP_HEAD then return true end

        local bone = character:LookupBone("ValveBiped.Bip01_Head1")
        if not bone then return false end

        local matrix = character:GetBoneMatrix(bone)
        if not matrix then return false end

        return trace.HitPos:DistToSqr(matrix:GetTranslation()) <= 18 * 18
    end

    function SWEP:PaintHit(ent, trace)
        if not trace or not trace.Hit then return end

        local victim = GetPaintVictim(ent)
        if IsValid(victim) and IsFaceHit(ent, trace) then
            net.Start("hg_paintcan_face_paint")
                net.WriteFloat(10)
            net.Send(victim)
        end

        if (self.nextPaint or 0) > CurTime() then return end
        self.nextPaint = CurTime() + 0.6

        if self.PaintLeft == nil then
            self.PaintLeft = (math.random(2) == 1) and self.PaintCharges or 0
        end

        if self.PaintLeft <= 0 then return end
        self.PaintLeft = self.PaintLeft - 1

        if not self.paintStyle then
            local styles = GetStyles()
            self.paintStyle = styles[math.random(#styles)]
        end

        local pos = trace.HitPos
        local normal = trace.HitNormal or vector_up

        for i = 1, 3 do
            local offset = VectorRand() * 8
            util.Decal(self.paintStyle.decal, pos + normal * 8 + offset, pos - normal * 8 + offset)
        end

        local ed = EffectData()
        ed:SetOrigin(pos + normal * 2)
        ed:SetNormal(normal)
        ed:SetScale(3)
        util.Effect("WaterSplash", ed, true, true)
    end

    function SWEP:PrimaryAttackAdd(ent, trace)
        self:PaintHit(ent, trace)
    end

    function SWEP:SecondaryAttackAdd(ent, trace)
        self:PaintHit(ent, trace)
    end
end

local PICKUP_MODELS = {
    ["models/props_junk/metal_paintcan001a.mdl"] = true,
    ["models/props_junk/metal_paintcan001b.mdl"] = true,
}
local ITEM_CLASS = string.StripExtension(string.GetFileFromFilename(debug.getinfo(1, "S").short_src))
local ITEM_NAME = SWEP.PrintName

if SERVER then
    local function TryPickup(ply, ent)
        if not IsValid(ply) or not IsValid(ent) or not ply:Alive() then return false end
        if ent:GetClass() ~= "prop_physics" then return false end
        if not PICKUP_MODELS[string.lower(ent:GetModel() or "")] then return false end

        if (ply.NextPaintCanPickup or 0) > CurTime() then return false end
        ply.NextPaintCanPickup = CurTime() + 0.5

        if ply:HasWeapon(ITEM_CLASS) then return false end

        local wep = ply:Give(ITEM_CLASS)
        if not IsValid(wep) then return false end

        ent:Remove()
        ply:SelectWeapon(ITEM_CLASS)

        return true
    end

    hook.Add("PlayerUse", "HG_PaintCanPickup", function(ply, ent)
        if not ply:KeyDown(IN_WALK) then return end -- Limbo: Alt + E to grab
        if TryPickup(ply, ent) then return false end
    end)

    hook.Add("KeyPress", "HG_PaintCanPickupKey", function(ply, key)
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

    hook.Add("Think", "HG_PaintCanHint", function()
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
    local facePaintEnd = 0
    local facePaintDuration = 10

    local function MakePaintBlob(cx, cy, radius, seed)
        local poly = {}
        local count = 20

        for i = 1, count do
            local angle = (i - 1) / count * math.pi * 2
            local wobble = 0.78 + ((i * 17 + seed * 13) % 9) / 30
            poly[#poly + 1] = {
                x = cx + math.cos(angle) * radius * wobble,
                y = cy + math.sin(angle) * radius * wobble
            }
        end

        return poly
    end

    local function DrawPaintBlob(cx, cy, radius, alpha, seed)
        surface.SetDrawColor(255, 255, 255, alpha)
        surface.DrawPoly(MakePaintBlob(cx, cy, radius, seed))
    end

    net.Receive("hg_paintcan_face_paint", function()
        facePaintDuration = math.max(net.ReadFloat(), 0.1)
        facePaintEnd = CurTime() + facePaintDuration
    end)

    hook.Add("HUDPaint", "HG_PaintCanFacePaint", function()
        local remaining = facePaintEnd - CurTime()
        if remaining <= 0 then return end

        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then
            facePaintEnd = 0
            return
        end

        local t = math.Clamp(remaining / facePaintDuration, 0, 1)
        local fade = t * t * (3 - 2 * t)
        local alpha = math.floor(238 * fade)

        local cx, cy = ScrW() * 0.5, ScrH() * 0.46
        local scale = math.min(ScrW(), ScrH()) / 900

        DrawPaintBlob(cx, cy, 82 * scale, alpha, 1)
        DrawPaintBlob(cx - 48 * scale, cy - 25 * scale, 48 * scale, alpha, 2)
        DrawPaintBlob(cx + 45 * scale, cy - 32 * scale, 53 * scale, alpha, 3)
        DrawPaintBlob(cx - 25 * scale, cy + 48 * scale, 46 * scale, alpha, 4)
        DrawPaintBlob(cx + 54 * scale, cy + 35 * scale, 39 * scale, alpha, 5)

        surface.SetDrawColor(255, 255, 255, alpha)
        for i = 1, 4 do
            local x = cx + (i - 2.5) * 22 * scale
            surface.DrawRect(x, cy + 75 * scale, 7 * scale, (18 + i * 5) * scale)
        end
    end)
end
