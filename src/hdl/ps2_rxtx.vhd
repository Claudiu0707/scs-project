library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ps2_rxtx is
    Port ( 
        rst:    in std_logic;
        clk:    in std_logic;
        ps2c:   inout std_logic;
        ps2d:   inout std_logic;
        
        wr_ps2:  in std_logic;
        data_tx: in std_logic_vector(7 downto 0);
        
        rx_error: out std_logic;
        rx_done:  out std_logic;
        tx_done:  out std_logic;
        data_rx:  out std_logic_vector(7 downto 0)
    );
end ps2_rxtx;

architecture Behavioral of ps2_rxtx is
    signal tx_idle: std_logic := '1';
begin
    ps2_rx_unit:
        entity WORK.ps2_rx port map (
                rst          => rst,
                tx_idle      => tx_idle,
                ps2c         => ps2c,
                ps2d         => ps2d,
                rx_done      => rx_done,
                rx_error     => rx_error,
                data_package => data_rx
        );
    
    ps2_tx_unit:
        entity WORK.ps2_tx port map (
                    rst          => rst,
                    clk          => clk,
                    wr_ps2       => wr_ps2,
                    ps2c         => ps2c,
                    ps2d         => ps2d,
                    data_package => data_tx,
                    tx_idle      => tx_idle,
                    tx_done      => tx_done
        );

end Behavioral;
