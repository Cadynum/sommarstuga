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
	     atByteStreamOut : out STD_LOGIC_VECTOR(7 downTo 0));
end At;

--***********************************************************
Architecture Behavioral of At is
	signal enable, readWrite, timerEnable, timeOut, send : STD_LOGIC := '0'; --, runTimer, timeOut : STD_LOGIC := '0';
	signal memBus : STD_LOGIC_VECTOR(7 downTo 0);
	type state_type is (RECEIVE_WAIT_HIGH, RECEIVE_WAIT_LOW, DECODE, DATA_OUT, DATA_IN, ENCODE, SEND_WAIT_HIGH, SEND_WAIT_LOW);
	signal state : state_type := RECEIVE_WAIT_HIGH;
	signal address : INTEGER range memSize-1 downTo 0 := 0; 
	signal counter : UNSIGNED(26 downTo 0) := "000000000000000000000000000";
	constant timerVal : UNSIGNED(26 downTo 0) := baud_1;-- "000000000000000000000010000"; -- time out between bytes
	--signal i : UNSIGNED (26 downto 0) := (others => '0');
	--constant codeWords : CHAR_ARRAY(3 downTo 0) := "test";
begin
	comp_mem : entity work.Mem generic map (memSize => memSize) 
				   port map(clk => clk, rst => rst, enable => enable, readWrite => readWrite, address => address, memBus => memBus);

--	readWrite <= '1' when state = RECEIVE else '0';
--	enable <= '1' when (state = RECEIVE OR state = SEND) else '0';
--	memBus <= atByteStreamIn when (readWrite = '1' AND enable = '1') else (others=>'Z');
--	atByteStreamOut <= memBus when (readWrite = '0' AND enable = '1') else "UUUUUUUU";

	--Next state logic
	--with state select
	--timerEnable <= '1' when RECEIVE_WAIT_LOW | RECEIVE_WAIT_HIGH,
	--	       '0' when others;

	P0 : process (clk, rst)
	begin
		if (rst = '1') then
			state <= RECEIVE_WAIT_HIGH;
		elsif (rising_edge(clk)) then
			case state is 
			when RECEIVE_WAIT_HIGH =>
				if (timeOut = '1') then
					if (address /= 0) then
						state <= DECODE;
					end if;
				elsif (messageAvail = '1') then
					state <= RECEIVE_WAIT_LOW;
				end if;

			when RECEIVE_WAIT_LOW =>
				if (timeOut = '1') then
					state <= DECODE;
				elsif (messageAvail = '0') then
					state <= RECEIVE_WAIT_HIGH;
				end if;

			when DECODE =>
				state <= SEND_WAIT_HIGH;
			when DATA_OUT =>
			when DATA_IN =>
			when ENCODE =>
			when SEND_WAIT_HIGH =>
				if (address = 0) then
					state <= RECEIVE_WAIT_HIGH;
				elsif (sendReady = '1') then 
					state <= SEND_WAIT_LOW;
				end if;
			when SEND_WAIT_LOW =>
				if (sendReady = '0') then 
					state <= SEND_WAIT_HIGH;
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

			if (state = RECEIVE_WAIT_HIGH) then
				timerEnable <= '1';
				if (timeOut = '1' AND address /= 0) then
					address <= address - 1;
				elsif (messageAvail = '1') then  --state change
					enable <= '1';
					readWrite <= '1';
					timerEnable <= '0';
				end if;
			end if;

			if (state = RECEIVE_WAIT_LOW) then
				timerEnable <= '1';
				if (messageAvail = '0') then
					address <= address + 1;
					timerEnable <= '0';
				end if;
			end if;

			if (state = SEND_WAIT_HIGH) then
				if (sendReady = '1') then  --ready goes high, put out data on membus
					enable <= '1';
					readWrite <= '0';
					send <= '1';
				end if;
			end if;

			if (state = SEND_WAIT_LOW) then		-- 1 clk after ready goes high
				if (send = '1') then -- send byte from membus
					send <= '0';
					sendByteOut <= '1';						
				elsif (sendReady = '0') then	-- ready goes low
					address <= address - 1;
				end if;
			end if;
		end if;
	end process;

	P2 : process (clk)
	begin
		if (rising_edge(clk)) then		
			if (state = RECEIVE_WAIT_LOW OR state = RECEIVE_WAIT_HIGH) then
				if (timeOut = '1' OR timerEnable = '0') then
					counter <= (others => '0');
				else
					counter <= counter + 1;
				end if;
			else
				counter <= (others => '0');
			end if;
		end if;
	end process;

	timeOut <= '1' when counter = timerVal else '0';
end Behavioral;