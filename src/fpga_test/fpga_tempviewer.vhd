library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onewire.all;
use work.Defs.char_array;
use work.Defs.asciichr;


entity fpga_tempviewer is
	port	( clk, reset : in std_ulogic
			; DQ : inout std_logic
			; an : buffer std_ulogic_vector(3 downto 0)
			; seg : buffer std_ulogic_vector(7 downto 0)
			; led : buffer asciichr
			);
end entity;


architecture a of fpga_tempviewer is
	signal temperature : signed(7 downto 0);
	
	signal pulse : boolean;
	signal cnt, mem_len : integer range 0 to 5;
	signal troll : char_array(0 to 5) := (x"30", x"31", x"32", x"33", x"34",x"35");
begin
	sensor:
	entity work.ds18s20 port map
		( clk => clk
		, reset => reset
		, valid => open
		, measure => '1'
		, DQ => DQ
		, temperature => temperature
		);

	display:
	entity work.segment_temperature port map(clk, reset, temperature, an, seg);
	
	lol:
	entity work.bcdascii port map(clk => clk
		, reset => reset
		, go => '1'
		, ready => open
		, rawd => temperature
		, chr_sel => cnt
		, chr => led
		, chr_max => mem_len
		);
	
	tmr:
	entity work.timer generic map (interrupt => 1) port map(clk, reset, false, pulse);

	process (clk, reset) begin
		if reset = '1' then
			cnt <= 0;
		elsif rising_edge(clk) then
			if pulse then
				if cnt = mem_len or cnt = 5 then
					cnt <= 0;
				else 
					cnt <= cnt + 1;
				end if;
			end if;
		end if;
	end process;
end architecture;
