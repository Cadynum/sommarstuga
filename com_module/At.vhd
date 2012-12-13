library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.DEFS.ALL;
--***********************************************************
entity At is
	generic (memSize : POSITIVE := 80);
	port(		
	     clk             : in STD_LOGIC;
	     rst             : in STD_LOGIC;
	-- ctrl signal in
	     tempInAvail       : in STD_LOGIC;
	     elementInAvail    : in STD_LOGIC;
	-- decoded ctrl signal out
	     setElement      : out STD_LOGIC;
	     getElement      : out STD_LOGIC;
	     getTemp      : out STD_LOGIC;
	-- data bus
	     tempDataIn : in STD_LOGIC_VECTOR(7 downTo 0);
	     elementDataOut : Out STD_LOGIC_VECTOR(2 downTo 0);
	     elementDataIn : in STD_LOGIC_VECTOR(2 downTo 0);
	-- com ports
	     messageAvail    : in STD_LOGIC;
	     sendByteOut     : out STD_LOGIC := '0';
	     sendReady        : in STD_LOGIC;
	     atByteStreamIn  : in STD_LOGIC_VECTOR(7 downTo 0);
	     atByteStreamOut : out STD_LOGIC_VECTOR(7 downto 0));
end At;

--***********************************************************
Architecture Behavioral of At is
	signal enable, readWrite, timerEnable, timeOut, clr: STD_LOGIC := '0'; --, runTimer, timeOut : STD_LOGIC := '0';
	signal memBus : STD_LOGIC_VECTOR(7 downTo 0);
	type state_type is (RECEIVE_START, RECEIVE_W_H, RECEIVE_W_L, DECODE, DATA_OUT, DATA_IN, ENCODE, SEND_START, SEND_W_H, SEND, SEND_W_L );
	signal state : state_type := RECEIVE_START;
	signal address, addressHigh : INTEGER range memSize-1 downTo 0 := 0; 
	signal counter : UNSIGNED(26 downTo 0) := "000000000000000000000000000";
	constant timerVal : UNSIGNED(26 downTo 0) := baud_1; --"000000000000000000000000111"; -- time out between bytes
	--constant codeWords : CHAR_ARRAY(3 downTo 0) := "test";
begin
	comp_mem : entity work.Mem generic map (memSize => memSize) 
				   port map(clk => clk, rst => rst, enable => enable, readWrite => readWrite, address => address, memBus => memBus);

	P0 : process (clk, rst)
	begin
		if (rst = '1') then
			state <= RECEIVE_START;
		elsif (rising_edge(clk)) then
			case state is 

			when RECEIVE_START =>
				if (messageAvail = '0') then
					state <= RECEIVE_W_H;
				end if;

			when RECEIVE_W_H =>
				if (timeOut = '1') then
					state <= RECEIVE_START;		-- UART timed out on 
				elsif (messageAvail = '1') then
					state <= RECEIVE_W_L;
				end if;
				
			when RECEIVE_W_L =>
				if (timeOut = '1') then
					state <= DECODE;
				elsif (messageAvail = '0') then
					state <= RECEIVE_W_H;
				end if;

			when DECODE =>
				state <= SEND_START;

			when DATA_OUT =>
			when DATA_IN =>
			when ENCODE =>

			when SEND_START =>
				state <= SEND_W_H;

			when SEND_W_H =>			
				if (sendReady = '1') then
					state <= SEND;
				end if;

			when SEND =>
				state <= SEND_W_L;

			when SEND_W_L =>
				if (address > addressHigh) then
					state <= RECEIVE_START;
				elsif (sendReady = '0') then
					state <= SEND_W_H;		
				end if;
			end case;
		end if;
	end process;
	
	memBus <= atByteStreamIn when (readWrite = '1' AND enable = '1') else "ZZZZZZZZ";
	atByteStreamOut <= memBus when (readWrite = '0') else "ZZZZZZZZ";


	P1 : process (clk)
	begin
		if (rising_edge(clk)) then
			
			enable <= '0';	
			sendByteOut <= '0';

			-- Receive
			if (state = RECEIVE_START) then				
				address <= 0;
				addressHigh <= 0;
			end if;

			if (state = RECEIVE_W_H) then
				timerEnable <= '1';
				if (messageAvail = '1') then
					enable <= '1';
					readWrite <= '1';
					timerEnable <= '0';
				elsif (timeOut = '1') then
					timerEnable <= '0';
				end if;
			end if;
	
			if (state = RECEIVE_W_L) then
				timerEnable <= '1';
				if (messageAvail = '0') then
					address <= address + 1;
					addressHigh <= address;
					timerEnable <= '0';
				elsif (timeOut = '1') then
					timerEnable <= '0';
				end if;
			end if;

			--**************** send
			if (state = SEND_START) then
				address <= 0;
			end if;

			if (state = SEND_W_H) then
				if (sendReady = '1') then
					readWrite <= '0';
					enable <= '1';
				end if;
			end if;

			if (state = SEND) then
				sendByteOut <= '1';
			end if;

			if (state = SEND_W_L) then
				if (sendReady = '0') then
					address <= address + 1;
				end if;
			end if;
		end if;
	end process;

	P4 : process (clk)
	begin
		if (rising_edge(clk)) then		
				if (timeOut = '1' OR timerEnable = '0') then
					counter <= (others => '0');
				else
					counter <= counter + 1;
				end if;
		end if;
	end process;

	timeOut <= '1' when counter = timerVal else '0';
end Behavioral;