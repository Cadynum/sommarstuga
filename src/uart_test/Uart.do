restart -f -nowave
add wave rst tx rx txByte rxByte txSend txReady rxReady ref tmpTx TmpRx
force clk 0 0ns, 1 5ns -repeat 10ns 
force rst 1 0ns, 0 0.2ms
force txByte "10100101"
force txSend 0 0ms, 1 0.3ms
run 3ms