library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk25_divider is
    Port (
        clk_in:  in  std_logic;
        clk_out: out std_logic
     );
end clk25_divider;

architecture Behavioral of clk25_divider is

signal count: integer := 0;
signal clk_temp: std_logic := 0;
begin
    process (clk_in)
    begin
        if rising_edge(clk_in) then
            count <= count + 1;
            if count = 2 then
                count   <= 0;
                clk_temp <= NOT clk_temp;
            end if;
        end if;
    end process;
    
    clk_out <= clk_temp;
end Behavioral;
