-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024/
-----------------------------------------------------------------------------
--
-- unit name:     manchester_decoder
--
-- description:
--
--   This file implements the logic of a Manchester code decoder.
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
--! @file manchester_decoder.vhd
--! @brief Manchester code decoder functionality.
-----------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! @brief Entity definition of the Manchester Decoder.
--! @details
--! The entity defines the input clock (`clk_i`), input data (`data_i`),
--! and outputs for decoded data (`data_o`) and validity of decoded data (`valid_o`).
entity manchester_decoder is
  port (
    clk_i   : in  std_logic; --! Input clock signal.
    data_i  : in  std_logic; --! Input data signal.
    data_o  : out std_logic; --! Decoded output data.
    valid_o : out std_logic  --! Validity signal for the decoded output.
  );
end manchester_decoder;

--! @brief Architecture definition of the Manchester Decoder.
--! @details
--! Implements the state machine and logic for decoding Manchester-encoded data.
architecture arch of manchester_decoder is
  --! @brief State type for the state machine.
  --! @details
  --! The decoder operates in three states: `SAME`, `INVERT`, and `IDLE`.
  type t_state_type is (SAME, INVERT, IDLE);

  --! Current and next state signals for the state machine.
  signal current_state, next_state : t_state_type := IDLE; -- Start in IDLE state.

  --! Register for the decoded output data.
  signal data_o_reg : std_logic := '0';

  --! Register for the validity signal.
  signal valid_o_reg : std_logic := '0';
begin
  --! @brief Process for state transitions on clock signal.
  --! @details
  --! Updates the `current_state` to the `next_state` on every clock cycle.
  process(clk_i)
  begin
    current_state <= next_state;
  end process;

  --! @brief Process for determining next state, output data, and validity.
  --! @details
  --! Implements the state machine logic based on the `current_state`.
  process(current_state)
  begin
    case current_state is
      when IDLE =>
        --! @details In the IDLE state, the output matches the input, and
        --! transitions to the SAME state.
        data_o_reg <= data_i;
        next_state <= SAME;
        valid_o_reg <= '1';

      when SAME =>
        --! @details In the SAME state, the output matches the input, and
        --! transitions to the INVERT state.
        data_o_reg <= data_i;
        next_state <= INVERT;
        valid_o_reg <= '1';

      when INVERT =>
        --! @details In the INVERT state, the output is the inverted input, and
        --! transitions back to the SAME state.
        data_o_reg <= not data_i;
        next_state <= SAME;
        valid_o_reg <= '1';

      when others =>
        --! @details Default case to handle undefined states. Resets outputs
        --! and transitions to the SAME state.
        data_o_reg <= '0';
        next_state <= SAME;
        valid_o_reg <= '0';
    end case;
  end process;

  --! @brief Assign decoded output and validity signals.
  data_o <= data_o_reg; --! @details Assign the registered data output to the port.
  valid_o <= valid_o_reg; --! @details Assign the registered validity signal to the port.
end arch;
