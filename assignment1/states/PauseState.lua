PauseState = Class{__includes = BaseState}

function PauseState:enter(params)
  self.bird = params.bird
  self.pipePairs = params.pairs
  self.timer = params.time
  self.score = params.score
  self.lastY = params.lastY
end

function PauseState:update(dt)

  if love.keyboard.wasPressed('p') then

    love.audio.play(sounds['pause'])
    -- resumes music from the paused state
    love.audio.play(sounds['music'])

    --empties the gCurrentState table to be filled again on the next pause
    gStateMachine:change('play', {bird = self.bird, pairs = self.pipePairs, time = self.timer, score = self.score, lastY = self.lastY})
  end
end

function PauseState:render()

 for k, pair in pairs(self.pipePairs) do
      pair:render()
  end

  love.graphics.setFont(flappyFont)
  love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

  self.bird:render()

  love.graphics.setFont(flappyFont)
  love.graphics.printf('GAME PAUSED', 0, 64, VIRTUAL_WIDTH, 'center')
  love.graphics.setFont(mediumFont)
  love.graphics.printf('Press P to continue', 0, 100, VIRTUAL_WIDTH, 'center')

  -- Double rectangles, universal 'PAUSE' symbol
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 15, VIRTUAL_HEIGHT / 2 - 20, 10, 40)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 20, 10, 40)
end
