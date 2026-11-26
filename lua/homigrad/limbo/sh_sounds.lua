-- Limbo: footstep set and gear rattle
--
-- limbo_zcityfootsteps 0 (default): footsteps use Limbo's set (from Remorse's content) where it has a sound for
--   the surface; 1: Z-City's own footsteps. Player classes with their own footsteps keep theirs.
-- limbo_gearrattle 1 (default): running with gear on (armor, or two or more weapons) rattles,
--   so you can hear someone coming before you see them.

local flags = {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}
local cv_zcsteps = CreateConVar("limbo_zcityfootsteps", "0", flags, "Limbo: 1 = Z-City's footsteps, 0 = Limbo's footstep set", 0, 1)
local cv_rattle = CreateConVar("limbo_gearrattle", "1", flags, "Limbo: running with gear on makes it rattle", 0, 1)

if CLIENT then return end

local stepCache = {}

-- "player/footsteps/concrete1.wav" -> "limbo/footsteps/concrete1.wav" if Limbo has it
local function LimboStep(sound)
	if not isstring(sound) then return end
	local cached = stepCache[sound]
	if cached ~= nil then return cached or nil end
	local name = string.GetFileFromFilename(sound)
	local path = "limbo/footsteps/" .. name
	local found = file.Exists("sound/" .. path, "GAME") and path or false
	stepCache[sound] = found
	return found or nil
end

hook.Add("HG_PlayerFootstep", "limbo_footsteps", function(ply, pos, foot, sound, volume, rf)
	if cv_zcsteps:GetBool() then return end
	if (ply.PlayerClassName or "") ~= "" then return end -- classes keep their own footsteps
	if ply:IsWalking() or ply:Crouching() then return end
	if hg.GetCurrentCharacter(ply) ~= ply then return end

	local snd = LimboStep(sound)
	if not snd then return end

	EmitSound(snd, pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, math.random(95, 105))
	return true
end)

local function HasGear(ply)
	local armor = ply:GetNetVar("Armor", {})
	if istable(armor) and next(armor) ~= nil then return true end

	local count = 0
	for _, wep in ipairs(ply:GetWeapons()) do
		local class = wep:GetClass()
		if class ~= "weapon_hands_sh" and class ~= "gmod_tool" and class ~= "weapon_physgun" and class ~= "gmod_camera" then
			count = count + 1
			if count >= 2 then return true end
		end
	end
	return false
end

hook.Add("HG_PlayerFootstep_Notify", "limbo_gearrattle", function(ply, pos)
	if not cv_rattle:GetBool() then return end
	if not hg.KeyDown(ply, IN_SPEED) or ply:Crouching() then return end
	if hg.GetCurrentCharacter(ply) ~= ply then return end
	if (ply.limboNextRattle or 0) > CurTime() then return end
	if math.random() > 0.6 then return end
	if not HasGear(ply) then return end

	ply.limboNextRattle = CurTime() + 0.3
	EmitSound("limbo/gear/gear_rattle" .. math.random(1, 26) .. ".wav", pos, ply:EntIndex(), CHAN_AUTO, 0.45, 65, nil, math.random(92, 108))
end)
