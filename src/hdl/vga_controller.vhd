library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    Port ( 
        clk:   in  std_logic;
        rst:   in  std_logic;
        hsync: out std_logic;
        vsync: out std_logic);
end vga_controller;

architecture Behavioral of vga_controller is

signal H_COUNT: integer := 0;
signal V_COUNT: integer := 0;

-- HSYNC and VSYNC signals are driven high when inactive
signal hsync_temp: std_logic := '1';
signal vsync_temp: std_logic := '1';

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
    process (clk)
    begin
        if rising_edge(clk) then
            H_COUNT <= H_COUNT + 1;
            
            if H_COUNT = H_TOTAL_SIZE then
                H_COUNT <= 0;
                V_COUNT <= V_COUNT + 1;
                if V_COUNT = V_TOTAL_SIZE then
                    V_COUNT <= 0;
                end if;
            end if;
            
            if H_COUNT >= H_ACTIVE_SIZE + H_FRONT_PORCH and 
               H_COUNT <= H_ACTIVE_SIZE + H_FRONT_PORCH + H_SYNC_PULSE then
                hsync_temp <= '0';
            else
                hsync_temp <= '1';
            end if;
               
            if V_COUNT >= V_ACTIVE_SIZE + V_FRONT_PORCH and
               V_COUNT <= V_ACTIVE_SIZE + V_FRONT_PORCH + V_SYNC_PULSE then
                vsync_temp <= '0'; 
            else
                vsync_temp <= '1';                  
            end if;
        end if;
    end process;
    
    hsync <= hsync_temp;
    vsync <= vsync_temp;
    
end Behavioral;
