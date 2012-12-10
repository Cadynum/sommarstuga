library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--***************************************

entity Com is
	port(
	-- ctrl signal in
	     clk             : in STD_LOGIC;
	     rst             : in STD_LOGIC;
	     tempInAvail     : in STD_LOGIC;
	     elementInAvail  : in STD_LOGIC;
	-- ctrl signal out
	     requestTemp     : out STD_LOGIC;
	     requestElement  : out STD_LOGIC;
	     elementOutAvail : out STD_LOGIC;
	-- bus in
	     tempIn     : in  STD_LOGIC_VECTOR(7 downTo 0);
	     elementIn  : in  STD_LOGIC_VECTOR(2 downTo 0);
	-- bus out
	     elementOut : out STD_LOGIC_VECTOR(2 downTo 0);
	-- com ports
	     tx : out STD_LOGIC;
	     rx : in STD_LOGIC);
end Com;

--***************************************

Architecture Behavioral of Com is
	type state_type is (IDLE);
	signal byteIn, byteOut : STD_LOGIC_VECTOR(7 downTo 0);
	signal inByteReady, outByteReady : STD_LOGIC;
	-- Data register, holds both
	signal tempInRegister : STD_LOGIC_VECTOR(7 downTo 0);
	signal elementInRegister : STD_LOGIC_VECTOR(2 downTo 0);
	signal state : State_type;

begin
	comp_uart : entity work.uart generic map (baudrate => 9600) port map (clk => clk, rst => rst,
									      txByte => byteOut, txSend => outByteReady, tx => tx,
									      rx => rx, rxReady => inByteReady, rxByte => byteIn);
	--comp_at : entity work.uart generic map (messageBufferSize => 80)

	P0 : Process
	begin
		wait until clk = '1';
			if(tempInAvail = '1') then tempInRegister <= tempIn; -- clocked register with wrong enable
			end if;
	end process;
end Behavioral;

