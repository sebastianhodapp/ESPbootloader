-- Start your normal program routines here 
print("Execute code")
dofile("config.lc")
wifi.setmode(wifi.STATION)
wifi.sta.config(ssid,password)
wifi.sta.connect()

dofile("program.lc")
