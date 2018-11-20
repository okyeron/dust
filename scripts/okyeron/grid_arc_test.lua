-- grid and arc test

--engine.name = 'TestSine'

steps = {}
aleds = {{},{},{},{}}
position = {1,1,1,1}
intensity = 1
starter = math.random(64)

local g = grid.connect()
local ar = arc.connect()


function init()
  counter = metro.alloc()
  counter.time = 1/30 -- interval
  counter.count = -1 -- run how long
  counter.callback = count
  counter:start()

    
  for i=1,16 do
    table.insert(steps,2)
  end
  for i=1,4 do
    table.insert(aleds,math.random(64))
  end
  g.rotation(0)
  grid_redraw()

    ar.all(0)

    for i=1,4 do
        for j=1,64 do
           ar.led(i, j, 4)
        end
    end
    
    arc_redraw()
    redraw()
end

function count()
    if position[1] == 65 then position[1] = 1 end
    
    for i=1,64 do
        if position[1] == i then
            for j=1,15 do
                ar.led(1, i-(j*2), 16-j)
            end
        else 
            ar.led(1, i, 0)
        end
    end 

    position[1] = position[1]+1
    
    arc_redraw()
end


function ar.delta(n, z)
    --aleds[n] = math.random(64)
    print (n)
    print (z)
    

    ar.all(0)
    
    --for i=1,64 do
        ar.led(n, math.abs(z), 15)
    --end 

    arc_redraw()
end 

function ar.key(n, z)
    print (n)
    print (z)
end 


function arc_redraw()
    ar.refresh()
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
    --print (steps[i])
    g.led(i,steps[i],intensity)
  end
  g.refresh()
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
  screen.text("GRID ARC TEST")

   screen.update()
end