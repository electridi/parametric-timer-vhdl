import os
from pathlib import Path
from vunit import VUnit

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()
vu.add_vhdl_builtins()

# Add path and create library 'lib' (Compatible with multiple os)
ROOT = Path(__file__).resolve().parent

lib = vu.add_library("lib")

# Paths
lib.add_source_files(ROOT / "src" / "*.vhd")
lib.add_source_files(ROOT / "test" / "*.vhd")

# Reference the testbench entity
tb = lib.entity("tb_timer")

# Test Case 1: 100MHz clock with 100ns delay
tb.add_config(name="100MHz", generics=dict(clk_freq_hz_g= int(100e6), delay_ns_g=100))

# Test Case 2: 50Mz clock with 200ns delay
tb.add_config(name="50MHz", generics=dict(clk_freq_hz_g=int(50e6), delay_ns_g=200))

# Test Case 3: 1MHz clock with 10us delay
tb.add_config(name="1MHz", generics=dict(clk_freq_hz_g= int(1e6), delay_ns_g=10000))

# Run vunit function
vu.main()