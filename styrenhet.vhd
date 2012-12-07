library ieee;
use IEEE.std_logic_1164.all;

entity styrenhet is
port (-- Klocka och reset
      clk : in std_logic;
      reset : in std_logic;
      
      -- Temperatur (TEMP)
      tempPutTempOnDb : out std_logic;
      tempNowOnDb : in std_logic;
      
      -- Kommunikation (COM)
      comHasTempOnDb : out std_logic;
      comHasElemStatusOnDb : out std_logic;
      comWantTemp : in std_logic;
      comWantElemStatus : in std_logic;
      comHasElemStatus : in std_logic;
      
      -- Element (ELEM)
      elemHasStatusOnDb : out std_logic;
      elemPutStatusOnDb : out std_logic;
      elemStatusNowOnDb : in std_logic
     );
end styrenhet;

architecture behavioral of styrenhet is

type state_type is (s0, s1, s2);
signal currentState,nextState: state_type;

begin

    p0: process (clk,reset)
    begin
        if (reset='1') then
            currentState <= s0;  --default state on reset.
        elsif (rising_edge(clk)) then
            currentState <= nextState;   --state change.
        end if;
    end process;

    --state machine process.
    p1: process (currentState,
                 tempNowOnDb,
                 comWantTemp,
                 comWantElemStatus,
                 comHasElemStatus,
                 elemStatusNowOnDb)
    begin
        case currentState is
            when s0 => -- Kommunikation (Väntetillstånd)
                if(comWantTemp = '1') then -- temperatur begärd.
                    tempPutTempOnDb <= '1';
                    nextState <= s1;
                elsif(comWantElemStatus = '1') then -- elementens status begärd.
                    elemPutStatusOnDb <= '1';
                    nextState <= s2;
                elsif(comHasElemStatus = '1') then -- ny status för element finns.
                    elemHasStatusOnDb <= '1';
                    nextState <= s0;
                else -- ingenting begärt.
                    nextState <= s0;
                end if;
            
            when s1 => -- Temperatur
                if(tempNowOnDb = '1') then
                    tempPutTempOnDb <= '0';
                    comHasTempOnDb <= '1';
                    nextState <= s0;
                else
                    nextState <= s1;
                end if;

            when s2 => -- Element
                if(elemStatusNowOnDb = '1') then
                    elemPutStatusOnDb <= '0';
                    comHasElemStatusOnDb <= '1';
                    nextState <= s0;
                else
                    nextState <= s2;
                end if;
        end case;
    end process;
end behavioral;
