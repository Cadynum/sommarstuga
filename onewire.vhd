package onewire is
	type control_t is (ctl_idle, ctl_read, ctl_write, ctl_reset);
	subtype slot_t is integer range 0 to 127;
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onewire.all;


entity onewire_proto is
	port	( clk, reset : in std_ulogic
			; ready : out std_ulogic
			; control : in control_t
			; write_bit : in std_ulogic
			; read_bit : out std_ulogic
			; sample_now : out std_ulogic
			; slot_max : in slot_t
			; slot_cnt_o : out slot_t
			; DQ : inout std_logic
			);
end entity;

architecture a of onewire_proto is
	-- // Constants. Times are in usec //
	-- min: 480 max: 960
	constant Treset_pulse : integer := 480;


	-- Write and read slots. Each slot have a >60usec duration, with >1usec
	--   obligatory recovery time.
	-- Values calibrated against one sensor

	-- min: 1 max: inf
	constant Trc : integer := 5;
	-- min: 60 max: 120 (for 0 write slot), otherwise inf
	constant Tslot : integer := 70;

	-- min: 1 max: 15
	constant Twrite_init : integer := 5;
	-- min/max: 60
	constant Twrite_hold : integer := Tslot - Twrite_init;

	-- Read slot
	-- The slave will get the value within 15us after the bus master pulls DQ low.
	constant Tread_init : integer := 5;
	constant Tread_sample : integer := 13 - Tread_init;
	constant Tread_recover : integer := Tslot + Trc - Tread_sample - Tread_init;



	-- // Types //
	type state_t is	( Sreset
					, Spostreset
					, Spresence1
					, Spresence2
					, Sready
					, Swrite_init
					, Swrite
					, Swrite_recover
					, Sread_init
					, Sread
					, Sread_recover
					);

	-- / Signals //
	signal DQO : std_ulogic;
	signal DQFlipFlop : std_ulogic := '1';
-- 	signal sample_now : std_logic;

	signal state, next_state_signal : state_t;
	signal reset_timer, pulse : boolean;

	signal cnt : integer range 0 to 1023;

	signal slot_cnt : slot_t;
	signal slot_cnt_inc, slot_cnt_reset : boolean;
begin
	usec_timer:
	entity work.timer port map (clk, reset, reset_timer, pulse);

	user_counter:
	process (clk, reset) begin
		if reset = '1' then
			cnt <= 0;
		elsif rising_edge(clk) then
			if reset_timer then
				cnt <= 0;
			elsif pulse then
				cnt <= cnt + 1;
			end if;
		end if;
	end process;


	slot_counter:
	process (clk, reset) begin
		if reset = '1' then
			slot_cnt <= 0;
		elsif rising_edge(clk) then
			if slot_cnt_reset then
				slot_cnt <= 0;
			elsif slot_cnt_inc then
				slot_cnt <= slot_cnt + 1;
			end if;
		end if;
	end process;


	DQ <= '0' when DQFlipFlop = '0' else 'Z';
	slot_cnt_o <= slot_cnt;

	process (clk, reset) begin
		if reset = '1' then
			state <= Sreset;
			DQFlipFlop <= '1';
		elsif rising_edge(clk) then
			state <= next_state_signal;
			if state = Sread then
				read_bit <= DQ;
			end if;
			DQFlipFlop <= DQO;
		end if;
	end process;


	process (cnt, slot_cnt, slot_max, DQ, state, write_bit, control, pulse) is
		variable next_state : state_t;
	begin
		reset_timer <= false;
		slot_cnt_reset <= false;
		slot_cnt_inc <= false;
		ready <= '0';
		sample_now <= '0';
		next_state := state;
		DQO <= '1';
		case state is
			-- Pull the pin low to reset the sensor(s)
			when Sreset =>
				DQO <= '0';
				if (cnt = Treset_pulse-1) and pulse then
					next_state := Spostreset;
				end if;

			-- wait for DQ to go high
			when Spostreset =>
--					if cnt = postreset_time then
--						next_state := Spresence1;
--					end if;
				reset_timer <= true;
				if DQ = '1' then
					next_state := Spresence1;
				end if;

			-- wait for the slave to start the precence pulse
			when Spresence1 =>
				reset_timer <= true;
				if DQ = '0' then
					next_state := Spresence2;
				end if;

			-- wait for the slave to finish the precence pulse
			-- 107us for one sensor
			when Spresence2 =>
				reset_timer <= true;
				if DQ = '1' then -- and.. just to be safe. remove later
					next_state := Sready;
				end if;

			-- Ready and waiting for commands
			when Sready =>
				reset_timer <= true;
				slot_cnt_reset <= true;
				ready <= '1';
				case control is
					when ctl_idle => null;
					when ctl_write => next_state := Swrite_init;
					when ctl_read => next_state := Sread_init;
					when ctl_reset => next_state := Sreset;
				end case;

			-- start a write slot by pulling the pin low
			when Swrite_init =>
				DQO <= '0';
				if cnt = Twrite_init - 1 and pulse then
					next_state := Swrite;
				end if;

			-- write the bit (LSB first)
			when Swrite =>
				DQO <= write_bit;
				if (cnt = Twrite_hold - 1) and pulse then
					next_state := Swrite_recover;
				end if;

			-- recover from the write slot
			when Swrite_recover =>
				if (cnt = Trc - 1) and pulse then
					if slot_cnt = slot_max then
						next_state := Sready;
					else
						slot_cnt_inc <= true;
						next_state := Swrite_init;
					end if;
				end if;

			-- Start a read slot by pulling the pin low
			when Sread_init =>
				DQO <= '0';
				if (cnt = Tread_init - 1) and pulse then
					next_state := Sread;
				end if;

			-- Sample the data (LSB first)
			when Sread =>
				if (cnt = Tread_sample -1) and pulse then
					sample_now <= '1';
					next_state := Sread_recover;
				end if;

			-- Recover from the read slot
			when Sread_recover =>
				if cnt = Tread_recover then
					if slot_cnt = slot_max then
						next_state := Sready;
					else
						slot_cnt_inc <= true;
						next_state := Sread_init;
					end if;
				end if;
		end case;
		-- Always reset the timer for the next state
		if next_state /= state then
			reset_timer <= true;
		end if;
		--avoid wasting one cycle
		--if next_state = Sready then
			--ready <= '1';
		--end if;
		next_state_signal <= next_state;
	end process;


end architecture;
