vector = {}
vector.__index = vector

function vector.new(x, y)
   local instance = {}
   instance.x = x or 0
   instance.y = y or 0
   return setmetatable(instance, vector)
end

function vector.__add(a, b)
   if type(a) == "number" then
      return vector.new(b.x + a, b.y + a)
   elseif type(b) == "number" then
      return vector.new(a.x + b, a.y + b)
   else
      return vector.new(a.x + b.x, a.y + b.y)
   end
end

function vector.__sub(a, b)
   if type(a) == "number" then
      return vector.new(b.x - a, b.y - a)
   elseif type(b) == "number" then
      return vector.new(a.x - b, a.y - b)
   else
      return vector.new(a.x - b.x, a.y - b.y)
   end
end

function vector.__mul(a, b)
   if type(a) == "number" then
      return vector.new(b.x * a, b.y * a)
   elseif type(b) == "number" then
      return vector.new(a.x * b, a.y * b)
   else
      return vector.new(a.x * b.x, a.y * b.y)
   end
end

function vector.__div(a, b)
   if type(a) == "number" then
      return vector.new(b.x / a, b.y / a)
   elseif type(b) == "number" then
      return vector.new(a.x / b, a.y / b)
   else
      return vector.new(a.x / b.x, a.y / b.y)
   end
end

function vector.__eq(a, b)
   return a.x == b.x and a.y == b.y
end

function vector.__lt(a, b)
   return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function vector.__le(a, b)
   return a.x <= b.x and a.y <= b.y
end

   -- function vector.__tostring(a)
      -- return "(" .. a.x .. ", " .. a.y .. ")"
   -- end

function vector.distance(a, b)
   return (b - a):len()
end

function vector:unpack()
   return self.x, self.y
end

function vector:len()
   return math.sqrt(self.x * self.x + self.y * self.y)
end

function vector:lenSq()
   return self.x * self.x + self.y * self.y
end

function vector:normalize()
   local l = self:len()
   if l > 0 then
      self = self / l
   end
   return self
end

function vector:abs()
   return vector.new(math.abs(self.x), math.abs(self.y))
end

function vector:rotate(phi)
   local c = math.cos(phi)
   local s = math.sin(phi)
   self.x = c * self.x - s * self.y
   self.y = s * self.x + c * self.y
   return self
end

function vector:floor()
   self.x = math.floor(self.x)
   self.y = math.floor(self.y)
   return self
end

function vector:rotated(phi)
   return self:clone():rotate(phi)
end

function vector:perpendicular()
   return vector.new(-self.y, self.x)
end

function vector:projectOn(other)
   -- return (self * other) * other / other:lenSq()
   local dp = (self.x * other.x + self.y * other.y)
   return vector.new(dp * other.x,
		     dp * other.y)
end

function vector:cross(other)
   return self.x * other.y - self.y * other.x
end
