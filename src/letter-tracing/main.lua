-- Original monoline print alphabet; coordinates normalized to 0..100.
local GLYPHS = {
["A"] = {{{0, 100}, {50, 0}, {100, 100}}, {{22, 60}, {78, 60}}},
["B"] = {{{0, 100}, {0, 0}, {55, 0}, {85, 15}, {85, 35}, {55, 50}, {0, 50}}, {{55, 50}, {90, 65}, {90, 85}, {60, 100}, {0, 100}}},
["C"] = {{{90, 15}, {70, 0}, {30, 0}, {5, 25}, {0, 50}, {5, 75}, {30, 100}, {70, 100}, {90, 85}}},
["D"] = {{{0, 100}, {0, 0}, {45, 0}, {80, 15}, {100, 50}, {80, 85}, {45, 100}, {0, 100}}},
["E"] = {{{90, 0}, {0, 0}, {0, 100}, {90, 100}}, {{0, 50}, {70, 50}}},
["F"] = {{{90, 0}, {0, 0}, {0, 100}}, {{0, 50}, {70, 50}}},
["G"] = {{{90, 20}, {70, 0}, {30, 0}, {5, 25}, {0, 50}, {5, 75}, {30, 100}, {70, 100}, {95, 80}, {95, 55}, {60, 55}}},
["H"] = {{{0, 0}, {0, 100}}, {{100, 0}, {100, 100}}, {{0, 50}, {100, 50}}},
["I"] = {{{20, 0}, {80, 0}}, {{50, 0}, {50, 100}}, {{20, 100}, {80, 100}}},
["J"] = {{{20, 0}, {90, 0}}, {{70, 0}, {70, 75}, {60, 95}, {40, 100}, {15, 90}, {5, 75}}},
["K"] = {{{5, 0}, {5, 100}}, {{95, 0}, {5, 55}, {100, 100}}},
["L"] = {{{0, 0}, {0, 100}, {95, 100}}},
["M"] = {{{0, 100}, {0, 0}, {50, 60}, {100, 0}, {100, 100}}},
["N"] = {{{0, 100}, {0, 0}, {100, 100}, {100, 0}}},
["O"] = {{{50, 0}, {20, 5}, {0, 30}, {0, 70}, {20, 95}, {50, 100}, {80, 95}, {100, 70}, {100, 30}, {80, 5}, {50, 0}}},
["P"] = {{{0, 100}, {0, 0}, {60, 0}, {90, 15}, {90, 40}, {60, 55}, {0, 55}}},
["Q"] = {{{50, 0}, {20, 5}, {0, 30}, {0, 70}, {20, 95}, {50, 100}, {80, 95}, {100, 70}, {100, 30}, {80, 5}, {50, 0}}, {{60, 70}, {100, 100}}},
["R"] = {{{0, 100}, {0, 0}, {60, 0}, {90, 15}, {90, 40}, {60, 55}, {0, 55}}, {{50, 55}, {100, 100}}},
["S"] = {{{90, 15}, {65, 0}, {30, 0}, {5, 20}, {10, 40}, {80, 60}, {95, 80}, {70, 100}, {30, 100}, {5, 85}}},
["T"] = {{{0, 0}, {100, 0}}, {{50, 0}, {50, 100}}},
["U"] = {{{0, 0}, {0, 70}, {10, 90}, {35, 100}, {65, 100}, {90, 90}, {100, 70}, {100, 0}}},
["V"] = {{{0, 0}, {50, 100}, {100, 0}}},
["W"] = {{{0, 0}, {25, 100}, {50, 45}, {75, 100}, {100, 0}}},
["X"] = {{{0, 0}, {100, 100}}, {{100, 0}, {0, 100}}},
["Y"] = {{{0, 0}, {50, 50}, {100, 0}}, {{50, 50}, {50, 100}}},
["Z"] = {{{0, 0}, {100, 0}, {0, 100}, {100, 100}}},
["a"] = {{{75, 40}, {55, 30}, {25, 30}, {5, 45}, {5, 65}, {25, 80}, {55, 80}, {75, 65}, {75, 30}}, {{75, 30}, {75, 80}}},
["b"] = {{{10, 0}, {10, 80}}, {{10, 45}, {30, 30}, {60, 30}, {80, 45}, {80, 65}, {60, 80}, {30, 80}, {10, 65}}},
["c"] = {{{80, 40}, {60, 30}, {30, 30}, {10, 45}, {10, 65}, {30, 80}, {60, 80}, {80, 70}}},
["d"] = {{{75, 40}, {55, 30}, {25, 30}, {5, 45}, {5, 65}, {25, 80}, {55, 80}, {75, 65}}, {{75, 0}, {75, 80}}},
["e"] = {{{10, 55}, {80, 55}, {75, 40}, {55, 30}, {30, 30}, {10, 45}, {10, 65}, {30, 80}, {60, 80}, {80, 70}}},
["f"] = {{{80, 10}, {65, 0}, {45, 0}, {30, 15}, {30, 80}}, {{5, 35}, {65, 35}}},
["g"] = {{{75, 40}, {55, 30}, {25, 30}, {5, 45}, {5, 65}, {25, 80}, {55, 80}, {75, 65}}, {{75, 30}, {75, 90}, {55, 100}, {25, 100}, {10, 90}}},
["h"] = {{{10, 0}, {10, 80}}, {{10, 45}, {30, 30}, {55, 30}, {75, 45}, {75, 80}}},
["i"] = {{{50, 30}, {50, 80}}, {{50, 8}, {50, 10}}},
["j"] = {{{65, 30}, {65, 85}, {50, 100}, {30, 100}, {15, 90}}, {{65, 8}, {65, 10}}},
["k"] = {{{10, 0}, {10, 80}}, {{75, 30}, {10, 60}, {80, 80}}},
["l"] = {{{50, 0}, {50, 80}}},
["m"] = {{{5, 30}, {5, 80}}, {{5, 45}, {20, 30}, {35, 30}, {50, 45}, {50, 80}}, {{50, 45}, {65, 30}, {80, 30}, {95, 45}, {95, 80}}},
["n"] = {{{10, 30}, {10, 80}}, {{10, 45}, {30, 30}, {55, 30}, {75, 45}, {75, 80}}},
["o"] = {{{45, 30}, {20, 30}, {5, 45}, {5, 65}, {20, 80}, {55, 80}, {75, 65}, {75, 45}, {55, 30}, {45, 30}}},
["p"] = {{{10, 30}, {10, 100}}, {{10, 45}, {30, 30}, {55, 30}, {75, 45}, {75, 65}, {55, 80}, {30, 80}, {10, 65}}},
["q"] = {{{75, 40}, {55, 30}, {25, 30}, {5, 45}, {5, 65}, {25, 80}, {55, 80}, {75, 65}}, {{75, 30}, {75, 100}}},
["r"] = {{{15, 30}, {15, 80}}, {{15, 45}, {35, 30}, {60, 30}, {75, 40}}},
["s"] = {{{75, 40}, {55, 30}, {25, 30}, {10, 40}, {15, 50}, {60, 60}, {75, 70}, {55, 80}, {25, 80}, {10, 70}}},
["t"] = {{{40, 5}, {40, 65}, {50, 80}, {70, 80}, {85, 70}}, {{15, 30}, {75, 30}}},
["u"] = {{{10, 30}, {10, 65}, {25, 80}, {50, 80}, {75, 65}}, {{75, 30}, {75, 80}}},
["v"] = {{{5, 30}, {45, 80}, {85, 30}}},
["w"] = {{{0, 30}, {20, 80}, {45, 45}, {70, 80}, {95, 30}}},
["x"] = {{{10, 30}, {80, 80}}, {{80, 30}, {10, 80}}},
["y"] = {{{5, 30}, {45, 80}}, {{85, 30}, {30, 100}}},
["z"] = {{{10, 30}, {80, 30}, {10, 80}, {80, 80}}},
}
-- Known shipped palettes, keyed by a public theme value (host exposes names, not palette).
local PALETTES = {
["3C7A3A"] = {page=0x0E1222,surface2=0x26365E,accent=0x55AE9F,accent2=0xF2B84B,text=0xF4F1E8,muted=0x8E9BC0},
["5A7FA8"] = {page=0x0A0D24,surface2=0x28326C,accent=0x70B7FF,accent2=0xFFD24A,text=0xF0F3FF,muted=0x96A0CD},
["8A5A34"] = {page=0x180C0A,surface2=0x583224,accent=0xFF8A3D,accent2=0x7ECC54,text=0xFAF0E1,muted=0xC4A68C},
["E88BB8"] = {page=0x1A1234,surface2=0x4E3A82,accent=0xFF8FC8,accent2=0x8FE0C0,text=0xFCF6FF,muted=0xC4B6E6},
["C03C3C"] = {page=0x101228,surface2=0x363866,accent=0xE24B4B,accent2=0xF3CF5A,text=0xF8F6F0,muted=0xA4A8CC},
}
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
