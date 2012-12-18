library ieee;
use IEEE.std_logic_1164.all;

entity sommarstuga is
port (clk : in std_logic;
      reset : in std_logic;
      lysdioder : out std_logic_vector(3 downto 0)
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
		input => nyStatus,
		output => aktuellStatus,
		element => lysdioder
	);
	
	compKommunikation : entity work.Com (
	
	);

end behavioral;