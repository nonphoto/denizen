ui = {}
ui.drawList = {}

function ui.draw()
   while ui.drawList[1] do
      local e = table.remove(ui.drawList)
      love.graphics.push()
      love.graphics.translate(e.position.x, e.position.y)
      e.drawFunction()
      love.graphics.pop()
   end
end

ui.hover = nil
ui.active = nil

function ui.mousepressed(x, y, button)
   ui.active = ui.hover
end

function ui.mousereleased(x, y, button)
   ui.active = nil
end


function circleHitbox(r)
   return function(x, p)
      return vector.lenSq(x - p) <= r * r
   end
end

function rectHitbox(hw)
   return function(x, p)
      return x.x >= p.x - hw.x
	 and x.x <= p.x + hw.x
	 and x.y >= p.y - hw.y
	 and x.y <= p.y + hw.y
   end
end

local defaultHitbox = circleHitbox(7)

local function defaultDrawNormal()
   love.graphics.setColor(100, 190, 230)
   love.graphics.circle("fill", 0, 0, 5, 20)
end

local function defaultDrawHover(position)
   love.graphics.setColor(10, 90, 255)
   love.graphics.circle("fill", 0, 0, 5, 20)
end

local function defaultDrawActive(position)
   love.graphics.setColor(230, 50, 50)
   love.graphics.circle("fill", 0, 0, 5, 20)
end

function ui.button(position, hitbox, drawNormal, drawHover, drawActive)
   local widget = {
      position = position or vector(),
      hitbox = hitbox or defaultHitbox,
      drawNormal = drawNormal or defaultDrawNormal,
      drawHover = drawHover or defaultDrawHover,
      drawActive = drawActive or defaultDrawActive,
   }
   
   local call = function(widget)
      if widget == ui.active then
	 ui.drawWidget(widget.drawActive, widget.position)
	 return mouse.world()
      else
	 if widget.hitbox(mouse.world(), widget.position) then
	    ui.drawWidget(widget.drawHover, widget.position)
	    ui.hover = widget
	 else
	    ui.drawWidget(widget.drawNormal, widget.position)
	 end
	 return nil
      end
   end
   
   setmetatable(widget, {__call = call})
   return widget
end

function ui.drawWidget(drawFunction, position)
   assert(type(drawFunction) == "function",
	  "invalid input: " .. tostring(drawFunction) .. " is not a function")
   table.insert(ui.drawList, {drawFunction = drawFunction, position = position})
end
