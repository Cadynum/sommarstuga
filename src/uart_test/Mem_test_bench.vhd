library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--************************************************

entity Mem_test_bench is
	generic(memSize : INTEGER := 100;
		clkPeriod : TIME := 10 ns);
	port(testOk : STD_LOGIC := 'H');
end Mem_test_bench;

--************************************************

architecture Behavioral of Mem_test_bench is
	signal clk, rst, enable, readWrite : STD_LOGIC;
	signal address : INTEGER range memSize-1  downTo 0;
	signal memBus : STD_LOGIC_VECTOR(7 downTo 0);
begin
	memmory : entity work.Mem generic map (memSize => memSize) port map (clk => clk, rst => rst, enable => enable, readWrite => readWrite,
									     address => address, memBus => memBus);

-- Clock runs at 100mhz, period = 1/100*10^6 = 10ns
	P0 : process
	begin
		clk <= '0';
		wait for clkPeriod/2;
		clk <= '1';
		wait for clkPeriod/2;
	end process;

	rst <=  '1',
		'0' AFTER 10 ns,
		'1' AFTER 80 ns,
		'0' AFTER 90 ns;


	enable <= '0',
		  '1' AFTER 10 ns,
		  '0' AFTER 40 ns,
		  '1' AFTER 50 ns;

	memBus <= "ZZZZZZZZ",
		  "00000001" AFTER 10 ns,
		  "00000010" AFTER 20 ns,
		  "00000011" AFTER 30 ns,
		  "ZZZZZZZZ" AFTER 40 ns;

	readWrite <= '0', 
		     '1' AFTER 10 ns,
		     '0' AFTER 50 ns;
	-- write to different addresses
	address <= 1,
	       2 AFTER 20 ns,
	       3 AFTER 30 ns,
	-- read from addresses
	       1 AFTER 50 ns,
	       3 AFTER 60 ns,
	       2 AFTER 70 ns,
	-- read again adfter reset
	       2 AFTER 90 ns,
	       2 AFTER 100 ns,
	       2 AFTER 110 ns;


	P1: process
	begin
		wait for 60 ns;
		assert (memBus = "00000001") report "TEST FAILED" severity error;
		assert false report "TEST PASSED" severity error;
	end process;

end Behavioral;


