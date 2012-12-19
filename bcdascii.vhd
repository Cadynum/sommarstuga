library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Defs.char_array;
use work.Defs.asciichr;

package bcdascii_p is
	subtype bcdbuf_t is integer range 0 to 31;

end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bcd.all;
use work.Defs.all;
use work.bcdascii_p.all;

entity bcdascii is
	port	( clk, reset : in std_ulogic
			; go : in std_ulogic
			; ready : buffer std_ulogic
			; rawd : in signed(7 downto 0)
			; chr : buffer asciichr
			; chr_sel : in bcdbuf_t
			; chr_max : buffer bcdbuf_t
			);
end entity;


architecture a of bcdascii is
	constant max_intd : integer := 2;

	type state_t is (idle, conv, psign, pskip, pint, pdot, pfrac);
	signal state : state_t;

	signal mem : char_array(0 to 5) := (others => x"FF");
	signal cnt : integer range 0 to 5 := 0;
	signal bcdsel : integer range max_intd-1 downto 0 := max_intd-1;

	signal bcd : std_ulogic_vector(max_intd*4-1 downto 0);
	signal is_negative : boolean;
	signal absolute : unsigned(rawd'range);
	signal int_part : unsigned(rawd'high-2 downto 0);
	signal fract_part : std_ulogic;

	constant pre_string : char_array := str2ca("Temperatur: "); --12chars
	constant post_string : char_array := str2ca(('C', cr, lf)); --3chars

begin


	chr_max <= pre_string'length + cnt + post_string'length;

	process (chr_sel, chr_max, mem, cnt) begin
		if chr_sel < pre_string'length then
			chr <= pre_string(chr_sel);
		elsif chr_sel < (pre_string'length+cnt+1) then
			chr <= mem(chr_sel-pre_string'length);
		elsif chr_sel < pre_string'length + cnt + 1 + post_string'length then
			chr <= post_string(chr_sel - (pre_string'length+cnt+1));
		else
			chr <= x"00";
		end if;
	end process;

	absolute <= unsigned(abs(rawd));
	int_part <= absolute(absolute'high-1 downto 1);

	process(clk, reset) begin
		if reset = '1' then
			state <= idle;
			ready <= '0';
		elsif rising_edge(clk) then
			case state is
				when idle =>
					if go = '1' then
						ready <= '0';
						cnt <= 0;
						bcdsel <= max_intd-1;
						state <= conv;
					end if;

				when conv =>
					state <= psign;
					bcd <= tobcd(int_part);
					fract_part <= absolute(0);
					is_negative <= rawd(rawd'high) = '1';

				when psign =>
					if is_negative then
						mem(cnt) <= chr2vec('-');
						cnt <= cnt + 1;
					end if;
					state <= pskip;

				-- Skippar alla nollor i början av talet.
				-- Lämna alltid en nolla
				when pskip =>
					if bcddigit(bcd, bcdsel) = 0 and bcdsel /= 0 then
						bcdsel <= bcdsel - 1;
					else
						state <= pint;
					end if;

				when pint =>
					mem(cnt) <= x"3" & std_logic_vector(bcddigit(bcd, bcdsel));
					cnt <= cnt + 1;
					if bcdsel = 0 then
						state <= pdot;
					else
						bcdsel <= bcdsel - 1;
					end if;

				when pdot =>
					mem(cnt) <= chr2vec('.');
					cnt <= cnt + 1;
					state <= pfrac;

				when pfrac =>
					if fract_part = '1' then
						mem(cnt) <= chr2vec('5');
					else
						mem(cnt) <= chr2vec('0');
					end if;
					ready <= '1';
					state <= idle;
			end case;
		end if;
	end process;
end architecture;

