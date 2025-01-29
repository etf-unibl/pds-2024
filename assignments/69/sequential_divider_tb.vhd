-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024/
-----------------------------------------------------------------------------

-- unit name:     Testbench for sequential divider
--
-- description:
--
--   This file implements testbench for sequential divider using
--   long-division algorithm
--
-----------------------------------------------------------------------------

-- Copyright (c) 2024 Faculty of Electrical Engineering
-----------------------------------------------------------------------------

-- The MIT License
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Testbench entity for sequential divider
--! @details This entity does not have any ports, as it is self-contained.
entity sequential_divider_tb is
end entity sequential_divider_tb;

--! @brief Testbench architecture for sequential divider
--! @details This architecture instantiates the sequential divider and generates test signals
architecture arch of sequential_divider_tb is
  --! Signals to connect to the unit under test (UUT)
  signal clk_i   : std_logic := '0';
  signal rst_i : std_logic := '0';
  signal start_i : std_logic := '0';
  signal a_i     : std_logic_vector(7 downto 0) := (others => '0');
  signal b_i     : std_logic_vector(7 downto 0) := (others => '0');
  signal q_o     : std_logic_vector(7 downto 0);
  signal r_o     : std_logic_vector(7 downto 0);
  signal ready_o  : std_logic;

  --! Clock period constant
  constant c_CLK_PERIOD : time := 10 ns;

  component sequential_divider
    port(
      clk_i   : in  std_logic;                    --! Clock input
      rst_i   : in  std_logic;                    --! Reset input
      start_i : in  std_logic;                    --! Start signal
      a_i     : in  std_logic_vector(7 downto 0); --! Dividend input
      b_i     : in  std_logic_vector(7 downto 0); --! Divisor input
      q_o     : out std_logic_vector(7 downto 0); --! Quotient output
      r_o     : out std_logic_vector(7 downto 0); --! Remainder output
      ready_o : out std_logic                     --! Division ready signal
    );
  end component;

begin

 --! @brief Instantiate the unit under test (UUT)
  --! @details Connects the testbench signals to the sequential divider entity.
  uut : sequential_divider
    port map (
      clk_i   => clk_i,
      rst_i   => rst_i,
      start_i => start_i,
      a_i     => a_i,
      b_i     => b_i,
      q_o     => q_o,
      r_o     => r_o,
      ready_o => ready_o
    );

  --! @brief Clock generation process
  --! @details Generates a periodic clock signal with a defined period.
  clk_process : process
  begin
    clk_i <= '0';
    wait for c_CLK_PERIOD / 2;
    clk_i <= '1';
    wait for c_CLK_PERIOD / 2;
  end process clk_process;

  --! @brief Stimulus process for testing all dividend and divisor combinations
  --! @details Loops through all possible 8-bit values for dividend and divisor,
  --! and checks if the division results match expected values.
  testbench : process
    variable i, j : integer := 0;
  begin
    --! Apply reset
    rst_i <= '1';
    wait for c_CLK_PERIOD * 2;
    rst_i <= '0';
    --! Loop through all possible values of a_i and b_i (0 to 255)
    for i in 0 to 255 loop
      for j in 0 to 255 loop
        --! Set inputs a_i and b_i
        a_i <= std_logic_vector(to_unsigned(i, 8));
        b_i <= std_logic_vector(to_unsigned(j, 8));

        wait for c_CLK_PERIOD*2;
        --! Start the division
        start_i <= '1';
        wait for c_CLK_PERIOD;
        start_i <= '0';

        --! Wait until ready_o is asserted
        wait until ready_o = '1';
        wait for c_CLK_PERIOD;

        --! Validate results
        if b_i = "00000000" then
          assert r_o = "11111111" and q_o = "11111111"
            report "Error: Division by zero detected!" severity error;
        else
          if q_o /= std_logic_vector(to_unsigned(i / j, 8)) or
             r_o /= std_logic_vector(to_unsigned(i mod j, 8)) then
            report "Mismatch detected: Expected Q=" & integer'image(i / j) &
                 " R=" & integer'image(i mod j) &
                 " Got Q=" & integer'image(to_integer(unsigned(q_o))) &
                 " R=" & integer'image(to_integer(unsigned(r_o)))
                 severity error;
          end if;
        end if;

        --! Wait until ready_o is deasserted before starting the next iteration
        wait until ready_o = '0';
      end loop;
    end loop;

    --! End of test
    assert false report "Testbench completed" severity note;
    wait;
  end process testbench;

end architecture arch;
