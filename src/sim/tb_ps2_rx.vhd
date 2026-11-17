-- Testbench fully AI generated using Gemini --

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ps2_rx is
end tb_ps2_rx;

architecture sim of tb_ps2_rx is

    -- Component Declaration for the Unit Under Test (UUT)
    component ps2_rx
        Port (  
            rst          : in std_logic;
            tx_idle      : in std_logic;
            ps2c         : in std_logic;
            ps2d         : in std_logic;
            rx_done      : out std_logic;
            rx_error     : out std_logic;
            data_package : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Inputs
    signal rst     : std_logic := '0';
    signal tx_idle : std_logic := '1';
    signal ps2c    : std_logic := '1';
    signal ps2d    : std_logic := '1';

    -- Outputs
    signal rx_done      : std_logic;
    signal rx_error     : std_logic;
    signal data_package : std_logic_vector(7 downto 0);

    -- Clock period constant (e.g., 50us clock period -> 20 kHz PS/2 clock)
    constant CLK_PERIOD : time := 50 us;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: ps2_rx 
        Port map (  
            rst          => rst,
            tx_idle      => tx_idle,
            ps2c         => ps2c,
            ps2d         => ps2d,
            rx_done      => rx_done,
            rx_error     => rx_error,
            data_package => data_package
        );

    -- Stimulus process
    stim_proc: process
        
        -- Procedure to send a PS/2 packet with automatic odd parity calculation
        procedure send_ps2_byte(
            constant data       : in std_logic_vector(7 downto 0);
            constant inject_err : in boolean := false
        ) is
            variable parity : std_logic;
        begin
            -- Calculate odd parity: total number of 1s in data + parity must be odd
            -- Therefore, parity = NOT (XOR of all data bits)
            parity := NOT (data(0) XOR data(1) XOR data(2) XOR data(3) XOR 
                           data(4) XOR data(5) XOR data(6) XOR data(7));
            
            if inject_err then
                parity := NOT parity; -- Flip parity to force a parity error
            end if;

            -- 1. Start Bit (Always '0')
            ps2c <= '1';
            ps2d <= '0';
            wait for CLK_PERIOD / 2;
            ps2c <= '0'; -- Falling edge triggers state machine read
            wait for CLK_PERIOD / 2;

            -- 2. Data Bits (LSB first)
            for i in 0 to 7 loop
                ps2c <= '1';
                ps2d <= data(i);
                wait for CLK_PERIOD / 2;
                ps2c <= '0'; -- Falling edge
                wait for CLK_PERIOD / 2;
            end loop;

            -- 3. Parity Bit
            ps2c <= '1';
            ps2d <= parity;
            wait for CLK_PERIOD / 2;
            ps2c <= '0'; -- Falling edge
            wait for CLK_PERIOD / 2;

            -- 4. Stop Bit (Always '1' for valid frame)
            ps2c <= '1';
            ps2d <= '1';
            wait for CLK_PERIOD / 2;
            ps2c <= '0'; -- Falling edge
            wait for CLK_PERIOD / 2;

            -- Return clock to idle high state between packets
            ps2c <= '1';
            ps2d <= '1';
            wait for CLK_PERIOD * 2;
        end procedure;

        -- Variable for manual test scenarios
        variable test_byte : std_logic_vector(7 downto 0);

    begin
        -- 1. Apply Reset
        rst <= '1';
        tx_idle <= '1';
        ps2c <= '1';
        ps2d <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for CLK_PERIOD;

        report "--- Starting PS/2 Receiver Simulations ---";

        -- Test 1: Send valid byte 0x3A
        report "Sending valid data: 0x3A";
        send_ps2_byte(X"3A", false);
        
        -- Test 2: Send valid byte 0xF0
        report "Sending valid data: 0xE0";
        send_ps2_byte(X"E0", false);

        -- Test 3: Send byte with an intentional Parity Error
        report "Sending data with injected PARITY error: 0x55";
        send_ps2_byte(X"55", true);

        -- Test 4: Send framing error (Stop bit left low instead of high)
        report "Sending data with INJECTED FRAMING error (Stop bit = 0)";
        test_byte := X"AA";

        -- Start bit
        ps2c <= '1'; ps2d <= '0'; wait for CLK_PERIOD/2; ps2c <= '0'; wait for CLK_PERIOD/2; 
        
        -- Data bits (using variable instead of literal)
        for i in 0 to 7 loop
            ps2c <= '1'; 
            ps2d <= test_byte(i); 
            wait for CLK_PERIOD/2; 
            ps2c <= '0'; 
            wait for CLK_PERIOD/2; 
        end loop;
        
        -- Parity bit
        ps2c <= '1'; ps2d <= '0'; wait for CLK_PERIOD/2; ps2c <= '0'; wait for CLK_PERIOD/2; 
        
        -- STOP BIT FORCED TO '0' (Framing Error)
        ps2c <= '1'; ps2d <= '0'; wait for CLK_PERIOD/2; ps2c <= '0'; wait for CLK_PERIOD/2; 
        
        -- Return to idle
        ps2c <= '1'; ps2d <= '1'; wait for CLK_PERIOD * 2;

        report "--- Simulation Completed Successfully ---";
        wait;
    end process;

end sim;