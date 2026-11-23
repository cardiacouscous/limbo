-- Limbo: from Remorse (github.com/kazoo43/remorseism), AGPL-3.0. Switch it off with limbo_immediatepain 0.
local limbo_cv = CreateConVar("limbo_immediatepain", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Limbo: pain hits at once instead of building up", 0, 1)
local hook = setmetatable({
	Add = function(event, name, fn, priority)
		return _G.hook.Add(event, name, function(...)
			if not limbo_cv:GetBool() then return end
			return fn(...)
		end, priority)
	end,
}, {__index = _G.hook})

if SERVER then
    local painaddDrainRate = 16
    local adrenalinePainaddPassiveRate = 20
    local adrenalinePainaddPassiveCap = 2
    local adrenalinePainaddPassiveMin = 1.5

    hook.Add("Org Think", "ImmediatePainApply", function(owner, org, timeValue)
        if not org.painadd or org.painadd <= 0 then return end
        local adrenaline = math.min(org.adrenaline or 0, adrenalinePainaddPassiveCap)
        local add = math.min(org.painadd, timeValue * painaddDrainRate)
        local passiveDrain = 0
        if adrenaline > adrenalinePainaddPassiveMin then
            passiveDrain = math.min(math.max(org.painadd - add, 0), timeValue * adrenalinePainaddPassiveRate * adrenaline)
        end
        local isHero = IsValid(owner) and owner:IsPlayer() and owner.RealishIsHero
        if isHero then
            org.avgpain = 0
            org.painadd = 0
            org.pain = 0
            return
        end
        org.avgpain = math.min(org.avgpain + add, 150)
        org.painadd = math.max(org.painadd - add - passiveDrain, 0)
        local heroPainMul = 1
        org.pain = org.avgpain * math.max(1 - (org.adrenaline or 0) / 4, 0.75) * math.max(1 - (org.analgesia or 0), 0) * heroPainMul
        org.pain = math.min(org.pain, 150)
    end, HOOK_MONITOR_HIGH)
    hook.Add("Org Think", "ImmediatePainDrainBoost", function(owner, org, timeValue)
        local isHero = IsValid(owner) and owner:IsPlayer() and owner.RealishIsHero
        if isHero then
            org.avgpain = 0
            org.pain = 0
            org.painadd = 0
            return
        end
        if org.avgpain <= 0 then return end
        local extraSub = timeValue * ( (org.painkiller or 0) * 2 + (org.analgesia or 0) * 4 ) * 2
        if org.naloxone and org.naloxone > 0 then
            extraSub = extraSub * math.max(0, 1 - org.naloxone * 0.5)
        end
        org.avgpain = math.max(org.avgpain - extraSub, 0)
        local heroPainMul = 1
        org.pain = org.avgpain * math.max(1 - (org.adrenaline or 0) / 4, 0.75) * math.max(1 - (org.analgesia or 0), 0) * heroPainMul
        org.pain = math.min(org.pain, 150)
    end, HOOK_MONITOR_LOW)
end
