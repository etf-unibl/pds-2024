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


entity dual_edge_detector is
  port (
  clk_i    : in  std_logic;
  rst_i    : in  std_logic;
  strobe_i : in  std_logic;
  p_o      : out std_logic
);
end dual_edge_detector;


architecture dual_edge_detector_arch of dual_edge_detector is
  type state_type is (zero, one);
  signal current_state, next_state : state_type;

begin 

  -- state register
  process(clk_i, rst_i)
  begin
		if(rst_i = '1') then
			current_state <= zero;
		elsif (rising_edge(clk_i))then
	      current_state <= next_state;	
		end if;	
  end process;
  
  -- next-state logic
  process(current_state, strobe_i)
  begin
    
    case current_state is 
      when zero => 
			if strobe_i = '1' then 
				next_state <= one;			--prelazak sa 0 na 1
			else 
				next_state <= zero;
			end if;
			
		when one => 
			if strobe_i = '0' then  
				next_state <= zero;    -- prelazak sa 1 na 0
			else 
				next_state <= one;
			end if;
	 end case;
  end process;


  -- Logika izlaza
  process(current_state, next_state)
  begin
    if current_state = zero and next_state = one then
      p_o <= '1';                                        -- detekcija prelaska sa 0 na 1
    elsif current_state = one and next_state = zero then
      p_o <= '1';		-- detekcija prelaska sa 1 na 
    else 
		p_o <= '0';
    end if;
  end process;

end dual_edge_detector_arch;
