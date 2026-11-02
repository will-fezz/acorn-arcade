-- Round Pong as a pond: same physics and scoring as the built-in game (tools/arcade/pong.cpp). A frog bounces about the pond; five lily pads follow
-- the finger round the rim and keep it in. Miss and the frog hops out: it sits dizzy at the rim for a moment, then the results page.
-- The old speeds were per frame at 30 fps, so here they scale with the time that really passed. Engine 3: gfx.size, scale, opa, back, text_color.
local IDLE, PLAY, LOCK = 0, 1, 2
local R_PAD, R_HIT, HALF, GAP = 206, 188, 0.42, 0.17
local FRAME_MS = 33
local WHITE, FAINT = 0xFFFFFF, 0x8A93A6   -- the score sits faint on the water while playing, as before (40 % white)
local pad, frog, splash = {}, nil, nil
local state, score, splash_f = IDLE, 0, 0
local pa, bx, by, vx, vy = -math.pi / 2, 233, 233, 0, 0
local lock_until, lock_nb, last = 0, false, nil
local pad_w, pad_h, frog_w, frog_h, sp_w, sp_h

local function draw_paddle()
  for i = 1, 5 do
    local a = pa + (i - 3) * GAP
    gfx.pos(pad[i], 233 + math.floor(R_PAD * math.cos(a)) - pad_w // 2, 233 + math.floor(R_PAD * math.sin(a)) - pad_h // 2)
  end
end

local function draw_frog() gfx.pos(frog, math.floor(bx) - frog_w // 2, math.floor(by) - frog_h // 2) end

local function idle_text()
  gfx.text_color("title", WHITE)
  gfx.text("title", "Tap")
  gfx.text("sub", sys.best() > 0 and ("Best " .. sys.best()) or "")
  gfx.hide(frog, true)
  gfx.hide(splash, true)
  splash_f = 0
end

function init()
  gfx.image("pond")
  pad_w, pad_h = gfx.size("pad")
  frog_w, frog_h = gfx.size("frog")
  sp_w, sp_h = gfx.size("splash")
  splash = gfx.image("splash")
  gfx.hide(splash, true)
  for i = 1, 5 do pad[i] = gfx.image("pad") end
  frog = gfx.image("frog")
  idle_text()
  draw_paddle()
end

function tick(now, press, down, x, y)
  local dt = last and math.min((now - last) / FRAME_MS, 3) or 1
  last = now
  if down then
    local dx, dy = x - 233, y - 233
    if dx * dx + dy * dy > 40 * 40 then
      pa = math.atan(dy, dx)
      draw_paddle()
    end
  end
  -- A splash ring on a pad hit: grows from half size to double while fading, 6 frames
  if splash_f > 0 then
    splash_f = splash_f + 1
    gfx.scale(splash, 128 + 32 * splash_f)
    gfx.opa(splash, math.max(0, 220 - 36 * splash_f))
    if splash_f >= 6 then splash_f = 0; gfx.hide(splash, true) end
  end
  if state == IDLE then
    if press then
      score, bx, by = 0, 233, 233
      local a = sys.random(628) / 100
      vx, vy = 4.5 * math.cos(a), 4.5 * math.sin(a)
      gfx.text_color("title", FAINT)
      gfx.text("title", "0")
      gfx.text("sub", "")
      gfx.src(frog, "frog")
      gfx.hide(frog, false)
      draw_frog()
      state = PLAY
    end
  elseif state == PLAY then
    if sys.active then sys.active() end
    bx, by = bx + vx * dt, by + vy * dt
    local rx, ry = bx - 233, by - 233
    local r = math.sqrt(rx * rx + ry * ry)
    if r >= R_HIT and r < R_HIT + 16 * dt and rx * vx + ry * vy > 0 then
      local ba = math.atan(ry, rx)
      local d = ba - pa
      while d > math.pi do d = d - 2 * math.pi end
      while d < -math.pi do d = d + 2 * math.pi end
      if math.abs(d) <= HALF then
        score = score + 1
        local sp = math.min(11, 4.5 + 0.3 * score)
        local out = ba + math.pi + d * 1.5 + (sys.random(41) - 20) / 100
        vx, vy = sp * math.cos(out), sp * math.sin(out)
        gfx.text("title", tostring(score))
        sys.score(score)
        sys.beep(620, 880, 50)
        gfx.pos(splash, math.floor(bx) - sp_w // 2, math.floor(by) - sp_h // 2)   -- where the frog met the pads
        gfx.scale(splash, 128)
        gfx.opa(splash, 255)
        gfx.hide(splash, false)
        gfx.back(splash, 1)   -- just above the pond
        splash_f = 1
      end
    end
    if r > 250 then
      -- hopped out: park the dizzy frog just inside the rim, then the results
      lock_nb = score > sys.best()
      if lock_nb then sys.set_best(score) end
      local k = 226 / r
      bx, by = 233 + rx * k, 233 + ry * k
      gfx.src(frog, "dizzy")
      draw_frog()
      sys.beep(300, 90, 500)
      lock_until = now + 700
      state = LOCK
      return
    end
    draw_frog()
  elseif now - lock_until >= 0 then
    state = IDLE
    idle_text()
    sys.finish(score, sys.best(), lock_nb)
  end
end
