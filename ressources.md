### Suppression d'element dans un tableau
=> lire le tableau à l'envers pour éviter les décalages
```
for i=#my_table,1,-1 do
  del(my_table,my_value)
 end
```

### Action a effectuer x% du temps
```
if (random(1) > 0.5)
```

### Random element from table
```
element=table[flr(rnd(#table)+1)]
```

### Random between 2 numbers
```
min_val=2
max_val=8
rnd(max_val)+min_val
```

### Debug function
```
function draw_debug()
 if debug then
  print(debug)
 end
end
```
N'importe ou dans le code
=> `debug=maVariableADebugger`


### Map function
```
function mp(v,a,b,c,d)
 local r=(((v-a)*(d-c))/(b-a))+c
 return r
end
```

### Screen shake
```
shake=0
function _draw()
 do_shake()
end

--shake the entire screen
function do_shake()
  local shake_x=rnd(16)-8
  local shake_y=rnd(16)-8
  shake_x*=shake
  shake_y*=shake
  camera(0,shake_y)
  shake=shake*0.91
  if(shake<0.05) then
    shake=0
  end
end
```

### Particule 360
```
angle = random(0,1)
x = sin(angle)
y = cos(angle)
```

### Object constructor and more
https://pico-8.fandom.com/wiki/Setmetatable
