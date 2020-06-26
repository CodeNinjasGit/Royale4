local PlayerManager = {}

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local moduleScripts = ServerStorage:WaitForChild("ModuleScripts")
local gameSettings = require(moduleScripts:WaitForChild("GameSettings"))

-- Events
local events = ServerStorage:WaitForChild("Events")
local matchEnd = events:WaitForChild("MatchEnd")

-- Variables
local lobbySpawn = workspace.Lobby.StartSpawn
local arenaMap = workspace.Arena
local spawnLocations = arenaMap.SpawnLocations
local playerWeapon = ServerStorage.Weapon

-- Values
local displayValues = ReplicatedStorage:WaitForChild("DisplayValues")
local playersLeft = displayValues:WaitForChild("PlayersLeft")

local activePlayers = {}

local function checkPlayerCount()
	if #activePlayers == 1 then
		matchEnd:Fire(gameSettings.endStates.FoundWinner)
		print("Found winner")
	end
end

local function removeActivePlayer(player)
	print("removing player")
	for playerKey, whichPlayer in pairs(activePlayers) do
		if whichPlayer == player then
			table.remove(activePlayers, playerKey)
			playersLeft.Value = #activePlayers
			checkPlayerCount()
		end
	end
end

local function respawnPlayerInLobby(player)
	player.RespawnLocation = lobbySpawn
	player:LoadCharacter()
end

local function preparePlayer(player, whichSpawn)
	player.RespawnLocation = whichSpawn
	player:LoadCharacter()
	
	local character = player.Character or player.CharacterAdded:Wait()
	-- Give the player a tool 
	local sword = playerWeapon:Clone()
	sword.Parent = character

	local humanoid = character:WaitForChild("Humanoid")
	
	humanoid.Died:Connect(function()
		respawnPlayerInLobby(player)
		removeActivePlayer(player)
	end)
end

local function onPlayerJoin(player)
	player.RespawnLocation = lobbySpawn
end

local function removePlayerWeapon(whichPlayer)
	-- Check to see if a player exist in case they disconnected or left. 
	if whichPlayer then
		local character = whichPlayer.Character
		
		-- If the player has it currently on their character
		if character:FindFirstChild("Weapon") then
			character.Weapon:Destroy()
		end
		-- If theplayer has the weapon in their backpack
		if whichPlayer.Backpack:FindFirstChild("Weapon") then
			whichPlayer.Backpack.Weapon:Destroy()
		end
	else
		print("No player to remove weapon")
	end
end

function PlayerManager.sendPlayersToMatch()
	local availableSpawnPoints = spawnLocations:GetChildren()
	
	for playerKey, whichPlayer in pairs(Players:GetPlayers()) do
		table.insert(activePlayers,whichPlayer)

		-- Gets a spawn location and then removes it from the table so the next player gets the next spawn
		local spawnLocation = availableSpawnPoints[1]
		table.remove(availableSpawnPoints, 1)
		preparePlayer(whichPlayer, spawnLocation)
	end

	playersLeft.Value = #activePlayers
end

function PlayerManager.getWinnerName()
	if activePlayers[1] then
		local winningPlayer = activePlayers[1]
		return winningPlayer.Name
	else
		return "Error: No player found"
	end
end

function PlayerManager.removeAllWeapons()
	for playerKey, whichPlayer in pairs(activePlayers) do
		removePlayerWeapon(whichPlayer)
	end
end

function PlayerManager.resetPlayers()
	for playerKey, whichPlayer in pairs(activePlayers) do
		respawnPlayerInLobby(whichPlayer)
	end

	activePlayers = {}
end

game.Players.PlayerAdded:Connect(onPlayerJoin)

return PlayerManager
