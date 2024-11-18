-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/pds-2023/
-----------------------------------------------------------------------------
--
-- unit name:     Testbench for converting signed to sign-magnitude number
--
-- description:
--
--   This file implements a self-checking testbench for vhdl file that
--   implements convertion of signed 8-bit number in form of
--   two's complement to form of signed-magnitude.
--
-----------------------------------------------------------------------------
-- Copyright (c) 2023 Faculty of Electrical Engineering
-----------------------------------------------------------------------------
-- The MIT License
-----------------------------------------------------------------------------
-- Copyright 2023 Faculty of Electrical Engineering
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

entity signed_to_sign_magnitude_converter_tb is
end signed_to_sign_magnitude_converter_tb;

architecture arch of signed_to_sign_magnitude_converter_tb is
  component signed_to_sign_magnitude_converter
    port(
      SIGN_BIN_i : in  std_logic_vector (7 downto 0);
      SIGN_MAG_o : out std_logic_vector (7 downto 0)
   );
  end component;

  signal SIGN_BIN_i_test : std_logic_vector (7 downto 0);
  signal SIGN_MAG_o_test : std_logic_vector (7 downto 0);

begin
  uut : signed_to_sign_magnitude_converter
  port map(
    SIGN_BIN_i => SIGN_BIN_i_test,
    SIGN_MAG_o => SIGN_MAG_o_test
  );

  testbench : process
  begin
    -- First value 'negative' zero and report for this case
    SIGN_BIN_i_test <= "10000000";
    wait for 50 ns;
    assert (SIGN_MAG_o_test = "00000000")
    report "Error at " & integer'image(to_integer(signed(SIGN_BIN_i_test)))
    severity error;
    -- Additional report for success cases
    report "Test passed for SIGN_BIN = 0";
    wait for 50 ns;

    -- For loop for all values from -127 to 127
    for i in -127 to 127 loop
      -- Conversion of the current iteration value into std_logic_vector
      SIGN_BIN_i_test <= std_logic_vector(to_signed(i, 8));
      wait for 50 ns;
      if (i < 0) then
        -- Negative number: set the MSB (sign) to 1 and calculate the magnitude
        -- Assert checks the condition for errors
        assert (SIGN_MAG_o_test = '1' & std_logic_vector(not(signed(SIGN_BIN_i_test(6 downto 0))) + 1))
        report "Error at " & integer'image(to_integer(signed(SIGN_BIN_i_test)))
        severity error;
        -- Additional report for success cases
        report "Test passed for SIGN_BIN = " & integer'image(to_integer(signed(SIGN_BIN_i_test)));
      else
        -- Positive number: transfer value.
        -- Assert checks the condition for errors
        assert (SIGN_MAG_o_test = SIGN_BIN_i_test)
        report "Error at " & integer'image(to_integer(signed(SIGN_BIN_i_test)))
        severity error;
        -- Additional report for success cases
        report "Test passed for SIGN_BIN = " & integer'image(to_integer(signed(SIGN_BIN_i_test)));
      end if;
    end loop;
    wait for 50 ns;
    report "Test completed.";
    wait;
  end process;
end arch;
