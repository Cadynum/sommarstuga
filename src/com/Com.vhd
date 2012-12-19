library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.DEFS.ALL;

--***************************************

entity Com is
	port(
	    -- ctrl signal in
	      clk : in STD_LOGIC;
	      rst : in STD_LOGIC;
	      tempInAvail : in STD_LOGIC;
	      elementInAvail : in STD_LOGIC;
	    -- ctrl signal out
	      requestTemp : out STD_LOGIC;
	      requestElement : out STD_LOGIC;
	      elementOutAvail : out STD_LOGIC;
	    -- bus in
	      tempIn : in SIGNED(7 downTo 0);
	      elementIn : in STD_LOGIC_VECTOR(3 downTo 0);
	    -- bus out
	      elementOut : out STD_LOGIC_VECTOR(3 downTo 0);
	    -- com ports
	      tx : out STD_LOGIC;
	      rx : in STD_LOGIC);
end Com;

--***************************************

Architecture Behavioral of Com is
    signal rxByte, txByte : STD_LOGIC_VECTOR(7 downTo 0);
    signal tempInRegister : SIGNED(7 downTo 0);
    signal rxReady, txReady : STD_LOGIC;
    signal txSend : STD_LOGIC;
    signal elementOutRegister, elementInRegister : STD_LOGIC_VECTOR(3 downTo 0);
    signal smsRequestTemp, smsRequestElement, smsHasElement : STD_LOGIC;

begin
    comp_uart : entity work.uart generic map (baudrate => 9600) port map (clk => clk, rst => rst,
									  txByte => txByte, txSend => txSend, tx => tx,
									  rx => rx, rxReady => rxReady, rxByte => rxByte, txReady => txReady);

    comp_at : entity work.At port map (clk => clk, rst => rst, tempInAvail => tempInAvail, elementInAvail => elementInAvail,
								     setElement => elementOutAvail, getElement => requestElement, getTemp => requestTemp,
								     tempDataIn => tempIn, elementDataIn => elementIn, elementDataOut => elementOut,
								     byteAvail => rxReady, byteIn => rxByte, 
								     sendByte => txSend, byteOut => txByte, sendReady => txReady);
end Behavioral;