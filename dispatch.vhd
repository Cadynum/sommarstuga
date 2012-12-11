library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onewire.all;


entity dispatch is
	port	( clk, reset : in std_ulogic
			; DQ : inout std_logic
			; temperature : buffer signed(7 downto 0) := (others => '0')
			);
end entity;

architecture a of dispatch is
	type state_t is ( init1
					, skiprom_convt
					, wait_convt
					, init2
					, skiprom_copy
					, read_temp
					);
	signal state, next_state : state_t;

	constant skipandconv : std_ulogic_vector(15 downto 0) := x"44CC";
	constant readscratch : std_ulogic_vector(15 downto 0) := x"BECC";

	signal control : control_t;
	signal write_bit, read_bit, ready, sample_now, pushtemp, error : std_ulogic;
	signal slot_max, slot_cnt : slot_t;
	signal inbuf : std_ulogic_vector(7 downto 0) := x"00";
begin



	onewire_proto:
	entity work.onewire_proto port map
		( clk => clk
		, reset => reset
		, ready => ready
		, control => control
		, write_bit => write_bit
		, read_bit => read_bit
		, sample_now_d => sample_now
		, slot_max => slot_max
		, slot_cnt => slot_cnt
		, DQ => DQ
		, error => error
		);

	process (clk, reset) begin
		if reset = '1' then
			state <= init1;
			temperature <= (others => '0');
			inbuf <= x"00";
		elsif rising_edge(clk) then
			state <= next_state;
			if pushtemp = '1' then
				temperature <= signed(inbuf);
			end if;
			if sample_now = '1' then
				inbuf(slot_cnt) <= read_bit;
			end if;
		end if;
	end process;

	process (state, ready, slot_cnt, inbuf) begin
		control <= ctl_idle;
		next_state <= state;
		slot_max <= 0;
		write_bit <= '-';
		pushtemp <= '0';
		case state is
			when init1 =>
				if ready = '1' then
					next_state <= skiprom_convt;
					control <= ctl_write;
				end if;

			when skiprom_convt =>
				slot_max <= skipandconv'high;
				write_bit <= skipandconv(slot_cnt);
				if ready = '1' then
					next_state <= wait_convt;
					control <= ctl_read;
				end if;

			when wait_convt =>
				control <= ctl_read;
				slot_max <= inbuf'high;
				if inbuf = x"FF" and ready = '1' then
					next_state <= init2;
					control <= ctl_reset;
				end if;

			when init2 =>
				if ready = '1' then
					next_state <= skiprom_copy;
					control <= ctl_write;
				end if;

			when skiprom_copy =>
				slot_max <= readscratch'high;
				write_bit <= readscratch(slot_cnt);
				if ready = '1' then
					next_state <= read_temp;
					control <= ctl_read;
				end if;

			when read_temp =>
				slot_max <= inbuf'high;
				if ready = '1' then
					pushtemp <= '1';
					next_state <= init1;
					control <= ctl_reset;
				end if;

			end case;
	end process;

end architecture;
