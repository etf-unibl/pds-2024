-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024
-----------------------------------------------------------------------------
--
-- unit name:     Dual-edge detector
--
-- description:
--
--   This file implements an dual-edge detector circuit using Mealy FSM.
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

-- ! @brief ovaj entitet implementira detekciju prelaza sa 0 na 1 i obrnuto koristeci Marlijevu masinu sa 2 stanja.
entity dual_edge_detector is
  port (
    clk_i    : in  std_logic;  -- ! @param ulazni clock signal
    rst_i    : in  std_logic;  -- ! @param reset signal
    strobe_i : in  std_logic;  -- ! @param ulazni signal za aktivaciju detekcije
    p_o      : out std_logic  -- ! @param izlazni signal za detekciju promjena
  );
end dual_edge_detector;

-- ! @brief implementacija arhitekture
architecture arch of dual_edge_detector is
  -- ! @brief tip stanje sa dva stanja zero i one
  type t_state is (zero, one);
  -- ! @brief pomocni signali koji su tipa t_state (trenutno i naredno stanje)
  signal current_state, next_state : t_state;
begin

  -- ! @brief state register
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      current_state <= zero;
    elsif rising_edge(clk_i) then
      current_state <= next_state;
    end if;
  end process;

  -- ! @brief next-state logic
  process(current_state, strobe_i)
  begin
    case current_state is
      when zero =>
        if strobe_i = '1' then
          next_state <= one; -- ! prelazak sa stanje zero na one
        else
          next_state <= zero;
        end if;
      when one =>
        if strobe_i = '0' then
          next_state <= zero; -- ! prelazak sa stanja one na zero
        else
          next_state <= one;
        end if;
    end case;
  end process;

  -- ! @brief output logic
  process(current_state, next_state)
  begin
    if current_state = zero and next_state = one then
      p_o <= '1'; -- ! detekcija prelaska sa 0 na 1
    elsif current_state = one and next_state = zero then
      p_o <= '1'; -- ! detekcija prelaska sa 1 na 0
    else
      p_o <= '0';
    end if;
  end process;

end arch;
