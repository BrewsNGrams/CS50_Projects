--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.balls = {[1] = self.ball}
    self.level = params.level
    self.paddleSizePoints = params.paddleSizePoints

    self.recoverPoints = 5000

    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)

    self.powerups = {}
    self.keys = {}

end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    for k, ball in ipairs(self.balls) do
      ball:update(dt)
    end


    for k, ball in ipairs(self.balls) do
      if ball:collides(self.paddle) then
          -- raise ball above paddle in case it goes below it, then reverse dy
          ball.y = self.paddle.y - 8
          ball.dy = -ball.dy

          --
          -- tweak angle of bounce based on where it hits the paddle
          --

          -- if we hit the paddle on its left side while moving left...
          if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
              ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

          -- else if we hit the paddle on its right side while moving right...
          elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
              ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
          end

          gSounds['paddle-hit']:play()
      end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

      for k, ball in ipairs(self.balls) do
          -- only check collision if we're in play
          if brick.inPlay and ball:collides(brick) then

              -- add to score
              if brick.isLocked == false then
                self.score = self.score + (brick.tier * 200 + brick.color * 25)
              elseif brick.isLocked == true and #self.keys ~= 0 then
                self.score = self.score + 1000
              end

              if self.score > self.paddleSizePoints then
                self.paddle = Paddle(self.paddle.skin, self.paddle.size + 1)
                self.paddleSizePoints = self.paddleSizePoints + 6000
              end
              -- trigger the brick's hit function, which removes it from play
              brick:hit(self.keys)
              if brick.powered > 50 and not brick.inPlay then
                self.powerup = PowerUp(brick.x, brick.y)
                table.insert(self.powerups, self.powerup)
              end

              -- if we have enough points, recover a point of health
              if self.score > self.recoverPoints then
                  -- can't go above 3 health
                  self.health = math.min(3, self.health + 1)

                  -- multiply recover points by 2
                  self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                  -- play recover sound effect
                  gSounds['recover']:play()
              end

              -- go to our victory screen if there are no more bricks left
              if self:checkVictory() then
                  gSounds['victory']:play()

                  gStateMachine:change('victory', {
                      level = self.level,
                      paddle = self.paddle,
                      health = self.health,
                      score = self.score,
                      highScores = self.highScores,
                      ball = self.ball,
                      recoverPoints = self.recoverPoints,
                      paddleSizePoints = self.paddleSizePoints
                  })
              end

              --
              -- collision code for bricks
              --
              -- we check to see if the opposite side of our velocity is outside of the brick;
              -- if it is, we trigger a collision on that side. else we're within the X + width of
              -- the brick and should check to see if the top or bottom edge is outside of the brick,
              -- colliding on the top or bottom accordingly
              --

              -- left edge; only check if we're moving right, and offset the check by a couple of pixels
              -- so that flush corner hits register as Y flips, not X flips
              if ball.x + 2 < brick.x and ball.dx > 0 then

                  -- flip x velocity and reset position outside of brick
                  ball.dx = -ball.dx
                  ball.x = brick.x - 8

              -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
              -- so that flush corner hits register as Y flips, not X flips
              elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then

                  -- flip x velocity and reset position outside of brick
                  ball.dx = -ball.dx
                  ball.x = brick.x + 32

              -- top edge if no X collisions, always check
              elseif ball.y < brick.y then

                  -- flip y velocity and reset position outside of brick
                  ball.dy = -ball.dy
                  ball.y = brick.y - 8

              -- bottom edge if no X collisions or top collision, last possibility
              else

                  -- flip y velocity and reset position outside of brick
                  ball.dy = -ball.dy
                  ball.y = brick.y + 16
              end

              -- slightly scale the y velocity to speed up the game, capping at +- 150
              if math.abs(ball.dy) < 150 then
                  ball.dy = ball.dy * 1.02
              end

              -- only allow colliding with one brick, for corners
              break
          end
      end
    end -- bricks for loop end

    -- if ball goes below bounds, revert to serve state and decrease health
    -- but only if its your last ball
    for k, ball in ipairs(self.balls) do
      if ball.y >= VIRTUAL_HEIGHT then
          gSounds['hurt']:play()
          table.remove(self.balls, k)

          if #self.balls == 0 then
            self.health = self.health -1
            if self.paddle.size > 1 then
              self.paddle = Paddle(self.paddle.skin, self.paddle.size - 1)
            end

            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints,
                    paddleSizePoints = self.paddleSizePoints
                })
            end
          end
        end -- end of if/then for 'death' check
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    for k, power in ipairs(self.powerups) do
        power:update(dt)
        if power:collides(self.paddle) then
          gSounds['powerup']:play()
          if power.ability == 1 then
            for i = 1, 2 do
              ball = Ball()
              ball.skin = math.random(7)
              ball.x = self.balls[1].x + math.random(20)
              ball.y = self.balls[1].y + math.random(20)
              ball.dx = self.balls[1].dx + math.random(20)
              ball.dy = self.balls[1].dy + math.random(20)
              table.insert(self.balls, ball)
              table.remove(self.powerups, k)
            end
          elseif power.ability == 2 then
            table.insert(self.keys, power)
            table.remove(self.powerups, k)
          end
        end
    end
end

function PlayState:render()

    -- render powerups
    for k, power in ipairs(self.powerups) do
      power:render()
    end

    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    for k, key in pairs(self.keys) do
      love.graphics.draw(gTextures['main'], gFrames['pwrups'][10], 16 * k, VIRTUAL_HEIGHT - 32)
    end

    self.paddle:render()

    for k, ball in ipairs(self.balls) do
      ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end
