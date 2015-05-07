-- compile this module if you have memory issues

-- GPIO0 resets the module
gpio.mode(3, gpio.INT)
gpio.trig(3,"both",function()
          node.restart()
     end)
     
-- read previous config
if file.open("config.lc") then
     file.close("config.lc")
     dofile("config.lc")
end

local unescape = function (s)
     s = string.gsub(s, "+", " ")
     s = string.gsub(s, "%%(%x%x)", function (h)
          return string.char(tonumber(h, 16))
         end)
     return s
end

print("Get available APs")
wifi.setmode(wifi.STATION) 
wifi.sta.getap(function(t)
	available_aps = "" 
	if t then 
          local count = 0
		for k,v in pairs(t) do 
			ap = string.format("%-10s",k) 
			ap = trim(ap)
			available_aps = available_aps .. "<option value='".. ap .."'>".. ap .."</option>"
               count = count+1
               if (count>=10) then break end
		end 
          available_aps = available_aps .. "<option value='-1'>---hidden SSID---</option>"
          setup_server()
	end
end)

function setup_server()

     -- Prepare HTML form
     print("Preparing HTML Form")
     if (file.open('configform.html','r')) then
          buf = file.read()
          file.close()
     end
     -- interpret variables in strings
     -- ssid="WLAN01"
     -- str="my ssid is ${ssid}"
     -- interp(str) -> "my ssid is WLAN01"
     buf = buf:gsub('($%b{})', function(w) 
               return _G[w:sub(3, -2)] or "" 
          end)

	print("Setting up Wifi AP")
     wifi.setmode(wifi.SOFTAP)
	local cfg={}
	cfg.ssid = "ESPconfig"
	cfg.pwd  = ""
	wifi.ap.config(cfg)

	print("Setting up webserver")
	local srv = nil
	srv=net.createServer(net.TCP)
	srv:listen(80,function(conn)
    	conn:on("receive", function(client,request)
        	local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        	if(method == nil)then
	            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
    	     end
        	local _GET = {}
        	if (vars ~= nil)then
            	for k, v in string.gmatch(vars, "([_%w]+)=([^%&]+)&*") do
                	_GET[k] = unescape(v)
            	end
	        end
              
    	    if (_GET.password ~= nil and _GET.ssid ~= nil) then
          if (_GET.ssid == "-1") then _GET.ssid=_GET.hiddenssid end
    	    	client:send("Saving data..");
        		file.open("config.lua", "w")
				file.writeline('ssid = "' .. _GET.ssid .. '"')
				file.writeline('password = "' .. _GET.password .. '"')
               -- write every variable in the form 
               for k,v in pairs(_GET) do
                    file.writeline(k..' = "'..v ..'"')
               end 
    			file.close()
    			node.compile("config.lua")
    			file.remove("config.lua")
    			client:send(buf);
		     node.restart();
        	end

          payloadLen = string.len(buf)
          client:send("HTTP/1.1 200 OK\r\n")
          client:send("Content-Type    text/html; charset=UTF-8\r\n")
            
          client:send("Content-Length:" .. tostring(payloadLen) .. "\r\n")
          client:send("Connection:close\r\n\r\n")               
          client:send(buf, function(client) client:close() end);
          end)
	end)
	print("Setting up Webserver done. Please connect to: " .. wifi.ap.getip())
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
