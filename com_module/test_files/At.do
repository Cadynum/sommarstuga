restart -f -nowave
add wave clk rst state byteIn byteOut sendByte sendReady byteAvail tempInAvail elementInAvail setElement getElement getTemp tempDataIn elementDataOut elementDataIn
force clk 0 0ns, 1 5ns -repeat 10ns 
force rst 1 0ns, 0 30ns
force byteIn "01100111" 0ns, "01100101" 50ns
force byteAvail 0 0ns, 1 40ns
run 200ns

