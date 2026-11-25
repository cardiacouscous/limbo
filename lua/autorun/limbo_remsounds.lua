--[[
	Limbo: Remorse's sounds, each with its own switch (server settings, 1 = Remorse's, 0 = Z-City's):
	  limbo_rem_gunsounds   - Remorse's gunshots, reloads and handling sounds
	  limbo_rem_bodysounds  - Remorse's bone breaks, skull fractures, blood drips,
	                          bullet-on-flesh hits, fall pain and crawling
	  limbo_rem_explosions  - Remorse's extra explosion layer
	Remorse's versions live under sound/limbo_rem/ (and bonefracture/, skullfracture/,
	arteryblooddrip/, newblooddrip/, explosionextra/) in Limbo Content, so Z-City's own
	files are untouched and come back when a switch is off.
	Sounds from Remorse (AGPL-3.0); see limbo_content credits.txt.
]]

local FL = bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY)
local cvGuns = CreateConVar("limbo_rem_gunsounds", "1", FL, "Remorse's gun sounds (0 = Z-City's)", 0, 1)
local cvBody = CreateConVar("limbo_rem_bodysounds", "1", FL, "Remorse's bone, blood and flesh sounds (0 = Z-City's)", 0, 1)
CreateConVar("limbo_rem_explosions", "1", FL, "Remorse's extra explosion layer (0 = off)", 0, 1)
-- gore switches live here too so the Settings menu can see them
CreateConVar("limbo_rem_torso", "1", FL, "Explosions can split bodies in half (0 = off)", 0, 1)
CreateConVar("limbo_rem_headgib", "1", FL, "Remorse's head gibbing (0 = Z-City's)", 0, 1)

LimboRem = LimboRem or {}
function LimboRem.Body() return cvBody:GetBool() end

local GUNS = {}
for _, p in ipairs({
	"arc9_eft_shared/weap_ar_pickup.ogg",
	"arc9_eft_shared/weap_bolt_catch.ogg",
	"arc9_eft_shared/weap_bolt_out.ogg",
	"arc9_eft_shared/weap_dmr_pickup.ogg",
	"arc9_eft_shared/weap_dmr_use.ogg",
	"arc9_eft_shared/weap_pump_drop.ogg",
	"arc9_eft_shared/weap_rifle_drop.ogg",
	"arc9_eft_shared/weap_rifle_pickup.ogg",
	"arc9_eft_shared/weap_rifle_use.ogg",
	"arccw_uc/common/fire-22-01.ogg",
	"arccw_uc/common/fire-22-sup-01.ogg",
	"hndg_beretta92fs/beretta92_fire1.wav",
	"homigrad/weapons/draw_hmg.mp3",
	"homigrad/weapons/draw_pistol.mp3",
	"homigrad/weapons/draw_rifle.mp3",
	"homigrad/weapons/pistols/deagle-1.wav",
	"homigrad/weapons/pistols/mac10-1.wav",
	"homigrad/weapons/pistols/mp5-1.wav",
	"homigrad/weapons/pistols/ump45-3.wav",
	"homigrad/weapons/rifle/m4a1-1.wav",
	"m16a4/m16a4_fp.wav",
	"m4a1/m4a1_dist.wav",
	"m4a1/m4a1_fp.wav",
	"m9/m9_dist.wav",
	"mp5k/mp5k_dist.wav",
	"mp5k/mp5k_suppressed_tp.wav",
	"mp5k/mp5k_tp.wav",
	"pwb/weapons/uzi/clipin.wav",
	"pwb/weapons/uzi/clipout.wav",
	"pwb2/weapons/vectorsmg/boltrelease.wav",
	"sounds_zcity/fn45/close.wav",
	"toz_shotgun/toz_dist.wav",
	"toz_shotgun/toz_fp.wav",
	"weapons/ak74/ak74_boltback.wav",
	"weapons/ak74/ak74_boltrelease.wav",
	"weapons/ak74/ak74_fp.wav",
	"weapons/ak74/ak74_magin.wav",
	"weapons/ak74/ak74_magout.wav",
	"weapons/ak74/ak74_magout_rattle.wav",
	"weapons/ak74/ak74_suppressed_fp.wav",
	"weapons/ak74/ak74_suppressed_tp.wav",
	"weapons/ak74/ak74_tp.wav",
	"weapons/arccw_ud/870/fire-01.ogg",
	"weapons/arccw_ud/870/rack_1.ogg",
	"weapons/arccw_ud/870/rack_2.ogg",
	"weapons/arccw_ud/m1014/breechclose.ogg",
	"weapons/arccw_ud/m1014/breechload.ogg",
	"weapons/arccw_ud/m16/grab.ogg",
	"weapons/arccw_ud/m16/magin.ogg",
	"weapons/arccw_ud/m16/magout.ogg",
	"weapons/arccw_ud/m16/magout_empty.ogg",
	"weapons/m45/m45_boltrelease.wav",
	"weapons/m4a1/m4a1_boltarelease.wav",
	"weapons/m4a1/m4a1_magain.wav",
	"weapons/m4a1/m4a1_magout.wav",
	"weapons/m67/handling/m67_pinpull.wav",
	"weapons/m67/m67_spooneject.wav",
	"weapons/newakm/akmm_boltback.wav",
	"weapons/newakm/akmm_boltrelease.wav",
	"weapons/newakm/akmm_dist.wav",
	"weapons/newakm/akmm_fp.wav",
	"weapons/newakm/akmm_magin.wav",
	"weapons/newakm/akmm_magout.wav",
	"weapons/newakm/akmm_suppressed_fp.wav",
	"weapons/newakm/akmm_suppressed_tp.wav",
	"weapons/newakm/akmm_tp.wav",
	"weapons/shoot/shot1.wav",
	"weapons/tfa_ins2/ak103/ak103_fp.wav",
	"weapons/tfa_ins2/doublebarrel/doublebarrel_fire.wav",
	"weapons/tfa_ins2/doublebarrel_sawnoff/doublebarrelsawn_fire.wav",
	"weapons/tfa_ins2/k98/m40a1_fp.wav",
	"weapons/tfa_ins2/m1garand/garand_fp.wav",
	"weapons/tfa_ins2/mp7/boltback.wav",
	"weapons/tfa_ins2/mp7/boltrelease.wav",
	"weapons/tfa_ins2/mp7/magin.wav",
	"weapons/tfa_ins2/mp7/magout.wav",
	"weapons/tfa_ins2/mwr_p90/p90_fire1.wav",
	"weapons/tfa_ins2/sks/sks_dist.wav",
	"weapons/tfa_ins2/sks/sks_fp.wav",
	"weapons/tfa_ins2/swmodel10/revolver_open_chamber.wav",
	"weapons/tfa_ins2/thanez_cobra/revolver_dump_rounds_01.wav",
	"weapons/tfa_ins2/thanez_cobra/revolver_speed_loader_insert_01.wav",
	"weapons/tfa_ins2/usp_match/usp_match_boltrelease.wav",
	"weapons/tfa_ins2/usp_tactical/fp_suppressed1.wav",
	"weapons/tfa_ins2/usp_tactical/magout.wav",
	"weapons/tfa_ins2/usp_tactical/magrelease.wav",
	"zcitysnd/sound/weapons/aks74u/aks_dist.wav",
	"zcitysnd/sound/weapons/aks74u/aks_fp.wav",
	"zcitysnd/sound/weapons/firearms/hndg_beretta92fs/beretta92_fire1.wav",
	"zcitysnd/sound/weapons/firearms/hndg_glock17/glock_fire_01.wav",
	"zcitysnd/sound/weapons/firearms/hndg_mkiii/mkiii_fire_01.wav",
	"zcitysnd/sound/weapons/firearms/shtg_remington870/remington_fire_01.wav",
	"zcitysnd/sound/weapons/m45/m45_fp.wav",
	"zcitysnd/sound/weapons/m45/m45_suppressed_fp.wav",
	"zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",
	"zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	"zcitysnd/sound/weapons/m9/handling/m9_magout.wav",
	"zcitysnd/sound/weapons/makarov/makarov_dist.wav",
	"zcitysnd/sound/weapons/makarov/makarov_fp.wav",
	"zcitysnd/sound/weapons/makarov/makarov_suppressed_fp.wav",
	"zcitysnd/sound/weapons/mk18/mk18_dist.wav",
	"zcitysnd/sound/weapons/mp5k/mp5k_fp.wav",
	"zcitysnd/sound/weapons/revolver/revolver_fp.wav",
	"pwb2/weapons/m4a1/ru-556 bolt back.wav",
	"pwb2/weapons/m4a1/ru-556 bolt forward.wav",
	"pwb2/weapons/m4a1/ru-556 clip in 2.wav",
	"pwb2/weapons/m4a1/ru-556 clip out 1.wav",
}) do GUNS[p] = true end

local BODY = {}
for _, p in ipairs({
	"physics/flesh/flesh_impact_bullet1.wav",
	"physics/flesh/flesh_impact_bullet2.wav",
	"physics/flesh/flesh_impact_bullet3.wav",
	"physics/flesh/flesh_impact_bullet4.wav",
	"physics/flesh/flesh_impact_bullet5.wav",
	"player/pl_fallpain1.wav",
	"player/pl_fallpain3.wav",
	"weapons/universal/uni_crawl_l_01.wav",
	"weapons/universal/uni_crawl_l_02.wav",
	"weapons/universal/uni_crawl_l_03.wav",
	"weapons/universal/uni_crawl_l_04.wav",
	"weapons/universal/uni_crawl_l_05.wav",
}) do BODY[p] = true end

local string_lower, string_gsub, string_match, string_sub = string.lower, string.gsub, string.match, string.sub

-- swaps a sound path for Remorse's version when its switch is on; anything else passes through
local function Swap(name)
	if not isstring(name) then return name end
	local pre = string_match(name, "^[%^%)%(<>#%*@!%?]*") or ""
	local p = string_lower(string_gsub(string_sub(name, #pre + 1), "\\", "/"))
	if (GUNS[p] and cvGuns:GetBool()) or (BODY[p] and cvBody:GetBool()) then
		return pre .. "limbo_rem/" .. p
	end
	return name
end
LimboRem.Swap = Swap

local ENT = FindMetaTable("Entity")
local oldEntEmit = LimboRem.oldEntEmit or ENT.EmitSound
LimboRem.oldEntEmit = oldEntEmit
ENT.EmitSound = function(self, name, ...) return oldEntEmit(self, Swap(name), ...) end

local oldEmit = LimboRem.oldEmit or EmitSound
LimboRem.oldEmit = oldEmit
EmitSound = function(name, ...) return oldEmit(Swap(name), ...) end

local oldPlay = LimboRem.oldPlay or sound.Play
LimboRem.oldPlay = oldPlay
sound.Play = function(name, ...) return oldPlay(Swap(name), ...) end

-- sounds the engine plays itself (bullet impacts on flesh)
hook.Add("EntityEmitSound", "limbo_remsounds", function(t)
	local new = Swap(t.SoundName)
	if new ~= t.SoundName then
		t.SoundName = new
		return true
	end
end)

if CLIENT then return end

-- Remorse's extra explosion layer, on top of whatever the explosion already plays
local EXPLO = {}
for i = 1, 9 do EXPLO[i] = "explosionextra/explode_" .. i .. ".wav" end
local lastPos, lastTime = nil, 0

local oldBlast = LimboRem.oldBlast or util.BlastDamage
LimboRem.oldBlast = oldBlast
util.BlastDamage = function(inflictor, attacker, pos, radius, damage, ...)
	if GetConVar("limbo_rem_explosions"):GetBool() and isvector(pos) and (radius or 0) >= 150 and (damage or 0) >= 20 then
		-- one layer per explosion, even when it deals its damage in several calls
		if not (lastPos and CurTime() - lastTime < 0.3 and lastPos:DistToSqr(pos) < 200 * 200) then
			lastPos, lastTime = Vector(pos), CurTime()
			local snd = EXPLO[math.random(#EXPLO)]
			local idx = (IsValid(inflictor) and inflictor:EntIndex() or 0)
			oldEmit(snd, pos, idx + 400, CHAN_ITEM, 1, 145, 0, math.random(95, 105))
			local p = Vector(pos)
			timer.Simple(0.04, function()
				oldEmit(snd, p, idx + 401, CHAN_AUTO, 0.7, 135, 0, math.random(90, 100))
			end)
		end
	end
	return oldBlast(inflictor, attacker, pos, radius, damage, ...)
end
