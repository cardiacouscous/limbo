-- Limbo: from NekiraS Melee Z-CITY (Workshop 3840464523) by Beta_mraww and artemif, converted to Limbo's melee base (charge attacks, Alt + E to grab props)
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Swiss Army Knife"
SWEP.Instructions = "multi-tool pocketknife. R+LMB to change mode to slash/stab. RMB to interact with environment."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/jaanus/swissknife_bigblade.mdl"
SWEP.WorldModelReal = "models/weapons/salat/reanim/c_s&wch0014.mdl"
SWEP.WorldModelExchange = "models/jaanus/swissknife_bigblade.mdl"


SWEP.SuicidePos = Vector(-6, 2, -9)
SWEP.SuicideAng = Angle(-30, 0, 0)
SWEP.SuicideCutVec = Vector(-1, -5, 1)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.CanSuicide = true
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)

SWEP.basebone = 39
SWEP.weaponPos = Vector(-0.5,-0.8,1)
SWEP.weaponAng = Angle(0,90,170)

SWEP.HoldPos = Vector(-4,0,-2)

SWEP.BreakBoneMul = 0.20

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "stab",
    ["attack2"] = "midslash1",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("melgun/swknife.png")
	SWEP.IconOverride = "melgun/swknife.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.DeploySnd = ""

SWEP.AttackPos = Vector(0,0,0)
SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 15
SWEP.DamageSecondary = 13

SWEP.PenetrationPrimary = 5
SWEP.PenetrationSecondary = 3
SWEP.BleedMultiplier = 1

SWEP.MaxPenLen = 3

SWEP.PainMultiplier = 0.7

SWEP.PenetrationSizePrimary = 1.5
SWEP.PenetrationSizeSecondary = 1

SWEP.StaminaPrimary = 9
SWEP.StaminaSecondary = 11

SWEP.AttackLen1 = 44
SWEP.AttackLen2 = 35

function SWEP:Reload()
    if SERVER then
        if self:GetOwner():KeyPressed(IN_ATTACK) then
            self:SetNetVar("mode", not self:GetNetVar("mode"))
            self:GetOwner():ChatPrint("Changed mode to "..(self:GetNetVar("mode") and "slash." or "stab."))
        end
    end
end

function SWEP:CanPrimaryAttack()
    if self:GetOwner():KeyDown(IN_RELOAD) then return end
    if not self:GetNetVar("mode") then
        return true
    else
        self.allowsec = true
	self:SecondaryAttack(true) -- fix: use DoSecondaryAttack for slash, not SecondaryAttack which blocks
        self.allowsec = nil
        return false
    end
end

function SWEP:CanSecondaryAttack()
    return self.allowsec and true or false
end


SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 80
SWEP.AttackRads2 = 55

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = false
SWEP.MultiDmg2 = true

--\\ Смена инструмента (модели + характеристики) через круговое меню (Q)
SWEP.IsSwissKnife = true

local posDefault, angDefault = Vector(-0.5, -0.8, 1), Angle(0, 90, 170)
local posAlt, angAlt = Vector(-0.2, -0.8, 0.8), Angle(0, -90, 170)

-- name - название в меню, model - модель, pos/ang - положение в руке,
-- stats - характеристики оружия в этом режиме (кровотечение, боль, переломы, урон...)
SWEP.ToolModels = {
    { -- 1: закрытый нож, тупой удар, почти без крови
        name = "Closed", model = "models/jaanus/swissknife_closed.mdl", pos = posDefault, ang = angDefault,
        stats = {
            DamageType = DMG_CLUB,
            DamagePrimary = 6, DamageSecondary = 5,
            PenetrationPrimary = 1, PenetrationSecondary = 1,
            BleedMultiplier = 0, PainMultiplier = 0.5, BreakBoneMul = 0.3,
        },
    },
    { -- 2: маленькое лезвие, слабый порез
        name = "Small blade", model = "models/jaanus/swissknife_smlblade.mdl", pos = posAlt, ang = angAlt,
        stats = {
            DamageType = DMG_SLASH,
            DamagePrimary = 9, DamageSecondary = 8,
            PenetrationPrimary = 3, PenetrationSecondary = 2,
            BleedMultiplier = 0.6, PainMultiplier = 0.5, BreakBoneMul = 0.1,
        },
    },
    { -- 3: большое лезвие, самый сильный режим (как было раньше)
        name = "Big blade", model = "models/jaanus/swissknife_bigblade.mdl", pos = posDefault, ang = angDefault,
        stats = {
            DamageType = DMG_SLASH,
            DamagePrimary = 15, DamageSecondary = 13,
            PenetrationPrimary = 5, PenetrationSecondary = 3,
            BleedMultiplier = 1, PainMultiplier = 0.7, BreakBoneMul = 0.2,
        },
    },
    { -- 4: открывашка для бутылок, тупой слабый удар
        name = "Bottle opener", model = "models/jaanus/swissknife_btlopener.mdl", pos = posDefault, ang = angDefault,
        stats = {
            DamageType = DMG_CLUB,
            DamagePrimary = 5, DamageSecondary = 4,
            PenetrationPrimary = 1, PenetrationSecondary = 1,
            BleedMultiplier = 0.15, PainMultiplier = 0.4, BreakBoneMul = 0.2,
        },
    },
    { -- 5: консервный нож, острый крючок, но хуже лезвий
        name = "Can opener", model = "models/jaanus/swissknife_canopener.mdl", pos = posAlt, ang = angAlt,
        stats = {
            DamageType = DMG_SLASH,
            DamagePrimary = 8, DamageSecondary = 6,
            PenetrationPrimary = 3, PenetrationSecondary = 2,
            BleedMultiplier = 0.5, PainMultiplier = 0.5, BreakBoneMul = 0.1,
        },
    },
}
SWEP.DefaultTool = 3 -- Big blade

function SWEP:GetTool()
    return self.ToolModels[self:GetNetVar("tool", self.DefaultTool)] or self.ToolModels[self.DefaultTool]
end

function SWEP:ApplyToolStats()
    local tool = self:GetTool()
    if self.appliedTool == tool then return end
    self.appliedTool = tool

    for key, value in pairs(tool.stats) do
        self[key] = value
    end
end

function SWEP:ThinkAdd()
    self:ApplyToolStats()

    local tool = self:GetTool()
    self.weaponPos = tool.pos
    self.weaponAng = tool.ang
end

function SWEP:GetWorldModelExchange()
    local tool = self:GetTool()

    -- база берёт позицию/угол модели в руке из этих полей
    self.weaponPos = tool.pos
    self.weaponAng = tool.ang

    return tool.model
end

if SERVER then
    util.AddNetworkString("SwissKnife_SetTool")

    net.Receive("SwissKnife_SetTool", function(len, ply)
        local idx = net.ReadUInt(4)
        local wep = ply:GetActiveWeapon()

        if not IsValid(wep) or not wep.IsSwissKnife then return end
        if not wep.ToolModels[idx] then return end

        wep:SetNetVar("tool", idx)
        wep:ApplyToolStats() -- сразу, не дожидаясь следующего тика
    end)
end

if CLIENT then
    local function OpenToolMenu(wep)
        local options = {}

        -- кнопка выхода: возвращает в обычное круговое меню
        options[1] = {function()
            hg.CreateRadialMenu()
            return -1
        end, "Exit"}

        for i, tool in ipairs(wep.ToolModels) do
            options[#options + 1] = {function()
                net.Start("SwissKnife_SetTool")
                    net.WriteUInt(i, 4)
                net.SendToServer()
            end, tool.name}
        end

        hg.CreateRadialMenu(options, false)
        input.SetCursorPos(ScrW() / 2, ScrH() / 2)
    end

    hook.Add("radialOptions", "swissknife_change_tool", function()
        local ply = LocalPlayer()
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not wep.IsSwissKnife then return end

        hg.radialOptions[#hg.radialOptions + 1] = {function()
            OpenToolMenu(wep)
            return -1 -- не закрывать меню, мы открыли подменю
        end, "Change the tool"}
    end)
end
--//
