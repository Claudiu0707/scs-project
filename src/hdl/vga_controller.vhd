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
signal read_address:     integer := 0;

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
    read_addr <= read_address;
    display   <= display_temp;
    
    process (clk)
    begin
        if rising_edge(clk) then
            horizontal_count <= horizontal_count + 1;
            if horizontal_count = H_TOTAL_SIZE then
                horizontal_count <= 0;
                vertical_count <= vertical_count + 1;
                if vertical_count = V_TOTAL_SIZE then
                    vertical_count <= 0;
                end if;
            end if;
            
            -- this section checks if the signal is inside the active area
            if horizontal_count < H_ACTIVE_SIZE and vertical_count < V_ACTIVE_SIZE then
                display_temp <= '1';
                read_address <= read_address + 1; 
                if read_address = 307200 then
                    read_address <= 0;
                end if;
            else
                display_temp <= '0';
            end if;
            
            -- drive low the HSYNC and VSYNC signals after front porch for the specified durations
            if horizontal_count >= H_ACTIVE_SIZE + H_FRONT_PORCH and 
               horizontal_count <  H_ACTIVE_SIZE + H_FRONT_PORCH + H_SYNC_PULSE then
                hsync_temp <= '0';
            else
                hsync_temp <= '1';
            end if;
            if vertical_count >= V_ACTIVE_SIZE + V_FRONT_PORCH and
               vertical_count <  V_ACTIVE_SIZE + V_FRONT_PORCH + V_SYNC_PULSE then
                vsync_temp <= '0'; 
            else
                vsync_temp <= '1';                  
            end if;
        end if;
    end process;
end Behavioral;
