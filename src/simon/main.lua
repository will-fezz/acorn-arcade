-- Simon as a flower: same game as the built-in one (tools/outdoor/simon.cpp). Four petals round a hub; watch the petals light up in turn, then tap them
-- in the same order. One more each round, a little quicker each time. Wait too long or tap the wrong petal and the round is over.
-- Petal 1 top-left, 2 top-right, 3 bottom-left, 4 bottom-right. Each sprite has one corner on the screen centre, so the theme's sizes place them.
-- Engine 4: gfx.arc draws the hub, sys.active keeps the screen on while Simon plays, sys.theme("simon_hub") gives the hub radius a theme's petals were cut for.
local IDLE, GAP, SHOW, INPUT, FAIL = 0, 1, 2, 3, 4
local FREQ = {415, 310, 252, 209}
local NAMES = {"tl", "tr", "bl", "br"}
local CHASE = {1, 2, 4, 3}   -- clockwise while waiting
local DIM, FAINT = 110, 70   -- a dim petal, and the whole flower when a round is lost (the old game recoloured towards navy, then red)
local HUB, RIM, INK, GREY = 0xFFF3D6, 0xE8B64A, 0x1E2440, 0x6A6E82
local petal, seq = {}, {}
local state, step, level, start_best, chase = IDLE, 0, 0, 0, 1
local lit_on, untl, last_input, chase_t = false, 0, 0, 0
local hub = 59

-- A filled disc from round-capped arcs: one stroke is at most 59 px wide, so a big disc takes two.
local function disc(r, col)
  local outer = r
  while true do
    local w = math.min(58, outer)
    gfx.arc(233, 233, math.max(1, outer - w // 2), 0, 360, w, col)
    if w >= outer then return end
    outer = outer - w + 2
  end
end

local function paint(on)   -- on = nil: all dim; on = i: petal i in full colour
  for i = 1, 4 do gfx.opa(petal[i], i == on and 255 or DIM) end
end

local function light(i)
  paint(i)
  sys.beep(FREQ[i], FREQ[i], 200)
end

local function idle_text()
  gfx.text("title", "Tap")
  gfx.text("sub", sys.best() > 0 and ("Best " .. sys.best()) or "")
end

local function show_level()
  gfx.text("title", tostring(level))
  gfx.text("sub", "")
end

local function add_step()
  if level < 100 then
    level = level + 1
    seq[level] = sys.random(4) + 1
  end
end

function init()
  gfx.image("meadow")
  for i = 1, 4 do
    local w, h = gfx.size(NAMES[i])
    petal[i] = gfx.image(NAMES[i])
    gfx.pos(petal[i], (i == 1 or i == 3) and 233 - w or 233, i <= 2 and 233 - h or 233)
  end
  hub = tonumber(sys.theme("simon_hub") or "") or 59
  disc(hub, RIM)
  disc(hub - 6, HUB)
  gfx.text_color("title", INK)
  gfx.text_color("sub", GREY)
  paint(nil)
  idle_text()
  state = IDLE
end

function tick(now, press, down, x, y)
  local tap
  if press then
    local dx, dy = x - 233, y - 233
    if dx * dx + dy * dy > (hub + 4) * (hub + 4) then tap = (dy >= 0 and 3 or 1) + (dx >= 0 and 1 or 0) end
  end
  local on_ms = math.max(240, 520 - level * 25)
  local off_ms = math.max(90, on_ms // 3)
  if state ~= IDLE and state ~= INPUT then sys.active() end
  if state == IDLE then
    if now - chase_t >= 0 then
      paint(CHASE[chase])
      chase = chase % 4 + 1
      chase_t = now + 300
    end
    if press then
      level, start_best = 0, sys.best()
      paint(nil)
      add_step()
      show_level()
      state, step, untl = GAP, 0, now + 700
    end
  elseif state == GAP then
    if now - untl >= 0 then
      if step < level then
        light(seq[step + 1])
        state, untl = SHOW, now + on_ms
      else
        state, step, lit_on, last_input = INPUT, 0, false, now
      end
    end
  elseif state == SHOW then
    if now - untl >= 0 then
      paint(nil)
      step = step + 1
      state, untl = GAP, now + off_ms
    end
  elseif state == INPUT then
    if lit_on and now - untl >= 0 then
      paint(nil)
      lit_on = false
      if step >= level then   -- round done
        if level > sys.best() then sys.set_best(level) end
        sys.score(level)
        add_step()
        show_level()
        state, step, untl = GAP, 0, now + 800
        return
      end
    end
    if tap and step < level then
      if tap == seq[step + 1] then
        light(tap)
        lit_on, untl = true, now + 220
        step = step + 1
        last_input = now
      else
        last_input = now - 100000
      end
    end
    if not lit_on and step < level and now - last_input > 5000 then
      for i = 1, 4 do gfx.opa(petal[i], FAINT) end
      sys.beep(110, 110, 500)
      gfx.text("title", tostring(level - 1))
      gfx.text("sub", "Oops")
      state, untl = FAIL, now + 1800
    end
  elseif state == FAIL then
    if now - untl >= 0 then
      paint(nil)
      idle_text()
      state, chase_t = IDLE, now + 300
      sys.finish(level - 1, sys.best(), level - 1 > start_best)
    end
  end
end
