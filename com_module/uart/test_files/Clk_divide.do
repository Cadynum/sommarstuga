restart -f -nowave
add wave clkIn toggleSync i clkVal clkOut divisor sync
force clkIn 0 0ns, 1 10ns -repeat 20ns 
force toggleSync 0 0ns, 1 290ns
force divisor "000000000000000000000000100"
run 400ns