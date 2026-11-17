library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ps2_rx is
    Port ( 
        rst:     in std_logic;
        tx_idle: in std_logic;
        ps2c:    in std_logic;
        ps2d:    in std_logic;
        
        rx_done:      out std_logic;
        rx_error:     out std_logic;
        data_package: out std_logic_vector(7 downto 0)
    );
end ps2_rx;

architecture Behavioral of ps2_rx is
    type state_type is (idle, start, receive, parity, stop);
    signal state: state_type := idle;
    
    signal full_data_package: std_logic_vector(7 downto 0) := (others => '0');
    signal parity_bit, rec_parity_bit: std_logic := '0';
    CONSTANT PACKAGE_CNT_TARGET: integer := 7;
    signal package_cnt: integer := 0; 
begin
    rx_done <= '1' when state = stop else '0';
    rx_error <= rec_parity_bit XOR (NOT parity_bit);
    data_package <= full_data_package(7 downto 0);
    
    process (ps2c, rst) 
    begin
        if rst = '1' then 
            state <= idle;
            package_cnt <= 0;
        else
            if tx_idle = '1' then 
                case state is
                    when idle =>
                        package_cnt <= 0;
                        if falling_edge (ps2c) then
                            if ps2d = '0' then
                                state <= start;
                            end if;
                        end if;
                    when start =>
                        state <= receive;
                    when receive =>
                        if falling_edge(ps2c) then
                            full_data_package <= ps2d & full_data_package(7 downto 1);
                            parity_bit <= parity_bit XOR ps2d;
                            package_cnt <= package_cnt + 1;
                            if package_cnt = PACKAGE_CNT_TARGET then
                                state <= parity;
                            end if;
                        end if; 
                    when parity =>
                        if falling_edge(ps2c) then
                            rec_parity_bit <= ps2d;
                            state <= stop;
                        end if;
                    when stop =>
                        if falling_edge(ps2c) then
                            state <= idle;
                        end if;
                end case;
            end if;               
        end if;
    end process;    
end Behavioral;
