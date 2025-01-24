-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024/
-----------------------------------------------------------------------------
--
-- unit name:     fibonacci_tb
--
-- description:
--
--   This file implements a testbench for the Fibonacci sequence generator
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

entity fibonacci_tb is
end fibonacci_tb;

architecture arch of fibonacci_tb is

  component fibonacci
    port (
            clk_i    : in  std_logic;
            rst_i    : in  std_logic;
            start_i  : in  std_logic;
            n_i      : in  std_logic_vector(5 downto 0);
            r_o      : out std_logic_vector(42 downto 0);
            ready_o  : out std_logic
        );
  end component;

  signal clk_i    : std_logic := '0';
  signal rst_i    : std_logic := '0';
  signal start_i  : std_logic := '0';
  signal n_i      : std_logic_vector(5 downto 0) := "000000";
  signal r_o      : std_logic_vector(42 downto 0);
  signal ready_o  : std_logic;

  constant c_CLK_PERIOD : time := 10 ns;

begin

  uut : fibonacci
    port map (
      clk_i   => clk_i,
      rst_i   => rst_i,
      start_i => start_i,
      n_i     => n_i,
      r_o     => r_o,
      ready_o => ready_o
    );

  clk_process : process
  begin
    clk_i <= '0';
    wait for c_CLK_PERIOD / 2;
    clk_i <= '1';
    wait for c_CLK_PERIOD / 2;
  end process clk_process;


  sim_proc : process
  begin
    -- We're using the 63rd Fibonacci number to inspect the design.
    n_i <= "111111";
    start_i <= '1';
    wait for c_CLK_PERIOD;
    start_i <= '0';
    wait until ready_o = '1';

    -- Asserting the computed Fibonacci(63) matches the expected value,
    -- we can't use "to_integer(unsigned(r_o))" here since it's a 43 bit number
    if r_o /= "1011111011011000111101100000110010011100010" then
      report "Test failed: Fibonacci(63) does not match the expected value" severity error;
    else
      report "Test passed: Fibonacci(63) matches the expected value" severity note;
    end if;

    wait;
  end process sim_proc;

end arch;
