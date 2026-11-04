-- Engine 6, self-contained theme bundle. No dynamic code, external assets or I/O.
local objs, paths = {}, {}
local guides, ink, inkCount = {}, {}, 0
local POOL = 112 -- largest glyph has 104 checkpoints; allocated once per launch
local idx, lower, stage, stroke, point = 1, false, 'intro', 1, 1
local marker, lift, completed, lastControl = nil, false, 0, -1000
local PAGE, GUIDE, INK, DOT, TEXT = 0x0E1222, 0x8E9BC0, 0x55AE9F, 0xF2B84B, 0xFFFFFF
local SURFACE = 0x26365E
local function add(o) objs[#objs+1]=o; return o end
local function line(a,b,w,c) return add(gfx.line(a[1],a[2],b[1],b[2],w,c)) end
local function box(x,y,w,h,r,c) return add(gfx.box(x,y,w,h,r,c,255)) end
local function letter() return string.char((lower and 96 or 64)+idx) end
local function save() sys.save('pick', tostring(idx)..(lower and ':l' or ':u')) end
local function controls()
  -- Previous / repeat / next. 56px targets, well within the circular display.
  for _,x in ipairs({115,233,351}) do box(x-28,359,56,56,28,SURFACE) end
  line({125,375},{110,387},4,TEXT); line({110,387},{125,399},4,TEXT)
  line({341,375},{356,387},4,TEXT); line({356,387},{341,399},4,TEXT)
  add(gfx.arc(233,387,15,35,315,4,TEXT))
  line({243,371},{243,382},4,TEXT); line({243,371},{232,371},4,TEXT)
end
local function build()
  paths={}; stroke=1; point=1; lift=false; stage='trace'; inkCount=0
  for i=1,POOL do gfx.hide(guides[i],true);gfx.hide(ink[i],true) end
  gfx.text('title',''); gfx.text('sub',''); gfx.text('score',letter())
  gfx.text_color('score',TEXT)
  for _,s in ipairs(GLYPHS[letter()]) do
    local samples={}
    for i=1,#s do
      local b={140+math.floor(s[i][1]*1.9+0.5),120+math.floor(s[i][2]*1.9+0.5)}
      if i==1 then samples[1]=b else
        local a={140+math.floor(s[i-1][1]*1.9+0.5),120+math.floor(s[i-1][2]*1.9+0.5)}
        local n=math.max(1,math.ceil(math.sqrt((b[1]-a[1])^2+(b[2]-a[2])^2)/9))
        for j=1,n do samples[#samples+1]={math.floor(a[1]+(b[1]-a[1])*j/n+0.5),math.floor(a[2]+(b[2]-a[2])*j/n+0.5)} end
      end
    end
    paths[#paths+1]=samples
  end
  local total=0
  for _,samples in ipairs(paths) do for _,p in ipairs(samples) do
    total=total+1; assert(total<=POOL,'glyph exceeds fixed pool')
    gfx.pos(guides[total],p[1]-12,p[2]-12);gfx.hide(guides[total],false)
  end end
  gfx.pos(marker,paths[1][1][1]-9,paths[1][1][2]-9);gfx.hide(marker,false);gfx.front(marker)
  save()
end
local function moveMarker()
  local p=paths[stroke][point]
  gfx.pos(marker,p[1]-9,p[2]-9); gfx.front(marker)
end
function init()
  objs={}; paths={}; idx=1; lower=false; lastControl=-1000
  local palette=PALETTES[sys.theme('tilt_wall') or '']
  if palette then PAGE=palette.page; SURFACE=palette.surface2; INK=palette.accent; DOT=palette.accent2; TEXT=palette.text end
  GUIDE=0xFFFFFF -- white guide dots at 80 % on the painted meadow, as the design pass drew them
  gfx.image('paper') -- the theme's meadow field (bg_meadow), bundled with the game
  guides={};ink={}
  for i=1,POOL do guides[i]=add(gfx.box(0,0,24,24,12,GUIDE,200));gfx.hide(guides[i],true) end
  for i=1,POOL do ink[i]=box(0,0,12,12,6,INK);gfx.hide(ink[i],true) end
  controls()
  -- Top letter doubles as the uppercase/lowercase switch. A small Aa pictogram.
  line({292,67},{299,49},2,DOT); line({299,49},{306,67},2,DOT); line({295,60},{303,60},2,DOT)
  add(gfx.arc(318,61,6,0,360,2,DOT)); line({324,55},{324,68},2,DOT)
  marker=box(0,0,18,18,9,DOT);gfx.hide(marker,true)
  local saved=sys.load('pick')
  if saved then local n,c=saved:match('^(%d+):([ul])$'); n=tonumber(n); if n and n>=1 and n<=26 then idx=n; lower=c=='l' end end
  gfx.text('title','Trace letters'); gfx.text('sub','Tap to start. Follow the dot.')
  gfx.text('score',''); gfx.text_color('title',TEXT); gfx.text_color('sub',TEXT)
  stage='intro'; completed=0; sys.score(0)
end
function tick(now,press,down,x,y)
  if stage=='intro' then if press then build(); lastControl=now end; return end
  if press and now-lastControl>=250 then
    if y>=32 and y<=96 and x>=170 and x<=335 then lower=not lower; build(); lastControl=now; return end
    if y>=359 and y<=415 then
      if math.abs(x-115)<=28 then idx=(idx+24)%26+1
      elseif math.abs(x-351)<=28 then idx=idx%26+1
      elseif math.abs(x-233)>28 then return end
      build(); lastControl=now; return
    end
  end
  if stage~='trace' then return end
  if not down then lift=false; return end
  if lift then return end
  -- Progress must follow the ordered checkpoints; touching an endpoint cannot
  -- fill the intervening path. Lifting never erases a child's work.
  local budget=6
  while budget>0 do
    local p=paths[stroke][point]
    if (x-p[1])^2+(y-p[2])^2>24^2 then return end
    inkCount=inkCount+1;gfx.pos(ink[inkCount],p[1]-6,p[2]-6);gfx.hide(ink[inkCount],false)
    point=point+1; budget=budget-1
    if point>#paths[stroke] then
      stroke=stroke+1; point=1; sys.beep(600,750,65)
      if stroke>#paths then
        stage='done'; completed=completed+1; sys.score(completed)
        gfx.hide(marker,true); gfx.text('score',letter()..'  *')
        sys.beep(850,1100,110); return
      end
      lift=true; moveMarker(); return
    end
    moveMarker()
  end
end
