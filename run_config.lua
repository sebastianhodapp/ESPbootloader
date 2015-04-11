
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

-- function to interpret variables in strings
-- ssid="WLAN01"
-- str="my ssid is ${ssid}"
-- interp(str) -> "my ssid is WLAN01"
function interp(s)
  return (s:gsub('($%b{})', function(w) 
          return _G[w:sub(3, -2)] or "" 
     end))
end


print("Get available APs")
wifi.setmode(wifi.STATION) 
wifi.sta.getap(function(t)
	available_aps = "" 
	if t then 
		for k,v in pairs(t) do 
			ap = string.format("%-10s",k) 
			ap = trim(ap)
			available_aps = available_aps .. "<option value='".. ap .."'>".. ap .."</option>"
		end 
          available_aps = available_aps .. "<option value='-1'>--hidden--</option>"
          setup_server(available_aps)
	end
end)



function setup_server(aps)
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
        	local buf = "";
        	local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        	if(method == nil)then
	            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
    	     end
        	local _GET = {}
        	if (vars ~= nil)then
            	for k, v in string.gmatch(vars, "([_%w]+)=([^&]+)&*") do
                	_GET[k] = v
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
    
          if (file.open('configform.html','r')) then
               -- make aps variable global to use in interp
               _G.aps=aps
               buf = interp(file.read())
               file.close()
          end
	     
          payloadLen = string.len(buf)
          client:send("HTTP/1.1 200 OK\r\n")
          client:send("Content-Type    text/html; charset=UTF-8\r\n")
            
          client:send("Content-Length:" .. tostring(payloadLen) .. "\r\n")
          client:send("Connection:close\r\n\r\n")               
    	     client:send(buf);
        	client:close();
          end)
	end)
	print("Setting up Webserver done. Please connect to: " .. wifi.ap.getip())
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
