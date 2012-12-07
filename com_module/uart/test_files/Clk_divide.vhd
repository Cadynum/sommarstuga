library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

--**************************************************************************--

entity Clk_divide is 
	port(toggleSync : in STD_LOGIC := '0';
	     clkIn : in STD_LOGIC := '0';
	     divisor : in UNSIGNED(26 downTo 0);
	     clkOut : out STD_LOGIC := '0');  
end Clk_divide;

--**************************************************************************--

architecture Behavioral of Clk_divide is
	signal i : UNSIGNED (26 downto 0) := (others => '0');
	signal clkVal : STD_LOGIC := '0';
	signal sync : STD_LOGIC := '0';
begin
	P0 : process (clkIn, toggleSync, sync)
	begin
		if(sync = toggleSync) then
			i <= (others => '0');
			sync <= not(toggleSync);
		elsif(rising_edge(clkIn)) then
			if (clkVal = '1') then
				i <= (others => '0');
			else
				i <= i + 1;
			end if;
		end if;
	end process;

	clkVal <= '1' when (i + 1 = divisor) else '0';

end architecture;