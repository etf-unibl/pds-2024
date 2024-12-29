-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024/
-----------------------------------------------------------------------------
--
-- unit name:     fibonacci
--
-- description:
--
--   This file implements a Fibonacci sequence generator.
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

-------------------------------------------------------
--! @file fibonacci.vhd
--! @brief Fibonacci sequence generator.
-------------------------------------------------------

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Fibonacci sequence generator entity description
--! The `fibonacci` entity generates Fibonacci numbers up to the 63rd Fibonacci number.
--! The sequence is generated based on the input length `n_i`, which defines the n-th Fibonacci number.

--! @structure
--! The entity has the following ports:
--! `clk_i` is the clock input, used to synchronize the process.
--! `rst_i` is the reset input, used to initialize or clear the generator state.
--! `start_i` is a signal that indicates if the input data is ready.
--! `n_i` is a 6-bit input vector specifying the length of the Fibonacci sequence generator.
--! `r_o` is the output carrying the Fibonacci number once it has been computed.
--! `ready_o` is an output signal indicating whether the Fibonacci number is ready for use.

entity fibonacci is
  port (
      clk_i   : in  std_logic; --! Clock input signal
      rst_i   : in  std_logic; --! Reset input signal
      start_i : in  std_logic; --! Signal indicates if input data is valid or not
      n_i     : in  std_logic_vector(5 downto 0); --! Input data that represents the length of the Fibonacci sequence
      r_o     : out std_logic_vector(42 downto 0); --! Output data
      ready_o : out std_logic  --! Signal indicates if output data is ready
);
end fibonacci;

--! @brief Architecture definition of Fibonacci sequence generator
--! @details Architecture is implemented using FSM with three states : idle, load and op.
--! The Fibonacci number computation is controlled by the input `n_i`, which defines the length of the sequence
--! The system operates synchronously with the clock (`clk_i`),
--! and the result is available when the `ready_o` signal is asserted.

--! @signals
--! - `state_reg`: Holds the current state of the state machine (idle, load, or op).
--! - `state_next`: Next state of the state machine.
--! - `a_reg`: Current Fibonacci number register.
--! - `n_reg`: Current value of the `n_i` register.
--! - `r_reg`: Register holding the output Fibonacci number.
--! - `adder_out`: The result of adding two Fibonacci numbers.
--! - `sub_out`: The result of subtracting one from `n_reg` (used to track the Fibonacci index).
--! - `n_is_0`: Signal indicating if `n_i` is zero.
--! - `count_0`: Signal indicating if `n_i` has reached its final value.

architecture arch of fibonacci is
  constant c_WIDTH : integer := 43;
  type t_state_type is (idle, load, op);
  signal state_reg, state_next : t_state_type;
  signal n_is_0        : std_logic;
  signal count_0       : std_logic;
  signal a_reg, a_next : unsigned(c_WIDTH - 1 downto 0) := (others => '0');
  signal n_reg, n_next : unsigned(5 downto 0) := (others => '0');
  signal r_reg, r_next : unsigned(c_WIDTH - 1 downto 0) := (others => '0');
  signal adder_out : unsigned(c_WIDTH - 1 downto 0) := (others => '0');
  signal sub_out   : unsigned(5 downto 0) := (others => '0');

begin

-- control path : state register
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process;

--! @state_transitions
--! - The state transitions depend on the value of `start_i`, `n_is_0`, and `count_0`.
--! - From `idle` to `load` when `start_i` is asserted and `n_is_0` is not zero.
--! - From `load` to `op` once loading is completed.
--! - From `op` back to `idle` when `count_0` is asserted, indicating the sequence has finished.

   -- control path: next-state/output logic
  process(state_reg, start_i, count_0)
  begin
    case state_reg is
      when idle =>
        if start_i = '1' then
          if n_is_0 = '0' then
            state_next <= idle;
          else
            state_next <= load;
          end if;
        else
          state_next <= idle;
        end if;
      when load =>
        state_next <= op;
      when op =>
        if count_0 = '1' then
          state_next <= idle;
        else
          state_next <= op;
        end if;
    end case;
  end process;

   -- control path: output logic
  ready_o <= '1' when state_reg <= idle
        else '0';

   -- data_path: data register
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      a_reg <= (others => '0');
      n_reg <= (others => '0');
      r_reg <= (others => '0');
    elsif rising_edge(clk_i) then
      a_reg <= a_next;
      n_reg <= n_next;
      r_reg <= r_next;
    end if;
  end process;

   -- data path: routing multiplexer
  process(state_reg, a_reg, n_reg, r_reg,
            adder_out, sub_out)

  begin

    case state_reg is
      when idle =>
        a_next <= a_reg;
        n_next <= n_reg;
        r_next <= r_reg;
      when load =>
        a_next <= (others => '0');
        r_next <= (0 => '1', others => '0');
        n_next <= unsigned(n_i);
      when op =>
        a_next <= r_reg;
        n_next <= sub_out;
        r_next <= adder_out;
    end case;
  end process;

   -- data path : functional units
  adder_out <=  a_reg + r_reg;
  sub_out <= n_reg - 1;

   -- data path : status
  n_is_0 <= '1' when n_i = "000000" else '0';
  count_0 <= '1' when n_next = "000001" else '0';

   -- data path : output
  r_o <= std_logic_vector(r_reg);


end arch;
