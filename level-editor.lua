require("util")
require("context")
require("terrain")
require("scene")
require("camera")
require("entity")

levelEditor = clone(context)

function levelEditor.load()
   terrain:read()
end

function levelEditor.unload()
   terrain:write("quit.sav")
end

function levelEditor.update(dt)
   local v = 1.0
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
	 local wall = terrain:check(mouse.world(), vector(5, 5))
	 if wall then
	    terrain:deleteWall(wall)
	 end
      end
   end
   
   terrain:update()
   player:update()

   camera:move((player.p - camera.p) / 5)
end

function levelEditor.draw()
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
end

function levelEditor.keypressed(key)
   if key == " " then player:jump() end
end

function levelEditor.keyreleased(key)
   if key == "1" then currentMode = "draw" end
   if key == "2" then currentMode = "edit" end
   if key == "3" then currentMode = "delete" end
   if key == "4" then currentMode = "image" end
   if key == "g" then gravity = not gravity end
   if key == "k" then player:reset() end
end

function levelEditor.mousepressed(x, y, button)
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

function levelEditor.mousereleased(x, y, button)
   if button == 'l' then
      if love.keyboard.isDown("lctrl") then
	 love.mousereleased(x, y, 'r')
	 return
      end
      if currentMode == "draw" then
	 if love.keyboard.isDown("lshift") then
	    terrain:newWall(lineEnd, lineStart)
	 else
	    terrain:newWall(lineStart, lineEnd)
	 end
	 lineStart = nil
	 lineEnd = nil
      elseif currentMode == "image" then
	 scene:newImage("missing.png", camera:toWorldSpace(vector(x, y)))
      end
      ui.mousereleased(x, y, button)
   end
end
