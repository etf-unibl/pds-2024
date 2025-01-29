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
--! @param rst_i     Input reset signal
--! @param start_i   Start signal to begin division
--! @param a_i       8-bit dividend input
--! @param b_i       8-bit divisor input
--! @param q_o       8-bit quotient output
--! @param r_o       8-bit remainder output
--! @param ready_o    Signal indicating division completion
entity sequential_divider is
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
end sequential_divider;

--! Architecture definition
--! @brief Sequential divider architecture implementing long division
--! @details This architecture uses state machines and data registers to implement
--! the division algorithm.
architecture arch of sequential_divider is
  --! State machine enumeration for division process
  --! @brief States of the divider machine
  type t_state is (idle, start, divide, done);

  --! @brief Internal signal declarations
  signal state_reg, state_next  : t_state;                      --! Current and next state
  signal rem_reg, rem_next      : unsigned(7 downto 0);         --! Remainder registers
  signal rem_t_reg, rem_t_next  : unsigned(8 downto 0);         --! Temporary remainder register
  signal div_reg, div_next      : unsigned(7 downto 0);         --! Dividend register
  signal q_reg, q_next          : unsigned(7 downto 0);         --! Quotient register
  signal b_reg, b_next          : unsigned(7 downto 0);         --! Divisor register
  signal bit_c_reg, bit_c_next  : natural range 0 to 8;         --! Iteration counter
  signal division_by_zero       : std_logic := '0';             --! Flag indicating division by zero
  signal ready_pulse            : std_logic := '0';             --! Flag indicating division by zero
  signal altb                   : std_logic := '0';             --! Flag indicating if dividend < divisor
begin

  --! @brief Process that updates the state register
  --! @details This process updates the state register on the rising clock edge or resets it when rst_i is high.
  state_reg_control_path : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg   <= idle;
    elsif rising_edge(clk_i) then
      state_reg  <= state_next;
    end if;
  end process state_reg_control_path;

  --! @brief Process that determines the next state
  --! @details This process evaluates the current state and inputs to decide the next state in the FSM.
  next_state_path : process(state_reg, start_i, bit_c_reg, b_i, a_i)
  begin
    altb <= '0';
    case state_reg is
      --! Initial idle state, waits for start signal to begin division
      when idle =>
        if start_i = '1' then
          state_next  <= start;  --! Transition to start state
        else
          state_next <= idle;
        end if;
      when start =>
        if unsigned(b_i) = 0 then
          state_next <= done;
        else
          if unsigned(a_i) < unsigned(b_i) then
            altb <= '1';
            state_next  <= done;
          else
            altb <= '0';
            state_next <=  divide;
          end if;
        end if;
      when divide =>
        if bit_c_reg = 0 then
          state_next <= done;
        else
          state_next <= divide;
        end if;
      when done =>
        state_next  <= idle;  --! Return to idle state for next division
    end case;
  end process next_state_path;

  --! @brief Process that updates data registers
  --! @details This process stores intermediate results and manages control signals.
  data_reg : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      rem_reg     <= (others => '0');
      rem_t_reg   <= (others => '0');
      div_reg     <= (others => '0');
      q_reg       <= (others => '0');
      b_reg       <= (others => '0');
      bit_c_reg   <=  0;
      ready_pulse <= '0';
    elsif rising_edge(clk_i) then
      rem_reg   <= rem_next;
      rem_t_reg <= rem_t_next;
      div_reg   <= div_next;
      q_reg     <= q_next;
      bit_c_reg <= bit_c_next;
      b_reg     <= b_next;
      if state_next = done then
        ready_pulse <= '1';
      else
        ready_pulse <= '0';
      end if;
      if state_next = start and unsigned(b_i) = 0 then
        division_by_zero <= '1';
      else
        division_by_zero <= '0';
      end if;
    end if;
  end process data_reg;

  ready_o <= ready_pulse;

  --! @brief Process that updates the data path and performs division
  --! @details This process executes the division algorithm, updates registers, and manages computation steps.
  data_path : process(state_reg, div_reg, q_reg, rem_reg, bit_c_reg, a_i, b_i, b_reg, rem_t_reg, rem_next, altb, division_by_zero)
  begin
    --! Default assignments to avoid latch inference
    rem_next   <= rem_reg;
    rem_t_next <= rem_t_reg;
    div_next   <= div_reg;
    q_next     <= q_reg;
    b_next     <= b_reg;
    bit_c_next <= bit_c_reg;
    case state_reg is
      when idle   =>
      when start  =>
        --! Initialize registers and start division process
        if division_by_zero = '1' then
          rem_next    <= (others => '1');
          q_next      <= (others => '1');
        else
          if altb = '1' then
            rem_next    <= unsigned(a_i);   --! Set remainder to a_i
            q_next      <= (others => '0'); --! Set quotient to 0
          else
            div_next    <= unsigned(a_i);   --! Set dividend to a_i
            b_next      <= unsigned(b_i);   --! Set divisor to b_i
            rem_next    <= (others => '0'); --! Set remainder
            rem_t_next  <= (others => '0'); --! Set temporary remainder
            q_next      <= (others => '0'); --! Set quotient
            bit_c_next  <= 8;               --! Set counter for 8-bit division
          end if;
        end if;
      when divide =>
        --! Perform long division
        rem_t_next    <= unsigned(rem_next(7 downto 0) & div_reg(7));
        if rem_t_reg(7 downto 0)  >= b_reg then
          rem_next <= rem_t_reg(7 downto 0) - b_reg;
          q_next   <= q_reg(6 downto 0) & '1';
        else
          rem_next <= rem_t_reg(7 downto 0);
          q_next   <= q_reg(6 downto 0) & '0';
        end if;
        div_next    <= div_reg(6 downto 0) & '0'; --! Shift dividend
        --! Decrement counter
        if bit_c_reg > 0 then
          bit_c_next <= bit_c_reg - 1;
        else
          bit_c_next <= 0;
        end if;
      when done =>
        if division_by_zero = '1' then
          rem_next    <= (others => '1');
          q_next      <= (others => '1');
        end if;
    end case;
  end process data_path;

  --! @brief Output assignments
  --! @details Assigns final values to quotient and remainder outputs in done state
  q_o <= std_logic_vector(q_reg) when ready_o = '1' else
         (others => '0'); --! Default when ready_o = '0'
  r_o <= std_logic_vector(rem_reg) when ready_o = '1' else
         (others => '0'); --! Default when ready_o = '0'

end arch;
