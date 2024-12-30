-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024.git
-----------------------------------------------------------------------------
--
-- unit name:     LOADING ZERO COUNTER
--
-- description:
--
--   This file implements a leading zero counter circuit.
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
--! @file 
--! @brief Leading zero counter 
-----------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
--! Use numeric elements
use ieee.numeric_std.all;

--! @brief Entity declaration for leading_zero_counter.
--! @details Defines the ports for the module.

entity leading_zero_counter is
  port (
    clk_i   : in std_logic; --! Clock input
    rst_i   : in std_logic; --! Reset input (active high)
    start_i : in std_logic; --! Start signal to begin counting
    n_i     : in std_logic_vector(15 downto 0); --! 16-bit input vector
    ready_o : out std_logic; --! Indicates when the module is idle
    zeros_o : out std_logic_vector(4 downto 0)  --! 5-bit count
  );
end leading_zero_counter;

--! @brief Architecture definition of leading zero counter
--! @details This design is realised on RTL using FSMD approach
architecture arch of leading_zero_counter is

  --! @brief FSM states for the operation.
  type t_state is (idle, load, op);
  --! @brief Signals for the FSM states.
  signal state_reg, state_next : t_state;
  --! @brief Data register signals.
  signal n_reg, n_next : std_logic_vector(15 downto 0);
  signal zeros_reg, zeros_next : unsigned(4 downto 0);
  --! @brief Counter for the number of leading zeros.
  signal zeros_count : unsigned(4 downto 0);
  --! @brief Current bit index being checked in the input vector.
  signal index : natural range 15 downto 0;
  --! @brief Signal indicating whether a '1' bit has been found.
  signal bit_one : std_logic;

begin

  --! @brief FSM state register.
  --! @details Handles transitions between states based on clock and reset.
  process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process;

  --! @brief FSM next-state logic.
  --! @details Determines the next state based on the current state.
  process (state_reg, start_i, bit_one)
  begin
    case state_reg is
      when idle =>
        if start_i = '1' then
          state_next <= load;
        else
          state_next <= idle;
        end if;
      when load =>
        state_next <= op;
      when op =>
        if bit_one = '1' then
          state_next <= idle;
        else
          state_next <= op;
        end if;
    end case;
  end process;

  --! @brief Output ready signal logic.
  --! @details Indicates when the FSM is in the idle state.
  ready_o <= '1' when state_reg = idle else
             '0';

  --! @brief Data register update process.
  --! @details Updates the data and zero counters based on the current state.
  process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      n_reg <= (others => '1');
      zeros_reg <= (others => '0');
    elsif rising_edge(clk_i) then
      n_reg <= n_next;
      zeros_reg <= zeros_next;
    end if;
  end process;

  --! @brief Data path logic.
  --! @details Determines the next values for data and zero counters.
  process (state_reg, n_reg, zeros_reg, n_i, zeros_count)
  begin
    case state_reg is
      when idle =>
        n_next <= n_reg;
        zeros_next <= zeros_reg;
      when load =>
        n_next <= n_i;
        zeros_next <= (others => '0');
      when op =>
        n_next <= n_reg;
        zeros_next <= zeros_count;
    end case;
  end process;

  --! @brief Zero counter update logic.
  --! @details Increments the zero counter if the current bit is '0' and
  --!          the maximum count has not been reached.
  zeros_count <= zeros_reg + 1 when n_reg(index) = '0' and zeros_reg < 16
                 else
                 zeros_reg;

  --! @brief Bit check logic.
  --! @details Sets the bit_one signal if a '1' bit is found or the maximum
  --!          count is reached.
  bit_one <= '1' when n_reg(index) = '1' or zeros_reg = 16 else
             '0';
  index <= 15 - to_integer(zeros_reg) when zeros_reg < 16 else
           0;

  --! @brief Output conversion logic.
  --! @details Converts the zero counter to std_logic_vector for output.
  zeros_o <= std_logic_vector(zeros_reg);
end arch;
