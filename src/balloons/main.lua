-- Balloons as a pack: same rules as the built-in game (tools/arcade/balloons.cpp, firmware 99ec346a), for small children. Balloons drift up, tap to pop, no fail state,
-- a star burst every 10 pops, gently faster. A fixed pool of 8 balloons, each with its own burst, plus 6 stars: made once, then only moved and hidden.
-- Needs engine 3 for gfx.size, gfx.scale, gfx.opa, gfx.text_color and sys.score. The old speeds were per frame at 30 fps, so here they scale with the time that really passed.
local COLOURS = {"red", "orange", "yellow", "green", "blue", "purple", "pink"}
local SCORE_COLOURS = {0xFF5252, 0xFFA12E, 0xFFD23F, 0x5BD86E, 0x4DB8FF, 0xB58CFF, 0xFF7AB8}
local WHITE = 0xFFFFFF
local FREE, LIVE, POP = 0, 1, 2
local FRAME_MS = 33

local bal, stars = {}, {}
local score, party, frame, last = 0, 0, 0, nil
local pop_w, pop_h, star_w, star_h

local function hidden_image(name)
  local o = gfx.image(name)
  gfx.hide(o, true)
  return o
end

function init()
  gfx.image("sky")
  pop_w, pop_h = gfx.size("pop")
  star_w, star_h = gfx.size("star_mini")
  for i = 1, 8 do
    bal[i] = {o = hidden_image("red_l"), p = hidden_image("pop"), x = 0, y = 0, ph = 0, w = 0, h = 0, st = FREE, pf = 0}
  end
  for k = 1, 6 do
    stars[k] = {o = hidden_image("star_mini"), x = 0, y = 0, vx = 0, vy = 0}
  end
  gfx.text("score", "0")
end

local function centre(u)
  return u.x + math.sin(u.ph) * 10 + u.w / 2, u.y + u.h * 0.36   -- the balloon's body sits in the top of the sprite, the string below it
end

local function celebrate()
  party = 18
  gfx.text_color("score", SCORE_COLOURS[(score // 10) % 7 + 1])
  for k = 1, 6 do
    local s, a = stars[k], k * 1.0472 + 0.5
    s.x, s.y = 233 + math.cos(a) * 60, 233 + math.sin(a) * 60
    s.vx, s.vy = math.cos(a) * 8, math.sin(a) * 8
    gfx.hide(s.o, false)
  end
end

-- The front-most live balloon under the finger, with a generous radius for small fingers.
local function tap(x, y)
  for i = 8, 1, -1 do
    local u = bal[i]
    if u.st == LIVE then
      local bx, by = centre(u)
      local dx, dy, rr = x - bx, y - by, u.w / 2 + 16
      if dx * dx + dy * dy <= rr * rr then
        u.st, u.pf = POP, 0
        gfx.hide(u.o, true)
        gfx.pos(u.p, math.floor(bx - pop_w / 2), math.floor(by - pop_h / 2))
        gfx.scale(u.p, 128)
        gfx.opa(u.p, 255)
        gfx.hide(u.p, false)
        score = score + 1
        gfx.text("score", tostring(score))
        sys.score(score)
        sys.beep(880, 180, 60)
        if score % 10 == 0 then celebrate() end
        return
      end
    end
  end
end

local function spawn(u)
  local name = COLOURS[sys.random(7) + 1] .. (sys.random(2) == 0 and "_l" or "_s")
  u.w, u.h = gfx.size(name)
  u.x = 120 + sys.random(227) - u.w / 2   -- centre between 120 and 346: clear of the round edge
  u.y = 470
  u.ph = sys.random(628) / 100
  u.st = LIVE
  gfx.src(u.o, name)
  gfx.pos(u.o, math.floor(u.x + math.sin(u.ph) * 10), math.floor(u.y))
  gfx.hide(u.o, false)
end

-- press: tap this tick, at x, y.
function tick(now, press, down, x, y)
  local dt = last and math.min((now - last) / FRAME_MS, 3) or 1
  last = now
  frame = frame + 1
  if press then tap(x, y) end
  local speed = 1.6 * math.min(2.5, 1 + 0.1 * (score // 10)) * dt
  local want = math.min(8, 4 + score // 15)
  local live = 0
  for i = 1, 8 do if bal[i].st ~= FREE then live = live + 1 end end
  for i = 1, 8 do
    local u = bal[i]
    if u.st == LIVE and u.y + u.h < 0 then   -- off the top
      gfx.hide(u.o, true)
      u.st = FREE
      live = live - 1
    end
    if u.st == FREE then
      if live < want and (frame + (i - 1) * 7) % 11 == 0 then
        spawn(u)
        live = live + 1
      end
    elseif u.st == LIVE then
      u.y = u.y - speed * (u.h <= 100 and 1.25 or 1)   -- little ones a bit quicker
      u.ph = u.ph + 0.06 * dt
      gfx.pos(u.o, math.floor(u.x + math.sin(u.ph) * 10), math.floor(u.y))
    else
      -- The burst grows from half size to 1.6 times over 8 ticks while fading out
      u.pf = u.pf + 1
      gfx.scale(u.p, 128 + 36 * u.pf)
      gfx.opa(u.p, math.max(0, 255 - 30 * u.pf))
      if u.pf >= 8 then
        gfx.hide(u.p, true)
        u.st = FREE
      end
    end
  end
  if party > 0 then
    party = party - 1
    for k = 1, 6 do
      local s = stars[k]
      s.x, s.y, s.vy = s.x + s.vx, s.y + s.vy, s.vy + 0.3
      if party == 0 then gfx.hide(s.o, true)
      else gfx.pos(s.o, math.floor(s.x - star_w / 2), math.floor(s.y - star_h / 2)) end
    end
    if party == 0 then gfx.text_color("score", WHITE) end
  end
end
