library ieee;
use ieee.std_logic_1164.all;


entity four_bit_full_subtractor is
    port (i_A : in std_logic_vector(3 downto 0);
          i_B : in std_logic_vector(3 downto 0);
          i_C : in std_logic;
          o_SUB : out std_logic_vector(3 downto 0);
          o_C : out std_logic);
end four_bit_full_subtractor; 

architecture sub_arch of four_bit_full_subtractor is 

signal temp0 : std_logic_vector(0 to 4); 

component one_bit_full_subtractor
			 port ( input : in std_logic_vector(2 downto 0);
					  diff: out std_logic; 
					  borrow_out: out std_logic );
end component;
 
begin 
temp0(0) <= i_C; 
g1: 
	for i in 0 to 3 generate
		four_bit_full_subtractor: one_bit_full_subtractor port map ( input(2) => i_A(i), input(1) => i_B(i), input(0) => temp0(i), diff => o_SUB(i), borrow_out => temp0(i+1));
	end generate;  
o_C <= temp0(4); 
end sub_arch; 