-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024
-----------------------------------------------------------------------------
--
-- unit name:     Sequential multiplier
--
-- description:
--
-- This file implements a sequential multiplier with repeated adding,
-- enabling back-to-back multiplication.
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
-- ! @brief ovaj entitet implementira sekvencijonalni mnozac koriscenjem masina sa konacnim
-- ! brojem stanja
entity sequential_multiplier is
  port (
    clk_i   : in  std_logic;  -- ! @param ulazni clock signal
    rst_i   : in  std_logic;  -- ! @param ashroni reset
    start_i : in  std_logic;  -- ! @param ulazni start signal
    a_i     : in  std_logic_vector(7 downto 0);  -- ! @param ulazni vektor a
    b_i     : in  std_logic_vector(7 downto 0);  -- ! @param ulazni vektor b
    c_o     : out std_logic_vector(15 downto 0);  -- ! @param rezultat mnozenja
    ready_o : out std_logic  -- ! @param spremnost da se prihvati ulaz
  );
end sequential_multiplier;
-- ! @brief arhitektura sekvencijalnog mnozaca realizovanog preko RT metodologije,
-- ! struktura se sastoji od data path i control path,
-- ! data path cini skup registara u kojem se nalaze promenljive ulazne i izlazne
-- ! control path opisujemo state register, next-state logic i output logic
architecture arch of sequential_multiplier is
  constant c_WIDTH : integer := 8;
  type t_state is (idle, ab0, load, op);
  signal state_reg, state_next : t_state;
  signal a_is_0, b_is_0, count_0 : std_logic;
  signal a_reg, a_next : unsigned(c_WIDTH-1 downto 0);
  signal n_reg, n_next : unsigned(c_WIDTH-1 downto 0);
  signal c_reg, c_next : unsigned(2*c_WIDTH-1 downto 0);
  signal adder_out : unsigned(2*c_WIDTH-1 downto 0);
  signal sub_out : unsigned(c_WIDTH-1 downto 0);
begin
  -- ! @brief control path: state register
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process;
  -- ! @brief control path: next state / output logic
  process(state_reg, start_i, a_is_0, b_is_0, count_0)
  begin
    case state_reg is
      when idle =>
        if start_i = '1' then
          if a_is_0 = '1' or b_is_0 = '1' then
            state_next <= ab0;
          else
            state_next <= load;
          end if;
        else
          state_next <= idle;
        end if;
      when ab0 =>
        state_next <= idle;
      when load =>
        state_next <= op;
      when op =>
        if count_0 = '1' then
          if start_i = '1' then
            if a_is_0 = '1' or b_is_0 = '1' then
              state_next <= ab0;
            else
              state_next <= load;
            end if;
          else
            state_next <= idle;
          end if;
        else
          state_next <= op;
        end if;
    end case;
  end process;
  -- ! @brief control path: output logic
  ready_o <= '1' when state_reg = idle else
             '1' when state_reg = op and start_i = '1' and count_0 = '1' else
             '0';
  -- ! @brief data path: data register
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      a_reg <= (others => '0');
      n_reg <= (others => '0');
      c_reg <= (others => '0');
    elsif rising_edge(clk_i) then
      a_reg <= a_next;
      n_reg <= n_next;
      c_reg <= c_next;
    end if;
  end process;
  -- ! @brief data path: routing multiplexer
  process(state_reg, a_reg, n_reg, c_reg, a_i, b_i, adder_out, sub_out)
  begin
    case state_reg is
      when idle =>
        a_next <= a_reg;
        n_next <= n_reg;
        c_next <= c_reg;
      when ab0 =>
        a_next <= unsigned(a_i);
        n_next <= unsigned(b_i);
        c_next <= (others => '0');
      when load =>
        a_next <= unsigned(a_i);
        n_next <= unsigned(b_i);
        c_next <= (others => '0');
      when op =>
        a_next <= a_reg;
        n_next <= sub_out;
        c_next <= adder_out;
    end case;
  end process;
  -- ! @brief data path: function units
  adder_out <= "00000000" & a_reg + c_reg;
  sub_out <= n_reg - 1;
  -- ! @brief data path: status
  a_is_0 <= '1' when a_i = "00000000" else '0';
  b_is_0 <= '1' when b_i = "00000000" else '0';
  count_0 <= '1' when n_next = "00000000" else '0';
  -- ! @brief data path: output
  c_o <= std_logic_vector(c_reg);
end arch;
