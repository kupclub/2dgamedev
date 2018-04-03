local socket = require "socket"
local bitser = require "libs.bitser"

UPDATERATE = 0.1

local t = {}

function t.connect(addr, port)
  local udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(address, port)
  return udp
end

function t.pokeServer(connection, state)
  connection:send(bitser.dumps(state))
end

function t.runServer()
  local udp = socket.udp()

  udp:settimeout(0)
  udp:setsockname('*', 1234)

  while true do
    local data, msg_or_ip, port_or_nil = udp:receivefrom()
    if data then
      local b = bitser.loads(data)
      if type(b) == "table" then
        state = b
      else
        print("unexpected type of data", b)
      end
    end
  end
end

return t
