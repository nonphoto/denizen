require("vector")

entity = {}
entity.p = vector()
entity.pp = vector(entity.p.x, entity.p.y)
entity.w = vector(50, 100)
entity.hw = entity.w / 2
entity.v = vector()
entity.a = vector()
entity.cs = "none"
entity.cj = false
entity.iw = {}

function entity:update()

   -- Test for a collision with the terrain and project out of it if necessary
   -- BUG: entities pass through all walls when intersecting, not just the first wall it intersected
   -- Either entity needs to receive multiple projections, or collide needs to handle intersections
   local projection, intersections = terrain:collide(self.p, self.hw, self.iw)
   self.p = self.p + projection
   self.iw = intersections

   -- BUG: entity passes through convex corners
   -- possible fix: make it so some walls are solid on both sides
   
   -- Only allow jumping when the entity was projected out of a wall
   -- BUG: entity can jump on any slope
   if projection ~= vector() then
      self.cj = true
   else
      self.cj = false
   end
   
   -- Verlet integration: entities keep their momentum
   local v = self.p - self.pp
   self.pp.x = self.p.x
   self.pp.y = self.p.y

   -- Friction
   self.p = self.p + (v * 0.9)

   -- Gravity
   if gravity then
      self.p.y = self.p.y + 1
   end
end

function entity:draw()
   love.graphics.setColor(255, 255, 255, 100)
   love.graphics.rectangle("fill",
			   self.p.x - self.hw.x,
			   self.p.y - self.hw.y,
			   self.w.x,
			   self.w.y)
end

function entity:jump()
   if self.cj then
      -- TODO: function to change velocity
      self.pp.y = self.pp.y + 15
      self.cj = false
   end
end

function entity:move(x, y)
   if type(x) == "table" then
      self.p = self.p + x
   else
      self.p.x = self.p.x + (x or 0)
      self.p.y = self.p.y + (y or 0)
   end
end

function entity:reset()
   self.p = vector()
   self.pp = vector()
end

return entity
