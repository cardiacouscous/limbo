--[[
	Limbo: compatibility with other mods
	limbo_compat 1 (default) - adjust Limbo for mods it knows about, when they're installed:

	Milsim Weapon Acoustics (and Dynamic Weapon Reverb)
	  - guns tell it when their suppressor is on (it can't read Z-City's suppressors itself)
	  - Z-City's own distant gunshot is played quieter while Milsim is running,
	    so Milsim's echo leads instead of the two doubling up

	Nothing here does anything when those mods aren't installed.
]]

hg = hg or {}
hg.LimboCompat = hg.LimboCompat or {}
local C = hg.LimboCompat

local cvCompat = CreateConVar("limbo_compat", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY),
	"Adjust Limbo for installed mods it knows about (Milsim Weapon Acoustics...)", 0, 1)

local DIST_VOLUME_WITH_MILSIM = 0.45

function C.On() return cvCompat:GetBool() end

-- Milsim Weapon Acoustics installed and turned on
function C.Milsim()
	if not MWA then return false end
	local cv = GetConVar("sv_mwa_enabled")
	return not cv or cv:GetBool()
end

-- how loud Z-City's own distant gunshot plays (1 = normal)
function C.DistVolume()
	if C.On() and C.Milsim() then return DIST_VOLUME_WITH_MILSIM end
	return 1
end

-- called by the gun base every step: lets reverb mods know about Z-City's suppressors
function C.MarkSuppressor(wep, suppressed)
	if C.On() then
		wep.MWA_Suppressed = suppressed
		wep.dwr_customIsSuppressed = suppressed
	else
		wep.MWA_Suppressed = nil
		wep.dwr_customIsSuppressed = nil
	end
end
