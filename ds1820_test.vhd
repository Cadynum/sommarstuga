library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onewire.all;

entity ds1820_test is
end entity;

architecture a of ds1820_test is
	signal clk, sensor : std_ulogic := '0';
	signal reset : std_ulogic := '1';
	signal DQ : std_logic;
	signal temperature : signed(7 downto 0);
	signal measure : std_ulogic := '1';
begin
	ds1820:
	entity work.ds1820 port map
		( clk => clk
		, reset => reset
		, valid => open
		, measure => measure
		, temperature => temperature
		, DQ => DQ
		);

	measure <= '0' after 40 us;


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
