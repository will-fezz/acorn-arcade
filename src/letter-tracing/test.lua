-- Runs against the SAME bundled Lua interpreter; strict gfx/sys contract stubs.
local objects,texts,nextid,peak,score,saved,now={}, {},0,0,0,nil,1000
local theme='3C7A3A'
local function int(v) assert(math.type(v)=='integer','fraction sent to host'); return v end
local function object(o)
 nextid=nextid+1; assert(nextid<=512,'host lifetime handle budget exceeded'); objects[nextid]=o;local n=0;for _ in pairs(objects) do n=n+1 end
 peak=math.max(peak,n);assert(n<=512,'host object budget exceeded');return nextid
end
local function rgb(c) assert(c>=0 and c<=0xffffff);int(c) end
gfx={
 image=function(n) assert(n=='paper' or n=='mascot','unknown image '..tostring(n));return object({kind=n}) end,
 line=function(x,y,a,b,w,c) for _,v in ipairs({x,y,a,b,w}) do int(v) end;rgb(c);assert(w>=1 and w<=59);return object({kind='line',x=x,y=y,a=a,b=b,w=w,c=c}) end,
 box=function(x,y,w,h,r,c,opa) for _,v in ipairs({x,y,w,h,r,opa}) do int(v) end;rgb(c);return object({kind='box',x=x,y=y,w=w,h=h,r=r,c=c}) end,
 arc=function(x,y,r,a,b,w,c) for _,v in ipairs({x,y,r,a,b,w}) do int(v) end;rgb(c);return object({kind='arc',x=x,y=y,r=r,a=a,b=b,w=w,c=c}) end,
 del=function(id) assert(objects[id]);objects[id]=nil end,
 pos=function(id,x,y) assert(objects[id]);objects[id].x=int(x);objects[id].y=int(y) end,
 front=function(id) assert(objects[id]) end,
 hide=function(id,h) assert(objects[id]);objects[id].hidden=h end,
 text=function(k,t) assert(k=='title' or k=='sub' or k=='score');texts[k]=t end,
 text_color=function(k,c) rgb(c) end,
}
sys={
 theme=function(k) assert(k=='tilt_wall');return theme end,
 save=function(k,v) assert(k=='pick' and #v<=256);saved=v end,
 load=function(k) assert(k=='pick');return saved end,
 score=function(v) int(v);score=v end,
 beep=function(a,b,ms) assert(ms>0 and ms<=1000) end,
}
local function tickAt(press,down,x,y) now=now+300;tick(now,press,down,x,y) end
local function tap(x,y) tickAt(true,true,x,y);tickAt(false,false,x,y) end
local function marker()
 for _,o in pairs(objects) do if o.kind=='box' and o.w==18 and not o.hidden then return o end end
end
local function snapshot(name)
 local rows={}
 for i=1,nextid do local o=objects[i];if o and not o.hidden then
  rows[#rows+1]=table.concat({o.kind,o.x or 0,o.y or 0,o.a or 0,o.b or 0,o.w or 0,o.h or 0,o.r or 0,o.c or 0},'\t')..'\n'
 end end
 for _,k in ipairs({'title','sub','score'}) do rows[#rows+1]='text\t'..k..'\t'..(texts[k] or ''):gsub('\n',' / ')..'\n' end
 write_snapshot('state/sweetcorn-new-games/letter-tracing/'..name..'.tsv',table.concat(rows))
end
init();assert(score==0 and texts.title=='Trace letters');tap(233,230);assert(texts.score=='A')
snapshot('outdoors-A')
-- Endpoint-only or far-away taps must not complete a glyph.
for i=1,30 do tap(330,310);tap(20,230) end
assert(score==0 and marker(),'endpoint shortcuts rejected')
local function complete()
 local before=score;local steps=0
 while marker() do
  local m=marker(); tickAt(false,true,m.x+9,m.y+9);tickAt(false,false,m.x+9,m.y+9)
  steps=steps+1;assert(steps<250,'unfinishable glyph '..texts.score)
 end
 assert(score==before+1 and texts.score:find('*',1,true),'completed letter scores once')
 for i=1,4 do tap(230,230) end;assert(score==before+1,'no duplicate score')
end
-- Complete every uppercase and lowercase, exercising long curves and multi-stroke letters.
for case=1,2 do
 for i=1,26 do
  assert(texts.score==string.char((case==1 and 64 or 96)+i),'letter order')
  complete();tap(351,387)
 end
 assert(texts.score==(case==1 and 'A' or 'a'),'alphabet wraps')
 tap(233,60)
end
assert(score==52)
-- Repeat resets incomplete or completed progress without deleting the total.
tap(233,387);assert(score==52 and texts.score=='A' and marker())
tap(115,387);assert(texts.score=='Z');tap(351,387);assert(texts.score=='A')
-- Switching case clears current trace; selected case/letter is saved and restored.
tap(233,60);for i=1,6 do tap(351,387) end;assert(texts.score=='g');snapshot('outdoors-g')
objects={};nextid=0;init();tap(233,230);assert(texts.score=='g','selection survives init')
-- Current themes do not need any new host API or shared theme modification.
for name,key in pairs({space='5A7FA8',dinosaurs='8A5A34',unicorns='E88BB8',manga='C03C3C'}) do
 theme=key;objects={};nextid=0;saved='1:u';init();tap(233,230);snapshot(name..'-A');complete()
end
-- Long sessions must not exhaust the host's lifetime handle count.
local handles=nextid
for i=1,300 do tap(351,387);tap(233,387);tap(233,60) end
assert(nextid==handles,'fixed pool must never allocate after init')
-- Malformed persisted data fails safe.
for _,bad in ipairs({'999:u','0:l','1:x','oops'}) do
 saved=bad;objects={};nextid=0;init();tap(233,230);assert(marker())
end
print('PASS: 52 glyph completion, shortcut rejection, score-once, lift/resume, reset, case/letter controls, wrap, persistence, all five themes, integer arguments; peak '..peak..'/512 objects')
