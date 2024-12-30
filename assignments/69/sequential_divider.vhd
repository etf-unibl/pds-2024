-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/pds-2023/
-----------------------------------------------------------------------------

-- unit name:     Sequential divider
--
-- description:
--
--   This file implements a sequential divider using long-division algorithm
--
-----------------------------------------------------------------------------

-- Copyright (c) 2023 Faculty of Electrical Engineering
-----------------------------------------------------------------------------

-- The MIT License
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Entity declaration
--! @brief Sequential divider entity
--! @param clk_i     Input clock signal
--! @param reset_i   Input reset signal
--! @param start_i   Start signal to begin division
--! @param a_i       8-bit dividend input
--! @param b_i       8-bit divisor input
--! @param q_o       8-bit quotient output
--! @param r_o       8-bit remainder output
--! @param done_o    Signal indicating division completion
entity sequential_divider is
  port(
    clk_i   : in  std_logic;                    --! Clock input
    reset_i : in  std_logic;                    --! Reset input
    start_i : in  std_logic;                    --! Start signal
    a_i     : in  std_logic_vector(7 downto 0); --! Dividend input
    b_i     : in  std_logic_vector(7 downto 0); --! Divisor input
    q_o     : out std_logic_vector(7 downto 0); --! Quotient output
    r_o     : out std_logic_vector(7 downto 0); --! Remainder output
    done_o  : out std_logic                     --! Division done signal
  );
end sequential_divider;

--! Architecture definition
--! @brief Sequential divider architecture implementing long division
--! This architecture uses state machines and data registers to implement
--! the division algorithm.
architecture arch of sequential_divider is
  --! State machine enumeration for division process
  --! @brief States of the divider machine
  type t_state is (idle, divide, last, done);

  --! Internal signal declarations
  signal state_reg, state_next         : t_state;                      --! Current and next state
  signal remainder_reg, remainder_next : unsigned(7 downto 0);         --! Remainder registers
  signal bd_reg, bd_next               : std_logic_vector(7 downto 0); --! Dividend register
  signal remainder_tmp                 : unsigned(7 downto 0);         --! Temporary remainder signal
  signal d_reg, d_next                 : unsigned(7 downto 0);         --! Divisor register
  signal n_reg, n_next                 : unsigned(3 downto 0);         --! Counter register
  signal q_bit                         : std_logic;                    --! Single bit quotient
begin

  --! Process to handle state and data register updates
  --! @brief Updates state and data registers on clock edge or reset
  state_n_data_reg : process(clk_i, reset_i)
  begin
    if reset_i = '1' then
      state_reg     <= idle;
      remainder_reg <= (others => '0');
      bd_reg        <= (others => '0');
      d_reg         <= (others => '0');
      n_reg         <= (others => '0');
    elsif rising_edge(clk_i) then
      state_reg     <= state_next;
      remainder_reg <= remainder_next;
      bd_reg        <= bd_next;
      d_reg         <= d_next;
      n_reg         <= n_next;
    end if;
  end process state_n_data_reg;

  --! Process to compute the next state and perform data operations
  --! @brief Determines the next state and updates the data path
  next_state_n_data_path : process(state_reg, n_reg, remainder_reg, bd_reg, d_reg, start_i, a_i, b_i, q_bit, remainder_tmp, n_next)
  begin
    done_o         <= '0'; --! Default done signal value
    state_next     <= state_reg;
    remainder_next <= remainder_reg;
    bd_next        <= bd_reg;
    d_next         <= d_reg;
    n_next         <= n_reg;

    case state_reg is
      --! Initial idle state, waits for start signal to begin division
      when idle =>
        if b_i = std_logic_vector(to_unsigned(0, 8)) then
          --! Handle division by zero: set NaN for quotient and remainder
          bd_next        <= (7 downto 0 => '1');  --! NaN for quotient
          remainder_next <= (others => '1');      --! NaN for remainder
          done_o         <= '1';                  --! Set done signal
          state_next     <= done;                 --! Transition to done state
        else
          if start_i = '1' then
            --! Initialize registers and start division process
            remainder_next <= (others => '0');
            bd_next    <= a_i;               --! Set dividend
            d_next     <= unsigned(b_i);     --! Set divisor
            n_next     <= to_unsigned(9, 4); --! Set index counter
            state_next <= divide;            --! Transition to divide state
          end if;
        end if;

      --! Divide state where the long-division algorithm executes
      when divide =>
        bd_next        <= bd_reg(6 downto 0) & q_bit;            --! Update dividend with quotient bit
        remainder_next <= remainder_tmp(6 downto 0) & bd_reg(7); --! Update remainder
        n_next         <= n_reg-1;                               --! Decrease index
        if n_next = 1 then
          state_next <= last; --! Transition to last iteration state
        end if;
      
      --! Last iteration state before completing division
      when last =>
        bd_next        <= bd_reg(6 downto 0) & q_bit; --! Final update of quotient
        remainder_next <= remainder_tmp;              --! Final update of remainder
        state_next     <= done;                       --! Transition to done state

      --! Done state indicating division is complete
      when done =>
        state_next <= idle; --! Return to idle state for next division
        done_o     <= '1';  --! Set done signal
    end case;
  end process next_state_n_data_path;

  --! Process to compare remainder and divisor, and compute quotient bit
  --! @brief Compares the remainder and divisor, updates quotient bit and remainder
  comp_and_sub : process(remainder_reg, d_reg)
  begin
    if remainder_reg >= d_reg then
      remainder_tmp <= remainder_reg - d_reg; --! Subtract divisor from remainder
      q_bit         <= '1';                   --! Set quotient bit
    else
      remainder_tmp <= remainder_reg; --! No change to remainder
      q_bit         <= '0';           --! Set quotient bit to 0
    end if;
  end process comp_and_sub;

  --! Output assignments
  --! @brief Assigns final values to quotient and remainder outputs
  q_o <= bd_reg;                          --! Output quotient
  r_o <= std_logic_vector(remainder_reg); --! Output remainder
end arch;
