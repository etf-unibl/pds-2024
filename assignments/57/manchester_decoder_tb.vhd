-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024/
-----------------------------------------------------------------------------
--
-- unit name:     manchester_decoder_tb
--
-- description:
--
--   This file implements a testbench for Manchester code decoder.
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

-----------------------------------------------------------------------------
--! @file manchester_decoder_tb.vhd
--! @brief Testbench for the Manchester code decoder functionality
--! @details
--! This testbench verifies the functionality of the Manchester decoder by applying
--! a series of predefined test vectors.
-----------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! @brief Entity declaration for the testbench
entity manchester_decoder_tb is
end manchester_decoder_tb;

architecture arch of manchester_decoder_tb is

  --! @brief Component declaration for the Unit Under Test (UUT)
  component manchester_decoder
    port ( clk_i   : in  std_logic;   --! Clock input
           data_i  : in  std_logic;   --! Input data signal
           data_o  : out std_logic;  --! Output data signal
           valid_o : out std_logic   --! Validity signal
         );
  end component;

  --! @brief Signals used in the testbench
  signal clk_i   : std_logic := '0';  --! Clock signal
  signal data_i  : std_logic := '0';  --! Input data signal
  signal data_o  : std_logic;         --! Output data signal
  signal valid_o : std_logic;         --! Validity signal

  --! @brief Clock period constant
  constant c_CLK_PERIOD : time := 10 ns;

  --! @brief Structure for a single test vector
  type t_test_vector is record
    data_i : std_logic;   --! Input data value
    data_o : std_logic;   --! Expected output data value
    valid_o : std_logic;  --! Expected validity value
  end record t_test_vector;

  --! @brief Array of test vectors
  type t_test_vector_array is array (natural range <>) of t_test_vector;

  --! @brief Predefined test vectors for the testbench
  constant c_TEST_VECTORS : t_test_vector_array := (
    (data_i => '0', data_o => '0', valid_o => '1'),
    (data_i => '1', data_o => '1', valid_o => '1'),
    (data_i => '0', data_o => '1', valid_o => '1'),
    (data_i => '0', data_o => '0', valid_o => '1'),
    (data_i => '1', data_o => '0', valid_o => '1'),
    (data_i => '1', data_o => '1', valid_o => '1'),
    (data_i => '0', data_o => '1', valid_o => '1'),
    (data_i => '0', data_o => '0', valid_o => '1'),
    (data_i => '1', data_o => '0', valid_o => '1'),
    (data_i => '0', data_o => '0', valid_o => '1'),
    (data_i => '1', data_o => '0', valid_o => '1')
  );

begin

  --! @brief Instantiation of the Unit Under Test (UUT)
  uut : manchester_decoder
    port map (
      clk_i   => clk_i,
      data_i  => data_i,
      data_o  => data_o,
      valid_o => valid_o
    );

  --! @brief Clock generation process
  clk_process : process
  begin
    clk_i <= '0';
    wait for c_CLK_PERIOD;
    clk_i <= '1';
    wait for c_CLK_PERIOD;
  end process clk_process;

  --! @brief Stimulus process to apply test vectors
  stim_proc : process
    variable i : integer := 0; --! Index for test vectors
  begin
    --! Loop through each test vector and apply inputs
    for i in 0 to c_TEST_VECTORS'length - 1 loop
      --! Apply data_i from the current test vector
      data_i <= c_TEST_VECTORS(i).data_i;
      wait for c_CLK_PERIOD / 2;

      --! Check expected values for data_o and valid_o
      assert (data_o = c_TEST_VECTORS(i).data_o and valid_o = c_TEST_VECTORS(i).valid_o)
        report "Test failed at time " & time'image(now) severity error;

      wait for c_CLK_PERIOD / 2;
    end loop;

    --! End the simulation
    wait;
  end process stim_proc;

end arch;
