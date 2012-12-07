--******************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY work;
USE work.defs.all;

--******************************************************

entity Uart is
	generic (baudRate : POSITIVE := 9600); -- **implement**
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
	component Uart_rx_ctrl is
		Port(clk : in  STD_LOGIC;
		     rst : in  STD_LOGIC;
		     rx : in  STD_LOGIC;
		     byteOut : out  STD_LOGIC_VECTOR(7 downTo 0);  -- Byte received on the serial line. Only valid when byteReady is high.
		     byteReady : out STD_LOGIC);                   -- Goes high after a byte is received and the byte value is valid.
	end component;

	component Uart_tx_ctrl is
		Port(send : in  STD_LOGIC;
		   data : in  STD_LOGIC_VECTOR (7 downto 0);
		   clk : in  STD_LOGIC;
		   ready : out  STD_LOGIC;
		   uart_tx : out  STD_LOGIC);
	end component;

--******************************************************

begin
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
		byteOut  => rxByte,
		byteReady => rxReady);

end Behavioral;