-- Class with which to hold the bronze medal sprite as well as the message given to players who score high enough to get bronze

Bronze_Medal = Class{}

function Bronze_Medal:init()

  -- Icon made by Pixel perfect from www.flaticon.com
  -- https://www.flaticon.com/authors/smalllikeart
  self.image = love.graphics.newImage('third-place.png')
  self.x = VIRTUAL_WIDTH / 2 - 32
  self.y = VIRTUAL_HEIGHT / 2 - 32

  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
end

function Bronze_Medal:render()
  love.graphics.setFont(flappyFont)
  love.graphics.printf('You got 3rd place!', 0, 64, VIRTUAL_WIDTH, 'center')
  love.graphics.draw(self.image, self.x, self.y - 20, 0, 0.5, 0.5)
end
