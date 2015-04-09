-- GPIO0 resets the module
gpio.mode(3, gpio.INT)
gpio.trig(3,"both",function()
          node.restart()
     end)

if file.open("config.lc") then
     file.close("config.lc")
     dofile("config.lc")
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
	cfg={}
	cfg.ssid = "ESP8266config"
	cfg.pwd  = ""
	wifi.ap.config(cfg)

	print("Setting up webserver")
	srv = nil
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
    
        	buf = "<html><body>"
        	buf = buf .. "<form method='get' action='http://" .. wifi.ap.getip() .."'>"
          buf = buf .. "Select access point: <select name='ssid'>" .. aps .. "</select><br>"
          buf = buf .. "(or type hidden ssid): <input name='hiddenssid'></input><br>"
          buf = buf .. "Enter password: <input type='password' name='password'></input><br><br>"
          -- add custom variables to the form in a .html file
          if (file.open('configvars.html','r')) then
               buf = buf .. file.read()
               file.close()
          end
	     buf = buf .. "<button type='submit'>Save</button></form></body></html>" 
        
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
