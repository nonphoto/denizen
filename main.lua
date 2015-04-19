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
scene = require("scene")
player = require("entity")
camera = require("camera")
ui = require("ui")

require("vector")

currentMode = "draw"
gravity = true

mouse = {}
mouse.screen = function()
   return vector(love.mouse.getPosition())
end

mouse.world = function()
   return camera:toWorldSpace(mouse.screen())
end

function bang()
   --print("!")
   return "!"
end

function quit()
   love.event.quit()
end

function love.load()
   love.graphics.setLineWidth(2)
   -- love.graphics.setDefaultFilter("nearest", "nearest")

   channel = love.thread.getChannel("console");
   thread = love.thread.newThread("console.lua");
   thread:start();

   terrain:read()
end

function love.update(dt)
   while channel:getCount() > 0 do
      local value = channel:pop()
      if value then
	 local f = loadstring("return " .. value)
	 print(f())
      end
   end
   
   local v = 1.5
   if love.keyboard.isDown("up") or love.keyboard.isDown("w")    then player:move( 0, -v) end
   if love.keyboard.isDown("down") or love.keyboard.isDown("s")  then player:move( 0,  v) end
   if love.keyboard.isDown("left") or love.keyboard.isDown("a")  then player:move(-v,  0) end
   if love.keyboard.isDown("right") or love.keyboard.isDown("d") then player:move( v,  0) end
   
   if love.mouse.isDown("l") then
      if currentMode == "draw" then
	 local p = terrain:pointInRadius(mouse.world(), 10)
	 if p then
	    lineEnd = p
	 else
	    lineEnd = mouse.world()
	 end
      elseif currentMode == "delete" then
	 local _, wall, _ = terrain:collide(mouse.world(), vector(5, 5))
	 if wall then
	    terrain:deleteWall(wall)
	 end
      end
   end
   
   terrain:update()
   player:update()

   local d = (player.p - camera.p) / 5
   camera:move(d)
end

function love.draw()
   camera:set()
   scene:draw()
   terrain:draw()
   if lineStart then
      love.graphics.setColor(255, 255, 255, 100)
      love.graphics.line(lineStart.x, lineStart.y, lineEnd.x, lineEnd.y)
   end
   player:draw()
   ui.draw()

   camera:unset()

   -- TODO: Find a way to make this less terrible
   if currentMode == "draw" then
      love.graphics.setColor(255, 255, 255, 255)
   else
      love.graphics.setColor(255, 255, 255, 100)
   end
   love.graphics.print("[1]: Draw", 10, 10)

   if currentMode == "edit" then
      love.graphics.setColor(255, 255, 255, 255)
   else
      love.graphics.setColor(255, 255, 255, 100)
   end
   love.graphics.print("[2]: Edit", 10, 25)

   if currentMode == "delete" then
      love.graphics.setColor(255, 0, 0, 255)
      local x, y = mouse.screen():unpack()
      love.graphics.rectangle("fill", x - 5, y - 5, 10, 10)
      love.graphics.setColor(255, 255, 255, 255)
   else
      love.graphics.setColor(255, 255, 255, 100)
   end
   love.graphics.print("[3]: Delete", 10, 40)

   if currentMode == "image" then
      love.graphics.setColor(255, 255, 255, 255)
   else
      love.graphics.setColor(255, 255, 255, 100)
   end
   love.graphics.print("[4]: Image", 10, 55)
   
   love.graphics.setColor(255, 255, 255, 100)
   love.graphics.print(love.timer.getFPS(), 200, 10)
end

function love.keypressed(key)
   if key == "escape" then love.event.quit() end
   if key == " " then player:jump() end
end

function love.keyreleased(key)
   if key == "1" then currentMode = "draw" end
   if key == "2" then currentMode = "edit" end
   if key == "3" then currentMode = "delete" end
   if key == "4" then currentMode = "image" end
   if key == "g" then gravity = not gravity end
   if key == "k" then player:reset() end
end

function love.mousepressed(x, y, button)
   if button == 'l' then
      if love.keyboard.isDown("lctrl") then
	 love.mousepressed(x, y, 'r')
	 return
      end

      local m = camera:toWorldSpace(vector(x, y))

      if currentMode == "draw" then
	 local p = terrain:pointInRadius(m, 10)
	 if p then
	    lineStart = p
	 else
	    lineStart = m
	 end
	 lineEnd = m
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
      if currentMode == "draw" then
	 terrain:newWall(lineStart, lineEnd)
	 lineStart = nil
	 lineEnd = nil
      elseif currentMode == "image" then
	 scene:newImage("missing.png", camera:toWorldSpace(vector(x, y)))
      end
      ui.mousereleased(x, y, button)
   end
end

function love.quit()
   terrain:write("quit.sav")
   print()
end

   
   
      
