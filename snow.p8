stars = {}
nbstars = 250

function _init()
  for i=1,nbstars do
    addstar(i)
  end
  debug=sin(45)
end

function _update60()
  for i=1,#stars do
    movestar(stars[i])
  end
end

function _draw()
  cls(0)
  for i=1,#stars do
    drawstar(stars[i])
  end
  draw_debug()
end

function addstar(i)
 if(rnd(1)>0.5) then
  orient=-1
 else
  orient=1
 end
 local s={
  i=i,
  x=rnd(128),
  y=rnd(128),
  z=flr(rnd(2)),
  angle = rnd(0.04)*orient
 }
 add(stars,s)
end

function drawstar(s)
 thick=mp(s.z,0,2,1,3)
 circfill(s.x,s.y,s.z)
end

function movestar(s)
 speed = mp(s.z,0,2,0.5,1) 
 s.y+=speed
 s.x+=speed*tan(s.angle)
 if (s.x<0) then
  s.x = 128
 end
 if (s.x>128) then
  s.x = 0
 end
 if (s.y>128) then
  s.y=-rnd(100)
  s.x=rnd(128)
  if(rnd(1)>0.5) then
   orient=-1
  else
   orient=1
  end
  s.angle=rnd(0.04)*orient
 end
end

function mp(v,a,b,c,d)
 local r=(((v-a)*(d-c))/(b-a))+c
 return r
end

function tan(a)
 return sin(a)/cos(a)
end

function draw_debug()
 if debug then
  print(debug)
 end
end
