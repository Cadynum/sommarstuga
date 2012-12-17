library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--************************************************

entity Test_bench is
	port(testOk : out std_logic := 'H');
end Test_bench;

--************************************************

architecture Behavioral of Test_bench is
	component Uart is
		Port (clk : in  STD_LOGIC;			   -- clock
		      rst : in STD_LOGIC;			   -- reset
		      rx : in  STD_LOGIC;			   -- receive serial line
		      txByte : in STD_LOGIC_VECTOR (7 downto 0);   -- byte to send
		      txSend : in STD_LOGIC;			   -- send byte

		      txReady : out STD_LOGIC;			   -- byte has been sent
		      tx : out  STD_LOGIC;			   -- send serial line
		      rxReady : out STD_LOGIC;			   -- byte has been received
		      rxByte : out STD_LOGIC_VECTOR (7 downto 0)); -- received byte
	end component Uart;

	signal clk, rst, rx, txSend, txReady, tx, rxReady : STD_LOGIC;
	signal rxByte, txByte : STD_LOGIC_VECTOR(7 downTo 0);
	constant clkPeriod : time := 10ns;
begin
	C0 : Uart port map(clk, rst, rx, txByte, txSend, txReady, tx, rxReady, rxByte);

    rst <= '1',
          '0' after 0.2ms;
    rx <= '1',
         '0' after 0.3ms, --start bit

         '1' after 0.4041ms,
         '0' after 0.5082ms,
         '1' after 0.6123ms,
         '0' after 0.7164ms,
         '0' after 0.8205ms,
         '1' after 0.9246ms,
         '0' after 1.0287ms,
         '1' after 1.1328ms,

         '1' after 1.2369ms; --stop bit

         P0 : process
         begin
             wait for 1.341ms;
             assert(rxByte = "10100101") report "test0 failed" severity error; --set q 
             assert false report "test succesful" severity error;
         end process;

-- Clock runs at 100mhz, period = 1/100*10^6 = 10ns
ClkProcess :process
   begin
        clk <= '0';
        wait for clkPeriod/2;
        clk <= '1';
        wait for clkPeriod/2;
   end process;


   -- Stimulus process
--  stim_proc: process
--   begin        
--        wait for 7 ns;
--        reset <='1';
--        wait for 3 ns;
--        reset <='0';
--        wait for 17 ns;
--        reset <= '1';
--        wait for 1 ns;
--        reset <= '0';
--        wait;
--  end process;

end Behavioral;


