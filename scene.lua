scene = {}
scene.textures = {}

function scene:newImage(filename, position)
   local image = love.graphics.newImage(filename)
   table.insert(self.textures, {image = image, position = position})
end

function scene:draw()
   love.graphics.setColor(255, 255, 255, 255)
   for k, v in pairs(self.textures) do
      love.graphics.draw(v.image, v.position:unpack())
   end
end
