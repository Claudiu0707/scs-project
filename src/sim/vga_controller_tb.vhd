library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_controller_tb is
--  Port ( );
end vga_controller_tb;

architecture Behavioral of vga_controller_tb is
signal rst, hsync, vsync, display: std_logic := '0';
signal read_addr: integer range 0 to 307199;

signal clk: std_logic := '0';
signal clk100: std_logic := '0';
begin
    rst <= '0';
    
    process
    begin
        clk100 <= '0';
        wait for 5ns;
        clk100 <= '1';
        wait for 5ns;
    end process;
    
    clk_entity: entity WORK.clk25_divider port map(
        clk_in => clk100,
        clk_out => clk
    );
    
    tb: entity WORK.vga_controller port map ( 
        clk => clk,
        rst => rst,
        hsync => hsync,
        vsync => vsync,
        display => display,
        read_addr => read_addr);
        
    
end Behavioral;
