library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bcd.all;

entity segment_unsigned is
	port	( clk, reset : in std_ulogic
			; raw : in unsigned(9 downto 0)
			; an : buffer std_ulogic_vector(3 downto 0)
			; segment : buffer std_ulogic_vector(7 downto 0)
			);
end entity;


architecture a of segment_unsigned is
	subtype seg_t is std_ulogic_vector(6 downto 0);
	type segarr_t is array (natural range <>) of seg_t;
	type sel_t is array (natural range <>) of std_ulogic_vector(3 downto 0);


	constant segarray : segarr_t :=	( "1000000"
									, "1111001"
									, "0100100"
									, "0110000"
									, "0011001"
									, "0010010"
									, "0000010"
									, "1111000"
									, "0000000"
									, "0011000"
									);
	constant sel : sel_t := ("1110", "1101", "1011", "0111");


	signal cnt : integer range 0 to 3 := 0;
	signal pulse : boolean;
	signal bcd : std_ulogic_vector(4*4-1 downto 0);
begin
	-- 1khz refresh rate for each led segment
	timer:
	entity work.timer generic map (interrupt => 10**3) port map (clk, reset, false, pulse);

	bcd <= tobcd(raw);

	-- this generates an incorrect metastability warning
	segment <= '1' & segarray(to_integer(bcddigit(bcd, cnt)));

	an <= sel(cnt);

	counter:
	process (clk, reset) begin
		if reset = '1' then
			cnt <= 0;
		elsif rising_edge(clk) then
			if pulse then
				cnt <= (cnt + 1) mod 4;
			end if;
		end if;
	end process;

end architecture;

