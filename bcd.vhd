library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package bcd is
	function tobcd  (din : in unsigned) return std_logic_vector;
end package;

package body bcd is

	function tobcd (din : in unsigned) return std_logic_vector is
		constant bits : integer := din'length;
		constant chunks : integer := (bits+2)/3;
		variable bcd : std_logic_vector(chunks*4-1 downto 0) := (others => '0');
		variable tmp : unsigned(3 downto 0);
	begin
		report "Number of cycles taken = " & integer'image(bits);
		for b in bits-1 downto 0 loop
			for i in 0 to chunks-1 loop
				tmp := unsigned( bcd((i+1)*4-1 downto i*4) );
				if tmp > 4 then
					bcd((i+1)*4-1 downto i*4) := std_logic_vector(tmp+3);
				end if;
			end loop;
			bcd := bcd(bcd'high-1 downto 0) & din(b);
		end loop;
		return bcd;
	end function;
 
end package body;
