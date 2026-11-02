-- Bop It as Bossy Robin: same rules as the built-in game (tools/outdoor/bopit.cpp). The robin calls a move in a speech bubble: tap it, swipe it, or
-- shake it (only when there is a motion chip). Do it before the worm backs into its hole; each move is quicker than the last. Wrong move or too slow: over.
-- Differences, because a pack cannot do them yet (NEEDED-API.md): the bubble shows the move's picture without the word, and the worm shrinks into its
-- hole instead of sliding behind a clip. Engine 4: gfx.line and gfx.arc draw the bubble and the hole, sys.tilt reads the shake, sys.active keeps the screen on.
local IDLE, GAP, ACT, LOCK = 0, 1, 2, 3
local ICON = {"tap", "swipe", "shake"}
local TONE = {520, 700, 900}
local WHITE, RIM, OPENING = 0xFFFFFF, 0x5C3E26, 0x160D09
local HOLE_X, WORM_Y, BUB_Y = 120, 402, 160
local robin, icon, worm, bubble, hole = nil, nil, nil, {}, {}
local state, score, act, until_t, started, limit = IDLE, 0, 1, 0, 0, 0
local armed, swiped, new_best, was_down = false, false, false, false
local worm_w, worm_h, rob_w, rob_h, ic_w, ic_h, shown_w = 240, 68, 150, 150, 80, 80, -1
local pax, pay, paz, has_imu

local function show_all(list, on) for _, o in ipairs(list) do gfx.hide(o, not on) end end

local function say(name)   -- the bubble, with a move's picture or none
  show_all(bubble, true)
  if name then
    gfx.src(icon, name)
    gfx.hide(icon, false)
  else
    gfx.hide(icon, true)
  end
end

local function hush() show_all(bubble, false); gfx.hide(icon, true) end

local function worm_show(on)
  show_all(hole, on)
  gfx.hide(worm, not on)
  shown_w = -1
end

-- w = the worm's visible length (the time left). It shrinks about its middle, so it is moved to keep its tail in the hole.
local function worm_set(w)
  w = math.max(6, math.min(worm_w, w))
  if w == shown_w then return end
  shown_w = w
  gfx.scale(worm, math.max(16, 256 * w // worm_w))
  gfx.pos(worm, HOLE_X - (worm_w - w) // 2, WORM_Y - worm_h // 2)
end

local function pose(name)
  gfx.src(robin, name)
  local w, h = gfx.size(name)
  gfx.pos(robin, 233 - w // 2, 318 - h // 2)
end

local function idle_text()
  gfx.text("score", sys.best() > 0 and ("Best " .. sys.best()) or "")
  pose("idle")
  say("tap")
  worm_show(false)
end

local function next_gap(now, ms)
  armed, swiped = false, false
  until_t, state = now + ms, GAP
end

local function fail(now)
  new_best = score > sys.best()
  if new_best then sys.set_best(score) end
  pose("sad")
  hush()
  worm_show(false)
  sys.beep(300, 90, 500)
  until_t, state = now + 700, LOCK
end

local function good(now)
  score = score + 1
  gfx.text("score", tostring(score))
  sys.score(score)
  pose("cheer")
  hush()
  worm_show(false)
  sys.beep(TONE[act], TONE[act] * 3 // 2, 80)
  next_gap(now, math.max(180, 400 - score * 8))
end

-- A filled disc from one round-capped arc (r up to 58).
local function disc(cx, cy, r, col) return gfx.arc(cx, cy, (r + 1) // 2, 0, 360, r + r % 2, col) end

function init()
  gfx.image("bopit")
  worm_w, worm_h = gfx.size("worm")
  -- The speech bubble: three thick round-capped strokes make a rounded box, and a disc is its tail towards the robin
  for k = -1, 1 do bubble[#bubble + 1] = gfx.line(233 - 45, BUB_Y + 37 * k, 233 + 45, BUB_Y + 37 * k, 50, WHITE) end
  bubble[#bubble + 1] = disc(233, BUB_Y + 62, 18, WHITE)
  icon = gfx.image("tap")
  ic_w, ic_h = gfx.size("tap")
  gfx.pos(icon, 233 - ic_w // 2, BUB_Y - ic_h // 2)
  robin = gfx.image("idle")
  -- The worm's hole: the rim under the worm, the dark opening over its tail
  hole[1] = disc(126, 406, 16, RIM)
  worm = gfx.image("worm")
  hole[2] = disc(126, 406, 11, OPENING)
  idle_text()
end

local function shaken()
  if has_imu == false then return false end
  local ax, ay, az = sys.tilt()
  if not ax then has_imu = false; return false end
  has_imu = true
  local d = pax and (math.abs(ax - pax) + math.abs(ay - pay) + math.abs(az - paz)) or 0
  pax, pay, paz = ax, ay, az
  return d > 900   -- milli-g, as the old game's 0.9 g
end

function tick(now, press, down, x, y, sx, sy)
  local rel = was_down and not down or (press and not down)
  was_down = down
  if state == IDLE then
    if press then
      score = 0
      gfx.text("score", "0")
      hush()
      next_gap(now, 600)
    end
    return
  end
  if state == LOCK then
    if now - until_t >= 0 then
      state = IDLE
      idle_text()
      sys.finish(score, sys.best(), new_best)
    end
    return
  end
  sys.active()
  local shook = state == ACT and act == 3 and shaken()
  if state == GAP then
    if now - until_t >= 0 then
      if has_imu == nil then shaken() end
      act = sys.random(has_imu and 3 or 2) + 1
      pose("call")
      say(ICON[act])
      limit = math.max(900, 2400 - score * 60)
      started = now
      worm_show(true)
      worm_set(worm_w)
      pax = nil
      sys.beep(TONE[act], TONE[act], 90)
      state = ACT
    end
    return
  end
  -- ACT
  if press then armed, swiped = true, false end
  local el = now - started
  if el >= limit then fail(now); return end
  worm_set(worm_w - worm_w * el // limit)
  if shook then good(now); return end
  if armed and down and not swiped then
    local dx, dy = x - sx, y - sy
    if dx * dx + dy * dy >= 60 * 60 then
      swiped = true
      if act == 2 then good(now) else fail(now) end
      return
    end
  end
  if armed and rel then
    armed = false
    if swiped then return end
    if act == 1 then good(now) else fail(now) end
  end
end
