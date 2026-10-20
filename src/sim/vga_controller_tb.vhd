library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_controller_tb is
--  Port ( );
end vga_controller_tb;

architecture Behavioral of vga_controller_tb is
signal rst, hsync, vsync: std_logic := '0';
signal clk: std_logic;
begin
    rst <= '0';
    
    process 
    begin
        clk <= '0';
        wait for 19.86ns;
        clk <= '1';
        wait for 19.86ns;
    end process;
    
    tb: entity WORK.vga_controller port map ( 
        clk => clk,
        rst => rst,
        hsync => hsync,
        vsync => vsync);
        
end Behavioral;
