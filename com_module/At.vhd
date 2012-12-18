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
	signal enable, readWrite : STD_LOGIC := '0'; 
	signal memBus : STD_LOGIC_VECTOR(7 downTo 0);
	signal address, addressHigh : INTEGER range memSize-1 downTo 0 := 0; 

	-- timer
	signal timerEnable, timeOut : STD_LOGIC := '0';
	signal counter : UNSIGNED(26 downTo 0) := "000000000000000000000000000";
	constant timerVal : UNSIGNED(26 downTo 0) := "000000000000000000000000111";-- time out between bytes

	-- state machines
	type state_type_receive is (RECEIVE_START, RECEIVE_W_H, RECEIVE_W_L, RECEIVE_DONE);
	type state_type_send is (SEND_START, SEND_W_H, SEND, SEND_W_L, SEND_DONE);
	type state_type_encode is (ENCODE_START);
	type state_type_decode is (DECODE_START, DECODE_TEST);
	type state_type_at is (WAIT_COMMAND, GET_ID, SEND_MODE, SEND_INDEX, GET_DATA, CONTROL_OUT, CONTROL_IN, SEND_DATA);
	signal receive_state : state_type_receive := RECEIVE_START;
	signal send_state : state_type_send := SEND_START;
	signal decode_state : state_type_decode := DECODE_START;
	signal encode_state : state_type_encode := ENCODE_START;
	signal at_state : state_type_at := WAIT_COMMAND;

	-- process statuses and enables
	signal rec_en, snd_en, dec_en, enc_en : STD_LOGIC := '0';
--	signal rec_done, snd_done, dec_done, enc_done STD_LOGIC := '0';

	-- DECODE /ENCODE
	signal bin_char : STD_LOGIC_VECTOR(7 downTo 0);
	signal is_match : boolean := false;
		-- white space ignored, '!' denotes variable
	
	constant sms_id : CHARACTER_ARRAY := "+CMTI=<!>,<!>"; --<mem>, <index>
	constant sms_command : CHARACTER_ARRAY := "+CMGR:""RECREAD"",""!"",""!""!OK"; -- "number", "date" "command"

begin
	comp_mem : entity work.Mem generic map (memSize => memSize) 
				   port map(clk => clk, rst => rst, enable => enable, readWrite => readWrite, address => address, memBus => memBus);
	
	AT_P : process (clk, rst)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then		
				at_state <= WAIT_COMMAND;
			else	
				case at_state is
					when WAIT_COMMAND => 
						if(receive_state = RECEIVE_START) then
							rec_en <= '1';
						elsif(receive_state = RECEIVE_DONE) then
							rec_en <= '0';
							at_state <= GET_ID;
						end if;
						
					when GET_ID => -- parse message for message index
						if(decode_state = DECODE_START) then
							dec_en <= '1';
						elsif(decode_state = DECODE_TEST) then
							dec_en <= '0';
							at_state <= SEND_MODE;	
						end if;

					when SEND_MODE => -- send text mode
						if(send_state = SEND_START) then
							snd_en <= '1';
						elsif(send_state  = SEND_DONE) then
							snd_en <= '0';
							at_state <= WAIT_COMMAND;
						end if;

					when GET_DATA =>  -- parse for number and data
					when SEND_INDEX => -- send for message with aquired index
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
						receive_state <= RECEIVE_W_H;
					end if;

				when RECEIVE_W_H =>
					if (timeOut = '1') then
						receive_state <= RECEIVE_START;
					elsif (messageAvail = '1') then
						receive_state <= RECEIVE_W_L;
					end if;
					
				when RECEIVE_W_L =>
					if (timeOut = '1') then
						receive_state <= RECEIVE_DONE;
					elsif (messageAvail = '0') then
						receive_state <= RECEIVE_W_H;
					end if;

				when RECEIVE_DONE =>
					receive_state <= RECEIVE_START;
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
				case decode_state is
				when DECODE_START =>
					decode_state <= decode_test;
				when DECODE_TEST =>

				end case;
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
				send_state <= SEND_START;
			elsif (snd_en = '1') then
				case send_state is

				when SEND_START =>
					send_state <= SEND_W_H;

				when SEND_W_H =>			
					if (address > addressHigh) then
						send_state <= SEND_DONE;
					elsif (sendReady = '1') then
						send_state <= SEND;
					end if;

				when SEND =>
					send_state <= SEND_W_L;

				when SEND_W_L =>
					if (sendReady = '0') then
						send_state <= SEND_W_H;		
					end if;				

				when SEND_DONE =>
					send_state <= SEND_START;
				end case;
			end if;
		end if;
	end process;
	
	memBus <= atByteStreamIn when (readWrite = '1' AND enable = '1') else "ZZZZZZZZ";
	atByteStreamOut <= memBus when (readWrite = '0') else "ZZZZZZZZ";


--******************** Out signal processes ************************
	OUTSIG_P : process (clk)
	begin
		if (rising_edge(clk)) then
			
			enable <= '0';	
			sendByteOut <= '0';

-- ******************** At *****************************************
			if (at_state = WAIT_COMMAND) then	
			end if;

-- ******************** Decode *************************************
			if(dec_en = '1') then
				if (decode_state = DECODE_START) then
					enable <= '1';
					address <= 0;
					readWrite <= '0';
				end if;

				if (decode_state = DECODE_TEST) then
					bin_char <= char2std('?');
				end if;
			end if;
-- ******************** Encode ************************************


-- ******************** Receive ***********************************
			if (rec_en = '1') then
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
			end if;

--********************** send *********************************

			if (snd_en = '1') then
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