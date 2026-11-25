--[[
	Limbo: Remorse's hands
	limbo_remorsehands 1 (default) - everyone gets Remorse's hands:
	    charge punch (E + left click with fists up), shove (E + right click), sprint shove,
	    Remorse's blocking and carrying
	limbo_remorsehands 0 - Z-City's normal hands

	The hands are Remorse's weapon_hg_coolhands (AGPL-3.0), shipped as weapon_rem_hands and
	registered over Z-City's own weapon_hg_coolhands, so the kick and the rest still find them.
	Zombies and furries keep their own hands.
]]

REMH = REMH or {}
local CLASS = "weapon_hg_coolhands"

local cvOn = CreateConVar("limbo_remorsehands", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY),
	"Remorse's hands for everyone (0 = Z-City's hands)", 0, 1)

function REMH.IsOurs(tbl) return istable(tbl) and tbl.REMH_Ours == true end
function REMH.ShoveKnockN() return 3 end
function REMH.ShoveForceMul() return 1 end

local function Takeover()
	local t = weapons.GetStored("weapon_rem_hands")
	if not t then return false end
	if REMH.IsOurs(weapons.GetStored(CLASS)) then return true end
	local copy = table.Copy(t)
	copy.ClassName = nil
	copy.Spawnable = false
	copy.REMH_Ours = true
	weapons.Register(copy, CLASS)
	return true
end
REMH.Takeover = Takeover

hook.Add("Initialize", "limbo_remhands", Takeover)
hook.Add("InitPostEntity", "limbo_remhands", function()
	Takeover()
	timer.Simple(1, Takeover)
	timer.Simple(5, Takeover)
end)
timer.Create("limbo_remhands_keep", 3, 0, Takeover)

-- a shove that doesn't knock you down makes you stumble for a moment
hook.Add("HG_MovementCalc_2", "limbo_remhands_stumble", function(mulTable, ply)
	if ply:GetNW2Float("remh_stumble", 0) > CurTime() then mulTable[1] = mulTable[1] * 0.35 end
end)

function REMH.OwnHands(ply)
	local c = string.lower(ply.PlayerClassName or "")
	return c == "furry" or string.find(c, "zombie", 1, true) ~= nil
end

function REMH.WantsRemorse(ply)
	return cvOn:GetBool() and not REMH.OwnHands(ply)
end

function REMH.HandsClass(ply)
	return REMH.WantsRemorse(ply) and CLASS or "weapon_hands_sh"
end

function REMH.HandsWeapon(ply)
	if not IsValid(ply) then return NULL end
	local w = ply:GetWeapon(REMH.HandsClass(ply))
	if IsValid(w) then return w end
	return ply:GetWeapon("weapon_hands_sh")
end

hg = hg or {}
if not hg.GetHandsWeaponClass then hg.GetHandsWeaponClass = REMH.HandsClass end
if not hg.GetHandsWeapon then hg.GetHandsWeapon = REMH.HandsWeapon end

if CLIENT then return end

if not hg.TriggerSprintCollisionStumble then
	function hg.TriggerSprintCollisionStumble(target)
		if not IsValid(target) or not target:IsPlayer() or not target:Alive() then return end
		target:SetNW2Float("remh_stumble", CurTime() + 0.6)
		target:ViewPunch(Angle(math.Rand(4, 8), math.Rand(-6, 6), math.Rand(-4, 4)))
	end
end

-- keep the hands out of Z-City's inventory list
local function CleanInv(ply)
	local inv = ply.inventory
	if istable(inv) and istable(inv.Weapons) and inv.Weapons[CLASS] ~= nil then
		inv.Weapons[CLASS] = nil
		if ply.SetNetVar then ply:SetNetVar("Inventory", inv) end
	end
end

local function IsHands(w)
	if not IsValid(w) then return false end
	local c = w:GetClass()
	return c == "weapon_hands_sh" or c == CLASS
end

function REMH.Apply(ply)
	if not IsValid(ply) or not ply:Alive() then return end
	local active = ply:GetActiveWeapon()
	local wasHands = IsHands(active) or not IsValid(active)

	if REMH.WantsRemorse(ply) then
		Takeover()
		local held = ply:GetWeapon(CLASS)
		if IsValid(held) and not held.REMH_Ours then ply:StripWeapon(CLASS) end
		if not ply:HasWeapon(CLASS) then ply:Give(CLASS) end
		if ply:HasWeapon("weapon_hands_sh") then ply:StripWeapon("weapon_hands_sh") end
		if wasHands and ply:HasWeapon(CLASS) then ply:SelectWeapon(CLASS) end
	elseif ply:HasWeapon(CLASS) then
		ply:StripWeapon(CLASS)
		if not ply:HasWeapon("weapon_hands_sh") and not ply:HasWeapon("weapon_zombclaws") then
			ply:Give("weapon_hands_sh")
		end
		if wasHands and ply:HasWeapon("weapon_hands_sh") then ply:SelectWeapon("weapon_hands_sh") end
	end
	CleanInv(ply)
end

-- after Z-City's own loadout
hook.Add("PlayerSpawn", "limbo_remhands", function(ply)
	timer.Simple(0.2, function() REMH.Apply(ply) end)
end)

-- catches the switch being flipped, class changes, and anything handing back the default hands
timer.Create("limbo_remhands_check", 1, 0, function()
	for _, ply in ipairs(player.GetAll()) do
		if ply:Alive() then
			local want = REMH.WantsRemorse(ply)
			local held = ply:GetWeapon(CLASS)
			local wrong = IsValid(held) and not held.REMH_Ours
			if (want and (not IsValid(held) or wrong or ply:HasWeapon("weapon_hands_sh"))) or (not want and IsValid(held)) then
				REMH.Apply(ply)
			end
		end
	end
end)

hook.Add("WeaponEquip", "limbo_remhands_inv", function(wep, ply)
	if IsValid(wep) and wep:GetClass() == CLASS then
		timer.Simple(0, function() if IsValid(ply) then CleanInv(ply) end end)
	end
end)
