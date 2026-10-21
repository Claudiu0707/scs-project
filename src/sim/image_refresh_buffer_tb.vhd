----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.10.2026 09:57:16
-- Design Name: 
-- Module Name: image_refresh_buffer_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity image_refresh_buffer_tb is
--  Port ( );
end image_refresh_buffer_tb;

architecture Behavioral of image_refresh_buffer_tb is

   signal clk: std_logic:='0';
   signal read_addr: integer range 0 to 307199:=0;
   signal pixel_color: std_logic_vector(11 downto 0);
   signal enable: std_logic:='0';
   signal write_addr: integer range 0 to 307199:=0;
   signal color: std_logic_vector(11 downto 0):=x"000";
   signal display: std_logic:='1';
   signal valid_pixel:std_logic;
    
begin

    clk <= not clk after 20 ns;
    
    sim: entity WORK.image_refresh_buffer
        port map(
        clk=>clk,
        read_addr=>read_addr,
        pixel_color=>pixel_color,
        enable=>enable,
        write_addr=>write_addr,
        color=>color,
        display=>display,
        valid_pixel=>valid_pixel
        );
        
process
    begin
        read_addr<=100; --initially the pixel is white
        wait until rising_edge(clk);
        wait for 1 ns;
        
        --verificam daca apare eroarea 
        assert pixel_color = x"FFF"
            report "Error: not white"
            severity error;
            
        
        wait until falling_edge(clk);
        write_addr<=100;
        color<=x"F00";
        enable<='1';
        
        wait until rising_edge(clk);
        wait for 1 ns;
        
        wait until falling_edge(clk);
        enable<='0';
        
        
        --test if we can read and see if the first addr is white
        wait until falling_edge(clk);
        enable<='0';
        read_addr<=101;
        
        wait until rising_edge(clk);
        wait for 1 ns;
        
        assert pixel_color=x"FFF"
            report "error: addr 101 should be white"
            severity error;
            
         --test if we can put blue at 100
         wait until falling_edge(clk);
         write_addr<=0;
         color<=x"00F";
         enable<='1';
         
         wait until falling_edge(clk);
         enable<='0';
         read_addr<=0;
         
         wait until rising_edge(clk);
         wait for 1 ns;
         
         assert pixel_color=x"00F"
            report "error: addr 0 should be blue"
            severity error;
            
            
          --now test if we can put green at the last addr
          wait until falling_edge(clk);
          write_addr<=307199;
          color<=x"0F0";
          enable<='1';
          
          wait until falling_edge(clk);
          enable<='0';
          read_addr<=307199;
          
          wait until rising_edge(clk);
          wait for 1 ns;
          
          assert pixel_color=x"0F0"
            report "error: last addr should be green"
            severity error;
            
            
            wait until falling_edge(clk);
            
            display<='1';
            read_addr<=200;
            write_addr<=200;
            color<=x"0F0";
            enable<='1';
            
            
            --rising edge=>write color
            wait until rising_edge(clk);
            wait for 1 ns;
            
            --stop writting 
            wait until falling_edge(clk);
            enable<='0';
            
            --next rising edge: read the new color
            wait until rising_edge(clk);
            wait for 1 ns;
            
            assert pixel_color=x"0F0"
                report "error: read/write failed"
                severity error;
                
        wait;
        end process;
end Behavioral;
