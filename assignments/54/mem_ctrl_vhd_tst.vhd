-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024.git
-----------------------------------------------------------------------------
--
-- unit name:     MEMORY CONTROLLER (FIRST METHOD) TESTBENCH
--
-- description:
--
--   This file implements a testbench code for memory controller.
--
-----------------------------------------------------------------------------
-- Copyright (c) 2024 Faculty of Electrical Engineering
-----------------------------------------------------------------------------
-- The MIT License
-----------------------------------------------------------------------------
-- Copyright 2024 Faculty of Electrical Engineering
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom
-- the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity mem_ctrl_vhd_tst is
end mem_ctrl_vhd_tst;
architecture arch of mem_ctrl_vhd_tst is
  --! @brief Signals
  signal burst_i : STD_LOGIC := '0';
  signal clk_i   : STD_LOGIC := '0';
  signal mem_i   : STD_LOGIC := '0';
  signal oe_o    : STD_LOGIC := '0';
  signal rst_i   : STD_LOGIC := '0';
  signal rw_i    : STD_LOGIC := '0';
  signal we_o    : STD_LOGIC;
  signal we_me_o : STD_LOGIC;
  component mem_ctrl
    port (
   burst_i : in STD_LOGIC;
   clk_i   : in STD_LOGIC;
   mem_i   : in STD_LOGIC;
   oe_o    : out STD_LOGIC;
   rst_i   : in STD_LOGIC;
   rw_i    : in STD_LOGIC;
   we_o    : out STD_LOGIC;
   we_me_o : out STD_LOGIC
   );
  end component;
  constant c_T : time := 20 ns;
  constant c_CLOCK_COUNT : integer := 500;
  signal i : integer := 0;   --! loop variable
  file output_buf : text;
  type t_vector is record
      mem_i :  STD_LOGIC;
      rw_i :  STD_LOGIC;
      burst_i :  STD_LOGIC;
      rst_i :  STD_LOGIC;
   end record t_vector;
  type t_vector_array is array (natural range <>) of t_vector;
  constant c_test_vectors : t_vector_array := (
      ('1','0','0','0'), --! write
      ('1','1','0','0'), --! read
      ('1','1','1','0'), --! burst
      ('0','0','0','0'), --! idle
      ('1','1','1','1')  --! reset
   );
begin
  i1 : mem_ctrl
   port map (
   --! @brief Enumerate the connections between the ports and the signals
   burst_i => burst_i,
   clk_i   => clk_i,
   mem_i   => mem_i,
   oe_o    => oe_o,
   rst_i   => rst_i,
   rw_i    => rw_i,
   we_o    => we_o,
   we_me_o => we_me_o
   );
  clock_gen : process
  begin
    clk_i <= '0';
    wait for c_T/2;
    clk_i <= '1';
    wait for c_T/2;
    if i = c_CLOCK_COUNT then
      file_close(output_buf);
      wait;
    else
      i <= i + 1;
    end if;
  end process clock_gen;
  output : process(clk_i)
    variable write_col_to_output_buf : line;
    variable flag : boolean := true;
  begin
    if flag then
      file_open(output_buf, "C:\Users\Korisnik\Desktop\VHDL\Zadatak 4\data_files\mem_ctrl_data.csv", write_mode);
      write(write_col_to_output_buf, string'("we_o,we_me_o,oe_o,mem_i,rw_i,burst_i,rst_i"));
      writeline(output_buf, write_col_to_output_buf);
      flag := false;
    end if;
    if rising_edge(clk_i) then
      write(write_col_to_output_buf, we_o);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, we_me_o);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, oe_o);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, mem_i);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, rw_i);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, burst_i);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, rst_i);
      writeline(output_buf, write_col_to_output_buf);
    end if;
  end process output;
  stim_proc : process
    variable seed1 : positive;
    variable seed2 : positive;
    variable x : real;
    variable y : integer;
    variable help : std_logic_vector(3 downto 0);
  begin
    --! @brief Manually going through all possible states
    wait for 30 ns;
    mem_i <= c_test_vectors(0).mem_i;
    rw_i <= c_test_vectors(0).rw_i;
    burst_i <= c_test_vectors(0).burst_i;
    rst_i <= c_test_vectors(0).rst_i;
    wait for 40 ns;
    mem_i <= c_test_vectors(1).mem_i;
    rw_i <= c_test_vectors(1).rw_i;
    burst_i <= c_test_vectors(1).burst_i;
    rst_i <= c_test_vectors(1).rst_i;
    wait for 40 ns;
    mem_i <= c_test_vectors(2).mem_i;
    rw_i <= c_test_vectors(2).rw_i;
    burst_i <= c_test_vectors(2).burst_i;
    rst_i <= c_test_vectors(2).rst_i;
    wait for 100 ns;
    --! @brief Generate random states
    while i < c_CLOCK_COUNT loop
      uniform(seed1, seed2, x);
      y := integer(floor(x * 16.0));
      help := std_logic_vector(to_unsigned(y, help'length));
      rw_i <= help(0);
      burst_i <= help(1);
      mem_i <= help(2);
      rst_i <= help(3);
      wait for 40 ns;
    end loop;
    wait;
  end process stim_proc;
end arch;
