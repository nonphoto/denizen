require("util")

Map = {}

Map.update = function(self)
   self.batch:bind()
   self.batch:clear()
   for y = 1, self.data.h do
      for x = 1, self.data.w do
	 if self.data[y][x] > 0 then
	    self.batch:add(self.tiles[self.data[y][x]], x * self.tiles.size, y * self.tiles.size)
	 end
      end
   end
   self.batch:unbind()
end

Map.draw = function(self, x, y)
   love.graphics.setColor(255, 255, 255)
   love.graphics.draw(self.batch, x, y)
end

Map.loadData = function(imageName)
   local result = {}
   local imageData = love.image.newImageData(imageName)
   result.w = imageData:getWidth()
   result.h = imageData:getHeight()
   for j = 1, result.h do
      result[j] = {}
      for i = 1, result.w do
	 local color = imageData:getPixel(i - 1, j - 1)
	 local value = math.floor((color + 1) / 16)
	 result[j][i] = value
      end
   end
   return result
end

Map.loadTiles = function(tilesetName, tileSize)
   local result = {}
   result.size = tileSize
   result.image = love.graphics.newImage(tilesetName)
   result.image:setFilter("nearest", "nearest")
   result.w = result.image:getWidth() / tileSize
   result.h = result.image:getHeight() / tileSize
   for j = 0, result.h - 1 do 
      for i = 0, result.w - 1 do
	 result[j * result.w + i + 1] = love.graphics.newQuad(
	    i * tileSize,
	    j * tileSize,
	    tileSize,
	    tileSize,
	    result.image:getWidth(),
	    result.image:getHeight())
      end
   end
   return result
end

Map.loadTerrain = function(imageName)
   local result = {}
   local imageData = love.image.newImageData(imageName)
   local w = imageData:getWidth()
   local h = imageData:getHeight()
   for j = 1, h do
      result[j] = {}
      for i = 1, w do
	 local c = {}
	 c.r, c.g, c.b = imageData:getPixel(i - 1, j - 1)

	 if colorEquals(c, 255, 255, 255) then
	    result[j][i] = true
	 elseif colorEquals(c, 0, 0, 0) then
	    result[j][i] = false
	 elseif colorEquals(c, 255, 0, 0) then
	    result.spawn1 = {
	       x = i,
	       y = j
	    }
	 elseif colorEquals(c, 0, 0, 255) then
	    result.spawn2 = {
	       x = i,
	       y = j
	    }
	 end
      end
   end
   -- print(inspect(result))
   return result
end

Map.new = function(dataName, tilesetName, terrainName, tileSize)
   local result = clone(Map)
   result.data = Map.loadData(dataName)
   result.tiles = Map.loadTiles(tilesetName, tileSize)
   if (terrainName) then result.terrain = Map.loadTerrain(terrainName) end
   result.batch = love.graphics.newSpriteBatch(result.tiles.image, result.data.w * result.data.h)
   result:update()
   return result
end

function Map:inBounds(x, y)
   local xCoord = math.floor(x/self.tiles.size)
   local yCoord = math.floor(y/self.tiles.size)
   return not self.terrain[yCoord][xCoord]
end
