library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity one_bit_full_subtractor is
port ( 
		input: in std_logic_vector (2 downto 0); --x, y, borrow_in
		diff, borrow_out: out std_logic
		);
end one_bit_full_subtractor; 

architecture sel_arch of one_bit_full_subtractor is 
begin 
	with input select 
			diff <= '0' when "000" | "011" | "101" | "110",
					  '1' when others; 
	with input select
		  borrow_out <= '0' when "000" | "100" | "101" | "110",
							 '1' when others; 
end sel_arch; 