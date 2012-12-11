library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onewire.all;


entity fpga_tempviewer is
	port	( clk, reset : in std_ulogic
			; DQ : inout std_logic
			; an : buffer std_ulogic_vector(3 downto 0)
			; seg : buffer std_ulogic_vector(7 downto 0)
			);
end entity;


architecture a of fpga_tempviewer is
	signal temperature : signed(7 downto 0);
begin
	sensor:
	entity work.dispatch port map (clk, reset, DQ, temperature);

	display:
	entity work.segment_temperature port map(clk, reset, temperature, an, seg);
end architecture;
