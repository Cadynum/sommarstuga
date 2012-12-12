--******************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY work;
USE work.defs.all;

--******************************************************

entity Mem is
	generic (memSize : POSITIVE := 80);		   -- in bytes
	Port (clk : in  STD_LOGIC;			   -- clock
	      rst : in STD_LOGIC;
	      enable : in STD_LOGIC;
	      address : in INTEGER range memSize-1  downTo 0;
	      readWrite : in STD_LOGIC;			   -- read on low, write on high.
	      memBus : inout STD_LOGIC_VECTOR(7 downTo 0));
end Mem;

--******************************************************

Architecture Behavioral of Mem is
	signal registers : CHAR_ARRAY (0 to memSize-1);
begin
	P0 : process (clk, rst, readWrite, enable)
	begin				
		if(rising_edge(clk)) then
			memBus <= "ZZZZZZZZ";
			-- reset, clears memmory
			if(rst = '1') then				
				for i in 0 to memSize-1 loop
					registers(i) <= (others=>'0');
				end loop; 
			--read
			elsif(readWrite = '0' AND enable = '1') then
				memBus <= registers(address);
			--write
			elsif(readWrite = '1' AND enable = '1') then
				registers(address) <= memBus;
			end if;
		end if;
	end process;

	
end Behavioral;