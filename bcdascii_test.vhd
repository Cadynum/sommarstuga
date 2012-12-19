library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Defs.char_array;
use work.Defs.asciichr;
use work.bcdascii_p.all;

entity bcdascii_test is
end entity;

architecture a of bcdascii_test is
	signal clk : std_ulogic := '0';
	signal reset : std_ulogic := '1';
	signal ready : std_ulogic;
	signal go : std_ulogic;
	signal rawd : signed(7 downto 0) := "10000000";
	signal mem : char_array(0 to 100);
	signal mem_len : bcdbuf_t;
	signal chr : asciichr;
	signal chr_max : bcdbuf_t;
	signal chr_sel : bcdbuf_t;

	function caToString (din : char_array; len : natural) return string is
		variable dout : string(1 to len);
	begin
		for i in 0 to len-1 loop
			dout(i+1) := character'val(to_integer(unsigned(din(i))));
		end loop;
		return dout;
	end function;
begin
	module : entity work.bcdascii port map (clk, reset, go, ready, rawd,
		chr, chr_sel, chr_max);

	process is
		variable testcnt : integer := 0;
	begin
		wait until reset = '0';
		for i in 0 to 255 loop
			go <= '1';
			wait until rising_edge(clk);
			go <= '0';
			wait until ready = '1';

			for jj in 0 to chr_max loop
				chr_sel <= jj;
				wait until clk'event;
				mem(jj) <= chr;
			end loop;
			report caToString(mem, chr_max+1);

			rawd <= rawd + 1;
			wait for 50 ns;
		end loop;
		report "NONE. End of simulation." severity failure;
	end process;



	-- 100Mhz clock
	clk <= not clk after 5 ns;

	reset <= '0' after 1 us;

end architecture;
