--[[
	Limbo: near-miss thoughts
	When a bullet passes close to you without hitting you, you get a short line like
	"A bullet whizzed past your head." Shown with Z-City's normal thoughts, at most every few seconds.
	limbo_nearmiss 1 (default) / 0 = off
	Lines and detection from the Remorse fork of Z-City (AGPL-3.0).
]]

local cvOn = CreateConVar("limbo_nearmiss", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY),
	"Thoughts when a bullet barely misses you", 0, 1)

local lines = {
	"A bullet barely missed you.",
	"A bullet whizzed past your head.",
	"A bullet flew by your ear.",
	"A bullet narrowly missed you.",
	"A bullet grazed past you.",
	"A bullet passed within inches of your head.",
	"A bullet went past you.",
	"A bullet missed you, but barely.",
}

local NEAR = 125 -- how close the bullet's path has to pass your head (about 2.4 m)

local function OwnerOf(ent)
	if not IsValid(ent) then return end
	if ent:IsPlayer() then return ent end
	if hg and hg.RagdollOwner then
		local ply = hg.RagdollOwner(ent)
		if IsValid(ply) then return ply end
	end
end

local function NearMiss(ply)
	if (ply.limboNearMissNext or 0) > CurTime() then return end
	if ply.Notify and ply:Notify(lines[math.random(#lines)], 12, "limbo_nearmiss", 0) then
		ply.limboNearMissNext = CurTime() + 6
	end
end

hook.Add("EntityFireBullets", "limbo_nearmiss", function(entity, data)
	if not cvOn:GetBool() or not IsValid(entity) then return end
	if (data.limit_ricochet or 0) > 0 or (data.penetrated or 0) > 0 then return end

	local oldCallback = data.Callback
	local shooter = IsValid(data.Attacker) and data.Attacker or (entity.GetOwner and entity:GetOwner() or entity)

	data.Callback = function(attacker, tr, dmginfo, ...)
		shooter = IsValid(attacker) and attacker or shooter
		local hitPly = OwnerOf(tr.Entity)
		if IsValid(hitPly) then hitPly.limboHitTime = CurTime() + 0.25 end

		local src = data.Src
		local dir = tr.HitPos - src
		local length = dir:Length()

		if length > 0 then
			dir:Normalize()
			for _, ply in ipairs(player.GetAll()) do
				if ply:Alive() and ply ~= shooter and ply ~= entity and ply ~= hitPly and (ply.limboHitTime or 0) < CurTime() then
					local head = ply:GetPos() + Vector(0, 0, 50)
					local closest = src + dir * math.Clamp((head - src):Dot(dir), 0, length)
					if head:Distance(closest) < NEAR then NearMiss(ply) end
				end
			end
		end

		if oldCallback then return oldCallback(attacker, tr, dmginfo, ...) end
	end
end)
