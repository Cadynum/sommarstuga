package onewire is
	type control_t is (ctl_idle, ctl_read, ctl_write, ctl_reset);
	subtype slot_t is integer range 0 to 15;
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onewire.all;


entity onewire_proto is
	port	( clk, reset : in std_ulogic
			; ready : buffer std_ulogic
			; control : in control_t
			; write_bit : in std_ulogic
			; read_bit, sample_now_d : buffer std_ulogic
			; slot_max : in slot_t
			; slot_cnt : buffer slot_t
			; error : buffer std_ulogic
			; DQ : inout std_logic
			);
end entity;

architecture a of onewire_proto is
	-- // Constants. Times are in usec //
	-- min: 480 max: 960
	constant Treset_pulse : integer := 500;

	-- Longest time allowed for slave to aswers with a presence pulse
	constant Tpresence_timeout : integer := 60;

	constant Tpresence_min : integer := 60;
	-- Longest allowed duration of response pulse plus 1
	constant Tpresence_max : integer := 240;

	--Smallest duration of presence operations
	constant Tpostpresence : integer := Treset_pulse - Tpresence_min;


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
					, Spostpresence
					, Sready
					, Swrite_init
					, Swrite
					, Swrite_recover
					, Sread_init
					, Sread
					, Sread_recover
					);

	-- / Signals //
	signal DQO, DQId, DQI : std_ulogic;
	signal DQFlipFlop : std_ulogic := '1';

	signal state, next_state_signal : state_t;
	signal reset_timer, pulse : boolean;

	signal cnt : integer range 0 to 512-1;

	signal sample_now : std_ulogic;
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

	-- Flip flop input and output for glitch free operation.
	process (clk, reset) begin
		if reset = '1' then
			state <= Sreset;
			DQFlipFlop <= '1';
		elsif rising_edge(clk) then
			state <= next_state_signal;
			sample_now_d <= sample_now;
			if sample_now = '1' then
				read_bit <= DQI;
			end if;
			DQFlipFlop <= DQO;
			DQId <= DQ;
			DQI <= DQId;
		end if;
	end process;


	process (cnt, slot_cnt, slot_max, DQI, state, write_bit, control, pulse) is
		variable next_state : state_t;
	begin
		error <= '0';
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
				reset_timer <= true;
				if DQI = '1' then
					next_state := Spresence1;
				end if;

			-- wait for the slave to start the presence pulse
			when Spresence1 =>
				if DQI = '0' then
					next_state := Spresence2;
				elsif (cnt = Tpresence_timeout-1) and pulse then
					next_state := Sreset;
					error <= '1';
				end if;

			-- wait for the slave to finish the presence pulse
			-- 107us for one sensor
			when Spresence2 =>
				if DQI = '1' then
					if (cnt >= Tpresence_min-1) and pulse then
						next_state := Spostpresence;
					elsif pulse then
						next_state := Sreset;
						error <= '1';
					end if;
				elsif (cnt = Tpresence_max-1) and pulse then
					next_state := Sreset;
					error <= '1';
				end if;

			when Spostpresence =>
				if (cnt = Tpostpresence-1) and pulse then
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
				if (cnt = Twrite_init - 1) and pulse then
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
		next_state_signal <= next_state;
	end process;


end architecture;
