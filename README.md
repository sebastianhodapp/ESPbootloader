# ESPbootloader
Bootloader for ESP8266 modules flashed with NodeMCU for simple wifi configuration.

<img width='300' src='http://www.sebastian-hodapp.de/wp-content/uploads/images/espbootloader-comfortable-wifi-configuration/github_espbootloader.jpg'>

# How does it work?
The script checks whether there is already a wifi configured. If not, the configuration mode is started. You can force to boot in config mode even when there is a config file, by connecting GPIO0 to ground anytime in the 5 seconds countdown at init.

The ESP8266 provides an access point and webpage listing all available access points plus possibility to enter the wifi password and any other configuration parameters.

These settings are stored persistently in the file *config.lc* and the module connects with to the network to run your normal code.

# How to use it
* Modify the *configform.html* file to include any configuration parameters that you need in your scripts.
* Add your normal program routines to file *run_program.lua*
* Upload all files to your ESP8266 module

# License
Copyright (c) 2015 [Sebastian Hodapp](http://www.sebastian-hodapp.de) Licensed under the [The MIT License (MIT)](http://opensource.org/licenses/MIT).
