-- Autor : Jelena Radakovoć

LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity full_subtractor is
    port ( A : in std_logic;
			  B : in std_logic;
           C_in : in std_logic;
           D : out std_logic;
           C_out : out std_logic);
end full_subtractor;

architecture arch_full_subtractor of full_subtractor is

begin

	D <= A xor B xor C_in;
	C_out <= ((not A) and (C_in or B)) or (B and C_in);

end arch_full_subtractor;