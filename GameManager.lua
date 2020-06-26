9-- Services
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Module Scripts
local moduleScripts = ServerStorage:WaitForChild("ModuleScripts")
local matchManager = require(moduleScripts:WaitForChild("MatchManager"))
local gameSettings = require(moduleScripts:WaitForChild("GameSettings"))
local displayManager = require(moduleScripts:WaitForChild("DisplayManager"))

-- Events
local events = ServerStorage:WaitForChild("Events")
local matchEnd = events:WaitForChild("MatchEnd")

while true do
	displayManager.updateStatus("Waiting for Players")

	repeat
		wait(gameSettings.intermissionDuration)
	until Players.NumPlayers >= gameSettings.minimumPlayers

	displayManager.updateStatus("Get ready!")
	wait(gameSettings.transitionTime)
	
	matchManager.prepareGame()
	local endState = matchEnd.Event:Wait()

	local endStatus = matchManager.getEndStatus(endState)
	displayManager.updateStatus(endStatus)

	matchManager.cleanupMatch()
	wait(gameSettings.transitionTime)

	matchManager.resetMatch()
end
