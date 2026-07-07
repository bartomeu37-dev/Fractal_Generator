----------------------------------------------------------------------------------
-- Testbench para timing_generator
-- Verifica las señales de control horizontal y vertical
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Si tienes el paquete auxiliary_functions_pkg, descomenta:
library work;
 use work.auxiliary_functions_pkg.all;

entity timing_generator_tb is
-- Testbench vacío (no tiene puertos)
end timing_generator_tb;

architecture Behavioral of timing_generator_tb is
    constant h_pixels: natural := 2200;
    constant v_pixels: natural := 1125;
  -- Componente a testear
  component timing_generator
    generic (
      h_pixels       : natural := 2200;
      v_pixels       : natural := 1125;
      front_porch_v  : natural := 4;
      back_porch_v   : natural := 36;
      active_lines   : natural := 1080;
      v_sync         : natural := 5;
      front_porch_h  : natural := 88;
      back_porch_h   : natural := 148;
      active_columns : natural := 1920;
      h_sync         : natural := 44
    );
    port (
      PIXEL_CLK      : in std_logic;
      ARESET         : in std_logic;
      START_LINE     : out std_logic;
      END_LINE       : out std_logic;
      START_H_SYNC   : out std_logic;
      END_H_SYNC     : out std_logic;
      START_FRAME    : out std_logic;
      END_FRAME      : out std_logic;
      START_V_SYNC   : out std_logic;
      END_V_SYNC     : out std_logic;
      CURRENT_COLUMN : out std_logic_vector(calc_num_bits(h_pixels) - 1 downto 0); -- Para 2200: ceil(log2(2200)) = 12 bits
      CURRENT_LINE   : out std_logic_vector(calc_num_bits(v_pixels) - 1 downto 0)  -- Para 1125: ceil(log2(1125)) = 12 bits
    );
  end component;

  -- Señales de estímulo
  signal pixel_clk_tb      : std_logic := '0';
  signal areset_tb         : std_logic := '1'; -- Inicia en reset
  
  -- Señales de salida del DUT
  signal start_line_tb     : std_logic;
  signal end_line_tb       : std_logic;
  signal start_h_sync_tb   : std_logic;
  signal end_h_sync_tb     : std_logic;
  signal start_frame_tb    : std_logic;
  signal end_frame_tb      : std_logic;
  signal start_v_sync_tb   : std_logic;
  signal end_v_sync_tb     : std_logic;
  signal current_column_tb : std_logic_vector(calc_num_bits(h_pixels) - 1 downto 0);
  signal current_line_tb   : std_logic_vector(calc_num_bits(v_pixels) - 1 downto 0);
  
  -- Constantes para el reloj
  constant CLK_PERIOD : time := 6.73 ns; -- ~ MHz para 1080p
  
begin

  -- Instancia del diseño bajo prueba (DUT)
  dut : timing_generator
    generic map (
      h_pixels       => 2200,    -- Total de columnas por línea
      v_pixels       => 1125,    -- Total de líneas por frame
      front_porch_h  => 88,      -- Front porch horizontal
      back_porch_h   => 148,     -- Back porch horizontal
      active_columns => 1920,    -- Pixeles activos horizontales
      h_sync         => 44,      -- Duración del sincronismo horizontal
      front_porch_v  => 4,       -- Front porch vertical
      back_porch_v   => 36,      -- Back porch vertical
      active_lines   => 1080,    -- Líneas activas verticales
      v_sync         => 5        -- Duración del sincronismo vertical
    )
    port map (
      PIXEL_CLK      => pixel_clk_tb,
      ARESET         => areset_tb,
      START_LINE     => start_line_tb,
      END_LINE       => end_line_tb,
      START_H_SYNC   => start_h_sync_tb,
      END_H_SYNC     => end_h_sync_tb,
      START_FRAME    => start_frame_tb,
      END_FRAME      => end_frame_tb,
      START_V_SYNC   => start_v_sync_tb,
      END_V_SYNC     => end_v_sync_tb,
      CURRENT_COLUMN => current_column_tb,
      CURRENT_LINE   => current_line_tb
    );

  -- Generación del reloj
  clock_process : process
  begin
    while true loop
      pixel_clk_tb <= '0';
      wait for CLK_PERIOD / 2;
      pixel_clk_tb <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  -- Proceso principal de test
  test_process : process
  begin
    -- Inicialización con reset
    report "Iniciando testbench...";
    areset_tb <= '1';
    wait for CLK_PERIOD * 5;
    
    -- Liberar reset
    report "Liberando reset...";
    areset_tb <= '0';
    wait;
  end process;

end Behavioral;