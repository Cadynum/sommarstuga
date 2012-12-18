restart -f -nowave
add wave clk rst state byteIn byteOut sendByte sendReady byteAvail tempInAvail elementInAvail setElement getElement getTemp tempDataIn elementDataOut elementDataIn timeOut counter
force clk 0 0ns, 1 5ns -repeat 10ns 
force rst 1 0ns, 0 30ns
force byteIn "01100111" 0ns, "01100101" 50ns
force byteAvail 0 0ns, 1 40ns
force elementInAvail 0 0ns, 1 75ns
force elementDataIn "0000" 0ns, "1010" 75ns
force sendReady 1 0ns, 0 95ns, 1 110ns, 0 125ns
run 140ns

