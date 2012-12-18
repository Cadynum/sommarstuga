library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bcd.all;
use work.Defs.character_array;

entity bcdascii is
	port	( clk, reset : in std_ulogic
			; go : in std_ulogic
			; ready : buffer std_ulogic
			; rawd : in signed(7 downto 0)
			; mem : buffer character_array(0 to 5)
			; mem_len : buffer integer range 0 to 5
			);
end entity;


architecture a of bcdascii is
	constant zero_digit : integer := character'pos('0');
	constant max_intd : integer := 2;
	
	type state_t is (idle, conv, psign, pskip, pint, pdot, pfrac);
	signal state : state_t;
	
	signal cnt : integer range 0 to 5 := 0;
	signal bcdsel : integer range max_intd-1 downto 0 := max_intd-1;
	
	signal bcd : std_ulogic_vector(max_intd*4-1 downto 0);
	signal is_negative : boolean;
	signal absolute : unsigned(rawd'range);
	signal int_part : unsigned(rawd'high-2 downto 0);
	signal fract_part : std_ulogic;

begin
	mem_len <= cnt;
	
	is_negative <= rawd(rawd'high) = '1';
	absolute <= unsigned(abs(rawd));
	int_part <= absolute(absolute'high-1 downto 1);
	fract_part <= absolute(0);
	
	process(clk, reset) is
		variable tmp : integer range 0 to 9;
	begin
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
					
				when psign =>
					if is_negative then
						mem(cnt) <= '-';
						cnt <= cnt + 1;
					end if;
					state <= pskip;
				
				-- Skippar alla nollor i början av talet. 
				-- Lämna alltid en nolla
				when pskip =>
					tmp := to_integer(bcddigit(bcd, bcdsel));
					if tmp = 0 and bcdsel /= 0 then
						bcdsel <= bcdsel - 1;
					else
						state <= pint;
					end if;
					
				when pint =>
					tmp := to_integer(bcddigit(bcd, bcdsel));
					mem(cnt) <= character'val(tmp + zero_digit);
					cnt <= cnt + 1;
					if bcdsel = 0 then
						state <= pdot;
					else
						bcdsel <= bcdsel - 1;
					end if;
				
				when pdot =>
					mem(cnt) <= '.';
					cnt <= cnt + 1;
					state <= pfrac;
					
				when pfrac =>
					if fract_part = '1' then
						mem(cnt) <= '5';
					else
						mem(cnt) <= '0';
					end if;	
					ready <= '1';
					state <= idle;		
			end case;
		end if;
	end process;
end architecture;

