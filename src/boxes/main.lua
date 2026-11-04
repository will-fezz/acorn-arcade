-- Dots and Boxes: Small (2x2 boxes), Medium (3x3) or Large (4x4), two people or an easy computer.
-- Engine 6 game-owned five-theme art. All objects allocated once for the largest board: the host
-- retains deleted slots, so replay and size changes hide/reuse rather than create/delete.
local LAYOUT={[2]={p=96,cy=247,line=256,claim=256},[3]={p=72,cy=247,line=256,claim=224},[4]={p=56,cy=249,line=192,claim=176}}
local CX=233                       -- board centre x; cy per size sits between the header strip and the footer
local MAXE,MAXC=40,16              -- edges and boxes of the 4x4 board
local SIZE_AT={{153,358},{233,358},{313,358}} -- the three size discs on the menu page
local n=2
local edges,claims,edge_obj,claim_obj={},{},{},{}
local points,cells={},{}
local phase,solo,turn,used,ai_at,touching='menu',false,1,0,0,false
local scores={0,0}
local header,board,menu,footer,size_ring
local size_obj={}
local dots={}
local function H(r,c) return r*n+c+1 end
local function V(r,c) return n*(n+1)+r*(n+1)+c+1 end
local function status(name) gfx.src(header,name) end
local function layout(size)
  n=size;local L=LAYOUT[n];local p=L.p
  local x0,y0=CX-(n*p)//2,L.cy-(n*p)//2
  points={};cells={}
  for r=0,n do for c=0,n-1 do points[H(r,c)]={x0+c*p+p//2,y0+r*p,true} end end
  for r=0,n-1 do for c=0,n do points[V(r,c)]={x0+c*p,y0+r*p+p//2,false} end end
  for r=0,n-1 do for c=0,n-1 do cells[r*n+c+1]={H(r,c),H(r+1,c),V(r,c),V(r,c+1),x=x0+c*p+p//2,y=y0+r*p+p//2} end end
  for i,o in ipairs(dots) do
    local k=i-1;gfx.pos(o,x0+(k%(n+1))*p-12,y0+(k//(n+1))*p-12)
  end
  for i,pt in ipairs(points) do
    gfx.pos(edge_obj[i],pt[1]-(pt[3] and 28 or 24),pt[2]-(pt[3] and 24 or 28));gfx.scale(edge_obj[i],L.line)
  end
  for i,cell in ipairs(cells) do gfx.pos(claim_obj[i],cell.x-28,cell.y-28);gfx.scale(claim_obj[i],L.claim) end
  gfx.pos(size_ring,SIZE_AT[n-1][1]-32,SIZE_AT[n-1][2]-32)
end
local function board_visible(on)
  for i,o in ipairs(dots) do gfx.hide(o,not on or i>(n+1)*(n+1)) end
  gfx.hide(footer,not on);gfx.hide(menu,on);gfx.hide(size_ring,on)
  for _,o in ipairs(size_obj) do gfx.hide(o,on) end
  for i=1,MAXE do gfx.hide(edge_obj[i],not on or i>#points) end
  for i=1,MAXC do gfx.hide(claim_obj[i],not on or i>#cells or claims[i]==0) end
end
local function paint_score() gfx.text('score',scores[1]..' : '..scores[2]) end
local function start(computer)
  solo,turn,used,phase=computer,1,0,'play';scores={0,0}
  for i=1,#points do edges[i]=0;gfx.src(edge_obj[i],points[i][3] and 'h0' or 'v0') end
  for i=1,#cells do claims[i]=0 end
  board_visible(true);paint_score();status('turn1');sys.score(0)
end
local function complete(c)
  local cell=cells[c]
  for k=1,4 do if edges[cell[k]]==0 then return false end end
  return true
end
local function place(e,now)
  if phase~='play' or not e or edges[e]~=0 then return false end
  edges[e]=turn;used=used+1
  gfx.src(edge_obj[e],(points[e][3] and 'h' or 'v')..turn)
  local gained=0
  for c=1,#cells do
    if claims[c]==0 and complete(c) then
      claims[c]=turn;scores[turn]=scores[turn]+1;gained=gained+1
      gfx.src(claim_obj[c],'claim'..turn);gfx.hide(claim_obj[c],false)
    end
  end
  paint_score();sys.score(scores[1]);sys.beep(520,gained>0 and 880 or 520,gained>0 and 110 or 35)
  if used==#points then
    phase='done';status(scores[1]==scores[2] and 'draw' or scores[1]>scores[2] and 'win1' or solo and 'winai' or 'win2')
    return true
  end
  if gained==0 then turn=3-turn end
  if solo and turn==2 then ai_at=(now+650)&0x7fffffff;status('thinking')
  else status(gained>0 and (turn==1 and 'extra1' or 'extra2') or (turn==1 and 'turn1' or 'turn2')) end
  return true
end
local function computer_edge()
  -- Easy: take a visible box if available, otherwise random. No chain search.
  local free,scoring={},{}
  for e=1,#points do if edges[e]==0 then
    free[#free+1]=e;edges[e]=2
    for c=1,#cells do if claims[c]==0 and complete(c) then scoring[#scoring+1]=e;break end end
    edges[e]=0
  end end
  local options=#scoring>0 and scoring or free
  return options[sys.random(#options)+1]
end
local function choose(size)
  layout(size)
  if sys.save then sys.save('size',tostring(size)) end
end
function init()
  gfx.image('background');header=gfx.image('choose');gfx.pos(header,73,89)
  board=gfx.image('dot');dots[1]=board;menu=gfx.image('menu');gfx.pos(menu,98,155)
  footer=gfx.image('footer');gfx.pos(footer,113,376)
  for i=1,MAXE do edge_obj[i]=gfx.image('h0');edges[i]=0 end
  for i=1,MAXC do claim_obj[i]=gfx.image('claim1');claims[i]=0 end
  size_ring=gfx.image('size_on')
  for i,s in ipairs(SIZE_AT) do local o=gfx.image('size'..(i+1));size_obj[i]=o;gfx.pos(o,s[1]-28,s[2]-28) end
  for i=2,25 do dots[i]=gfx.image('dot') end
  local saved=sys.load and tonumber(sys.load('size') or '')
  layout((saved==3 or saved==4) and saved or 2)
  gfx.text('title','');gfx.text('sub','');gfx.text('score','');board_visible(false);sys.score(0)
end
function tick(now,press,down,x,y)
  local tap=press and not touching;touching=down
  if phase=='play' and solo and turn==2 then
    if ((now-ai_at)&0x7fffffff)<0x40000000 then place(computer_edge(),now);tap=false end
  end
  if not tap then return end
  if sys.active then sys.active() end
  if phase=='menu' then
    for i,s in ipairs(SIZE_AT) do if (x-s[1])^2+(y-s[2])^2<=32*32 then choose(i+1);return end end
    if x>=98 and x<368 and y>=155 and y<227 then start(true)
    elseif x>=98 and x<368 and y>=247 and y<319 then start(false) end
    return
  end
  if y>=376 and y<432 then
    if x>=113 and x<225 then start(solo)
    elseif x>=241 and x<353 then phase='menu';board_visible(false);gfx.text('score','');status('choose') end
    return
  end
  if phase~='play' or (solo and turn==2) then return end
  -- Nearest edge midpoint wins, within a disc that leaves dots and box centres dead on every size.
  local best,bd
  for e,pt in ipairs(points) do
    local d=(x-pt[1])^2+(y-pt[2])^2
    if not bd or d<bd then best,bd=e,d end
  end
  local lim=math.min(LAYOUT[n].p//2-6,30)
  if best and bd<=lim*lim then place(best,now) end
end
