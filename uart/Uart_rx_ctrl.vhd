LIBRARY work;
USE work.defs.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

--******************************************************

entity Uart_rx_ctrl is
	Port(clk : in  STD_LOGIC;
	     rst : in  STD_LOGIC;
	     rx : in  STD_LOGIC;
	     byteOut : out  STD_LOGIC_VECTOR(7 downTo 0);
	     byteReady : out STD_LOGIC);
end Uart_rx_ctrl;

--******************************************************

architecture Behavioral of Uart_rx_ctrl is
	type State_type is (IDLE, START, RECEIVE, STOP, READY);

	signal baudTiming, shift, sync, toggle : STD_LOGIC := '0';
	signal state, nextState : State_type := IDLE;
	signal divisor : UNSIGNED(26 downTo 0);
	signal bitIndex : natural := 0;
	signal i : UNSIGNED (26 downto 0) := (others => '0');

	component Shift_register is
		Port(clk: in STD_LOGIC;
		     serialIn : in  STD_LOGIC;
		     shift : in  STD_LOGIC;
		     byteOut : out  STD_LOGIC_VECTOR (7 downto 0));
	end component Shift_register;

--******************************************************

begin
	C0 : Shift_register port map(
		clk => clk,
		shift => shift,
		serialIn => rx,
		byteOut => byteOut);
	
	P0 : process(clk, rst)
	begin
		if rst = '1' then
			state <= IDLE;
		elsif (rising_edge(clk)) then
			state <= nextState;
		end if;
	end process;

	shift <= '1' when (baudTiming = '1' AND state = RECEIVE) else '0';
	byteReady <= '1' when (state = READY) else '0';
	divisor <= baud_76800 when (state = IDLE OR state = READY) else 
		   baud_9600 when (state = RECEIVE OR state = STOP) else
		   baud_19200 when (state = START);

	sync <= '1' when state = IDLE else
		'0' when state = START else
		'1' when state = RECEIVE else
		'0' when state = STOP else
		'1' when state = READY;

	P1 : process(clk, state, rx, baudTiming, bitIndex)
	begin
		if(rising_edge(clk)) then
			if(baudTiming = '1') then
				if(state = RECEIVE) then
					bitIndex <= bitIndex + 1;

					if(bitIndex = 7) then
						bitIndex <= 0;
						nextState <= STOP;
					end if;
				elsif(state = IDLE) then
					if (rx = '0') then nextState <= START; 
					end if;
				elsif(state = START) then
					if (rx = '0') then nextState <= RECEIVE; 
					end if;
				elsif(state = STOP) then
					if (rx = '1') then
						nextState <= READY;
					else 
						nextState <= IDLE;
					end if;
				elsif(state = READY) then
					if (rx = '0') then nextState <= START;
					end if;
				end if;
			end if;
		end if;
	end process;

	P2 : process (clk, sync, toggle)
	begin
		if (rising_edge(clk)) then
			if(sync = '1' XOR toggle = '1') then 
				i <= (others => '0');	
				toggle <= not(toggle);

			elsif (baudTiming = '1') then
				i <= (others => '0');
			else
				i <= i + 1;
			end if;
		end if;
	end process;
	
	baudTiming <= '1' when (i = divisor) else '0';

end Behavioral;

