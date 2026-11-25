library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_module is
    Port (
        RST: in std_logic;
        CLK100MHZ: in std_logic;
        
        PS2_CLK:  inout std_logic;             
        PS2_DATA: inout std_logic;
        
        BTNL: out std_logic;
        BTNR: out std_logic;
        
        VGA_R:     out std_logic_vector(3 downto 0);
        VGA_G:     out std_logic_vector(3 downto 0);
        VGA_B:     out std_logic_vector(3 downto 0);
        
        VGA_HS:    out std_logic;
        VGA_VS:    out std_logic);
end top_module;

architecture Structural of top_module is
signal data_ready: std_logic := '0';
signal ps2_x, ps2_y: std_logic_vector(8 downto 0) := (others => '0');
begin
    vga_module_entity: 
    entity WORK.vga_module port map (
        CLK100MHZ => CLK100MHZ,
        VGA_R => VGA_R,
        VGA_G => VGA_G,
        VGA_B => VGA_B,
        VGA_HS => VGA_HS,
        VGA_VS => VGA_VS);
    
    ps2_controller: 
    entity WORK.ps2_controller port map (
        rst => RST,
        clk => CLK100MHZ,
        ps2c => PS2_CLK,          
        ps2d => PS2_DATA,
        
        data_ready => data_ready,
        ps2_button_left  => BTNL,
        ps2_button_right => BTNR,
        ps2_x  => ps2_x,
        ps2_y  => ps2_y
    );
end Structural;
