library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ps2_tx is
    Port (
        rst:     in std_logic;
        clk:     in std_logic; -- clk signal from the board       
        wr_ps2:  in std_logic;
        ps2c: inout std_logic; -- clk signal from the ps/2 device
        ps2d: inout std_logic;
        data_package: in std_logic_vector(7 downto 0);
        
        tx_idle: out std_logic;
        tx_done: out std_logic
       
     );
end ps2_tx;

architecture Behavioral of ps2_tx is
    type state_type is (idle, rts, start, transmit, stop);
    signal state: state_type := idle;
    
    signal ps2c_tri, ps2d_tri: std_logic := '0';
    signal ps2c_temp, ps2d_temp: std_logic := '0';
    
    CONSTANT line_down_init: integer := 4;
    signal line_down_cnt: integer := 4;
    
    CONSTANT package_size: integer := 8;
    signal package_cnt: integer := 0; 
   
    CONSTANT divisions: integer := 2000;
    signal clk_div_cnt: integer := 0;
    signal clk_div: std_logic := '0';
    
    signal full_package: std_logic_vector(8 downto 0);
    signal parity_bit: std_logic := '1';
    
begin

    -- process for state changes
    process (ps2c, rst, wr_ps2)
    begin
        if rst = '1' then
            state <= idle;
        end if;
        
        case state is
            when idle =>
                if wr_ps2 = '1' then
                    state <= rts;
                    line_down_cnt <= line_down_init;
                    full_package <= parity_bit & data_package;
                end if;
            when rts  =>
                -- stay in this state for at least 100us
                if rising_edge (clk_div) then
                    if line_down_cnt = 0 then
                        state <= start;
                    else 
                        line_down_cnt <= line_down_cnt - 1;
                    end if;
                end if;
            when start =>
                if falling_edge (ps2c) then 
                    state <= transmit;
                    package_cnt <= package_size;
                end if;
            when transmit =>
                if falling_edge(ps2c) then
                    -- shift next bit
                    -- check if all bits where shifted out
                    if package_cnt = 0 then
                        state <= stop;
                    else
                        package_cnt <= package_cnt - 1;
                    end if;
                end if;
            when stop =>
                if falling_edge(ps2c) then
                    tx_done <= '1';
                    state <= idle;
                end if;
        end case;
    end process;
    
    -- process for setting signals according to the state
    process (state)
    begin
        case state is
            when idle =>
                tx_idle  <= '1';
                ps2c_tri <= '0';
                ps2d_tri <= '0';
            when rts  =>
                tx_idle  <= '0';
                tx_done  <= '0';
                ps2c_tri <= '1';
                ps2d_tri <= '1';
                ps2c     <= '0';
            when start =>
                tx_idle  <= '0';
                tx_done  <= '0';
                ps2c_tri <= '1';
                ps2d_tri <= '0';
                ps2c     <= '0';
            when transmit =>
                ps2d <= full_package(0);
                ps2d_tri <= '1';
            when stop =>
        end case;
    end process;
    
    ps2c <= ps2c_temp when ps2c_tri = '0' else 'Z';
    ps2d <= ps2d_temp when ps2d_tri = '0' else 'Z';
    
    -- To send data to the ps2 device, one must hold the clock line down for at least 100us to inhibit any mouse activity. (we will hold for 150us)
    -- During this process, the ps2 device won't produce a clock signal.
    -- For this reason we require an additional clock signal to measure the time the line is held low (the FPGA board clock signal = 100MHz)
    -- We divide it to obtain a clock frequency of 25KHz (similar to mouse frequency)
    process (clk)
    begin
        if rising_edge(clk) then
            clk_div_cnt <= clk_div_cnt + 1;
            if clk_div_cnt = divisions then
                clk_div <= NOT clk_div;
                clk_div_cnt <= 0;
            end if;
        end if;
    end process;
end Behavioral;
