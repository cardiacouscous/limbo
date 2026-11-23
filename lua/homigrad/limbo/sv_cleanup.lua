-- Limbo: corpse and dropped weapon cleanup
--
-- What gets cleaned: death corpses (players and NPCs) and weapons lying on the ground with no owner.
-- What never gets cleaned:
--   * each player's latest corpse, with the gear Z-City stores on it (until that player dies again)
--   * ragdolls spawned from the spawn menu, map-placed weapons, weapons spawned from the spawn menu
--     that nobody has picked up yet
--   * anything frozen (posed with the physgun) or parented to something (mounted guns, loot on a corpse)
--   * anything with a living player within limbo_cleanup_radius
-- Things are removed instantly (no fade).

local cv_on = GetConVar("limbo_cleanup")
local cv_time = GetConVar("limbo_cleanup_time")
local cv_keep = GetConVar("limbo_cleanup_keeplast")
local cv_radius = GetConVar("limbo_cleanup_radius")

local CHECK_EVERY = 30 -- seconds between passes

local corpses = {} -- [ragdoll] = true

local function MarkCorpse(rag)
	if not IsValid(rag) or rag.limboCorpse then return end
	rag.limboCorpse = true
	rag.limboSince = CurTime()
	corpses[rag] = true
end

-- player corpses: Z-City links the body in its own DoPlayerDeath hook, so read it a moment later
hook.Add("PlayerDeath", "limbo_cleanup", function(ply)
	timer.Simple(0.2, function()
		if not IsValid(ply) then return end
		local rag = ply.RagdollDeath
		if not IsValid(rag) then rag = ply:GetNWEntity("RagdollDeath") end
		if not IsValid(rag) then return end

		MarkCorpse(rag)

		-- the previous corpse goes back into the normal cleanup, starting its timer now
		local old = ply.limboLastCorpse
		if IsValid(old) and old ~= rag then
			old.limboKeptBy = nil
			old.limboSince = CurTime()
		end

		rag.limboKeptBy = ply
		ply.limboLastCorpse = rag
	end)
end)

-- NPC corpses
hook.Add("CreateEntityRagdoll", "limbo_cleanup", function(owner, rag)
	if IsValid(owner) and owner:IsNPC() then MarkCorpse(rag) end
end)

-- a player who leaves no longer keeps a corpse
hook.Add("PlayerDisconnected", "limbo_cleanup", function(ply)
	local rag = ply.limboLastCorpse
	if IsValid(rag) and rag.limboKeptBy == ply then
		rag.limboKeptBy = nil
		rag.limboSince = CurTime()
	end
end)

-- guns from the spawn menu stay until someone has held them
hook.Add("PlayerSpawnedSWEP", "limbo_cleanup", function(ply, wep)
	if IsValid(wep) then wep.limboSpawned = true end
end)

hook.Add("EntityRemoved", "limbo_cleanup", function(ent)
	corpses[ent] = nil
end)

local function IsFrozen(ent)
	for i = 0, ent:GetPhysicsObjectCount() - 1 do
		local phys = ent:GetPhysicsObjectNum(i)
		if IsValid(phys) and not phys:IsMoveable() then return true end
	end
	return false
end

local function PlayerNearby(pos, living)
	local r = cv_radius:GetFloat()
	if r <= 0 then return false end
	r = r * r
	for _, p in ipairs(living) do
		if p:GetPos():DistToSqr(pos) < r then return true end
	end
	return false
end

local function IsKept(rag)
	return cv_keep:GetBool() and IsValid(rag.limboKeptBy) and rag.limboKeptBy.limboLastCorpse == rag
end

-- a living player's own ragdoll (knocked down) is never a corpse
local function IsLivingBody(rag)
	local owner = hg and hg.RagdollOwner and hg.RagdollOwner(rag)
	return IsValid(owner) and owner:IsPlayer() and owner:Alive() and owner.FakeRagdoll == rag
end

local function RemoveCorpse(rag)
	-- the hidden loot Z-City parented to the body goes with it
	for _, child in ipairs(rag:GetChildren()) do
		if IsValid(child) and child:IsWeapon() and not IsValid(child:GetOwner()) then child:Remove() end
	end
	rag:Remove()
end

local function Pass(force)
	local now = CurTime()
	local maxAge = cv_time:GetFloat() * 60
	local removed = 0

	local living = {}
	for _, p in ipairs(player.GetAll()) do
		if p:Alive() then living[#living + 1] = p end
	end

	-- corpses
	for rag in pairs(corpses) do
		if not IsValid(rag) then corpses[rag] = nil continue end
		if IsKept(rag) or IsLivingBody(rag) or IsFrozen(rag) then continue end
		if not force then
			if now - (rag.limboSince or now) < maxAge then continue end
			if PlayerNearby(rag:GetPos(), living) then continue end
		end
		RemoveCorpse(rag)
		corpses[rag] = nil
		removed = removed + 1
	end

	-- dropped weapons
	for _, wep in ents.Iterator() do
		if not IsValid(wep) or not wep:IsWeapon() then continue end

		if IsValid(wep:GetOwner()) then
			wep.limboSpawned = nil
			wep.limboFreeSince = nil
			continue
		end

		if wep.limboSpawned or wep:MapCreationID() ~= -1 then continue end
		if IsValid(wep:GetParent()) or IsFrozen(wep) then wep.limboFreeSince = nil continue end

		wep.limboFreeSince = wep.limboFreeSince or now
		if not force then
			if now - wep.limboFreeSince < maxAge then continue end
			if PlayerNearby(wep:GetPos(), living) then continue end
		end
		wep:Remove()
		removed = removed + 1
	end

	return removed
end

timer.Create("limbo_cleanup", CHECK_EVERY, 0, function()
	if cv_on:GetBool() then Pass(false) end
end)

-- clear everything that isn't kept, frozen or parented, right now (ignores age and distance)
concommand.Add("limbo_cleanup_now", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	local n = Pass(true)
	local msg = "[Limbo] Cleanup removed " .. n .. " things."
	if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
end)
