library ieee;
use IEEE.std_logic_1164.all;

entity sommarstuga is
port (clk : in std_logic;
      reset : in std_logic;
      lysdioder : out std_logic_vector(3 downto 0);
      dq : inout std_logic;
      segment : buffer std_ulogic_vector(7 downto 0);
      an : buffer std_ulogic_vector(3 downto 0)      
      );
end sommarstuga;

architecture behavioral of sommarstuga is
	-- Databussar.
	signal temp : std_logic_vector(7 downto 0);
	signal nyStatus : std_logic_vector(3 downto 0);
	signal aktuellStatus : std_logic_vector(3 downto 0);
	
	-- Temperatur.
	signal tempPutTempOnDb : out std_logic;
	signal tempNowOnDb : in std_logic;
	      
	-- Kommunikation.
	signal comHasTempOnDb : out std_logic;
	signal comHasElemStatusOnDb : out std_logic;
	signal comWantTemp : in std_logic;
	signal comWantElemStatus : in std_logic;
	signal comHasElemStatus : in std_logic;
	      
	-- Element.
	signal elemHasStatusOnDb : out std_logic;
	signal elemPutStatusOnDb : out std_logic;
	signal elemStatusNowOnDb : in std_logic;
	signal elemNewStatusDone : in std_logic;

	begin
		
	-- Mappningar av komponenter.
	
	compStyrenhet : entity work.styrenhet map (
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
	
	compElement : entity work.element map (
		clk => clk,
		reset => reset,
		getNewStatus => elemHasStatusOnDb,
		returnStatus => elemPutStatusOnDb,
		statusOnDb => elemStatusNowOnDb,
		statusUpdated => elemNowStatusDone,
		nyStatus => nyStatus,
		aktuellStatus => aktuellStatus,
		element => lysdioder
	);
	
	compKommunikation : entity work.Com (
	
	);
	
	compTemperatur : entity work.ds18s20 (
		clk => clk,
		reset => reset,
		measure => '1',
		valid => tempNowOnDb,
		DQ => dq,
		temperature => temp
	);
	
	compSjuSegmentDisplay : entity work.segment_temperature (
		clk => clk,
		reset => reset,
		rawd => temp,
		an => an,
		segment => segment
	);
	

end behavioral;