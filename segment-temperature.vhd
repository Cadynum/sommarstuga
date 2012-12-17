library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bcd.all;

entity segment_temperature is
	port	( clk, reset : in std_ulogic
			; rawd : in signed(7 downto 0)
			; an : buffer std_ulogic_vector(3 downto 0)
			; segment : buffer std_ulogic_vector(7 downto 0)
			);
end entity;


architecture a of segment_temperature is
	subtype seg_t is std_ulogic_vector(6 downto 0);
	type segarr_t is array (natural range <>) of seg_t;

	signal is_negative : boolean;
	signal absolute : unsigned(rawd'range);
	signal int_part : unsigned(rawd'high-1 downto 0);
	signal fract_part : std_ulogic;

	signal cnt : integer range 0 to 3;

	signal pulse : boolean;
	signal dot : std_ulogic;
	signal bcd : std_ulogic_vector(3*4-1 downto 0);
	signal digit : seg_t;


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
									, "0111111" -- minus sign
									);

	type sel_t is array (natural range <>) of std_ulogic_vector(3 downto 0);
	constant sel : sel_t := ("1110", "1101", "1011", "0111");

begin
	-- 1khz refresh rate for each led segment
	timer:
	entity work.timer generic map (interrupt => 10**3) port map (clk, reset, false, pulse);

	is_negative <= rawd(rawd'high) = '1';
	absolute <= unsigned(abs(rawd));
	int_part <= absolute(absolute'high downto 1);
	fract_part <= absolute(0);

	bcd <= tobcd(int_part);

	dot <= '0' when cnt = 1 else '1';

	process (cnt, bcd, is_negative, fract_part) is
		variable active : unsigned(3 downto 0);
		variable setval : integer range segarray'range(1);
	begin

		if cnt = 0 then
			if fract_part = '1' then
				setval := 5;
			else
				setval := 0;
			end if;
		elsif cnt = 3 and is_negative then
			setval := 10; --minus sign
		else
			setval := to_integer(bcddigit(bcd, cnt-1));
		end if;

		digit <= segarray(setval);
	end process;

	segment <= dot & digit;
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

