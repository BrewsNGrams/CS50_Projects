Gold_Medal = Class{}

function Gold_Medal:init()

  -- Icon made by Pixel perfect from www.flaticon.com
  -- https://www.flaticon.com/authors/smalllikeart
  self.image = love.graphics.newImage('first-place.png')
  self.x = VIRTUAL_WIDTH / 2 - 32
  self.y = VIRTUAL_HEIGHT / 2 - 32

  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
end

function Gold_Medal:render()
  love.graphics.setFont(flappyFont)
  love.graphics.printf('You got 1st place!!!', 0, 64, VIRTUAL_WIDTH, 'center')
  love.graphics.draw(self.image, self.x, self.y - 20, 0, 0.5, 0.5)
end
