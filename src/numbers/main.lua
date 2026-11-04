-- Numbers: engine 6, no external assets beyond an owned-pack anchor/tile.
-- All drawing objects are allocated once, avoiding the host's lifetime 512-ID cap.
local glyph = {
 [0]={{.2,0},{.8,0},{1,.2},{1,.8},{.8,1},{.2,1},{0,.8},{0,.2},{.2,0}},
 [1]={{.2,.2},{.5,0},{.5,1}},
 [2]={{0,.15},{.2,0},{.8,0},{1,.2},{.9,.4},{0,1},{1,1}},
 [3]={{0,0},{1,0},{.5,.45},{1,.6},{1,.85},{.8,1},{0,1}},
 [4]={{.8,1},{.8,0},{0,.65},{1,.65}},
 [5]={{1,0},{0,0},{0,.45},{.8,.45},{1,.65},{1,.85},{.8,1},{0,1}},
 [6]={{.9,0},{.3,.1},{0,.5},{0,.8},{.2,1},{.8,1},{1,.8},{1,.6},{.8,.45},{0,.45}},
 [7]={{0,0},{1,0},{.3,1}},
 [8]={{.5,.5},{0,.25},{.1,0},{.9,0},{1,.25},{.5,.5},{0,.75},{.1,1},{.9,1},{1,.75},{.5,.5}},
 [9]={{1,.55},{.2,.55},{0,.35},{0,.15},{.2,0},{.8,0},{1,.2},{1,.7},{.7,1},{.2,1}}
}
local pools, boxes, dots, controls = {}, {}, {}, {}
local mode, phase, goal, choices, correct, score, deadline = 'menu','play',0,{},1,0,nil
local trace, nextpoint, number = {},1,0
local accent, shadow = 0x3C7A3A,0x1C3A1E
local WHITE, INK, GUIDE = 0xFFFFFF,0xFFFFFF,0xBED0CB
local KINDS = {'thing_a','thing_b','thing_c','thing_d'} -- the theme's four countables (apple, ladybird, daisy, strawberry outdoors)
-- Trace ink in the theme's gold accent2 (keyed by the public tilt_wall value); the untraced guide is the same dots at low opacity.
local GOLDS = {['3C7A3A']=0xF2B84B,['5A7FA8']=0xFFD24A,['8A5A34']=0x7ECC54,['E88BB8']=0x8FE0C0,['C03C3C']=0xF3CF5A}
local gold = 0xF2B84B
local function round(n) return math.floor(n+.5) end
local function hidepool(p) for _,o in ipairs(p) do gfx.hide(o,true) end end
local function newpool(n,col)
 local p={}; for i=1,n do p[i]=gfx.image("bead");gfx.recolor(p[i],col,255);gfx.hide(p[i],true) end;return p
end
local function points(n,x,y,w,h)
 local out={}
 local function one(d,ox,ww)
  local g=glyph[d]
  for i=1,#g-1 do
   local a,b=g[i],g[i+1];local dx,dy=(b[1]-a[1])*ww,(b[2]-a[2])*h
   local steps=math.max(1,math.ceil(math.sqrt(dx*dx+dy*dy)/9))
   for k=0,steps-1 do out[#out+1]={round(ox+a[1]*ww+dx*k/steps),round(y+a[2]*h+dy*k/steps)} end
  end
  out[#out+1]={round(ox+g[#g][1]*ww),round(y+g[#g][2]*h)}
 end
 if n==10 then one(1,x,w*.32);one(0,x+w*.5,w*.5) else one(n,x,w) end
 return out
end
local function paint(p,pts,col)
 assert(#pts<=#p)
 for i,o in ipairs(p) do
  gfx.hide(o,i>#pts)
  if pts[i] then gfx.pos(o,pts[i][1]-3,pts[i][2]-3);gfx.opa(o,col==GUIDE and 110 or 255) end
 end
end
local function clear()
 for _,p in ipairs(pools) do hidepool(p) end
 for _,o in ipairs(dots) do gfx.hide(o,true) end
 for _,o in ipairs(boxes) do gfx.hide(o,true) end
 gfx.text('title','');gfx.text('sub','');gfx.text('score','')
end
local function menu()
 clear();mode='menu';phase='play';deadline=nil
 gfx.text('score','Numbers');gfx.text('title','Choose a game');gfx.text('sub','Count     Trace     Compare')
 for i=1,3 do gfx.hide(boxes[i],false) end
 paint(pools[1],points(3,99,330,26,40),WHITE)
 paint(pools[2],points(2,220,330,26,40),WHITE)
 -- Compare icon: one thing against two.
 gfx.src(dots[1],KINDS[1]);gfx.pos(dots[1],318,322);gfx.hide(dots[1],false)
 for i=2,3 do gfx.src(dots[i],KINDS[2]);gfx.pos(dots[i],354,312+(i-2)*38);gfx.hide(dots[i],false) end
 for _,o in ipairs(controls) do gfx.hide(o,true) end
end
local function win(now)
 phase='win';deadline=now+1300;score=score+1;sys.score(score)
 gfx.text('sub','Lovely!');sys.beep(660,990,100)
end
local function showobjects(n,x,y,offset,cols,kind)
 for i=1,n do local o=dots[offset+i];gfx.src(o,kind);gfx.pos(o,x+((i-1)%cols)*44,y+((i-1)//cols)*(cols==5 and 50 or 44));gfx.hide(o,false) end
end
local function start()
 clear();phase='play';deadline=nil
 for _,o in ipairs(controls) do gfx.hide(o,false) end
 if mode=='trace' then
  gfx.text('score','Trace '..number)
  trace=points(number,168,125,130,180);nextpoint=1
  paint(pools[4],trace,GUIDE)
  gfx.opa(pools[4][1],255)
  gfx.pos(controls[2],trace[1][1]-12,trace[1][2]-12)
 elseif mode=='count' then
  goal=sys.random(11);correct=sys.random(3)+1;choices={}
  choices[correct]=goal
  local used={[goal]=true}
  for i=1,3 do if i~=correct then
   -- Bounded selection, including a deterministic fallback for test/random sources.
   local v=sys.random(11);while used[v] do v=(v+1)%11 end
   choices[i]=v;used[v]=true
  end end
  gfx.text('score','How many?');gfx.text('sub',goal==0 and 'None? Tap zero.' or 'Count, then tap a number')
  showobjects(goal,123,132,0,5,KINDS[sys.random(4)+1])
  for i=1,3 do gfx.hide(boxes[i],false);paint(pools[i],points(choices[i],99+(i-1)*121,330,26,40),WHITE) end
  gfx.hide(controls[2],true)
 else
  local a=sys.random(9)+1;local b=(a+sys.random(8))%9+1
  if b==a then b=a%9+1 end
  local more=(mode=='more');correct=((more and a>b) or (not more and a<b)) and 1 or 2
  gfx.text('score',more and 'More' or 'Less');gfx.text('sub',more and 'Tap the bigger group' or 'Tap the smaller group')
  gfx.hide(boxes[4],false);gfx.hide(boxes[5],false)
  local ka=sys.random(4)+1;local kb=(ka+sys.random(3))%4+1 -- two different kinds, so counting is the only way
  showobjects(a,89,115,0,3,KINDS[ka]);showobjects(b,253,115,10,3,KINDS[kb])
  gfx.hide(controls[2],true)
 end
end
function init()
 accent=tonumber(sys.theme('tilt_wall') or '',16) or accent
 shadow=tonumber(sys.theme('tilt_wall_sh') or '',16) or shadow
 gold=GOLDS[sys.theme('tilt_wall') or ''] or gold
 gfx.image('field') -- the theme's pond page (Bounce Back's field), bundled with the game
 for i=1,3 do boxes[i]=gfx.box(76+(i-1)*121,310,72,80,24,shadow,255) end
 boxes[4]=gfx.box(76,100,150,150,20,shadow,170);boxes[5]=gfx.box(240,100,150,150,20,shadow,170)
 for i=1,3 do pools[i]=newpool(55,WHITE) end;pools[4]=newpool(160,gold)
 for i=1,20 do dots[i]=gfx.image(KINDS[1]);gfx.hide(dots[i],true) end
 controls[1]=gfx.box(204,402,58,30,12,shadow,255)
 controls[2]=gfx.box(0,0,24,24,12,gold,150)
 controls[3]=gfx.line(220,417,246,417,4,WHITE)
 controls[4]=gfx.line(220,417,228,410,4,WHITE)
 controls[5]=gfx.line(220,417,228,424,4,WHITE)
 gfx.text_color('title',INK);gfx.text_color('sub',INK);gfx.text_color('score',WHITE)
 menu()
end
function tick(now,press,down,x,y)
 if press or down then sys.active() end
 if press and mode~='menu' and x>=194 and x<=272 and y>=392 and y<=442 then menu();return end
 if mode=='menu' then
  if press and y>=300 and y<=390 then
   if x>=66 and x<=158 then mode='count' elseif x>=187 and x<=279 then mode='trace';number=0 elseif x>=308 and x<=400 then mode='more' else return end
   start()
  end;return
 end
 if phase=='win' then
  if now>=deadline then
   if mode=='trace' then number=(number+1)%11 elseif mode=='more' then mode='less' elseif mode=='less' then mode='more' end
   start()
  end;return
 end
 if mode=='trace' then
  if down then
   local p=trace[nextpoint];local dx,dy=x-p[1],y-p[2]
   if dx*dx+dy*dy<=20*20 then
    gfx.opa(pools[4][nextpoint],255);nextpoint=nextpoint+1
    if nextpoint>#trace then gfx.hide(controls[2],true);win(now)
    else local q=trace[nextpoint];gfx.pos(controls[2],q[1]-12,q[2]-12) end
   end
  end;return
 end
 if not press then return end
 local selected
 if mode=='count' and y>=300 and y<=390 then
  for i=1,3 do local xx=76+(i-1)*121;if x>=xx-10 and x<=xx+82 then selected=i end end
 elseif mode~='count' and y>=100 and y<=250 then
  if x>=70 and x<=230 then selected=1 elseif x>=236 and x<=396 then selected=2 end
 end
 if selected then
  if selected==correct then win(now) else gfx.text('sub','Have another look');sys.beep(360,440,50) end
 end
end
