library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.bcdascii_p.all;

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
	     setElement      : out STD_LOGIC := '0';
	     getElement      : out STD_LOGIC;
	     getTemp      : out STD_LOGIC;
	-- data bus
	     tempDataIn : in SIGNED(7 downTo 0);
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
	constant timerVal : UNSIGNED(26 downTo 0) := baud_1;--"000000000000000000000000111";-- time out between control bytes

	-- state machines
	type state_type is (WAIT_COMMAND, WAIT_GET, WAIT_SET, WAIT_EQUALS, SET_ELEM, GET_ELEM, GET_TEMP, WAIT_TEMP_CONVERT, WAIT_TEMP_DATA, WAIT_ELEM_DATA, WAIT_ELEM_HIGH, WAIT_ELEM_LOW, WAIT_ELEM_FIRST, SEND_WL, SEND_WH);
	signal state : state_type := WAIT_COMMAND;
	
	-- 
	signal index, toIndex: integer range 0 to 5 := 0;
	signal elemCount : integer range 0 to 3 := 0;
	signal isTemp : boolean := true;

	-- buffers
	signal elBuf : STD_LOGIC_VECTOR(3 downTo 0);

	signal ascii_go, ascii_ready : std_ulogic;
	signal ascii_chr : asciichr;
	signal ascii_chr_max : bcdbuf_t;


	--constant elemPrefix : character_array := "Element (1,2,3,4) on/off: ";
begin
	comp_bcdascii : entity work.bcdascii port map (clk => clk, reset => rst, rawd => tempDataIn, go => ascii_go,
						       ready => ascii_ready, chr => ascii_chr, chr_max => ascii_chr_max, chr_sel => index);

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
					if (timeOut = '1') then
						state <= WAIT_COMMAND;
					elsif (byteAvail = '1') then
						if (byteIn = char2std('t')) then
							state <= GET_TEMP;
						elsif (byteIn = char2std('e')) then
							state <= GET_ELEM;
						end if;
					end if;

				when WAIT_SET =>
					timerEnable <= '1';
					if (timeOut = '1') then
						state <= WAIT_COMMAND;
					elsif (byteAvail = '1') then
						if (byteIn = char2std('e')) then
							state <= WAIT_EQUALS;
						end if;
					end if;

				when WAIT_EQUALS =>
					timerEnable <= '0';
					if (timeOut = '1') then
						state <= WAIT_COMMAND;
					elsif (byteAvail = '1') then
						if (byteIn = char2std('=')) then
							state <= WAIT_ELEM_FIRST;
						end if;
					end if;

				when WAIT_ELEM_FIRST =>
					if (byteAvail = '0') then
						state <= WAIT_ELEM_HIGH;
					end if;

				when WAIT_ELEM_HIGH =>
					if (byteAvail = '1') then
						state <= WAIT_ELEM_LOW;
					end if;
					
				when WAIT_ELEM_LOW =>
					if (elemCount = 3) then
						state <= SET_ELEM;
					elsif (byteAvail = '0') then
						state <= WAIT_ELEM_HIGH;
					end if;

				when SET_ELEM =>
					state <= WAIT_COMMAND;

				when GET_ELEM =>
					state <= WAIT_ELEM_DATA;

				when GET_TEMP =>
					state <= WAIT_TEMP_DATA;

				when WAIT_TEMP_DATA =>
					if (tempInAvail = '1') then
						state <= WAIT_TEMP_CONVERT;
					end if;

				when WAIT_TEMP_CONVERT =>
					if (ascii_ready = '1') then
						state <= SEND_WH;
					end if;

				when WAIT_ELEM_DATA =>
					if (elementInAvail = '1') then
						state <= SEND_WH;
					end if;

				when SEND_WH =>
					if (sendReady = '1') then
						state <= SEND_WL;
					end if;

				when SEND_WL =>
					if (index = toIndex) then
						state <= WAIT_COMMAND;					
					elsif (sendReady = '0') then
						state <= SEND_WH;
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
			ascii_go <= '0';

			case state is
				when WAIT_ELEM_HIGH =>
					if (byteAvail = '1') then
						if (byteIn = char2std('0')) then
							elBuf(elemCount) <= '0';
						elsif (byteIn = char2std('1')) then
							elBuf(elemCount) <= '1';
						else 
							elBuf <= "1001";
						end if;
					end if;

				when WAIT_ELEM_LOW =>
					if (elemCount = 3) then
						elemCount <= 0;
					elsif (byteAvail = '0') then
						elemCount <= elemCount + 1;
					end if;

				when SET_ELEM =>
					elementDataOut <=  elBuf;
					setElement <= '1';

				when GET_ELEM =>
					getElement <= '1';

				when GET_TEMP =>
					getTemp <= '1';

				when WAIT_TEMP_DATA =>
					if (tempInAvail = '1') then
						isTemp <= true;
						ascii_go <= '1';
					end if;

				when WAIT_TEMP_CONVERT =>
					if (ascii_ready = '1') then
						toIndex <= ascii_chr_max;
						index <= 0;
					end if;

				when WAIT_ELEM_DATA =>
					if (elementInAvail = '1') then
						elBuf <= elementDataIn;
						isTemp <= false;
						toIndex <= elBuf'high;
					end if;

				when SEND_WL =>
					if (index = toIndex) then
						index <= 0;
					elsif (sendReady = '0') then
						index <= index + 1;
					end if;

				when SEND_WH =>
					if (sendReady = '1') then
					sendByte <= '1';
						if (isTemp) then
								byteOut <= ascii_chr;
						else
							byteOut <= "0011000" & elBuf(index);
						end if;
					end if;
				when others =>
					--shouldn't be reached
			end case;
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