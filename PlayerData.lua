-- Getting services for players, data, and remote events 

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- DATASTORE SETUP

local data_Version = 020
local dataStore = DataStoreService:GetDataStore("Production" .. data_Version)

-- REMOTES + CONFIGS
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendData = Remotes:WaitForChild("SendData")

local Configs = ReplicatedStorage:WaitForChild("Configs")
local Badges = require(Configs:WaitForChild("Badges"))

-- MODULE 1: valueTypes
-- Creates numberValue, stringValue, intValue, and folders easily

local valueType = {}

function valueType.Number(name, parent, value)
	local v = Instance.new("NumberValue")
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

function valueType.String(name, parent, value)
	local v = Instance.new("StringValue")
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

function valueType.Int(name, parent, value)
	local v = Instance.new("IntValue")
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

function valueType.Folder(name, parent)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

-- MODULE 2: LevelSystem
-- Handles leveling up when EXP reaches maxExp

local LevelSystem = {}

function LevelSystem.Attach(profile)
	profile.Exp:GetPropertyChangedSignal("Value"):Connect(function()
		if profile.Exp.Value >= profile.MaxExp.Value then
			profile.Level.Value += 1
			profile.Exp.Value = 0
			profile.MaxExp.Value = math.floor(profile.MaxExp.Value * 1.5)
		end
	end)
end

-- MODULE 3: BadgeSystem
-- Awards badges based on kills or streaks
local BadgeSystem = {}

local KillBadges = {
	{25, 698787811135500},
	{100, 2329854472355842},
	{250, 2531904949459467},
	{500, 2710146805506798},
}

function BadgeSystem.CheckKills(player, kills)
	for _, info in ipairs(KillBadges) do
		if kills >= info[1] then
			Badges.AwardBadge(player, info[2])
		end
	end
end

function BadgeSystem.CheckStreak(player, streak)
	if streak >= 10 then
		Badges.AwardBadge(player, 1074865010728383)
	end
end

-- MODULE 4: PlayerProfile
-- Creates all folders and values for a player

local PlayerProfile = {}

function PlayerProfile.Create(player)
	local profile = {}	

	-- Folders
	profile.Leaderstats = valueType.Folder("leaderstats", player)
	profile.GameValues = valueType.Folder("GameValues", player)
	profile.Materials = valueType.Folder("Materials", player)
	profile.Arrivals = valueType.Folder("Arrivals", player)
	profile.Masteries = valueType.Folder("Masteries", player)

	-- Leaderstats
	profile.Level = valueType.Number("Level", profile.Leaderstats, 1)
	profile.Rank = valueType.String("Rank", profile.Leaderstats, "Starter")
	profile.Credits = valueType.Number("Credits", profile.Leaderstats, 100000)

	-- Game values
	profile.Exp = valueType.Number("Exp", profile.GameValues, 1)
	profile.MaxExp = valueType.Number("MaxExp", profile.GameValues, 100)
	profile.Kills = valueType.Number("Kills", profile.GameValues, 0)
	profile.Games = valueType.Number("Games", profile.GameValues, 0)
	profile.Streak = valueType.Number("Streak", profile.GameValues, 0)

	-- Materials
	profile.MagmaRock = valueType.Number("Magma Rock", profile.Materials, 0)
	profile.Herb = valueType.Number("Herb", profile.Materials, 0)

	-- Equipped items
	profile.EquippedArrival = valueType.String("EquippedArrival", player, "")
	profile.EquippedMastery = valueType.String("EquippedMastery", player, "")

	-- Daily reward
	profile.DailyReward = valueType.Int("DailyReward", player, 1)
	profile.LastClaimTime = valueType.Int("LastClaimTime", player, 0)

	return profile
end

-- MODULE 5: DataStoreModule
-- Loads and saves player data using pcall

local DataStoreModule = {}

function DataStoreModule.Load(player)
	local data
	local success, err = pcall(function()
		data = dataStore:GetAsync(player.UserId)
	end)

	if not success then
		warn("Failed to load data:", err)
	end

	print("Successfully loaded data")
	return data
end

function DataStoreModule.Save(player, data)
	local success, err = pcall(function()
		dataStore:SetAsync(player.UserId, data)
	end)

	if not success then
		warn("Failed to save data:", err)
	end

	print("Successfully saved")
	return success
end

-- ACTIVE PROFILES TABLE
local ActiveProfiles = {}

-- Apply loaded data to player profile
local function applyData(profile, data)
	if not data then return end

	profile.Credits.Value = data.Credits or profile.Credits.Value
	profile.Level.Value = data.Level or profile.Level.Value
	profile.Rank.Value = data.Rank or profile.Rank.Value

	profile.Exp.Value = data.Exp or profile.Exp.Value
	profile.MaxExp.Value = data.MaxExp or profile.MaxExp.Value
	profile.Kills.Value = data.Kills or profile.Kills.Value
	profile.Games.Value = data.Games or profile.Games.Value
	profile.Streak.Value = data.Streak or profile.Streak.Value

	profile.MagmaRock.Value = data.MagmaRock or profile.MagmaRock.Value
	profile.Herb.Value = data.Herb or profile.Herb.Value

	profile.EquippedArrival.Value = data.EquippedArrival or ""
	profile.EquippedMastery.Value = data.EquippedMastery or ""

	profile.DailyReward.Value = data.DailyReward or 1
	profile.LastClaimTime.Value = data.LastClaimTime or 0

	-- Load arrivals
	if data.Arrivals then
		for _, name in ipairs(data.Arrivals) do
			valueType.String(name, profile.Arrivals, name)
		end
	end

	-- Load masteries
	if data.Masteries then
		for _, name in ipairs(data.Masteries) do
			valueType.String(name, profile.Masteries, name)
		end
	end
	
	print(profile)
end

-- converting player stats into table for saving
-- This is useful/needed because datastoreservice dosent save objects

local function serialize(profile)
	local data = {}

	data.Credits = profile.Credits.Value
	data.Level = profile.Level.Value
	data.Rank = profile.Rank.Value

	data.Exp = profile.Exp.Value
	data.MaxExp = profile.MaxExp.Value
	data.Kills = profile.Kills.Value
	data.Games = profile.Games.Value
	data.Streak = profile.Streak.Value

	data.MagmaRock = profile.MagmaRock.Value
	data.Herb = profile.Herb.Value

	data.EquippedArrival = profile.EquippedArrival.Value
	data.EquippedMastery = profile.EquippedMastery.Value

	data.DailyReward = profile.DailyReward.Value
	data.LastClaimTime = profile.LastClaimTime.Value

	data.Arrivals = {}
	data.Masteries = {}

	for _, v in ipairs(profile.Arrivals:GetChildren()) do
		table.insert(data.Arrivals, v.Name)
	end

	for _, v in ipairs(profile.Masteries:GetChildren()) do
		table.insert(data.Masteries, v.Name)
	end

	return data
end

-- Load player, apply loaded data,
-- Attach players leveling system, and award badges

local function loadPlayer(player)
	local profile = PlayerProfile.Create(player)
	ActiveProfiles[player] = profile

	local data = DataStoreModule.Load(player)
	applyData(profile, data)

	-- Attach leveling system
	LevelSystem.Attach(profile)

	-- Award badges if needed
	BadgeSystem.CheckKills(player, profile.Kills.Value)
	BadgeSystem.CheckStreak(player, profile.Streak.Value)

	-- Send data to client
	SendData:FireClient(player, data or {})
end

-- save playerData
local function savePlayer(player)
	local profile = ActiveProfiles[player]
	if not profile then return end

	local data = serialize(profile)
	DataStoreModule.Save(player, data)
	print(data)
end

-- AUTOSAVE LOOP (runs every 60 seconds)
-- Useful for cases where the server might crash or shut down
task.spawn(function()
	while true do
		task.wait(60)
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayer(player)
		end
	end
end)

-- PLAYER EVENTS
Players.PlayerAdded:Connect(loadPlayer)

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	ActiveProfiles[player] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayer(player)
	end
end)


