--[[
	Limbo: head gibbing
	limbo_rem_headgib 1 (default) - Remorse's head gibbing: a torn-up head stump in a few stages,
	    skull and jaw pieces flying off, blood spilling from the stump and the pieces
	limbo_rem_headgib 0 - Z-City's own head explosion
	Remorse's version is from the Remorse fork of Z-City (AGPL-3.0); its gore models come from
	other gore mods, credited in Limbo Content's credits.txt.
]]
local cvHeadGib = CreateConVar("limbo_rem_headgib", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY), "Remorse's head gibbing (0 = Z-City's)", 0, 1)

local net, hg, pairs, Vector, ents, IsValid, util = net, hg, pairs, Vector, ents, IsValid, util

local vecZero = Vector(0,0,0)
local vecInf = Vector(0,0,0) / 0

local function removeBone(rag, bone, phys_bone, nohuys)
	if !nohuys then rag:ManipulateBoneScale(bone, vecZero) end
	--rag:ManipulateBonePosition(bone,vecInf) -- Thanks Rama (only works on certain graphics cards!)

	if rag.gibRemove[phys_bone] then return end

	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	phys_obj:EnableCollisions(false)
	phys_obj:SetMass(0.1)
	--rag:RemoveInternalConstraint(phys_bone)

	constraint.RemoveAll(phys_obj)
	rag.gibRemove[phys_bone] = phys_obj
end

local function recursive_bone(rag, bone, list)
	for i,bone in pairs(rag:GetChildBones(bone)) do
		if bone == 0 then continue end

		list[#list + 1] = bone

		recursive_bone(rag, bone, list)
	end
end

function Gib_RemoveBone(rag, bone, phys_bone, nohuys)
	rag.gibRemove = rag.gibRemove or {}

	removeBone(rag, bone, phys_bone, nohuys)

	local list = {}
	recursive_bone(rag, bone, list)
	for i, bone in pairs(list) do
		removeBone(rag, bone, rag:TranslateBoneToPhysBone(bone), nohuys)
	end
end

gib_ragdols = gib_ragdols or {}
local gib_ragdols = gib_ragdols

local VectorRand, ents_Create = VectorRand, ents.Create
local vector_up = Vector(0,0,1)
local function PhysCallback( ent, data )
	--data.HitPos -- data.HitNormal
	if data.DeltaTime < 0.2 then return end
	ent:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav")
	-- if !data.HitEntity:IsPlayer() and !data.HitEntity:IsRagdoll() and math.abs(data.HitNormal.z) < 0.75 then
	-- 	ent:SetMoveType(MOVETYPE_NONE)
	-- 	ent:SetSolid(SOLID_NONE)

	-- 	local tr = util.QuickTrace(data.HitPos - data.HitNormal * 1, data.HitNormal)
	-- 	ent:SetPos(tr.HitPos)
	-- 	local entindex = ent:EntIndex()
	-- 	local speed = math.Rand(0.2,0.4)
	-- 	local randspeed = math.Rand(-0.3,0.3)
	-- 	local needDecal = CurTime() + 1
	-- 	ent:SetModelScale(0, 10)
	-- 	SafeRemoveEntityDelayed(ent, 10)
	-- 	timer.Create("meatMove"..entindex, 0.1, 0, function()
	-- 		if !IsValid(ent) then timer.Remove("meatMove"..entindex) return end
	-- 		local tr = util.QuickTrace(ent:GetPos(), -data.HitNormal:Angle():Up())
	-- 		if math.abs(tr.HitNormal.z) > 0.75 then timer.Remove("meatMove"..entindex) return end
	-- 		local ang = data.HitNormal:Angle()
	-- 		ent:SetPos(ent:GetPos() - ang:Up() * speed + ang:Right() * randspeed)
	-- 		randspeed = LerpFT(0.05,randspeed, 0)
	-- 		if needDecal < CurTime() then
	-- 			needDecal = CurTime() + math.Rand(1,3)
	-- 			util.Decal("Normal.Blood24", ent:GetPos() - data.HitNormal * 1, ent:GetPos() + data.HitNormal * 1, ent)
	-- 		end
	-- 	end)
	-- end

	util.Decal("Normal.Blood24", data.HitPos - data.HitNormal * 1, data.HitPos + data.HitNormal * 1, ent)
end

local grub, mat, gamemod = Model("models/grub_nugget_small.mdl"), "models/flesh", engine.ActiveGamemode()
local meatModels = {
	Model("models/props_junk/watermelon01_chunk02a.mdl"),
}
local gibRemoveTime = 60 --120
function SpawnMeatGore(mainent, pos, count, force, scale, models)
	force = force or Vector(0,0,0)
	models = models or meatModels
	for i = 1, (count or math.random(8, 10)) do
		local ent = ents_Create("prop_physics")
		ent:SetModel(models[math.random(#models)])
		if models == meatModels then ent:SetSubMaterial(0, mat) end
		ent:SetPos(pos)
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		ent:SetModelScale(math.Rand(0.8,1.1) * (scale or 1))
		ent:SetAngles(AngleRand(-180,180))
		ent:Activate()
		ent:Spawn()

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(mainent:GetVelocity() + VectorRand(-65,65) + force / 10)
			phys:AddAngleVelocity(VectorRand(-65,65))
		end

		if zb.CROUND and zb.CROUND ~= "hmcd" or gamemod == "sandbox" then
			ent:DrawShadow(false)
			ent:SetModelScale(0, gibRemoveTime)
			SafeRemoveEntityDelayed(ent, gibRemoveTime)
		end

		ent:AddCallback( "PhysicsCollide", PhysCallback )

		local entIndex = ent:EntIndex()
		if cvHeadGib:GetBool() then timer.Simple(0.2, function()
			if not IsValid(ent) then return end
			net.Start("hg_gib_bloodspill")
			net.WriteUInt(entIndex, 16)
			net.WriteFloat(math.Rand(1, 2))
			net.WriteBool(false)
			net.Broadcast()
		end) end
	end
end

local headpos_male, headpos_female, headang = Vector(0,0,7), Vector(-2,0,6), Angle(0,0,-0)
local zc_headpos_male, zc_headpos_female = Vector(0,0,5), Vector(-2,0,4)

util.AddNetworkString("addfountain")
util.AddNetworkString("hg_gib_bloodspill")
util.AddNetworkString("hg_fullbody_bloodmist")

hg.fountains = hg.fountains or {}
local headboom_mdl = Model("models/gleb/zcity/headboom.mdl")
local zippyHeadGoreModels = {
	Model("models/headpartial/headpartial1.mdl"),
	Model("models/headpartial/headpartial2.mdl"),
	Model("models/headpartial/headpartial3.mdl"),
	Model("models/headpartial/headpartial4.mdl"),
	Model("models/headpartial/headpartial5.mdl"),
}
local eyeRModel = Model("models/gore/head_eye01.mdl")
local eyeLModel = Model("models/gore/head_eye02.mdl")

local zippyHeadGibModels = {
	Model("models/gore/head_headbitfrontleft.mdl"),
	Model("models/gore/head_headbitfrontright.mdl"),
	Model("models/gore/head_headbitbackleft.mdl"),
	Model("models/gore/head_headbitbackright.mdl"),
	Model("models/gore/head_headbittopleft.mdl"),
	Model("models/gore/head_headbittopright.mdl"),
	eyeRModel,
	eyeLModel,
	Model("models/gore/head_jawlo.mdl"),
}

function hg.HeadGibModels(org)
	if not org or not (org.eyePoppedL or org.eyePoppedR) then return zippyHeadGibModels end
	local models = {}
	for i, mdl in ipairs(zippyHeadGibModels) do
		if mdl == eyeRModel and org.eyePoppedR then continue end
		if mdl == eyeLModel and org.eyePoppedL then continue end
		models[#models + 1] = mdl
	end
	return models
end
local fullBodySounds = {
	Sound("fullbodyexplode/rem_fullbodygib1.wav"),
	Sound("fullbodyexplode/rem_fullbodygib2.wav"),
	Sound("fullbodyexplode/rem_fullbodygib3.wav"),
}
local fullBodyMainSound = Sound("fullbodyexplode/rem_fullbodygibmain.mp3")
local fullBodyGibModels = {
	stomach = {
		Model("models/gore/pelvis.mdl"),
		Model("models/gore/uppertorso.mdl"),
	},
	rleg = {
		Model("models/gore/rleg_meatbit001r.mdl"),
	},
	lleg = {
		Model("models/gore/lleg_meatbit001l.mdl"),
	},
	larm = {
		Model("models/gore/larm_armgorehandl.mdl"),
		Model("models/gore/larm_armgoreupperl.mdl"),
	},
}

local sounds = {
	Sound("player/zombie_head_explode_01.wav"),
	Sound("player/zombie_head_explode_02.wav"),
	Sound("player/zombie_head_explode_03.wav"),
	Sound("player/zombie_head_explode_04.wav"),
	Sound("player/zombie_head_explode_05.wav"),
	Sound("player/zombie_head_explode_06.wav")
}
util.PrecacheModel(headboom_mdl)
for _, mdl in ipairs(zippyHeadGoreModels) do
	util.PrecacheModel(mdl)
end
for _, mdl in ipairs(zippyHeadGibModels) do
	util.PrecacheModel(mdl)
end
for _, models in pairs(fullBodyGibModels) do
	for _, mdl in ipairs(models) do
		util.PrecacheModel(mdl)
	end
end

for _, snd in ipairs(sounds) do
	util.PrecacheSound(snd)
end
for _, snd in ipairs(fullBodySounds) do
	util.PrecacheSound(snd)
end
util.PrecacheSound(fullBodyMainSound)

local function getHeadGoreStage(damage)
	return math.Clamp(math.ceil(math.max((damage or 0) - 175, 0) / 5), 1, 5)
end

local function getInitialHeadGoreStage(damage)
	return math.min(getHeadGoreStage(damage), table.Random({1,1,1,1,2,2,2,3,4,5}))
end

local function setupZippyHeadGore(ent, rag, stage)
	ent:SetModel(zippyHeadGoreModels[stage])
	local att = rag:GetAttachment(3)
	local pos, ang = LocalToWorld(ThatPlyIsFemale(rag) and headpos_female or headpos_male, headang, att.Pos, att.Ang)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetParent(rag, 3)
	return pos
end

local function copyHeadAppearance(from, to)
	local ply = IsValid(from:GetNWEntity("ply")) and from:GetNWEntity("ply") or hg.RagdollOwner and hg.RagdollOwner(from)
	if IsValid(ply) and ApplyAppearanceRagdoll then ApplyAppearanceRagdoll(to, ply) end
	to:SetNWEntity("ply", IsValid(ply) and ply or from:GetNWEntity("ply"))
	to:SetNWString("PlayerName", from:GetNWString("PlayerName", ""))
	to:SetNetVar("Accessories", from:GetNetVar("Accessories", IsValid(ply) and ply:GetNetVar("Accessories", "") or ""))
	to:SetSkin(from:GetSkin())
	to:SetMaterial(from:GetMaterial())
	for i = 0, #from:GetBodyGroups() do
		to:SetBodygroup(i, from:GetBodygroup(i))
	end
	for i = 0, #from:GetMaterials() - 1 do
		to:SetSubMaterial(i, from:GetSubMaterial(i))
	end
	to:SetRenderMode(RENDERMODE_NORMAL)
	to:SetColor(Color(255, 255, 255, 255))
	to:SetNWVector("PlayerColor", from:GetNWVector("PlayerColor", vector_origin))
end

local function hideNonHeadBones(ent, headBone)
	local headPhysBone = ent:TranslateBoneToPhysBone(headBone)
	for i = 0, ent:GetBoneCount() - 1 do
		if i == headBone then continue end
		ent:ManipulateBoneScale(i, vecZero)
		local physBone = ent:TranslateBoneToPhysBone(i)
		if physBone == -1 or physBone == headPhysBone then continue end
		local phys = ent:GetPhysicsObjectNum(physBone)
		if IsValid(phys) then
			phys:EnableCollisions(false)
			phys:SetMass(0.1)
			ent:RemoveInternalConstraint(physBone)
		end
	end
	ent:RemoveInternalConstraint(headPhysBone)
end







function Gib_UpdateHeadGoreStage(rag, damage)
	if not IsValid(rag) or not rag.headexploded then return end
	local stage = getHeadGoreStage(damage)
	if (rag.zippyHeadGoreStage or 0) >= stage then return end

	rag.zippyHeadGoreStage = stage
	if IsValid(rag.zippyHeadGore) then
		rag.zippyHeadGore:SetModel(zippyHeadGoreModels[stage])
		net.Start("hg_gib_bloodspill")
		net.WriteUInt(rag.zippyHeadGore:EntIndex(), 16)
		net.WriteFloat(math.Rand(5, 10))
		net.WriteBool(true)
		net.Broadcast()
		SpawnMeatGore(rag.zippyHeadGore, rag.zippyHeadGore:GetPos(), 3, VectorRand(-120, 120), 0.45, hg.HeadGibModels(rag.organism))
		return
	end

	local ent = ents_Create("prop_dynamic")
	setupZippyHeadGore(ent, rag, stage)
	ent:Spawn()
	rag.zippyHeadGore = ent
	net.Start("hg_gib_bloodspill")
	net.WriteUInt(ent:EntIndex(), 16)
	net.WriteFloat(math.Rand(5, 10))
	net.WriteBool(true)
	net.Broadcast()
	SpawnMeatGore(ent, ent:GetPos(), 3, VectorRand(-120, 120), 0.45, hg.HeadGibModels(rag.organism))

	rag:CallOnRemove("remove_zippy_head_gore", function()
		if IsValid(ent) then ent:Remove() end
	end)
end

local function remGibInput(rag, bone, force, damage)
	if not IsValid(rag) then return end
	
	local gibRemove = rag.gibRemove

	if not gibRemove then
		rag.gibRemove = {}
		gibRemove = rag.gibRemove

		gib_ragdols[rag] = true
	end

	local phys_bone = rag:TranslateBoneToPhysBone(bone)
	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	
	if (not gibRemove[phys_bone]) and (bone == rag:LookupBone("ValveBiped.Bip01_Head1")) then
		--sound.Emit(rag,"player/headshot" .. math.random(1, 2) .. ".wav")
		--sound.Emit(rag,"physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
		--sound.Emit(rag,"physics/body/body_medium_break3.wav")
		--sound.Emit(rag,"physics/glass/glass_sheet_step" .. math.random(1,4) .. ".wav", 90, 50, 2)
		rag:EmitSound(sounds[math.random(#sounds)], 70, math.random(115, 125), 2)

		Gib_RemoveBone(rag, bone, phys_bone)
		
		--rag:ManipulateBoneScale(rag:LookupBone("ValveBiped.Bip01_Neck1"),vecZero)
		rag:ManipulateBonePosition(rag:LookupBone("ValveBiped.Bip01_Neck1"),Vector(-1,0,0))

		local stage = getInitialHeadGoreStage(damage)
		local ent = ents_Create("prop_dynamic")
		local pos = setupZippyHeadGore(ent, rag, stage)
		ent:Spawn()
		rag.zippyHeadGore = ent
		rag.zippyHeadGoreStage = stage
		net.Start("hg_gib_bloodspill")
		net.WriteUInt(ent:EntIndex(), 16)
		net.WriteFloat(math.Rand(5, 10))
		net.WriteBool(true)
		net.Broadcast()

		SpawnMeatGore(ent, pos, nil, force, nil, hg.HeadGibModels(rag.organism)) --модельки поменять и будет эпик

		local armors = rag:GetNetVar("Armor",{})

		if armors["head"] and !hg.armor["head"][armors["head"]].nodrop then
			local ent = hg.DropArmorForce(rag, armors["head"])
			ent:SetPos(phys_obj:GetPos())
		end
		
		if armors["face"] and !hg.armor["face"][armors["face"]].nodrop then
			local ent = hg.DropArmorForce(rag, armors["face"])
			ent:SetPos(phys_obj:GetPos())
		end

		rag.noHead = true
		rag:SetNWString("PlayerName", "Beheaded body")

		net.Start("addfountain")
		net.WriteEntity(rag)
		net.WriteVector(force or vector_origin)
		net.Broadcast()

		hg.fountains[rag] = {bone = rag:LookupBone("ValveBiped.Bip01_Neck1"), lpos = ThatPlyIsFemale(rag) and Vector(4,0,0) or Vector(5,0,0),lang = Angle(0,0,0)}

		rag:CallOnRemove("removefountain", function()
			hg.fountains[rag] = nil
			SetNetVar("fountains", hg.fountains)
		end)

		SetNetVar("fountains", hg.fountains)
	end
end

local function zcGibInput(rag, bone, force)
	if not IsValid(rag) then return end
	
	local gibRemove = rag.gibRemove

	if not gibRemove then
		rag.gibRemove = {}
		gibRemove = rag.gibRemove

		gib_ragdols[rag] = true
	end

	local phys_bone = rag:TranslateBoneToPhysBone(bone)
	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	
	if (not gibRemove[phys_bone]) and (bone == rag:LookupBone("ValveBiped.Bip01_Head1")) then
		--sound.Emit(rag,"player/headshot" .. math.random(1, 2) .. ".wav")
		--sound.Emit(rag,"physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
		--sound.Emit(rag,"physics/body/body_medium_break3.wav")
		--sound.Emit(rag,"physics/glass/glass_sheet_step" .. math.random(1,4) .. ".wav", 90, 50, 2)
		rag:EmitSound(sounds[math.random(#sounds)], 70, math.random(95, 105), 2)

		Gib_RemoveBone(rag, bone, phys_bone)
		
		--rag:ManipulateBoneScale(rag:LookupBone("ValveBiped.Bip01_Neck1"),vecZero)
		rag:ManipulateBonePosition(rag:LookupBone("ValveBiped.Bip01_Neck1"),Vector(-1,0,0))

		local ent = ents_Create("prop_dynamic")
		ent:SetModel(headboom_mdl)
		local att = rag:GetAttachment(3)
		local pos, ang = LocalToWorld(ThatPlyIsFemale(rag) and zc_headpos_female or zc_headpos_male, headang, att.Pos, att.Ang)
		ent:SetPos(pos)
		ent:SetAngles(ang)
		--ent:AddEffects(EF_FOLLOWBONE)
		ent:SetParent(rag, 3)--rag:LookupBone("ValveBiped.Bip01_Head1"))
		ent:Spawn()

		SpawnMeatGore(ent, pos, nil, force) --модельки поменять и будет эпик

		local armors = rag:GetNetVar("Armor",{})

		if armors["head"] and !hg.armor["head"][armors["head"]].nodrop then
			local ent = hg.DropArmorForce(rag, armors["head"])
			ent:SetPos(phys_obj:GetPos())
		end
		
		if armors["face"] and !hg.armor["face"][armors["face"]].nodrop then
			local ent = hg.DropArmorForce(rag, armors["face"])
			ent:SetPos(phys_obj:GetPos())
		end

		rag.noHead = true
		rag:SetNWString("PlayerName", "Beheaded body")

		net.Start("addfountain")
		net.WriteEntity(rag)
		net.WriteVector(force or vector_origin)
		net.Broadcast()

		hg.fountains[rag] = {bone = rag:LookupBone("ValveBiped.Bip01_Neck1"), lpos = ThatPlyIsFemale(rag) and Vector(4,0,0) or Vector(5,0,0),lang = Angle(0,0,0)}

		rag:CallOnRemove("removefountain", function()
			hg.fountains[rag] = nil
			SetNetVar("fountains", hg.fountains)
		end)

		SetNetVar("fountains", hg.fountains)
	end
end

function Gib_Input(rag, bone, force, damage)
	if cvHeadGib:GetBool() then
		-- Z-City doesn't pass how hard the head was hit, so pick a stage the way Remorse's random roll does
		return remGibInput(rag, bone, force, damage or (175 + math.random(5, 25)))
	end
	return zcGibInput(rag, bone, force)
end
