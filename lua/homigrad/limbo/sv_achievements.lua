-- Limbo: what unlocks Limbo's achievements (the achievements themselves are listed in achievements/sv_achievement.lua)

local function Give(ply, key, add)
	if not IsValid(ply) or not ply:IsPlayer() or ply:IsBot() then return end
	if not hg.achievements or not hg.achievements.GetAchievementInfo(key) then return end
	if add then
		hg.achievements.AddPlayerAchievement(ply, key, add)
	else
		hg.achievements.SetPlayerAchievement(ply, key, 1)
	end
end

-- the player behind a ragdoll or a player
local function PlayerOf(ent)
	if not IsValid(ent) then return end
	if ent:IsPlayer() then return ent end
	local owner = hg.RagdollOwner and hg.RagdollOwner(ent)
	if IsValid(owner) and owner:IsPlayer() then return owner end
end

-- who gets the blame for a death
local function KillerOf(victim, attacker)
	local k = PlayerOf(attacker)
	if IsValid(k) and k ~= victim then return k end
	k = victim.ZBestAttacker
	if IsValid(k) and k:IsPlayer() and k ~= victim then return k end
end

--\\ traps: remember who placed them (Z-City forgets a grenade's owner after 90 seconds)
local trapClasses = {ent_claymore = true, ent_hg_slam = true}
hook.Add("OnEntityCreated", "limbo_achievements_traps", function(ent)
	timer.Simple(0, function()
		if not IsValid(ent) then return end
		local class = ent:GetClass()
		if not trapClasses[class] and not string.StartWith(class, "ent_hg_grenade") then return end
		local placer = ent.owner2 or ent.owner
		if IsValid(placer) and placer:IsPlayer() then ent.limboPlacer = placer end
		ent.limboPlacedAt = CurTime()
	end)
end)

local function IsTrap(ent)
	if not IsValid(ent) then return false end
	if trapClasses[ent:GetClass()] then return true end
	-- a grenade rigged as a tripwire is welded in place; a thrown one isn't
	return string.StartWith(ent:GetClass(), "ent_hg_grenade") and ent.cons2 ~= nil
end
--//

--\\ deaths: Short-lived, Martyrdom (bleeding out), bookkeeping
local function Died(victim, attacker)
	victim.limboDiedAt = CurTime()
	victim.limboDiedPos = victim:GetPos()

	-- Short-lived: died within a few seconds of a kill
	if victim.limboLastKillAt and CurTime() - victim.limboLastKillAt <= 5 then
		Give(victim, "limbo_shortlived")
	end
	victim.limboLastKillAt = nil

	local killer = KillerOf(victim, attacker)
	victim.limboKilledBy = killer

	if IsValid(killer) then
		killer.limboLastKillAt = CurTime()

		-- Martyrdom: the person who killed you dies to what you did before you died (a wound, a grenade)
		if killer.limboKilledBy == victim and killer.limboDiedAt and CurTime() - killer.limboDiedAt < 120
			and killer.limboDiedAt < CurTime() then
			Give(killer, "limbo_martyrdom")
		end
	end
end

hook.Add("PlayerDeath", "limbo_achievements", function(victim, inflictor, attacker)
	Died(victim, attacker)

	-- remember whose body this is, for the looting achievements
	timer.Simple(0.2, function()
		if not IsValid(victim) then return end
		local rag = victim.RagdollDeath
		if not IsValid(rag) then rag = victim:GetNWEntity("RagdollDeath") end
		if IsValid(rag) then rag.limboCorpseOf = victim end
	end)
end)

hook.Add("OnNPCKilled", "limbo_achievements", function(npc, attacker)
	local k = PlayerOf(attacker)
	if IsValid(k) then k.limboLastKillAt = CurTime() end
end)
--//

--\\ damage after death: Martyrdom (grenades etc.) and Forgot about that (traps)
hook.Add("EntityTakeDamage", "limbo_achievements", function(target, dmg)
	local victim = PlayerOf(target)
	if not IsValid(victim) or not victim:Alive() then return end

	local inflictor = dmg:GetInflictor()
	local responsible = IsValid(inflictor) and inflictor.limboPlacer or PlayerOf(dmg:GetAttacker())
	if not IsValid(responsible) or responsible == victim then return end

	local diedAt = responsible.limboDiedAt
	if not diedAt then return end

	local madeBefore = IsValid(inflictor) and inflictor ~= responsible and inflictor:GetCreationTime() < diedAt
	local posthumous = (not responsible:Alive() or madeBefore) and (madeBefore or CurTime() - diedAt < 60)
	if not posthumous then return end

	-- Forgot about that: a trap placed at least 2 minutes ago, far from where you died
	if IsTrap(inflictor) and inflictor.limboPlacer == responsible then
		local age = CurTime() - (inflictor.limboPlacedAt or inflictor:GetCreationTime())
		local far = responsible.limboDiedPos and responsible.limboDiedPos:DistToSqr(inflictor:GetPos()) >= 600 * 600
		if age >= 120 and far then Give(responsible, "limbo_forgot") end
	end

	-- Martyrdom: hurting the one who killed you
	if responsible.limboKilledBy == victim and CurTime() - diedAt < 120 then
		Give(responsible, "limbo_martyrdom")
	end
end)
--//

--\\ Long way down: break a leg in a fall and live
local function CheckFall(ply)
	local org = ply.organism
	if not org then return end
	local before = (org.lleg or 0) >= 1 and (org.rleg or 0) >= 1
	if before then return end
	timer.Simple(4, function()
		if not IsValid(ply) or not ply:Alive() or not ply.organism then return end
		local o = ply.organism
		if (o.lleg or 0) >= 1 or (o.rleg or 0) >= 1 then Give(ply, "limbo_longwaydown") end
	end)
end

hook.Add("OnPlayerHitGround", "limbo_achievements", function(ply, inWater, onFloater, speed)
	if inWater or speed < 500 then return end
	CheckFall(ply)
end)

hook.Add("EntityTakeDamage", "limbo_achievements_fall", function(target, dmg)
	if not dmg:IsDamageType(DMG_FALL) then return end
	local ply = PlayerOf(target)
	if IsValid(ply) and ply:Alive() then CheckFall(ply) end
end)
--//

--\\ looting: Hand-me-down, Leftovers, Keepsake
hook.Add("Limbo_TookItem", "limbo_achievements", function(ply, ent, tab)
	if not IsValid(ent) or ent:IsPlayer() then return end -- a living, knocked-down player isn't a body
	local isBody = ent.limboCorpse or ent.limboCorpseOf or ent:IsRagdoll()
	if not isBody then return end

	if ent.limboCorpseOf == ply then
		Give(ply, "limbo_keepsake")
		return
	end

	if tab == "Weapons" or tab == "Armor" then Give(ply, "limbo_handmedown") end

	ent.limboLootedBy = ent.limboLootedBy or {}
	if not ent.limboLootedBy[ply] then
		ent.limboLootedBy[ply] = true
		Give(ply, "limbo_leftovers", 1)
	end
end)
--//

hook.Add("PlayerSpawn", "limbo_achievements", function(ply)
	ply.limboLastKillAt = nil
end)
