-- Snake as a pack: same rules as the built-in arc_snake_tick (firmware 2026-11-01).
-- Host API: gfx.image/src/pos/del/front/back/hide/text, sys.beep/random/best/set_best/finish.
local CAP, CELL, RAD = 80, 24, 8
local BODY, HEAD, FOOD = 22, 30, 28
local DIRN = {"right", "up", "left", "down"}
local IDLE, PLAY, OVER = 0, 1, 2

local state, score = IDLE, 0
local ob, cx, cy = {}, {}, {}
local head, len = 0, 0
local dir_x, dir_y, last_x, last_y, fx, fy = 1, 0, 1, 0, 0, 0
local next_step, over_until, new_best = 0, 0, false
local food_ob

local function dir_idx(dx, dy)
  if dx > 0 then return 1 elseif dx < 0 then return 3 elseif dy < 0 then return 2 else return 4 end
end
local function place(o, gx, gy, size)
  gfx.pos(o, 233 + gx * CELL - size // 2, 233 + gy * CELL - size // 2)
end
local function seg(k) return (head - k + CAP) % CAP end

local function dress()
  local name = state == OVER and "dizzy_" or "head_"
  gfx.src(ob[head], name .. DIRN[dir_idx(last_x, last_y)])
  place(ob[head], cx[head], cy[head], HEAD)
  gfx.front(ob[head])
  if len > 1 then
    local t, n = seg(len - 1), seg(len - 2)
    gfx.src(ob[t], "tail_" .. DIRN[dir_idx(cx[t] - cx[n], cy[t] - cy[n])])
    place(ob[t], cx[t], cy[t], HEAD)
    gfx.back(ob[t], 1)
  end
end

local function on_snake(gx, gy, skip_tail)
  for k = 0, len - (skip_tail and 2 or 1) do
    local s = seg(k)
    if cx[s] == gx and cy[s] == gy then return true end
  end
  return false
end

local FOODS = {"carrot", "radish", "beet"}
local function new_food()
  for _ = 1, 40 do
    local gx, gy = sys.random(15) - 7, sys.random(15) - 7
    if gx * gx + gy * gy <= (RAD - 1) * (RAD - 1) and not on_snake(gx, gy, false) then
      fx, fy = gx, gy
      break
    end
  end
  gfx.src(food_ob, FOODS[sys.random(3) + 1])
  place(food_ob, fx, fy, FOOD)
end

local function clear_snake()
  for k = 0, len - 1 do gfx.del(ob[seg(k)]) end
  len = 0
end

local function idle_text()
  gfx.text("title", "Tap")
  gfx.text("sub", sys.best() > 0 and ("Best " .. sys.best()) or "")
  gfx.text("score", "")
  gfx.hide(food_ob, true)
end

function init()
  gfx.image("soil")
  food_ob = gfx.image("carrot")
  idle_text()
end

function reset()
  clear_snake()
  state = IDLE
  idle_text()
end

-- press: tap this tick. down/x/y: finger. sx/sy: swipe origin (host resets it via sys.swipe_mark).
function tick(now, press, down, x, y, sx, sy)
  if state == IDLE then
    if press then
      clear_snake()
      head, len = 2, 3
      for k = 0, 2 do
        cx[k], cy[k] = k - 2, 0
        ob[k] = gfx.image(k % 2 == 0 and "body_a" or "body_b")
        place(ob[k], cx[k], cy[k], BODY)
      end
      dir_x, dir_y, last_x, last_y = 1, 0, 1, 0
      score = 0
      state = PLAY
      dress()
      gfx.hide(food_ob, false)
      new_food()
      gfx.text("title", "")
      gfx.text("sub", "")
      gfx.text("score", "0")
      next_step = now + 500
    end
    return
  end
  if state == OVER then
    if now - over_until >= 0 then
      clear_snake()
      idle_text()
      state = IDLE
      sys.finish(score, sys.best(), new_best)
    end
    return
  end
  if down then
    local dx, dy = x - sx, y - sy
    if math.abs(dx) >= 24 or math.abs(dy) >= 24 then
      local nx, ny = 0, 0
      if math.abs(dx) > math.abs(dy) then nx = dx > 0 and 1 or -1 else ny = dy > 0 and 1 or -1 end
      if nx ~= -last_x or ny ~= -last_y then dir_x, dir_y = nx, ny end
      sys.swipe_mark()
    end
  end
  if now - next_step < 0 then return end
  next_step = now + math.max(110, 260 - score * 6)
  local nx, ny = cx[head] + dir_x, cy[head] + dir_y
  local grow = nx == fx and ny == fy and len < CAP
  if nx * nx + ny * ny > RAD * RAD or on_snake(nx, ny, not grow) then
    last_x, last_y = dir_x, dir_y
    state = OVER
    dress()
    new_best = score > sys.best()
    if new_best then sys.set_best(score) end
    sys.beep(300, 90, 500)
    over_until = now + 1400
    return
  end
  last_x, last_y = dir_x, dir_y
  gfx.src(ob[head], head % 2 == 0 and "body_a" or "body_b")
  place(ob[head], cx[head], cy[head], BODY)
  local nh = (head + 1) % CAP
  local o
  if grow then
    o = gfx.image(nh % 2 == 0 and "body_a" or "body_b")
    len = len + 1
  else
    o = ob[seg(len - 1)]
  end
  head = nh
  cx[head], cy[head], ob[head] = nx, ny, o
  dress()
  if grow then
    score = score + 1
    gfx.text("score", tostring(score))
    sys.beep(700, 1100, 70)
    new_food()
  end
end
