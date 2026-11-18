library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity generic_counter is
    Generic (wait_time_ms: natural;
             clk_freq_mhz: natural);
    Port (
        rst:   in std_logic;
        clk:   in std_logic;
        ce:    in std_logic;
        done: out std_logic
    );
end generic_counter;

architecture Behavioral of generic_counter is
    -- CNT_UPPER_LIMIT = clk_freq (MHz) * 10^3 * time(ms) 
    -- e.g. clk_freq_mhz = 100 | time = 500ms
    --      100 * 10^6 clock periods every second === (convert to ms) ===> 100 * 10^3 clock periods every ms
    --      we want to wait 500ms => CNT_UPPER_LIMIT = 500 * 100 * 10^3 clock periods
    CONSTANT CNT_UPPER_LIMIT: natural := clk_freq_mhz * 1000 * wait_time_ms;
    signal cnt_value: natural range 0 to CNT_UPPER_LIMIT := 0;
    signal running: std_logic := '0';

begin
    counter:
    process (clk, rst)
    begin
        if rst = '1' then 
            cnt_value <= 0;
            done <= '0';
            running <= '0';
        elsif rising_edge(clk) then
            done <= '0';
            if running = '0' then
                if ce = '1' then
                    running <= '1';
                    cnt_value <= 0;
                end if;
            else 
                if cnt_value < CNT_UPPER_LIMIT then
                    cnt_value <= cnt_value + 1;
                else 
                    cnt_value <= 0;
                    done      <= '1';
                    running   <= '0';
                end if;
            end if;
        end if;
    end process;
end Behavioral;
