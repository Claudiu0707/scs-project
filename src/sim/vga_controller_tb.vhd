library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_controller_tb is
--  Port ( );
end vga_controller_tb;

architecture Behavioral of vga_controller_tb is
signal rst, hsync, vsync: std_logic := '0';
begin
    rst <= '0';
    tb: entity WORK.vga_controller port map ( 
        rst => rst,
        hsync => hsync,
        vsync => vsync);
        
end Behavioral;
