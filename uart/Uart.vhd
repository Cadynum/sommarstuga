--******************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;

LIBRARY work;

USE work.defs.all;

--******************************************************

entity Uart is
	Port (clk : in  STD_LOGIC;			   -- clock
	      rst : in STD_LOGIC;			   -- reset
	      rx : in  STD_LOGIC;			   -- receive serial line
	      txByte : in STD_LOGIC_VECTOR (7 downto 0);   -- byte to send
	      txSend : in STD_LOGIC;			   -- send byte

	      txReady : out STD_LOGIC;			   -- byte has been sent
	      tx : out  STD_LOGIC;			   -- send serial line
	      rxReady : out STD_LOGIC;			   -- byte has been received
	      rxByte : out STD_LOGIC_VECTOR (7 downto 0)); -- received byte
end Uart;

--******************************************************

architecture Behavioral of Uart is
	signal tmpRxByte : STD_LOGIC_VECTOR(7 downTo 0) := "00011000";
	signal tmpRxReady : STD_LOGIC;
	
	component Uart_rx_ctrl is
		Port(clk : in  STD_LOGIC;
		     rst : in  STD_LOGIC;
		     rx : in  STD_LOGIC;
		     byteOut : out  STD_LOGIC_VECTOR(7 downTo 0);
		     byteReady : out STD_LOGIC);
	end component;

	component UART_TX_CTRL is
		Port ( SEND : in  STD_LOGIC;
		   DATA : in  STD_LOGIC_VECTOR (7 downto 0);
		   CLK : in  STD_LOGIC;
		   READY : out  STD_LOGIC;
		   UART_TX : out  STD_LOGIC);
	end component;

--******************************************************

begin
	rxReady <= tmpRxReady;

	txControl : UART_TX_CTRL port map(
		SEND => txSend,
		DATA => txByte,

		CLK => clk,
		READY => txReady,

		UART_TX => tx);
		
	rxControl : Uart_rx_ctrl port map(
		clk => clk,
		rst => rst,
		rx => rx,
		byteOut  => tmpRxByte,
		byteReady => tmpRxReady);

	P0 : process(clk, rst)
	begin
		if(rising_edge(clk)) then
			if(rst = '1') then
				rxByte <= "10000001";
			elsif(tmpRxReady = '1') then
				rxByte <= tmpRxByte;
			end if;
		end if;
	end process;

end Behavioral;