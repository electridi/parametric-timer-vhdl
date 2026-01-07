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


end architecture rtl;