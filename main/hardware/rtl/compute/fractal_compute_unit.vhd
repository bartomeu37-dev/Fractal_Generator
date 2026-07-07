----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/01/2026 03:32:40 PM
-- Design Name: 
-- Module Name: fractal_compute_unit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;
use work.auxiliary_functions_pkg.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fractal_compute_unit is
  generic (
    N_CORES   : natural             := 80; -- Valores por defecto
    RESX      : natural             := 960;
    RESY      : natural             := 540;
    DELTAREAL : signed(17 downto 0) := "000000000001000000";
    RMIN      : signed(17 downto 0) := "111000100000000000";
    DELTAIMG  : signed(17 downto 0) := "000000000001000000";
    IMIN      : signed(17 downto 0) := "111011110010000000"
  );
  port (
    clk         : in std_logic;
    RESET       : in std_logic;
    ITER        : out std_logic_vector(7 downto 0);
    C_REAL_IN   : in std_logic_vector(17 downto 0);
    C_IMG_IN    : in std_logic_vector(17 downto 0);
    MAX_ITER_IN : in std_logic_vector(7 downto 0);
    ADDR        : out std_logic_vector(18 downto 0);
    PUSH        : out std_logic);
end fractal_compute_unit;

architecture Behavioral of fractal_compute_unit is
  component fractal_core_io is
    generic (
      CORE_ID   : natural;
      RESX      : natural;
      RESY      : natural;
      DELTAREAL : signed(17 downto 0);
      RMIN      : signed(17 downto 0);
      DELTAIMG  : signed(17 downto 0);
      N_CORES   : natural;
      IMIN      : signed(17 downto 0)
    );
    port (
      clk         : in std_logic;
      RESET       : in std_logic;
      P_COLOR     : out std_logic_vector(7 downto 0);
      WEA         : out std_logic;
      C_REAL_IN   : in std_logic_vector(17 downto 0);
      C_IMG_IN    : in std_logic_vector(17 downto 0);
      MAX_ITER_IN : in std_logic_vector(7 downto 0);
      CONTINUE    : in std_logic
    );
  end component;

  -- Creamos un array que sirve como bus de datos
  type iter_array_t is array (0 to N_CORES - 1) of std_logic_vector(7 downto 0);

  signal cores_iter     : iter_array_t;
  signal cores_wea      : std_logic_vector(N_CORES - 1 downto 0);
  signal cores_continue : std_logic_vector(N_CORES - 1 downto 0);
  signal counter_cores  : UNSIGNED(calc_num_bits(N_CORES) - 1 downto 0);
  signal all_end        : std_logic;
  signal continue_cores : std_logic;

  signal addr_mem : UNSIGNED(18 downto 0);

  signal push_reg : std_logic;
  signal addr_reg : std_logic_vector(18 downto 0);
  signal iter_reg : std_logic_vector(7 downto 0);
begin

  gen_cores : for i in 0 to N_CORES - 1 generate
    ins_core : fractal_core_io
    generic map(
      CORE_ID   => i,
      RESX      => RESX,
      RESY      => RESY,
      DELTAREAL => DELTAREAL,
      RMIN      => RMIN,
      DELTAIMG  => DELTAIMG,
      N_CORES   => N_CORES,
      IMIN      => IMIN
    )
    port map
    (
      clk         => clk,
      RESET       => RESET,
      P_COLOR     => cores_iter(i),
      WEA         => cores_wea(i),
      C_REAL_IN   => C_REAL_IN,
      C_IMG_IN    => C_IMG_IN,
      MAX_ITER_IN => MAX_ITER_IN,
      CONTINUE    => cores_continue(i)
    );
  end generate gen_cores;

  -------------------------------------------------------
  -- AND
  -------------------------------------------------------

  all_and_end : process (cores_wea, continue_cores)
    variable and_tmp : std_logic;
  begin
    and_tmp := '1';
    for i in 0 to N_CORES - 1 loop
      and_tmp := and_tmp and cores_wea(i);
    end loop;
    all_end <= and_tmp and not(continue_cores);
  end process;

  -------------------------------------------------------
  -- CONTADOR Y REGISTRO DE SALIDAS
  -------------------------------------------------------
  counter : process (clk, RESET)
  begin
    if RESET = '1' then
      counter_cores  <= (others => '0');
      continue_cores <= '0';
      addr_mem       <= (others => '0');
      push_reg       <= '0';
      addr_reg       <= (others => '0');
      iter_reg       <= (others => '0');

    elsif rising_edge(clk) then
      continue_cores <= '0';
      push_reg       <= '0';

      if all_end = '1' then
        push_reg      <= '1';
        addr_reg      <= std_logic_vector(addr_mem);
        iter_reg      <= cores_iter(to_integer(counter_cores));
        counter_cores <= counter_cores + 1;
        addr_mem      <= addr_mem + 1;

        if counter_cores = N_CORES - 1 then
          counter_cores  <= (others => '0');
          continue_cores <= '1';
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------
  -- ASIGNACIONES
  -------------------------------------------------------
  PUSH           <= push_reg;
  ADDR           <= addr_reg;
  ITER           <= iter_reg;
  cores_continue <= (others => continue_cores);
end Behavioral;
