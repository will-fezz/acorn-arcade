-- Lights Out as fireflies: same puzzle as the built-in game (tools/arcade/lights.cpp). 5x5 fireflies on a night meadow; a tap flips a firefly and
-- its four neighbours between awake (lit, with a glow behind it) and asleep. Levels are made by tapping the solved board, so every one can be solved,
-- and solved means every firefly is asleep. Endless: best = highest level cleared. Engine 3: gfx.size, sys.score; sys.active when the host has it.
local TS, PITCH, OX, OY = 56, 62, 81, 93
local bug, glow, lit, shown = {}, {}, {}, {}
local level, moves, win_until = 1, 0, nil
local lit_w, lit_h, off_w, off_h

local function centre(i)
  return OX + (i % 5) * PITCH + TS // 2, OY + (i // 5) * PITCH + TS // 2
end

-- Only the cells that changed are touched: a tap flips at most five.
local function paint()
  for i = 0, 24 do
    if shown[i] ~= lit[i] then
      shown[i] = lit[i]
      local cx, cy = centre(i)
      if lit[i] then
        gfx.src(bug[i], "lit")
        gfx.pos(bug[i], cx - lit_w // 2, cy - lit_h // 2)
      else
        gfx.src(bug[i], "off")
        gfx.pos(bug[i], cx - off_w // 2, cy - off_h // 2)
      end
      gfx.hide(glow[i], not lit[i])
    end
  end
  gfx.text("score", "Level " .. level)
end

local function flip(i)
  lit[i] = not lit[i]
  if i % 5 > 0 then lit[i - 1] = not lit[i - 1] end
  if i % 5 < 4 then lit[i + 1] = not lit[i + 1] end
  if i >= 5 then lit[i - 5] = not lit[i - 5] end
  if i < 20 then lit[i + 5] = not lit[i + 5] end
end

local function solved()
  for i = 0, 24 do if lit[i] then return false end end
  return true
end

local function generate()
  repeat
    for i = 0, 24 do lit[i] = false end
    for _ = 1, math.min(2 + level, 14) do flip(sys.random(25)) end
  until not solved()
  moves, win_until = 0, nil
  paint()
end

function init()
  gfx.image("night")
  lit_w, lit_h = gfx.size("lit")
  off_w, off_h = gfx.size("off")
  local gw, gh = gfx.size("glow")
  for i = 0, 24 do   -- glows first, so every firefly sits above every glow
    local cx, cy = centre(i)
    glow[i] = gfx.image("glow")
    gfx.pos(glow[i], cx - gw // 2, cy + 4 - gh // 2)
    gfx.hide(glow[i], true)
  end
  for i = 0, 24 do
    local cx, cy = centre(i)
    bug[i] = gfx.image("off")
    gfx.pos(bug[i], cx - off_w // 2, cy - off_h // 2)
    shown[i], lit[i] = false, false
  end
  level = 1
  generate()
end

function tick(now, press, down, x, y)
  if win_until then
    if now - win_until >= 0 then
      level = level + 1
      generate()
    end
    return
  end
  if not press then return end
  local cx, cy = x - OX, y - OY
  if cx >= 0 and cy >= 0 and cx < 5 * PITCH and cy < 5 * PITCH and cx % PITCH < TS + 3 and cy % PITCH < TS + 3 then
    flip(cy // PITCH * 5 + cx // PITCH)
    moves = moves + 1
    paint()
    if solved() then
      if level > sys.best() then sys.set_best(level) end
      sys.score(level)
      gfx.text("score", "Solved!")
      sys.beep(660, 1320, 350)
      win_until = now + 1200
    else
      sys.beep(520, 620, 50)
    end
  end
end
