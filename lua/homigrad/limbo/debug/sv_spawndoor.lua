-- Limbo debug: test door spawner (admins only). The debug folder is left out of Workshop builds.
--
-- limbo_spawndoor      spawns a wooden door where you're looking
-- limbo_spawndoor 1    same, but locked (shoot the handle to unlock it)

concommand.Add("limbo_spawndoor", function(ply, cmd, args)
	if not IsValid(ply) or not ply:IsAdmin() then return end

	local tr = ply:GetEyeTrace()
	if not tr.Hit then return end

	local yaw = ply:EyeAngles().y
	local door = ents.Create("prop_door_rotating")
	if not IsValid(door) then return end

	door:SetModel("models/props_c17/door01_left.mdl")
	door:SetKeyValue("hardware", "1")
	door:SetKeyValue("distance", "90")
	door:SetKeyValue("speed", "100")
	door:SetKeyValue("returndelay", "-1")
	door:SetKeyValue("spawnflags", "8192") -- use opens
	door:SetPos(tr.HitPos + tr.HitNormal * 2 + Vector(0, 0, 54))
	door:SetAngles(Angle(0, yaw + 180, 0))
	door:Spawn()
	door:Activate()

	if args[1] == "1" then door:Fire("Lock") end

	undo.Create("Limbo Door")
		undo.AddEntity(door)
		undo.SetPlayer(ply)
	undo.Finish()
end)
