library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity period_counter_tb is
end entity;

architecture sim of period_counter_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  component period_counter is
    port (
      clk_i    : in  std_logic;
      rst_i    : in  std_logic;
      signal_i : in  std_logic;
      period_o : out std_logic_vector(9 downto 0)
    );
  end component;

  -- Testbench signals
  signal clk_i    : std_logic := '0';
  signal rst_i    : std_logic := '0';
  signal signal_i : std_logic := '0';
  signal period_o : std_logic_vector(9 downto 0);

  constant CLK_PERIOD : time := 10 ns;  -- Clock period for simulation

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: period_counter
    port map (
      clk_i    => clk_i,
      rst_i    => rst_i,
      signal_i => signal_i,
      period_o => period_o
    );

  -- Clock generation
  clk_process: process
  begin
    while true loop
      clk_i <= '0';
      wait for CLK_PERIOD / 2;
      clk_i <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  -- Testbench stimulus process
  stimulus_process: process
    variable cycle_count : integer := 0;
    variable measured_period : integer := 0;
  begin
    -- Reset the UUT
    rst_i <= '1';
    wait for 2 * CLK_PERIOD;
    rst_i <= '0';
    wait for CLK_PERIOD;

    -- Iterate through all possible periods (1 to 1023 cycles)
    for i in 1 to 1023 loop
      -- Generate signal with the current period (i cycles)
      signal_i <= '1';
      wait for i * CLK_PERIOD;
      signal_i <= '0';
      wait for i * CLK_PERIOD;

      -- Allow some time for the period_o to stabilize
      wait for 2 * CLK_PERIOD;

      -- Check the output
      measured_period := to_integer(unsigned(period_o));
      assert measured_period = i report "Mismatch: Expected " & integer'image(i) & ", Got " & integer'image(measured_period) severity error;
    end loop;

    -- Test complete
    wait;
  end process;

end architecture;
