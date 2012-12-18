library ieee;
use IEEE.std_logic_1164.all;

entity element is
port (clk : in std_logic;
      reset : in std_logic;
      getNewStatus : in std_logic;
      returnStatus : in std_logic;
      statusOnDb : out std_logic;
      statusUpdated : out std_logic;
      input : in std_logic_vector(3 downto 0);
      output : out std_logic_vector(3 downto 0);
      element : out std_logic_vector(3 downto 0)
      );
end element;

architecture behavioral of element is
signal status : std_logic_vector(3 downto 0);
begin
    process(clk, reset) begin
        if(reset = '1') then
            statusOnDb <= '0';
            output <= "0000";
            status <= "0000";
            element <= "0000";
        elsif(rising_edge(clk)) then
            statusOnDb <= '0';
            element <= status;
            if(getNewStatus = '1') then
                status <= input;
                statusUpdated <= '1';
            elsif(returnStatus = '1') then
                output <= status;
                statusOnDb <= '1';
            end if;
        end if;
    end process;
end behavioral;