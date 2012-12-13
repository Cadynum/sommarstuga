restart -f -nowave
add wave clk rst state enable readWrite address addressHigh timerEnable timeOut counter messageAvail sendReady atByteStreamIn memBus atByteStreamOut sendByteOut
force clk 0 0ns, 1 5ns -repeat 10ns 
force rst 1 0ns, 0 30ns
force atByteStreamIn "00000000" 0ns, "11110000" 50ns, "00001111" 100ns
force messageAvail 0 0ns, 1 50ns , 0 100ns, 1 150ns
force sendReady 1 0ns, 0 250ns, 1 300ns, 0 350ns, 1 400ns
run 1200ns