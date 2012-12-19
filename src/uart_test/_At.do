restart -f -nowave
add wave clk rst at_state receive_state decode_state send_state rec_en dec_en snd_en is_match bin_char enable atByteStreamIn memBus atByteStreamOut sendByteOut
force clk 0 0ns, 1 5ns -repeat 10ns 
force rst 1 0ns, 0 30ns
force atByteStreamIn "00111111" 0ns
force messageAvail 0 0ns, 1 50ns , 0 100ns, 1 150ns
force sendReady 1 0ns, 0 250ns, 1 300ns, 0 350ns, 1 400ns
run 1200ns