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
library ieee;
use ieee.std_logic_1164.all;

entity mem_ctrl is
  port (
  clk_i   : in  std_logic;
  rst_i   : in  std_logic;
  mem_i   : in  std_logic;
  rw_i    : in  std_logic;
  burst_i : in  std_logic;
  oe_o    : out std_logic;
  we_o    : out std_logic;
  we_me_o : out std_logic
);
end mem_ctrl;

architecture arch of mem_ctrl is
  type t_state is
        (idle, read1, read2, read3, read4, write);
  signal state_reg, state_next : t_state;
begin
  -- ! @brief State register
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process;
  -- ! @brief Next-state logic
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
        if burst_i = '1' then
          state_next <= read1;
        else
          state_next <= idle;
        end if;
      when others =>
        state_next <= idle;
    end case;
  end process;
  -- ! @brief Output logic process (Moore outputs)
  process(state_reg)
  begin
    we_o <= '0';  -- Default value
    oe_o <= '0';
    case state_reg is
      when idle =>
        null;
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
      when others =>
        null;
    end case;
  end process;
  -- ! @brief Mealy output logic process
  process(state_reg, mem_i, rw_i)
  begin
    we_me_o <= '0';  -- Default value
    case state_reg is
      when idle =>
        if (mem_i = '1') and (rw_i = '0') then
          we_me_o <= '1';
        end if;
      when write =>
        we_me_o <= '1';
      when others =>
        we_me_o <= '0';
    end case;
  end process;
end arch;
