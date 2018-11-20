-- OBLIQUE STRATEGIES
-- Brian Eno & Peter Schmidt
--
-- KEY 3 / Random strategy
-- KEY 2 / Random cutoff value
-- ENC 3 / Linear strategy scroll
-- ENC 1,2 / Clear screen

engine.name = 'PolyPerc'

-- read strategies from a text file
local file = '/home/we/dust/scripts/oblique.txt'

-- set y position to start writing text on screen
local start_y = 30

-- see if the file exists
function file_exists(file)
  local f = io.open(file, "r")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
  if file_exists(file) then print ("reading text file to table")  end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end


function textwrap(s, w, offset)
  local len =  string.len(s)
  print (len)
  local strstore = {}
  local k = 1
  while k < len do
      table.insert(strstore, string.sub(s, k, k+w-1))
     k = k + w
  end
    strposition = start_y + offset
    for v in pairs(strstore) do
        screen.text(strstore[v])
        screen.move(0, strposition)
        strposition = strposition + offset
    end 
end

-- get strategies from text file - each line into an array
-- then get a count of how many items in the array
local lines = lines_from(file)
local ob_count = 0
for k,v in pairs(oblique) do
     ob_count = ob_count + 1
end

-- SET DEFAULT VARIABLES/VALUES + INITIALIZE STRATEGIES TABLE
function init()
  position = 1
  f = 1000
  engine.hz(0)
  engine.amp(0)
  mode = 2
  oblique = lines
end

-- GENERATE SCALE
local scale = {
  1/8, 1/6, 1/5, 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 7/8
}

function redraw()
  -- RETRIEVE/DISPLAY RANDOM STRATEGY FROM TABLE
  if mode == 0 then
    screen.clear()
    screen.level(15)
    -- wrap text
    screen.move(0,start_y)
    textwrap(oblique[ math.random( #oblique )], 28, 10)
   
    -- center text so start from center point
    --screen.move(64,32)
    -- screen.text_center(oblique[math.random(ob_count)])
    -- alternate way to get random item from array
    --screen.text_center(oblique[ math.random( #oblique )])
  end
  -- ORGANIZE SEQUENTIAL DISPLAY OF TABLE VALUES
  if mode == 1 then
    screen.clear()
    screen.level(15)
    screen.move(0,30)
    screen.text(oblique[position])
    screen.move(0,40)
    screen.level(1)
    screen.text(position .. "/" .. #oblique)
  end
  if mode == 2 then
    screen.clear()
  end
  screen.update()
end

function enc(n,d)
  -- USE ENC 3 TO SEQUENTIALLY SCROLL THROUGH STRATEGIES 
  if n == 3 then
    mode = 1
    position = position + d
    if position > ob_count then
      position = ob_count
    end
    if position < 1 then
      position = 1
    end
  end
  redraw()
  -- USE ENC 1 OR 2 TO CLEAR SCREEN
  if n == 1 or n == 2 then
    d = 0
    mode = 2
  end
end

function key(n,z)
  -- USE KEY 3 TO DISPLAY RANDOM STRATEGY
  if n == 3 and z == 1 then
    mode = 0
    engine.hz(f * scale[math.random(13)])
    engine.release(math.random(5))
    engine.amp(0.5)
    engine.pw(math.random(100)/100)
    redraw()
  end
  if n == 2 then
    engine.cutoff(1000*(math.random(20)))
  end
end
