-- SETUP -----------------------------------------------------------------------
-- Initialize functions and variables here

math.randomseed(os.time())

tileSize = 32

terrain = require("terrain")
player = require("player")

-- LOAD ------------------------------------------------------------------------
-- Called once at the beginning of the game

function love.load()
   print("Loading...")
   
   print("Finished loading.")
end



-- UPDATE ----------------------------------------------------------------------
-- Called when calculating logic

function love.update(dt)
   player:update()
end



-- DRAW ------------------------------------------------------------------------
-- Called when drawing to the screen

function love.draw()
   terrain:draw()
   player:draw()
end
