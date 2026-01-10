----------------------------
-- Testbench tb_timer.vhd --
----------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- VUnit critical libraries
library vunit_lib;
context vunit_lib.vunit_context;

entity tb_timer is
    generic (
        runner_cfg    : string;
        clk_freq_hz_g : natural := 100_000_000; -- Default frequency: 100 MHz
        delay_ns_g    : natural := 100    -- Using natural because of ghdl's compatibility
    );
end entity;

architecture sim of tb_timer is

    constant delay_g : time := delay_ns_g * 1 ns;   -- cast to time type
    
    -- Interface signals
    signal clk_i   : std_ulogic := '0';
    signal arst_i  : std_ulogic := '0';
    signal start_i : std_ulogic := '0';
    signal done_o  : std_ulogic;

    -- Clock period calculation based on frequency generic
    constant CLK_PERIOD : time := 1 sec / clk_freq_hz_g;

begin

    ---------------------------------------------------------------------------
    -- Clock Generator
    ---------------------------------------------------------------------------
    clk_i <= not clk_i after CLK_PERIOD / 2;

    ---------------------------------------------------------------------------
    -- DUT Instance
    ---------------------------------------------------------------------------
    dut : entity work.timer
        generic map (
            clk_freq_hz_g => clk_freq_hz_g,
            delay_g       => delay_g
        )
        port map (
            clk_i   => clk_i,
            arst_i  => arst_i,
            start_i => start_i,
            done_o  => done_o
        );

    ---------------------------------------------------------------------------
    -- Main Test Process
    ---------------------------------------------------------------------------
    main : process
        variable start_time : time;
        variable end_time   : time;
    begin
        test_runner_setup(runner, runner_cfg);

        -- Initial informative log
        info("Starting test: Freq=" & natural'image(clk_freq_hz_g) & 
             " Hz, Delay=" & time'image(delay_g));

        -- 1. Asynchronous Reset
        arst_i <= '1';
        wait for 2 * CLK_PERIOD;
        arst_i <= '0';
        wait until rising_edge(clk_i);

        -- 2. Initial State Verification (Self-checking)
        check_equal(done_o, '1', "Error: Timer should start in 'done' (IDLE) state");

        -- 3. Trigger the Timer
        start_i <= '1';
        start_time := now;
        wait until rising_edge(clk_i);
        start_i <= '0';

        -- 4. Verify Busy State
        wait for 1 ps; -- Delta cycle margin to observe the transition after clock edge
        check_equal(done_o, '0', "Error: Timer should be BUSY (done_o='0') after start_i pulse");

        -- 5. Wait for the Timer to complete
        wait until done_o = '1';
        end_time := now; -- Capture end timestamp

        -- 6. Verification in a 1 ps range
        check(end_time - start_time >= (delay_g + CLK_PERIOD) - 1 ps and 
              end_time - start_time <= (delay_g + CLK_PERIOD) + 1 ps,
              "Measured duration " & time'image(end_time - start_time) & 
              " is outside tolerance for " & time'image(delay_g));

        info("Test completed successfully after " & time'image(end_time - start_time));

        test_runner_cleanup(runner);
    end process;

end architecture;