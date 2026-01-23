-- services
local players =  game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")	
local dataStoreService = game:GetService("DataStoreService")

local dataVersion = 020 -- orginal data: 010
local dataStore = dataStoreService:GetDataStore("Production" .. dataVersion)

-- configs
local configs = replicatedStorage:WaitForChild("Configs")
local badges = require(configs:WaitForChild("Badges"))


-- functions

local function loadData(player)

	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"

	local gameValues = Instance.new("Folder", player)
	gameValues.Name = "GameValues"
	
	local materials = Instance.new("Folder", player)
	materials.Name = "Materials"

	local arrivals = Instance.new("Folder", player)
	arrivals.Name = "Arrivals"

	local masteries = Instance.new("Folder", player)
	masteries.Name = "Masteries"

	local level = Instance.new("NumberValue", leaderstats)
	level.Name = "Level"
	level.Value = 1

	local rank = Instance.new("StringValue", leaderstats)
	rank.Name = "Rank"
	rank.Value = "Starter"

	local credits = Instance.new("NumberValue", leaderstats)
	credits.Name = "Credits"
	credits.Value = 100000

	local exp = Instance.new("NumberValue", gameValues)
	exp.Name = "Exp"
	exp.Value = 1
	
	local maxExp = Instance.new("NumberValue", gameValues)
	maxExp.Name = "MaxExp"
	maxExp.Value = 100

	local kills = Instance.new("NumberValue", gameValues)
	kills.Name = "Kills"
	kills.Value = 0

	local games = Instance.new("NumberValue", gameValues)
	games.Name = "Games"
	games.Value = 0

	local streak = Instance.new("NumberValue", gameValues)
	streak.Name = "Streak"
	streak.Value = 0
	
	local mamgaRock = Instance.new("NumberValue", materials)
	mamgaRock.Name = "Magma Rock"
	mamgaRock.Value = 0
	
	local herb = Instance.new("NumberValue", materials)
	herb.Name = "Herb"
	herb.Value = 0

	local equippedArrival = Instance.new("StringValue", player)
	equippedArrival.Name = "EquippedArrival"

	local equippedMastery = Instance.new("StringValue", player)
	equippedMastery.Name = "EquippedMastery"
	
	local dailyReward = Instance.new("IntValue", player)
	dailyReward.Name = "DailyReward"
	dailyReward.Value = 1
	
	local lastClaimTime = Instance.new("IntValue", player)
	lastClaimTime.Name = "LastClaimTime"
	lastClaimTime.Value = 0
	
	local data

	local success, errorMsg = pcall(function()
		data = dataStore:GetAsync(player.UserId)
	end)

	-- checking if the player data is nil, if not then load the data
	if data ~= nil then
		print(data)

		-- leaderstats
		if data.Credits then
			credits.Value = data.Credits
		end

		if data.Level then
			level.Value = data.Level
		end

		if data.Rank then
			rank.Value = data.Rank
		end

		-- GameValues
		if data.Exp then
			exp.Value = data.Exp
		end
		
		if data.MaxExp then
			maxExp.Value = data.MaxExp
		end

		if data.Kills then
			kills.Value = data.Kills
		end

		if data.Games then
			games.Value = data.Games
		end

		if data.Streak then
			streak.Value = data.Streak
		end
		
		if data.MagmaRock then
			mamgaRock.Value = data.MagmaRock
		end
		
		if data.Herb then
			herb.Value = data.Herb
		end

		if data.EquippedArrival then
			equippedArrival.Value = data.EquippedArrival
		end
		
		if data.EquippedMastery then
			equippedMastery.Value = data.EquippedMastery
		end
		
		if data.DailyReward then
			dailyReward.Value = data.DailyReward or 1
		end
		
		if data.LastClaimTime then
			lastClaimTime.Value = data.LastClaimTime or 1
		end

		if data.Arrivals then
			for i, v in pairs(data.Arrivals) do
				local val = Instance.new("StringValue")
				val.Name = v
				val.Parent = player.Arrivals
			end
		end
		
		if data.Masteries then
			for i, v in pairs(data.Masteries) do
				local val = Instance.new("StringValue")
				val.Name = v
				val.Parent = player.Masteries
			end
		end

		replicatedStorage:WaitForChild("Remotes").SendData:FireClient(player, data)
	end
	
	if kills.Value >= 25 then
		badges.AwardBadge(player, 698787811135500)
	end
	if kills.Value >= 100 then
		badges.AwardBadge(player, 2329854472355842)
	end
	if kills.Value >= 250 then
		badges.AwardBadge(player, 2531904949459467)
	end
	if kills.Value >= 500 then
		badges.AwardBadge(player, 2710146805506798)
	end
	
	-- level system
	exp:GetPropertyChangedSignal("Value"):Connect(function()
		if exp.Value >= maxExp.Value then
			level.Value += 1
			exp.Value = 0
			maxExp.Value *= 1.5
		end
	end)
	
	if streak.Value == 10 then
		badges.AwardBadge(player, 1074865010728383)
	end
end

-- saving player data when left
local function saveData(player)
	local data = {}

	data.Credits = player.leaderstats.Credits.Value
	data.Level = player.leaderstats.Level.Value
	data.Rank = player.leaderstats.Rank.Value

	data.Exp = player.GameValues.Exp.Value
	data.MaxExp = player.GameValues.MaxExp.Value
	data.Kills = player.GameValues.Kills.Value
	data.Games = player.GameValues.Games.Value
	data.Streak = player.GameValues.Streak.Value
	data.DailyReward = player.DailyReward.Value
	data.LastClaimTime = player.LastClaimTime.Value
	
	data.MagmaRock = player.Materials["Magma Rock"].Value
	data.Herb = player.Materials.Herb.Value

	data.EquippedArrival = player.EquippedArrival.Value
	data.EquippedMastery = player.EquippedMastery.Value

	data.Arrivals = {}
	data.Masteries = {}

	for i, v in pairs(player.Arrivals:GetChildren()) do
		table.insert(data.Arrivals, v.Name)
	end
	
	for i, v in pairs(player.Masteries:GetChildren()) do
		table.insert(data.Masteries, v.Name)
	end

	local success, errorMsg = pcall(function()
		dataStore:SetAsync(player.UserId, data)
	end)

	if success then
		print("successfully saved")
		print(data)
	end
end

-- addng event functions
game.Players.PlayerAdded:Connect(function(player)
	loadData(player)
end)
game.Players.PlayerRemoving:Connect(function(player)
	saveData(player)
end)

game:BindToClose(function()
	for _, player in pairs(players:GetChildren()) do
		coroutine.wrap(saveData)(player)
	end
end)