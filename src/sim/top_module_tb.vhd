library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_module_tb is
--  Port ( );
end top_module_tb;

architecture Behavioral of top_module_tb is
signal CLK100MHZ: std_logic := '0';
signal VGA_R:     std_logic_vector(3 downto 0);
signal VGA_G:     std_logic_vector(3 downto 0);
signal VGA_B:     std_logic_vector(3 downto 0);
signal VGA_HS:    std_logic;
signal VGA_VS:    std_logic;

begin
    
    process
    begin
        CLK100MHZ <= '0';
        wait for 5ns;
        CLK100MHZ <= '1';
        wait for 5ns;
    end process;
    
    
    top_module_entity: entity WORK.top_module port map (
        CLK100MHZ => CLK100MHZ,
        VGA_R => VGA_R,
        VGA_G => VGA_G,
        VGA_B => VGA_B,
        VGA_HS => VGA_HS,
        VGA_VS => VGA_VS
    );
    
end Behavioral;
