-- Limbo: once per map, when a round mode starts (anything but Sandbox), say that Limbo is made for Sandbox.

local said = false
local NOTE = "Limbo is made for Sandbox. Round modes still work, but they'll feel close to plain Z-City."

hook.Add("ZB_StartRound", "limbo_sandboxnote", function()
	if said or engine.ActiveGamemode() == "sandbox" then return end
	said = true

	timer.Simple(2, function()
		PrintMessage(HUD_PRINTTALK, NOTE)
		MsgC(Color(224, 180, 60), "[limbo] ", color_white, NOTE, "\n")
	end)
end)
