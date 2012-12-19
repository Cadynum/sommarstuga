library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer_test is
end entity;

architecture a of timer_test is
	signal clk : std_logic := '0';
	signal reset : std_logic := '1';
	signal pulse : std_logic;
begin
	-- 100Mhz clock
	clk <= not clk after 5 ns;
	reset <= '0' after 5 us;
	
	TC : entity work.timer port map (clk, reset, pulse);
	
end architecture;

