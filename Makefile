# Path to nodemcu-uploader (https://github.com/kmpm/nodemcu-uploader)
UPLOADER=./uploader.py
# Serial port
PORT=/dev/cu.usbserial
BAUD=9600

HTML_FILES := $(wildcard html/*)
LUA_FILES := init.lua run_config.lua run_program.lua

# Help
help:
	@echo ""
	@echo "******** ESPbootloader Makefile options ********"
	@echo ""
	@echo "(1)"
	@echo "make should be installed, verify if not sure (i.e. \"which make\")"
	@echo ""
	@echo "(2)"
	@echo "\"make all\" --> uploads all files"
	@echo ""
	@echo "(3)"
	@echo "\"make html\" --> uploads html folder with files"
	@echo ""
	@echo "(4)"
	@echo "optional parameters may be passed in to specify port and baudrate:"
	@echo "e.g. \"make all PORT:=/dev/tty.usb_evs BAUD:=115200\""
	@echo ""

# Upload files
all: $(LUA_FILES) $(HTML_FILES)
ifneq ($(strip $(port)),) 
override PORT = $(port)
endif
ifneq ($(strip $(baud)),) 
override BAUD = $(baud)
endif
	@echo "Flashing with PORT $(PORT) and BAUDRATE $(BAUD)"
	@$(UPLOADER) -b $(BAUD) -p $(PORT) upload $(foreach f, $^, $(f))

html: $(HTML_FILES)
ifneq ($(strip $(port)),) 
override PORT = $(port)
endif
ifneq ($(strip $(baud)),) 
override BAUD = $(baud)
endif
	@echo "Flashing with PORT $(PORT) and BAUDRATE $(BAUD)"
	@$(UPLOADER) -b $(BAUD) -p $(PORT) upload $(foreach f, $^, $(f))