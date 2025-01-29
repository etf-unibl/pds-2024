-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024
-----------------------------------------------------------------------------
--
-- unit name:     manchester_encoder_tb
--
-- description:
--
--   This file is used to test the functionality of the Manchester encoder circuit.
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

entity manchester_encoder_tb is
end manchester_encoder_tb;

architecture arch of manchester_encoder_tb is
  component manchester_encoder
    port (
      clk_i : in  std_logic;
      rst_i : in  std_logic;
      v_i   : in  std_logic;
      d_i   : in  std_logic;
      y_o   : out std_logic
    );
  end component;

  signal clk_i : std_logic := '0';
  signal rst_i : std_logic := '0';
  signal v_i   : std_logic := '0';
  signal d_i   : std_logic := '0';
  signal y_o   : std_logic;

  constant c_CLOCK_PERIOD : time := 20 ns;

  -- Test vectors
  type t_test_vector is record
    valid_data_v : std_logic;
    data_v : std_logic;
    output_v      : std_logic;
  end record;

  type t_test_vector_array is array (natural range <>) of t_test_vector;
  constant c_TEST_VECTORS : t_test_vector_array := (
    ('0', '0', '0'),
    ('0', '1', '0'),
    ('1', '0', '0'),
    ('1', '1', '1'),
    ('0', '0', '0')
  );

  signal current_test : integer := 0;
  signal expected_output : std_logic;

begin


  uut : manchester_encoder
    port map (
      clk_i => clk_i,
      rst_i => rst_i,
      v_i   => v_i,
      d_i   => d_i,
      y_o   => y_o
    );

  -- Clock generation process
  clk_process : process
  begin
    clk_i <= '0';
    wait for c_CLOCK_PERIOD / 2;
    clk_i <= '1';
    wait for c_CLOCK_PERIOD / 2;
  end process clk_process;

  -- Reset process
  rst_process : process
  begin
    rst_i <= '1';
    wait for 30 ns;
    rst_i <= '0';
    wait;
  end process rst_process;

  test_process : process
  begin
    for i in c_TEST_VECTORS'range loop
      current_test <= i;
      v_i <= c_TEST_VECTORS(i).valid_data_v;
      d_i <= c_TEST_VECTORS(i).data_v;
      expected_output <= c_TEST_VECTORS(i).output_v;

      wait until rising_edge(clk_i);
      wait for 10 ns;

      if y_o = expected_output then
        report "Test case " & integer'image(i + 1) & " passed! Expected value was: " &
        std_logic'image(expected_output) & ", but actual value is: " & std_logic'image(y_o);
      else
        report "Test case " & integer'image(i + 1) & " failed: Expected value was: " &
        std_logic'image(expected_output) & ", but actual value is: " & std_logic'image(y_o)
        severity error;
      end if;
    end loop;

    report "All test cases completed.";
    wait;
  end process test_process;

end arch;
