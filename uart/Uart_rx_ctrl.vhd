
-- Uart receive module
--******************************************************

LIBRARY work;
USE work.defs.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

--******************************************************

entity Uart_rx_ctrl is
	Port(clk : in  STD_LOGIC;
	     rst : in  STD_LOGIC;
	     rx : in  STD_LOGIC;                          -- Serial line in.
	     byteOut : out  STD_LOGIC_VECTOR(7 downTo 0); -- The byte read sromt the serial line.
	     byteReady : out STD_LOGIC);                  -- Goes high when byteOut is valid.
end Uart_rx_ctrl;

--******************************************************

architecture Behavioral of Uart_rx_ctrl is
	type State_type is (IDLE, START, RECEIVE, STOP, READY);

	signal timing, shift, sync, toggle : STD_LOGIC := '0';
	signal state, nextState : State_type := IDLE;
	signal divisor : UNSIGNED(26 downTo 0) := baud_76800;
	signal bitIndex : UNSIGNED(2 downTo 0) := "000";
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
	
	shift <= '1' when (timing = '1' AND state = RECEIVE) else '0';
	byteReady <= '1' when (state = READY) else '0';

	with state select
	divisor <= baud_76800 when IDLE,
		   baud_76800 when READY,
		   baud_19200 when START,
		   baud_9600 when others; --RECEIVE and START

	with state select
	sync <= '0' when START,
		'0' when STOP,
		'1' when others; -- IDLE, RECEIVE and READY

	P0 : process(clk, rst)
	begin
		if rst = '1' then
			state <= IDLE;
		elsif (rising_edge(clk)) then
			state <= nextState;
		end if;
	end process;

	P1 : process(clk, state, rx, timing, bitIndex)
	begin
		if(rising_edge(clk)) then
			if(timing = '1') then
				case state is
					when RECEIVE =>
						bitIndex <= bitIndex + 1;
						if(bitIndex = 7) then
							bitIndex <= "000";
							nextState <= STOP;
						end if;
					when IDLE =>
						if (rx = '0') then nextState <= START; 
						end if;
					when START =>
						if (rx = '0') then nextState <= RECEIVE; 
						end if;
					when STOP =>
						if (rx = '1') then
							nextState <= READY;
						else 
							nextState <= IDLE;
						end if;
					when READY =>
						if (rx = '0') then nextState <= START;
						end if;
				end case;
			end if;
		end if;
	end process;

	P2 : process (clk, sync, toggle)
	begin
		if (rising_edge(clk)) then
			if(sync = '1' XOR toggle = '1') then 
				i <= (others => '0');	
				toggle <= not(toggle);

			elsif (timing = '1') then
				i <= (others => '0');
			else
				i <= i + 1;
			end if;
		end if;
	end process;	
	timing <= '1' when (i = divisor) else '0';

end Behavioral;

