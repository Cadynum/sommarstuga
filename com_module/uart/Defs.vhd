library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- ********************************************************************************
-- Definitions file
-- Contains the divisors used for the baud speed syncronizing.
--
-- ********************************************************************************

package Defs is
	type CHAR_ARRAY is array (integer range<>) of std_logic_vector(7 downto 0);
	type CHARACTER_ARRAY is array (natural range<>) of Character;

	constant baud_1      : UNSIGNED (26 downTo 0) := "101111101011110000100000000";-- 1 sec
	constant baud_9600   : UNSIGNED (26 downTo 0) := "000000000000010100010110000";
	constant baud_19200  : UNSIGNED (26 downTo 0) := "000000000000001010001011000"; -- 9600 / 2
	constant baud_76800  : UNSIGNED (26 downTo 0) := "000000000000000010100010110"; -- 9600 / 8 = 1302

-- ********************************************************************************
-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

	function char2int (arg : character) return natural;
	function char2std (arg : character) return std_logic_vector;
	function string_to_vector (s : string) return std_logic_vector;


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


---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end Defs;
