-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/pds-2023/
-----------------------------------------------------------------------------

-- unit name:     Testbench for memory controller
--
-- description:
--
--   This file implements a self-checking testbench for vhdl file that
--   implements conversion of signed 8-bit number in form of
--   two's complement to form of signed-magnitude.
--
-----------------------------------------------------------------------------

-- Copyright (c) 2023 Faculty of Electrical Engineering
-----------------------------------------------------------------------------

-- The MIT License
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

--! @brief Testbench entity for the memory controller.
entity mem_ctrl_tb is
end mem_ctrl_tb;

--! @brief Testbench architecture for verifying the memory controller.
architecture arch of mem_ctrl_tb is

  --! @brief Component declaration for memory controller (DUT).
  component mem_ctrl
    port(
      clk_i   : in  std_logic;   --! Clock input
      rst_i   : in  std_logic;   --! Reset input
      mem_i   : in  std_logic;   --! Memory input
      rw_i    : in  std_logic;   --! Read/Write control signal
      burst_i : in  std_logic;   --! Burst mode control signal
      oe_o    : out std_logic;   --! Output enable signal
      we_o    : out std_logic;   --! Write enable signal
      we_me_o : out std_logic    --! Memory write enable signal
    );
  end component;

  --! @brief Clock period constant for simulation.
  constant c_CLOCK : time := 20 ns;

  --! @brief Simulation loop counter.
  signal i : integer := 0;

  --! @brief Input and output signals for the DUT.
  signal clk_i_test   : std_logic := '0';
  signal rst_i_test   : std_logic := '0';
  signal mem_i_test   : std_logic := '0';
  signal rw_i_test    : std_logic := '0';
  signal burst_i_test : std_logic := '0';
  signal oe_o_test    : std_logic;
  signal we_o_test    : std_logic;
  signal we_me_o_test : std_logic;

  --! @brief File handles for output data files.
  file output_buf : text;  --! Output data file
  type test_vector is record
    mem_i   :  std_logic;
    rw_i    :  std_logic;
    burst_i :  std_logic;
    oe_o    :  std_logic;
    we_o    :  std_logic;
    we_me_o :  std_logic;
  end record;
  type test_vector_array is array (natural range <>) of test_vector;
  -- Test vectors
  constant test_vectors : test_vector_array := (
      ('0', 'X', 'X', '0', '0', '0'), -- Reset
      ('1', '1', '0', '1', '0', '0'), -- Idle -> Read1
      ('0', '0', '0', '0', '0', '0'), -- Read1 -> Idle
      ('1', '1', '1', '1', '0', '0'), -- Read1 -> Read2 (burst)
      ('1', '0', '0', '0', '1', '1'), -- Write state
      ('1', '1', '1', '1', '0', '0'), -- Burst Read progression
      ('0', '0', '0', '0', '0', '0')  -- Return to Idle
  );
begin

  --! @brief Instantiate the Device Under Test (DUT).
  uut : mem_ctrl
    port map(
      clk_i   => clk_i_test,
      rst_i   => rst_i_test,
      mem_i   => mem_i_test,
      rw_i    => rw_i_test,
      burst_i => burst_i_test,
      oe_o    => oe_o_test,
      we_o    => we_o_test,
      we_me_o => we_me_o_test
    );
--  --! @brief Reset signal initialization.
--  rst_i_test <= '0';
  --! @brief Generate clock signal for the DUT.
  clk_process : process
  begin
    clk_i_test <= '0';
    wait for c_CLOCK / 2;
    clk_i_test <= '1';
    wait for c_CLOCK / 2;
  end process clk_process;

  --! @brief File-based stimulus generator and output verification process.
  testbench : process
  begin
    rst_i_test <= '1';
    wait for c_CLOCK;
    rst_i_test <= '0';

    for i in 0 to test_vectors'length-1 loop
      mem_i_test <= test_vectors(i).mem_i;
      rw_i_test <= test_vectors(i).rw_i;
      burst_i_test <= test_vectors(i).burst_i;
      wait until rising_edge(clk_i_test);
      wait for c_CLOCK/2;
      report "Test " & integer'image(i+1) & " passed. Outputs: " &  "oe=" & std_logic'image(oe_o_test) &
           ", we=" & std_logic'image(we_o_test) &  ", we_me=" & std_logic'image(we_me_o_test);

      assert (oe_o_test = test_vectors(i).oe_o and we_o_test = test_vectors(i).we_o and we_me_o_test = test_vectors(i).we_me_o)
      report "Test " & integer'image(i+1) & " failed. Got " & std_logic'image(oe_o_test) & ", " &
            std_logic'image(we_o_test) & ", " & std_logic'image(we_me_o_test) &
            "Expected: " & std_logic'image(test_vectors(i).oe_o) & "," & std_logic'image(test_vectors(i).we_o) & ", " &
            std_logic'image(test_vectors(i).we_me_o) severity error;
    end loop;
    report "Simulation finished successfully.";
    wait;
  end process testbench;

end arch;
