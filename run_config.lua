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
		setup_server(available_aps)
	end
end)

function setup_server(aps)
	print("Setting up Wifi AP")
	wifi.setmode(wifi.SOFTAP)
	cfg={}
	cfg.ssid = ssid
	cfg.pwd  = psw
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
            	for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                	_GET[k] = v
            	end
	        end
              
    	    if (_GET.psw ~= nil and _GET.ap ~= nil) then
    	    	client:send("Saving data..");
        		file.open("config.lua", "w")
				file.writeline('ssid = "' .. _GET.ap .. '"')
				file.writeline('password = "' .. _GET.psw .. '"')
    			file.close()
    			node.compile("config.lua")
    			file.remove("config.lua")
    			client:send(buf);
				node.restart();
        	end
    
        	buf = "<html><body>"
        	buf = buf .. "<form method='get' action='http://" .. wifi.ap.getip() .."'>"
	      	buf = buf .. "Select access point: <select name='ap'>" .. aps .. "</select><br>"
	      	buf = buf .. "Enter password: <input type='password' name='psw'></input><br><br><button type='submit'>Save</button></form>"
	      	buf = buf .. "</body></html>" 
    	    client:send(buf);
        	client:close();
	        collectgarbage();
    	end)
	end)
	print("Setting up Webserver done. Please connect to: " .. wifi.ap.getip())
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
