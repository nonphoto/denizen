camera = {}
camera.p = vector()
camera.s = 1
camera.a = 0

function camera:set()
   love.graphics.push()
   love.graphics.rotate(-self.a)
   love.graphics.scale(1 / self.s, 1 / self.s)
   love.graphics.translate(
	 -self.p.x + love.graphics.getWidth() / 2 * self.s,
	 -self.p.y + love.graphics.getHeight() / 2 * self.s)
end

function camera:unset()
   love.graphics.pop()
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.rectangle(
      "fill",
      love.graphics.getWidth() / 2 - 1,
      love.graphics.getHeight() / 2 - 1, 3, 3)
end

function camera:move(d)
   self.p = self.p + d
end

function camera:rotate(a)
   self.a = self.a + a
end

function camera:scale(s)
   self.s = self.s * s
end

function camera:toWorldSpace(v)
   return v + self.p - vector(love.graphics.getWidth(), love.graphics.getHeight()) / 2
end
