
library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-----------------------------------------------------------
-- PAQUETES
-----------------------------------------------------------
use work.auxiliary_functions_pkg.all;
-----------------------------------------------------------
-- ENTIDAD
-----------------------------------------------------------
entity vga_driver is
  generic (
    ADDRESS_PIXEL_WIDTH : natural := 17
  );
  port (
    ARESET           : in std_logic;
    CLK              : in std_logic;
    VGA_HS_O         : out std_logic;
    VGA_VS_O         : out std_logic;
    VGA_R            : out std_logic_vector (3 downto 0);
    VGA_B            : out std_logic_vector (3 downto 0);
    VGA_G            : out std_logic_vector (3 downto 0);
    PIXEL_IN         : in std_logic_vector (7 downto 0);
    START_V_SYNC_OUT : out std_logic;
    START            : in std_logic;
    ADDRESS_PIXEL    : out std_logic_vector(ADDRESS_PIXEL_WIDTH - 1 downto 0);
    PALLETE_SELECTOR : in std_logic_vector(1 downto 0)
  );
end entity vga_driver;

-----------------------------------------------------------
-- ARQUITECTURA
-----------------------------------------------------------

architecture BEHAVIORAL of vga_driver is

  -------------------------------------------------------
  -- DECLARACIÓN DE COMPONENTES
  -------------------------------------------------------

  --VGA TIMING GENERATOR---------------------------------
  component timing_generator is
    generic (
      h_pixels       : natural;
      v_pixels       : natural;
      front_porch_v  : natural;
      back_porch_v   : natural;
      active_lines   : natural;
      v_sync         : natural;
      front_porch_h  : natural;
      back_porch_h   : natural;
      active_columns : natural;
      h_sync         : natural
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
      CURRENT_COLUMN : out std_logic_vector(calc_num_bits(h_pixels) - 1 downto 0);
      CURRENT_LINE   : out std_logic_vector(calc_num_bits(v_pixels) - 1 downto 0)
    );
  end component;

  --CLUT---------------------------------
  component clut is
    port (
      clk         : in std_logic;
      pallete_sel : in std_logic_vector(1 downto 0);
      iter        : in std_logic_vector(7 downto 0);
      vga_rgb     : out std_logic_vector(11 downto 0)
    );
  end component;

  -------------------------------------------------------
  -- CONSTANTES
  -------------------------------------------------------
  constant h_pixels : natural := 2200;
  constant v_pixels : natural := 1125;

  -------------------------------------------------------
  -- TIPOS
  -------------------------------------------------------
  -------------------------------------------------------
  -- SEÑALES INTERNAS
  -------------------------------------------------------
  signal start_line_signal     : std_logic;
  signal end_line_signal       : std_logic;
  signal start_h_sync_signal   : std_logic;
  signal end_h_sync_signal     : std_logic;
  signal start_frame_signal    : std_logic;
  signal end_frame_signal      : std_logic;
  signal start_v_sync_signal   : std_logic;
  signal end_v_sync_signal     : std_logic;
  signal current_column_signal : std_logic_vector(calc_num_bits(h_pixels) - 1 downto 0);
  signal current_line_signal   : std_logic_vector(calc_num_bits(v_pixels) - 1 downto 0);

  signal vga_hs_o_s : std_logic;
  signal vga_vs_o_s : std_logic;
  signal vga_r_s    : std_logic_vector(3 downto 0);
  signal vga_g_s    : std_logic_vector(3 downto 0);
  signal vga_b_s    : std_logic_vector(3 downto 0);

  signal column_counter : unsigned(calc_num_bits(h_pixels) - 1 downto 0) := (others => '0');
  signal line_counter   : unsigned(calc_num_bits(v_pixels) - 1 downto 0) := (others => '0');

  signal address_pixel_s : std_logic_vector(ADDRESS_PIXEL_WIDTH - 1 downto 0);
  signal pixel_ok        : std_logic;

  signal vga_rgb : std_logic_vector(11 downto 0);

  -------------------------------------------------------
  -- MAQUINAS DE ESTADOS
  -------------------------------------------------------

begin

  -- Instanciación del generador de timing VGA
  timing_gen_inst : timing_generator
  generic map(
    h_pixels       => 2200, -- Total de pixeles horizontales
    v_pixels       => 1125, -- Total de líneas verticales
    front_porch_v  => 4,    -- Porche frontal vertical
    back_porch_v   => 36,   -- Porche trasero vertical
    active_lines   => 1080, -- Líneas activas (resolución vertical)
    v_sync         => 5,    -- Duración del sync vertical
    front_porch_h  => 88,   -- Porche frontal horizontal
    back_porch_h   => 148,  -- Porche trasero horizontal
    active_columns => 1920, -- Columnas activas (resolución horizontal)
    h_sync         => 44    -- Duración del sync horizontal
  )
  port map
  (
    PIXEL_CLK      => CLK,                   -- Entrada: Reloj de pixel
    ARESET         => ARESET,                -- Entrada: Reset asíncrono
    START_LINE     => start_line_signal,     -- Salida: Inicio de línea activa
    END_LINE       => end_line_signal,       -- Salida: Fin de línea activa
    START_H_SYNC   => start_h_sync_signal,   -- Salida: Inicio de sync horizontal
    END_H_SYNC     => end_h_sync_signal,     -- Salida: Fin de sync horizontal
    START_FRAME    => start_frame_signal,    -- Salida: Inicio de frame activo
    END_FRAME      => end_frame_signal,      -- Salida: Fin de frame activo
    START_V_SYNC   => start_v_sync_signal,   -- Salida: Inicio de sync vertical
    END_V_SYNC     => end_v_sync_signal,     -- Salida: Fin de sync vertical
    CURRENT_COLUMN => current_column_signal, -- Salida: Columna actual
    CURRENT_LINE   => current_line_signal    -- Salida: Línea actual
  );

  --INSTANCIACIÓN DE LA MEMORIA DE COLOR-----------------

  clut_inst : clut
  port map
  (
    clk         => CLK,
    pallete_sel => PALLETE_SELECTOR,
    iter        => PIXEL_IN,
    vga_rgb     => vga_rgb
  );
  -------------------------------------------------------
  -- ASIGNACIONES DE SEÑALES 
  -------------------------------------------------------
  line_counter <= unsigned(current_line_signal) when unsigned(current_line_signal) < 36 else
    unsigned(current_line_signal) - 36;

  column_counter <= unsigned(current_column_signal) when unsigned(current_column_signal) < 148 else
    unsigned(current_column_signal) - 148;

  -------------------------------------------------------
  -- PROCESOS SECUENCIALES 
  -------------------------------------------------------
  draw_process : process (CLK, ARESET)
    variable draw_idle     : std_logic; -- draw = 1, idle = 0
    variable v_pixel_count : UNSIGNED(20 downto 0);
    variable h_pixel_count : UNSIGNED(20
    downto 0);
    variable pixel_request : std_logic; -- Para perder un ciclo de reloj al esperar la BlockRam, ya que suele gastar un ciclo en llegar datos
  begin
    if ARESET = '1' then
      draw_idle := '0';
      pixel_ok        <= '0';
      address_pixel_s <= (others => '0');
      pixel_request := '0';
    elsif rising_edge(CLK) then

      pixel_request := '0'; -- valor predeterminado es 0

      if draw_idle = '0' then
        if START = '1' then
          draw_idle := '1';
        end if;
      elsif draw_idle = '1' then
        if ((column_counter >= 0) and (column_counter < (1920))) and
          ((line_counter >= 0) and (line_counter < (1080))) then

          h_pixel_count := to_unsigned((to_integer(unsigned(column_counter))) / 2, 21);
          v_pixel_count := to_unsigned((to_integer(unsigned(line_counter))) / 2, 21);

          -- Calculamos la dirección para un ancho de 960 usando: (v_pixel * 1024) - (v_pixel * 64) + h_pixel
          address_pixel_s <= std_logic_vector(resize(
            shift_left(v_pixel_count, 10) - shift_left(v_pixel_count, 6) + h_pixel_count,
            ADDRESS_PIXEL_WIDTH));

          -- Codificamos los valores de los píxeles (332)
          pixel_request := '1';
        else
          pixel_request := '0';
          address_pixel_s <= (others => '0');
        end if;

        if end_frame_signal = '1' then
          draw_idle := '0';
        end if;

      end if;

      pixel_ok <= pixel_request;
    end if;
  end process;

  sync_process_h : process (CLK, ARESET)
  begin
    if ARESET = '1' then
      vga_hs_o_s <= '0';
    elsif rising_edge(CLK) then
      if start_h_sync_signal = '1' then
        vga_hs_o_s <= '0';
      elsif end_h_sync_signal = '1' then
        vga_hs_o_s <= '1';
      end if;
    end if;
  end process;

  sync_process_v : process (CLK, ARESET)
  begin
    if ARESET = '1' then
      vga_vs_o_s <= '0';
    elsif rising_edge(CLK) then
      if start_v_sync_signal = '1' then
        vga_vs_o_s <= '0';
      elsif end_v_sync_signal = '1' then
        vga_vs_o_s <= '1';
      end if;
    end if;
  end process;
  -------------------------------------------------------
  -- ASIGNACIONES CONCURRENTES
  -------------------------------------------------------
  VGA_HS_O         <= vga_hs_o_s;
  VGA_VS_O         <= vga_vs_o_s;
  ADDRESS_PIXEL    <= address_pixel_s;
  START_V_SYNC_OUT <= start_v_sync_signal;

  -- VGA_R <= PIXEL_IN(7 downto 5) & "0" when pixel_ok = '1' else
  --   (others => '0');
  -- VGA_G <= PIXEL_IN(4 downto 2) & "0" when pixel_ok = '1' else
  --   (others => '0');
  -- VGA_B <= PIXEL_IN(1 downto 0) & "00" when pixel_ok = '1' else
  --   (others => '0');

  VGA_R <= vga_rgb(11 downto 8) when pixel_ok = '1' else
    (others => '0');
  VGA_G <= vga_rgb(7 downto 4) when pixel_ok = '1' else
    (others => '0');
  VGA_B <= vga_rgb(3 downto 0) when pixel_ok = '1' else
    (others => '0');

end architecture BEHAVIORAL;
