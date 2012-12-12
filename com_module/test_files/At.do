restart -f -nowave
add wave clk rst state enable readWrite address timerEnable timeOut counter messageAvail sendReady atByteStreamIn memBus atByteStreamOut sendByteOut send
force clk 0 0ns, 1 5ns -repeat 10ns 
force rst 1 0ns, 0 40ns
force atByteStreamIn "11110000" 0ns, "00001111" 15ns -repeat 30ns 
force messageAvail 0 0ns, 1 100ns , 0 200ns, 1 300ns, 0 400ns, 1 500ns, 0 600ns, 1 700ns, 0 800ns, 1 900ns, 0 1000ns, 1 1500ns
force sendReady 1 0ns, 0 1395ns, 1 1445ns, 0 1495ns, 1 1545ns
run 2000ns