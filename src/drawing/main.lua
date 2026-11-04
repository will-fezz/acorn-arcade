-- Drawing: a round paper that fills the glass, colours along the top rim, brushes along the bottom rim.
-- The host has images, boxes and a 512 lifetime object cap but no mutable bitmap, so the paper is a fixed grid
-- of 16 px image cells (377 of them inside a 176 px radius) recoloured as the finger passes; nothing is
-- allocated after init. Six colours, three widths, eraser, confirmed clear. Nothing is saved.
local palettes={
 ['3C7A3A']={0x0E1222,0x26365E,0x55AE9F},
 ['5A7FA8']={0x0A0D24,0x28326C,0x70B7FF},
 ['8A5A34']={0x180C0A,0x583224,0xFF8A3D},
 ['E88BB8']={0x1A1234,0x4E3A82,0xFF8FC8},
 ['C03C3C']={0x101228,0x363866,0xE24B4B}}
local colors={0x232636,0xE24B4B,0xF2B84B,0x3C9C66,0x4B83DD,0xBB5FC3}
local C,S,N,ORG,LIM=233,16,23,49,176     -- centre, cell size, grid columns, grid origin, paper radius for cell centres
local PAPER,TOOLR,HIT=186,206,30          -- white disc radius, rim radius of the targets, target hit radius
local cells,values,index={},{},{}         -- index[row*N+col+1] -> cell number or nil outside the paper
local ink,width,erase=1,1,false
local touching,gesture,px,py=false,nil,nil,nil
local modal,told=false,false
local colorRing,toolRing,dialog
local COLOUR_AT,TOOL_AT={},{}             -- rim target centres
local function at(deg) return C+math.floor(TOOLR*math.cos(math.rad(deg))+.5),C+math.floor(TOOLR*math.sin(math.rad(deg))+.5) end
for i,deg in ipairs({-135,-117,-99,-81,-63,-45}) do COLOUR_AT[i]={at(deg)} end
for i,deg in ipairs({54,72,90,108,126}) do TOOL_AT[i]={at(deg)} end
local function selections()
 local c=COLOUR_AT[ink];gfx.pos(colorRing,c[1]-24,c[2]-24)
 local t=TOOL_AT[erase and 4 or width];gfx.pos(toolRing,t[1]-24,t[2]-24)
end
local function clear()
 for i,o in ipairs(cells) do values[i]=0;gfx.recolor(o,0xFFFFFF,255) end
end
local function stamp(cx,cy)
 -- Odd footprints give centred 16 / 48 / 80 px brushes; cells outside the paper simply do not exist.
 local r=width-1
 for dy=-r,r do for dx=-r,r do
  local x,y=cx+dx,cy+dy
  if x>=0 and x<N and y>=0 and y<N then
   local i=index[y*N+x+1]
   if i then
    local v=erase and 0 or ink
    if values[i]~=v then values[i]=v;gfx.recolor(cells[i],v==0 and 0xFFFFFF or colors[v],255) end
   end
  end
 end end
end
local function stroke(x0,y0,x1,y1)
 -- Integer Bresenham interpolation avoids gaps when host samples skip cells.
 local dx,dy=math.abs(x1-x0),-math.abs(y1-y0)
 local sx,sy=x0<x1 and 1 or -1,y0<y1 and 1 or -1
 local err=dx+dy
 while true do
  stamp(x0,y0)
  if x0==x1 and y0==y1 then break end
  local e=2*err
  if e>=dy then err=err+dy;x0=x0+sx end
  if e<=dx then err=err+dx;y0=y0+sy end
 end
end
local function near(list,x,y)
 for i,p in ipairs(list) do if (x-p[1])^2+(y-p[2])^2<=HIT*HIT then return i end end
end
function init()
 local p=palettes[sys.theme('tilt_wall')] or palettes['3C7A3A']
 gfx.text('title','');gfx.text('score','')
 gfx.image('background') -- the theme's picnic page, bundled with the game
 gfx.box(C-PAPER,C-PAPER,PAPER*2,PAPER*2,PAPER,0xFFFFFF,255) -- the round paper
 cells={};values={};index={}
 for row=0,N-1 do for col=0,N-1 do
  local x,y=ORG+col*S,ORG+row*S
  if (x+S/2-C)^2+(y+S/2-C)^2<=LIM*LIM then
   local o=gfx.image('pixel');gfx.pos(o,x,y);cells[#cells+1]=o;index[row*N+col+1]=#cells
  end
 end end
 clear()
 -- Rim targets: selection discs sit behind 36 px colour discs and tool pictures.
 colorRing=gfx.box(0,0,48,48,24,p[3],255)
 for i,c in ipairs(colors) do local a=COLOUR_AT[i];gfx.box(a[1]-18,a[2]-18,36,36,18,c,255) end
 toolRing=gfx.box(0,0,48,48,24,p[3],255)
 for i,name in ipairs({'tool_thin','tool_mid','tool_wide','tool_erase','tool_clear'}) do
  local o=gfx.image(name);gfx.pos(o,TOOL_AT[i][1]-18,TOOL_AT[i][2]-18)
 end
 dialog=gfx.image('confirm');gfx.pos(dialog,99,166);gfx.hide(dialog,true)
 ink,width,erase,modal,told=1,1,false,false,false
 gfx.text_color('sub',p[1]);gfx.text('sub','Drawing is not saved') -- page-colour note on the white paper until the first touch; the clear card repeats it
 selections();sys.score(0)
end
function tick(now,press,down,x,y)
 local tap=(press or down) and not touching
 touching=down
 if not down and not press then gesture=nil;px=nil;py=nil;return end
 if sys.active then sys.active() end
 if not told then told=true;gfx.text('sub','') end
 if tap then
  gesture='ui';px=nil;py=nil
  if modal then
   if y>=244 and y<300 and x>=109 and x<357 then
    if x>=243 then clear() end
    modal=false;gfx.hide(dialog,true)
   end
   return
  end
  local c=near(COLOUR_AT,x,y)
  if c then ink=c;erase=false;selections();return end
  local t=near(TOOL_AT,x,y)
  if t then
   if t<=3 then width=t;erase=false elseif t==4 then erase=true
   else modal=true;gfx.hide(dialog,false) end
   selections();return
  end
  if (x-C)^2+(y-C)^2<=PAPER*PAPER then gesture='draw' end
 end
 if modal or gesture~='draw' then return end
 if (x-C)^2+(y-C)^2>PAPER*PAPER then px=nil;py=nil;return end
 local cx,cy=math.floor((x-ORG)/S),math.floor((y-ORG)/S)
 stroke(px or cx,py or cy,cx,cy);px,py=cx,cy
end
