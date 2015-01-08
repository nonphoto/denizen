-- SETUP -----------------------------------------------------------------------
-- Initialize functions and variables here

math.randomseed(os.time())
math.lerp = function(v0, v1, t)
   return (1 - t) * v0 + (t) * v1
end

tileSize = 32

inspect = require("inspect")
terrain = require("terrain")
player = require("player")

-- LOAD ------------------------------------------------------------------------
-- Called once at the beginning of the game

function love.load()
   print("Loading...")

   love.graphics.setLineWidth(2)
   love.graphics.setDefaultFilter("nearest", "nearest")
   
   print("Finished loading.")
end

function love.keypressed(key)
   if key == "escape" then love.event.quit() end
end



-- UPDATE ----------------------------------------------------------------------
-- Called when calculating logic

function love.update(dt)
   local v = 1.5
   if love.keyboard.isDown("up")    then player:move( 0, -v) end
   if love.keyboard.isDown("down")  then player:move( 0,  v) end
   if love.keyboard.isDown("left")  then player:move(-v,  0) end
   if love.keyboard.isDown("right") then player:move( v,  0) end
   player:update()
end



-- DRAW ------------------------------------------------------------------------
-- Called when drawing to the screen

function love.draw()
   terrain:draw()
   player:draw()
end
