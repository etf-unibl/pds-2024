-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024.git
-----------------------------------------------------------------------------
--
-- unit name:     MEMORY CONTROLLER (FIRST METHOD) TESTBENCH
--
-- description:
--
--   This file implements a testbench code for memory controller.
--
-----------------------------------------------------------------------------
-- Copyright (c) 2024 Faculty of Electrical Engineering
-----------------------------------------------------------------------------
-- The MIT License
-----------------------------------------------------------------------------
-- Copyright 2024 Faculty of Electrical Engineering
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom
-- the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_ctrl_vhd_tst is
end mem_ctrl_vhd_tst;

architecture arch of mem_ctrl_vhd_tst is
-- ! @brief Signal declarations
  signal clk_i     : std_logic := '0';
  signal rst_i     : std_logic := '0';
  signal mem_i     : std_logic := '0';
  signal rw_i      : std_logic := '0';
  signal burst_i   : std_logic := '0';
  signal oe_o      : std_logic;
  signal we_o      : std_logic;
  signal we_me_o   : std_logic;

  constant c_T : time := 20 ns;

  component mem_ctrl
    port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      mem_i   : in  std_logic;
      rw_i    : in  std_logic;
      burst_i : in  std_logic;
      oe_o    : out std_logic;
      we_o    : out std_logic;
      we_me_o : out std_logic
    );
  end component;

begin
-- ! @brief DUT instantiation
  uut : mem_ctrl
    port map (
      clk_i   => clk_i,
      rst_i   => rst_i,
      mem_i   => mem_i,
      rw_i    => rw_i,
      burst_i => burst_i,
      oe_o    => oe_o,
      we_o    => we_o,
      we_me_o => we_me_o
    );

-- ! @brief Clock generation process
  clock_gen : process
  begin
    while true loop
      clk_i <= '0';
      wait for c_T / 2;
      clk_i <= '1';
      wait for c_T / 2;
    end loop;
  end process clock_gen;

-- ! @brief Stimulus process
  stimulus_proc : process
  begin
-- ! @brief Reset
    rst_i <= '1';
    wait for c_T;
    rst_i <= '0';
    wait for c_T;

-- ! @brief Test 1: Idle
    mem_i <= '0';
    rw_i <= '0';
    burst_i <= '0';
    wait for c_T;
    assert (oe_o = '0' and we_o = '0' and we_me_o = '0')
      report "Test 1 failed: Idle state" severity error;

-- ! @brief Test 2: Write operation
    mem_i <= '1';
    rw_i <= '0';
    burst_i <= '0';
    wait for c_T;
    assert (we_o = '1' and we_me_o = '1' and oe_o = '0')
      report "Test 2 failed: Write operation" severity error;

-- ! @brief Test 3: Single read
    mem_i <= '1';
    rw_i <= '1';
    burst_i <= '0';
    wait for 2*c_T;
    assert (oe_o = '1' and we_o = '0' and we_me_o = '0')
      report "Test 3 failed: Read operation" severity error;

-- ! @brief Test 4: Burst read
    mem_i <= '1';
    rw_i <= '1';  -- Read operation
    burst_i <= '1';  -- Burst read enabled
    wait for 5 * c_T;
    assert (oe_o = '1' and we_o = '0' and we_me_o = '0')
      report "Test 5 failed: Burst read operation" severity error;

-- ! @brief  Test 5: Write operation during burst
    mem_i <= '1';
    rw_i <= '0';  -- Write operation
    burst_i <= '1';  -- Burst read is active
    wait for 2 * c_T;
    assert (we_o = '1' and oe_o = '0' and we_me_o = '1')
      report "Test 6 failed: Write operation during burst" severity error;

-- ! @brief Test 6: Read operation after burst
    mem_i <= '1';
    rw_i <= '1';  -- Read operation
    burst_i <= '0';  -- Burst read finished
    wait for 2 * c_T;
    assert (oe_o = '1' and we_o = '0' and we_me_o = '0')
      report "Test 7 failed: Read operation after burst" severity error;
    wait;
  end process stimulus_proc;
end arch;
