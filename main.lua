math.randomseed(os.time())
math.lerp = function(v0, v1, t)
   return (1 - t) * v0 + (t) * v1
end
math.sign = function(x)
   if x > 0 then return 1 end
   if x == 0 then return 0 end
   if x < 0 then return -1 end
end

inspect = require("inspect")
terrain = require("terrain")
player = require("entity")
ui = require("ui")

require("vector")

function getMouse()
   return vector(love.mouse.getPosition())
end

menu = {}
menu.modes = {
   draw = ui.button(vector(20, 20)),
   edit = ui.button(vector(40, 20)),
   play = ui.button(vector(60, 20))
}
menu.currentMode = "draw"

function love.load()
   love.graphics.setLineWidth(2)
   -- love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.keypressed(key)
   if key == "escape" then love.event.quit() end
end

function love.mousepressed(x, y, button)
   if button == 'l' then
      if love.keyboard.isDown("lctrl") then
	 love.mousepressed(x, y, 'r')
	 return
      end

      if menu.currentMode == "draw" then
	 local p = terrain:pointInRadius(getMouse(), 7)
	 if p then
	    lineStart = p
	 else
	    lineStart = vector(x, y)
	 end
	 lineEnd = vector(x, y)
      end
   end
   ui.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
   if button == 'l' then
      if love.keyboard.isDown("lctrl") then
	 love.mousereleased(x, y, 'r')
	 return
      end
      if menu.currentMode == "draw" then
	 terrain:newLine(lineStart, lineEnd)
	 lineStart = nil
	 lineEnd = nil
      end
   end
   ui.mousereleased(x, y, button)
end

function love.update(dt)
   local v = 1.5
   if love.keyboard.isDown("up")    then player:move( 0, -v) end
   if love.keyboard.isDown("down")  then player:move( 0,  v) end
   if love.keyboard.isDown("left")  then player:move(-v,  0) end
   if love.keyboard.isDown("right") then player:move( v,  0) end
   if love.mouse.isDown("l") then
      if menu.currentMode == "draw" then
	 local p = terrain:pointInRadius(getMouse(), 7)
	 if p then
	    lineEnd = p
	 else
	    lineEnd = getMouse()
	 end
      end
   end

   if menu.modes.draw() then menu.currentMode = "draw" end
   if menu.modes.edit() then menu.currentMode = "edit" end
   if menu.modes.play() then menu.currentMode = "play" end
   
   terrain:update()
   player:update()
end

function love.draw()
   terrain:draw()
   if lineStart then
      love.graphics.setColor(255, 255, 255, 100)
      love.graphics.line(lineStart.x, lineStart.y, lineEnd.x, lineEnd.y)
   end
   player:draw()
   ui.draw()
   love.graphics.setColor(255, 255, 255, 100)
   love.graphics.print(love.timer.getFPS(), 10, 10)
end
