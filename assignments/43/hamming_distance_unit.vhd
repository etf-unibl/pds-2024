-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024/
-----------------------------------------------------------------------------
--
-- unit name:     hamming_distance_unit
--
-- description:
--
--   This file implements a hamming distance logic.
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

entity hamming_distance_unit is
  generic(
    g_WIDTH : natural := 8
  );
  port(
    A_i : in  std_logic_vector(g_WIDTH-1 downto 0);
    B_i : in  std_logic_vector(g_WIDTH-1 downto 0);
    Y_o : out std_logic_vector(3 downto 0)
  );
end hamming_distance_unit;

architecture arch of hamming_distance_unit is
  signal axorb : std_logic_vector(g_WIDTH-1 downto 0);
begin
  axorb <= A_i xor B_i;
  circuit_logic : process(axorb)
    variable xor_value    : std_logic_vector(0 downto 0) := "0";
    variable inc_value    : integer   := 0;
    variable counter      : integer   := 0;
  begin
    for i in 0 to (g_WIDTH-1) loop
      xor_value(0) := axorb(i);
      inc_value    := to_integer(unsigned(xor_value));
      counter      := counter + inc_value;
    end loop;
    Y_o <= std_logic_vector(to_unsigned(counter,Y_o'length));
    counter      := 0;
  end process circuit_logic;
end arch;
