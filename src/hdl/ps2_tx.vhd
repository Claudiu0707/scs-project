library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ps2_tx is
    Port (
        rst:            in std_logic;
        clk:            in std_logic; -- fpga board clock signal   
        wr_ps2:         in std_logic; -- start transmission
        ps2c:        inout std_logic; -- ps2 device clock line
        ps2d:        inout std_logic; -- ps2 device data line
        data_package:  in std_logic_vector(7 downto 0); -- package to be transmitted
        
        tx_idle:  out std_logic;       -- signals receiver component that data and clock line are free/busy
        tx_done:  out std_logic;        -- signals the end of a transmission
        tx_error: out std_logic
     );
end ps2_tx;

architecture Behavioral of ps2_tx is
    type state_type is (idle, rts, start, transmit, stop);
    signal state: state_type := idle;
    
    signal ps2c_tri, ps2d_tri: std_logic := '0';
    signal ps2c_temp, ps2d_temp: std_logic := '0';
    
    CONSTANT LINE_DOWN_CNT_INIT: integer := 7500;
    signal line_down_cnt: integer := 7500;
    
    CONSTANT PACKAGE_CNT_INIT: integer := 8;
    signal package_cnt: integer := 0; 
   
    signal full_package: std_logic_vector(8 downto 0);
    signal parity_bit: std_logic := '1';
    
    signal ps2_clk_history: std_logic_vector(2 downto 0) := "111";
    
begin
    parity_bit <= NOT (data_package(0) XOR data_package(1) XOR data_package(2) XOR data_package(3)
                   XOR data_package(4) XOR data_package(5) XOR data_package(6) XOR data_package(7));
        
    ps2c <= ps2c_temp when ps2c_tri = '1' else 'Z';
    ps2d <= ps2d_temp when ps2d_tri = '1' else 'Z';
    
    process (clk, rst)
    begin
        if rst = '1' then
            state     <= idle;
            tx_idle   <= '1';
            tx_done   <= '0';
            tx_error  <= '0';
            ps2c_tri  <= '0';
            ps2d_tri  <= '0';
            ps2c_temp <= '0';
            ps2d_temp <= '0';
            ps2_clk_history <= "111";
        elsif rising_edge(clk) then
            ps2_clk_history <=  ps2_clk_history(1 downto 0) & ps2c;
            case state is
                when idle =>
                    tx_idle <= '1';  
                    tx_error <= '0';
                    tx_done <= '0';
                    if wr_ps2 = '1' then
                        tx_idle   <= '0';
                        state <= rts;
                        line_down_cnt <= LINE_DOWN_CNT_INIT;
                        full_package  <= parity_bit & data_package;
                    end if;
                when rts  =>
                    ps2c_tri  <= '1';
                    ps2c_temp <= '0';
                    if line_down_cnt = 1 then
                        state <= start;  
                        ps2d_temp <= '0';  
                        ps2d_tri  <= '1';
                    else 
                        line_down_cnt <= line_down_cnt - 1;
                    end if;
                when start =>
                    ps2c_tri  <= '0';
                    if (ps2_clk_history(2) = '1' AND ps2_clk_history(1) = '0') then 
                        ps2d_temp <= full_package(0);
                        full_package <= '0' & full_package(8 downto 1);
                        package_cnt <= PACKAGE_CNT_INIT - 1;
                        state <= transmit;
                    end if;
                when transmit =>
                    if (ps2_clk_history(2) = '1' AND ps2_clk_history(1) = '0') then 
                        ps2d_temp <= full_package(0);
                        full_package <= '0' & full_package(8 downto 1);
                        if package_cnt = 0 then
                            state <= stop;
                        else
                            package_cnt <= package_cnt - 1;
                        end if;
                    end if;
                when stop =>
                    if (ps2_clk_history(2) = '1' AND ps2_clk_history(1) = '0') then 
                        if ps2d_tri = '1' then
                            ps2d_tri <= '0';
                        else              
                            if ps2d /= '0' then    
                                tx_error <= '1';  
                            end if;        
                            tx_done <= '1';
                            state <= idle;
                        end if;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
