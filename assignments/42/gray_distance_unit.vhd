-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024.git
-----------------------------------------------------------------------------
--
-- unit name:     GRAY DISTANCE CIRCUIT
--
-- description:
--
--   This file implements a simple gray distance calculator logic.
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

entity gray_distance_unit is
  generic (
  g_N : natural := 4
);
  port (
  A_i        : in  std_logic_vector(g_N-1 downto 0);
  B_i        : in  std_logic_vector(g_N-1 downto 0);
  DISTANCE_o : out std_logic_vector(g_N-1 downto 0)
);
end gray_distance_unit;

architecture arch of gray_distance_unit is
begin
  distance_calc : process(A_i, B_i) is
    variable gray_to_bin_A  : std_logic_vector(g_N-1 downto 0);
    variable gray_to_bin_B  : std_logic_vector(g_N-1 downto 0);
    variable bin_A, bin_B   : integer;
    variable diff           : integer;
    variable op1            : integer;
    variable op2            : integer;
  begin
    gray_to_bin_A(g_N-1) := A_i(g_N-1);
    gray_to_bin_B(g_N-1) := B_i(g_N-1);

-- The conversion of Gray to binary code

    for i in g_N-2 downto 0 loop
      gray_to_bin_A(i) := gray_to_bin_A(i+1) xor A_i(i);
      gray_to_bin_B(i) := gray_to_bin_B(i+1) xor B_i(i);
    end loop;

-- Converting a binary vector to an integer

    bin_A := to_integer(unsigned(gray_to_bin_A));
    bin_B := to_integer(unsigned(gray_to_bin_B));

-- Determining the maximum and minimum values

    if bin_B > bin_A then
      op1 := bin_B;
      op2 := bin_A;
    else
      op1 := bin_A;
      op2 := bin_B;
    end if;

    diff := op1 - op2;
    DISTANCE_o <= std_logic_vector(to_unsigned(diff, g_N));
  end process distance_calc;
end arch;
