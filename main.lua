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

global= {}
global.currentMode = "draw"

function love.load()
   love.graphics.setLineWidth(2)
   -- love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.keypressed(key)
   if key == "escape" then love.event.quit() end
end

function love.keyreleased(key)
   if key == "1" then global.currentMode = "draw" end
   if key == "2" then global.currentMode = "edit" end
   if key == "3" then global.currentMode = "delete" end
end

function love.mousepressed(x, y, button)
   if button == 'l' then
      if love.keyboard.isDown("lctrl") then
	 love.mousepressed(x, y, 'r')
	 return
      end

      if global.currentMode == "draw" then
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
      if global.currentMode == "draw" then
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
      if global.currentMode == "draw" then
	 local p = terrain:pointInRadius(getMouse(), 7)
	 if p then
	    lineEnd = p
	 else
	    lineEnd = getMouse()
	 end
      end
   end
   
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

   if global.currentMode == "draw" then
      love.graphics.setColor(255, 255, 255, 255)
   else
      love.graphics.setColor(255, 255, 255, 100)
   end
   love.graphics.print("[1]: Draw", 10, 10)

   if global.currentMode == "edit" then
      love.graphics.setColor(255, 255, 255, 255)
   else
      love.graphics.setColor(255, 255, 255, 100)
   end
   love.graphics.print("[2]: Edit", 10, 25)

   if global.currentMode == "delete" then
      love.graphics.setColor(255, 255, 255, 255)
   else
      love.graphics.setColor(255, 255, 255, 100)
   end
   love.graphics.print("[3]: Delete", 10, 40)
   
   love.graphics.setColor(255, 255, 255, 100)
   love.graphics.print(love.timer.getFPS(), 200, 10)
end
