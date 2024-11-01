-- Autor : Jelena Radakovoć

LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity four_bit_full_subtractor is
    port (i_A : in std_logic_vector(3 downto 0);
          i_B : in std_logic_vector(3 downto 0);
          i_C : in std_logic;
          o_SUB : out std_logic_vector(3 downto 0);
          o_C : out std_logic);
end four_bit_full_subtractor;

architecture arch_four_bit_full_subtractor of four_bit_full_subtractor is
	
	signal c1, c2, c3 : std_logic;    -- signali za prenos pozajmica izmedju bita
	
	component full_subtractor
		port ( A : in std_logic;
				 B : in std_logic;
				 C_in : in std_logic;
				 D : out std_logic;
				 C_out : out std_logic);
	end component;
	
begin

-- Prvi bit:
	FS0 : full_subtractor port map (
		  A => i_A(0),
        B => i_B(0),
        C_in => i_C,
        D => o_SUB(0),
        C_out => c1
    );
	 
	 FS1 : full_subtractor port map (
		  A => i_A(1),
        B => i_B(1),
        C_in => c1,
        D => o_SUB(1),
        C_out => c2
    );
	 
	 FS2: full_subtractor port map (
        A => i_A(2),
        B => i_B(2),
        C_in => c2,
        D => o_SUB(2),
        C_out => c3
    );
	 
	 FS3: full_subtractor port map (
        A => i_A(3),
        B => i_B(3),
        C_in => c3,
        D => o_SUB(3),
        C_out => o_C
    );
	 
end arch_four_bit_full_subtractor;