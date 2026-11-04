-- Tic-tac-toe for the 466 px round Sweetcorn console. Engine 6 game-owned art.
-- Allocate once: the real host keeps deleted object slots until a game exits.
local cells, marks, winlines = {}, {}, {}
local wins = {{1,2,3},{4,5,6},{7,8,9},{1,4,7},{2,5,8},{3,6,9},{1,5,9},{3,5,7}}
local header, board, menu, footer
local phase, solo, turn, used, ai_at, won = "menu", false, 1, 0, 0, 0
local touching = false
local completed = 0
-- Winning line in the theme's gold accent2 (keyed by the public tilt_wall value, as the shell palette is not exposed).
local GOLD = ({["3C7A3A"]=0xF2B84B, ["5A7FA8"]=0xFFD24A, ["8A5A34"]=0x7ECC54, ["E88BB8"]=0x8FE0C0, ["C03C3C"]=0xF3CF5A})[sys.theme and sys.theme("tilt_wall") or ""] or 0xF2B84B
local function centre(i)
  return 149 + ((i-1)%3)*84, 150 + ((i-1)//3)*84
end
local function status(name) gfx.src(header, name) end
local function show_board(on)
  gfx.hide(board, not on); gfx.hide(footer, not on); gfx.hide(menu, on)
end
local function reset_marks()
  for i=1,9 do
    cells[i]=0
    gfx.hide(marks[i][1],true); gfx.hide(marks[i][2],true)
  end
  for _,o in ipairs(winlines) do gfx.hide(o,true) end
end
local function start(one_player)
  solo,turn,used,won = one_player,1,0,0
  reset_marks(); show_board(true); phase="play"; status("turn_x")
end
local function finish(winner, line)
  phase="done"; won=winner; completed=completed+1
  status(winner==1 and "win_x" or winner==2 and "win_o" or "draw")
  if line then gfx.hide(winlines[line],false) end
  sys.score(completed) -- rounds completed, not a fictitious competitive high score
  sys.beep(660,880,120)
end
local function place(i, now)
  if phase~="play" or cells[i]~=0 then return end
  cells[i]=turn; used=used+1; gfx.hide(marks[i][turn],false)
  sys.beep(turn==1 and 520 or 660,turn==1 and 520 or 660,45)
  for n,w in ipairs(wins) do
    if cells[w[1]]~=0 and cells[w[1]]==cells[w[2]] and cells[w[2]]==cells[w[3]] then
      finish(turn,n); return
    end
  end
  if used==9 then finish(0); return end
  turn=3-turn
  if solo and turn==2 then
    -- modulo matches the actual host's 31-bit millisecond counter.
    ai_at=(now+650)&0x7fffffff; status("thinking")
  else status(turn==1 and "turn_x" or "turn_o") end
end
function init()
  gfx.image("background")
  header=gfx.image("choose"); gfx.pos(header,73,60)
  board=gfx.image("board"); gfx.pos(board,107,108)
  menu=gfx.image("menu"); gfx.pos(menu,98,149)
  footer=gfx.image("footer"); gfx.pos(footer,107,374)
  for i=1,9 do
    local x,y=centre(i)
    marks[i]={gfx.image("cross"),gfx.image("ring")}
    for _,o in ipairs(marks[i]) do gfx.pos(o,x-28,y-28) end
  end
  for n,w in ipairs(wins) do
    local x1,y1=centre(w[1]); local x2,y2=centre(w[3])
    winlines[n]=gfx.line(x1,y1,x2,y2,12,GOLD)
  end
  reset_marks(); show_board(false)
  gfx.text("title",""); gfx.text("sub",""); gfx.text("score","")
  sys.score(0)
end
function tick(now, press, down, x, y)
  -- Consume one placement per physical contact, even if press repeats or a
  -- held finger crosses a cell. Nothing is queued while the computer thinks.
  local tap=press and not touching
  touching=down
  if phase=="play" and solo and turn==2 then
    local elapsed=(now-ai_at)&0x7fffffff
    if elapsed<0x40000000 then
      local free={}
      for i=1,9 do if cells[i]==0 then free[#free+1]=i end end
      if #free>0 then place(free[sys.random(#free)+1],now) end
      tap=false -- a tap landing with the AI move must not become a human move
    end
  end
  if not tap then return end
  if sys.active then sys.active() end
  if phase=="menu" then
    if x>=98 and x<368 and y>=149 and y<217 then start(true)
    elseif x>=98 and x<368 and y>=241 and y<309 then start(false) end
    return
  end
  if y>=374 and y<418 then
    if x>=107 and x<226 then start(solo)
    elseif x>=240 and x<359 then
      reset_marks(); show_board(false); phase="menu"; status("choose")
    end
    return
  end
  if phase~="play" or (solo and turn==2) then return end
  if x<107 or x>=359 or y<108 or y>=360 then return end
  local col,row=(x-107)//84,(y-108)//84
  -- Ignore the slim separators: near misses must not choose another square.
  local lx,ly=(x-107)%84,(y-108)%84
  if lx<4 or lx>=80 or ly<4 or ly>=80 then return end
  place(row*3+col+1,now)
end
