library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
	generic( clkfreq : positive := 100*10**6
			; interrupt : positive := 10**6
			);
	port	( clk, reset : in std_logic
			; pulse : out std_logic
			);
end entity;

architecture a of timer is
	constant cnt_max : positive := clkfreq/interrupt-1;
	signal cnt : positive range 0 to cnt_max := 0;
	signal active : boolean;
begin
	active <= cnt = cnt_max;
	pulse <= '1' when active else '0';

	process(clk, reset) begin
		if reset = '1' then
			cnt <= 0;
		elsif rising_edge(clk) then
			if active then
				cnt <= 0;
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;

end architecture;

