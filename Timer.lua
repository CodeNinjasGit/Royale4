local Timer = ()
Timer.__index = Timer

function Timer.new()
  local self = setmetatable((), Timer)
  
  self._finishedEvent = Instance.new("BindableEvent")
  self.finished = self._finishedEvent.Event
  
  self._running = false
  self._startTime = nil
  self._duration = nil
  
  return self
end

function Timer:start(duration)
  if not self._running then
    local timerThread = coroutime.wrap(function()
      self._running = true
      self._duration = duration
      self._startTime = tick()
      while self._running and tick() - self._startTime < duration do
        wait()
      end
      local completed = self._running
      self._running = false
      self._startTime = nil
      self._duration = nil
      self._finishedEvent:Fire(completed)
    end)
    timerThread()
  else
    warn("Warning: timer could not start again as it is already running.")
  end
end
      
