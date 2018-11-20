-- clARCk port
-- for arc-dev branch

-- original maxpat by JP
-- https://github.com/monome-community/collected/tree/master/clarck

engine.name = 'TestSine'

local steps = {}
local aleds = {{},{},{},{}}

local position = 1
localintensity = 1

local ar = arc.connect()


function allLeds(z)
    for i=1,4 do
        ar.all(i, z)
    end
end

function allRefresh()
    for i=1,4 do
        ar.refresh(i)
    end
end
   
function init()
  
  counter = metro.alloc()
  counter.time = 1/64 -- interval
  counter.count = -1 -- run how long
  counter.callback = count
  counter:start()
  mcount = 0
  lastsec = 0
    allLeds(1)
    allRefresh()
    
end

function count()
    now = os.date("*t")
    mcount = mcount+1
    --print (mcount)
    --print (now)
    -- add a tick to led array each second
    -- what hour/min/second are we?
    hour = now.hour
    mins = now.min
    secs = now.sec
    
    if (secs > lastsec) or (secs == 0) then
        mcount = 0
    end
    msecs = mcount

    lastsec = secs

    
    for i=1,64 do
        if i < math.floor(hour*5) then aleds[1][i] = 15 end
        if i < mins then aleds[2][i] = 15 end
        if i < secs then aleds[3][i] = 15 end
        if i < msecs then aleds[4][i] = 15 end
    end 
--        ar.led(1, hour, 15)
--        ar.led(2, mins, 15)
--        ar.led(3, secs, 15)
    for key,value in ipairs(aleds[1]) do ar.led(1, key, value) end
    for key,value in ipairs(aleds[2]) do ar.led(2, key, value) end
    for key,value in ipairs(aleds[3]) do ar.led(3, key, value) end
    for key,value in ipairs(aleds[4]) do ar.led(4, key, value) end
        

        if hour == 0 then
            aleds[1] = {}
            ar.all(1, 1)
        end
        if mins == 0 then
            aleds[2] = {}
            ar.all(2, 1)
        end
        if secs == 0 then
            aleds[3] = {}
            ar.all(3, 1)
        end
        if msecs == 0 then
            aleds[4] = {}
            ar.all(4, 1)
        end

    arc_redraw(1)
    arc_redraw(2)
    arc_redraw(3)
    arc_redraw(4)
end

function ar.event(n, z, typ)
    --aleds[n] = math.random(64)
    print (n)
    print (z)
    print (typ)
    --ar.all(n, 1)
    for i=2,64 do
    --    ar.led(n, i, math.floor(i/4))
    end 
end

function arc_redraw(enc)
    -- redraw one specific enc arc
    ar.refresh(enc)
end
