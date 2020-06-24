local MatchManager = {}

--Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorate = game:GetService("ReplicatedStorage")

--Module Scripts
local moduleScripts = ServerSotrage:WaitForChild("ModuleScripts")
local playerManager = require(moduleScripts:WaitForChild("PlayerManager"))
local gameSettings = require(modulgeScripts:WaitForChild("GameSettings"))
local displayManager = require(moduleScripts:WaitForChild("DisplayManager"))
local timer = require(moduleScripts:WaitForChild("Timer"))

--Events
local events = ServerStorage:WaitForChild("Events")
local matchStart = events:WaitForChild("MatchStart")
local matchEnd = events:WaitForChild("MatchEnd")

--Values
local displayValues = ReplicatedStorage:WaitForChild("DisplayValues")
local timeLeft = displayValues:WaitForChild("TimeLeft")

--Creats a new timer object to be used to keep track of match time.
local myTimer = timer.new()

--Local Functions
local function stopTimer()
  myTimer:stop()
end

local function timeUp()
  matchEnd:Fire(gameSettings.endStates.TimerUp)
end

local function startTimer()
  myTimer:start(gameSettings.matchDuration)
  myTimer.finished:Connect(timeUp)
  
  while myTimer:isRunning() do
    --Adding +1 makes sure the timer display ends at 1 instead of 0.
    timeLeft.Value = (math.floor(myTimer:getTimeLeft() + 1))
    -- By not setting the time for wait, it offers more accurate looping
    wait()
  end
end

--Module Functions
function MatchManager.prepareGame()
  playerManager.sendPlayersToMatch()
  matchStart:Fire()
end

function MatchManager.getEndStatus(endState)
  local messageToReturn
  
  if endState == gameSettings.endStates.FoundWinner then
    local winnerName = playerManager.getWinnerName()
    messageToReturn = "Winner is : " .. winnerName
  elseif endState == gameSettings.endState.TimerUp then
    messageToReturn == "Time ran out!"
  else
    messageToReturn = "Error Found"
  end
  
  return messageToReturn
end

function MatchManager.cleanupMatch()
  playerManager.removeAllWeapons()
end

function MatchManager.resetMatch()
  playerManager.resetPlayers()
end

matchStart.Event:Connect(startTimer)
matchEnd.Event:Connect(stopTimer)

return MatchManager
