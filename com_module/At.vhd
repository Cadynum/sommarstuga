library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.DEFS.ALL;
--***********************************************************
entity At is
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
	     elementDataOut : Out STD_LOGIC_VECTOR(3 downTo 0);
	     elementDataIn : in STD_LOGIC_VECTOR(3 downTo 0);
	-- com ports
	     byteAvail    : in STD_LOGIC;
	     sendByte     : out STD_LOGIC := '0';
	     sendReady    : in STD_LOGIC;
	     byteIn  : in STD_LOGIC_VECTOR(7 downTo 0);
	     byteOut : out STD_LOGIC_VECTOR(7 downto 0));
end At;

--***********************************************************
Architecture Behavioral of At is
	-- timer
	signal timerEnable, timeOut : STD_LOGIC := '0';
	signal counter : UNSIGNED(26 downTo 0) := "000000000000000000000000000";
	constant timerVal : UNSIGNED(26 downTo 0) := "000000000000000000000001111";-- time out between bytes

	-- state machines
	type state_type is (WAIT_COMMAND, WAIT_GET, WAIT_SET, WAIT_EQUALS, SET_ELEM, GET_ELEM, GET_TEMP, WAIT_TEMP_DATA, WAIT_ELEM_DATA, SEND);
	signal state : state_type := WAIT_COMMAND;

begin


	--*************************************************
	STATE_PROCESS : process (clk, rst)
	begin
		if (rst = '1') then
			-- reset
		elsif (rising_edge(clk)) then
			timerEnable <= '0';

			case state is 
				when WAIT_COMMAND =>
					if (byteAvail = '1') then
						if (byteIn = char2std('g')) then
							state <= WAIT_GET;
						elsif (byteIn = char2std('s')) then
							state <= WAIT_SET;
						end if;
					end if;
					
				when WAIT_GET =>
					timerEnable <= '1';
					if (byteAvail = '1') then
						if (byteIn = char2std('t')) then
							state <= GET_TEMP;
						elsif (byteIn = char2std('e')) then
							state <= GET_ELEM;
						end if;
					elsif (timeOut = '1') then
						state <= WAIT_COMMAND;
					end if;

				when WAIT_SET =>
					timerEnable <= '1';
					if (byteAvail = '1') then
						if (byteIn = char2std('e')) then
							state <= WAIT_EQUALS;
						end if;
					elsif (timeOut = '1') then
						state <= WAIT_COMMAND;
					end if;

				when WAIT_EQUALS =>
					timerEnable <= '1';
					if (byteAvail = '1') then
						if (byteIn = char2std('=')) then
							state <= SET_ELEM;
						end if;
					elsif (timeOut = '1') then
						state <= WAIT_COMMAND;
					end if;

				when SET_ELEM =>
					if (byteAvail = '1') then
						state <= WAIT_COMMAND;
					elsif (timeOut = '1') then
						state <= WAIT_COMMAND;
					end if;

				when GET_ELEM =>
					state <= WAIT_ELEM_DATA;
				when GET_TEMP =>
					state <= WAIT_TEMP_DATA;
				when WAIT_TEMP_DATA =>
					if (tempInAvail = '1') then
						state <= SEND;
					end if;
				when WAIT_ELEM_DATA =>
					if (elementInAvail = '1') then
						state <= SEND;
					end if;
				when SEND =>
					if (sendReady = '1') then
						state <= WAIT_COMMAND;
					end if;
			end case;
		end if;
	end process;

-- ******************** Receive outsignals ***********************************
	OUTSIGNAL_PROCESS : process (clk, rst)
	begin
		if (rst = '1') then
			-- reset
		elsif (rising_edge(clk)) then
			sendByte <= '0';
			setElement <= '0';
			getElement <= '0';
			getTemp <= '0';

			case state is
				when SET_ELEM =>
					if (byteAvail = '1') then
						elementDataOut <=  byteIn (3 downTo 0);
						setElement <= '1';
					end if;

				when GET_ELEM =>
					getElement <= '1';

				when GET_TEMP =>
					getTemp <= '1';

				when WAIT_TEMP_DATA =>
					if (tempInAvail = '1') then
--						byteOut <=  string_to_vector("temp:") & tempDataIn;
						byteOut <= tempDataIn;						
					end if;

				when WAIT_ELEM_DATA =>
					if (elementInAvail = '1') then
--						byteOut <= string_to_vector("elem:") & elementDataIn;
						byteOut <= '0' & '0' & '0' & '0' & elementDataIn;						
					end if;

				when SEND =>
					if (sendReady = '1') then
						sendByte <= '1';
					end if;
				when others =>
					--do nothing
			end case;
		end if;
	end process;





--	SEND_P : process (clk, rst, snd_en)
--	begin
--		if (rising_edge(clk)) then
--			if (rst = '1' OR snd_en = '1') then
--				send_state <= SEND_START;
--			else
--				case send_state is
--
--				when SEND_START =>
--					send_state <= SEND_W_H;
--
--				when SEND_W_H =>			
--					if (address > addressHigh) then
--						send_state <= SEND_DONE;
--					elsif (sendReady = '1') then
--						send_state <= SEND;
--					end if;
--
--				when SEND =>
--					send_state <= SEND_W_L;
--
--				when SEND_W_L =>
--					if (sendReady = '0') then
--						send_state <= SEND_W_H;		
--					end if;				
--
--				when SEND_DONE =>
--					-- terminal state, stuck here until snd_en, no outsignals
--				end case;
--			end if;
--		end if;
--	end process;
--	
--
--
----********************** send outsignals *********************************
--
--			if (snd_en = '1') then
--				if (send_state = SEND_START) then
--					address <= 0;
--				end if;
--
--				if (send_state = SEND_W_H) then
--					if (sendReady = '1') then
--						readWrite <= '0';
--						enable <= '1';
--					end if;
--				end if;
--
--				if (send_state = SEND) then
--					sendByteOut <= '1';
--				end if;
--
--				if (send_state = SEND_W_L) then
--					if (sendReady = '0') then
--						address <= address + 1;
--					end if;
--				end if;
--			end if;
--		end if;
--	end process;

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