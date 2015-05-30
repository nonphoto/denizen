math.randomseed(os.time())

math.lerp = function(v0, v1, t)
   return (1 - t) * v0 + (t) * v1
end

math.sign = function(x)
   if x > 0 then return 1 end
   if x == 0 then return 0 end
   if x < 0 then return -1 end
end

function clone(base_object, clone_object)
   if type(base_object) ~= "table" then
      return clone_object or base_object
   end
   clone_object = clone_object or {}
   clone_object.__index = base_object
   return setmetatable(clone_object, clone_object)
end

function isa(clone_object, base_object)
   local clone_object_type = type(clone_object)
   local base_object_type = type(base_object)
   if clone_object_type ~= "table" and base_object_type ~= table then
      return clone_object_type == base_object_type
   end
   local index = clone_object.__index
   local _isa = index == base_object
   while not _isa and index ~= nil do
      index = index.__index
      _isa = index == base_object
   end
   return _isa
end

function array(t)
   result = {}
   for k, v in pairs(t) do
      table.insert(result, v)
   end
   return result
end

function map(f, t)
   local result = {}
   for k, v in pairs(t) do
      result[k] = f(v)
   end
   return result
end

function filter(f, t)
   local result = {}
   for k, v in pairs(t) do
      if f(v) then
	 result[k] = v
      end
   end
   return newtbl
end

function fold(f, x, t)
   for k, v in pairs(t) do
      x = f(x, v)
   end
   return x
end

function reduce(f, t)
   return fold(f, t[1], table.remove(t, 1))
end

function reverse(t)
   local result = {}
   for k, v in pairs(t) do
      result[v] = k
   end
   return result
end

function serialize(o)
   print(type(o))
   local s = ""
   if type(o) == "number" then
      s = s .. o
   elseif type(o) == "string" then
      s = s .. string.format("%q", o)
   elseif type(o) == "table" then
      s = s .. "{/n"
      for k,v in pairs(o) do
	 s = s .. "  ", k, " = "
	 s = s .. serialize(v) .. ",/n"
      end
      s = s .. "}\n"
   else
      error("cannot serialize a " .. type(o))
   end
   return s
end
