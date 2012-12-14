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
	-- memmory control
	signal enable, readWrite STD_LOGIC := '0'; 
	signal memBus : STD_LOGIC_VECTOR(7 downTo 0);
	signal address, addressHigh : INTEGER range memSize-1 downTo 0 := 0; 

	-- timer
	signal timerEnable, timeOut STD_LOGIC := '0';
	signal counter : UNSIGNED(26 downTo 0) := "000000000000000000000000000";
	constant timerVal : UNSIGNED(26 downTo 0) := baud_1;--"000000000000000000000000111";-- time out between bytes

	-- state machines
	type state_type_receive is (RECEIVE_START, RECEIVE_W_H, RECEIVE_W_L);
	type state_type_send is (SEND_START, SEND_W_H, SEND, SEND_W_L);
	type state_type_encode is ();
	type state_type_decode is ();
	type state_type_at is (WAIT_COMMAND, GET_NUMBER, VERIFY, GET_ID, SET_MODE, GET_COMMAND, CONTROL_OUT, CONTROL_IN, SEND_DATA);
	signal receive_state : state_type_receive := RECEIVE_START;
	signal send_state : state_type_send := SEND_START;
	signal decode_state : state_type_decode_send := DECODE_START;
	signal encode_state : state_type_encode := ENCODE_START;
	signal at_state : state_type_at := AT_START;
	-- process statuses and enables
	signal rec_en, snd_en, dec_en, enc_en STD_LOGIC := '0';
	signal rec_done, snd_done, dec_done, enc_done STD_LOGIC := '0';

	-- DECODE /ENCODE????
	--constant codeWords : CHAR_ARRAY(3 downTo 0) := "test";
begin
	comp_mem : entity work.Mem generic map (memSize => memSize) 
				   port map(clk => clk, rst => rst, enable => enable, readWrite => readWrite, address => address, memBus => memBus);
	
	AT_P : process (clk, rst)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then				-- se upp med synkron reset (asynkron tidigare)
				-- reset
			else						-- ingen enable
				case at_state is
					when WAIT_COMMAND => 
						if(rec_done = '1') then
							rec_en <= '0';
							snd_en <= '1';
						elsif (snd_done = '1') then
							snd_done <= '0';
							rec_en <= '1';
						else 
							rec_en <= '1';
						end if;
						
					when GET_NUMBER => 
					when VERIFY => 
					when GET_ID => 
					when SET_MODE => 
					when GET_COMMAND => 
					when CONTROL_OUT => 
					when CONTROL_IN => 
					when SEND_DATA =>
				end case;
			end if;
		end if;
	end process;

	RECEIVE_P : process (clk, rst)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				-- reset
			elsif (rec_en = '1') then	
				case receive_state is 
				when RECEIVE_START =>
					if (messageAvail = '0') then
						state <= RECEIVE_W_H;
					end if;

				when RECEIVE_W_H =>
					if (timeOut = '1') then
						state <= RECEIVE_START;
					elsif (messageAvail = '1') then
						state <= RECEIVE_W_L;
					end if;
					
				when RECEIVE_W_L =>
					if (timeOut = '1') then
						state <= DECODE;
					elsif (messageAvail = '0') then
						state <= RECEIVE_W_H;
					end if;
				end case;
			end if;
		end if;
	end process;

	DECODE_P : process (clk, rst)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				-- reset
			elsif (dec_en = '1') then
				-- do stuff
			end if;
		end if;
	end process;

	ENCODE_P : process (clk, rst)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				-- reset
			elsif (enc_en = '1') then
				-- do stuff
			end if;
		end if;
	end process;

	SEND_P : process (clk, rst)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				-- reset
			elsif (snd_en = '1') then
				case send_state is
				when SEND_START =>
					state <= SEND_W_H;

				when SEND_W_H =>			
					if (address > addressHigh) then
						state <= RECEIVE_START;
					elsif (sendReady = '1') then
						state <= SEND;
					end if;

				when SEND =>
					state <= SEND_W_L;

				when SEND_W_L =>
					if (sendReady = '0') then
						state <= SEND_W_H;		
					end if;
				end case;
			end if;
		end if;
	end process;
	
	memBus <= atByteStreamIn when (readWrite = '1' AND enable = '1') else "ZZZZZZZZ";
	atByteStreamOut <= memBus when (readWrite = '0') else "ZZZZZZZZ";


	OUTSIG_P : process (clk)
	begin
		if (rising_edge(clk)) then
			
			enable <= '0';	
			sendByteOut <= '0';

-- ******************** At ************************************
			if (at_state = WAIT_COMMAND) then
			end if;

			if (at_state = VERIFY) then
			end if;

			if (at_state = GET_ID) then
			end if;

			if (at_state = SET_MODE) then
			end if;

			if (at_state = GET_COMMAND) then
			end if;

			if (at_state = CONTROL_OUT) then
			end if;

			if (at_state = CONTROL_IN) then
			end if;

			if (at_state = SEND_DATA) then
			end if;

-- ******************** Decode ************************************


-- ******************** Encode ************************************


-- ******************** Receive *******************************
			if (receive_state = RECEIVE_START) then				
				address <= 0;
				addressHigh <= 0;
			end if;

			if (receive_state = RECEIVE_W_H) then
				timerEnable <= '1';
				if (messageAvail = '1') then
					enable <= '1';
					readWrite <= '1';
					timerEnable <= '0';
				elsif (timeOut = '1') then
					timerEnable <= '0';
				end if;
			end if;
	
			if (receive_state = RECEIVE_W_L) then
				timerEnable <= '1';
				addressHigh <= address;
				if (messageAvail = '0') then					
					address <= address + 1;
					timerEnable <= '0';
				elsif (timeOut = '1') then
					timerEnable <= '0';
				end if;
			end if;

--********************** send *********************************

			if (send_state = SEND_START) then
				address <= 0;
			end if;

			if (send_state = SEND_W_H) then
				if (sendReady = '1') then
					readWrite <= '0';
					enable <= '1';
				end if;
			end if;

			if (send_state = SEND) then
				sendByteOut <= '1';
			end if;

			if (send_state = SEND_W_L) then
				if (sendReady = '0') then
					address <= address + 1;
				end if;
			end if;
		end if;
	end process;

	TIMER_P : process (clk)
	begin
		if (rising_edge(clk)) then		
				if (timerEnable = '0') then
					counter <= (others => '0');
				else
					counter <= counter + 1;
				end if;
		end if;
	end process;

	timeOut <= '1' when counter = timerVal else '0';
end Behavioral;