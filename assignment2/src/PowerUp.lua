PowerUp = Class {}

function PowerUp:init(x, y)
  self.x = x
  self.y = y
  self.ability = math.random(2)

  self.dx = 0
  self.dy = 50

  self.width = 16
  self.height = 16
end

function PowerUp:collides(target)
  if self.x > target.x + target.width or target.x > self.x + self.width then
      return false
  end

  if self.y > target.y + target.height or target.y > self.y + self.height then
      return false
  end

  return true
end

function PowerUp:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end

function PowerUp:render()
  if self.ability == 1 then
    love.graphics.draw(gTextures['main'], gFrames['pwrups'][4], self.x + 8, self.y)
  else
    love.graphics.draw(gTextures['main'], gFrames['pwrups'][10], self.x + 8, self.y)
  end
end
