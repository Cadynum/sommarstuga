library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- ********************************************************************************
-- Definitions file
-- Contains the divisors used for the baud speed syncronizing.
--
-- ********************************************************************************

package Defs is
	subtype asciichr is std_logic_vector(7 downto 0);
	type CHAR_ARRAY is array (natural range<>) of asciichr;
	type CHARACTER_ARRAY is array (natural range<>) of Character;

	constant baud_1      : UNSIGNED (26 downTo 0) := "101111101011110000100000000";-- 1 sec
	constant baud_9600   : UNSIGNED (26 downTo 0) := "000000000000010100010110000";
	constant baud_19200  : UNSIGNED (26 downTo 0) := "000000000000001010001011000"; -- 9600 / 2
	constant baud_76800  : UNSIGNED (26 downTo 0) := "000000000000000010100010110"; -- 9600 / 8 = 1302

	function char2int (arg : character) return natural;
	function char2std (arg : character) return std_logic_vector;
	function string_to_vector (s : string) return std_logic_vector;
	
	function chr2vec (c : character) return asciichr;
	function str2ca(str : string) return char_array;

end Defs;

package body Defs is
	function char2int(arg : character)
		return natural is
		begin
			return character'pos(arg);
	end char2int;

	function char2std(arg : character)
		return std_logic_vector is
		begin
			return std_logic_vector (to_unsigned(char2int(arg),8));
	end char2std;

	function string_to_vector( s : string )
		return std_logic_vector 
		is
			variable r : std_logic_vector( s'length * 8 - 1 downto 0);
		begin
			for i in 1 to s'high loop
				r(i * 8 - 1 downto (i - 1) * 8) := std_logic_vector(to_unsigned( character'pos(s(i)) , 8 ) ) ;
			end loop ;
			return r ;
	end function ;


	function chr2vec (c : character) return asciichr is
	begin
		return asciichr(to_unsigned(character'pos(c), 8));
	end function;
	
	function str2ca(str : string) return char_array is
		variable ca : char_array(str'low-1 to str'high-1);
	begin
		for i in str'range loop
			ca(i-1) := chr2vec(str(i));
		end loop;
		return ca;
	end function; 
end Defs;
