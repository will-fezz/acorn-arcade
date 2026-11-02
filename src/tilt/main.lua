-- Tilt maze as a pack: the console's own ball maze (tools/tilt_tick.cpp and tools/tilt_levels.py, ESPHome build of 2026-10-21, hedge maze of 2026-11-01), ported to Lua.
-- Roll the hedgehog to the nest by tilting the console. Six levels of ring walls with gaps, spokes and puddles. A puddle sends it back to the start and the clock
-- keeps running; the nest starts the next level. Tap re-zeros the tilt and restarts the level. Tilt is measured against how the console was held when the level
-- started, so it plays in the hand or flat on a table.
-- Needs engine 4: sys.tilt (Tilt-a-tron's approach, see licences/MIT-tilt-a-tron.txt), sys.active, sys.theme, gfx.arc and gfx.line.
-- sys.tilt gives milli-g pointing downhill in screen axes: +x right, +y towards the player.
local C = 233
local R_OUT, WT, BR = 182, 3, 11          -- rim, wall half-thickness, hedgehog radius (24 px sprite)
local HOLE_FALL, GR, GAP_PX = 10, 17, 44
local R_LIM, CLR = R_OUT - WT - BR, BR + WT
local ACC, VMAX = 1000, 450               -- px/s^2 per g, px/s

-- angles in degrees clockwise from 3 o'clock; points as {angle, radius}
local LEVELS = {
  {rings = {{92, {270}}}, spokes = {}, holes = {}, start = {90, 159}, goal = {0, 0}},
  {rings = {{136, {270}}, {68, {90}}}, spokes = {}, holes = {{0, 102}, {180, 102}}, start = {90, 159}, goal = {0, 0}},
  {rings = {{136, {0}}, {92, {180}}, {48, {270}}}, spokes = {{45, 136, 182}, {270, 92, 136}}, holes = {{180, 172}, {135, 126}}, start = {90, 159}, goal = {0, 0}},
  {rings = {{136, {200, 340}}, {92, {20, 160}}, {48, {90}}}, spokes = {{270, 136, 182}, {90, 92, 136}},
   holes = {{150, 172}, {30, 172}, {180, 126}, {0, 126}}, start = {90, 159}, goal = {0, 0}},
  {rings = {{48, {0, 180}}, {92, {270}}, {136, {90}}}, spokes = {{0, 92, 136}, {180, 136, 182}},
   holes = {{180, 126}, {320, 98}, {30, 172}, {330, 145}}, start = {0, 0}, goal = {270, 159}},
  {rings = {{136, {300}, 38}, {92, {120}, 38}, {48, {300}, 38}}, spokes = {{250, 136, 182}, {350, 92, 136}, {60, 92, 136}, {200, 48, 92}},
   holes = {{90, 172}, {200, 145}, {180, 126}, {0, 98}, {240, 70}}, start = {270, 159}, goal = {0, 0}},
}

local function polar(a, r)
  local t = math.rad(a)
  return r * math.cos(t), r * math.sin(t)
end
local function hex(s, d)
  local v = s and tonumber(s, 16)
  return v or d
end

local WALL, WALL_SH = 0x3C7A3A, 0x1C3A1E
local hog, hog_w, hog_h, objs = nil, 0, 0, {}
local level, state, anim, frames = 1, 0, 0, 0
local px, py, vx, vy, fx, fy, bx0, by0, sx, sy, hx, hy = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
local arcs, ends, segs, holes, goal, start = {}, {}, {}, {}, {}, {}
local run_ms, last, act_ms, tenth = 0, nil, 0, -1
local best_level, total_ms, new_best = {}, 0, false
local no_tilt = false
-- states: 0 settling (zeroing the tilt), 1 rolling, 2 falling into a puddle, 3 into the nest, 4 all done

local function clock(ms)
  local t = ms // 100
  return string.format("%d:%02d.%d", t // 600, (t // 10) % 60, t % 10)
end

local function clear()
  for i = 1, #objs do gfx.del(objs[i]) end
  objs = {}
end
local function keep(o) objs[#objs + 1] = o; return o end

local function build()
  clear()
  local L = LEVELS[level]
  arcs, ends, segs, holes = {}, {}, {}, {}
  keep(gfx.arc(C, C + 2, R_OUT, 0, 360, 2 * WT, WALL_SH))
  keep(gfx.arc(C, C, R_OUT, 0, 360, 2 * WT, WALL))
  for _, ring in ipairs(L.rings) do
    local r, gaps, gpx = ring[1], ring[2], ring[3] or GAP_PX
    local half = math.deg((gpx / 2 + WT) / r)
    table.sort(gaps)
    for i, g in ipairs(gaps) do
      local nxt = gaps[i % #gaps + 1] + (i == #gaps and 360 or 0)
      local a0, a1 = g + half, nxt - half
      arcs[#arcs + 1] = {r = r, a0 = a0 % 360, span = a1 - a0}
      local x0, y0 = polar(a0, r)
      local x1, y1 = polar(a1, r)
      ends[#ends + 1] = {x0, y0, x1, y1}
      keep(gfx.arc(C, C + 2, r, math.floor(a0), math.floor(a1 + 0.5), 2 * WT, WALL_SH))
      keep(gfx.arc(C, C, r, math.floor(a0), math.floor(a1 + 0.5), 2 * WT, WALL))
    end
  end
  for _, s in ipairs(L.spokes) do
    local x0, y0 = polar(s[1], s[2])
    local x1, y1 = polar(s[1], s[3])
    segs[#segs + 1] = {x0, y0, x1, y1}
    keep(gfx.line(math.floor(C + x0 + 0.5), math.floor(C + y0 + 2.5), math.floor(C + x1 + 0.5), math.floor(C + y1 + 2.5), 2 * WT, WALL_SH))
    keep(gfx.line(math.floor(C + x0 + 0.5), math.floor(C + y0 + 0.5), math.floor(C + x1 + 0.5), math.floor(C + y1 + 0.5), 2 * WT, WALL))
  end
  local pw, ph = gfx.size("puddle")
  for _, h in ipairs(L.holes) do
    local x, y = polar(h[1], h[2])
    holes[#holes + 1] = {x, y}
    local o = keep(gfx.image("puddle"))
    gfx.pos(o, math.floor(C + x - pw / 2), math.floor(C + y - ph / 2))
  end
  goal = {polar(L.goal[1], L.goal[2])}
  start = {polar(L.start[1], L.start[2])}
  local nw, nh = gfx.size("nest")
  local n = keep(gfx.image("nest"))
  gfx.pos(n, math.floor(C + goal[1] - nw / 2), math.floor(C + goal[2] - nh / 2))
  hog = keep(gfx.image("hog"))
end

local function place(scale)
  gfx.pos(hog, math.floor(C + px - hog_w / 2 + 0.5), math.floor(C + py - hog_h / 2 + 0.5))
  gfx.scale(hog, math.floor(256 * scale))
end

local function restart(fresh)
  if fresh then run_ms = 0 end
  px, py, vx, vy, fx, fy = start[1], start[2], 0, 0, 0, 0
  state, frames, sx, sy, tenth = 0, 0, 0, 0, -1
  gfx.hide(hog, false)
  place(1)
  gfx.text("title", no_tilt and "No tilt sensor" or ("Level " .. level))
  local b = best_level[level]
  gfx.text("sub", b and ("Best " .. clock(b)) or "Hold still")
  gfx.text("score", clock(run_ms))
end

function init()
  WALL = hex(sys.theme("tilt_wall"), WALL)
  WALL_SH = hex(sys.theme("tilt_wall_sh"), WALL_SH)
  gfx.image("lawn")
  hog_w, hog_h = gfx.size("hog")
  level = 1
  build()
  restart(true)
end

local function push(qx, qy, lim, inside, hit)
  local dx, dy = px - qx, py - qy
  local d = math.sqrt(dx * dx + dy * dy)
  if inside then if d <= lim then return hit end elseif d >= lim then return hit end
  if d < 0.001 then dx, dy, d = 0, -1, 1 end
  local nx, ny = dx / d, dy / d
  if inside then nx, ny = -nx, -ny end
  local pen = inside and d - lim or lim - d
  px, py = px + nx * pen, py + ny * pen
  local vn = vx * nx + vy * ny
  if vn < 0 then
    if -vn > hit then hit = -vn end
    vx, vy = (vx - 1.35 * vn * nx) * 0.97, (vy - 1.35 * vn * ny) * 0.97   -- restitution 0.35
  end
  return hit
end

local function pull(cx, cy, rr, ax, ay)
  local dx, dy = cx - px, cy - py
  local d = math.sqrt(dx * dx + dy * dy)
  if d < rr and d > 0.5 then
    local k = 700 * (1 - d / rr) / d
    return ax + dx * k, ay + dy * k
  end
  return ax, ay
end

local function dist(p) return math.sqrt((p[1] - px) ^ 2 + (p[2] - py) ^ 2) end

local function done_level()
  state, anim = 3, 0
  local t = (run_ms + 50) // 100 * 100
  new_best = best_level[level] == nil or t < best_level[level]
  if new_best then best_level[level] = t end
  total_ms = total_ms + run_ms
  gfx.text("title", "Level " .. level)
  gfx.text("sub", new_best and (clock(t) .. "  New best!") or clock(t))
  sys.score(level)
  sys.beep(523, 784, 300)
end

function tick(now, press, down, x, y, swx, swy)
  local dt = last and (now - last) / 1000 or 0.033
  last = now
  if dt < 0.005 then dt = 0.005 elseif dt > 0.06 then dt = 0.06 end
  if press then
    if state == 4 then
      level, total_ms = 1, 0
      build()
      restart(true)
    elseif state ~= 3 then
      restart(false)
    end
  end
  local tx, ty = sys.tilt()
  if tx == nil then
    no_tilt = true
    tx, ty = 0, 0
  end
  tx, ty = tx / 1000, ty / 1000
  if state == 0 then   -- settling: average the pose over about half a second, then roll
    frames = frames + 1
    if frames > 4 and frames <= 16 then sx, sy = sx + tx, sy + ty end
    if frames == 16 then bx0, by0 = sx / 12, sy / 12 end
    if frames < 27 then return end
    state = 1
    gfx.text("title", "")
    gfx.text("sub", "")
  end
  fx = fx + 0.45 * ((tx - bx0) - fx)
  fy = fy + 0.45 * ((ty - by0) - fy)
  if state == 4 then return end
  if state == 3 then   -- into the nest, then the next level
    anim = anim + 1
    px, py = px + (goal[1] - px) * 0.3, py + (goal[2] - py) * 0.3
    place(math.max(0.05, 1 - anim / 12))
    if anim == 12 then gfx.hide(hog, true) end
    if anim >= 40 then
      if level >= #LEVELS then
        local best = sys.best()
        local mine = (total_ms + 50) // 100
        local nb = best == 0 or mine < best
        if nb then sys.set_best(mine) end
        gfx.text("title", "All done!")
        gfx.text("sub", "Time " .. clock(total_ms) .. (nb and "  Best!" or ("  Best " .. clock(best * 100))))
        state = 4
        sys.beep(523, 1047, 500)
      else
        level = level + 1
        build()
        restart(true)
      end
    end
    return
  end
  if state == 2 then   -- into a puddle, then back to the start
    anim = anim + 1
    px, py = px + (hx - px) * 0.35, py + (hy - py) * 0.35
    place(math.max(0.05, 1 - anim / 10))
    if anim >= 16 then
      px, py, vx, vy = start[1], start[2], 0, 0
      place(1)
      state = 1
    end
    run_ms = run_ms + math.floor(dt * 1000)
    return
  end
  -- rolling
  run_ms = run_ms + math.floor(dt * 1000)
  if run_ms // 100 ~= tenth then
    tenth = run_ms // 100
    gfx.text("score", clock(run_ms))
  end
  local ax = math.abs(fx) < 0.02 and 0 or fx * ACC
  local ay = math.abs(fy) < 0.02 and 0 or fy * ACC
  for _, h in ipairs(holes) do ax, ay = pull(h[1], h[2], 12 + BR - 2, ax, ay) end
  ax, ay = pull(goal[1], goal[2], GR + BR, ax, ay)
  vx, vy = vx + ax * dt, vy + ay * dt
  local damp = 0.55 ^ dt   -- rolling friction
  vx, vy = vx * damp, vy * damp
  local sp = math.sqrt(vx * vx + vy * vy)
  if sp > VMAX then vx, vy, sp = vx * VMAX / sp, vy * VMAX / sp, VMAX end
  local steps = math.max(1, math.min(8, math.ceil(sp * dt / 3)))
  local sdt, hit = dt / steps, 0
  for _ = 1, steps do
    px, py = px + vx * sdt, py + vy * sdt
    hit = push(0, 0, R_LIM, true, hit)
    for i, A in ipairs(arcs) do
      local th = math.deg(math.atan(py, px)) % 360
      if (th - A.a0) % 360 <= A.span then
        local r = math.sqrt(px * px + py * py)
        if r > 0.001 then hit = push(px * A.r / r, py * A.r / r, CLR, false, hit) end
      else
        local e = ends[i]
        hit = push(e[1], e[2], CLR, false, hit)
        hit = push(e[3], e[4], CLR, false, hit)
      end
    end
    for _, g in ipairs(segs) do
      local dx, dy = g[3] - g[1], g[4] - g[2]
      local t = ((px - g[1]) * dx + (py - g[2]) * dy) / (dx * dx + dy * dy)
      if t < 0 then t = 0 elseif t > 1 then t = 1 end
      hit = push(g[1] + t * dx, g[2] + t * dy, CLR, false, hit)
    end
  end
  for _, h in ipairs(holes) do
    if dist(h) < HOLE_FALL then
      hx, hy, state, anim = h[1], h[2], 2, 0
      sys.beep(700, 200, 350)
      break
    end
  end
  if state == 1 and dist(goal) < GR - 4 then done_level() end
  place(1)
  -- rolling about counts as using the screen: there are no touches while this is played
  if (sp > 25 or hit > 40) and now - act_ms > 1000 then
    act_ms = now
    sys.active()
  end
end
