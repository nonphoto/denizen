local ui = {}
ui.drawList = {}

function ui:draw()
   while self.drawList[1] do
      local f = table.remove(self.drawList)
      f()
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

ui.lastid = 0
function ui:newid()
   self.lastid = self.lastid + 1
   return self.lastid
end

ui.hoverid = nil
ui.activeid = nil

function ui:mousepressed(x, y, button)
   if button == 'r' then
      self.activeid = self.hoverid
   end
end

function ui:mousereleased(x, y, button)
   if button == 'r' then
      self.activeid = nil
   end
end

function ui:handle(id, position, radius)
   local mouse = vector(love.mouse.getX(), love.mouse.getY())
   if vector.lenSq(position - mouse) <= radius * radius then
      self:drawWidget(function()
	    love.graphics.setColor(255, 0, 0)
	    love.graphics.circle("fill", position.x, position.y, radius, 10)
      end)
      self.hoverid = id
   else
      self:drawWidget(function()
	    love.graphics.setColor(80, 150, 255)
	    love.graphics.circle("fill", position.x, position.y, radius, 10)
      end)
   end

   if id == self.activeid then
      return mouse
   end
end

function ui:drawWidget(drawFunction)
   table.insert(self.drawList, drawFunction)
end

return ui
