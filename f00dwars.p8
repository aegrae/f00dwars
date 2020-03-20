pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- f00dwars
-- by davis, ashlae, ifenna

--constants
g = -0.3
f_coeff = 0.85
move_speed = 2
x_min = 1
x_max = 127 - 8
y_min = 1
y_max = 127 - 8
jump_vel = 5
max_health = 5
invuln_frames = 60
heal_frames = 300
health_gui_x = 2
health_gui_y = 2
health_gui_size = 2
num_start_fruits = 30
fruit_types = 4
max_fruit_speed = 2
fruit_spawn_frames = 90

left = 0
right = 1
up = 2
down = 3

title = 0
game = 1
game_over = 2

scene = title

--globals
players = {}
fruits = {}

g_dir = down

n_players = 1
n_alive = 1
winner_number = 0

frames_alive = 0


function _init()
 music(0)
 go_to_main_menu()
end

function _update()
 if scene == title then
  choose_mode()
 elseif scene == game_over then
  wait_for_key(5, winner_number)
 elseif scene == game then
  movement_inputs()
  apply_gravity()
  fruits_fall()
  check_collisions()
  remove_eaten_fruits()
  update_timers()
 end
end

function _draw()
 cls()
 if scene == title then
  draw_mode_select()
 elseif scene == game_over then
  draw_game_over()
 elseif scene == game then
  draw_border()
  draw_center_arrow()
  draw_fruits()
  draw_players()
  draw_health()
 end
end

function choose_mode()
 if btnp_any(up) then
  n_players = max(n_players - 1, 1)
 end
 if btnp_any(down) then
  n_players = min(n_players + 1, 4)
 end
 if btnp_any(5) then
  start_game()
 end
end

function btnp_any(b)
 return btnp(b, 0) or btnp(b, 1) or btnp(b, 2) or btnp(b, 3)
end

function draw_mode_select()
 draw_border()
 print("f00dwars", 48, 16, 7)
 print("choose mode", 42, 24)
 print("(press x to select)", 26, 32)
 print("1 player", 48, 60)
 print("2 player", 48, 68)
 print("3 player", 48, 76)
 print("4 player", 48, 84)
 print(">", 40, 52 + 8 * n_players)
end

function draw_game_over()
 draw_border()
 if n_players == 1 then
  score = flr(frames_alive / 30)
  print("you survived "..score.." seconds", 16, 16, 7)
 else
  print("congratulations!", 32, 16, 7)
  spr(players[winner_number + 1].sprite, 60, 60)
 end
 print("press x to restart", 28, 24)
end

function wait_for_key(key, player)
 if btnp(key, player) or btnp(key, 0) then
  go_to_main_menu()
 end
end

function go_to_main_menu()
 scene = title
end

function start_game()
 scene = game
 initialize_globals()
 initialize_players()
 initialize_fruits()
end

function initialize_globals()
 frames_alive = 0
 n_alive = n_players
 fruits = {}
 g_dir = down
end

function initialize_players()
 players = {}
 for i=1,n_players do
  player = {}
  player.alive = true
  player.x = i * x_max / (n_players + 1)
  player.y = y_max
  player.x_vel = 0
  player.y_vel = 0
  player.health = max_health
  player.jumping = false
  player.grounded = false
  player.invuln_timer = 0
  player.heal_timer = 0
  player.number = i - 1
  player.sprite = 19 + player.number
  players[#players + 1] = player
 end
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

function heal(player)
 player.health = player.health + 1
 player.heal_timer = 0
end

function update_timers()
 frames_alive = frames_alive + 1
 if frames_alive % fruit_spawn_frames == 0 then
  spawn_fruit()
 end
 for i, player in pairs(players) do
  if player.alive then
   if player.invuln_timer > 0 then
    player.invuln_timer = player.invuln_timer - 1
   end
   if player.health < max_health then
    player.heal_timer = player.heal_timer + 1
    if player.heal_timer == heal_frames then
     heal(player)
    end
   end
  end
 end
end

function draw_border()
 line(0, 0, 0, 127, 9)
 line(0, 127, 127, 127, 8)
 line(127, 127, 127, 0, 15)
 line(127, 0, 0, 0, 3)
end

function draw_health()
 draw_player_health(health_gui_x, health_gui_y, players[1], 12)
 right_x = x_max + 8 - health_gui_x - max_health * (health_gui_size + 1)
 bottom_y = y_max + 9 - health_gui_y - health_gui_size
 if n_players >= 2 then
  draw_player_health(right_x, health_gui_y, players[2], 11)
 end
 if n_players >= 3 then
  draw_player_health(health_gui_x, bottom_y, players[3], 14)
 end
 if n_players == 4 then
  draw_player_health(right_x, bottom_y, players[4], 10)
 end
end

function draw_player_health(x, y, player, color)
 for i=1,player.health do
  rectfill(x, y, x + health_gui_size - 1,
           y + health_gui_size - 1, color)
  x = x + health_gui_size + 1
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

function draw_players()
 for i, player in pairs(players) do
  if player.alive then
   draw_player(player)
  end
 end
end

function draw_player(player)
 damage_sprite = 35 + flr(player.heal_timer / heal_frames * 9)
 if player.invuln_timer > 0 then
  if flr(player.invuln_timer / 2) % 2 == 0 then
   spr(player.sprite, player.x, player.y)
   spr(damage_sprite, player.x, player.y)
  end
 else
  spr(player.sprite, player.x, player.y)
  spr(damage_sprite, player.x, player.y)
 end
end

function movement_inputs()
 for i, player in pairs(players) do
  if player.alive then
   movement_input(player)
  end
 end
end

function movement_input(player)
 g_up_down = (g_dir == up) or (g_dir == down)
 if btn(left, player.number) and g_up_down then
  player.x_vel = 0
  player.x = player.x - move_speed
 end
 if btn(right, player.number) and g_up_down then
  player.x_vel = 0
  player.x = player.x + move_speed
 end
 if btn(up, player.number) and not g_up_down then
  player.y_vel = 0
  player.y = player.y - move_speed
 end
 if btn(down, player.number) and not g_up_down then
  player.y_vel = 0
  player.y = player.y + move_speed
 end
 if player.jumping and not btn(4, player.number) then
  cut_jump(player)
 end
 if btnp(4, player.number) and player.grounded then
  jump(player)
 end
end

function jump(player)
 player.jumping = true
 player.grounded = false
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

function cut_jump(player)
 if g_dir == left and player.x_vel > 0 then
  player.x_vel = 0
 end
 if g_dir == right and player.x_vel < 0 then
  player.x_vel = 0
 end
 if g_dir == up and player.y_vel > 0 then
  player.y_vel = 0
 end
 if g_dir == down and player.y_vel < 0 then
  player.y_vel = 0
 end 
end

function apply_gravity()
 for i, player in pairs(players) do
  if player.alive then
   apply_gravity_to_player(player)
  end
 end
end

function apply_gravity_to_player(player)
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
   land(player)
  end
 end
 if player.x > x_max then
  player.x = x_max
  player.x_vel = 0
  if g_dir == right then
   land(player)
  end
 end
 if player.y < y_min then
  player.y = y_min
  player.y_vel = 0
  if g_dir == up then
   land(player)
  end
 end
 if player.y > y_max then
  player.y = y_max
  player.y_vel = 0
  if g_dir == down then
   land(player)
  end
 end
end

function land(player)
 player.grounded = true
 player.jumping = false
 -- friction
 player.x_vel = player.x_vel * f_coeff
 player.y_vel = player.y_vel * f_coeff
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

function hurt_player(player)
 if player.invuln_timer == 0 then
  player.health = player.health - 1
  if player.health == 0 then
   die(player)
  end
  all_players_invuln()
 end
end

function all_players_invuln()
 for i, player in pairs(players) do
  if player.alive then
   player.invuln_timer = invuln_frames
  end
 end
end

function die(player)
 player.alive = false
 n_alive = n_alive - 1
 if n_alive <= 1 then
  choose_winner()
  scene = game_over
 end
end

function choose_winner()
 for i, player in pairs(players) do
  if player.alive then
   winner_number = player.number
  end
 end
end

function check_collisions()
 for i, player in pairs(players) do
  if player.alive then
   check_collisions_for_player(player)
  end
 end
end

function check_collisions_for_player(player)
 for i,v in pairs(fruits) do
  if player.invuln_timer == 0 then
   if not v.eaten and collide_with_player(v.x, v.y, player) then
    eat_fruit(v, player)
   end
  end
 end
end

function eat_fruit(fruit, player)
 hurt_player(player)
 fruit.eaten = true
 if fruit.type <= down then
  g_dir = fruit.type
  all_players_airborn()
 end
end

function all_players_airborn()
 for i, player in pairs(players) do
  if player.alive then
   player.grounded = false
  end
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

function collide_with_player(x, y, player)
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
0000000000000000000000000cccccc00bbbbbb00eeeeee00aaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000
000000000005000000000000ccccccccbbbbbbbbeeeeeeeeaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000
000000000055500000000000ccaccaccbb7bb7bbeefeefeeaa1aa1aa000000000000000000000000000000000000000000000000000000000000000000000000
000000000555550000000000ccccccccbbbbbbbbeeeeeeeeaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000
000000000005000000000000ccaccaccbb7bb7bbeefeefeeaa1aa1aa000000000000000000000000000000000000000000000000000000000000000000000000
000000000005000000000000ccaaaaccbb7777bbeeffffeeaa1111aa000000000000000000000000000000000000000000000000000000000000000000000000
000000000005000000000000ccccccccbbbbbbbbeeeeeeeeaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000
0000000000050000000000000cccccc00bbbbbb00eeeeee00aaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000800000008800000088800000888800008888800088888800888888000000000000000000000000000000000
00000000000000000000000000000000800000008800000088800000888800008888800088888800888888808888888800000000000000000000000000000000
00050000000000000000500000000000800000008800000088000000880800008808800088088000880880808808808800000000000000000000000000000000
00550000000000000000550000000000800000008800000088800000888800008888800088888800888888808888888800000000000000000000000000000000
05555555000000005555555000000000800000008800000088000000880800008808800088088000880880808808808800000000000000000000000000000000
00550000000000000000550000000000800000008800000088000000880000008800000088000000880000808800008800000000000000000000000000000000
00050000000000000000500000000000800000008800000088800000888800008888800088888800888888808888888800000000000000000000000000000000
00000000000000000000000000000000000000000800000008800000088800000888800008888800088888800888888000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
333333333333333333333333333333333333bbbb333333333333333333333333333333333333333333333333333333333333333333ffff333333333333333333
90000000000000000ffff000000000000008888880000000000000000000000000000000000000000000000000000000000000000ffffff0000000000000000f
908808808808ffffffffff00000000000088888888b0000003333000000000000000000000000000000000000000000000000000fff00fff000000000000000f
90880880880fffffff00fff0000000000088888888bb000033333300000000000000000000000000000000000000000000000000ff0000bbbb0000000000000f
9000033330fff00fff000ff00000000000888888889bb00bbbb33330000000000000000000000000000000000000000000000000ff000888888000000000000f
9000333333ff000fff000ff0000000000088888888900088888833300000000000000333300000000000000000000000b0000000fff08888888800003333000f
9003333333ff000fff00fff0000000000008888333300888888883330000000000003333330000000000000000000000bb0000000fff8888888800033333300f
9003333333fff00fffffff000000000000008833333308888888833300000000000333333330000000000000000000099bb0000000ff8888888800333333330f
90003033030ffffffffff00000000000000003333333388888888f3000000000000333333330000000000000000000999000000000008888888800333333330f
900000330000ffff0000000000000000000003333333388888888ff0000000000b0030330300000000000000000009999000000000000888888000030330300f
90000033000000000000000000000000000033333333008888883ff0000000000bb000330000000000000000000099990000000000000988880000000330000f
900000330000000000000000000000000000333333330008888ffff00000000099bb00330000000000000000b00099000000000000009990000000000330000f
9000000000000000000bbbb000000000000003033330000ffffffff000000009990000330000000000000000bb09900000000000000bbbbbbb0000000330000f
900000000000000000888888000000000000000333000008ffffffff000000999900000000000000000000099bb000000000000000888888888000000000000f
900000033330000008888888800000333300000330000008fffff8ff00000999900000000000000000000099900000003333000008888888888800000000000f
900000333333000008888888800003333330000330000008ff8888ff0000099000000000000000000000099990000003333330000888888888880000bbbb000f
900003333333300008888888800033333333000000000008fff88fff00009900000000000000000000009999000000333333330008888888888800088888800f
9000033333333000088888888000333333330000000000008ffffff000000000000000000000000000009900000000333333330008888888888800888888880f
90000030330300000088888800000303303000000000000008ffff0000000000000000000000000000099000000000030330300000888888888000888888880f
9000000033000000000888800000000330000000000000000000000000000000000000000000000000000000000000000330000000088888880000888888880f
9000000033000000000000000000000330000000000000000000000000000000000000000000000000000000000000000330000000000000000000888888880f
9000000033000000000000000000000330000000000000000000000000000000000000000000000000000000000000000330000000000000000000088888800f
9000000000000000000000000000000bbbb0000000000000000000000000000000000000000000000000000000000ffff000000000000000000000008888000f
900ffff0000000000003333000000088888800000000000000000000000000000000000ffff0000000ffff000000ffffff00000000000000000000000000000f
90ffffffbbbb0000003333330000088888888000000000000000000000000000000000ffffff00000ffffff0000fff00fff000000000000000000000ffff000f
9fff00fff8888000033333333000088888888000000ffff0000000000000000000000fff00fff000fff00fff000ff0000ff00000000000000000000ffffff00f
9ff0008ff88888f003333333300008888888800000ffffff000000000000000000000ff0000ff000ff0000ff000ff0033ff00000000000000000b0fff00fff0f
9ff0008ff88888ff0030330300000888888880000fff00fff00000000000000000000ff0000ff000ff0000ff000fff33fff30000000000000000bbff0000ff0f
9fff00fff88888fff000330000000088888800000ff0000ff00000000000000000000fff00fff000fff00fff0bbbffffff3330000000000000099bbf0000ff0f
90ffffff8888880ff000330000000008888000000ff000033330000000000000000000ffffff00000ffffff088888ffff333300000000000009990fff00fff0f
900ffff88888b00ff00933b000000000000000000fff003333330000000000000000000ffff0000000ffff088888888033030333300000333999900ffffff00f
900000008888bbfff0999000000000000000000000fff333333330000000000000000000000000000000000888888880330033333300033399990000ffff000f
9000000000f99bbf099990000000000000000000000ff3333333300000000000000000000000000000000008888888803303333333303333993300000000000f
9000000000999ff0999900000000000000000000000000303303000000000000000000000000000000000008888888803303333333303339933300000000000f
9000000009999000990000000000000000000000000000003300000000000000000000000000000000000000888888000000303303000303303000000000000f
9000000099990009900000000000000000000000000000003300000000000000000000000000000000000000088880000000003300000003300000000000000f
9000000099333300000000000000000000000000000000003300000000000000000000000000000000000000000000000000003300000003300000000000000f
9000000993333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000003300000003300000000000000f
9000000033333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
90000000333333330000000000000000000000000000000000000ffff0000000000000000000000000000000000000000000000000000000000000000000000f
9000ffff03033030000000000000000000000000000000000000ffffff000000000000000000000000000000000000000000000000000000000000000000000f
900ffffff033330000000000000000000000000000000000000fff00fff0000000000000000000000000000000000000000000000000000000000000ffff000f
90fff00ff333333033330000000000000000000000000000000ff0000ff000000000000000000000000000000000000000000000000000000000000ffffff00f
90ff00003333333333333000000000000000000000000000000ff0000ff00000000000000000000000000000000000000000000000000000000000fff00fff0f
90ff00003333333333333300000000000000000000000000000fff00fff00000000000000000000000000000000000000000000000000000000000ff0000ff0f
90fff00ff303303333333300000000000000000b000000000000ffffff000000000000000000000000000000000000000000000000000000000000ff0000ff0f
900ffffffff3300303303000000000000000000bb000000000000ffff0000000000000000000000000000000000000000000000000000000000000fff00fff0f
9000fffffff33f00033000000000000000000099bb00000000000000000000000000000000000000000000000000000000000000000000000000000ffffff00f
9000000fff033ff00330000000000000000009990000000000000000000000000000ffff00000000000000000000000000000000000ffff000000000ffff000f
9000000ff0000ff0033000000000000000009999b00000000000000000000000000ffffff000000000000000000000000000000000fffbff000000000000000f
9000000ff0000ff000000000000b000000099990bb00000000000000000bbbb000fff00fff00000000000000000000000000000b0fff0bbff00000000000000f
9000000fff00fff000000000000bb000000990099bb00000000000000088888800ff0000ff00000000000000000000000000000bbff099bbf00000000000000f
90000000ffffff00000000000099bb000099009990000000000000000888888880ff0000ff000000000000000000000000000099bbf9990ff00000000000000f
900000000ffff00000000000099900000000099990000000000000000888888880fff00fff00000000000000ffff0000000009990f9999fff00000000000000f
9000000000000000000000009999000000009999000000000000000008888888800ffffff00000000000000ffffff0000000999909999fff000000000000000f
90000000000000000000000999900000000099000000000000000000088888888000ffff00000000000000fff00fff0000099990099ffff0000000000000000f
90000000000000000000000990000000000990000000000000000000008888880000000000000000000000ff0000ff00000990009900000000000000bbbb000f
900000000000000000000099000000000000000000000000b0000000000888800000000000000000000000ff0000ff000099000000000000000000088888800f
900000000000000000000000b00000000000000000000000bb000000000000000000000000000000000000fff00fff000000000000000000000000888888880f
9000000b0000000000000000bb00000000000000000000099bb0ffff0000000000000000003333000000000ffffff0000000ffff00000000000000888888880f
9000000bb0000000000000099bb000000000000000000099900ffffff00000000000000bbbb3333000000000ffff0000000ffffff0000000000000888888880f
90000099bb0000000000009990000000000000000000099990fff00fff0000000000008888883333000000000000000000fffbbfff000000000000888888880f
90000999000000000000099990000000000000000000999900ff0000ff0000000000088888888333000000000000000000ff9000ff0000000000000b8888800f
90009999000000000000999988000000000000000000990000ff0000ff0000000000088888888030000000000000000009ff9000ff0000000000000bb888000f
90099990000000000008998888800000000000000009900000fff00fff0000000000088888888000000000000000000099fff00fff00000000000099bb00000f
90099000bbbb000000099888888000000000000000000000000ffffff000000000000888888880000000000000000000990ffffff0000000000009990000000f
9099000888888000000888888880000000000000000000000000ffff00000000000050888888300000000000000000099000ffff00000000000099990000000f
900000888888880000088888888000000ffff000000000000000000000000000000055088880000000000000000000000000000000000000000999900000000f
90000088888888000000888888000000ffffff00000000000000000000b00000555555500000000000000000000000000000000000000000000bbbb00000000f
90000088888bbbb0000008888000000fff00fff0000000000000000000bb0000000055000000000000000000000000000000000000000000008888880000000f
9000008888888888000000000000000ff0000ff00000000000000000099bb000000050000000000000000000000000000000000000000000088888888000000f
9000000888888888800000000000000ff0000ff0000000000000000099900000000000000000000000000000000000000000000000000000088888888000000f
9000000088888888800000000000000fff00fff0000000000000000999900000000000000000000000000000000000000000000000000000088888888000000f
90000000088888888000000000000000ffffff00000000000000009999000000000000000000000000000000000000000000000000000000088888888000000f
900000000888888880000000000000000ffff000000000000000009900000000000000000000000000000000000000000000000000000000008888880000000f
90000000008888880000000000000000000000000000000000000990000000000000000000000000000000000ffff0000000000000000000000888800000000f
9000000000088880000000000000000000000000000000000000000000000000000000000000000000000000ffffff000000000000000000000000000000000f
900000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff00fff00000000000000000000000000000000f
900000000000000000000000000000000000000003333000000000000000000000000000000000000000000ff0000ff00000000000000000000000000000000f
900000000000000000000000000000000000000033333300000000000000000000000000000000000000000ff0000ff00000000000000000000000000000000f
90000000000bbbb000000000000000000000000333333330000000000000000000000000000000000000000fff00fff00000000000000000000000000000000f
9000000000888888000000000000000000000003333333300000000000000000000000000000000000000000ffffff000000000000000000000000000000000f
90000000088888888000000000000000000000003033030000000000000000000000000000000000000000000ffff0000000000000000000000000000000000f
9000000008888888800000000000000000000000003300000000000000000000000000000000000033330000000000000000000000000000000000000000000f
9000000008888888830000000000000000000000003300000000000000000000000000000000000333333000000000000000000000000000000000000000000f
9000000008888888833000000000000000000000003300000000000000000000000000000000003333333300000000000000000000000000000000000000000f
9000000000888888333000000000000000000000000000000000000000000000000000000000003333333300000000000000000000000000000000000000000f
9000000000088883030000000000000000000000000000000000000000000000000000000000099303303000000000000000000000000000000000000000000f
900000b000000033000000000000000000000000000000000000000000000000000000000000999903300000000000000000000000000000000000000000000f
900000bb00000033000000000000000000000000000000000000000000000000000000000009999003300000000333300000000000000000000000000000000f
900009ffff000033000000000000000000000000000000000000000000000000000000000009900003300000003333330000000000000000000000000000000f
90009ffffff00000000000000000000000000000000000000000000000000000000000000099000000000000033333333000000000000000000000000000000f
9009fff00fff000000000000000000000000000000000000000000000000000000000000000000000000000003333333300000000000000b000000000000000f
9099ff0000ff0000000000000000000000000b000000000000000000ffff000000000000000000000000000000303303000000000000000bb00000000000000f
9099ffb000ff0000000000000000000000000bb0000000000000000ffffff0000000000000000000000000000000330000000000b0000099bb0000000000000f
9990fffb0fff00000000000000000000000099bb00000000000000fff00fff000000000000000000000000000000330000000000bb000999000000000000000f
90099ffffff000000000000000000000000999bb00000000000000ff0000ff0000000000000000000000000000003300000000099bb09999000000000000000f
909999ffff00000000bbbb33000000000099999bb0000000000000ff0000ff00000000000000000000000000000000000000009990099990000000000000000f
999990000000ffff08888883300000000999999000000000000000fff00fff00000000000000000000000000000000000000099990099000000000000000000f
99900000000fffff88888888330000000999999b000000000000000ffffff000000000000000000000000000000000000000999fff990000000000000000000f
99ffff0000fff00f88888888330000009999990bb000000000000000ffff000000000000000000000000000000000000000099fbbbbf0000000000000000000f
9ffffff000ff0000888888883000000000990099bb00000000000000000000000000000000000000000000000000000000099f888888f000000000000000000f
fff00fff00ff0000888888880000000009900999000000000000000000000000000000000000000000000000000000000000088888888000000000000000000f
ff0000ff00fff00ff8888880000000000000999900000000000000000000000000333300000000000000000000000000000bb88888888000000000000000000f
ff0000ff000ffffff08888b00000000000099990000000000000000000000000033333300000000000000000000000000088888888888000000000333300000f
fff00fff0000ffff000099bb0000000000099000000000000000000000000000333333330000000000000000000000000888888888888000000003333330000f
9ffffff000000000000999000000000000990000000000000000000000000000333333330000000000000000000000000888888888880000000033bbbb33000f
90ffff0000000000009999000000000000000000000000000000000000000000030330300000000000000000000000000888888888800000000038888883000f
9000000000000000099990000000000000000000000000000000000000000000000330000000000000000000000000000888888880000000000088888888000f
9000000000000000099000000000000000000000000000000000000000000000000330000000000000000000000000000088888800000000000088888888000f
90000000000000009900000000000000000000000000000000000000000000000003300000000000000000000ffff0000008888000000000000088888888000f
9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffff00000bb00000000000000088888888000f
900000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff00fff00099bffff00000000000f8888880000f
900000000000000000000000000000000000000000000000000000000000000000000000000000000000000fbbbb0ff00999ffffff000000000fff888800000f
900000000000000000000000000000000000000000000000000000000000000000000000000000000000000888888ff0999fff00fff00bbbb0fff00fff00000f
9000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb00088888888f9999ff0000ff0888888ff0000ff00000f
90000000000000000000000000000000000000000000b000000000000000000000000000000000888888008888888809900ff0000ff88888888f0000ff00000f
9000000000ffff000000000000000000000003333000bb00000000000000b000000ffff0000008888888808888888899000fff00fff88888888ff00fff00000f
900000000ffffff000000000000000000bbb333333099bb0000000000bbbbb0000ffffff0000088888888088888888000000ffffff088888888ffffff000000f
90000000fff00fff0000000000000000888333333339900000000000888888b00fff00fff0000888888880088888800000000ffff00888888880ffffcccccc0f
90000000ff0000ff0000000000000008888333333339900000000008888888800ff0000ff00008888888800088880000000000000000888888000008cccccccf
90000000ff0000ff0000000000000008888838339399000000000008888888800ff0000ff00000888888000000000000000000000000088880000008caccaccf
90000000fff00fff0000000000000008888888339900000000000008888888800fff00fff00000088880000000000000000000000000000000000008cccccccf
900000000ffffff000000000000000088888883390000000000000088888888000ffffff000000000000000000000000000000000000000000000008caccaccf
9000000000ffff00000000000000000088888833000000000000000988888800000ffff0000000000000000000000000000000000000000000000008caaaaccf
900000000000000000000000000000000888800000000000000000000888800000000000000000000000000000000000000000000000000000000008cccccccf
900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc0f
8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888f

__sfx__
011000000c32010310133400c32010310143400c3201031014340133301434013320143301333010320133300c32010310133400c32010310143400c32010310183300c331243300c33100000183300000018330
011000000c32010310133400c32010310143400c3201031014340133301434013320143301333010320133300c32010310133400c32010310143400c32010310183300c33124300243300c33118300303300c331
011000000c32010310133400c32010310143400c3201031014340133301434013320143301333010320133300c32010310133400c32010310143400c3201031024430184300c4301843024430184310c43100400
01100000245501855000000185502255022500185502055020500185501f5501e5001f5501d5501b5501955018552185521855218552185521855218552185520000000000000000000030052300523005230052
01100000245501855000000185502255022500185502055020500185501f5501e5001f5501d5501b5501955018552185521855218552185521855218552185520c5501b5501e5502155025550300003000030000
011000200c053216033c10024603246350c0033c700000030c053000030000324600246350000300003000030c053000030000300003246350000300003000030c05300003000030000324635000030000300003
011000200c0530c7003c1253c015246350c0033c125000030c053000033c1253c015246350000300003000030c053000033c1003c000246350000300003000030c05300003000030000324635000033c1003c000
011000000c7500d7510e7510f751107511175112751137511475115751167511775118751197511a7511b7511c7511d7511e7511f751207512175122751237512475125751267512775128751297512a7512b751
__music__
01 00424305
00 01424305
00 00424305
00 02424305
00 03424306
00 03424306
00 03474306
02 04474306

