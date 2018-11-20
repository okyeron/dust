--local mo = midi.connect(1) -- connect to port 1 (which is set in SYSTEM > DEVICES)
local mo = midi.connect(2) -- defaults to port 1 (which is set in SYSTEM > DEVICES)


-- process incoming midi
mo.event = function(data) 
  d = midi.to_msg(data)
  --tab.print(d)
    if d.type == "cc" then
        print ("cc: ".. d.cc .. " " .. d.val)
        --print (d.val)
     -- do stuff with d.cc (cc number) and d.val (incoming value)
    end
    if d.type == "note_on" then
        print (d.vel)
        print (d.note)
     -- do stuff with d.note-on (note, vel, ch)
    end
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function showme()
    print("-midi.list-")
    tab.print(midi.list)

    --table.insert(midi.devices.options.midi,1)
    print("-midi.devices-")
    tab.print(midi.devices)
    for w,z in pairs(midi.devices) do
        tab.print(z)
        print("-")
    end
    
    print("-midi vport-")
    --tab.print(midi.vport)
    
    for x,y in pairs(midi.vport) do
        print (x .. ": " .. y.name)
    end
    print("-")
    print("-midi device details-")
    for i,v in pairs(midi.devices) do
      tab.print(midi.devices[i])
      print("-")
    end
    
 


    print("-Grids-")
    --tab.print(grid.list)
    for i,v in pairs(grid.list) do
        print(grid.list[i])
        if string.find (grid.list[i], "a40h") then 
            print ("arduinome")
        elseif string.find (grid.list[i], "40h") then 
            print ("40h")
        elseif string.find (grid.list[i], "m64-") then 
            print ("series 64")
        elseif string.find (grid.list[i], "m128-") then 
            print ("series 128")
        elseif string.find (grid.list[i], "m256-") then 
            print ("series 256")
        else
            print ("other mext device")
        end
    end
            
    --print(string.find (grid.vport[i].name, "467"))
    
    print("-Grid vport-")
    --tab.print(grid.vport)
    for i,v in pairs(grid.vport) do
      --tab.print(grid.vport[i])
      print(grid.vport[i].name)
      
      -- print("-")
    end


    --print("-Grid devices-")
    --tab.print(grid.devices)
    --print (tablelength(grid.devices))
    
    --print("-Grid device details-")
    --for i,v in pairs(grid.devices) do
    --  tab.print(grid.devices[i])
    --  print("-")
    --end
    
end 

function init()
    showme()
end

--print(midi.devices[3].name)


-- helper send functions:
--o.note_on(80,100)
--o.note_off(80) -- optional off vel

-- raw bytes:
--o.send{144,80,100}

-- or message table:
--o.send{type="note_on", note=72, vel=100}
--o.cc(72,100)

-- select different port
--local second_midi = midi.connect(2)
--second_midi.cc(72,100)

--second_midi.event = function(data) 
--  tab.print(midi.to_msg(data))
--end

-- grids
gr = grid.connect() -- get grid port 1 (defined in menu)

gr.all(0)
--gr.led(math.random(1,8),math.random(1,8),2)
--gr.led(math.random(1,8),math.random(1,8),15)
--gr.all(2)
gr.refresh()
gr.event = function(x,y,z) print("hello!!!") end

p_index = gr.index -- gets the vport for this connection
print (p_index)

tab.print (gr)