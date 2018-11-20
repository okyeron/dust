-- clARCk port
-- for arc-dev branch

-- original maxpat by JP
-- https://github.com/monome-community/collected/tree/master/clarck

-- engine.name = 'TestSine'

local steps = {}
local aleds = {{},{},{},{}}

local tickcount = 0
local intensity = 1

local ar = arc.connect()

function init()
  mcount = 0
  lastsec = 0
  secs = 0
  
  counter = metro.alloc()
  counter.time = 1/960 -- interval
  counter.count = -1 -- run how long
  counter.callback = count
  counter:start()
    
    ar.all(0)
    arc_redraw()
    redraw()
end

function count()
    now = os.date("*t")
    hour = now.hour
    mins = now.min
    secs = now.sec
 
    if (secs > lastsec) or (secs == 0) then
        mcount = 0
        tickcount = 0
    end

    if tickcount == 0 then 
        --print (current_time)
        --print (lastsec)
        --print (secs)
        --print (lastsec)
        lastsec = secs

    end

    if tickcount%16 == 0 then 
        aleds[1] = {}
        aleds[2] = {}
        aleds[3] = {}
        aleds[4] = {}
    --    ar.all(0)  -- dont actaully send a 0 mes, just reset the array
    end
   
    -- fill led arrays
    for i=1,64 do
        if i <= math.ceil(hour*2.7) then 
            if i==0 or i==16 or i==32 or i==48 then
                aleds[1][i] = 4
            else
                aleds[1][i] = 15
            end 
        else
            aleds[1][i] = 0
        end
        if i <= mins then 
            if i==0 or i==16 or i==32 or i==48 then
                aleds[2][i] = 4
            else
                aleds[2][i] = 15 
            end
        else
            aleds[2][i] = 0
        end
        if i <= secs then 
            if i==0 or i==16 or i==32 or i==48 then
                aleds[3][i] = 4 
            else
                aleds[3][i] = 15 
            end
         else
            aleds[3][i] = 0
       end
        if i <= mcount then 
            aleds[4][i] = 15 
        else
            aleds[4][i] = 0
        end
    end 
    -- set array to LED values
    for key,value in ipairs(aleds[1]) do ar.led(1, key, value) end
    for key,value in ipairs(aleds[2]) do ar.led(2, key, value) end
    for key,value in ipairs(aleds[3]) do ar.led(3, key, value) end
    for key,value in ipairs(aleds[4]) do ar.led(4, key, value) end
        

    if hour == 0 then
        aleds[1] = {}
    end
    if mins == 0 then
        aleds[2] = {}
    end
    if secs == 0 then
        aleds[3] = {}
    end
    if mcount == 0 then
        aleds[4] = {} 
    end
 
    if tickcount%15 == 0 then -- use all 64 leds for sub-seconds
        mcount = mcount+1
    end

    if tickcount == 960 then tickcount = 0 end
      
    
    --redraw every 60 ticks
    if tickcount%16 == 0 then arc_redraw() end


    if tickcount == 0 then redraw() end -- redraw norns display every second
    tickcount = tickcount + 1
    
end

function ar.event(n, z, typ)
    --aleds[n] = math.random(64)
    print (n)
    print (z)
    print (typ)
    --ar.all(0)
    for i=1,64 do
    --    ar.led(n, i, math.floor(i/4))
    end 
end

function arc_redraw()
    -- redraw 
    ar.refresh()
end

function redraw()
  -- clear screen
  screen.aa(1)
  screen.clear()
  -- set pixel brightness (0-15)
  screen.level(15)
  -- set text face
  screen.font_face(1)

  screen.move(3,10)
  -- set text size
  screen.font_size(8)
  -- draw text
  screen.text("CL ARC K")

  screen.move(15,42)
  screen.font_face(5)
  -- set text size
  screen.font_size(20)
  -- draw text
  current_time = os.date("%H:%M:%S")
  screen.text(current_time)
  -- draw centered text
  screen.update()
end