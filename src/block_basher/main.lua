-- Block Basher: round breakout, engine 6 game-owned bundle.
-- Bricks are three concentric rings in the middle of the field (6, 8 and 10 arc bricks); the paddle is a bead arc
-- that runs the whole 360 degrees just inside the field's stone ring, steered by a finger anywhere on the field
-- (the paddle goes to the finger's angle) or by turning the console like a wheel (sys.tilt x,y -> the paddle sits
-- where gravity points). The ball bounces off the bricks, the centrepiece and the paddle; past the paddle it is lost.
-- Fixed 240 Hz integration, polar brick/paddle contacts, one contact per substep.
local C,BR = 233,13            -- centre, ball radius (the ball art is 26 px)
local PR,PHALF = 196,32        -- paddle bead-centre radius and half-angle in degrees
local PIN = PR-10              -- paddle inner face: the ball reflects here
local LOST = 215               -- beyond this the ball is gone
local CORE = 40                -- centrepiece radius (80 px art)
local BEADS = 9                -- paddle is 9 discs on a 7 degree pitch (arcs cannot turn on the host)
local RINGS = {{r=66,n=6},{r=96,n=8},{r=126,n=10}}
local HALFBAND = 13            -- brick band is 26 px
local GAP = 6                  -- degrees between bricks
local S = {phase='ready', score=0, lives=3, remaining=24, pa=math.pi/2,
  x=233,y=406,vx=0,vy=0,bricks={}, last=nil,acc=0, mode='touch',armed=false}
local ball,centre,mode_button,beads
local STEP=1/240
local function clamp(v,a,b) return math.max(a,math.min(b,v)) end
local function int(v) return math.floor(v+.5) end
local function wrap(a) -- to (-pi, pi]
  while a>math.pi do a=a-2*math.pi end
  while a<=-math.pi do a=a+2*math.pi end
  return a
end
local function hud() gfx.text('score',tostring(S.score)..' / '..S.lives) end
local function prompts()
  gfx.hide(mode_button,false)
  gfx.text('title',S.phase=='won' and 'All clear!' or S.phase=='over' and 'Nice try!' or 'Block Basher')
  gfx.text('sub',S.phase=='ready' and (S.mode=='tilt' and 'Tap to launch, turn to steer' or 'Tap to launch, drag to steer') or 'Tap to play again')
end
local function park()
  local rr=PIN-BR-2
  S.x,S.y=C+rr*math.cos(S.pa),C+rr*math.sin(S.pa)
  S.vx,S.vy=0,0;S.acc=0
end
local function fresh()
  S.phase,S.score,S.lives,S.remaining='ready',0,3,#S.bricks
  for _,b in ipairs(S.bricks) do b.live=true;gfx.hide(b.obj,false) end
  park();S.armed=false;hud();prompts();sys.score(0)
end
local function result(phase)
  S.phase=phase;S.acc=0;S.armed=false
  if S.score>sys.best() then sys.set_best(S.score) end
  prompts()
end
local function lose()
  S.lives=S.lives-1;hud();sys.beep(260,120,100)
  if S.lives==0 then result('over') else S.phase='ready';park();S.armed=false;prompts() end
end
local function launch()
  S.phase='play';S.acc=0
  -- towards the middle, nudged 20 degrees so the first bounce is never dead straight
  local a=S.pa+math.pi+math.rad(20)
  S.vx,S.vy=170*math.cos(a),170*math.sin(a)
  gfx.hide(mode_button,true)
  gfx.text('title','');gfx.text('sub','')
end
local function reflect_radial(nx,ny,outward)
  -- flip the radial component so the ball moves in the direction `outward` wants (+1 away from centre, -1 towards)
  local dot=S.vx*nx+S.vy*ny
  if (outward>0 and dot<0) or (outward<0 and dot>0) then S.vx,S.vy=S.vx-2*dot*nx,S.vy-2*dot*ny end
end
local function step(dt)
  S.x,S.y=S.x+S.vx*dt,S.y+S.vy*dt
  local dx,dy=S.x-C,S.y-C
  local rr=math.sqrt(dx*dx+dy*dy)
  if rr<.001 then rr=.001;dx=.001 end
  local nx,ny=dx/rr,dy/rr
  local theta=math.atan(dy,dx)
  -- Paddle: an arc of PHALF degrees either side of pa at radius PIN, met from inside while moving outward.
  if rr+BR>=PIN and rr<PIN+14 and S.vx*nx+S.vy*ny>0 then
    local d=wrap(theta-S.pa)
    local reach=math.rad(PHALF)+BR/PR
    if math.abs(d)<=reach then
      local offset=clamp(d/math.rad(PHALF),-1,1)
      local speed=math.min(260,170+S.score*.5)
      local a=theta+math.pi+offset*math.rad(30) -- back towards the middle, aimed by where it hit
      S.vx,S.vy=speed*math.cos(a),speed*math.sin(a)
      rr=PIN-BR-.05;S.x,S.y=C+nx*rr,C+ny*rr
      sys.beep(500,650,25)
      return
    end
  end
  if rr>LOST then lose();return end
  -- Centrepiece
  if rr-BR<CORE then
    reflect_radial(nx,ny,1)
    rr=CORE+BR+.05;S.x,S.y=C+nx*rr,C+ny*rr
    sys.beep(400,400,20)
    return
  end
  -- Bricks: polar bands with angular segments; the radial component reflects, one brick per substep.
  for _,b in ipairs(S.bricks) do
    if b.live and rr+BR>b.r-HALFBAND and rr-BR<b.r+HALFBAND then
      local d=wrap(theta-b.mid)
      if math.abs(d)<=b.half+BR/rr then
        local inside=rr<b.r
        reflect_radial(nx,ny,inside and -1 or 1)
        rr=inside and (b.r-HALFBAND-BR-.05) or (b.r+HALFBAND+BR+.05)
        S.x,S.y=C+nx*rr,C+ny*rr
        b.live=false;gfx.hide(b.obj,true)
        S.score,S.remaining=S.score+10,S.remaining-1;sys.score(S.score);hud()
        sys.beep(700,950,30)
        if S.remaining==0 then result('won') end
        return
      end
    end
  end
end
local function place_paddle()
  for i,o in ipairs(beads) do
    local a=S.pa+math.rad((i-(BEADS+1)/2)*7)
    gfx.pos(o,int(C+PR*math.cos(a)-10),int(C+PR*math.sin(a)-10))
  end
end
function init()
  local wall=sys.theme('tilt_wall') or '3C7A3A'
  local accent=tonumber(wall,16)
  -- Ring colours: the theme's wall colour, accent2 gold and ok green (keyed by the public tilt_wall value; the shell palette is not exposed).
  local ROWS=({["3C7A3A"]={0xF2B84B,0x3F8A73},["5A7FA8"]={0xFFD24A,0x3FBF8F},["8A5A34"]={0x7ECC54,0x5FAE3F},["E88BB8"]={0x8FE0C0,0x5CC9A0},["C03C3C"]={0xF3CF5A,0x4FB36B}})[wall] or {0xF2B84B,0x3F8A73}
  gfx.image('background')
  centre=gfx.image('centre');gfx.pos(centre,C-40,C-40)
  S.bricks={}
  for ri,ring in ipairs(RINGS) do
    local span=360/ring.n
    local col=ri==1 and accent or ROWS[ri-1]
    for k=0,ring.n-1 do
      local a0=k*span+GAP/2-90
      local b={r=ring.r,mid=math.rad(a0+(span-GAP)/2),half=math.rad((span-GAP)/2),live=true}
      b.obj=gfx.arc(C,C,ring.r,int(a0),int(a0+span-GAP),HALFBAND*2,col)
      S.bricks[#S.bricks+1]=b
    end
  end
  beads={}
  for i=1,BEADS do beads[i]=gfx.box(0,0,20,20,10,accent,255) end
  ball=gfx.image('ball')
  mode_button=gfx.image('touch')
  gfx.pos(mode_button,97,325) -- 44 px disc at angle 135 degrees, radius 162: between the outer ring and the paddle
  S.last=nil;S.mode='touch';S.pa=math.pi/2;fresh()
  place_paddle();gfx.pos(ball,int(S.x-BR),int(S.y-BR))
end
function tick(now,press,down,x,y)
  local elapsed=S.last and clamp((now-S.last)/1000,0,.1) or 0
  S.last=now
  if not down then S.armed=true end
  local on_button=((x-119)^2+(y-347)^2)<=28*28
  -- Mode toggle, only while waiting: a play drag never toggles mode.
  if S.phase~='play' and press and S.armed and on_button then
    if S.mode=='touch' then
      local tx=sys.tilt()
      if tx then S.mode='tilt';gfx.src(mode_button,'tilt');prompts()
      else gfx.text('sub','No tilt: drag to play') end
    else S.mode='touch';gfx.src(mode_button,'touch');prompts() end
    S.armed=false
  elseif S.phase~='play' and press and S.armed then
    if S.phase~='ready' then fresh() else launch() end
    S.armed=false
  end
  if S.mode=='touch' then
    if down and not (S.phase~='play' and on_button) then
      local dx,dy=x-C,y-C
      if dx*dx+dy*dy>CORE*CORE then S.pa=math.atan(dy,dx) end
    end
  else
    local tx,ty=sys.tilt()
    if tx then
      ty=ty or 0
      if tx*tx+ty*ty>=150*150 then -- dead band: flat on a table keeps the last angle
        local target=math.atan(ty,tx)
        S.pa=S.pa+wrap(target-S.pa)*math.min(1,elapsed*12)
      end
    else S.mode='touch';gfx.src(mode_button,'touch') end
  end
  if S.phase=='play' then
    sys.active();S.acc=S.acc+elapsed
    local count=0
    while S.acc>=STEP and S.phase=='play' and count<24 do
      S.acc=S.acc-STEP;step(STEP);count=count+1
    end
  elseif S.phase=='ready' then park() end
  place_paddle()
  gfx.pos(ball,int(S.x-BR),int(S.y-BR))
end
-- Returned state is ignored by firmware; native tests inspect/inject edge cases.
return S
