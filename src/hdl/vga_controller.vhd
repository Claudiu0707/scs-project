library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    Port ( 
        rst: in std_logic;
        hsync: out std_logic;
        vsync: out std_logic);
end vga_controller;

architecture Behavioral of vga_controller is
-- These values are according to the VGA standard for 640x480 | 60Hz | 25.175MHz

constant ACTIVE_HORIZONTAL_TIME: time := 25.4222us;

constant H_SYNC_PULSE_TIME:      time := 3.81333us;
constant V_SYNC_PULSE_TIME:      time := 63.5000us;

constant H_FRONT_PORCH_TIME:     time := 0.63555us;
constant H_BACK_PORCH_TIME:      time := 0.63555us;

constant V_FRONT_PORCH_TIME:     time := 317.775us;
constant V_BACK_PORCH_TIME:      time := 1048.65us;

constant IMAGE_TIME: time := 16.6us;
constant LINE_TIME:  time := 31.6ns;
constant PIXEL_TIME: time := 39.721ns; 

constant ACTIVE_HORIZONTAL_SIZE: integer := 640;
constant ACTIVE_VERTICAL_SIZE:   integer := 480;

-- HSYNC and VSYNC signals are driven high when inactive
signal hsync_temp: std_logic := '1';
signal vsync_temp: std_logic := '1';

begin
    hsync <= hsync_temp when rst = '0' else '1';
    vsync <= vsync_temp when rst = '0' else '1';   
    
    process
    begin
        for i in 0 to ACTIVE_VERTICAL_SIZE loop
            wait for ACTIVE_HORIZONTAL_TIME;  
            
            wait for H_FRONT_PORCH_TIME;
            hsync_temp <= '0';
            wait for H_SYNC_PULSE_TIME;
            hsync_temp <= '1';            
            wait for H_BACK_PORCH_TIME;
        end loop;
            
        wait for V_FRONT_PORCH_TIME;
        vsync_temp <= '0';
        wait for V_SYNC_PULSE_TIME;
        vsync_temp <= '1';
        wait for V_BACK_PORCH_TIME;
    end process;
    
end Behavioral;
