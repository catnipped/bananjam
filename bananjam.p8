pico-8 cartridge // http://www.pico-8.com
version 8
__lua__

timers = {}

function timer_start(id, time)
   timers[id] = { t = time }
end

function timer_check(id)
   return timers[id].t <= 0
end

function timers_tick()
   for timer in all(timers) do
      if timer.t > 0 then
         timer.t -= 0.01666666
      else
         timer.t = 0
      end
   end
end

function timers_clear()
   timers = {}
end

function enemy_base(x, y)
   local enemy = {}
   add(enemies, enemy)
   enemy.x = x
   enemy.y = y
   enemy.w = 1
   enemy.h = 1
   enemy.polarity = false
   enemy.movement = 0
   enemy.shotpattern = 0
   enemy.score = 1
   enemy.gunoffset = { x = 0, y = 0 }
   return enemy
end

function create_enemy_simple(x, y)
   local enemy = enemy_base(x, y)
   enemy.hp = 25
   enemy.sprite = 32
   enemy.speed = 0.5 + (progress * 0.02)
   return enemy
end

function create_enemy_grunt(x, y)
   local enemy = enemy_base(x, y)
   enemy.hp = 70
   enemy.sprite = 64
   enemy.movement = 1
   enemy.shotpattern = 3
   return enemy
end

function create_enemy_destroyer(x, y)
   local enemy = enemy_base(x, y)
   enemy.hp = 250
   enemy.sprite = 96
   enemy.movement = 2
   enemy.w = 2
   enemy.h = 2
   enemy.shotpattern = 2
   enemy.polarity = false
   return enemy
end

function create_enemy_peeper(x, y)
   local enemy = enemy_base(x, y)
   enemy.hp = 70
   enemy.sprite = 67
   enemy.movement = 3
   enemy.state = 0
   enemy.shotpattern = 1
   enemy.flip = true
   return enemy
end

function create_enemy_longship(x, y)
   local enemy = enemy_base(x, y)
   enemy.hp = 300
   enemy.sprite = 68
   enemy.movement = 2
   enemy.shotpattern = 4
   enemy.w = 1
   enemy.h = 4
   if rnd(100) > 50 then
      enemy.polarity = true
   end
   return enemy
end

function create_enemy_stone(x, y)
   local enemy = enemy_base(x, y)
   enemy.hp = 180
   enemy.sprite = 69
   enemy.movement = 1
   enemy.shotpattern = 5
   enemy.w = 2
   enemy.h = 2
   enemy.gunoffset.y = -4
   if rnd(100) > 50 then
      enemy.polarity = true
   end
   return enemy
end

function create_enemy_banana(x, y)
   local enemy = enemy_base(x, y)
   enemy.hp = 2000
   enemy.sprite = 71
   enemy.movement = 4
   enemy.shotpattern = 6
   enemy.w = 4
   enemy.h = 4
   enemy.gunoffset.y = -30
   return enemy
end

function create_enemy_bomber(x, y)
   local enemy = enemy_base(x, y)
   enemy.hp = 100
   enemy.sprite = 66
   enemy.movement = 5
   enemy.shotpattern = 7
   enemy.w = 1
   enemy.h = 1
   enemy.charging = true
   return enemy
end

function update_enemy(e)
   if e.movement == 0 then
      -- move back and forth across the whole screen
      if e.polarity == false then e.x += e.speed
      elseif e.polarity == true then e.x -= e.speed end
      if e.x > 100 then e.polarity = true
      elseif e.x < 15 then e.polarity = false end
      e.y += 0.35
   elseif e.movement == 1 then
      -- move like a snake
      e.x += sin(e.y / 50) * 0.5
      e.y += 0.5
   elseif e.movement == 2 then
      -- move down, then out to the side
      if e.y < 50 then
         e.y += 0.15
      elseif e.x < 64 then
         e.polarity = true
         e.x -= 1
      else
         e.polarity = true
         e.x += 1
      end
   elseif e.movement == 3 then
      -- move down, then up, repeat
      if e.state == 0 then
         e.polarity = true
         e.y += 0.25
         if e.y > 64 then
            e.state = 1
         end
      else
         e.polarity = false
         e.y -= 0.25
         if e.y < 0 then
            e.state = 0
         end
      end
   elseif e.movement == 4 then
      -- boss movement
      if e.y < 50 then
         e.y += 0.1
      end
   elseif e.movement == 5 then
      -- bomber movement
      if e.charging then
         e.y += 2
         if e.y > 50 then
            e.charging = false
         end
      else
         if e.polarity then
            e.x += cos(frames * 0.01)
            e.y += sin(frames * 0.01)
         else
            if e.y > 20 then
               e.y -= 0.5
            else
               e.charging = true
            end
         end
      end
   end
   
   gun_x = e.x + e.w * 4 + e.gunoffset.x
   gun_y = e.y + e.h * 8 + e.gunoffset.y

   if e.shotpattern == 0 then
      -- simple shots going downwards
      if every(50) then
         add_e_projectile(gun_x, gun_y, e.polarity, 0, rnd(0.3) + 0.8)
      end
   elseif e.shotpattern == 1 then
      -- shot every second shot on/off in a diagonal line
      if every(40) then
         if e.x > 64 then
            dir = 0.15
         else
            dir = -0.15
         end
         e.flip = not e.flip
         add_e_projectile(gun_x, gun_y, e.flip, dir)
      end
   elseif e.shotpattern == 2 then
      -- bursts of three shots in a triangle shape
      if every(60) then
         add_e_projectile(gun_x, gun_y, not e.polarity, 0, 1.0)
         add_e_projectile(gun_x, gun_y, e.polarity, 0.05, 0.8)
         add_e_projectile(gun_x, gun_y, e.polarity, -0.05, 0.8)
      end
   elseif e.shotpattern == 3 then
      -- fast shots
      if every(15) then
         add_e_projectile(gun_x, gun_y, e.polarity, 0, 2.0)
         if rnd(100) > 80 then e.polarity = not e.polarity end
      end
   elseif e.shotpattern == 4 then
      -- bursts of a lot of shots going almost straight forward
      if every(100) then
         add_e_projectile(gun_x, gun_y, e.polarity, rnd(0.01) - 0.005, 2.0)
         add_e_projectile(gun_x, gun_y, e.polarity, rnd(0.01) - 0.005, 2.5)
         add_e_projectile(gun_x, gun_y, e.polarity, rnd(0.01) - 0.005, 3.0)
         add_e_projectile(gun_x, gun_y, e.polarity, rnd(0.01) - 0.005, 3.5)
         add_e_projectile(gun_x, gun_y, e.polarity, rnd(0.01) - 0.005, 4.0)
         e.polarity = not e.polarity
      end
   elseif e.shotpattern == 5 then
      -- shot all directions
      if every(180) then
         for angle = 0.0, 1.0, 0.15 do
            add_e_projectile(gun_x, gun_y, e.polarity, angle, rnd(1.5) + 0.25)
         end
         e.polarity = not e.polarity
      end
   elseif e.shotpattern == 6 then
      if every(50) then
         add_e_projectile(gun_x, gun_y, e.polarity, 0.05 + rnd(0.01) - 0.005, 1.0)
         add_e_projectile(gun_x, gun_y, not e.polarity, 0.025 + rnd(0.01) - 0.005, 1.5)
         add_e_projectile(gun_x, gun_y, not e.polarity, 0.025 + rnd(0.01) - 0.005, 0.5)
         add_e_projectile(gun_x, gun_y, e.polarity, rnd(0.01) - 0.005, 3.0)
         add_e_projectile(gun_x, gun_y, e.polarity, rnd(0.01) - 0.005, 2.0)
         add_e_projectile(gun_x, gun_y, e.polarity, rnd(0.01) - 0.005, 1.0)
         add_e_projectile(gun_x, gun_y, not e.polarity, -0.025 + rnd(0.01) - 0.005, 1.5)
         add_e_projectile(gun_x, gun_y, not e.polarity, -0.025 + rnd(0.01) - 0.005, 0.5)
         add_e_projectile(gun_x, gun_y, e.polarity, -0.05 + rnd(0.01) - 0.005, 1.0)
         e.polarity = not e.polarity
      end
   elseif e.shotpattern == 7 then
      if every(60 * 5) then
         add_e_projectile(gun_x, gun_y, e.polarity, 0, 0.5)
         e.polarity = not e.polarity
      end
   end

   --collision with player
   if inside(player, e) then
     e.hit = true
     player.energy -= 1
     e.hp -= 5
   end
end

enemies = {}
e_projectiles = {}
progress = 0

x_patterns = {
   { 32, 48, 64 },
   { 48, 64, 80 },
   { 32, 64, 96 },
}

function get_x_coord_pattern()
   return x_patterns[flr(rnd(#x_patterns)) + 1]
end

function get_x_coord_column()
   return (flr(rnd(12)) + 2) * 8
end

function spawn_enemy_wave_by_progress()

   progress += 1

   if progress % 30 == 0 then
      create_enemy_banana(get_x_coord_column(), -32)
   end

   local randLimit = progress
   if randLimit > 35 then randLimit = 35 end
   local r = flr(rnd(randLimit))

   --r = 18

   if r > 30 then
      local i = 0
      for x in all(get_x_coord_pattern()) do
         if i == 1 then
            create_enemy_destroyer(x - 4, -16)
         else
            local s = create_enemy_simple(x, -16)
            s.movement = 2
         end
         i += 1
      end
   elseif r > 25 then
      create_enemy_longship(64 - 4, -64)
   elseif r > 20 then
      create_enemy_destroyer(get_x_coord_column(), -16)
      if rnd(100) > 90 then spawn_enemy_wave_by_progress() end
   elseif r > 17 then
      local xs = get_x_coord_pattern()
      create_enemy_bomber(xs[1], -16)
      create_enemy_bomber(xs[2], -8)
      create_enemy_bomber(xs[3], -16)
   elseif r > 13 then
      for i = 1, flr(rnd(2) + 1) do
         create_enemy_stone(get_x_coord_column(), -32 * i)
      end
   elseif r > 8 then
      local xx = get_x_coord_column()
      create_enemy_peeper(xx, -16)
      create_enemy_peeper(128 - xx - 8, -16)
   elseif r > 5 then
      create_enemy_grunt(get_x_coord_column(), -16)
      if rnd(100) > 90 then spawn_enemy_wave_by_progress() end
   else
      for x in all(get_x_coord_pattern()) do
         create_enemy_simple(x, -8)
      end
   end
end

function lerp(a,b,t)
  return a + t*(b-a)
end

function every(duration,offset,period)
  local offset = offset or 0
  local period = period or 1
  local offset_frames = frames + offset
  return offset_frames % duration < period
end

function pythagoras(ax,ay,bx,by)
  local x = ax-bx
  local y = ay-by
  return sqrt(x*x+y*y)
end

function add_e_projectile(e_x,e_y, e_polarity, e_direction, e_velocity, e_size) --needs only an x,y
  e_direction = e_direction or 0
  e_velocity = e_velocity or 1
  e_polarity = e_polarity or false
  e_size = e_size or 1
  local projectile = {x = e_x,y = e_y, direction = e_direction, velocity = e_velocity, polarity = e_polarity, size = e_size}
  add(e_projectiles,projectile)
end

function update_e_projectiles()
  for p in all(e_projectiles) do

    if pythagoras(p.x,p.y,player.x,player.y) < 15 and p.polarity ~= polarity then
      p.x = lerp(p.x,player.x+3,0.2)
      p.y = lerp(p.y,player.y+6,0.2)
    else
      p.x = p.x+p.velocity*sin(p.direction)
      p.y = p.y+p.velocity*cos(p.direction)
    end
  end
  for p = #e_projectiles, 1, -1 do
    local x = e_projectiles[p].x
    local y = e_projectiles[p].y
    if x > 120 or x < 8 or y > 128 or y < 20 then del(e_projectiles,e_projectiles[p]) end
  end
end

function draw_e_projectiles()
  for p in all(e_projectiles) do
    if p.polarity == true then
      circfill(p.x,p.y,p.size+1,7)
      circfill(p.x,p.y,p.size,0)
    else
      circfill(p.x,p.y,p.size+1,0)
      circfill(p.x,p.y,p.size,7)
    end
  end
end


function init_stars()
	stars = {}
		for i=1,20 do
			add(stars, {
				x = rnd(128),
				y = rnd(128),
				s = rnd(1)
			})
		end
end

function update_stars()
	for star in all(stars) do
    if polarity then star.y -= star.s
    else star.y += star.s end

		if star.y >= 130 then
			star.y = 0 - rnd(3)
			star.x = rnd(128)
			star.s = rnd(1)
		elseif star.y <= -10 then
      star.y = 128 + rnd(3)
			star.x = rnd(128)
			star.s = rnd(1)
    end
	end
end

function draw_stars()
	for star in all(stars) do
		if (star.y > 0) then
			-- rectfill(star.x-1, star.y-1, star.x+1, (star.y+star.s)+1, 0)
			line(star.x, star.y, star.x, star.y+(star.s*2), (5+rnd(2)))
		end
	end
end



function _init ()
   --  scene = "title"
   scene = "title"
   frames = 0

   init_stars()

   player = {}
   player.energy = 60
   player.x = 64
   player.y = 64
   player.w = 1
   player.h = 1
   player.hit = 0
   player.projectiles = {}
   player.score = 0
   player.highscore = false
   e_projectiles = {}
   polarity = false

   shield = {}
   shield.x = 60
   shield.y = 58
   oldscore = get_score()
   enemies = {}
   progress = 0

   timers_clear()
   timer_start(1, 1.0)
   timer_start(2, 10.0) --time to show high score
   music(0)
end

function player_control()
  if btn(4) and player.energy > 1 then
    add(player.projectiles,{x = player.x+3, y = player.y+4})
    add(player.projectiles,{x = player.x+3, y = player.y+2})
    add(player.projectiles,{x = player.x+3, y = player.y})
    add(player.projectiles,{x = player.x+3, y = player.y-2})
    add(player.projectiles,{x = player.x+3, y = player.y-4})
    player.energy -= 0.1
    local note = flr(player.energy/32)
    if (every(4)) sfx(10,2)

  else
    sfx(-1,3)
  end
  if btnp(5) then
    if polarity == false then polarity = true
    elseif polarity == true then polarity = false
    end
    sfx(14)
  end
  if btn(2) then player.y -= 1 end
  if btn(1) then player.x += 1 end
  if btn(3) then player.y += 1 end
  if btn(0) then player.x -= 1 end
  player.x =mid (3,player.x,118)
  player.y =mid (0,player.y,120)
end

function update_game()
  update_stars()
  if (btnp(4,1)) dset(1,0) dset(2,0)
  -- player update
  player_control()


  -- shield.x = lerp(shield.x,player.x-4,0.1)
	-- shield.y = lerp(shield.y,player.y-8,0.5)
	for n = #player.projectiles, 1, -1 do
		player.projectiles[n].y -= 8
    player.projectiles[n].x = player.x+3
		if player.projectiles[n].y < -30 then del(player.projectiles,player.projectiles[1]) end
	end

    --enemies

    local rate = 120 - (progress * 0.5)
    if rate < 60 then rate = 60 end
    
    if frames % rate == 0 then
       spawn_enemy_wave_by_progress()
    end

    for e in all(enemies) do
       update_enemy(e)
    end

  for e = #enemies, 1, -1 do
    local x = enemies[e].x
    local y = enemies[e].y
    local hp = enemies[e].hp
    if x > 200 or x < -200 or y > 200 or y < -200 then
      del(enemies,enemies[e])

    elseif hp < 1 then
      if player.energy <= 20 then
        player.score += 2*(enemies[e].score * (100 - player.energy))

      else
        player.score += (enemies[e].score * (100 - player.energy))

      end
      del(enemies,enemies[e])
    end

  end

  update_e_projectiles()
  collisions()

  local highscore = get_score()
  highscore = 0 + highscore
  if player.score > highscore then player.highscore = true end

  if player.energy < 0 then
    scene = "dead"
    if player.highscore == true then
      local score1 = 0 + sub(player.score,1,4)
      dset(1,player.score)
      if player.score > 9999 then
        local score2 = sub(player.score,5,8)
        dset(2,score2)
      else
        dset(2,nil)
      end
    end
    frames = 0
    timer_start(3,3.0)
    sfx(6)
  end
  player.energy = mid(0,player.energy,100)


end

function _update60 ()
   timers_tick()
   frames += 1
  if scene == "title" then
    if timer_check(1) then
      if btnp(4) or btnp(5) then
        timer_start(4,1.0)
        scene = "lingo"
        music(-1)
        sfx(6)
      end
    end
    update_stars()
  elseif scene == "dead" then
    update_death()
    music(-1)

  elseif scene == "game" then
    update_game()
  end
  if scene == "lingo" then
    if timer_check(4) then scene = "game" music(3,1+2) sfx(-1) end
  end

end

function update_death()
  if timer_check(3) and btn(4) then
     scene = "title"
     sfx(-1)
     music(0)
     _init()
  end
end

function inside(point, enemy)
  if point == nil then return false end
   local px = point.x
   local py = point.y
   return
      px > enemy.x and px < enemy.x + enemy.w * 8 and
      py > enemy.y and py < enemy.y + enemy.h * 8
end

function collisions()
  --laser collison
   for p = #player.projectiles, 1, -1 do
      for e in all(enemies) do
         if inside(player.projectiles[p], e) then
            e.hp -= 1
            e.hit = true

            if (every(4)) player.score += 1  sfx(12,3)
            del(player.projectiles,player.projectiles[p])
         end
      end
   end
  --enemy collisions
  for p = #e_projectiles, 1, -1 do
      if inside(e_projectiles[p], player) then
        if e_projectiles[p].polarity ~= polarity then
          player.energy += 5
          player.score += 1
        elseif e_projectiles[p].polarity == polarity then
          player.energy -= 10
          player.hit += 2
          sfx(13,3)
        end
        del(e_projectiles,e_projectiles[p])
      end
  end
end

function draw_highscore(score,string)
  pal()
  palt(0,false)
  palt(14,true)
  local length = "0" .. score
  length = #length -2
  local x = 26
  local y = 53
  rectfill(x-3,y-3,x + (8*5), y + 23, 7)
  rectfill(x+(8*5),y-3,x + (8*10) + 1, y + 23, 0)
  rectfill(x-2,y-2,x + (8*10), y + 22, 5)
  pal(0,7)
  pal(7,0)
  for n = 0,length do
    local nr = sub(score, n+1,n+1) or 0
    nr = "0" .. nr
    print(string,x,y-1,7)
    spr(134+nr,(n*10)+x,y+5,1,2)
  end
end

function draw_title()
  pal()
  rectfill(0,0,64,128,0)
  rectfill(64,0,128,128,7)
  circfill(64,31,31,0)
  circfill(64,95,31,7)
  draw_stars()
  rectfill(0,0,4,127,9)
  rectfill(127-4,0,127,127,9)
  palt(0,false)
  palt(14,true)
  map(2,0,127-8,16,1,12)
  pal(7,0) pal(0,7)
  map(2,0,0,16,1,12)
  local sine = sin((frames/1000)*3.14)*7
  local sine2 = sin((frames/700)*3.14)*4

  if every(60*30,60*10,60*10) then
    local score = get_score()
    draw_highscore(score, "high-score")
  elseif every(60*30,60*20,60*10) then
      draw_instructions()
  else
    if (every(60,0,30)) print("press",40,22,0)
    if (every(60,30,30)) print("button",56+20,97,7)
    if every(480,0,200+rnd(80)) then
      pal(7,7) pal(0,0)
      spr(128,38+sine2,28+sine,6,8)
      polarity = false
    elseif every(480,240,200+rnd(80)) then
      spr(128,38+sine2,28+sine,6,8)
      polarity = true
    end
  end


end

function draw_instructions()
  local x = 15
  local y = 10
  local x2 = 110
  pal(7,7)
  pal(0,0)
  print("monoid",x,y,7)
  print("by @ossianboren",x,y+6,6)
  print("and @e_svedang",x,y+12)


  print("press \151 to",x,y+25,7)
  print("switch polarity",x,y+31)
  spr(5,x+65,y+25)
  spr(6,x+85,y+25)

  print("good:    bad:",x,y+43,6)
  circfill(x+25,y+45,2,7)
  circfill(x+25,y+45,1,0)
  circfill(x+55,y+45,1,7)

  print("good:    bad:",x+41,y+58,5)
  circfill(x+64,y+60,2,0)
  circfill(x+64,y+60,1,7)
  circfill(x+95,y+60,1,0)

  print("energy is used",x+41,y+75,0)
  print("for life and laser",x+25,y+81)

  print("good luck!",x+57,y+105,5)
  if every(4,0,2) then
    rectfill(x+5,y+65,x+8,y+101,7)
    rectfill(x+4,y+64,x+7,y+100,0)
  else
    rectfill(x+5,y+65,x+8,y+101,0)
    rectfill(x+4,y+64,x+7,y+100,7)
  end
end

function get_score()
  local score = 0
  if dget(1) > 0  and dget(2) > 0 then
    score = dget(1) .. dget(2)
  elseif dget(1) > 0 then
    score = dget(1)
  end
  return score
end

function draw_ui()
  palt(0,false)
  palt(14,true)

  if btnp (5) then
      for x = 0,15 do
        for y = 0,15 do
          spr(33+rnd(4),x*8,y*8)
        end
      end
  end

	rectfill(0,0,4,128,9)
	rectfill(127-4,0,128,128,9)


  if btn(4) and every(4,0,2) then
    pal(0,7)
    pal(7,0)
  end
  local energy = flr(player.energy)
  if polarity == true then
    pal(0,7)
    pal(7,0)
  end
  if polarity == true and btn(4) and every(4,0,2) then
    pal(0,0)
    pal(7,7)
  end
  print(energy,1,121,0)
  print(energy,1,120,7)
  local energybar = 117
  rectfill(2,energybar+1-player.energy,6,energybar+1,0)
  rectfill(1,energybar-player.energy,5,energybar,7)
  if energy < 20 and every(60,0,30) then
    print("energy low",9,121,0)
    print("energy low",9,120,9)
  end
  if player.highscore then
    print("new score", 87,121,0)
    print("new score", 87,120,9)
  end

  -- function polaritylabel()
  --   if polarity == false then
  --     rectfill(0,0,8,128,0)
  --     pal(0,7)
  --     map(1,0,0,0,1,16)
  --   elseif polarity == true then
  --     rectfill(0,0,8,128,7)
  --     pal(7,0)
  --     map(0,0,0,0,1,16)
  --   end
  -- end
  palt(14,true)
  palt(0,false)
  --
  player.score = flr(player.score)
  local length = "0" .. player.score
  length = #length -2
  for n = length,0,-1 do

    local nr = sub(player.score, n+1,n+1) or 0
    nr = "0" .. nr
    if polarity == false then
      pal(0,7)
      pal(7,0)
    elseif polarity == true then
      pal(0,0)
      pal(7,7)
    end
    spr(134+nr,119,n*16,1,2)
  end


end

function draw_game()
  cls()
  pal()
  palt(0,false)
  palt(14,true)

  --background and stars
  if polarity == true then
    rectfill(0,0,128,128,7)
    pal(0,7)
    pal(7,0)
    draw_stars()
    pal(7,7)
    pal(0,0)
  else draw_stars() end

  if player.hit > 0 and polarity == true then
    circfill(player.x+3,player.y+4,player.hit*(1+rnd(4)),0)
    player.hit -= 1
    mid(player.hit,0,20)
  elseif player.hit > 0 then
    circfill(player.x+3,player.y+4,player.hit*(1+rnd(4)),7)
    player.hit -= 1
  end

  --projectiles
  for i = #player.projectiles, 1, -1 do
    n = player.projectiles[i]
    if polarity == true and every(2,1) then line(n.x,n.y,n.x,n.y+3,0)
    elseif every(2,1) then line(n.x,n.y,n.x,n.y+3,7) end
  end
  if btn(4) and polarity and every(2,1) then circfill(player.x+3,player.y-3,2,0)
  elseif btn(4) and every(2,1) then circfill(player.x+3,player.y-3,2,7) end
  draw_e_projectiles()




  --enemies
  for e in all(enemies) do
    if e.hit then
        local x = player.x+4
        local y = e.y + (e.h*8)
        circfill(x,y,rnd(4),5+rnd(2))
    end
    if e.polarity == true then
      pal(0,7)
      pal(7,0)
    end
    if e.hit and polarity == true then
      pal(0,0)
      pal(8,0)
      pal(7,0)
      e.hit = false
    elseif e.hit and polarity == false then
      pal(0,7)
      pal(8,7)
      pal(7,7)
      e.hit = false
    end
    spr(e.sprite,e.x,e.y,e.w,e.h)

  end
  pal()
  palt(0,false)
  palt(14,true)
  --player
  local ship_sprite = 5
  local ship_sprite_turning = 39

  if polarity == true then
    ship_sprite = 6
    ship_sprite_turning = 40
  end

  if btn(0) then spr(ship_sprite_turning,player.x-1,player.y)
  elseif btn(1) then spr(ship_sprite_turning,player.x,player.y,1,1,true)
  else spr(ship_sprite,player.x,player.y) end

  draw_ui()
end

function draw_death()
  if timer_check(3) then
    for x = 0,15 do
      for y = 0,15 do
        if every(rnd(6)) then spr(33+rnd(4),x*8,y*8,1,1,rnd(2),rnd(2)) end
      end
    end
    local message = "your score"
    if player.highscore then
      message = "new high-score"
      rectfill(25,89,8*10+25,95,0)
      print("old score:" .. oldscore, 26, 90, 7)
    end
    draw_highscore(player.score,message)

    rectfill(0,0,4,128,9)
  	rectfill(127-4,0,128,128,9)
  else
    if every(2) then circfill(player.x+3,player.y+2,frames/4,7)
    else circfill(player.x+4,player.y+3,frames/4,0) end
  end
end

function _draw ()
  if scene == "title" then
    draw_title()
  elseif scene == "dead" then
    draw_death()
  elseif scene == "game" then
    draw_game()
  else
    for x = 0,15 do
      for y = 0,15 do
        if every(rnd(6)) then spr(33+rnd(4),x*8,y*8,1,1,rnd(2),rnd(2)) end
      end
    end
    rectfill(0,0,4,128,9)
    rectfill(127-4,0,128,128,9)
  end
  --print(("cpu:".. flr((stat(1)*100)) .. "% ram:" .. flr(stat(0)) .. " scene:" .. scene ),10,1,14)
end
__gfx__
00000000eee7ee7eee7eeeeeeeeeeeeeeeeeeeeeee000eeeee777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000ee7eeee7e7eeee7ee7ee7eeeeee7ee7ee07770eee70007eeeeeeeeeee000000ee0e00e00e0eeeee0eee00eeee0000000e0000000e0000000e00ee00e
007007007e7e7ee7ee7eeee7ee77eeeeeeee77ee0770770e7007007eeeeeeeeee0777700e0e00e00e0eeeee0eee00eeee7770700e0077777e00eeee0e00ee00e
0007700007eee7ee7e7e7ee7e7eeeeeeee7eee7e0077700e7700077eeeeeeeeee0eeee00e0e00e00e0eeeee0eee00eeeeeee0e00e00eeeeee00eeee0e00ee00e
000770007707e7070700e77007ee7eeeeee7ee700707070e7070707eeeeeeeeee0eeee00e0e00e00e0eeeee0eee00eeeeeee0e77e00eeeeee00eeee0e00ee00e
00700700007700777077007770eee7eeee77e0070777770e7000007eeeeeeeeee0eeee00e0e00e00e0eeeee0eee00eeeeeee0eeee00eeeeee00eeee0e00ee00e
00000000ee0077000e00770007077eeee7ee77700700070e0077700eeeeeeeeee0eeee00e0e00e00e0eeeee0eee00eeeeeee0eeee00eeeeee00eeee0e00ee07e
00000000eeee00eeeeee00eee070eeeeeeee070e070e070e07eee70eeeeeeeeee0eeee00e0e00e00e0000000eee70eeeeeee0eeee0000000e00eeee0e0000000
00000000ee00eeeeee00eeeee070eeeeeeee070eeeeeeeeeeeeeeeeeeeeeeeeee0eeee70e0e70e70e0077770eeee0eeeeeee00eee0077000e07eeee0e0077770
00000000007700ee007700e00777ee7ee7e77070eeeee00000eeeeeeeeeeeeeee0eeeee0e0ee0ee0e00eeee0eeee0eeeeeee00eee00ee777e0eeeee0e00eeee0
000000007700770077007707700e77eeee7ee077eee007777700eeeeeeeeeeeee0eeeee0e0ee0ee0e00eeee0eeee0eeeeeee00eee00eeeeee0eeeee0e00eeee0
00000000707e7077077e007007ee7eeeee7eee70ee07700000770eeeeeeeeeeee0eeeee0e0ee0ee0e00eeee0eeee0eeeeeee00eee00eeeeee0eeeee0e00eeee0
000000000e7eee7e7ee7e707e7eee7eee7ee77eee0700eeeee0070eeeeeeeeeee0000000e0000000e00eeee0ee00000eeeee00eee0000000e0000000e00eeee0
000000007ee7e7e77eeee7eeee77eeeeeee7e7ee0700eeeeeee0070eeeeeeeeee0000007e0000000e00eeee0ee00000eeeee00eee0000000e0000000e00eeee0
000000007eeee7eee7eeee7ee7ee7eeeeeeeee7e070eeeeeeeee070eeeeeeeeee777777ee7777777e77eeee7ee77777eeeee77eee7777777e7777777e77eeee7
00000000e7ee7eeeeeeee7eeeeeeeeeeeeeeeeee000eeeeeeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e00ee00e07777707000700070007007777007000eeeeeeeeeeeeeeeeeeee00eeeeee77eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e070070e00077000070700000777707007007077eeeee77777eeeeeeeee0770eeee7007ee00eeeeee000000ee0000000e0000000eeeeeeeee0000000e0000e00
e078870e77007777070770070000777777000000eee770000077eeeeee070770ee707007e00eeeeee007770ee0077700e0077000eeeeeeeee0000000e0000e00
0778877000077700770070007770007000007700ee70077777007eeeee007700ee770077e00eeeeee00eee0ee00eee00e00ee777eeee7eeee0770770e0770e00
0070070007070707077770000077000007707000e7077eeeee7707eeee070770ee707007e00eeeeee00eee0ee00eee70e00eeeeeeee707eee0ee0ee0e0ee0e00
07700770777700000070000077700777770077777077eeeeeee7707eee077770ee700007e00eeeeee00eee0ee00eeee0e00eeeeeeee707eee0ee0ee0e0ee0e00
070ee07007077770777707070000070000000000707eeeeeeeee707eee070070ee007700e00eeeeee00eee0ee00eeee0e00eeeeeee70007ee0ee0ee0e0ee0e00
e0eeee0e77007000707007007077077007777707777eeeeeeeee777eee070e70ee077e70e07eeeeee0000000e0000000e00eeeeee7000007e0ee0ee0e0ee0e00
000000000000000000000000000000000000000000000000000000000000000000000000e0eeeeeee0077770e0077000e07eeeeeee70007ee0e00e00e0ee0e70
000000000000000000000000000000000000000000000000000000000000000000000000e0eeeeeee00eeee0e00ee770e0eeeeeeeee707eee0e00e00e0ee0ee0
000000000000000000000000000000000000000000000000000000000000000000000000e0eeeeeee00eeee0e00eeee0e0eeeeeeeee707eee0e00e00e0ee0ee0
000000000000000000000000000000000000000000000000000000000000000000000000e0eeeeeee00eeee0e00eeee0e0eeeeeeeeee7eeee0e00e00e0ee0ee0
000000000000000000000000000000000000000000000000000000000000000000000000e0000000e0000000e00eeee0e0000000eeeeeeeee0e00e00e0ee0000
000000000000000000000000000000000000000000000000000000000000000000000000e0000000e0000000e00eeee0e0000000eeeeeeeee0e00e00e0ee0000
000000000000000000000000000000000000000000000000000000000000000000000000e7777777e7777777e77eeee7e7777777eeeeeeeee7e77e77e7ee7777
000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee88eeeee8888eee00eee00ee888eeee8e9e98eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
ee8888eeee8778eee000e000eeeee88e89a2a2e8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
8e0880e8ee8008eee0000000e8e8ee8e88494848eeeee111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
80700708ee8778eee007070088888e8ee078800eeeee111111111eeeeeeeeeeee444aaeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
e880088eee8008eee00777008787888ee078802eeee11000011111eeeeeeeeee44444aaaeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
80800808ee8778eee0088800e808888ee000002eee1100000011111eeeeeeeee44ee4aaaaaeeeeeeeeeeeeee0000000000000000000000000000000000000000
80000008ee8008eeee00800ee888888ee078802ee11000000001111eeeeeeeeeeeee99aaaaaeeeeeeeeeeeee0000000000000000000000000000000000000000
e88ee88eeee88eeeeee000eee8e8ee8ee078802ee11000000001111eeeeeeeeeeeeeee9aaaaaeeeeeeeeeeee0000000000000000000000000000000000000000
00000000000000000000000000000000e078802ee11000000001111eeeeeeeeeeeeeee9aaaaaeeeeeeeeeeee0000000000000000000000000000000000000000
0000000000000000000000000000000007088000e11000000011111eeeeeeeeeeeeeeee9aaaaaeeeeeeeeeee0000000000000000000000000000000000000000
0000000000000000000000000000000007098820ee1100000111111eeeeeeeeeeeeeeeee9aaaaaeeeeeeeeee0000000000000000000000000000000000000000
0000000000000000000000000000000007088520ee111111111111eeeeeeeeeeeeeeeeee9aaaaaaeeeeeeeee0000000000000000000000000000000000000000
0000000000000000000000000000000007095750eee1111111111eeeeeeeeeeeeeeeeeeee9aaaaaaeeeeeeee0000000000000000000000000000000000000000
0000000000000000000000000000000007088520eeee11111111eeeeeeeeeeeeeeeeeeeee9aaaaaaeeeeeeee0000000000000000000000000000000000000000
0000000000000000000000000000000087098828eeeeee1111eeeeeeeeeeeeeeeeeeeeeee9aaaaaaaeeeeeee0000000000000000000000000000000000000000
0000000000000000000000000000000087088828eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee9aaaaaaaeeeeeee0000000000000000000000000000000000000000
eeee282e282eeeee0000000000000000800008280000000000000000eeeeeeeeeeeeeeeee9aaaaaaaeeeeeee0000000000000000000000000000000000000000
eee280828082eeee0000000000000000878808280000000000000000eeeeeeeeeeeeeeeee9aaaaaaaeeeeeee0000000000000000000000000000000000000000
ee28000a00082eee0000000000000000858858280000000000000000eeeeeeeeeeeeeeeee9aaaaaaaeeeeeee0000000000000000000000000000000000000000
828000000000828e0000000000000000078575200000000000000000eeeeeeeeeeeeeeeee9aaaaaaaeeeeeee0000000000000000000000000000000000000000
e800000a000008ee0000000000000000058575200000000000000000eeeeeeeeeeeeeeeee9aaaaaaaeeeeeee0000000000000000000000000000000000000000
800000000000008e0000000000000000078575200000000000000000eeeeeeeeeeeeeeeee9aaaaaaaeeeeeee0000000000000000000000000000000000000000
e809000a000908ee0000000000000000058858200000000000000000eeeeeeeeeeeeeeeee9aaaaaaaeeeeeee0000000000000000000000000000000000000000
800700888007008e0000000000000000078888200000000000000000eeeeeeeeeeeeeeeee9aaaaaaeeeeeeee0000000000000000000000000000000000000000
e80008e8e80008ee0000000000000000000008200000000000000000eeeeeeeeeeeeeeee9aaaaaaaeeeeeeee0000000000000000000000000000000000000000
e88888e8e88888ee0000000000000000070808200000000000000000eeeeeeeeeeeeeeee9aaaaaaeeeeeeeee0000000000000000000000000000000000000000
e80008e8e80008ee00000000000000000708c9200000000000000000eeeeeeeeeeeeee99aaaaaeeeeeeeeeee0000000000000000000000000000000000000000
ee808ee8ee808eee000000000000000007089c200000000000000000eeeeeeeeeeeee9aaaaaeeeeeeeeeeeee0000000000000000000000000000000000000000
ee828ee8ee828eee0000000000000000070888200000000000000000eeeeeeeeeeee9aaaaaeeeeeeeeeeeeee0000000000000000000000000000000000000000
e80008e3e80008ee0000000000000000e008820e0000000000000000eeeeeeeeee99aaaaaeeeeeeeeeeeeeee0000000000000000000000000000000000000000
ee808eeeee808eee0000000000000000ee0820ee0000000000000000eeeeeeee444aaaeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
eee8eeeeeee8eeee0000000000000000eee00eee0000000000000000eeeeeeee44eeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000eee00eeee000000ee000000eee0eee0ee0000000e0000000e0000000ee00000eee00000e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee077770ee000eeee000770ee000770eee0eee0ee0077000e0077000e0007700ee07700eee07770e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeee0ee000eeee777ee00e777ee00ee0eee0ee00ee777e00ee777e777ee00ee0ee70eee0eee0e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeee0ee770eeeeeeeee00eeeeee00e00eee00e00eeeeee00eeeeeeeeeee00e00eee00e00eee00
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000eee0eeee0eeeeeeeee00eeeeee00e00eee00e00eeeeee00eeeeeeeeeee00e00eee00e00eee00
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0700ee0eeee00eeeeeeee00eeeeee00e00eee00e00eeeeee00eeeeeeeeeee70e00eee00e00eee00
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0e700e0eeee00eeeeeeee00eeeeee00e0000000e00eeeeee00eeeeeeeeeeee0e00eee00e0000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0ee7000eeee00eeee000000eee00007e7777700e000000ee0000000eeee0000e7000007e7777770
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eee700eeee00eee0077777eee77700eeeeee00e7777700e0077700eeee0077e0077700eeeeeee0
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeee00eeee00eee00eeeeeeeeeee00eeeeee00eeeeee00e00eee00eeee00eee00eee00eeeeee00
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeee00eeee00eee00eeeeeeeeeee00eeeeee00eeeeee00e00eee00eeee00eee00eee00eeeeee00
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000eee0000ee00ee000e000ee00eeeeee00e000ee00e00eee00eeee00eee00eee00eeeeee00
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000eee0000ee0000000e0000000eeeeee00e0000000e0000000eeee00eee0000000eeeeee00
eeeeeeeeeeeeeeeeeeeeeeee0000000000eeeeeeeeeeeeeee7777777eee7777ee7777777e7777777eeeeee77e7777777e7777777eeee77eee7777777eeeeee77
eeeeeeeeeeeeeeeeeeeee000777777777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeee00777777777777777000eeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeee0777777777770007777770eeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeee0777777777700000007777700eeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee077777777770000077077777770eeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeee07777777777700000070077777770eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeee077777777777700000000777777770eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeee0707777777777700000077777777770ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeee0070777777777777777777777777770ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeee0707777777777777777777777777770ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0707077777777777777777777777770e00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeee070777777777777777777777777770e00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeee07707777777777777777777777770e00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeee007077777777777777777777770ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeee00707777777777777777777770ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeee0007070707770707777777770eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeee070e070707070707077770000eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeee0777000000070707000000eeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeee077770e00700000000eeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee077770e0077770eeeee000eeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeee0777700e077770eeeee0070eeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeee077770000707770eeee007770eeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeee077770770707770eeee0077770eeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeee07777077700707700ee0077770eeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeee077777077707077770000777700eeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeee077777700777077777700777700eeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeee0007777700e007777777770777700eeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eee0000777077700eee0077777770777770eeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
e00777777707700eeeeee00000000777700eeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
07777777777000eeeeeeeeeeeee0777700eeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
077777770000eeeeeeeeeeeeee0777770eeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
077700000eeeeeeeeeeeeeeee0077770eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
e0000eeeeeeeeeeeeeeeeeeee0777700eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeee0077700eeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeee0000070eeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeee0077700eeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeee077770eeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeee077770eeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeee07770eeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeee077770eeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeee077770eeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeee07770eeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeee077000eeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeee0700700eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeee007770eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeee077700eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeee07700eeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeee000eeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000008188d0008188d188d000000000000b9f71727b9f71727172700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
092a2e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
193a3e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a290e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a391e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b2b2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b3b3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c2c0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c3c1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0f0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1f1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2d080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d3d180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0106002001051016040160301605206201c61601600110302566511041010011f6041f62701101190030f00319053016052566519003190531900319003110302566511041010011f6041f627011010f6050f003
010c002001403235531930309500193031c5531c5031c55300000000002a3031c5532a30300000235531a403145030000030503305530240027403000002d55300000000001e4030000000000193030000000000
013000200f4300f43203432034320343503432034350f43113430074310743107432134320e432074350e43113430074300743203432034310f4300f430034310343103430034350343203435034310a43116430
0130000c033300f33203331033260f3261b3260332003322033220f3320f332073310333303332033320333203372034720a4720a472034730347003440034710377103770035420377203772037710a5510a550
0018001013073306230000000000000000000013073306230000000000346033463334633000002d6332363300000000000000000000000000000000000000000000000000000000000000000000000000000000
011800103d1052b0153601324105240153800138013201053d1052e0153601124105240153900138013231052516536525231552511522125241552012521155201251e155201451c1551f155191551715516145
001018202466123651236512265121651206411f6411c6411b641196311763116631146311362112621106210e6210c6110a6110a611096110861107611056110361001610016100161001610016100161001610
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001f3121a3111700116001150011400112001120011100110001100010f0010e0010d0010c0010c0010b001090010800107001070010600105001030010300103001020010200102001020010200101001
011000001d65211653000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001565300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900002225300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003f5531b533000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 04054344
01 04050344
02 02450444
01 00424344
00 00424344
00 00024344
00 00034344
00 00040544
00 00040544
00 40030544
01 00030544
02 00020544
02 01030544
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

