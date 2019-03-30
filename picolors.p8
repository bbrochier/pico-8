pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--gameloop

--init
function _init()
 init_colors(colors_en)
 init_title_parts()
end


--update
function _update60()
 t+=1
 if(state=="play") then
  update_play()
  --test smoke
  for i=#smoke_parts,1,-1 do
   update_smoke(smoke_parts[i],i)
  end
 elseif(state=="score") then
  update_score()
 elseif(state=="title") then
  update_title()
 end
end


--draw
function _draw()
 do_shake()
 if(state=="play") then
  draw_play()
  --test smoke
  for i=#smoke_parts,1,-1 do
   draw_smoke(smoke_parts[i])
  end
 elseif(state=="score") then
  draw_score()
 elseif(state=="title") then
  draw_title()
 end
 draw_debug()
end


-->8
--player/cpu/particules

--player
player={
 txt="color name",
 col=8,
 
 update=function(self)
  local i=flr(rnd(#color_names)+1)
  self.txt=color_names[i]
  local j=flr(rnd(#color_names)+1)
  self.col=color_codes[j]
 end,
 
 draw=function(self)
  rectfill(0,109,127,127,self.col)
  for j=0,127,8 do
   spr(2,j,109)
  end
  rectfill(0,117,127,127,self.col)
  print(self.txt,hcenter(self.txt),120,7)
  print("⬅️",3,120,1)
  print("➡️",119,120,1)
 end
}


--cpu
cpu={
 txt="color name",
 col=0,
 lvl=1,
 
 update=function(self)
  local i=flr(rnd(#color_names)+1)
  self.txt=color_names[i]
  local j=flr(rnd(#color_names)+1)
  self.col=color_codes[j]
 end,
 
 draw=function(self)
  for i=1,self.lvl do
  rectfill(0,i*9,127,i*9+9,self.col)
   for j=0,143,8 do
    if(i%2==0) then
     spr(1,j,i*9)
    else
     spr(1,j,i*9,1,1,true)
    end
   end   
  end
  rectfill(0,self.lvl*9,127,self.lvl*9+9,self.col)
  print(self.txt,hcenter(self.txt),self.lvl*9+3,7)
 end,
 
 move_down=function(self)
  shake=1
 	self.lvl+=1
 	t=0
 end
}

--init colors
function init_colors(colors_lang)
 for i in all(color_names) do
  del(color_names, i)
 end
 for j in all(color_codes) do
		del(color_codes, j)
 end
 for k,v in pairs(colors_lang) do
		add(color_names, k)
		add(color_codes, v)
	end
	
	player:update()
	cpu:update()
	check_match()
end

smoke={
 col=7,
 x=80,
 y=80,
 r=0,
 max_r=rnd(8),
 speed=2,
 age=0,
 max_age=rnd(120),
 update=function(self)
  if(self.age<self.max_age) then
   self.age+=1*self.speed
   self.r=mp(self.age,0,self.max_age,0,self.max_r)
  end
 end
}

function add_smoke(x,y)
 local smoke_part={
  col=smoke_parts_col[flr(rnd(#smoke_parts_col)+1)],
  x=x,
  y=y,
  r=0,
  max_r=rnd(6),
  speed=2,
  age=0,
  max_age=rnd(120)
 }
 add(smoke_parts,smoke_part)
end

function update_smoke(s,index)
 s.age+=1*s.speed
 s.r=mp(s.age,0,s.max_age,0,s.max_r)
 if(s.age>=s.max_age) then
  del(smoke_parts,s)
 end
end

function draw_smoke(s)
 if(s.age<s.max_age) then
  circfill(s.x,s.y,s.r,s.col)
 end
end
-->8
--play state

--update
function update_play()
 if btnp(➡️) then
  if (check_match() == true) then
   sfx(4)
   won()
  else
   sfx(3)
   lost()
  end
  player:update()
  cpu:update()
  --smoke
  for i=#smoke_parts,1,-1 do
   update_smoke(smoke_parts[i],i)
  end
 end
 
 if btnp(⬅️) then
  if (check_match() == false) then
   sfx(4)
   won()
  else
   sfx(3)
   lost()
  end
  player:update()
  cpu:update()
 end
 
 if (t>=120) then --2seconds
  sfx(2)
  lost()
 end
end

--draw
function draw_play()
 cls(1)
 draw_status()
 cpu:draw()
 player:draw()
end

--check
function check_match()
  local p=player
  local c=cpu 
  if (
   p.txt == c.txt or 
   p.col == c.col or 
   colors[p.txt] == c.col or 
   colors[c.txt] == p.col
  ) then
    return true
  else
    return false
  end
end

--status
function draw_status()
 rectfill(0,0,127,9,0)
 print(score,3,2,7)
end

--won
function won()
 score+=1
 t=0
end

--lost
function lost()
 cpu:move_down()
 for i=1,100 do
  add_smoke(rnd(10)+122,rnd(10)+cpu.lvl*9+1)
  add_smoke(rnd(10)-4,rnd(10)+cpu.lvl*9+1)
 end
 if(cpu.lvl==12) then
  for i=#smoke_parts,1,-1 do
   del(smoke_parts,smoke_parts[i])
  end
  add(highscores,score)
  state="score"
 end
end

--start
function start_game()
 score=0
 cpu.lvl=1
 t=0
 state="play"
end

-->8
--utilities

--text align center
function hcenter(s)
 return 64-#s*2
end

--debug
function draw_debug()
 if debug then
  print(debug,3,2,7)
 end
end

--map
function mp(v,a,b,c,d)
 local r=(((v-a)*(d-c))/(b-a))+c
 return r
end

--shake the entire screen
function do_shake()
  local shake_x=rnd(10)-5
  local shake_y=rnd(10)-5
  shake_x*=shake
  shake_y*=shake
  camera(0,shake_y)
  shake=shake*0.91
  if(shake<0.5) then
    shake=0
  end
end

--check if value exist in table
function table_contains(t,value)
 for _,v in pairs(t) do
  if(v==value) then
   return true
  end
 end
 return false
end
-->8
--score state

function update_score()
 score_menu:update()
end

function draw_score()
 cls(1)
 
 for i=1,#highscores do
  highscore=max(highscores[i],highscore)
 end
 
 if (score==highscore) then
  print("new high score: "..highscore,30,50,8)
 else
  print("score: "..score,30,30,7)
  print("high score: "..highscore,30,50,10)
 end
 
 score_menu:draw()
 print("⬇️⬆️ ❎",97,120,13)
end

score_menu= {
 x=50,
 y=75,
 txt={"replay","main menu"},
 selected=1,
 update=function(self)
  if btnp(⬆️) then
   sfx(0)
   self.selected=max(1,self.selected-1)
  elseif btnp(⬇️) then
   sfx(0)
   self.selected=min(#self.txt,self.selected+1)
  end
  if btnp(❎) then
   sfx(1)
   if (self.selected==1) then
    start_game()
   end
   if (self.selected==2) then
    state="title"
   end
  end
 end,
 draw=function(self)
  local col=7
  for i=1,#self.txt do
   if(i==self.selected) then
    col=i+10
    col_selected=col
    add_title_parts_col(col)
   else
    col=7
   end
   print(self.txt[i],self.x,self.y+((i-1)*10),col)
   pal(14,col_selected)
   spr(3,self.x-6+sin(time()),self.y+((self.selected-1)*10))
   pal()
  end
 end
}
-->8
--variables

debug=""
shake=0
score=0
highscores={}
highscore=0
state="title"
lang="en"
t=0

colors_fr={
 rouge=8,
 vert=11,
 bleu=12,
 jaune=10,
 orange=9,
 noir=0,
 mauve=13,
 gris=6,
 rose=14,
 brun=4
}

colors_en={
 red=8,
 green=11,
 blue=12,
 yellow=10,
 orange=9,
 black=0,
 purple=13,
 grey=6,
 pink=14,
 brown=4
}

menu_en={
 "start",
 "rules",
 "language",
 "credits"
}

menu_fr={
 "commencer",
 "regles",
 "langue",
 "credits"
}

col_selected=8
title_parts_col={8}
title_parts={}

menu_txt=menu_en
colors=colors_en

color_names={}
color_codes={}

smoke_parts={}
smoke_parts_col={6,7}

menu={
 main=1,
 lang=0,
 rules=0
}
-->8
--title state

function update_title()
 if(menu.main==1) then
  main_menu:update()
 elseif(menu.lang==1) then
  lang_menu:update()
 end
 for i=#title_parts,1,-1 do
  if(title_parts[i].x<0) then
   del(title_parts,title_parts[i])
  end
 end
end

function draw_title()
 cls(1)
 --starfield
 add_title_part()
 for i=1,#title_parts do
  draw_title_part(title_parts[i])
  move_title_part(title_parts[i])
 end
 
 --title
 spr(32,16,20-sin(time()*0.2)*5,6,2)
 spr(38,32,30+sin(time()*0.2)*5,10,2)
 
 --highscore
 if (highscore>0) then
  print("high score: "..highscore,40,58,14)
 end
 
 --menu
 if(menu.main==1) then
  main_menu:draw()
 elseif(menu.lang==1) then
  lang_menu:draw()
 end
 print("⬇️⬆️ ❎",97,120,13)
end

main_menu= {
 x=50,
 y=75,
 txt=menu_txt,
 selected=1,
 update=function(self)
  if btnp(⬆️) then
   sfx(0)
   self.selected=max(1,self.selected-1)
  elseif btnp(⬇️) then
   sfx(0)
   self.selected=min(#self.txt,self.selected+1)
  end
  if btnp(❎) then
   sfx(1)
   if (self.selected==1) then
    start_game()
   elseif (self.selected==2) then
    --rules
   elseif (self.selected==3) then
    menu.lang=1
    menu.main=0
   end
  end
 end,
 draw=function(self)
  local col=7
  for i=1,#self.txt do
   if(i==self.selected) then
    col=i+7
    col_selected=col
    add_title_parts_col(col)
   else
    col=7
   end
   print(self.txt[i],self.x,self.y+((i-1)*10),col)
   pal(14,col_selected)
   spr(3,self.x-6+sin(time()),self.y+((self.selected-1)*10))
   pal()
  end
 end
}

lang_menu= {
 x=50,
 y=75,
 txt={"english","francais"},
 selected=1,
 update=function(self)
  if btnp(⬆️) then
   sfx(0)
   self.selected=max(1,self.selected-1)
  elseif btnp(⬇️) then
   sfx(0)
   self.selected=min(#self.txt,self.selected+1)
  end
  if btnp(❎) then
   sfx(1)
   if (self.selected==1) then
    main_menu.txt=menu_en
    colors=colors_en
    init_colors(colors_en)
    menu.lang=0
    menu.main=1
   end
   if (self.selected==2) then
    main_menu.txt=menu_fr
    colors=colors_fr
    init_colors(colors_fr)
    menu.lang=0
    menu.main=1
   end
  end
 end,
 draw=function(self)
  local col=7
  for i=1,#self.txt do
   if(i==self.selected) then
    col=i+11
    col_selected=col
    add_title_parts_col(col)
   else
    col=7
   end
   print(self.txt[i],self.x,self.y+((i-1)*10),col)
   pal(14,col_selected)
   spr(3,self.x-6+sin(time()),self.y+((self.selected-1)*10))
   pal()
  end
 end
}

--particules
function add_title_part(opt)
 delta=0
 if(opt=="init") then
  delta=0
 else
  delta=128
 end
 local part={
  x=rnd(128)+delta,
  y=rnd(128),
  col=title_parts_col[ceil(rnd(#title_parts_col))]
 }
 add(title_parts,part)
end

function draw_title_part(p)
 pset(p.x,p.y,p.col) 
end

function move_title_part(p)
 p.x-=rnd(1.5)+0.5
end

function init_title_parts()
 for i=1,150 do
  add_title_part("init")
 end
end

function add_title_parts_col(col)
 for i=1,#title_parts_col do
 --add only if col in not in table 
  if(not table_contains(title_parts_col,col)) then
   add(title_parts_col,col)
  end
 end
end
__gfx__
000000000005555011111111e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000055550011111111ee00000000888888888880009999999900000aaaaaaaa00080008888000000000008888888800000888888880000088888888888
007007000555500011111111eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770005555000011111111ee000000888888888888809999999999990aaaaaaaaaaaa088808888000000000888888888888088888888888808888888888888
000770005550000511101111e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700550000551100011100000000888800000000009999000099990aaaa0000aaaa088808888000000000888800008888088880000888808888000000000
00000000500005551000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000055550000000100000000888888888880009999000000000aaaa0000aaaa088808888000000000888800008888088888888888808888888888800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000008888888888809999000000000aaaa0000aaaa088808888000000000888800008888088888888880000088888888888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000888809999000099990aaaa0000aaaa088808888000000000888800008888088880088888800000000008888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000888888888888809999999999990aaaaaaaaaaaa088808888888888880888888888888088880000888808888888888888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000088888888888000009999999900000aaaaaaaa00080000088888888880008888888800088880000888808888888888800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888880009999000aaaaaaa000000bbbbbbbb00000000000aaaaaaa000000bbbbbbbb000cccc00000000000dddddddd00000eeeeeeee00000fffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888888888888099990aaaaaaaaaaaa0bbbbbbbbbbbb0000000aaaaaaaaaaaa0bbbbbbbbbbbb0cccc000000000dddddddddddd0eeeeeeeeeeee0fffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888800008888099990aaaa0000aaaa0bbbb0000bbbb0000000aaaa0000aaaa0bbbb0000bbbb0cccc000000000dddd0000dddd0eeee0000eeee0ffff000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888888888888099990aaaa000000000bbbb0000bbbb0000000aaaa000000000bbbb0000bbbb0cccc000000000dddd0000dddd0eeeeeeeeeeee0fffffffffff00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888888888800099990aaaa000000000bbbb0000bbbb0000000aaaa000000000bbbb0000bbbb0cccc000000000dddd0000dddd0eeeeeeeeee00000fffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888800000000099990aaaa0000aaaa0bbbb0000bbbb0000000aaaa0000aaaa0bbbb0000bbbb0cccc000000000dddd0000dddd0eeee00eeeeee0000000000ffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888800000000099990aaaaaaaaaaaa0bbbbbbbbbbbb0000000aaaaaaaaaaaa0bbbbbbbbbbbb0cccccccccccc0dddddddddddd0eeee0000eeee0fffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88880000000009999000aaaaaaaa00000bbbbbbbb00000000000aaaaaaaa00000bbbbbbbb00000cccccccccc000dddddddd000eeee0000eeee0fffffffffff00
__sfx__
000100002a7502a7502a7402a7402a7302a7302a7202a7201d7001a70018700177001670016700157001570028700097002470007700207001a70005700047001670016700047001570003700037001570002700
000100000375004750047400674007730087300a7200d7200f750117501375016750187501a7501b7501e7502075022750247502675027750287502c7502d7502f75030750327503375036750367503a75033000
001000001a63018620186101561018600186001560000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
011000000b4700b4700b4501a63018620186101561000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
0004000024550285502a5502c5502e5502f5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344

