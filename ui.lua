local ui = {}
ui.drawList = {}

function ui.draw()
   while ui.drawList[1] do
      local f = table.remove(ui.drawList)
      f()
   end
end

ui.hover = nil
ui.active = nil

function ui.mousepressed(x, y, button)
   if button == 'r' then
      ui.active = ui.hover
   end
end

function ui.mousereleased(x, y, button)
   if button == 'r' then
      ui.active = nil
   end
end

function ui.handle()
      -- sneaky trick to give widgets their own identity
   local widget = {}
   return function(position, radius)
      local mouse = vector(love.mouse.getPosition())
      if vector.lenSq(position - mouse) < radius * radius then
	 ui.drawWidget(function()
	       love.graphics.setColor(255, 0, 0)
				    love.graphics.circle("fill", position.x, position.y, radius, 10)
			      end)
			      ui.hover = widget
			   else
			      ui.drawWidget(function()
				    love.graphics.setColor(80, 150, 255)
				    love.graphics.circle("fill", position.x, position.y, radius, 10)
			      end)
			   end

			   if widget == ui.active then
			      return mouse
			   end
   end
end

function ui.drawWidget(drawFunction)
   table.insert(ui.drawList, drawFunction)
end

return ui
