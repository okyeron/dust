
--local BeatClock = require 'beatclock'
--local clk = BeatClock.new()
--local clk_midi = midi.connect()
--clk_midi.event = clk.process_midi


--function init()
--    clk.on_step = count
--    clk.on_select_internal = function() clk:start() end
--    clk.on_select_external = function() print("external") end
--    clk:add_clock_params()
--    clk:start()
--end

function count()
  --print( clk.current_ticks)
  --print("bpm: "..params:get("bpm"))
end

m = midi.connect()
m.event = function(data)
  local d = midi.to_msg(data)
  tab.print(d)
  
end