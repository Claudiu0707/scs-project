library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_module is
    Port (
        CLK100MHZ: in std_logic;
        
        VGA_R:     out std_logic_vector(3 downto 0);
        VGA_G:     out std_logic_vector(3 downto 0);
        VGA_B:     out std_logic_vector(3 downto 0);
        
        VGA_HS:    out std_logic;
        VGA_VS:    out std_logic);
end vga_module;

architecture Behavioral of vga_module is
signal clk25:   std_logic;
signal rst:     std_logic := '0';
signal enable:  std_logic := '0';
signal display: std_logic;
signal valid_pixel: std_logic := '0';

signal pixel_color: std_logic_vector(11 downto 0) := (others => '0'); 
signal color: std_logic_vector(11 downto 0) := (others => '0'); 
signal read_addr:  integer range 0 to 307199;
signal write_addr: integer range 0 to 307199;
begin    
    clk_divider_entity: 
    entity WORK.clk25_divider port map (
        clk_in  => CLK100MHZ,
        clk_out => clk25
    );
 
    vga_controller_entity: 
    entity WORK.vga_controller port map (
        clk => clk25,
        rst => rst,
        hsync => VGA_HS,
        vsync => VGA_VS,
        display => display,
        read_addr => read_addr); 
    
    image_refresh_buffer_entity:
    entity WORK.image_refresh_buffer port map (
        clk         => clk25,
        read_addr   => read_addr,
        enable      => enable,
        write_addr  => write_addr,
        color       => color,
        display     => display,
        pixel_color => pixel_color,
        valid_pixel => valid_pixel);    
    
    VGA_R <= pixel_color(11 downto 8);
    VGA_G <= pixel_color(7  downto 4);
    VGA_B <= pixel_color(3  downto 0);
end Behavioral;
