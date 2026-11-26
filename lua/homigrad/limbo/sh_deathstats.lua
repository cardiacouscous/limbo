-- Limbo: death stats. When you die, two quiet lines show in the bottom-left corner, each with a tick:
--   how you died ("Bled out", "Shot dead", ...)
--   who did it, with what, from how far ("Shot by Marcus · Glock 17 · 14 m")
-- Using kill (or respawning) after someone hurt you counts as their kill, not "Killed self".
-- limbo_deathstats 1 (default) / 0 = off

local cvOn = CreateConVar("limbo_deathstats", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY),
	"Limbo: show how you died in the corner when you die", 0, 1)

if SERVER then
	util.AddNetworkString("limbo_deathstats")

	local RECENT = 120 -- seconds a hit still counts for whoever did it
	local UNITS_TO_M = 0.01905

	local function PlayerOf(ent)
		if not IsValid(ent) then return end
		if ent:IsPlayer() then return ent end
		local owner = hg.RagdollOwner and hg.RagdollOwner(ent)
		if IsValid(owner) and owner:IsPlayer() then return owner end
	end

	local function NiceClass(class)
		class = string.gsub(class or "", "^npc_", "")
		class = string.gsub(class, "^weapon_", "")
		class = string.gsub(class, "^ent_", "")
		class = string.gsub(class, "_", " ")
		return class
	end

	local function WeaponName(ent)
		if not IsValid(ent) then return end
		local name = ent.PrintName
		if not isstring(name) or name == "" or string.StartWith(name, "#") then name = NiceClass(ent:GetClass()) end
		return name
	end

	local function AttackerName(att)
		if att:IsPlayer() then return att.GetPlayerName and att:GetPlayerName() or att:Nick() end
		if att:IsNPC() or att:IsNextBot() then return "a " .. NiceClass(att:GetClass()) end
	end

	-- the weapon behind a hit: a thrown thing (grenade, molotov) or the attacker's gun
	local function HitWeapon(att, inflictor)
		if IsValid(inflictor) and inflictor ~= att and not inflictor:IsPlayer() and not inflictor:IsNPC() then
			return WeaponName(inflictor)
		end
		if att.GetActiveWeapon then
			local wep = att:GetActiveWeapon()
			if IsValid(wep) then return WeaponName(wep) end
		end
	end

	local verbs = {
		{DMG_BULLET, "Shot", "Shot dead"},
		{DMG_BUCKSHOT, "Shot", "Shot dead"},
		{DMG_BLAST, "Blown up", "Blown up"},
		{DMG_SLASH, "Cut", "Cut down"},
		{DMG_BURN, "Burned", "Burned to death"},
		{DMG_CLUB, "Beaten", "Beaten to death"},
		{DMG_CRUSH, "Crushed", "Crushed"},
		{DMG_FALL, "Pushed", "Fell to death"},
		{DMG_DROWN, "Drowned", "Drowned"},
		{DMG_NERVEGAS, "Poisoned", "Poisoned"},
		{DMG_POISON, "Poisoned", "Poisoned"},
		{DMG_SHOCK, "Electrocuted", "Electrocuted"},
	}
	local function Verbs(dmgType)
		for _, v in ipairs(verbs) do
			if bit.band(dmgType or 0, v[1]) ~= 0 then return v[2], v[3] end
		end
		return "Killed", "Killed"
	end

	hook.Add("EntityTakeDamage", "limbo_deathstats", function(target, dmg)
		local victim = PlayerOf(target)
		if not IsValid(victim) or not victim:Alive() or dmg:GetDamage() <= 0 then return end
		local now = CurTime()
		victim.LimboLastHitType = dmg:GetDamageType()
		local att = dmg:GetAttacker()
		local attPly = PlayerOf(att)
		if IsValid(attPly) then att = attPly end
		if not IsValid(att) or att == victim or not (att:IsPlayer() or att:IsNPC() or att:IsNextBot()) then return end
		local body = IsValid(victim.FakeRagdoll) and victim.FakeRagdoll or victim
		victim.LimboLastAttack = {
			name = AttackerName(att),
			weapon = HitWeapon(att, dmg:GetInflictor()),
			dist = math.Round(att:GetPos():Distance(body:GetPos()) * UNITS_TO_M),
			type = dmg:GetDamageType(),
			time = now,
		}
	end)

	local function BledOut(org)
		return org and isnumber(org.blood) and org.blood < 3000
	end

	local function Suffocated(org)
		return org and istable(org.o2) and isnumber(org.o2[1]) and org.o2[1] <= 1
	end

	hook.Add("PlayerDeath", "limbo_deathstats", function(victim, inflictor, attacker)
		if not cvOn:GetBool() or victim:IsBot() then return end
		local org = victim.organism
		local rec = victim.LimboLastAttack
		if rec and CurTime() - rec.time > RECENT then rec = nil end
		victim.LimboLastAttack = nil

		local selfKill = attacker == victim or not IsValid(attacker) or attacker:IsWorld()
		local cause
		if BledOut(org) then
			cause = "Bled out"
		elseif Suffocated(org) then
			cause = "Suffocated"
		elseif selfKill and rec then
			cause = "Died of wounds"
		elseif selfKill and attacker == victim then
			cause = "Killed self"
		else
			local _, dead = Verbs(victim.LimboLastHitType)
			cause = dead == "Killed" and "Died" or dead
		end
		victim.LimboLastHitType = nil

		local line2 = ""
		if rec and rec.name then
			local by = Verbs(rec.type)
			line2 = by .. " by " .. rec.name
			if rec.weapon and rec.weapon ~= "" and rec.type ~= DMG_FALL then line2 = line2 .. "  ·  " .. rec.weapon end
			if rec.dist and rec.dist > 1 then line2 = line2 .. "  ·  " .. rec.dist .. " m" end
		end

		net.Start("limbo_deathstats")
		net.WriteString(cause)
		net.WriteString(line2)
		net.Send(victim)
	end)

	hook.Add("PlayerSpawn", "limbo_deathstats", function(ply)
		ply.LimboLastAttack, ply.LimboLastHitType = nil, nil
	end)
	return
end

surface.CreateFont("Limbo_DeathStats1", {font = "Limbo Dokdo", size = math.max(18, ScreenScale(7)), weight = 400, antialias = true})
surface.CreateFont("Limbo_DeathStats2", {font = "Limbo Dokdo", size = math.max(14, ScreenScale(5.3)), weight = 400, antialias = true})

local TICK = "ui/rem_tik.wav"
local FADE_IN, GAP, HOLD, FADE_OUT, MIN_SHOW = 0.12, 0.6, 7, 0.8, 3
local shown -- {cause, line2, start}

net.Receive("limbo_deathstats", function()
	shown = {cause = net.ReadString(), line2 = net.ReadString(), start = CurTime(), ticked = 0}
end)

local col1, col2 = Color(232, 230, 225), Color(169, 166, 158)
local shadow = Color(0, 0, 0)

local function Line(text, font, x, y, col, alpha)
	shadow.a = alpha * 0.6
	draw.SimpleText(text, font, x + 1, y + 1, shadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	col.a = alpha
	draw.SimpleText(text, font, x, y, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

hook.Add("DrawOverlay", "limbo_deathstats", function()
	if not shown or gui.IsGameUIVisible() then return end
	local ply = LocalPlayer()
	local t = CurTime() - shown.start
	local endAt = shown.fadeFrom or (shown.start + HOLD)
	if IsValid(ply) and ply:Alive() and t > 0.5 and not shown.fadeFrom then
		shown.fadeFrom = math.max(CurTime(), shown.start + MIN_SHOW) -- respawned: fade out (after a short minimum)
		endAt = shown.fadeFrom
	end
	local out = math.Clamp((CurTime() - endAt) / FADE_OUT, 0, 1)
	if out >= 1 then shown = nil return end

	local hasLine2 = shown.line2 ~= ""
	if shown.ticked < 1 then shown.ticked = 1 surface.PlaySound(TICK) end
	if hasLine2 and shown.ticked < 2 and t >= GAP then shown.ticked = 2 surface.PlaySound(TICK) end

	local a1 = math.Clamp(t / FADE_IN, 0, 1) * (1 - out) * 255
	local a2 = math.Clamp((t - GAP) / FADE_IN, 0, 1) * (1 - out) * 255

	local x, y = ScrW() * 0.02, ScrH() - ScrH() * 0.03
	if hasLine2 then
		surface.SetFont("Limbo_DeathStats2")
		local _, h2 = surface.GetTextSize(shown.line2)
		Line(shown.line2, "Limbo_DeathStats2", x, y, col2, a2)
		y = y - h2
	end
	Line(shown.cause, "Limbo_DeathStats1", x, y, col1, a1)
end)
