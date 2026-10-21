----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.10.2026 14:52:15
-- Design Name: 
-- Module Name: image_refresh_buffer - Behavioral
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

entity image_refresh_buffer is
 Port (
        clk: in std_logic;
        --reading addr of the pixel
        read_addr: in integer range 0 to 307199;
        --colors of the pixel on 12 bits
        pixel_color:out std_logic_vector(11 downto 0);
        enable:in std_logic;
        --the addr of the modified pixel
        write_addr:in integer range 0 to 307199;
        --final color 
        color:in std_logic_vector(11 downto 0);
        
        display: in std_logic;
        valid_pixel:out std_logic

  );
end image_refresh_buffer;

architecture Behavioral of image_refresh_buffer is

--declaring the necessary memory for the image
--this memory has 307200 locations (640x480)
--each location has 12 bits for the colors
type mem_type is array(0 to 307199) of std_logic_vector(11 downto 0);
--initialize each pixel with the color white
signal image_mem: mem_type := (others => x"FFF");

attribute ram_style:string;
attribute ram_style of image_mem : signal is "block";

signal valid_reg:std_logic:='0';
signal read_data: std_logic_vector(11 downto 0):=(others=>'0');

begin

process(clk)
    begin 
        if rising_edge(clk) then
        
        --read only the active pixels
        --if the vga is in the active reg it reads the pixel
        --if it s not in the active reg it doesn t read new pixels
        --the color is stored in read_data but it s not displayed
            if display='1' then 
                read_data<=image_mem(read_addr);
            end if;
            
            
        --display on the part read 
        --sincronization between memory and valid reg 
            valid_reg<=display;
            
        --write a new pixel
        if enable ='1' then 
             image_mem(write_addr)<=color;
        end if;
        
        end if;
  end process;
         
  --one line on the screen will be organized in 4 areas 
  --display=1=>read mem, color
  --front porch: display =0 =>rgb=black
  --sync porch: display=0=>rgb=black
  --back porch: display=0=>rgc=black
  pixel_color<=read_data when valid_reg='1'
                         else x"000";
  valid_pixel<=valid_reg;         
    
    

end Behavioral;
