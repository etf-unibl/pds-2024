

library ieee;
use ieee.std_logic_1164.all;

entity invertor is
	port
	(
		input	: in  std_logic;
		output	: out std_logic
	);
end invertor;

architecture invertor_arch of invertor is
begin
	
	output = not input;
	
end invertor_arch;