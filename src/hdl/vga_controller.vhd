library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    Port ( 
        clk:   in  std_logic;
        rst:   in  std_logic;
        
        hsync:     out std_logic;
        vsync:     out std_logic;
        display:   out std_logic;
        read_addr: out integer range 0 to 307199);
end vga_controller;

architecture Behavioral of vga_controller is

signal horizontal_count: integer := 0;
signal vertical_count:   integer := 0;
signal read_addr_temp:     integer := 0;

-- HSYNC and VSYNC signals are driven high when inactive
signal hsync_temp:   std_logic := '1';
signal vsync_temp:   std_logic := '1';
signal display_temp: std_logic := '0';

-- These values are according to the VGA standard for 640x480 | 60Hz | 25.175MHz
constant H_TOTAL_SIZE:  integer := 800;
constant H_ACTIVE_SIZE: integer := 640;
constant H_FRONT_PORCH: integer := 16;
constant H_BACK_PORCH:  integer := 48;
constant H_SYNC_PULSE:  integer := 96;

constant V_TOTAL_SIZE:  integer := 525;
constant V_ACTIVE_SIZE: integer := 480;
constant V_FRONT_PORCH: integer := 11;
constant V_BACK_PORCH:  integer := 31;
constant V_SYNC_PULSE:  integer := 2;

begin    
    hsync     <= hsync_temp;
    vsync     <= vsync_temp;
    read_addr <= read_addr_temp;
    display   <= display_temp;
        
    -- Update horizontal and vertical count 
    process (clk)
    begin
        if rising_edge(clk) then
            horizontal_count <= horizontal_count + 1;
            if horizontal_count = H_TOTAL_SIZE - 1 then
                horizontal_count <= 0;
                vertical_count <= vertical_count + 1;
                if vertical_count = V_TOTAL_SIZE - 1 then
                    vertical_count <= 0;
                end if; 
            end if;
        end if;
    end process;
    
    -- Compute pixel address and set the flag for valid region
    display_temp <= '1' when horizontal_count < H_ACTIVE_SIZE and vertical_count < V_ACTIVE_SIZE else '0';
    read_addr_temp <= vertical_count * 640 + horizontal_count when display_temp = '1' else 0; 
    
    
    -- Drive the HSYNC and VSYNC signals
    hsync_temp <= '0' when horizontal_count >= H_ACTIVE_SIZE + H_FRONT_PORCH and 
                           horizontal_count < H_ACTIVE_SIZE + H_FRONT_PORCH + H_SYNC_PULSE
                  else '1';
    vsync_temp <= '0' when vertical_count >= V_ACTIVE_SIZE + V_FRONT_PORCH and
                           vertical_count <  V_ACTIVE_SIZE + V_FRONT_PORCH + V_SYNC_PULSE 
                  else '1';        

    
end Behavioral;