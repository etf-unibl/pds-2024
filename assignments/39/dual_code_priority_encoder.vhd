-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024/
-----------------------------------------------------------------------------
--
-- unit name:     dual_code_priority_encoder
--
-- description:
--
--   This file implements the logic of a Priority Encoder with dual output.
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

entity dual_code_priority_encoder is
  port (
      REQ_i    : in  std_logic_vector(7 downto 0);  -- Input request signal
      CODE1_o  : out std_logic_vector(2 downto 0);  -- First priority output
      CODE2_o  : out std_logic_vector(2 downto 0);  -- Second priority output
      VALID1_o : out std_logic;                     -- Validity of first priority output
      VALID2_o : out std_logic                      -- Validity of second priority output
   );
end dual_code_priority_encoder;

architecture arch of dual_code_priority_encoder is
  signal req_int : unsigned(7 downto 0); -- Internal unsigned version of REQ_i
begin
   -- Convert REQ_i to unsigned for processing
  req_int <= unsigned(REQ_i);
   -- Process to handle the setting of the two highest priority inputs to two outputs
  process(req_int)
    variable temp_req   : unsigned(7 downto 0);  -- Temporary variable for masking
    variable first_bit  : integer range -1 to 7; -- Highest-priority bit index
    variable second_bit : integer range -1 to 7; -- Second-priority bit index
  begin
      -- Initialize variables
    first_bit := -1;
    second_bit := -1;
    temp_req := req_int;

      -- Find the highest-priority bit (CODE1_o)
    for i in 7 downto 0 loop
      if temp_req(i) = '1' then
        first_bit := i;
        exit;
      end if;
    end loop;

      -- If a first priority is found, mask it and search for the second
    if first_bit /= -1 then
      temp_req(first_bit) := '0'; -- Mask the highest-priority bit
      for i in 7 downto 0 loop
        if temp_req(i) = '1' then
          second_bit := i;
          exit;
        end if;
      end loop;
    end if;

      -- Assign outputs based on found bits
    if first_bit /= -1 then
      CODE1_o <= std_logic_vector(to_unsigned(first_bit, 3));
      VALID1_o <= '1';
    else
      CODE1_o <= (others => '0');
      VALID1_o <= '0';
    end if;

    if second_bit /= -1 then
      CODE2_o <= std_logic_vector(to_unsigned(second_bit, 3));
      VALID2_o <= '1';
    else
      CODE2_o <= (others => '0');
      VALID2_o <= '0';
    end if;
  end process;
end arch;

-- No code after this, just an empty line.
