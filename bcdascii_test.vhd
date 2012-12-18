library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcdascii_test is
end entity;

architecture a of bcdascii_test is
	signal clk : std_ulogic := '0';
	signal reset : std_ulogic := '1';
	signal ready : std_ulogic;
	signal go : std_ulogic;
	signal rawd : signed(7 downto 0) := x"00";
	
	--type arr is array (natural range<>) of signed(7 downto 0);
	--constant testvec : arr := ("x
	
begin
	module : entity work.bcdascii port map (clk, reset, go, ready, rawd);
	
	process is
		variable testcnt : integer := 0;		
	begin
		wait until reset = '0';
		while true loop
			go <= '1';
			wait until rising_edge(clk);
			go <= '0';
			wait until ready = '1';
			rawd <= rawd + 1;
			wait for 50 ns;
		end loop;
	end process;
		
		

	-- 100Mhz clock
	clk <= not clk after 5 ns;

	reset <= '0' after 1 us;

end architecture;
