local sti = require "sti"
local gamera = require "gamera"

function love.load()
  -- PHYSICS SETUP:

  love.physics.setMeter(64)
  world = love.physics.newWorld(0, 9.81*164, true)


  map = sti("art/map1.lua", { "box2d" })
  map:box2d_init(world)
  map:removeLayer("ground")

  cam = gamera.new(0,0,map.width*map.tilewidth,map.height*map.tileheight)
  cam:setScale(2.0)

  gameWon = false

  for k, object in pairs(map.objects) do
    if object.name == "ball" then
      ball = object
      break
    end
  end
  map:removeLayer("ball")

  for k, object in pairs(map.objects) do
    if object.name == "hole" then
      hole = object
      break
    end
  end
  map:removeLayer("hole")

  objects = {}
--     --let's create a ball
  objects.ball = {}
  objects.ball.body = love.physics.newBody(world, ball.x, ball.y, "dynamic")
  objects.ball.body:setFixedRotation(true)
--   --newCircleShape(radius)
  objects.ball.shape = love.physics.newCircleShape(3.5)
  objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 10)
  objects.ball.sprite = love.graphics.newImage("art/golf-tileset.png")
  objects.ball.quad = love.graphics.newQuad(32,9,7,7, objects.ball.sprite:getDimensions())
  objects.ball.fixture:setFriction(0.09)

--   -- apparently restitution is 'bounciness' or something
  objects.ball.fixture:setRestitution(0.5)

 -- GAME STUFF
  shotAngle = 0
  love.graphics.setBackgroundColor(135/255, 150/255, 180/255)
  love.graphics.setDefaultFilter( 'nearest', 'nearest' )
  -- love.window.setMode(650, 650)
end

function love.update(dt)
  -- require("lurker").update()
  cam:setPosition(objects.ball.body:getX(), objects.ball.body:getY())
  map:update(dt)
  world:update(dt)
  if love.keyboard.isDown('right') then
    shotAngle = shotAngle + 50 * dt
  end
  if love.keyboard.isDown('left') then
    shotAngle = shotAngle - 50 * dt
  end
  local ballX = objects.ball.body:getX()
  local ballY = objects.ball.body:getY()
  if ballX > hole.x + 4 and ballX < hole.x + 14 and ballY > hole.y and ballY < hole.y + 16 then
    gameWon = true
  end
end

function love.keypressed(key)
  if key == "space" then
    -- this is the math that turns an angle in degrees into X/Y coords.
    -- the 15000 is "power" didn't code a variable for that yet
    local angleRad = (shotAngle + 270) * math.pi/180
    local xForce = 25000 * math.cos(angleRad)
    local yForce = 25000 * math.sin(angleRad)
    objects.ball.body:applyForce(xForce, yForce)
  end

end

function love.draw()
  if gameWon then
    love.graphics.print('YOU WIN YAY! CONGRATULATIONS YOU CRAZY FOOL')
  end
  -- love.graphics.setColor(0,0,1)
  cam:draw(function(l,t,w,h)
    love.graphics.setDefaultFilter( 'nearest', 'nearest' )
    love.graphics.setColor(1, 1, 1)
    map:draw(-l,-t,2,2)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(objects.ball.sprite, objects.ball.quad, objects.ball.body:getX()-3, objects.ball.body:getY()-3)

    love.graphics.setColor(0, 0, 0)
    local angleRad = (shotAngle + 270) * math.pi/180
    local x = 50 * math.cos(angleRad)
    local y = 50 * math.sin(angleRad)
    love.graphics.circle('fill', objects.ball.body:getX() + x, objects.ball.body:getY() + y, 5)
  end)

end
