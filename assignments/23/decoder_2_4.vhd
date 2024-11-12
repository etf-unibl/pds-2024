library ieee;
use ieee.std_logic_1164.all;

entity decoder_2_4 is
    port (
        i_A : in std_logic_vector(1 downto 0);  
        i_E : in std_logic;                    
        o_Y : out std_logic_vector(3 downto 0) 
    );
end decoder_2_4;

architecture arch_decoder_2_4 of decoder_2_4 is
begin
    -- Using selective signal assignments for each possible combination of i_A when i_E is '1'
    with (i_E & i_A) select
        o_Y <= "0001" when "100",  -- i_E = '1' and i_A = "00"
               "0010" when "101",  -- i_E = '1' and i_A = "01"
               "0100" when "110",  -- i_E = '1' and i_A = "10"
               "1000" when "111",  -- i_E = '1' and i_A = "11"
               "0000" when others; -- Output "0000" if i_E = '0' or any unexpected values
end arch_decoder_2_4;