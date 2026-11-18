library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_generic_counter is
--  Port ( );
end tb_generic_counter;

architecture Behavioral of tb_generic_counter is
    signal wait_time: natural := 500;
    signal clk_freq:  natural := 100;
    
    CONSTANT CLK_PERIOD: time := 10ns;
    signal rst, clk, ce, done: std_logic := '0';
begin
    
    uut: 
    entity WORK.generic_counter 
        generic map(
            wait_time_ms => wait_time,
            clk_freq_mhz => clk_freq)
        port map (
            rst  => rst,
            clk  => clk,
            ce   => ce,
            done => done);
    
    clk_generator:
    process
    begin
        clk <= NOT clk;
        wait for CLK_PERIOD / 2;
        clk <= NOT clk;
        wait for CLK_PERIOD / 2;
    end process;
    
    testbench:
    process
    begin
        wait for 10ns;
        rst <= '1';
        wait for 20ns;
        rst <= '0';
        wait for 30 ns;
        ce <= '1';
        wait for 10 ns;
        ce <= '0';
        wait for 500ms;
    end process;
end Behavioral;
