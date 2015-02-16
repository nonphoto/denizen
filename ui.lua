local ui = {}
ui.elements = {}

function ui:draw()
   for k, v in pairs(self.elements) do
      v:draw()
   end
end

function ui:createDraggable(position, callback)
   local result = {}
   result.position = position

   result.draw = function(self)
      love.graphics.setColor(80, 150, 255)
      love.graphics.circle("fill", self.position.x, self.position.y, 5, 10)
   end

   result.mousePressed = function(self, x, y, button)   
      callback(self.position)
   end
   
   table.insert(self.elements, result)
   return result
end

return ui
