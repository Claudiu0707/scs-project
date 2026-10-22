library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_module is
    Port (
        CLK100MHZ: in std_logic;
        
        VGA_R:     out std_logic_vector(3 downto 0);
        VGA_G:     out std_logic_vector(3 downto 0);
        VGA_B:     out std_logic_vector(3 downto 0);
        
        VGA_HS:    out std_logic;
        VGA_VS:    out std_logic);
end top_module;

architecture Structural of top_module is
begin
    vga_module_entity: entity WORK.vga_module port map (
        CLK100MHZ => CLK100MHZ,
        VGA_R => VGA_R,
        VGA_G => VGA_G,
        VGA_B => VGA_B,
        VGA_HS => VGA_HS,
        VGA_VS => VGA_VS);

end Structural;
