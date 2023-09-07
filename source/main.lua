import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

gfx = playdate.graphics

bounceSound = playdate.sound.synth.new(playdate.sound.kWaveSine)
bounceSound:setADSR(0.1, 0.1, 0.1, 0)

class("Ball").extends(gfx.sprite)

function Ball:init()
  Ball.super.init(self)

  self.xSpeed = 5
  self.ySpeed = 6

  radius = 5
  local ballImage = gfx.image.new(2 * radius, 2 * radius)
  gfx.pushContext(ballImage)
  gfx.fillCircleAtPoint(radius, radius, radius)
  gfx.popContext()

  self:setImage(ballImage)
  self:setCollideRect(0, 0, self:getSize())

  self:moveTo(200, 120)
end

function Ball:update()

    if self.x + self.xSpeed >= 400 
        then self.xSpeed *= -1
    elseif self.x + self.xSpeed <= 0
        then self.xSpeed *= -1
    end
    
    self:moveBy(self.xSpeed, 0)
end

ball = Ball()
ball:add()

class("Paddle").extends(gfx.sprite)

function Paddle:init()
  -- remember to do this so the parent sprite constructor
  -- can get its bits wired up
  Paddle.super.init(self)

  self.ySpeed = 5

  width = 8
  height = 50
  local paddleImage = gfx.image.new(width, height)
  gfx.pushContext(paddleImage)
  -- (x, y, width, height, corner rounding)
  -- note that we fill at (0,0) rather than (self.x, self.y)
  -- since we are in a new draw context thanks to pushContext
  gfx.fillRoundRect(0, 0, width, height, 2)
  gfx.popContext()
  self:setImage(paddleImage)
  self:setCollideRect(0, 0, self:getSize())

  -- 10 is arbitrary, but looks like a nice little buffer
  self:moveTo(10, screenHeight / 2 - height)
end

function Paddle:update()
    if playdate.buttonIsPressed(playdate.kButtonDown) then
      self:moveBy(0, self.ySpeed)
    end
  
    if playdate.buttonIsPressed(playdate.kButtonUp) then
      self:moveBy(0, -self.ySpeed)
    end
  end

paddle = Paddle()
paddle:add()

screenWidth = playdate.display.getWidth()
screenHeight = playdate.display.getHeight()

leftWall = gfx.sprite.addEmptyCollisionSprite(-5, 0, 5, screenHeight)
leftWall:add()

rightWall = gfx.sprite.addEmptyCollisionSprite(screenWidth, 0, 5, screenHeight)
rightWall:add()

topWall = gfx.sprite.addEmptyCollisionSprite(0, -5, screenWidth, 5)
topWall:add()

bottomWall = gfx.sprite.addEmptyCollisionSprite(0, screenHeight, screenWidth, 5)
bottomWall:add()

function Ball:update()
    -- returns actualX, actualY, a list of collisions, and the
    -- length of the set of collisions
    --
    -- actualX and actualY represent where the sprite ended up
    -- after the collisions were applied and it was moved outside
    -- the bounds of any sprites it collided with. But for now
    -- we only care if it needs to bounce or not. :)
    --
    -- We're only going to use the list of collisions right now,
    -- so the convention in Lua is to use _ for unused variables
    local _, _, collisions, _ = self:moveWithCollisions(self.x + self.xSpeed, self.y + self.ySpeed)
  
    -- In Lua, #collection gives you the length of the object,
    -- similar to collection.length in other languages
    for i = 1, #collisions do
      -- just for testing purposes
      print(collisions[i].normal)
      -- if the ball should bounce horizontally, then invert
      -- its xSpeed
      --
      -- also ~= is "not equals" in Lua, similar to != in
      -- most other languages 
      if collisions[i].normal.x ~= 0 then
        bounceSound:playNote("G4", 1, 1)
        self.xSpeed *= -1
      end
      if collisions[i].normal.y ~= 0 then
        bounceSound:playNote("G4", 1, 1)
        self.ySpeed *= -1
      end
    end
  end

function playdate.update()
  gfx.sprite.update()
end