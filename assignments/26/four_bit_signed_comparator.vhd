library ieee;
use ieee.std_logic_1164.all;

entity four_bit_signed_comparator is
    port (i_A : in std_logic_vector(3 downto 0);
          i_B : in std_logic_vector(3 downto 0);
          o_AGTB : out std_logic);
end four_bit_signed_comparator;



architecture beh_arch of four_bit_signed_comparator is


begin

    -- Using a conditional operator for bitwise comparison (conditional architecture) 
	 
    o_AGTB <= '0' when (i_A(3) = '1' and i_B(3) = '0') else  -- i_A is negative, and i_B is positive
              '1' when (i_A(3) = '0' and i_B(3) = '1') else  -- i_B is negative, and i_A is positive
              '1' when (i_A(2) = '1' and i_B(2) = '0') else  -- Comparison of the second most significant bit
				  '0' when (i_A(2) = '0' and i_B(2) = '1') else
              '1' when (i_A(1) = '1' and i_B(1) = '0') else  -- Comparison of the third bit
				  '0' when (i_A(1) = '0' and i_B(1) = '1') else
              '1' when (i_A(0) = '1' and i_B(0) = '0') else  -- Comparison of the least significant bit
              '0';

end beh_arch;
