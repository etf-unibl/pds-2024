-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024
-----------------------------------------------------------------------------
--
-- unit name:     Testbench
--
-- description:
--
--    This file implements testbench for sequential multiplier with repeated adding,
--    enabling back-to-back multiplication.
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

--! @brief Testbench entity for sequential multiplier
--! @details This entity does not have any ports, as it is self-contained.
entity sequential_multiplier_tb is
end sequential_multiplier_tb;

--! @brief Testbench architecture for sequential multiplier
--! @details This architecture instantiates the sequential multiplier and generates test signals.
architecture seq_mult_arch of sequential_multiplier_tb is

  signal clk_i      : std_logic := '0';
  signal rst_i      : std_logic := '0';
  signal start_test : std_logic := '0';
  signal a_test     : std_logic_vector(7 downto 0)  := (others => '0');
  signal b_test     : std_logic_vector(7 downto 0)  := (others => '0');
  signal c_test     : std_logic_vector(15 downto 0) := (others => '0');
  signal ready_test : std_logic := '0';

  --! @brief Clock period constant
  constant c_T : time := 10 ns;

  --! @brief Component declaration for the sequential multiplier
  component sequential_multiplier
    port(
      clk_i   : in  std_logic;                     --! Clock input
      rst_i   : in  std_logic;                     --! Reset input
      start_i : in  std_logic;                     --! Start signal
      a_i     : in  std_logic_vector(7 downto 0);  --! First operand input
      b_i     : in  std_logic_vector(7 downto 0);  --! Second operand input
      c_o     : out std_logic_vector(15 downto 0); --! Result output
      ready_o : out std_logic                      --! Ready output
    );
  end component;

begin

  --! @brief Instantiate the unit under test (UUT)
  --! @details Connects the testbench signals to the sequential multiplier entity.
  uut : sequential_multiplier
  port map(
    clk_i   => clk_i,
    rst_i   => rst_i,
    start_i => start_test,
    a_i     => a_test,
    b_i     => b_test,
    c_o     => c_test,
    ready_o => ready_test
  );

  --! @brief Clock generation process
  --! @details Generates a periodic clock signal with a defined period.
  clk_process : process
  begin
    clk_i <= '0';
    wait for c_T/2;
    clk_i <= '1';
    wait for c_T/2;
  end process clk_process;

  --! @brief Stimulus process for testing all possible operand combinations
  --! @details Loops through all possible 8-bit values for operands a_test and b_test, and validates results.
  testbench : process
    variable i, j : integer := 0;
  begin
    rst_i <= '1';
    wait for c_T*2;
    rst_i <= '0';
    wait for c_T*2;

    --! Loop through all combinations of a_test and b_test
    for i in 0 to 255 loop
      for j in 0 to 255 loop
        --! Set inputs a_i and b_i
        a_test <= std_logic_vector(to_unsigned(i, 8));
        b_test <= std_logic_vector(to_unsigned(j, 8));

        wait for c_T*2;
        --! Start the multiplication
        start_test <= '1';
        wait for c_T;
        start_test <= '0';

        --! Wait until ready_test is asserted
        wait until ready_test = '1';
        wait for c_T;

        --! Validate the multiplication result
        assert (to_integer(unsigned(c_test)) = to_integer(unsigned(a_test) * unsigned(b_test))) report "Error detected! a = " &
             integer'image(to_integer(unsigned(a_test))) & ", b = " &
             integer'image(to_integer(unsigned(b_test))) & ", Expected = " &
             integer'image(to_integer(unsigned(a_test)) * to_integer(unsigned(b_test))) & ", Got = " &
             integer'image(to_integer(unsigned(c_test))) severity error;
      end loop;
    end loop;

    --! Test completed successfully
    report "Test completed successfully.";
    wait;
  end process;
end seq_mult_arch;
