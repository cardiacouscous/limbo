-- Limbo: what the ESC menu shows under your character (last death, this session)

if SERVER then
	util.AddNetworkString("limbo_menustats")

	local function PlayerOf(ent)
		if not IsValid(ent) then return end
		if ent:IsPlayer() then return ent end
		local owner = hg.RagdollOwner and hg.RagdollOwner(ent)
		if IsValid(owner) and owner:IsPlayer() then return owner end
	end

	local function Send(ply, kind, cause)
		if not IsValid(ply) or ply:IsBot() then return end
		net.Start("limbo_menustats")
		net.WriteString(kind)
		net.WriteString(cause or "")
		net.Send(ply)
	end

	local function NiceNPC(ent)
		local name = string.gsub(ent:GetClass(), "^npc_", "")
		name = string.gsub(name, "_", " ")
		return name
	end

	hook.Add("PlayerDeath", "limbo_menustats", function(victim, inflictor, attacker)
		local killer = PlayerOf(attacker)
		if not (IsValid(killer) and killer ~= victim) then
			local best = victim.ZBestAttacker
			killer = IsValid(best) and best:IsPlayer() and best ~= victim and best or nil
		end

		local cause
		if IsValid(killer) then
			cause = "killed by " .. killer:Nick()
			Send(killer, "kill")
		elseif IsValid(attacker) and attacker:IsNPC() then
			cause = "killed by a " .. NiceNPC(attacker)
		elseif attacker == victim then
			cause = "by your own hand"
		elseif victim.organism and (victim.organism.blood or 5000) < 3000 then
			cause = "bled out"
		else
			cause = "died"
		end
		Send(victim, "death", cause)
	end)

	hook.Add("OnNPCKilled", "limbo_menustats", function(npc, attacker)
		local k = PlayerOf(attacker)
		if IsValid(k) then Send(k, "kill") end
	end)
	return
end

hg.LimboStats = hg.LimboStats or {kills = 0, deaths = 0, longest = 0}

net.Receive("limbo_menustats", function()
	local kind, cause = net.ReadString(), net.ReadString()
	local stats = hg.LimboStats
	if kind == "kill" then
		stats.kills = stats.kills + 1
	elseif kind == "death" then
		stats.deaths = stats.deaths + 1
		stats.lastDeath = {cause = cause, time = CurTime()}
		if stats.lifeStart then
			stats.longest = math.max(stats.longest, CurTime() - stats.lifeStart)
			stats.lifeStart = nil
		end
	end
end)

-- when a new life starts
hook.Add("Think", "limbo_menustats", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local stats = hg.LimboStats
	local alive = ply:Alive()
	if alive and (stats.wasAlive == false or (stats.wasAlive == nil and not stats.lifeStart)) then
		stats.lifeStart = CurTime()
	end
	stats.wasAlive = alive
end)
