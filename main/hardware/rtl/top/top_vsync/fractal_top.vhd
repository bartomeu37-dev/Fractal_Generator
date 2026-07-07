----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/04/2026 10:38:24 PM
-- Design Name: 
-- Module Name: fractal_top - Behavioral
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

-----------------------------------------------------------
-- PAQUETES
-----------------------------------------------------------
use work.auxiliary_functions_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity fractal_top is
  port (
    clk              : in std_logic;
    VGA_HS_O         : out std_logic;
    VGA_VS_O         : out std_logic;
    VGA_R            : out std_logic_vector(3 downto 0);
    VGA_B            : out std_logic_vector(3 downto 0);
    VGA_G            : out std_logic_vector(3 downto 0);
    RESET            : in std_logic;
    PALLETE_SELECTOR : in std_logic_vector(1 downto 0)
  );
end fractal_top;

architecture Behavioral of fractal_top is

  component clk_wiz_0 is
    port (
      clk_out1 : out std_logic;
      reset    : in std_logic;
      locked   : out std_logic;
      clk_in1  : in std_logic
    );
  end component;

  component clk_wiz_1 is
    port (
      clk_out1 : out std_logic;
      reset    : in std_logic;
      locked   : out std_logic;
      clk_in1  : in std_logic
    );
  end component;

  component fractal_compute_unit is
    generic (
      N_CORES   : natural             := 30;
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
  end component;

  component blk_mem_gen_0 is
    port (
      clka  : in std_logic;
      ena   : in std_logic;
      wea   : in std_logic_vector(0 downto 0);
      addra : in std_logic_vector(18 downto 0);
      dina  : in std_logic_vector(7 downto 0);
      clkb  : in std_logic;
      enb   : in std_logic;
      addrb : in std_logic_vector(18 downto 0);
      doutb : out std_logic_vector(7 downto 0)
    );
  end component;

  component vga_driver is
    generic (
      ADDRESS_PIXEL_WIDTH : natural := 19
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
      START            : in std_logic;
      ADDRESS_PIXEL    : out std_logic_vector(ADDRESS_PIXEL_WIDTH - 1 downto 0);
      START_V_SYNC_OUT : out std_logic;
      PALLETE_SELECTOR : in std_logic_vector(1 downto 0)
    );
  end component;

  signal addres_pixel_s    : std_logic_vector(18 downto 0);
  signal pixel_s           : std_logic_vector(7 downto 0);
  signal pixel_clk_s       : std_logic;
  signal p_color_s         : std_logic_vector(7 downto 0);
  signal wea_s             : std_logic;
  signal address_pixel_s_a : std_logic_vector(18 downto 0);
  signal pixel_clk         : std_logic;
  signal fractal_clk       : std_logic;
  signal clk_bufg          : std_logic;
  --signal continue_calc     : std_logic;
  -- Señal de reseteo para el nucleo fractal
  signal reset_fc : std_logic;

  -- señal para la constante C
  signal c_real_count : SIGNED(17 downto 0) := "111101000101111010";
  signal c_img_count  : SIGNED(17 downto 0) := "000000110000010111";

  -- señal intermedia para la constante C
  signal c_real_s           : std_logic_vector(17 downto 0);
  signal c_img_s            : std_logic_vector(17 downto 0);
  signal max_iter_s         : std_logic_vector(7 downto 0);
  signal start_v_sync_out_s : std_logic;

  -- señal para empezar el cálculo
  signal start_calc : std_logic;

  -- señal para cambiar la constante
  signal change_c : std_logic;

  -- circuito CDC
  signal sync_ff0 : std_logic;
  signal sync_ff1 : std_logic;
  signal sync_ff2 : std_logic;

  signal increment_state : std_logic;

  type state_t is (ST_IDLE, ST_RUNNING);
  signal current_state : state_t := ST_IDLE;

  signal real_dir : std_logic := '0';
  signal img_dir  : std_logic := '0';

begin

  -------------------------------------------------------
  -- INSTANCIACIÓN DE COMPONENTES
  -------------------------------------------------------

  -- Instanciación del FCU
  fractal_compute_unit_inst : fractal_compute_unit
  generic map(
    N_CORES   => 80,
    RESX      => 960,
    RESY      => 540,
    DELTAREAL => "000000000001001001",
    RMIN      => "110111011101110111",
    DELTAIMG  => "000000000001001001",
    IMIN      => "111011001100110011"
  )
  port map
  (
    clk         => fractal_clk,
    RESET       => reset_fc,
    ITER        => p_color_s,
    C_REAL_IN   => c_real_s,
    C_IMG_IN    => c_img_s,
    MAX_ITER_IN => max_iter_s,
    ADDR        => address_pixel_s_a,
    PUSH        => wea_s
  );

  -- Instanciacion del buffer del reloj
  BUFG_inst : BUFG
  port map
  (
    O => clk_bufg,
    I => clk
  );

  -- Instanciación del generador de relojes
  clock_gen : clk_wiz_0
  port map
  (
    clk_out1 => pixel_clk,
    reset    => RESET,
    locked   => open,
    clk_in1  => clk_bufg
  );

  -- Instanciación del generador de relojes para el nucleo fractal
  clock_gen_fr : clk_wiz_1
  port map
  (
    clk_out1 => fractal_clk,
    reset    => RESET,
    locked   => open,
    clk_in1  => clk_bufg
  );

  -- Instanciación del componente blk_mem_gen_0
  blk_mem_gen_0_inst : blk_mem_gen_0
  port map
  (
    clka  => fractal_clk,
    ena   => '1',
    wea => (0 => wea_s),
    addra => address_pixel_s_a,
    dina  => p_color_s,
    clkb  => pixel_clk,
    enb   => '1',
    addrb => addres_pixel_s,
    doutb => pixel_s
  );

  -- Instanciación del componente vga_driver
  vga_driver_inst : vga_driver
  generic map(
    ADDRESS_PIXEL_WIDTH => 19
  )
  port map
  (
    ARESET           => RESET,
    CLK              => pixel_clk,
    START_V_SYNC_OUT => start_v_sync_out_s,
    VGA_HS_O         => VGA_HS_O,
    VGA_VS_O         => VGA_VS_O,
    VGA_R            => VGA_R,
    VGA_G            => VGA_G,
    VGA_B            => VGA_B,
    PIXEL_IN         => pixel_s,
    START            => '1',
    ADDRESS_PIXEL    => addres_pixel_s,
    PALLETE_SELECTOR => PALLETE_SELECTOR
  );

  -------------------------------------------------------
  -- PROCESO DE INCREMENTO DE C
  -------------------------------------------------------

  process (fractal_clk)
  begin
    if rising_edge(fractal_clk) then
      sync_ff0 <= start_calc;
      sync_ff1 <= sync_ff0;
      sync_ff2 <= sync_ff1;
    end if;
  end process;
  change_c <= sync_ff1 and (not sync_ff2);

  inc_c_process : process (fractal_clk, RESET)
  begin
    if RESET = '1' then
      current_state <= ST_IDLE;
      c_img_count   <= "000000110000010111";
      img_dir       <= '1';
      real_dir      <= '1';
      c_real_count  <= "111101000101111010";
      reset_fc      <= '1';
    elsif rising_edge(fractal_clk) then

      case current_state is

        when ST_IDLE =>
          reset_fc <= '1'; -- El núcleo se mantiene a apagado

          if change_c = '1' then
            current_state <= ST_RUNNING;
          end if;

        when ST_RUNNING =>
          reset_fc <= '0'; -- Liberamos el reset para que el núcleo calcule

          if wea_s = '1' and unsigned(address_pixel_s_a) >= 518399 then

            -- control de intervalos del contador R
            if real_dir = '1' then
              c_real_count <= c_real_count + 16;
              if c_real_count >= 5000 - 16 then
                real_dir <= '0';
              end if;
            else
              c_real_count    <= c_real_count - 16;
              if c_real_count <= -14000 + 16 then
                real_dir        <= '1';
              end if;
            end if;

            --Control de iintervalos del contador I
            if img_dir = '1' then
              c_img_count <= c_img_count + 8;
              if c_img_count >= 13000 - 8 then
                img_dir <= '0';
              end if;
            else
              c_img_count    <= c_img_count - 8;
              if c_img_count <= -1000 + 8 then
                img_dir        <= '1';
              end if;
            end if;

            reset_fc      <= '1';
            current_state <= ST_IDLE;
          else
            c_real_count <= c_real_count;
            c_img_count  <= c_img_count;
          end if;

      end case;

    end if;
  end process;

  -------------------------------------------------------
  -- PROCESO DE GENERACIÓN DE PULSO VSYNC
  -------------------------------------------------------
  vsync_cicle_proc : process (pixel_clk)
    variable prev_vsync : std_logic;
  begin
    if rising_edge(pixel_clk) then
      start_calc <= '0';
      if start_v_sync_out_s = '1' and prev_vsync = '0' then
        start_calc <= '1';
      end if;

      prev_vsync := start_v_sync_out_s;
    end if;
  end process;
  
  -------------------------------------------------------
  -- ASIGNACIONES CONCURRENTES
  -------------------------------------------------------
  c_real_s   <= std_logic_vector(c_real_count);
  c_img_s    <= std_logic_vector(c_img_count);
  max_iter_s <= x"FA";

end Behavioral;
