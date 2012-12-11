library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onewire.all;

entity dispatch_test is
end entity;

architecture a of dispatch_test is
	signal clk, sensor : std_ulogic := '0';
	signal reset : std_ulogic := '1';
	signal DQ : std_logic;
begin
	dispatch:
	entity work.dispatch port map
		( clk => clk
		, reset => reset
		, led => open
		, DQ => DQ
		);



	-- Simulate open drain with high pullup resistor
	process (DQ) begin
		if DQ = 'Z' then
			DQ <= '1';
		elsif DQ = 'X' or DQ = 'U' then
			DQ <= 'Z';
		end if;
	end process;

	DQ <= sensor;


	-- Simulate the DS1820.
	-- Only reset implemented
	process begin
		sensor <= 'Z';
		wait until DQ'stable(480 us) and DQ = '0';
		wait until DQ = '1';
		wait for 15 us;
		sensor <= '0';
		wait for 130 us;
	end process;

	-- 100Mhz clock
	clk <= not clk after 5 ns;

	reset <= '0' after 5 us;

end architecture;
