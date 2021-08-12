--State that shows the user the controls for the game

ButtonState = Class{__includes = BaseState}

function ButtonState:update(dt)
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    gStateMachine:change('countdown')
  end
end

function ButtonState:render()
  love.graphics.setFont(flappyFont)
  love.graphics.printf('Controls', 0, 64, VIRTUAL_WIDTH, 'center')

  love.graphics.setFont(mediumFont)
  love.graphics.printf('Press\n\'SPACE\'\nto Jump', 0, 120, VIRTUAL_WIDTH / 2, 'center')
  love.graphics.printf('Press\n\'P\'\n to Pause', VIRTUAL_WIDTH / 2, 120, VIRTUAL_WIDTH / 2, 'center')

  love.graphics.setFont(flappyFont)
  love.graphics.printf('Press Enter to Play', 0, 200, VIRTUAL_WIDTH, 'center')
end
