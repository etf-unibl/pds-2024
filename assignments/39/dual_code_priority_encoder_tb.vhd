-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024/
-----------------------------------------------------------------------------
--
-- unit name:     dual_code_priority_encoder_tb
--
-- description:
--
--   This file implements a testbench for the Priority Encoder with dual output.
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

entity dual_code_priority_encoder_tb is
-- No ports for a test bench
end dual_code_priority_encoder_tb;

architecture arch of dual_code_priority_encoder_tb is
    -- Component declaration for the DUT
  component dual_code_priority_encoder is
    port (
            REQ_i    : in  std_logic_vector(7 downto 0);
            CODE1_o  : out std_logic_vector(2 downto 0);
            CODE2_o  : out std_logic_vector(2 downto 0);
            VALID1_o : out std_logic;
            VALID2_o : out std_logic
        );
  end component;

    -- Signals to connect to the DUT
  signal REQ_i_tb    : std_logic_vector(7 downto 0) := (others => '0');
  signal CODE1_o_tb  : std_logic_vector(2 downto 0);
  signal CODE2_o_tb  : std_logic_vector(2 downto 0);
  signal VALID1_o_tb : std_logic;
  signal VALID2_o_tb : std_logic;

    -- Simulation control
  signal clk      : std_logic := '0';
  signal done     : boolean := false;

begin
    -- DUT instantiation
  uut : dual_code_priority_encoder
        port map (
            REQ_i    => REQ_i_tb,
            CODE1_o  => CODE1_o_tb,
            CODE2_o  => CODE2_o_tb,
            VALID1_o => VALID1_o_tb,
            VALID2_o => VALID2_o_tb
        );

    -- Clock generation (useful for timing consistency)
  clk_process : process
  begin
    while not done loop
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;
    end loop;
    wait;
  end process clk_process;

    -- Test process
  test_process : process
    variable expected_code1 : integer;
    variable expected_code2 : integer;
    variable expected_valid1 : std_logic;
    variable expected_valid2 : std_logic;
    variable req_unsigned : unsigned(7 downto 0);
  begin
        -- Test cases
    for i in 0 to 255 loop

      REQ_i_tb <= std_logic_vector(to_unsigned(i, 8));
      wait for 20 ns; -- Allow time for DUT to process

            -- Take the input
      req_unsigned := unsigned(REQ_i_tb);
      expected_code1 := -1;
      expected_code2 := -1;

            -- Find the first priority bit
      for j in 7 downto 0 loop
        if req_unsigned(j) = '1' then
          expected_code1 := j;
          req_unsigned(j) := '0'; -- Mask it
          exit;
        end if;
      end loop;

            -- Find the second priority bit
      for j in 7 downto 0 loop
        if req_unsigned(j) = '1' then
          expected_code2 := j;
          exit;
        end if;
      end loop;

            -- Determine validity
      if expected_code1 /= -1 then
        expected_valid1 := '1';
      else
        expected_valid1 := '0';
      end if;

      if expected_code2 /= -1 then
        expected_valid2 := '1';
      else
        expected_valid2 := '0';
      end if;


            -- Check results
      if expected_code1 /= -1 then
        assert CODE1_o_tb = std_logic_vector(to_unsigned(expected_code1, 3))
                  report "Test failed for REQ_i_tb = " & integer'image(i) & ". CODE1_o_tb mismatch!"
                   severity error;
      else
        assert CODE1_o_tb = "000" -- Default value when no valid bit is found
                  report "Test failed for REQ_i_tb = " & integer'image(i) & ". CODE1_o_tb mismatch!"
                  severity error;
      end if;


      if expected_code2 /= -1 then
        assert CODE2_o_tb = std_logic_vector(to_unsigned(expected_code2, 3))
               report "Test failed for REQ_i_tb = " & integer'image(i) & ". CODE2_o_tb mismatch!"
                 severity error;
      else
        assert CODE2_o_tb = "000" -- Default value when no valid bit is found
               report "Test failed for REQ_i_tb = " & integer'image(i) & ". CODE2_o_tb mismatch!"
                severity error;
      end if;
      assert VALID1_o_tb = expected_valid1
                report "Test failed for REQ_i_tb = " & integer'image(i) & ". VALID1_o_tb mismatch!"
                severity error;
      assert VALID2_o_tb = expected_valid2
                report "Test failed for REQ_i_tb = " & integer'image(i) & ". VALID2_o_tb mismatch!"
               severity error;
    end loop;

         -- End simulation
    done <= true;
    wait;
  end process test_process;
end arch;

-- No code after this, just an empty line.
