Silver_Medal = Class{}

function Silver_Medal:init()

  -- Icon made by Pixel perfect from www.flaticon.com
  -- https://www.flaticon.com/authors/smalllikeart
  self.image = love.graphics.newImage('second-place.png')
  self.x = VIRTUAL_WIDTH / 2 - 32
  self.y = VIRTUAL_HEIGHT / 2 - 32

  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
end

function Silver_Medal:render()
  love.graphics.setFont(flappyFont)
  love.graphics.printf('You got 2nd place!!', 0, 64, VIRTUAL_WIDTH, 'center')
  love.graphics.draw(self.image, self.x, self.y - 20, 0, 0.5, 0.5)
end
