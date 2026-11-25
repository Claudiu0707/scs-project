library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ps2_rxtx_top is
    Port (
        rst: in std_logic;
        clk: in std_logic;
        wr:  in std_logic;
        
        ps2c:   inout std_logic;
        ps2d:   inout std_logic;
        
        data_tx: in std_logic_vector(7 downto 0);
        data_rx: out std_logic_vector(7 downto 0);
        
        rx_error: out std_logic;
        rx_done:  out std_logic;
        tx_error: out std_logic;
        tx_done:  out std_logic
    
     );
end ps2_rxtx_top;

architecture Behavioral of ps2_rxtx_top is
signal wr_deb: std_logic := '0';
begin
    debounce_entity:
    entity WORK.debouncer port map (
       Clk => clk,
       Rst => rst,
       Din => wr,
       Qout => wr_deb);
       
       
    ps2_rxtx_entity:
    entity WORK.ps2_rxtx port map (
        rst => rst,
        clk => clk,
        ps2c => ps2c,
        ps2d => ps2d,
        
        wr_ps2 => wr_deb,
        data_tx => data_tx,
        
        rx_error => rx_error,
        rx_done  => rx_done,
        tx_error => tx_error,
        tx_done  => tx_done,
        data_rx => data_rx);
end Behavioral;
