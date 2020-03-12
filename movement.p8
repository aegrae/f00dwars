pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
x = 64
y = 64
x_vel = 0
y_vel = 0
g_dir = 3
g = -0.3

move_speed = 2

x_min = 1
x_max = 127 - 8
y_min = 1
y_max = 127 - 8

t_res = 5
prev_t = 0

jump_vel = 5
jumping = true

function _update()
 gravity_timer()
 movement_input()
 apply_gravity()
end

function _draw()
 cls()
 draw_border()
	draw_center_arrow()
 spr(0,x,y)
end

function draw_center_arrow()
 if g_dir == 0 then
  spr(35, 64, 64)
 end
 if g_dir == 1 then
  spr(37, 64, 64)
 end
 if g_dir == 2 then
  spr(20, 64, 64)
 end
 if g_dir == 3 then
  spr(52, 64, 64)
 end
end

function draw_border()
 line(0, 0, 0, 127, 12)
 line(0, 127, 127, 127, 3)
 line(127, 127, 127, 0, 8)
 line(127, 0, 0, 0, 10)
end

function movement_input()
 g_up_down = (g_dir == 2) or (g_dir == 3)
 if btn(0) and g_up_down then
  x_vel = 0
  x = x - move_speed
 end
 if btn(1) and g_up_down then
  x_vel = 0
  x = x + move_speed
 end
 if btn(2) and not g_up_down then
  y_vel = 0
  y = y - move_speed
 end
 if btn(3) and not g_up_down then
  y_vel = 0
  y = y + move_speed
 end
 if btnp(4) and not jumping then
  jump()
 end
end

function jump()
 jumping = true
 if g_dir == 0 then
  x_vel = jump_vel
 end
 if g_dir == 1 then
  x_vel = -jump_vel
 end
 if g_dir == 2 then
  y_vel = jump_vel
 end
 if g_dir == 3 then
  y_vel = -jump_vel
 end 
end

function gravity_timer()
	if time() % t_res < prev_t then
	 change_gravity(flr(rnd(4)))
	end
	prev_t = time() % t_res
end

function change_gravity(new_g)
 g_dir = new_g
end

function apply_gravity()
 if g_dir == 0 then
  x_vel = x_vel + g
 end
 if g_dir == 1 then
  x_vel = x_vel - g
 end
 if g_dir == 2 then
  y_vel = y_vel + g
 end
 if g_dir == 3 then
  y_vel = y_vel - g
 end
 
 x = x + x_vel
 y = y + y_vel
 
 if x < x_min then
  x = x_min
  x_vel = 0
  if g_dir == 0 then
   jumping = false
  end
 end
 if x > x_max then
  x = x_max
  x_vel = 0
  if g_dir == 1 then
   jumping = false
  end
 end
 if y < y_min then
  y = y_min
  y_vel = 0
  if g_dir == 2 then
   jumping = false
  end
 end
 if y > y_max then
  y = y_max
  y_vel = 0
  if g_dir == 3 then
   jumping = false
  end
 end
end
__gfx__
00000b0000ffff000033330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000bb00ffffff00333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000099bbfff00fff3333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099900ff0000ff3333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900ff0000ff0303303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999000fff00fff0003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
099000000ffffff00003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9900000000ffff000003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
baaaaaaaaaaaaaaaaaaaaaa900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800050000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800550000000000000000550000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000805555555000000005555555000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800550000000000000000550000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800050000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000800000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3333333333333333333333e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0010111111111111120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0030313131313131320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
