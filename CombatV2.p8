pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- collision function
function collide(x1,y1,w1,h1, x2,y2,w2,h2)
  return not (
    x1+w1 < x2 or
    x1 > x2+w2 or
    y1+h1 < y2 or
    y1 > y2+h2
  )
end

-- player
px = 20
py = 20
phealth = 3
damage_timer = 0 -- cooldown timer

-- enemy
ex = 100
ey = 60
ehealth = 5
enemy_shoot_timer = 0

-- bullets
bullets = {}
enemy_bullets = {}

function spawn_bullet()
  add(bullets, {x=px+8, y=py+4, w=4, h=2, dx=2, dy=0})
end

function spawn_enemy_bullet()
  add(enemy_bullets, {x=ex-4, y=ey+4, w=4, h=2, dx=-2, dy=0})
end

function _update()
  -- player movement
  if btn(0) then px -= 1 end
  if btn(1) then px += 1 end
  if btn(2) then py -= 1 end
  if btn(3) then py += 1 end

  -- shoot bullet (z key)
  if btnp(4) then
    spawn_bullet()
  end

  -- update player bullets
  for b in all(bullets) do
    b.x += b.dx
    b.y += b.dy

    if ehealth > 0 and collide(b.x,b.y,b.w,b.h, ex,ey,8,8) then
      ehealth -= 1
      if ehealth < 0 then ehealth = 0 end
      del(bullets, b)
    end

    if b.x > 128 then del(bullets, b) end
  end

  -- enemy movement: slowly align with player vertically
  if ehealth > 0 then
    if ey < py then ey += 0.5 end
    if ey > py then ey -= 0.5 end
  end

  -- enemy shooting
  if ehealth > 0 then
    enemy_shoot_timer += 1
    if enemy_shoot_timer > 60 then -- shoot every ~1 second
      spawn_enemy_bullet()
      enemy_shoot_timer = 0
    end
  end

  -- update enemy bullets
  for eb in all(enemy_bullets) do
    eb.x += eb.dx
    eb.y += eb.dy

    if collide(px,py,8,8, eb.x,eb.y,eb.w,eb.h) then
      phealth -= 1
      if phealth < 0 then phealth = 0 end
      del(enemy_bullets, eb)
    end

    if eb.x < 0 then del(enemy_bullets, eb) end
  end

  -- damage cooldown for touch collision
  if damage_timer > 0 then
    damage_timer -= 1
  end

  if ehealth > 0 and collide(px,py,8,8, ex,ey,8,8) then
    if damage_timer == 0 then
      phealth -= 1
      if phealth < 0 then phealth = 0 end
      damage_timer = 30
    end
  end
end

function _draw()
  cls()

  -- draw player
  rectfill(px,py,px+7,py+7, 11)

  -- draw enemy if alive
  if ehealth > 0 then
    rectfill(ex,ey,ex+7,ey+7, 8)
  else
    print("enemy defeated!", 40, 60, 10)
  end

  -- draw bullets
  for b in all(bullets) do
    rectfill(b.x,b.y,b.x+b.w-1,b.y+b.h-1, 9)
  end

  -- draw enemy bullets
  for eb in all(enemy_bullets) do
    rectfill(eb.x,eb.y,eb.x+eb.w-1,eb.y+eb.h-1, 2)
  end

  -- draw health
  print("player hp: "..phealth, 2, 2, 7)
  print("enemy hp: "..ehealth, 2, 10, 7)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770006c6600800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770006c6600800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
