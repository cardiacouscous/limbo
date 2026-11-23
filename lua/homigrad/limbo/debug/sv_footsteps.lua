-- Limbo debug: limbo_footsteps_debug 1 prints each footstep and which sound Limbo picks.
-- The debug folder is left out of Workshop builds.

local cv = CreateConVar("limbo_footsteps_debug", "0", {FCVAR_ARCHIVE}, "Limbo debug: print footsteps to the console", 0, 1)

hook.Add("HG_PlayerFootstep_Notify", "limbo_footsteps_debug", function(ply, pos, foot, sound)
	if not cv:GetBool() then return end
	local class = ply.PlayerClassName or ""
	local mine = "limbo/footsteps/" .. string.GetFileFromFilename(sound or "")
	print(string.format("[limbo] %s step %s | class '%s' | limbo file %s | walking %s crouching %s",
		ply:Nick(), tostring(sound), class, file.Exists("sound/" .. mine, "GAME") and "found" or "MISSING",
		tostring(ply:IsWalking()), tostring(ply:Crouching())))
end)
