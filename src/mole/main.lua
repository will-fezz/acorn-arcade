-- Whac-a-Mole: same rules as the built-in game (tools/arcade/mole.cpp). A 30 s round, six mounds round the middle, tap the moles; no penalties.
-- Every 10 moles adds 5 s, so a quick player keeps going; pops get faster and shorter all the while. The four mole images share one canvas with
-- the mound on its bottom edge. Engine 3: gfx.size, text_color, sys.score; sys.active when the host has it.
local IDLE, PLAY = 0, 1
local EMPTY, RISE, UP, SINK, BONK = 0, 1, 2, 3, 4
local ART = {[EMPTY] = "hole", [RISE] = "peek", [UP] = "up", [SINK] = "peek", [BONK] = "bonk"}
local WHITE, BONUS = 0xFFFFFF, 0x55AE9F
local hole, hx, hy, hs, ht = {}, {}, {}, {}, {}
local state, score, last_s = IDLE, 0, -1
local end_at, next_spawn, bonus_until = 0, 0, nil

local function set_state(i, st, untl)
  hs[i], ht[i] = st, untl
  gfx.src(hole[i], ART[st])
end

local function clear_moles() for i = 1, 6 do set_state(i, EMPTY, 0) end end

local function idle_text()
  gfx.text("title", "Tap")
  bonus_until = nil
  gfx.text_color("sub", WHITE)
  gfx.text("sub", sys.best() > 0 and ("Best " .. sys.best()) or "")
  gfx.src(hole[1], "peek")   -- a mole peeks from the top mound while we wait
end

function init()
  gfx.image("garden")
  local w, h = gfx.size("hole")
  for i = 1, 6 do
    local a = ((i - 1) * 60 - 90) * math.pi / 180
    hx[i] = 233 + math.floor(120 * math.cos(a) + 0.5)
    hy[i] = 233 + math.floor(120 * math.sin(a) + 0.5)
    hole[i] = gfx.image("hole")
    gfx.pos(hole[i], hx[i] - w // 2, hy[i] + 42 - h)
    hs[i], ht[i] = EMPTY, 0
  end
  idle_text()
end

function tick(now, press, down, x, y)
  if state == IDLE then
    if press then
      score, last_s = 0, -1
      clear_moles()
      gfx.text("title", "0")
      end_at = now + 30000
      next_spawn = now + 400
      state = PLAY
    end
    return
  end
  if sys.active then sys.active() end
  if now - end_at >= 0 then
    clear_moles()
    local nb = score > sys.best()
    if nb then sys.set_best(score) end
    sys.beep(660, 330, 400)
    state = IDLE
    idle_text()
    sys.finish(score, sys.best(), nb)
    return
  end
  if bonus_until and now - bonus_until >= 0 then
    bonus_until = nil
    gfx.text_color("sub", WHITE)
    last_s = -1
  end
  local s = (end_at - now + 999) // 1000
  if not bonus_until and s ~= last_s then
    last_s = s
    gfx.text("sub", string.format("%d:%02d", s // 60, s % 60))
  end
  if now - next_spawn >= 0 then
    for _ = 1, 8 do
      local i = sys.random(6) + 1
      if hs[i] == EMPTY then set_state(i, RISE, now + 70); break end
    end
    next_spawn = now + math.max(200, 900 - score * 12)
  end
  -- A tap counts on the whole sprite while the mole is rising or up
  local hit
  if press then
    for i = 1, 6 do
      if not hit and (hs[i] == RISE or hs[i] == UP) then
        local dx, dy = x - hx[i], y - hy[i]
        if dx >= -60 and dx <= 60 and dy >= -118 and dy <= 46 then hit = i end
      end
    end
  end
  for i = 1, 6 do
    if i == hit then
      score = score + 1
      gfx.text("title", tostring(score))
      sys.score(score)
      set_state(i, BONK, now + 260)
      if score % 10 == 0 then
        end_at = end_at + 5000
        bonus_until = now + 800
        gfx.text_color("sub", BONUS)
        gfx.text("sub", "+5s")
        sys.beep(880, 1760, 140)
      else
        sys.beep(900, 1500, 80)
      end
    elseif hs[i] ~= EMPTY and now - ht[i] >= 0 then
      if hs[i] == RISE then set_state(i, UP, now + math.max(380, 1400 - score * 16))
      elseif hs[i] == UP then set_state(i, SINK, now + 70)
      else set_state(i, EMPTY, 0) end
    end
  end
end
