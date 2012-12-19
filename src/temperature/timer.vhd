library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
	generic ( clkfreq : positive := 100*10**6 -- 100Mhz
			; interrupt : positive := 10**6 -- 1usec
			);
	port	( clk, reset : in std_ulogic
			; reset_timer : in boolean
			; pulse : buffer boolean
			);
end entity;

architecture a of timer is
	constant cnt_max : integer := clkfreq/interrupt-1;
	signal cnt : integer range 0 to cnt_max := 0;
begin
	pulse <= cnt = cnt_max;

	process(clk, reset) begin
		if reset = '1' then
			cnt <= 0;
		elsif rising_edge(clk) then
			if pulse or reset_timer then
				cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;

end architecture;

