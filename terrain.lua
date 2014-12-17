local Terrain = {}

Terrain.data = {
   {{1, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {1, 1}, },
   {{1, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {1, 1}, },
   {{1, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {1, 1}, },
   {{1, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {1, 1}, },
   {{1, 1}, {1, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 1}, {1, 1}, },
   {{1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, },
   {{1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, },
   {{1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, },
}

tileSize = 32

Terrain.draw = function(self)

   for y = 1, #self.data do
      for x = 1, #self.data[1] do
	 love.graphics.push()
	 love.graphics.setColor(100, 100, 100)
	 love.graphics.translate((x - 1) * tileSize, (y - 1) * tileSize)
	 love.graphics.polygon("fill",
			       0, tileSize - math.floor(tileSize * self.data[y][x][1]),
			       0, tileSize,
			       tileSize, tileSize,
			       tileSize, tileSize - math.floor(tileSize * self.data[y][x][2]))
	 love.graphics.pop()
      end
   end
end

return Terrain
