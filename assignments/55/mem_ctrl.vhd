-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/pds-2023/
-----------------------------------------------------------------------------

-- unit name:     Modified memory controller
--
-- description:
--
--   This file implements a modification of memory controller from example.
--   In this file, back-to-back mode is enabled, where controller does not
--   have to go into idle state every operation, it can initiate next
--   operation right after previous one.
--
-----------------------------------------------------------------------------

-- Copyright (c) 2023 Faculty of Electrical Engineering
-----------------------------------------------------------------------------

-- The MIT License
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- ! @brief Entity for the memory controller with back-to-back operation enabled.
entity mem_ctrl is
  port (
    clk_i   : in  std_logic;  -- ! Clock signal
    rst_i   : in  std_logic;  -- ! Reset signal (active high)
    mem_i   : in  std_logic;  -- ! Memory access request signal
    rw_i    : in  std_logic;  -- ! Read/Write control signal
    oe_o    : out std_logic;  -- ! Output enable signal
    we_o    : out std_logic;  -- ! Write enable signal
    we_me_o : out std_logic   -- ! Mealy-based write enable signal
  );
end mem_ctrl;

-- ! @brief Architecture implementing the memory controller logic.
architecture arch of mem_ctrl is

  -- ! @brief State machine type representing the memory controller states.
  type t_mc_sm_type is (idle, read, write);

  -- ! @brief Registers for current and next states of the state machine.
  signal state_reg, state_next : t_mc_sm_type;

begin

  -- ! @brief State register process for updating the current state on clock edge.
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process;

  -- ! @brief Next-state logic process implementing state transitions.
  process(state_reg, mem_i, rw_i)
  begin
    state_next <= state_reg;  -- ! Default: stay in the current state
    case state_reg is
      when idle =>
        if mem_i = '1' and rw_i = '1' then
          state_next <= read;
        elsif mem_i = '1' and rw_i = '0' then
          state_next <= write;
        else
          state_next <= idle;
        end if;
      when write =>
        if mem_i = '1' then
          if rw_i = '1' then
            state_next <= read;
          else
            state_next <= write;
          end if;
        else
          state_next <= idle;
        end if;
      when read =>
        if mem_i = '1' and rw_i = '0' then
          state_next <= write;
        elsif mem_i = '1' and rw_i = '1' then
          state_next <= read;
        else
          state_next <= idle;
        end if;
    end case;
  end process;

  -- ! @brief Moore output logic process generating outputs based on the current state.
  process(state_reg)
  begin
    -- Default values
    oe_o <= '0';
    we_o <= '0';

    case state_reg is
      when idle =>
        -- Outputs remain inactive
      when write =>
        we_o <= '1';
      when read =>
        oe_o <= '1';
    end case;
  end process;

  -- ! @brief Mealy output logic process generating `we_me_o` based on inputs and state.
  process(state_reg, mem_i, rw_i, rst_i)
  begin
    we_me_o <= '0';  -- ! Default value
    if rst_i = '1' then
      we_me_o <= '0';
    else
      case state_reg is
        when idle =>
          if (mem_i = '1') and (rw_i = '0') then
            we_me_o <= '1';
          end if;
        when write =>
          we_me_o <= '1';
        when read =>
          -- No write enable in read states
      end case;
    end if;
  end process;

end arch;
