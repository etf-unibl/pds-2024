-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024.git
-----------------------------------------------------------------------------
--
-- unit name:     MEMORY CONTROLLER (FIRST METHOD)
--
-- description:
--
--   This file implements a modified memory controller.
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
--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! @file mem_ctrl.vhd
--! @brief Memory controller with read, write, and burst functionality.

entity mem_ctrl is
  port (
  clk_i   : in  std_logic; --! Clock input
  rst_i   : in  std_logic; --! Reset input (active high)
  mem_i   : in  std_logic; --! Memory enable input
  rw_i    : in  std_logic; --! Read('1')/Write('0') control input
  burst_i : in  std_logic; --! Burst mode enable input
  oe_o    : out std_logic; --! Output enable signal
  we_o    : out std_logic; --! Write enable signal (Moore output)
  we_me_o : out std_logic  --! Write enable signal (Mealy output)
);
end mem_ctrl;

architecture arch of mem_ctrl is
  --! @brief Enumeration of FSM states
  type t_state is
        (idle, read1, read2, read3, read4, read5, write);
  --! @brief Signal for the next state
  signal state_reg, state_next : t_state;
begin
  --! @brief State register
  --! @details Handles state transitions based on clock and reset signals
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process;

  --! @brief Next-state logic
  process(state_reg, mem_i, rw_i, burst_i)
  begin
    case state_reg is
      when idle =>
        if mem_i = '1' then
          if rw_i = '1' then
            if burst_i = '1' then
              state_next <= read2;
            else
              state_next <= read1;
            end if;
          else
            state_next <= write;
          end if;
        else
          state_next <= idle;
        end if;
      when write =>
        state_next <= idle;
      when read1 =>
        state_next <= idle;
      when read2 =>
        state_next <= read3;
      when read3 =>
        state_next <= read4;
      when read4 =>
        state_next <= read5;
      when read5 =>
        state_next <= idle;
    end case;
  end process;

  --! @brief Output logic process (Moore outputs)
  --! @details Sets outputs based on the current state
  process(state_reg)
  begin
    we_o <= '0';  --! Default value
    oe_o <= '0';
    case state_reg is
      when idle =>
      when write =>
        we_o <= '1';
      when read1 =>
        oe_o <= '1';
      when read2 =>
        oe_o <= '1';
      when read3 =>
        oe_o <= '1';
      when read4 =>
        oe_o <= '1';
      when read5 =>
        oe_o <= '1';
    end case;
  end process;

  --! @brief Mealy output logic process
  --! @details Computes outputs based on current state and inputs
  process(state_reg, mem_i, rw_i)
  begin
    we_me_o <= '0';  --! Default value
    case state_reg is
      when idle =>
        if (mem_i = '1') and (rw_i = '0') then
          we_me_o <= '1';
        end if;
      when write =>
      when read1 =>
      when read2 =>
      when read3 =>
      when read4 =>
      when read5 =>
    end case;
  end process;
end arch;
