require("util")
require("vector")
require("ui")
require("entity")
require("camera")
require("scene")
require("terrain")
require("context")
require("level-editor")
require("animation-editor")

currentMode = "draw"
currentContext = levelEditor
gravity = true

function switchContext(c)
   local context = require("context")
   assert(isa(c, context),
	  "Cannot switch to an object that isn't a clone of 'context'.")
   currentContext.unload()
   currentContext = c
   currentContext.load()
end

mouse = {}
function mouse.screen()
   return vector(love.mouse.getPosition())
end

function mouse.world()
   return camera:toWorldSpace(mouse.screen())
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
   
   currentContext.load()
end

function love.update(dt)
   while channel:getCount() > 0 do
      local value = channel:pop()
      if value then
	 local f = loadstring("return " .. value)
	 print(f())
      end
   end

   currentContext.update(dt)
end

function love.draw()
   currentContext.draw()
   
   love.graphics.setColor(255, 255, 255, 100)
   love.graphics.print(love.timer.getFPS(), 200, 10)
end

function love.keypressed(key)
   currentContext.keypressed(key)
end

function love.keyreleased(key)
   if key == "escape" then love.event.quit() end
   currentContext.keyreleased(key)
end

function love.mousepressed(x, y, button)
   currentContext.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
   currentContext.mousereleased(x, y, button)
end

function love.quit()
   currentContext.unload()
   print()
end

   
   
      
