local DisplayManager = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Display Values used to update Player GUI
local displayValues = ReplicatedStorage:WaitForChild("DisplayValues")
local status = displayValues:WaitForChild("Status")
local playersLeft = displayValues:WaitForChild("PlayersLeft")
local timeLeft = displayValues:WaitForChild("TimeLeft")

-- Local Functions
local function updateRoundStatus()
	status.Value = "Players Left: " .. playersLeft.Value .. " / Time Left: " .. timeLeft.Value
end

-- Module Functions
function DisplayManager.updateStatus(stringToUpdate)
	status.Value = stringToUpdate
end

playersLeft.Changed:Connect(updateRoundStatus)
timeLeft.Changed:Connect(updateRoundStatus)

return DisplayManager
