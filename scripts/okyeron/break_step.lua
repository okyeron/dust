-- break_step v.014
-- sample based step sequencer with preset patterns from well known breakbeats
-- based-on/extended-from jah/step.lua and jah/stepmod.lua
-- controlled by grid
--
-- requires drumpattrns.txt  -- edit path below 
-- 
-- key2 = stop sequencer
-- key3 = play sequencer
-- enc2 = tempo
-- enc3 = pattern select
-- 
-- swing amount is in PARAMETERS
--
-- grid = edit trigs
--
-- select drum kit (606,808,909) from parameters
--
-- change the data directory path here as needed
local file = data_dir .. "okyeron/drumpattrns.txt"

engine.name = 'Ack'

local gr = grid.connect()
local ControlSpec = require 'controlspec'
local Metro = require 'metro'
local Ack = require 'jah/ack'

local TRIG_LEVEL = 15
local PLAYPOS_LEVEL = 7
local CLEAR_LEVEL = 0


local tempo_spec = ControlSpec.new(20, 300, ControlSpec.WARP_LIN, 0, 120, "BPM")
local swing_amount_spec = ControlSpec.new(0, 100, ControlSpec.WARP_LIN, 0, 0, "%")

local maxwidth = 16
local height = 8
local playing = false
local queued_playpos
local playpos = -1
local timer
local key3down

local ppqn = 24 
local ticks
local ticks_to_next
local odd_ppqn
local even_ppqn

local trigger_indicators = {}
local grid_available

local locks = {}
local prev_locks


    local file = data_dir .. "okyeron/drumpattrns.txt"
    local big_patterns = {}
    local sub_patterns ={}
    local drumkits = {
        {"606-BD","606-SD","606-CH","606-OH","606-CY","606-HT","606-LT"},
        {"808-BD","808-SD","808-CH","808-OH","808-CY","808-CP","808-MA","808-CB"},
        {"909-BD","909-SD","909-CH","909-OH","909-CY","909-CP","909-RS","909-RC"}
        }
        drumkits[1].key = "606"
        drumkits[2].key = "808"
        drumkits[3].key = "909"

    local p_num = 1
    local p_idx = 1
    
    local trigs = {}


-- trig/lock functions

local function set_lock(x, y, value) -- TODO: param locks
  locks[y*maxwidth+x] = value
end

local function trig_is_locked(x, y) -- TODO: param locks
  return locks[y*maxwidth+x]
end

local function get_lock(x, y) -- TODO: param locks
  return locks[y*maxwidth+x]
end

-- pattern save hack (start)
local function set_bit(r, index)
  return r | 1 << index
end

local function clear_bit(r, index)
  return r & ~(1<<index)
end
-- pattern save hack (fin)


local function set_trig(x, y, value)
  trigs[y*maxwidth+x] = value
  if not value then
    set_lock(x, y, nil)
  end
end

local function trig_is_set(x, y)
  return trigs[y*maxwidth+x]
end


-- utility functions

local function split_str(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

local function is_even(number)
  return number % 2 == 0
end

local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- file i/o functions

-- see if the file exists
local function file_exists(file)
  local f = io.open(file, "r")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
local function lines_from(file)
  if file_exists(file) then print ("reading text file to table")  end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end


-- grid functions

local function refresh_grid_button(x, y, refresh)
    if params:get("last row cuts") == 2 and y == 8 then
      if x-1 == playpos then
        gr.led(x, y, PLAYPOS_LEVEL)
      else
        gr.led(x, y, CLEAR_LEVEL)
      end
    else
      if trig_is_set(x, y) then
        gr.led(x, y, TRIG_LEVEL)
      elseif x-1 == playpos then
        gr.led(x, y, PLAYPOS_LEVEL)
      else
        gr.led(x, y, CLEAR_LEVEL)
      end
    end
    if refresh then
      gr.refresh()
    end
  
end

-- pattern save hack (start)
local function restore_row_trigs(paramvalue, y)
  for x=1,16 do
    set_trig(x, y, paramvalue & (1<<x) ~= 0)
    refresh_grid_button(x, y, false)
  end
  gr.refresh()
end
-- pattern save hack (fin)

local function refresh_grid_column(x, refresh)
  for y=1,height do
    refresh_grid_button(x, y, false)
  end
  if refresh then
    gr.refresh()
  end
end


local function refresh_grid()
  gr.all(0)
  for x=1,maxwidth do
    refresh_grid_column(x, false)
  end
  gr.refresh()
end

  -- pattern load
local function patternload(pid)
    trigs = {} -- reset trigs
    --print(big_patterns[pid])
    for y=1,tablelength(big_patterns[pid])-1 do
        for x=1,16 do
        if (tonumber(big_patterns[pid][y][2][x])==1) then
            set_trig(x,y,true)
            refresh_grid_button(x, y, false)
          end 
        end
    end
    refresh_grid()
end
local function drumkitload(kitid)
    for y=1,tablelength(drumkits[kitid])-1 do
      params:set(y..": sample", "/home/we/dust/audio/common/".. drumkits[kitid].key .."/"..drumkits[kitid][y]..".wav")
    end
end


local function tick()
  ticks = (ticks or -1) + 1

  if (not ticks_to_next) or ticks_to_next == 0 then
    local previous_playpos = playpos
    if queued_playpos then
      playpos = queued_playpos
      queued_playpos = nil
    elseif params:get("grid width") == 1 then
      playpos = (playpos + 1) % 8
    else
      playpos = (playpos + 1) % 16
    end
    local new_prev_locks = {}
    local ts = {}
    for y=1,8 do
      if trig_is_set(playpos+1, y) and not (params:get("last row cuts") == 2 and y == 8) then
        ts[y] = 1
      else
        ts[y] = 0
      end
      if trig_is_locked(playpos+1, y) and not (params:get("last row cuts") == 2 and y == 8) then
        engine.speed(speed_spec:map(get_lock(playpos+1, y)))
        new_prev_locks[y] = true
      else
        if prev_locks and prev_locks[y] then
          engine.speed(params:get(y.."speed"))
        end
      end
    end
    prev_locks = new_prev_locks
    engine.multiTrig(ts[1], ts[2], ts[3], ts[4], ts[5], ts[6], ts[7], ts[8])

    if previous_playpos ~= -1 then
      refresh_grid_column(previous_playpos+1)
    end
    if playpos ~= -1 then
      refresh_grid_column(playpos+1)
    end

    gr.refresh()

    if is_even(playpos) then
      ticks_to_next = even_ppqn
    else
      ticks_to_next = odd_ppqn
    end
    redraw()
  else
    ticks_to_next = ticks_to_next - 1
  end
end

local function update_metro_time()
  timer.time = 60/params:get("tempo")/ppqn/params:get("beats per pattern")
end

local function update_swing(swing_amount)
  local swing_ppqn = ppqn*swing_amount/100*0.75
  even_ppqn = util.round(ppqn+swing_ppqn)
  odd_ppqn = util.round(ppqn-swing_ppqn)
end

gr.event = function(x,y,state) -- grid key events
  if state == 1 then
    if params:get("last row cuts") == 2 and y == 8 then
      queued_playpos = x-1
    else
      if trig_is_set(x, y) then
        set_trig(x, y, false)
        refresh_grid_button(x, y, true)
      else
        set_trig(x, y, true)
        refresh_grid_button(x, y, true)
      end
    end
    gr.refresh()
  end
  redraw()
end

-- INIT

function init()
  gr.all(0)
  local pid = 1 -- default pattern
  local drumkit_id = 2 -- default drumkit

  for x=1,maxwidth do
    for y=1,height do
    --  set_trig(x, y, false)
    end
  end

  timer = Metro.alloc()
  timer.callback = tick

    --params:read("okyeron/break_step.pset")
    --print ("reading pset")

    -- read pattern file
    local lines = lines_from(file)
    for k,v in pairs(lines) do
        if (v == "!") then break end
        if (v ~= "") then
            split_line1 = split_str(v, "|")
            if (split_line1[1] == "Pattern") then 
                pttrn_name = split_line1[2]
                --big_patterns[p_num] = {key = pttrn_name}
                
                p_idx = 1
            else
                split_line2 = split_str(split_line1[2], ",")
                sub_patterns[#sub_patterns+1] = {split_line1[1], split_line2}
                p_idx=p_idx+1
            end
        else
            -- table.insert(big_patterns, {key = pttrn_name, value= {sub_patterns}})
            big_patterns[p_num] = sub_patterns
            big_patterns[p_num].key = pttrn_name
            sub_patterns = {}
            p_num = p_num+1
        end
    end
    
    --some debug to know what is what in the patterns table 
    --tab.print(big_patterns[pid]) 
    --print (tablelength(big_patterns))
    --print (big_patterns[1].key) -- pattern name
    --print (big_patterns[pid][1][1] .. " - instrument") -- instrument
    --print (big_patterns[pid][1][2][2] .. " - step") -- [set][y][2][x]
	
	-- setup pattern name params
	params:add_number("pattern select",1,tablelength(big_patterns)-1,1)
    params:set_action("pattern select", function(n) patternload(n) end)
    params:set("pattern select", pid)

 	params:add_option("drumkit",{"606", "808", "909"},drumkit_id)
    params:set_action("drumkit", function(n) drumkitload(n) end)

    --tab.print(drumkits)
    --print(drumkit_id)
    --print (drumkits[drumkit_id].key)

  -- original step param setup
    params:add_option("grid width", {"8", "16"}, 2) -- TODO: should now be possible to infer from grid metadata(?)
    params:set_action("grid width", function(value) update_metro_time() end)
    params:add_option("last row cuts", {"no", "yes"}, 1)
    params:set_action("last row cuts", function(value)
      last_row_cuts = (value == 2)
      refresh_grid()
    end)
    params:add_number("beats per pattern", 1, 8, 4)
    params:set_action("beats per pattern", function(value) update_metro_time() end)
    params:add_control("tempo", tempo_spec)
    params:set_action("tempo", function(bpm) update_metro_time() end)

  update_metro_time()

  params:add_control("swing amount", swing_amount_spec)
  params:set_action("swing amount", update_swing)

  params:add_separator()
  Ack.add_params()


    patternload(pid)

    params:bang()

  -- pattern save hack (start)
  -- pattern save hack (fin)

  playing = true
  timer:start()

  gr.refresh()

  cleanup()
end

function cleanup()

    -- pattern save hack (start)
    params:write("okyeron/break_step.pset")
    print ("wrote pset")
  -- pattern save hack (fin)
end

function enc(n, delta)
  if n == 1 then
    mix:delta("output", delta)
  elseif n == 2 then
    params:delta("tempo", delta)
  elseif n == 3 then
    params:delta("pattern select", delta)
    -- params:delta("swing amount", delta)
  end
  redraw()
end

function key(n, z)
  if n == 2 and z == 1 then
    if playing == false then
      playpos = -1
      queued_playpos = 0
      redraw()
      refresh_grid()
    else
      playing = false
      timer:stop()
    end
  elseif n == 3 and z == 1 then
    if z == 1 then
      playing = true
      timer:start()
      key3down = true
    else
      key3down = false
    end
  end
  redraw()
end

function redraw() -- display redraw
  screen.font_size(8)
  screen.clear()
  screen.level(15)
  screen.move(10,30)
  if playing then
    screen.level(3)
    screen.text("[] stop")
  else
    screen.level(15)
    screen.text("[] stopped")
  end
  --[[
  screen.level(3)
  screen.move(50,30)
  if playing then
    screen.text(" > ")
  else
    screen.text(" < ")
  end
  ]]
  screen.font_size(8)
  screen.move(70,30)
  if playing then
    screen.level(15)
    screen.text("|> playing")
    screen.text(" "..playpos+1)
  else
    screen.level(3)
    screen.text("|> play")
  end
  screen.level(15)
  screen.move(10,50)
  screen.text(params:string("tempo"))
  screen.move(70,50)
  screen.text(big_patterns[params:get("pattern select")].key)
  screen.level(3)
  screen.move(10,60)
  screen.text("tempo")
  screen.move(70,60)
  screen.text("pattern")
  screen.update()
end