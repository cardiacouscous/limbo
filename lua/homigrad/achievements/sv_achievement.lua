hg.achievements = hg.achievements or {}
hg.achievements.achievements_data = hg.achievements.achievements_data or {}
hg.achievements.achievements_data.player_achievements = hg.achievements.achievements_data.player_achievements or {}
hg.achievements.achievements_data.created_achevements = {}

local function updatePlayer(ply)
    local name = ply:Name()
	local steamID64 = ply:SteamID64()

    if not hg.achievements.SqlActive then
        hg.achievements.achievements_data.player_achievements[steamID64] = {}
        return
    end 

	local query = mysql:Select("hg_achievements")
		query:Select("achievements")
		query:Where("steamid", steamID64)
		query:Callback(function(result)
            --print(result)
            --PrintTable(result)
			if (IsValid(ply) and istable(result) and #result > 0 and result[1].achievements) then
				local updateQuery = mysql:Update("hg_achievements")
					updateQuery:Update("steam_name", name)
					updateQuery:Where("steamid", steamID64)
				updateQuery:Execute()

                hg.achievements.achievements_data.player_achievements[steamID64] = util.JSONToTable(result[1].achievements)

                --PrintTable(hg.achievements.achievements_data.player_achievements[steamID64])
			else
				local insertQuery = mysql:Insert("hg_achievements")
					insertQuery:Insert("steamid", steamID64)
					insertQuery:Insert("steam_name", name)
					insertQuery:Insert("achievements", util.TableToJSON({}))
				insertQuery:Execute()

				hg.achievements.achievements_data.player_achievements[steamID64] = {}
			end
		end)
	query:Execute()
end

hook.Add("DatabaseConnected", "AchievementsCreateData", function()
	local query

	query = mysql:Create("hg_achievements")
		query:Create("steamid", "VARCHAR(20) NOT NULL")
		query:Create("steam_name", "VARCHAR(32) NOT NULL")
        query:Create("achievements", "TEXT NOT NULL")
		query:PrimaryKey("steamid")
	query:Execute()

    hg.achievements.SqlActive = true

    print("Achievements SQL database connected.")

    for i, ply in player.Iterator() do
        updatePlayer(ply)
    end
end)

hook.Add( "PlayerInitialSpawn","hg_Exp_OnInitSpawn", updatePlayer)
hook.Add("PlayerDisconnected", "savevalues", function(ply)
    if !hg.achievements.SqlActive then print("Tried to save achievement data to SQL, but it is not active.") return end
    
    hg.achievements.SaveToSQL(ply)
end)

function hg.achievements.SaveToSQL(ply, data)
    if not hg.achievements.SqlActive then return end

    local name = ply:Name()
	local steamID64 = ply:SteamID64()
    local updateQuery = mysql:Update("hg_achievements")
        updateQuery:Update("achievements", util.TableToJSON(data or hg.achievements.GetPlayerAchievements(ply) or {}) )
        updateQuery:Update("steam_name", name)
        updateQuery:Where("steamid", steamID64)
    updateQuery:Execute()
end

function hg.achievements.SavePlayerAchievements()
    if !hg.achievements.SqlActive then print("Tried to save achievement data to SQL, but it is not active.") return end

    for k, ply in player.Iterator() do
        hg.achievements.SaveToSQL(ply)
    end
end

local replacement_img = "homigrad/vgui/models/star.png"

function hg.achievements.CreateAchievementType(key, needed_value, start_value, description, name, img, showpercent)
    img = img or replacement_img
    hg.achievements.achievements_data.created_achevements[key] = {
        start_value = start_value,
        needed_value = needed_value,
        description = description,
        name = name,
        img = img,
        key = key,
        showpercent = showpercent,
    }
end


function hg.achievements.GetAchievements()
    return hg.achievements.achievements_data.created_achevements
end


function hg.achievements.GetAchievementInfo(key)
    return hg.achievements.achievements_data.created_achevements[key]
end


function hg.achievements.GetPlayerAchievements(ply)
    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    return hg.achievements.achievements_data.player_achievements[steamID]
end


function hg.achievements.GetPlayerAchievement(ply, key)
    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    return hg.achievements.achievements_data.player_achievements[steamID][key] or {}
end


local function isAchievementCompleted(ply, key, val)
    local ach = hg.achievements.achievements_data.created_achevements[key]
    return val >= ach.needed_value and (hg.achievements.achievements_data.player_achievements[ply:SteamID64()][key].value or 0) < val
end

util.AddNetworkString("hg_NewAchievement")

function hg.achievements.SetPlayerAchievement(ply, key, val)
    --print("Triggered achievement for player " .. ply:Name() .. " ; " .. ply:SteamID() .. ": " .. (key or "none") .. ", value " .. (val or "none"))
    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    local playerAchievements = hg.achievements.achievements_data.player_achievements[steamID]
    playerAchievements[key] = playerAchievements[key] or {}

    if isAchievementCompleted(ply, key, val) then
        local ach = hg.achievements.achievements_data.created_achevements[key]
        net.Start("hg_NewAchievement")
            net.WriteString(ach.name)
            net.WriteString(ach.img)
        net.Send(ply)
    end

    playerAchievements[key].value = val
end

function hg.achievements.AddPlayerAchievement(ply, key, val)
    local ach = hg.achievements.GetPlayerAchievement(ply, key)
    local ach_info = hg.achievements.GetAchievementInfo(key)

    hg.achievements.SetPlayerAchievement(ply, key, math.Approach(ach.value or ach_info.start_value, ach_info.needed_value, val))
end

util.AddNetworkString("req_ach")

net.Receive("req_ach", function(len, ply)
    if (ply.ach_cooldown or 0) > CurTime() then return end
    ply.ach_cooldown = CurTime() + 2
    net.Start("req_ach")
        net.WriteTable(hg.achievements.GetAchievements())
        net.WriteTable(hg.achievements.GetPlayerAchievements(ply))
    net.Send(ply)
end)

//if !hg.init_ach then
    -- braindeath
    hg.achievements.CreateAchievementType("brain",1,0,"Die from hypoxia.","I will definitely survive...", nil, false)
    -- death from drugs
    hg.achievements.CreateAchievementType("drugs",1,0,"Die from opioids overdose.","Overstimulated", nil, false)
    -- TERMINATOR
    hg.achievements.CreateAchievementType("illbeback",3,0,"Get shot in the head and get up alive.","I'll be back", nil, true)
    -- russian roulette
    hg.achievements.CreateAchievementType("deadlygambling",10,0,"Survive 10 games of Russian roulette in one life.","Deadly Gambling", nil, true)

    //hg.init_ach = true
//end

hook.Add("PlayerDeath", "hg_deadlygambling_reset", function(ply)
    local ach = hg.achievements.GetPlayerAchievement(ply,"deadlygambling")
    if ach["value"] ~= 10 and ach["value"] ~= 0 then
        hg.achievements.SetPlayerAchievement(ply, "deadlygambling", 0)
    end
end)

hook.Add("HomigradDamage","hg_illbeback_Acchivment",function(ply, dmgInfo, hitgroup, ent, harm, hitBoxs)
    --if gmod.GetGamemode() ~= "zcity" then return end
    if not ply:IsPlayer() then return end
    if (dmgInfo:IsDamageType(128) or dmgInfo:IsDamageType(DMG_BULLET)) and hitgroup == HITGROUP_HEAD and hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] ~= 3 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",1)
        ply.illbeback = CurTime() + 10
    end
end)

hook.Add("HG_OnOtrub","hg_illbeback_Acchivment",function(ply)
    if ply:IsRagdoll() then
        ply = hg.RagdollOwner(ply)
    end
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] == 1 and (ply.illbeback or 0) > CurTime() then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",2)
    end
end)

hook.Add("PlayerDeath","hg_illbeback_Acchivment",function(ply)
    local val = hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"]
    if val ~= 3 and val ~= 0 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback", 0)
    end
end)

hook.Add("PlayerSilentDeath","hg_illbeback_Acchivment",function(ply)
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] ~= 3 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",0)
    end
end)

hook.Add("HG_OnWakeOtrub","hg_illbeback_Acchivment",function(ply)
    if ply:IsRagdoll() then
        ply = hg.RagdollOwner(ply)
    end
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] == 2 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",3)
    end
end)



-- Limbo: also save when the server shuts down (the host leaving a listen server doesn't always count as a disconnect)
hook.Add("ShutDown", "limbo_saveachievements", function()
    if hg.achievements.SqlActive then hg.achievements.SavePlayerAchievements() end
end)

-- Limbo's own achievements
hg.achievements.CreateAchievementType("limbo_again", 10, 0, "Die ten times.", "Again", nil, true)
hg.achievements.CreateAchievementType("limbo_stillhere", 30, 0, "Stay alive for thirty minutes.", "Still here", nil, true)
hg.achievements.CreateAchievementType("limbo_notyet", 1, 0, "Wake yourself up.", "Not yet", nil, false)
hg.achievements.CreateAchievementType("limbo_longwaydown", 1, 0, "Break a leg in a fall and live.", "Long way down", nil, false)
hg.achievements.CreateAchievementType("limbo_handmedown", 1, 0, "Take a weapon or armor off someone's body.", "Hand-me-down", nil, false)
hg.achievements.CreateAchievementType("limbo_leftovers", 10, 0, "Loot 10 bodies that aren't yours.", "Leftovers", nil, true)
hg.achievements.CreateAchievementType("limbo_keepsake", 1, 0, "Take something back from your own body.", "Keepsake", nil, false)
hg.achievements.CreateAchievementType("limbo_shortlived", 1, 0, "Die within a few seconds of a kill.", "Short-lived", nil, false)
hg.achievements.CreateAchievementType("limbo_martyrdom", 1, 0, "Hurt whoever killed you, after you're dead.", "Martyrdom", nil, false)
hg.achievements.CreateAchievementType("limbo_forgot", 1, 0, "Hurt someone with a trap you set long ago, far from where you died.", "Forgot about that", nil, false)
hg.achievements.CreateAchievementType("limbo_halved", 1, 0, "Get split in half.", "Halved", nil, false)
hg.achievements.CreateAchievementType("limbo_kamikaze", 1, 0, "Pull the pin and let it go off in your hand.", "Kamikaze", nil, false)
hg.achievements.CreateAchievementType("limbo_windup", 1, 0, "Break a skull or hurt a brain with a fully charged melee hit.", "Wind-up", nil, false)
hg.achievements.CreateAchievementType("limbo_stillfight", 1, 0, "Kill someone with your spine broken.", "I can still fight", nil, false)
hg.achievements.CreateAchievementType("limbo_dontneedthis", 1, 0, "Kill someone with an arm missing.", "Don't need this", nil, false)
hg.achievements.CreateAchievementType("limbo_dontneedthat", 1, 0, "Kill someone with a leg missing.", "Don't need that", nil, false)
hg.achievements.CreateAchievementType("limbo_dontneedany", 1, 0, "Kill someone with an arm and a leg missing.", "Don't need any of these", nil, false)
hg.achievements.CreateAchievementType("limbo_howdid", 1, 0, "Lose all four limbs, and live.", "How did we get here?", nil, false)

hook.Add("PlayerDeath", "limbo_achievements", function(ply)
    hg.achievements.AddPlayerAchievement(ply, "limbo_again", 1)

    local val = hg.achievements.GetPlayerAchievement(ply, "limbo_stillhere")["value"] or 0
    if val < 30 and val ~= 0 then hg.achievements.SetPlayerAchievement(ply, "limbo_stillhere", 0) end
end)

timer.Create("limbo_stillhere", 60, 0, function()
    for _, ply in player.Iterator() do
        if ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then
            local val = hg.achievements.GetPlayerAchievement(ply, "limbo_stillhere")["value"] or 0
            if val < 30 then hg.achievements.SetPlayerAchievement(ply, "limbo_stillhere", val + 1) end
        end
    end
end)
