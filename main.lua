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
context = require("context")
ui = require("ui")
levelEditor = require("level-editor")
animationEditor = require("animation-editor")

require("vector")

currentMode = "draw"
currentContext = levelEditor
gravity = true

function switchContext(c)
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

   
   
      
