-- Start your normal program routines here 
print("Execute code")
dofile("config.lc")
wifi.setmode(wifi.STATION)
wifi.sta.config(ssid,password)
wifi.sta.connect()

ssid=nil
password=nil

-- check if mqtt-client.lc exists before execute
if file.open("mqtt-client.lc") then
     file.close("mqtt-client.lc")
     dofile("mqtt-client.lc")
end