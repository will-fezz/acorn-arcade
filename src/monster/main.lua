-- Feed the Monster as a picnic: same game as the built-in one (tools/outdoor/monster.cpp). Pick a monster (Mochi, Pip or Nimbus), then drag the fruit
-- off the blanket into its mouth; it munches, a star pops and more fruit appears. No ending: the count goes to the play log. The face button, top left,
-- goes back to the picker. The chosen monster is remembered in the game's saved number (sys.best), the only thing a pack can keep yet.
-- Engine 4: gfx.arc draws the face button and the picker rings.
local KINDS = {"mochi", "pip", "nimbus"}
local FRUITS = {"apple", "straw", "grapes", "banana"}
local SPOTS = {150, 233, 316}            -- the fruit's places on the blanket, clear of the right-edge swipe
local PCX, PCY = {233, 146, 320}, {133, 283, 283}
local MX, MY, MON_Y = 233, 305, 240       -- the mouth, and the monster's centre
local FACE_X, FACE_Y = 106, 106
local DIMMED = 77                         -- the picnic behind the picker, as under the old 70 % navy cover
local bg, mon, fruit, star, face, ring, mini = nil, nil, nil, nil, {}, {}, {}
local picking, kind, eaten = true, 1, 0
local fx, fy, hx, hy, gx, gy = 0, 0, 0, 0, 0, 0
local drag, munch, respawn, starf, bob, frame = false, 0, 0, 0, 0, 0
local mon_w, mon_h, fr_w, fr_h, star_x = 0, 0, 0, 0, 293

local function disc(cx, cy, r, col) return gfx.arc(cx, cy, (r + 1) // 2, 0, 360, r + r % 2, col) end

local function place_mon(dy) gfx.pos(mon, 233 - mon_w // 2, MON_Y - mon_h // 2 + dy) end
local function place_fruit() gfx.pos(fruit, math.floor(fx) - fr_w // 2, math.floor(fy) - fr_h // 2) end

local function spawn()
  hx, hy = SPOTS[sys.random(3) + 1], 405
  fx, fy = hx, hy
  local name = FRUITS[sys.random(4) + 1]
  gfx.src(fruit, name)
  fr_w, fr_h = gfx.size(name)
  place_fruit()
  gfx.hide(fruit, false)
end

local function show_picker(on)
  picking = on
  gfx.opa(bg, on and DIMMED or 255)
  for k = 1, 3 do
    gfx.hide(mini[k], not on)
    gfx.hide(ring[k], not (on and k == kind))
  end
  for _, o in ipairs(face) do gfx.hide(o, on) end
  gfx.hide(mon, on)
  gfx.hide(fruit, on)
  gfx.hide(star, true)
  gfx.text("score", on and "" or tostring(eaten))
  drag = false
end

local function choose(k)
  kind = k
  if sys.best() ~= k then sys.set_best(k) end
  gfx.src(mon, KINDS[k])
  mon_w, mon_h = gfx.size(KINDS[k])
  gfx.scale(mon, 256)
  place_mon(0)
  eaten, munch, respawn, starf, bob = 0, 0, 0, 0, 0
  show_picker(false)
  spawn()
end

function init()
  bg = gfx.image("picnic")
  local b = sys.best()
  kind = (b >= 1 and b <= 3) and b or 1
  mon = gfx.image(KINDS[kind])
  mon_w, mon_h = gfx.size(KINDS[kind])
  place_mon(0)
  fruit = gfx.image("apple")
  fr_w, fr_h = gfx.size("apple")
  star = gfx.image("star")
  -- The face button: a navy disc, two eyes and a smile
  face[1] = disc(FACE_X, FACE_Y, 28, 0x26345A)
  face[2] = disc(FACE_X - 8, FACE_Y - 6, 5, 0xFFFFFF)
  face[3] = disc(FACE_X + 8, FACE_Y - 6, 5, 0xFFFFFF)
  face[4] = gfx.arc(FACE_X, FACE_Y + 1, 12, 30, 150, 4, 0xFFFFFF)
  -- The picker: three small monsters on the dimmed picnic, a white ring round the last one chosen
  for k = 1, 3 do
    local w, h = gfx.size(KINDS[k])
    mini[k] = gfx.image(KINDS[k])
    gfx.scale(mini[k], 112)   -- 300 px art at about 130 px, scaled about its centre
    gfx.pos(mini[k], PCX[k] - w // 2, PCY[k] - h // 2)
  end
  for k = 1, 3 do ring[k] = gfx.arc(PCX[k], PCY[k], 78, 0, 360, 5, 0xFFFFFF) end
  show_picker(true)
end

local function munch_sound()
  sys.beep(784, 784, 70)
  sys.beep(1047, 1047, 70)
end

function tick(now, press, down, x, y)
  if picking then
    if press then
      for k = 1, 3 do
        local dx, dy = x - PCX[k], y - PCY[k]
        if dx * dx + dy * dy <= 80 * 80 then choose(k); return end
      end
    end
    return
  end
  if press then
    local dx, dy = x - FACE_X, y - FACE_Y
    if dx * dx + dy * dy <= 40 * 40 then show_picker(true); return end
  end
  frame = frame + 1
  local visible = respawn == 0
  if down and not drag and visible then
    local dx, dy = x - fx, y - fy
    if dx * dx + dy * dy <= 56 * 56 then drag, gx, gy = true, dx, dy end
  end
  local moved = false
  if drag then
    if down then
      local nx, ny = x - gx, y - gy
      if math.abs(nx - fx) >= 1 or math.abs(ny - fy) >= 1 then fx, fy, moved = nx, ny, true end
    else
      drag = false
      local dx, dy = fx - MX, fy - MY
      if dx * dx + dy * dy <= 75 * 75 then   -- eaten!
        gfx.hide(fruit, true)
        eaten = eaten + 1
        gfx.text("score", tostring(eaten))
        sys.score(eaten)
        munch_sound()
        munch, respawn, starf = 24, 40, 26
        star_x = 233 + 60 + sys.random(50)
        gfx.pos(star, star_x, 110)
        gfx.hide(star, false)
      end
    end
  elseif visible and (math.abs(fx - hx) > 0.5 or math.abs(fy - hy) > 0.5) then
    fx, fy = fx + (hx - fx) * 0.12, fy + (hy - fy) * 0.12   -- float gently back home
    if math.abs(fx - hx) < 1 and math.abs(fy - hy) < 1 then fx, fy = hx, hy end
    moved = true
  end
  if moved then place_fruit() end
  -- Munch: a chunky scale pulse; otherwise a slow breathing bob every 8 frames
  if munch > 0 then
    munch = munch - 1
    gfx.scale(mon, munch == 0 and 256 or 256 + math.floor(28 * math.sin(munch * 0.52)))
  elseif frame % 8 == 0 then
    bob = (bob + 1) % 2
    place_mon(bob == 1 and -3 or 0)
  end
  if starf > 0 then
    starf = starf - 1
    gfx.pos(star, star_x, 110 - (26 - starf) * 2)
    if starf == 0 then gfx.hide(star, true) end
  end
  if respawn > 0 then
    respawn = respawn - 1
    if respawn == 0 then spawn() end
  end
end
