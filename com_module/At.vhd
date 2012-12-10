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
	     messageAvail    : in STD_LOGIC;
	-- decoded ctrl signal out
	     setElement      : in STD_LOGIC;
	     getElement      : in STD_LOGIC;
	     getTemp      : in STD_LOGIC;
	-- data bus
	     tempDataIn : in STD_LOGIC_VECTOR(7 downTo 0);
	     elementDataOut : inOut STD_LOGIC_VECTOR(2 downTo 0);
	     elementDataIn : inOut STD_LOGIC_VECTOR(2 downTo 0);
	-- com ports
	     atByteStreamIn  : in STD_LOGIC_VECTOR(7 downTo 0);
	     atByteStreamOut : in STD_LOGIC_VECTOR(7 downTo 0));
end At;

--***********************************************************
Architecture Behavioral of At is
	signal enable, readWrite STD_LOGIC;
	signal memBus STD_LOGIC_VECTOR(7 downTo 0);
	type state_type is (IDLE, RECEIVE, DECODE, DATA_OUT, DATA_IN, ENCODE, SEND);
	signal state, nextState: state_type;
	signal address : in INTEGER range memSize-1  downTo 0; 
	constant codeWords : CHAR_ARRAY( downTo 0) =:();
begin
	comp_mem : entity work.Mem generic map (memSize => 80) 
				   port map(clk => clk, rst => rst, enable => enable, readWrite => readWrite, address => address, memBus => memBus);

	P0 : process(clk, rst)
		begin
			if rst = '1' then
				state <= IDLE;
			elsif (rising_edge(clk)) then
				state <= nextState;
			end if;
	end process;

	P1 : process(clk, messageAvail)
	begin
		runTimer <= '0';

		case state is
		when IDLE =>
			if (messageAvail = '1') then
				nextStat <= RECEIVE;
			end if;
		when RECEIVE =>
			if (messageAvail = '1') then
				--skriv till minnet
				runTimer <= '1';
				nextState <= WAIT_BYTE;
			else
				
			end if;
		when WAIT_BYTE =>
			if (timeOut = '1') then
				runTimer <= '0'
				nextState <= DECODE;
			elsif (messageAvail = '0') then
				nextState <= RECEIVE;
			end if;
		when DECODE =>
			
		when DATA_OUT =>
		when DATA_IN =>
		when ENCODE =>
		when SEND =>
		end case;
	end process;

	P2 : process (clk, rst, runTimer)
	begin
		if (rising_edge(clk)) then
			if(rst = '1' OR runTimer = '0') then 
				i <= (others => '0');
			else
				i <= i + 1;
			end if;
		end if;
	end process;	
	timeOut <= '1' when (i =< divisor) else '0';
end Behavioral;