local sti = require "sti"
local gamera = require "gamera"

function love.load()
  -- PHYSICS SETUP:

  love.physics.setMeter(64)
  world = love.physics.newWorld(0, 9.81*164, true)


  map = sti("art/map1.lua", { "box2d" })
  map:box2d_init(world)
  print(map.width, map.height, map.tilewidth, map.tileheight)

  cam = gamera.new(0,0,map.width*map.tilewidth,map.height*map.tileheight)
  cam:setScale(2.0)

  objects = {}
--     --let's create a ball
  objects.ball = {}
  objects.ball.body = love.physics.newBody(world, 650/2, 650/2, "dynamic")
  objects.ball.body:setFixedRotation(true)
--   --newCircleShape(radius)
  objects.ball.shape = love.physics.newCircleShape(4)
  objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 10)
  objects.ball.fixture:setFriction(0.09)

--   -- apparently restitution is 'bounciness' or something
  objects.ball.fixture:setRestitution(0.5)

 -- GAME STUFF
  shotAngle = 0
  love.graphics.setBackgroundColor(0.5, 0.6, 0.9)
  love.graphics.setDefaultFilter( 'nearest', 'nearest' )
  -- love.window.setMode(650, 650)
end

function love.update(dt)
  cam:setPosition(objects.ball.body:getX(), objects.ball.body:getY())
  map:update(dt)
  world:update(dt)
  if love.keyboard.isDown('right') then
    shotAngle = shotAngle + 1
  end
  if love.keyboard.isDown('left') then
    shotAngle = shotAngle - 1
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
  -- love.graphics.setColor(0,0,1)
  cam:draw(function(l,t,w,h)
    love.graphics.setColor(1, 1, 1)
    map:draw()
    map:box2d_draw()

    --draws teh ground using the ground world position stuff

    love.graphics.setColor(.95, .2, .1)
    love.graphics.circle('fill', objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())

    love.graphics.setColor(0, 0, 0)
    local angleRad = (shotAngle + 270) * math.pi/180
    local x = 50 * math.cos(angleRad)
    local y = 50 * math.sin(angleRad)
    love.graphics.circle('fill', objects.ball.body:getX() + x, objects.ball.body:getY() + y, 5)
  end)

  love.graphics.setColor(0, 0, 0)
  love.graphics.print(shotAngle, 0, 0, 0,2, 2)
end
