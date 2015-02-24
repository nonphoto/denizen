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

local global = {}

global.mouse = vector()

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
      lineStart = vector(x, y)
      lineEnd = vector(x, y)
   end
   ui.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
   if button == 'l' then
      if love.keyboard.isDown("lctrl") then
	 love.mousereleased(x, y, 'r')
	 return
      end
      terrain:newLine(lineStart, lineEnd)
      lineStart = nil
      lineEnd = nil
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
      local mouse = vector(love.mouse.getPosition())
      lineEnd = mouse
      local x = terrain:pointInRadius(mouse, 7)
      if x then lineEnd = x end
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
   love.graphics.setColor(255, 255, 255, 100)
   love.graphics.print(love.timer.getFPS(), 10, 10)
end
