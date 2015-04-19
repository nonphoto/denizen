local channel = love.thread.getChannel("console")
local s = ""
while true do
      -- io.write("denizen -> ")
   local s = io.read()
   channel:supply(s)
end
