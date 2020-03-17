pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--constants
g = -0.3
move_speed = 2
x_min = 1
x_max = 127 - 8
y_min = 1
y_max = 127 - 8
jump_vel = 5
max_health = 5
invuln_frames = 60
health_gui_x = 2
health_gui_y = 2
health_gui_size = 2
num_start_fruits = 12
fruit_types = 4
max_fruit_speed = 2
fruit_spawn_frames = 90

left = 0
right = 1
up = 2
down = 3

--globals
player = {}
fruits = {}

g_dir = up

frames_alive = 0
game_over = false


function _init()
 initialize_globals()
 initialize_player()
 initialize_fruits()
end

function _update()
 if game_over then
  wait_for_key(5)
 else
  movement_input()
  apply_gravity()
  fruits_fall()
  check_collisions()
  remove_eaten_fruits()
  update_timers()
 end
end

function _draw()
 cls()
 if game_over then
  score = flr(frames_alive / 30)
  print("you survived "..score.." seconds")
  print("press x to restart")
 else
  draw_border()
  draw_health()
  draw_center_arrow()
  draw_fruits()
  draw_player()
 end
end

function wait_for_key(key)
 if btn(key) then
  restart()
 end
end

function restart()
 _init()
end

function initialize_globals()
 frames_alive = 0
 fruits = {}
 g_dir = 3
 game_over = false
end

function initialize_player()
 player.x = x_max / 2
 player.y = y_max
 player.x_vel = 0
 player.y_vel = 0
 player.health = max_health
 player.jumping = true
 player.invuln_timer = 0
end

function initialize_fruits()
 for i=1,num_start_fruits do
  spawn_fruit()
 end
end

function spawn_fruit()
 fruit = {}
 fruit.eaten = false
 fruit.type = flr(rnd(fruit_types))
 fruit.fall_speed = rnd(max_fruit_speed)
 fruit.fall_angle = rnd()

 if g_dir == left then
  entrances = {right, up, down}
 end
 if g_dir == right then
  entrances = {left, up, down}
 end
 if g_dir == up then
  entrances = {left, right, down}
 end
 if g_dir == down then
  entrances = {left, right, up}
 end
 entrance = entrances[flr(rnd(#entrances)) + 1]

 if entrance == left then
  fruit.x = 0
  fruit.y = rnd(y_max)
  fruit.fall_angle = rnd(0.5) - 0.25
 end
 if entrance == right then
  fruit.x = x_max
  fruit.y = rnd(y_max)
  fruit.fall_angle = rnd(0.5) + 0.25
 end
 if entrance == up then
  fruit.x = rnd(x_max)
  fruit.y = 0
  fruit.fall_angle = rnd(0.5)
 end
 if entrance == down then
  fruit.x = rnd(x_max)
  fruit.y = y_max
  fruit.fall_angle = rnd(0.5) + 0.5
 end

 fruits[#fruits + 1] = fruit
end

function update_timers()
 frames_alive = frames_alive + 1
 if frames_alive % fruit_spawn_frames == 0 then
  spawn_fruit()
 end
 if player.invuln_timer > 0 then
  player.invuln_timer = player.invuln_timer - 1
 end
end

function draw_border()
 line(0, 0, 0, 127, 9)
 line(0, 127, 127, 127, 8)
 line(127, 127, 127, 0, 15)
 line(127, 0, 0, 0, 3)
end

function draw_health()
 health_x = health_gui_x
 for i=1,player.health do
  rectfill(health_x, health_gui_y,
           health_x + health_gui_size - 1,
           health_gui_y + health_gui_size - 1, 8)
  health_x = health_x + health_gui_size + 1
 end
end

function draw_center_arrow()
 if g_dir == left then
  spr(32, 64, 64)
 end
 if g_dir == right then
  spr(34, 64, 64)
 end
 if g_dir == up then
  spr(17, 64, 64)
 end
 if g_dir == down then
  spr(49, 64, 64)
 end
end

function draw_fruits()
 for i,v in pairs(fruits) do
  if not v.eaten then
   spr(v.type, v.x, v.y)
  end
 end
end

function draw_player()
 if player.invuln_timer > 0 then
  if flr(player.invuln_timer / 2) % 2 == 0 then
   spr(33, player.x, player.y)
  end
 else
  spr(33, player.x, player.y)
 end
end

function movement_input()
 g_up_down = (g_dir == up) or (g_dir == down)
 if btn(left) and g_up_down then
  player.x_vel = 0
  player.x = player.x - move_speed
 end
 if btn(right) and g_up_down then
  player.x_vel = 0
  player.x = player.x + move_speed
 end
 if btn(up) and not g_up_down then
  player.y_vel = 0
  player.y = player.y - move_speed
 end
 if btn(down) and not g_up_down then
  player.y_vel = 0
  player.y = player.y + move_speed
 end
 if btnp(4) and not player.jumping then
  jump()
 end
end

function jump()
 player.jumping = true
 if g_dir == left then
  player.x_vel = jump_vel
 end
 if g_dir == right then
  player.x_vel = -jump_vel
 end
 if g_dir == up then
  player.y_vel = jump_vel
 end
 if g_dir == down then
  player.y_vel = -jump_vel
 end 
end

function apply_gravity()
 if g_dir == left then
  player.x_vel = player.x_vel + g
 end
 if g_dir == right then
  player.x_vel = player.x_vel - g
 end
 if g_dir == up then
  player.y_vel = player.y_vel + g
 end
 if g_dir == down then
  player.y_vel = player.y_vel - g
 end
 
 player.x = player.x + player.x_vel
 player.y = player.y + player.y_vel
 
 if player.x < x_min then
  player.x = x_min
  player.x_vel = 0
  if g_dir == left then
   player.jumping = false
  end
 end
 if player.x > x_max then
  player.x = x_max
  player.x_vel = 0
  if g_dir == right then
   player.jumping = false
  end
 end
 if player.y < y_min then
  player.y = y_min
  player.y_vel = 0
  if g_dir == up then
   player.jumping = false
  end
 end
 if player.y > y_max then
  player.y = y_max
  player.y_vel = 0
  if g_dir == down then
   player.jumping = false
  end
 end
end

function fruits_fall()
 for i,v in pairs(fruits) do
  oob = v.y > y_max or v.y < 0 or v.x > x_max or v.x < 0
  if oob then
   v.eaten = true
   spawn_fruit()
  else
   v.x = v.x + v.fall_speed * cos(v.fall_angle)
   -- y is inverted since it counts from the top
   v.y = v.y - v.fall_speed * sin(v.fall_angle)
  end
 end
end

function hurt_player()
 if player.invuln_timer == 0 then
  player.health = player.health - 1
  if player.health == 0 then
   die()
  end
  player.invuln_timer = invuln_frames
 end
end

function die()
 game_over = true
end

function check_collisions()
 for i,v in pairs(fruits) do
  if player.invuln_timer == 0 then
   if not v.eaten and collide_with_player(v.x, v.y) then
    eat_fruit(v)
   end
  end
 end
end

function eat_fruit(fruit)
 hurt_player()
 fruit.eaten = true
 if fruit.type <= down then
  g_dir = fruit.type
 end
end

function remove_eaten_fruits()
 new_fruits = {}
 for i,v in pairs(fruits) do
  if not v.eaten then
   new_fruits[#new_fruits + 1] = v
  end
 end
 fruits = new_fruits
end

function intersect(min1, max1, min2, max2)
  return max(min1,max1) > min(min2,max2) and
         min(min1,max1) < max(min2,max2)
end

function collide_with_player(x, y)
 x_intersect = intersect(player.x, player.x+8, x, x+8)
 y_intersect = intersect(player.y, player.y+8, y, y+8)
 return x_intersect and y_intersect
end

__gfx__
00000b0000ffff000033330000bbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000bb00ffffff00333333008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000099bbfff00fff3333333388888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099900ff0000ff3333333388888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900ff0000ff0303303088888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999000fff00fff0003300088888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
099000000ffffff00003300008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9900000000ffff000003300000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000ccaccacc0000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00550000cccccccc0000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555555ccaccacc5555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00550000ccaaaacc0000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000cccccccc0000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
