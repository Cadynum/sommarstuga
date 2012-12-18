library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sommarstuga is
port (clk : in std_logic;
      reset : in std_logic;
      lysdioder : out std_logic_vector(3 downto 0);
      dq : inout std_logic;
      segment : buffer std_ulogic_vector(7 downto 0);
      an : buffer std_ulogic_vector(3 downto 0);
      tx : out std_logic;
      rx : in std_logic
      );
end sommarstuga;

architecture behavioral of sommarstuga is
	-- Databussar.
	signal temp : signed(7 downto 0);
	signal nyStatus : std_logic_vector(3 downto 0);
	signal aktuellStatus : std_logic_vector(3 downto 0);
	
	-- Temperatur.
	signal tempPutTempOnDb : std_logic;
	signal tempNowOnDb : std_logic;
	      
	-- Kommunikation.
	signal comHasTempOnDb : std_logic;
	signal comHasElemStatusOnDb : std_logic;
	signal comWantTemp : std_logic;
	signal comWantElemStatus : std_logic;
	signal comHasElemStatus : std_logic;
	      
	-- Element.
	signal elemHasStatusOnDb : std_logic;
	signal elemPutStatusOnDb : std_logic;
	signal elemStatusNowOnDb : std_logic;
	signal elemNewStatusDone : std_logic;

	begin
		
	-- Mappningar av komponenter.
	
	compStyrenhet : entity work.styrenhet port map (
		clk => clk,
		reset => reset,
		tempPutTempOnDb => tempPutTempOnDb,
		tempNowOnDb => tempNowOnDb,
		comHasTempOnDb => comHasTempOnDb,
		comHasElemStatusOnDb => comHasElemStatusOnDb,
		comWantTemp => comWantTemp,
		comWantElemStatus => comWantElemStatus,
		comHasElemStatus => comHasElemStatus,
		elemHasStatusOnDb => elemHasStatusOnDb,
		elemPutStatusOnDb => elemPutStatusOnDb,
		elemStatusNowOnDb => elemStatusNowOnDb,
		elemNewStatusDone => elemNewStatusDone
	);
	
	compElement : entity work.element port map (
		clk => clk,
		reset => reset,
		getNewStatus => elemHasStatusOnDb,
		returnStatus => elemPutStatusOnDb,
		statusOnDb => elemStatusNowOnDb,
		statusUpdated => elemNewStatusDone,
		nyStatus => nyStatus,
		aktuellStatus => aktuellStatus,
		element => lysdioder
	);
	
	compKommunikation : entity work.Com port map (
		clk => clk,
		rst => reset,
		tempInAvail => comHasTempOnDb,
		elementInAvail => comHasElemStatusOnDb,
		requestTemp => comWantTemp,
		requestElement => comWantElemStatus,
		elementOutAvail => comHasElemStatus,
		tempIn => temp,
		elementIn => aktuellStatus,
		elementOut => nyStatus,
		tx => tx,
		rx => rx
	);
	
	compTemperatur : entity work.ds18s20 port map(
		clk => clk,
		reset => reset,
		measure => '1',
		valid => tempNowOnDb,
		DQ => dq,
		temperature => temp
	);
	
	compSjuSegmentDisplay : entity work.segment_temperature port map (
		clk => clk,
		reset => reset,
		rawd => temp,
		an => an,
		segment => segment
	);

end behavioral;