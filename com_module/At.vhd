library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.DEFS.ALL;
--***********************************************************
entity At is
	generic ( messageBufferSize : POSITIVE := 80);
	port(		
	     clk             : in STD_LOGIC;
	     rst             : in STD_LOGIC;
	-- ctrl signal in
	     tempAvail       : in STD_LOGIC;
	     elementAvail    : in STD_LOGIC;
	-- decoded ctrl signal out
	     setElement      : in STD_LOGIC;
	     getElement      : in STD_LOGIC;
	     getTemp      : in STD_LOGIC;
	-- data bus
	     tempDataIn : in STD_LOGIC_VECTOR(7 downTo 0);
	     elementData : inOut STD_LOGIC_VECTOR(2 downTo 0);
	-- com ports
	     atByteStreamIn  : in STD_LOGIC_VECTOR(7 downTo 0);
	     atByteStreamOut : in STD_LOGIC_VECTOR(7 downTo 0));
end At;

--***********************************************************
Architecture Behavioral of At is
	signal commandBuffer : CHAR_ARRAY (messageBufferSize downTo 0);
	signal bufferIndex : INTEGER range 0 to 3;
begin
end Behavioral;