--ds = nil
--package.loaded["ds"] = nil
local ds = require "drawshapes"

function init()
  t = {
    {1,2,3,4},
    {5,6,7,8},
    {9,10,11,12}
  }
    c = 0
    cx=64 --x center
    cy=32 --y center
    radius=30 --radius
    percent=70 --needle percent
    position = 0
    
end


function redraw()
  -- enable anti-alasing
  screen.aa(1)
  -- clear screen
  screen.clear()
  screen.move(0,0)
  -- set pixel brightness (0-15)
  screen.level(10)
  -- set line width
  --screen.line_width(1.0)
  -- move position
    
 --   screen.circle (cx, cy, radius)
    ds.drawgauge(cx,cy,radius,percent,position,0,100)
--    screen.stroke()
--    screen.close()
 --   screen.circle (cx, cy, radius-22)
 --   screen.level (0)
 --   screen.fill()
    
    --ds.drawgauge(cx,cy,radius,percent,1,0,100)
    --ds.gridlay(8,8,0,0)
    --screen.update()

  screen.update()
end 

    
function enc(n, delta)
    if n==2 then
      screen.clear()
      --screen.level (10)
      ds.drawgauge(cx,cy,radius,percent,position+delta,0,100)
      screen.update()
      position = position+delta
    end
    redraw()
end


