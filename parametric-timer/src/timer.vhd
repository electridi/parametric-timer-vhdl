-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Author: Ilaria Di Capua
-- Xilinx FPGA
-- Date: 06/01/2026
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- This entity implements a timer that counts a specific duration based on the input clock frequency and a time generic.
-------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity timer is
    generic (
        clk_freq_hz_g : natural; -- Clock frequency in Hz
        delay_g       : time     -- Delay duration, e.g., 100 ms
    );
    port (
        clk_i   : in std_ulogic;
        arst_i  : in std_ulogic;
        start_i : in std_ulogic; -- No effect if not done_o
        done_o  : out std_ulogic -- ’1’ when not counting ("not busy")
    );
end entity timer;

architecture rtl of timer is

    ---------------------------------------------------------------------------
    -- 1. The total number of cycles (TOTAL_CYCLES) is stored in a 64 bits unsigned.
    --    In this way it is possible to handle both high frequency rates and long delays
    --    (e.g. 100MHz, 60s) otherwise resulting in overflow of the integer type.
    -- 2. To ensure enough precision, TOTAL_CYCLES is computed using 1 ns.
    -- 3. Asynchronous reset is chosen for this entity.
    ---------------------------------------------------------------------------

    -- Total number of cycles: (delay in ns * frequency in Hz) / 10^9
    constant TOTAL_CYCLES : unsigned(63 downto 0) := resize((to_unsigned(delay_g / 1 ns, 64) * to_unsigned(clk_freq_hz_g, 64)) / 1000000000, 64);

    -- Registers
    signal count_reg : unsigned(63 downto 0) := (others => '0');   -- To store the counter's actual value
    signal busy_reg  : std_ulogic := '0';   -- To store the timer state: '0' free, '1' busy

begin

    -- done_o set at '1' when the timer is NOT busy
    done_o <= not busy_reg;

    process(clk_i, arst_i)
    begin
        if arst_i = '1' then
            count_reg <= (others => '0');
            busy_reg  <= '0';
        
        elsif rising_edge(clk_i) then
            if busy_reg = '0' then
                -- If timer is NOT busy and start_i is toggled
                if start_i = '1' then
                    if TOTAL_CYCLES > 0 then 
                        busy_reg  <= '1';
                        count_reg <= to_unsigned(1, 64); -- Counting starts
                    end if;
                end if;
            else
                -- Incrementing counter until it reaches TOTAL_CYCLES
                if count_reg < TOTAL_CYCLES then
                    count_reg <= count_reg + 1;
                else
                    -- Clean-up
                    count_reg <= (others => '0');
                    busy_reg  <= '0';
                end if;
            end if;
        end if;
    end process;

end architecture rtl;