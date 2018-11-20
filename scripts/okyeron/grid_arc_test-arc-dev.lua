-- grid and arc test

engine.name = 'PolyPerc'

steps = {}
aleds = {}
position = 1
intensity = 1

local g = grid.connect()
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
  for i=1,16 do
    table.insert(steps,math.random(8))
  end
  for i=1,4 do
    table.insert(aleds,math.random(64))
  end
  grid_redraw()
    allLeds(1)

    for i=1,4 do
        for j=1,64 do
           -- ar.led(i, j, 5)
        end
    end
    
    --ar.refresh(1)
    --ar.refresh(2)
    --ar.refresh(3)
    --ar.refresh(4)
    
    allRefresh()
    
end

function ar.event(n, z)
    --aleds[n] = math.random(64)
    --print (n)
    --print (z)
    ar.all(n, 1)
    for i=2,z do
        ar.led(n, i, math.floor(i/4))
    end 

    arc_redraw(n)
end 

function arc_redraw(n)
    ar.refresh(n)
end

function g.event(x, y, z)
  if z == 1 then
    steps[x] = y
    grid_redraw()
  end
end

function grid_redraw()
  g.all(0)
  for i=1,16 do
    if i==position then intensity = 15 else intensity = 4 end
        --print (intensity)
    g.led(i,steps[i],intensity)
  end
  g.refresh()
end
