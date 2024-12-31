-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024/
-----------------------------------------------------------------------------
--
-- unit name:     period_counter
--
-- description:
--
--   This file implements the logic of a Period counter.
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
--! @file period_counter.vhd
--! @brief Period counter code functionality.
-----------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
--! Use numeric utilities for arithmetic operations on `unsigned` and `signed` types
use ieee.numeric_std.all;

--! @brief Entity declaration for the period counter
--! @details
--! The entity defines the input clock (`clk_i`), input signal (`signal_i`), reset (`rst_i`)
--! and  10 bit output (`period_o`) given in milliseconds.
entity period_counter is
  port (
    clk_i    : in  std_logic;               --! Clock input signal
    rst_i    : in  std_logic;               --! Reset input signal (active high)
    signal_i : in  std_logic;               --! Input signal for period measurement
    period_o : out std_logic_vector(9 downto 0) --! Output signal representing the measured period
  );
end period_counter;

--! @brief Architecture implementation of the period counter
--! @details
--! Implements a state machine to measure the period between two rising edges of the input signal.
architecture arch of period_counter is
  --! @brief t_state_type State type for the state machine
  --! @details
  --! State type for the state machine with states : `IDLE`, `FIRST_EDGE`, and `SECOND_EDGE`.
  type t_state_type is (IDLE, FIRST_EDGE, SECOND_EDGE);

  --! Current state of the state machine
  signal current_state : t_state_type := IDLE;

  --! Counter for clock cycles between rising edges
  signal counter       : unsigned(19 downto 0) := (others => '0');

  --! Output period value (10-bit scaled from counter)
  signal period        : unsigned(9 downto 0) := (others => '0');

  --! Synchronized version of the input signal
  signal signal_sync   : std_logic := '0';

  --! Previous value of the synchronized input signal
  signal signal_prev   : std_logic := '0';

  --! Rising edge detection signal
  signal rising_edge_d : std_logic := '0';

begin

  --! @brief Process to synchronize the input signal with the clock domain
  --! @details
  --! Captures the input signal and its previous state for edge detection.
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      signal_prev <= signal_sync;
      signal_sync <= signal_i;
    end if;
  end process;

  --! @brief Rising edge detection logic
  --! @details
  --! Sets `rising_edge_d` when a rising edge is detected on the synchronized signal.
  rising_edge_d <= '1' when signal_sync = '1' and signal_prev = '0' else '0';

  --! @brief State machine process
  --! @details
  --! Implements the logic for measuring the period between two rising edges of the input signal.
  --! Here we are using a clock with a predetermined 1MHz frequency (or 1000ns period) and scaling the output counter to period appropriately.
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        --! Reset all states and signals.
        current_state <= IDLE;
        counter <= (others => '0');
        period <= (others => '0');
      else
        case current_state is
          when IDLE =>
            --! Reset counter/period and switch to waiting for first rising edge.
            counter <= (others => '0');
            period <= (others => '0');
            current_state <= FIRST_EDGE;

          when FIRST_EDGE =>
            --! Wait for the first rising edge to start counting.
            if rising_edge_d = '1' then
              counter <= (others => '0');
              period <= (others => '0');
              current_state <= SECOND_EDGE;
            end if;

          when SECOND_EDGE =>
            --! Measure the period and wait for the second rising edge.
            if rising_edge_d = '1' then
              period <= counter(19 downto 10); -- Convert counter to 10-bit period by shifting the counter 10 bits to the right.
              current_state <= FIRST_EDGE;
            else
              counter <= counter + 1; -- Increment counter until second rising edge.
            end if;

          when others =>
            --! Default case: return to IDLE state.
            current_state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  --! @brief Assign the measured period to the output port.
  period_o <= std_logic_vector(period);

end arch;
