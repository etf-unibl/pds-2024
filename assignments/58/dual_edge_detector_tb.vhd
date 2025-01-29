-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024
-----------------------------------------------------------------------------
--
-- unit name:     TEST
--
-- description:
--
--   This file has the testing purpose for creating the first github pull request.
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


entity dual_edge_detector_tb is 
end dual_edge_detector_tb;

architecture tb_arch of dual_edge_detector_tb is 

		
	component dual_edge_detector is
	  port (
	  clk_i    : in  std_logic;
	  rst_i    : in  std_logic;
	  strobe_i : in  std_logic;
	  p_o      : out std_logic
	  );
	end component;
	
	signal clk_i : std_logic := '0';
	signal rst_i : std_logic := '0';
	signal strobe_i : std_logic := '0';
	signal p_o : std_logic ;
	
	constant T : time := 20 ns;
	constant clk_num : integer := 15;
	
	type test_vector is record 
		strobe_in : std_logic_vector(1 downto 0);
		expected_out : std_logic;
	end record;

	type test_vector_array is array(natural range <>) of test_vector;
	constant test_vectors : test_vector_array := (
	  ("00", '0'),  --ostaje na 0
	  ("01", '1'),  --prelazak sa 0 na 1
	  ("11", '0'),   -- ostaje na 1
	  ("10", '1')  -- prelazak sa 0 na 1
	);

	signal i : integer := 0;

begin

	uut: dual_edge_detector 
		port map(
			clk_i => clk_i,
         rst_i  => rst_i,
         strobe_i => strobe_i,
         p_o  => p_o
		
		);
		
	rst_i <= '1', '0' after T/2;

	 process
   begin
     clk_i <= '0';
     wait for T/2;
     clk_i <= '1';
     wait for T/2;
	  if(i = clk_num) then
	    wait;
	  else i <= i + 1;
	  end if;
   end process;	
	
	process
	begin 
	
		for i in test_vectors'range loop
		
			strobe_i <= test_vectors(i).strobe_in(1);
			wait for T;
			strobe_i <= test_vectors(i).strobe_in(0);
		   wait for T/8;
			report "Test " & integer'image(i) & " : "
				& "strobe_in = " & std_logic'image(test_vectors(i).strobe_in(1))
				&  std_logic'image(test_vectors(i).strobe_in(0))
				& ", expected_out = " & std_logic'image(test_vectors(i).expected_out)
				& ", actual_out = " & std_logic'image(p_o);
				
			assert (p_o = test_vectors(i).expected_out)
				report "Test failed for index " & integer'image(i)
				severity error;
			wait for T;
			
		end loop;
		
		wait;
	end process;			
	

end tb_arch;
