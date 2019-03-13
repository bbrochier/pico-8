suppression d'element dans un tableau
=> lire le tableau à l'envers pour éviter les décalages

RANDOM STUFF
action a effectuer x% du temps
=> if (random(1) > 0.5)

random element from table
element=table[flr(rnd(#table)+1)]


pico8 debug function

function draw_debug()
 if debug then
  print(debug)
 end
end

n'importe ou dans le code
=> debug=#myarray

====================
 MAP function pico8
====================
function mp(v,a,b,c,d)
 local r=(((v-a)*(d-c))/(b-a))+c
 return r
end


====================
particule 360

angle = random(0,1)
x = sin(angle)
y = cos(angle)


Object constructor and more
https://pico-8.fandom.com/wiki/Setmetatable
