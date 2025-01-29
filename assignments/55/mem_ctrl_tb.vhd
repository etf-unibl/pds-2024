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

  --! @brief Number of clock cycles for the simulation.
  constant c_NUM_OF_CLOCKS : integer := 1000;

  --! @brief Simulation loop counter.
  signal i : integer := 0;

  --! @brief Input and output signals for the DUT.
  signal clk_i_test, rst_i_test, mem_i_test, rw_i_test, burst_i_test : std_logic;
  signal oe_o_test, we_o_test, we_me_o_test                          : std_logic;

  --! @brief File handles for input and output data files.
  file input_buf  : text;  --! Input data file
  file output_buf : text;  --! Output data file

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

  --! @brief Reset signal initialization.
  rst_i_test <= '0';
  --! @brief Generate clock signal for the DUT.
  clk_process : process
  begin
    clk_i_test <= '0';
    wait for c_CLOCK / 2;
    clk_i_test <= '1';
    wait for c_CLOCK / 2;
    if i = c_NUM_OF_CLOCKS then
      file_close(output_buf);
      file_close(input_buf);
      wait;
    else
      i <= i + 1;
    end if;
  end process clk_process;

  --! @brief File-based stimulus generator and output verification process.
  testbench : process
    variable read_col_from_input_buf : line;   --! Line read from input file
    variable write_col_to_output_buf : line;   --! Line written to output file
    variable val_mem_i : std_logic;            --! Input: Memory control signal
    variable val_rw_i  : std_logic;            --! Input: Read/Write control
    variable val_burst_i : std_logic;          --! Input: Burst control
    variable val_oe_o : std_logic;             --! Expected Output Enable
    variable val_we_o : std_logic;             --! Expected Write Enable
    variable val_we_me_o : std_logic;          --! Expected Memory Write Enable
    variable val_comma : character;            --! Comma delimiter
    variable good_num : boolean;               --! Validity flag for parsed data

  begin
    -- Reset
    rst_i_test <= '1';
    wait for c_CLOCK;
    rst_i_test <= '0';

    --! Open input and output files.
    file_open(input_buf, "..\..\data_files\mem_ctrl_input.csv", read_mode);
    file_open(output_buf, "..\..\data_files\mem_ctrl_output.csv", write_mode);

    --! Write header to the output file.
    write(write_col_to_output_buf, string'
    ("#mem_i_test,rw_i_test,burst_i_test,oe_actual,we_actual,we_me_actual,oe_o_test,we_o_test,we_me_o_test,result"));
    writeline(output_buf, write_col_to_output_buf);

    --! Loop through input file lines.
    while not endfile(input_buf) loop
      readline(input_buf, read_col_from_input_buf);
      read(read_col_from_input_buf, val_mem_i, good_num);
      next when not good_num; --! Skip invalid lines
      read(read_col_from_input_buf, val_comma);
      read(read_col_from_input_buf, val_rw_i, good_num);
      assert good_num report "Invalid value for rw_i_test";
      read(read_col_from_input_buf, val_comma);
      read(read_col_from_input_buf, val_burst_i, good_num);
      assert good_num report "Invalid value for burst_i_test";
      read(read_col_from_input_buf, val_comma);
      read(read_col_from_input_buf, val_oe_o, good_num);
      assert good_num report "Invalid value for oe_actual";
      read(read_col_from_input_buf, val_comma);
      read(read_col_from_input_buf, val_we_o, good_num);
      assert good_num report "Invalid value for we_actual";
      read(read_col_from_input_buf, val_comma);
      read(read_col_from_input_buf, val_we_me_o, good_num);
      assert good_num report "Invalid value for we_me_actual";

      --! Drive signals for DUT.
      mem_i_test <= val_mem_i;
      rw_i_test <= val_rw_i;
      burst_i_test <= val_burst_i;
      wait for c_CLOCK;

      --! Write results to output file.
      write(write_col_to_output_buf, mem_i_test);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, rw_i_test);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, burst_i_test);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, val_oe_o);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, val_we_o);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, val_we_me_o);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, oe_o_test);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, we_o_test);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, we_me_o_test);

      --! Check for mismatches and log results.
      if val_oe_o /= oe_o_test or val_we_o /= we_o_test or val_we_me_o /= we_me_o_test then
        write(write_col_to_output_buf, string'(",Error"));
      else
        write(write_col_to_output_buf, string'(",OK"));
      end if;

      writeline(output_buf, write_col_to_output_buf);
    end loop;
    --! Close input and output files.
    -- ! Close input and output files.
    file_close(input_buf);
    file_close(output_buf);
    report "All tests completed";
    wait;
  end process testbench;

end arch;
