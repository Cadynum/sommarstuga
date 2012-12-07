library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--********************************************************
entity Shift_register is
	Port(clk: in STD_LOGIC;
	     serialIn : in  STD_LOGIC;
	     shift : in  STD_LOGIC;
	     byteOut : out  STD_LOGIC_VECTOR (7 downto 0));
end Shift_register;
--********************************************************

architecture Behavioral of Shift_register is
	signal reg : STD_LOGIC_VECTOR (7 downTo 0) := (others=>'0');
begin
	Shift_process : process (clk)
	begin
		if (rising_edge(clk)) then
			if (shift = '1') then
				reg <= reg (6 downto 0) & serialIn;
			end if;
		end if;
	end process;
	
	byteOut <= reg;
end Behavioral;