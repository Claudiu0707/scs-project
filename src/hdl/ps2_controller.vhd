library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ps2_controller is
    Port ( 
        rst:     in std_logic;
        clk:     in std_logic;
        ps2c: inout std_logic;             
        ps2d: inout std_logic;
        
        data_ready:       out std_logic;
        ps2_button_left:  out std_logic;
        ps2_button_right: out std_logic;
        ps2_x:  out std_logic_vector(8 downto 0);
        ps2_y:  out std_logic_vector(8 downto 0)
        );
end ps2_controller;

architecture Behavioral of ps2_controller is
    type state_type is (init_state, reset_state, setup_state, 
                        pck_receive_state, pck_check_state, echo_state);
    signal state: state_type := init_state;
    
    -- watchdog timer values
    CONSTANT CLK_FREQ_MHZ:        natural := 100;
    CONSTANT WD_HOLD_STATE_MS:    natural := 1000;  -- hold the state associated with the WD counter for 500ms
    CONSTANT WD_RST_STATE_MS:     natural := 500;   -- retry every 500ms to reset the ps2 device
    CONSTANT WD_ACK_COMMAND_MS:   natural := 50;    -- wait for 50ms for an acknowledgement response from the ps2 device
    CONSTANT WD_PCK_REC_STATE_MS: natural := 10;    -- wait for 10ms for next data package
    
    signal wd1_rst, wd2_rst, wd3_rst, wd4_rst: std_logic := '0';
    
    signal wd_hold_state_rst, wd_rst_state_rst, wd_ack_command_rst, wd_pck_rec_rst: std_logic := '0';
    signal wd_ce_hold_state, wd_ce_rst_state, wd_ce_ack_command, wd_ce_pck_rec_state: std_logic := '0';
    signal wd_done_hold_state, wd_done_rst_state, wd_done_ack_command, wd_done_pck_rec_state: std_logic := '0';
    
    -- init state related signals
    signal init_step: natural range 0 to 1 := 0;
    signal diag_rec: std_logic := '0';
    
    -- reset state related signals
    signal reset_step: natural range 0 to 2 := 0;
    signal rst_cmd_sent: std_logic := '0';
    
    -- setup state related signals
    signal setup_step: natural range 0 to 4 := 0;
    signal setup_done, setup_cmd1_sent, setup_cmd2_sent: std_logic := '0';
    
    -- echo state related signals
    signal echo_step: natural range 0 to 1 := 0;
    signal echo_cmd_sent: std_logic := '0';
    
    -- package receive state related signals
    signal pck_rec_step: natural range 0 to 3 := 0;
    signal pck1, pck2, pck3: std_logic_vector(7 downto 0) := (others => '0');
    signal pck_error: std_logic := '0';
    
    -- ps2_rxtx unit signals
    signal wr_ps2: std_logic := '0';
    signal data_tx, data_rx: std_logic_vector(7 downto 0) := (others => '0');
    signal rx_error, rx_done, tx_error, tx_done: std_logic := '0';
    
    
begin
    ps2_button_left  <= pck1(0);
    ps2_button_right <= pck1(1);
    ps2_x  <= pck1(4) & pck2;
    ps2_y  <= pck1(5) & pck3;


    ps2_rxtx_unit:
    entity WORK.ps2_rxtx port map (
        rst  => rst,
        clk  => clk,
        ps2c => ps2c,
        ps2d => ps2d,
        wr_ps2  => wr_ps2,
        data_tx => data_tx,
        rx_error => rx_error,
        rx_done  => rx_done,
        tx_error => tx_error,
        tx_done  => tx_done,
        data_rx  => data_rx
    );

        
    process (clk, rst)
    begin
        if rst = '1' then    
            state <= init_state;
            init_step <= 0;  reset_step <= 0;  setup_step <= 0;
            echo_step <= 0;  pck_rec_step <= 0;
            rst_cmd_sent <= '0';  echo_cmd_sent <= '0';
            setup_cmd1_sent <= '0';  setup_cmd2_sent <= '0';
            setup_done <= '0';  pck_error <= '0';
            wr_ps2 <= '0';  data_ready <= '0';
            wd_ce_hold_state <= '0';  wd_ce_rst_state <= '0';
            wd_ce_ack_command <= '0';  wd_ce_pck_rec_state <= '0';
            pck1 <= (others => '0');  pck2 <= (others => '0');  pck3 <= (others => '0');
        elsif rising_edge(clk) then
            wr_ps2 <= '0';
            data_ready <= '0';
            case state is
                ----------------------------------------------------------------------------------------------------
                when init_state  =>
                    wd_hold_state_rst <= '0';
                    -- init sequence: 1. wait for 0xAA | 2. wait for 0x00 per the PS2 protocol
                    if init_step = 0 then
                        -- enable watchdog timer
                        if  wd_ce_hold_state = '0' then 
                            wd_ce_hold_state <= '1';
                        else
                            if wd_done_hold_state = '1' then  
                            -- watchdog timer elapsed => try to force reset the ps2 device, deactivate the watchdog timer, reset init sequence
                                state <= reset_state;
                                wd_ce_hold_state <= '0';
                                init_step <= 0;
                            elsif rx_done = '1' AND rx_error = '0' AND data_rx = x"AA" then
                            -- ps2 device internal test passed => move to next step in the init sequence, reset the watchdog timer and deactivate it                     
                                init_step <= 1;
                                wd_hold_state_rst <= '1';
                                wd_ce_hold_state <= '0';
                            end if;
                        end if;                
                    else 
                        -- enable watchdog timer
                        if  wd_ce_hold_state = '0' then 
                            wd_ce_hold_state <= '1';
                        else 
                            if wd_done_hold_state = '1' then 
                            -- watchdog timer elapsed => try to force reset the ps2 device, deactivate the watchdog timer, reset init sequence
                                state <= reset_state;
                                wd_ce_hold_state <= '0';
                                init_step <= 0;
                            elsif rx_done = '1' AND rx_error = '0' AND data_rx = x"00" then
                            -- ps2 device internal id => move to setup state, reset the watchdog timer and deactivate it, reset init sequence   
                                state <= setup_state;
                                wd_hold_state_rst <= '1';
                                wd_ce_hold_state <= '0';
                                init_step <= 0;
                            end if;
                        end if;                    
                    end if;
                    
    
                    
                ----------------------------------------------------------------------------------------------------
                when setup_state =>
                    wd_ack_command_rst <= '0';
                    -- setup sequence: 1. enable stream mode (send 0xEA) | 2. enable data reporting (send 0xF4) per the PS2 protocol
                    if setup_step = 0 then
                        -- enable stream mode and wait for transmission to finish
                        if setup_cmd1_sent = '0' then
                            data_tx <= x"EA";
                            wr_ps2  <= '1';
                            setup_cmd1_sent <= '1';
                        elsif tx_done = '1' then 
                            wr_ps2  <= '0';
                            setup_step <= 1;
                        end if;
                    elsif setup_step = 1 then
                        -- wait for acknowledgement (receive 0xFA) | enable watchdog timer to prevent the controller to remain locked in bad states
                        if wd_ce_ack_command = '0' then
                            wd_ce_ack_command <= '1';
                        else 
                            if wd_done_ack_command = '1' then
                                state <= echo_state;
                                wd_ce_ack_command <= '0';
                                setup_step <= 0;
                                setup_cmd1_sent <= '0';
                                setup_cmd2_sent <= '0';
                            elsif rx_done = '1' AND rx_error = '0' AND data_rx = x"FA" then
                                setup_step <= 2;
                                wd_ack_command_rst <= '1';
                                wd_ce_ack_command <= '0';
                            end if;
                        end if;
                    elsif setup_step = 2 then
                        -- enable data reporting mode and wait for transmission to finish
                        if setup_cmd2_sent = '0' then
                            data_tx <= x"F4";
                            wr_ps2  <= '1';
                            setup_cmd2_sent <= '1';
                        elsif tx_done = '1' then 
                            wr_ps2  <= '0';
                            setup_step <= 3;
                        end if;
                    elsif setup_step = 3 then
                        -- wait for acknowledgement (receive 0xFA) | enable watchdog timer to prevent the controller to remain locked in bad states
                        if wd_ce_ack_command = '0' then
                            wd_ce_ack_command <= '1';
                        else 
                            if wd_done_ack_command = '1' then
                                state <= echo_state;
                                wd_ce_ack_command <= '0';
                                setup_step <= 0;
                                setup_cmd1_sent <= '0';
                                setup_cmd2_sent <= '0';
                            elsif rx_done = '1' AND rx_error = '0' AND data_rx = x"FA" then
                                setup_step <= 4;
                                wd_ack_command_rst <= '1';
                                wd_ce_ack_command <= '0';
                            end if;
                        end if;
                    else 
                        setup_step <= 0;
                        setup_done <= '1';
                        setup_cmd1_sent <= '0';
                        setup_cmd2_sent <= '0';
                        state <= pck_receive_state;
                    end if;
                    
                    
                ----------------------------------------------------------------------------------------------------
                when pck_receive_state =>
                    -- reset watchdog timers for idle state and for next package arrival
                    wd_pck_rec_rst <= '0';
                    wd_hold_state_rst <= '0';
                    if pck_rec_step = 0 then        -- idle state (wait for pck1)
                        if wd_ce_hold_state = '0' then
                            wd_ce_hold_state <= '1';
                        else
                            if wd_done_hold_state = '1' then
                                -- if no packet arrives, check if ps2 device is still available
                                state <= echo_state;
                                wd_ce_hold_state <= '0';
                            elsif rx_done = '1' then 
                                -- packet 1 arrived
                                wd_ce_hold_state <= '0';
                                wd_hold_state_rst <= '1';
                                
                                pck1 <= data_rx;
                                pck_error <= rx_error;
                                
                                pck_rec_step <= 1;
                            end if;
                        end if;    
                        
                    elsif pck_rec_step = 1 then     -- pck1 received (wait for pck2)
                        if wd_ce_pck_rec_state = '0' then
                            wd_ce_pck_rec_state <= '1';
                        else
                            if wd_done_pck_rec_state = '1' then
                                pck_rec_step <= 0;
                                wd_ce_pck_rec_state <= '0';
                            elsif rx_done = '1' then 
                                wd_ce_pck_rec_state <= '0';
                                wd_pck_rec_rst <= '1';
                                
                                pck2 <= data_rx;
                                pck_error <= pck_error OR rx_error;
                                
                                pck_rec_step <= 2;                        
                            end if;
                        end if;
                    elsif pck_rec_step = 2 then     -- pck2 received (wait for pck3)
                        if wd_ce_pck_rec_state = '0' then
                            wd_ce_pck_rec_state <= '1';
                        else
                            if wd_done_pck_rec_state = '1' then
                                pck_rec_step <= 0;
                                wd_ce_pck_rec_state <= '0';
                            elsif rx_done = '1' then 
                                wd_ce_pck_rec_state <= '0';
                                wd_pck_rec_rst <= '1';
                                
                                pck3 <= data_rx;
                                pck_error <= pck_error OR rx_error;
                                
                                pck_rec_step <= 3;                        
                            end if;
                        end if;
                    else                            -- pck3 received
                        pck_rec_step <= 0;
                        state <= pck_check_state;
                    end if;
                    
                ----------------------------------------------------------------------------------------------------
                when pck_check_state =>
                    -- if no error in the received packets, signal the availability of new data
                    if pck_error = '0' then 
                        data_ready <= '1';           
                    end if;
                    state <= pck_receive_state;                   
                    
                ---------------------------------------------------------------------------------------------------- 
                when reset_state =>
                    if reset_step = 0 then
                        if rst_cmd_sent = '0' then
                            data_tx <= x"FF";
                            wr_ps2  <= '1';
                            rst_cmd_sent <= '1';
                        elsif tx_done = '1' then
                            wr_ps2 <= '0';
                            reset_step <= 1;
                        end if;
                    else
                        if wd_ce_hold_state = '0' then
                            wd_ce_hold_state <= '1';
                        else
                            if wd_done_hold_state = '1' then
                                reset_step <= 0;
                                rst_cmd_sent <= '0';
                                wd_ce_hold_state <= '0';
                            elsif rx_done = '1' AND rx_error = '0' AND data_rx = x"FA" then
                                reset_step <= 0;
                                rst_cmd_sent <= '0';
                                wd_ce_hold_state <= '0';
                                setup_done <= '0';
                                setup_step <= 0;
                                setup_cmd1_sent <= '0';
                                setup_cmd2_sent <= '0';
                                init_step <= 0;
                                state <= init_state;
                            end if;
                        end if;
                    end if;
                    
                ----------------------------------------------------------------------------------------------------
                when echo_state =>
                    if echo_step = 0 then
                        if echo_cmd_sent = '0' then
                            data_tx <= x"F4";
                            wr_ps2 <= '1';
                            echo_cmd_sent <= '1';
                        elsif tx_done = '1' then
                            wr_ps2 <= '0';
                            echo_cmd_sent <= '0';
                            echo_step <= 1;
                        end if;
                    else
                        if wd_ce_ack_command = '0' then
                            wd_ce_ack_command <= '1';
                        else 
                            if wd_done_ack_command = '1' then
                                state <= reset_state;
                                wd_ce_ack_command <= '0';
                                echo_step <= 0;
                            elsif rx_done = '1' AND rx_error = '0' AND data_rx = x"FA" then
                                wd_ack_command_rst <= '1';
                                wd_ce_ack_command <= '0';
                                echo_step <= 0;
                                if setup_done = '0' then
                                    state <= setup_state;
                                else
                                    state <= pck_receive_state;
                                end if;
                            end if;
                        end if;        
                    end if;   
            end case;
        end if;
    end process;

    -- reset watchdog timers when global reset = '1' 
    -- or when the counters are not enabled
    wd1_rst <= rst OR NOT wd_ce_hold_state;
    wd2_rst <= rst OR NOT wd_ce_rst_state;
    wd3_rst <= rst OR NOT wd_ce_ack_command;
    wd4_rst <= rst OR NOT wd_ce_pck_rec_state;
    WD_TIMER_HOLD_STATE:
    entity WORK.generic_counter 
        generic map(
            wait_time_ms => WD_HOLD_STATE_MS,
            clk_freq_mhz => CLK_FREQ_MHZ)
        port map (
            rst  => wd1_rst,
            clk  => clk,
            ce   => wd_ce_hold_state,
            done => wd_done_hold_state);
    
    WD_TIMER_RST_STATE:
    entity WORK.generic_counter 
        generic map(
            wait_time_ms => WD_RST_STATE_MS,
            clk_freq_mhz => CLK_FREQ_MHZ)
        port map (
            rst  => wd2_rst,
            clk  => clk,
            ce   => wd_ce_rst_state,
            done => wd_done_rst_state);
    
    WD_TIMER_ACK_COMMAND:
    entity WORK.generic_counter 
        generic map(
            wait_time_ms => WD_ACK_COMMAND_MS,
            clk_freq_mhz => CLK_FREQ_MHZ)
        port map (
            rst  => wd3_rst,
            clk  => clk,
            ce   => wd_ce_ack_command,
            done => wd_done_ack_command);
            
    WD_TIMER_PCK_REC_STATE:
    entity WORK.generic_counter 
        generic map(
            wait_time_ms => WD_PCK_REC_STATE_MS,
            clk_freq_mhz => CLK_FREQ_MHZ)
        port map (
            rst  => wd4_rst,
            clk  => clk,
            ce   => wd_ce_pck_rec_state,
            done => wd_done_pck_rec_state);    
end Behavioral;
