-- Pet in its burrow: the built-in game (tools/outdoor/pet.cpp) as a pack. Tap the egg five times and it hatches; then four signs care for the pet:
-- carrot (feed), moon (sleep or wake), ball (play: catch the ball five times), heart (cuddle and clean). Four daisies at the top show hunger, energy, fun
-- and cleanliness, one petal per fifth. It never dies; it gets sad, hungry or sleepy, and grows up. Same rates as before, per hour.
-- What the old game had that a pack cannot do yet (NEEDED-API.md): it kept its stats with the real time, so they moved while the console was off, and it
-- grew up 48 hours after hatching. Here, when the host offers sys.time and sys.save/sys.load, that is what it does. Until then the whole pet is packed
-- into the game's one saved number (sys.best), time only counts while the game is open, and it grows up after 12 cares.
-- Engine 4: gfx.arc and gfx.line draw the daisies and the zzz.
local PX, FEET = 233, 290
local BX, BY = {128, 195, 271, 338}, {362, 392, 392, 362}
local DX, DY = {158, 208, 258, 308}, 62
local SIGNS = {"sign_carrot", "sign_moon", "sign_ball", "sign_heart"}
local WHITE, GOLD, FAINT, ZCOL = 0xFFFFFF, 0xFFC43C, 0x6E7486, 0xC8D2FF
local DIM = 102   -- lights out: the burrow and the pet at 40 %, the signs as they are
local HOUR = 3600000
local bg, pimg, carrot, ball = nil, nil, nil, nil
local btn, petals, faint, centre, hrt, zz, zy, lastv = {}, {}, {}, {}, {}, {}, {}, {}
local P = {h = 80, e = 80, f = 80, c = 80, sleep = false, kind = -1, taps = 0, cares = 0, born = 0, ts = nil}
local built, joy, feed, play, hits, hearts, wob, frame = nil, 0, 0, 0, 0, 0, 0, 0
local ax, ay, ball_x, ball_y = 0, 0, 0, 0
local base_ms = nil   -- no clock: when the stats were last committed, in game time
local pw, ph = 180, 180

local function cl(v) return math.max(0, math.min(100, v)) end
local function clock() return sys.time and sys.time() or nil end   -- seconds since 1970, nil when the console has no time yet

-- ---- saving: the full state when the host can keep it, otherwise packed into one number
local function save()
  if sys.save then
    sys.save("pet", string.format("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", math.floor(P.h), math.floor(P.e), math.floor(P.f), math.floor(P.c),
      P.sleep and 1 or 0, P.kind, P.taps, P.cares, P.born, P.ts or 0))
    return
  end
  local q = function(v) return math.floor(cl(v)) // 4 end   -- 0..25
  sys.set_best(q(P.h) | q(P.e) << 5 | q(P.f) << 10 | q(P.c) << 15 | (P.sleep and 1 or 0) << 20 | (P.kind + 1) << 21 | math.min(P.taps, 7) << 23 | math.min(P.cares, 15) << 26)
end

local function load()
  if sys.load then
    local s = sys.load("pet")
    if s then
      local v = {}
      for n in s:gmatch("-?%d+") do v[#v + 1] = tonumber(n) end
      if #v == 10 then
        P.h, P.e, P.f, P.c, P.sleep, P.kind, P.taps, P.cares, P.born = v[1], v[2], v[3], v[4], v[5] == 1, v[6], v[7], v[8], v[9]
        P.ts = v[10] ~= 0 and v[10] or nil
      end
    end
    return
  end
  local b = sys.best()
  if b <= 0 then return end
  P.h, P.e, P.f, P.c = (b & 31) * 4, (b >> 5 & 31) * 4, (b >> 10 & 31) * 4, (b >> 15 & 31) * 4
  P.sleep, P.kind, P.taps, P.cares = (b >> 20 & 1) == 1, (b >> 21 & 3) - 1, b >> 23 & 7, b >> 26 & 15
end

-- ---- the stats now: the saved ones, decayed by the hours since they were saved
local H, E, F, C, hrs = 80, 80, 80, 80, 0
local function stats(now)
  local t = clock()
  hrs = 0
  if t and P.ts and t > P.ts then hrs = (t - P.ts) / 3600
  elseif not t and base_ms then hrs = (now - base_ms) / HOUR end
  local s = P.sleep
  H = cl(P.h - hrs * (s and 5 or 12))
  E = cl(P.e + hrs * (s and 40 or -8))
  F = cl(P.f - hrs * (s and 0 or 16))
  C = cl(P.c - hrs * (s and 4 or 8))
end

local function commit(now, sleep)
  P.h, P.e, P.f, P.c, P.sleep = H, E, F, C, sleep
  P.ts = clock()
  base_ms = now
  hrs = 0
  save()
end

local function stage()
  if P.kind < 0 then return 0 end
  local t = clock()
  if t and P.born ~= 0 then return t - P.born >= 48 * 3600 and 2 or 1 end
  return P.cares >= 12 and 2 or 1
end

local function care(now)   -- grows the pet when there is no clock
  if P.cares < 15 then P.cares = P.cares + 1 end
end

local function pop() sys.beep(900, 300, 70) end
local function happy()
  sys.beep(784, 784, 70)
  sys.beep(1047, 1047, 70)
end

local function disc(cx, cy, r, col) return gfx.arc(cx, cy, (r + 1) // 2, 0, 360, r + r % 2, col) end

-- A "z" from three strokes, drawn at 0,0 and moved as one.
local function make_z()
  return {gfx.line(0, 0, 14, 0, 4, ZCOL), gfx.line(14, 0, 0, 16, 4, ZCOL), gfx.line(0, 16, 14, 16, 4, ZCOL)}
end
local function place_z(z, x, y) for _, o in ipairs(z) do gfx.pos(o, x, y) end end
local function hide_z(z, on) for _, o in ipairs(z) do gfx.hide(o, on) end end

function init()
  load()
  bg = gfx.image("burrow")
  pimg = gfx.image("egg")
  pw, ph = gfx.size("egg")
  for k = 1, 3 do
    zz[k] = make_z()
    hide_z(zz[k], true)
    zy[k] = 150 - (k - 1) * 30
    hrt[k] = gfx.image("heart")
    gfx.hide(hrt[k], true)
  end
  -- the daisies: five petals round a gold heart; a lost petal shows its faint twin
  for k = 1, 4 do
    petals[k], faint[k] = {}, {}
    for p = 1, 5 do
      local a = -1.5708 + (p - 1) * 1.2566
      local px, py = DX[k] + math.floor(13 * math.cos(a) + 0.5), DY + math.floor(13 * math.sin(a) + 0.5)
      faint[k][p] = disc(px, py, 8, FAINT)
      petals[k][p] = disc(px, py, 8, WHITE)
    end
    centre[k] = disc(DX[k], DY, 7, GOLD)
    lastv[k] = -1
  end
  for k = 1, 4 do
    local w, h = gfx.size(SIGNS[k])
    btn[k] = gfx.image(SIGNS[k])
    gfx.pos(btn[k], BX[k] - w // 2, BY[k] - h // 2)
  end
  carrot = gfx.image("carrot")
  gfx.hide(carrot, true)
  ball = gfx.image("ball")
  gfx.hide(ball, true)
  if P.kind >= 0 and P.born == 0 and clock() then P.born = clock() end
end

local function show_daisies(on)
  for k = 1, 4 do
    gfx.hide(centre[k], not on)
    gfx.hide(btn[k], not on)
    for p = 1, 5 do
      gfx.hide(faint[k][p], not on)
      gfx.hide(petals[k][p], not on or p > lastv[k])
    end
  end
end

local function place_ball()   -- left or middle, clear of the right rim
  local bw, bh = gfx.size("ball")
  ball_x, ball_y = 50 + sys.random(200), 80 + sys.random(180)
  gfx.pos(ball, ball_x, ball_y)
  gfx.hide(ball, false)
  ball_x, ball_y = ball_x + bw // 2, ball_y + bh // 2
end

-- What a tap is on: 1-4 a sign, 10 the ball, 9 anywhere else (the egg or the pet)
local function hit(x, y, egg)
  if not egg then
    for k = 1, 4 do
      local dx, dy = x - BX[k], y - BY[k]
      if dx * dx + dy * dy <= 44 * 44 then return k end
    end
  end
  if play > 0 then
    local dx, dy = x - ball_x, y - ball_y
    if dx * dx + dy * dy <= 46 * 46 then return 10 end
  end
  return 9
end

function tick(now, press, down, x, y)
  if not base_ms then
    base_ms = now
    if not P.ts and clock() then P.ts = clock() end
  end
  stats(now)
  frame = frame + 1
  local egg = P.kind < 0
  local sleeping = P.sleep
  local act = press and hit(x, y, egg) or 0
  local function wake() if sleeping then sleeping = false; commit(now, false) end end
  if act == 9 and egg then   -- tap the egg: wobble, crack, hatch
    wob = 8
    P.taps = P.taps + 1
    pop()
    built = nil
    if P.taps >= 5 then
      P.taps, P.kind, P.cares = 0, sys.random(3), 0
      P.born = clock() or 0
      H, E, F, C = 80, 80, 80, 80
      commit(now, false)
      joy = 50
      happy()
    else
      save()
    end
  elseif act == 9 and not egg and not sleeping and joy == 0 then   -- tap the pet: a giggle
    joy = 16
    pop()
  elseif act >= 1 and act <= 4 and not egg and feed == 0 then
    if act == 1 then wake(); feed, ax, ay = 1, BX[1] - 20, BY[1] - 20; gfx.hide(carrot, false) end
    if act == 2 then commit(now, not sleeping); sleeping = not sleeping; joy, play = 0, 0; gfx.hide(ball, true); care(now); save() end
    if act == 3 then wake(); play, hits = 300, 0; place_ball() end
    if act == 4 then
      wake()
      C, F = 100, cl(F + 5)
      care(now)
      commit(now, false)
      joy, hearts = 40, 30
      happy()
    end
  elseif act == 10 and play > 0 then   -- caught the ball
    hits = hits + 1
    F = cl(F + 12)
    commit(now, false)
    joy = 14
    pop()
    if hits >= 5 then
      play, joy = 0, 40
      gfx.hide(ball, true)
      care(now)
      save()
      happy()
    else
      place_ball()
    end
  end
  if play > 0 then
    play = play - 1
    if play == 0 then gfx.hide(ball, true) end
  end
  local st = stage()
  -- The carrot flies to the mouth
  if feed > 0 then
    feed = feed + 1
    local tx, ty = PX - 20, (st == 1 and 232 or 205) - 20
    ax, ay = ax + (tx - ax) * 0.2, ay + (ty - ay) * 0.2
    gfx.pos(carrot, math.floor(ax), math.floor(ay))
    if feed > 18 then
      feed = 0
      gfx.hide(carrot, true)
      H = cl(H + 30)
      care(now)
      commit(now, false)
      joy = 40
      happy()
    end
  end
  if joy > 0 then joy = joy - 1 end
  -- Wakes up by itself once rested
  if sleeping and E >= 100 and hrs > 0 then commit(now, false); sleeping = false end
  -- mood: 0 content, 1 joy, 2 hungry, 3 sleepy, 4 sad, 5 asleep, 6 eating
  local mood = 0
  if sleeping then mood = 5
  elseif feed > 0 then mood = 6
  elseif joy > 0 then mood = 1
  elseif H < 30 then mood = 2
  elseif E < 25 then mood = 3
  elseif F < 30 or C < 30 then mood = 4
  elseif H > 70 and E > 60 and F > 70 and C > 60 then mood = 1 end
  local dirty = not egg and C < 35
  local key = egg and ("egg" .. math.min(P.taps, 4)) or (st .. ":" .. mood .. (dirty and "d" or ""))
  -- The sprite, changed only when stage or mood changes
  if key ~= built then
    built = key
    local src, scale = "grown", 256
    if egg then src = P.taps >= 2 and "hatch" or "egg"
    elseif mood == 5 then src = "asleep"
    elseif mood == 2 or mood == 3 or mood == 4 or dirty then src = "sad" end
    if not egg and st == 1 then scale = 190 end   -- the baby: three quarters
    gfx.src(pimg, src)
    gfx.scale(pimg, scale)
    pw, ph = gfx.size(src)
    if egg then for k = 1, 4 do lastv[k] = 0 end end
    show_daisies(not egg)
    -- Lights out and zzz while asleep
    gfx.opa(bg, mood == 5 and DIM or 255)
    gfx.opa(pimg, mood == 5 and DIM or 255)
    for k = 1, 3 do hide_z(zz[k], mood ~= 5) end
  end
  -- Small moves only: a wobble for the egg, a gentle breathing bob for the pet. Scaled about its centre, so the visible feet stay on the burrow mouth.
  local scale = (not egg and st == 1) and 190 or 256
  local ox, oy = 0, 0
  if egg and wob > 0 then
    wob = wob - 1
    ox = wob == 0 and 0 or (wob % 4 < 2 and 4 or -4)
  elseif not egg and not sleeping then
    oy = (frame // 8) % 2 == 1 and -4 or 0
  end
  gfx.pos(pimg, PX - pw // 2 + ox, FEET - ph // 2 * scale // 256 - ph // 2 + oy)
  if sleeping and frame % 3 == 0 then
    for k = 1, 3 do
      zy[k] = zy[k] - 1.5
      if zy[k] < 40 then zy[k] = 150 end
      place_z(zz[k], 300 - math.floor(zy[k]) // 4 + (k - 1) * 6, math.floor(zy[k]))
    end
  end
  if hearts > 0 then
    hearts = hearts - 1
    for k = 1, 3 do
      gfx.hide(hrt[k], hearts == 0)
      gfx.pos(hrt[k], 150 + (k - 1) * 70, 150 - (30 - hearts) * 3 - (k - 1) * 12)
    end
  end
  -- The daisies, refreshed when a stat crosses a fifth
  if not egg and frame % 10 == 1 then
    local v = {math.floor((H + 10) / 20), math.floor((E + 10) / 20), math.floor((F + 10) / 20), math.floor((C + 10) / 20)}
    for k = 1, 4 do
      if v[k] ~= lastv[k] then
        lastv[k] = v[k]
        for p = 1, 5 do gfx.hide(petals[k][p], p > v[k]) end
      end
    end
  end
end
