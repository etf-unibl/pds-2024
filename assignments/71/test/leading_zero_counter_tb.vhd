-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/knezicm/pds-2024/
-----------------------------------------------------------------------------
--
-- unit name:     TESTBENCH
--
-- description:
--
--   This file implements a leading zero counter testbench.
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

entity leading_zero_counter_tb is
end leading_zero_counter_tb;

architecture arch of leading_zero_counter_tb is

  component leading_zero_counter is
    port (
      clk_i    : in  std_logic;
      rst_i    : in  std_logic;
      start_i  : in  std_logic;
      n_i      : in  std_logic_vector(15 downto 0);
      ready_o  : out std_logic;
      zeros_o  : out std_logic_vector(4 downto 0)
    );
  end component;

  constant c_TIME : time := 20 ns;
  signal i : integer := 0;

  type t_test_vector is record
    n   : std_logic_vector(15 downto 0);
    res : std_logic_vector(4 downto 0);
  end record t_test_vector;

  type t_test_vector_array is array (natural range <>) of t_test_vector;

  constant c_TEST_VECTOR : t_test_vector_array := (
    ("1010101010101010", "00000"),
    ("0101010101010101", "00001"),
    ("0010101010101010", "00010"),
    ("0001010101010101", "00011"),
    ("0000101010101010", "00100"),
    ("0000010101010101", "00101"),
    ("0000001010101010", "00110"),
    ("0000000101010101", "00111"),
    ("0000000010101010", "01000"),
    ("0000000001010101", "01001"),
    ("0000000000101010", "01010"),
    ("0000000000010101", "01011"),
    ("0000000000001010", "01100"),
    ("0000000000000101", "01101"),
    ("0000000000000010", "01110"),
    ("0000000000000001", "01111"),
    ("0000000000000000", "10000")
  );

  signal stop        : std_logic := '0';
  signal start_test  : std_logic;
  signal rst_test    : std_logic;
  signal clk_test    : std_logic;
  signal n_test      : std_logic_vector(15 downto 0);
  signal ready_test  : std_logic;
  signal zeros_test  : std_logic_vector(4 downto 0) := "00000";
  signal result      : std_logic_vector(4 downto 0);

begin

  uut : leading_zero_counter
    port map (
      clk_i    => clk_test,
      rst_i    => rst_test,
      start_i  => start_test,
      n_i      => n_test,
      ready_o  => ready_test,
      zeros_o  => zeros_test
    );

  rst_test <= '0';

  -- generisanje taktnog signala
  process
  begin

    clk_test <= '0';
    wait for c_TIME / 2;
    clk_test <= '1';
    wait for c_TIME / 2;

    if stop = '1' then
      wait;
    end if;

  end process;

  -- generisanje nove vrijednosti za provjeru 
  process
  begin

    n_test <= c_TEST_VECTOR(i).n;
    result <= c_TEST_VECTOR(i).res;

    wait for c_TIME;

    start_test <= '1'; -- iniciramo obradu( spremnost )

    wait for c_TIME;

    start_test <= '0';

    wait until ready_test = '1';  -- cekamo da kolo izvrsi obradu  
    wait for c_TIME / 2;

    if i < c_TEST_VECTOR'length then
      i <= i + 1;                      --prelazak na sledeci testni vektor
    else
      stop <= '1';
      report "Test completed successfully."
      severity note;
      wait;
    end if;

  end process;

  -- provjera izlaza obrade 
  process
  begin

    if stop = '1' then
      wait;
    end if;

    wait until start_test = '1';
    wait for c_TIME / 4;
    wait until ready_test = '1';
    wait for c_TIME / 4;


    assert false
    report "Checking " & integer'image(to_integer(unsigned(zeros_test))) &
           " and " & integer'image(to_integer(unsigned(result)))
    severity note;

    assert (zeros_test = result)
      report "Error when result = " & integer'image(to_integer(unsigned(zeros_test))) & LF &
             " expected to be = " & integer'image(to_integer(unsigned(result)))
      severity error;
  end process;
end arch;
