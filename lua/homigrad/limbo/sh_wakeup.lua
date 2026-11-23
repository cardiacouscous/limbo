-- Limbo: "wake up"
--
-- Sometimes while you're knocked out, "wake up" fades in with [E] under it. It stays until you press E or
-- wake up on your own. Pressing E jolts you awake: consciousness straight back up, the shock that was holding
-- you under eased, a bit of adrenaline and the awaken sound. Injuries stay as they are.
-- Never offered while dying: heart stopped, bad brain damage, very low blood or no air.

local flags = {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}
local cv_on = CreateConVar("limbo_wakeup", "1", flags, "Limbo: sometimes offer \"wake up\" while knocked out", 0, 1)
local cv_chance = CreateConVar("limbo_wakeup_chance", "0.25", flags, "Limbo: chance per knockout that \"wake up\" shows (0-1)", 0, 1)

local NW = "limbo_wakeprompt"
local SOUND = "limbo/awaken.mp3"

if SERVER then
	util.AddNetworkString("limbo_wokeup")

	local function CanWake(org)
		if not org or not org.alive or org.heartstop then return false end
		if (org.brain or 0) >= 0.4 then return false end
		if (org.blood or 5000) < 2900 then return false end
		if istable(org.o2) and (org.o2[1] or 30) < 12 then return false end
		return true
	end

	hook.Add("Org Think", "limbo_wakeup", function(owner, org, timeValue)
		if not IsValid(owner) or not owner:IsPlayer() then return end

		if not org.otrub or not owner:Alive() then
			org.limboWakeRolled = nil
			org.limboWakeAt = nil
			if owner:GetNWBool(NW) then owner:SetNWBool(NW, false) end
			return
		end

		if not cv_on:GetBool() then return end

		-- one roll per knockout; if it hits, the prompt shows a few seconds in
		if not org.limboWakeRolled then
			org.limboWakeRolled = true
			if math.random() < cv_chance:GetFloat() then
				org.limboWakeAt = CurTime() + math.Rand(3, 8)
			end
		end

		local offer = org.limboWakeAt and CurTime() >= org.limboWakeAt and CanWake(org) or false
		if owner:GetNWBool(NW) ~= offer then owner:SetNWBool(NW, offer) end
	end)

	hook.Add("PlayerButtonDown", "limbo_wakeup", function(ply, button)
		if button ~= KEY_E or not ply:GetNWBool(NW) then return end
		local org = ply.organism
		if not org or not org.otrub or not CanWake(org) then return end

		org.consciousness = 1
		org.shock = math.min(org.shock or 0, (org.shock_turn or 10) * 2)
		org.needotrub = false
		org.limboWakeAt = nil
		if hg.organism.AddNaturalAdrenaline then hg.organism.AddNaturalAdrenaline(org, 0.5) end
		ply:SetNWBool(NW, false)

		if hg.achievements and hg.achievements.SetPlayerAchievement then
			hg.achievements.SetPlayerAchievement(ply, "limbo_notyet", 1)
		end

		net.Start("limbo_wokeup")
		net.Send(ply)
	end)

	hook.Add("PlayerDeath", "limbo_wakeup", function(ply)
		ply:SetNWBool(NW, false)
	end)
else
	surface.CreateFont("Limbo_Wake", {font = "Dokdo", size = ScreenScale(30), weight = 400, antialias = true})
	surface.CreateFont("Limbo_WakeKey", {font = "Dokdo", size = ScreenScale(12), weight = 400, antialias = true})

	net.Receive("limbo_wokeup", function()
		surface.PlaySound(SOUND)
	end)

	local fade, keyFade = 0, 0

	-- letters spaced out by hand
	local function DrawSpaced(text, font, x, y, spacing, col)
		surface.SetFont(font)
		local total = 0
		local widths = {}
		for i = 1, #text do
			local w = surface.GetTextSize(text:sub(i, i))
			widths[i] = w
			total = total + w + (i < #text and spacing or 0)
		end
		local cx = x - total / 2
		for i = 1, #text do
			draw.SimpleText(text:sub(i, i), font, cx, y, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			cx = cx + widths[i] + spacing
		end
	end

	hook.Add("DrawOverlay", "limbo_wakeup", function()
		local ply = LocalPlayer()
		local want = IsValid(ply) and ply:Alive() and ply:GetNWBool(NW)

		-- slow in (about 4 seconds), quick out
		fade = math.Approach(fade, want and 1 or 0, FrameTime() * (want and 0.25 or 3))
		keyFade = math.Approach(keyFade, (want and fade >= 1) and 1 or 0, FrameTime() * (want and 0.5 or 3))
		if fade <= 0 then return end

		local eased = fade * fade * (3 - 2 * fade)
		local breathe = 0.85 + 0.15 * math.sin(CurTime() * 1.3)
		local a = 255 * eased * breathe

		local cx, cy = ScrW() * 0.5, ScrH() * 0.5
		local drift = (1 - eased) * ScreenScale(4)
		DrawSpaced("wake up", "Limbo_Wake", cx, cy + drift, ScreenScale(2 + (1 - eased) * 4), Color(235, 235, 235, a))

		if keyFade > 0 then
			draw.SimpleText("[E]", "Limbo_WakeKey", cx, cy + ScreenScale(6), Color(224, 180, 60, 200 * keyFade * breathe), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end)
end
