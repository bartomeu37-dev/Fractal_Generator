----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2026 10:01:21 PM
-- Design Name: 
-- Module Name: fractal_core - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fractal_core_io is
  generic (
    CORE_ID   : natural             := 0;
    RESX      : natural             := 960;
    RESY      : natural             := 540;
    DELTAREAL : signed(17 downto 0) := "000000000001000000";
    RMIN      : signed(17 downto 0) := "111000100000000000";
    DELTAIMG  : signed(17 downto 0) := "000000000001000000";
    N_CORES   : natural             := 1;
    IMIN      : signed(17 downto 0) := "111011110010000000"
  );
  port (
    clk     : in std_logic;
    RESET   : in std_logic;
    P_COLOR : out std_logic_vector(7 downto 0);
    --ADDRESS     : out std_logic_vector(18 downto 0);
    WEA         : out std_logic;
    C_REAL_IN   : in std_logic_vector(17 downto 0);
    C_IMG_IN    : in std_logic_vector(17 downto 0);
    MAX_ITER_IN : in std_logic_vector(7 downto 0);
    NUMBER_DEV  : out std_logic_vector(31 downto 0);
    CONTINUE    : in std_logic
  );
end fractal_core_io;

architecture Behavioral of fractal_core_io is
  constant ESCAPE_THRESH : unsigned(17 downto 0) := to_unsigned(4 * 2 ** 14, 18);
  signal C_REAL          : signed(17 downto 0)   := "111101000101111010";
  signal C_IMG           : signed(17 downto 0)   := "000000110000010111";
  signal MAX_ITER        : unsigned(7 downto 0)  := "01100100";

  component coordinates_generator is
    generic (
      RESX      : natural             := 960;
      RESY      : natural             := 540;
      DELTAREAL : signed(17 downto 0) := "000000000001001001";
      RMIN      : signed(17 downto 0) := "110111011101110111";
      DELTAIMG  : signed(17 downto 0) := "000000000001001001";
      IMIN      : signed(17 downto 0) := "111011001100110011"
    );
    port (
      clk          : in std_logic;
      NEW_POINT    : in std_logic;
      X_COORDINATE : out std_logic_vector(17 downto 0);
      Y_COORDINATE : out std_logic_vector(17 downto 0);
      X_POSITION   : out std_logic_vector(17 downto 0);
      Y_POSITION   : out std_logic_vector(17 downto 0);
      RESET        : in std_logic
    );
  end component;

  signal new_point_s      : std_logic;
  signal real_coordinate  : std_logic_vector(17 downto 0);
  signal img_coordinate   : std_logic_vector(17 downto 0);
  signal pixel_x_position : std_logic_vector(17 downto 0);
  signal pixel_y_position : std_logic_vector(17 downto 0);

  -------------------------------------------------------
  -- SEÑALES DEL CALCULO
  -------------------------------------------------------
  signal real_coordinate_signed : SIGNED(17 downto 0);
  signal img_coordinate_signed  : SIGNED(17 downto 0);

  -------------------------------------------------------
  -- SEÑALES EXTRAS
  -------------------------------------------------------
  --signal next_addr : UNSIGNED(18 downto 0);
  signal next_iter : UNSIGNED(7 downto 0);
  signal wea_mem   : std_logic;
  -------------------------------------------------------
  -- SEÑALES PARA EL BUFFER DE COORDENADAS
  -------------------------------------------------------
  --signal addr_bf_np            : UNSIGNED(18 downto 0);
  signal iter_bf_np            : UNSIGNED(7 downto 0);
  signal real_coordinate_bf_np : SIGNED(17 downto 0);
  signal img_coordinate_bf_np  : SIGNED(17 downto 0);
  signal valid_bf_np           : std_logic;
  -------------------------------------------------------
  -- SEÑALES PARA EL BUFFER DE MULTIPLICACIÓN
  -------------------------------------------------------
  -- contexto
  --signal addr_bf_m  : UNSIGNED(18 downto 0);
  signal iter_bf_m  : UNSIGNED(7 downto 0);
  signal valid_bf_m : std_logic;
  -- calculos
  signal real_x_bf_m : signed(17 downto 0);
  signal img_y_bf_m  : signed(17 downto 0);

  -------------------------------------------------------
  -- SEÑALES PARA EL BUFFER DE SUMAS
  -------------------------------------------------------
  -- contexto
  --signal addr_bf_s  : UNSIGNED(18 downto 0);
  signal iter_bf_s  : UNSIGNED(7 downto 0);
  signal valid_bf_s : std_logic;

  -- registro calculos
  signal real_x_sq_bf_s_18 : signed(17 downto 0);
  signal img_y_sq_bf_s_18  : signed(17 downto 0);
  signal prod_x_y_bf_s_18  : signed(17 downto 0);
  -- cálculos combinacionales
  signal real_x_sq_bf_s_36 : unsigned(35 downto 0);
  signal img_y_sq_bf_s_36  : unsigned(35 downto 0);
  signal prod_x_y_bf_s_36  : signed(35 downto 0);

  -------------------------------------------------------
  -- SEÑALES PARA EL BUFFER DE MEMORIA
  -------------------------------------------------------
  --signal addr_buf_mem : UNSIGNED(18 downto 0);
  signal iter_buf_mem : UNSIGNED(7 downto 0);
  signal wea_ff_mem   : std_logic;

  -------------------------------------------------------
  -- SEÑALES PARA EL MUX DE ENTRADA
  -------------------------------------------------------
  -- contexto
  --signal addr_mux : UNSIGNED(18 downto 0);
  signal iter_mux : UNSIGNED(7 downto 0);
  -- calculos
  signal real_x_mux : signed(17 downto 0);
  signal img_y_mux  : signed(17 downto 0);
  -- seleccion
  signal sel_last_new_p : std_logic;
  -- Señal punto válido
  signal valid_mux : std_logic;
  -------------------------------------------------------
  -- SEÑALES PARA LA ETAPA DE SUMA
  -------------------------------------------------------
  signal module      : UNSIGNED(17 downto 0);
  signal next_img_y  : SIGNED(17 downto 0);
  signal next_real_x : SIGNED(17 downto 0);

  -------------------------------------------------------
  -- SEÑALES PARA LA ETAPA DE COMPARACIÓN
  -------------------------------------------------------
  --signal next_addr_mem : UNSIGNED(18 downto 0);
  signal next_iter_mem : UNSIGNED(7 downto 0);

  -------------------------------------------------------
  -- SEÑALES PARA EL CONTROL
  -------------------------------------------------------
  signal next_point         : std_logic;
  signal multiplication_ena : std_logic;
  signal mod_and_calc_ena   : std_logic;
  signal comp_ena           : std_logic;
  -- Señales de fetch y prefetch para tener un punto siempre cargado
  signal fetch_state    : integer range 0 to 2 := 0;
  signal prefetch_valid : std_logic            := '0';
  signal internal_stall : std_logic;

  -------------------------------------------------------
  -- SEÑALES PARA EL CONTROL DE PARADA
  -------------------------------------------------------
  type state_type is (ST_EJECUCION, ST_ESPERA, ST_RESET);
  signal st_state : state_type;
  signal wea_out  : std_logic;

  -------------------------------------------------------
  -- SEÑALES PARA DEPURACIÓN
  -------------------------------------------------------
  signal number_np_bf_dev     : unsigned(31 downto 0);
  signal number_mux_dev       : UNSIGNED(31 downto 0);
  signal number_m_bf_dev      : UNSIGNED(31 downto 0);
  signal number_s_bf_dev      : UNSIGNED(31 downto 0);
  signal number_out_bf_dev    : UNSIGNED(31 downto 0);
  signal number_next_dev      : UNSIGNED(31 downto 0);
  signal number_out_bf_ff_dev : UNSIGNED(31 downto 0);

  -------------------------------------------------------
  -- SEÑALES PARA CONTROL DE ETAPAS
  -------------------------------------------------------
  -- Estas señales dicen si el punto ha escapado
  signal escaped_m_point        : std_logic;
  signal escaped_s_reg          : std_logic; -- Salida del registro de la etapa de suma
  signal escaped_s_comb         : std_logic; -- Salida combinacional del control de comparación
  signal escaped_feedback_point : std_logic;

begin

  -------------------------------------------------------
  -- INSTANCIACIÓN DE COMPONENTES
  -------------------------------------------------------
  inst_coordinates_generator : component coordinates_generator
    generic map(
      RESX => RESX / N_CORES,
      RESY => RESY,
      -- DELTAREAL = 0.00390625
      DELTAREAL => resize(to_signed(N_CORES, 18) * DELTAREAL, 18),
      -- RMIN = -1.875
      RMIN => RMIN + resize(to_signed(CORE_ID, 18) * DELTAREAL, 18),
      -- DELTAIMG = 0.00390625
      DELTAIMG => DELTAIMG,
      -- IMIN = -1.0546875
      IMIN => IMIN
    )
    port map
    (
      clk          => clk,
      NEW_POINT    => new_point_s,
      X_COORDINATE => real_coordinate,
      Y_COORDINATE => img_coordinate,
      X_POSITION   => pixel_x_position,
      Y_POSITION   => pixel_y_position,
      RESET        => RESET
    );

    -------------------------------------------------------
    -- PIPELINE STALL CONTROLLER
    -------------------------------------------------------
    ps_process : process (RESET, clk)
    begin
      if RESET = '1' then
        st_state <= ST_RESET;
      elsif rising_edge(clk) then
        case st_state is
          when ST_RESET =>
            internal_stall <= '1';
            st_state       <= ST_EJECUCION;
          when ST_EJECUCION =>
            internal_stall <= '0';
            if wea_mem then
              internal_stall <= '1';
              st_state       <= ST_ESPERA;
            end if;
          when ST_ESPERA =>
            internal_stall <= '1';
            if CONTINUE = '1' then
              internal_stall <= '0';
              st_state       <= ST_EJECUCION;
            end if;
          when others =>
            null;
        end case;
      end if;
    end process;

    -------------------------------------------------------
    -- FRONT END
    -------------------------------------------------------
    ft_process : process (RESET, clk)
    begin
      if RESET = '1' then
        multiplication_ena <= '0';
        mod_and_calc_ena   <= '0';
        comp_ena           <= '0';
        wea_out            <= '0';
      elsif rising_edge(clk) then

        if wea_ff_mem = '1' then
          wea_out <= '1';
        elsif CONTINUE = '1' then
          wea_out <= '0';
        end if;

      end if;
    end process;

    -------------------------------------------------------
    -- ASIGNACIONES CONCURRENTES
    -------------------------------------------------------
    real_coordinate_signed <= signed(real_coordinate);
    img_coordinate_signed  <= signed(img_coordinate);
    new_point_s            <= next_point;
    C_REAL                 <= SIGNED(C_REAL_IN);
    C_IMG                  <= SIGNED(C_IMG_IN);
    MAX_ITER               <= UNSIGNED(MAX_ITER_IN);
    NUMBER_DEV             <= std_logic_vector(number_out_bf_ff_dev);
    -------------------------------------------------------
    -- SALIDAS
    -------------------------------------------------------
    P_COLOR <= std_logic_vector(iter_buf_mem);
    WEA     <= wea_out and internal_stall;

    -------------------------------------------------------
    -- REGISTROS
    -------------------------------------------------------
    prefetch_process : process (RESET, clk)
    begin
      if RESET = '1' then
        real_coordinate_bf_np <= (others => '0');
        img_coordinate_bf_np  <= (others => '0');
        number_np_bf_dev      <= TO_UNSIGNED(CORE_ID, 32);
        prefetch_valid        <= '0';
        fetch_state           <= 0;
        next_point            <= '0';
      elsif rising_edge(clk) then
        -- Máquina de estados del prefetch
        case fetch_state is
          when 0 =>
            next_point <= '0';
            if prefetch_valid = '0' then
              -- El registro está vacío, pedimos un punto
              next_point  <= '1';
              fetch_state <= 1;
            end if;

          when 1 =>
            -- Quitamos el pulso y esperamos 1 ciclo a que el generador cargue el punto nuevo
            next_point  <= '0';
            fetch_state <= 2;

          when 2 =>
            -- Capturamos el dato en el registro
            real_coordinate_bf_np <= real_coordinate_signed;
            img_coordinate_bf_np  <= img_coordinate_signed;
            prefetch_valid        <= '1';
            fetch_state           <= 0;
        end case;

        -- Como si fuera una FIFO se consume el punto antes generado y automaticamente pedimos un punto
        -- nuevo para llenar el buffer de coordenadas
        -- Si el pipeline pide un punto Y lo tenemos listo:
        if sel_last_new_p = '1' and prefetch_valid = '1' and internal_stall = '0' then
          prefetch_valid   <= '0'; -- Vaciamos el registro y decimos que pida punto nuevo
          number_np_bf_dev <= number_np_bf_dev + N_CORES;
        end if;
      end if;
    end process;

    product_reg : process (RESET, clk)
    begin
      if RESET = '1' then
        number_m_bf_dev <= (others => '0');
        iter_bf_m       <= (others => '0');
        real_x_bf_m     <= (others => '0');
        img_y_bf_m      <= (others => '0');
        escaped_m_point <= '1';
        valid_bf_m      <= '0';
      elsif rising_edge(clk) then
        if internal_stall = '0' then
          -- actualizamos contexto
          iter_bf_m       <= iter_mux;
          valid_bf_m      <= valid_mux;
          escaped_m_point <= escaped_feedback_point;
          -- actualizamos los puntos
          real_x_bf_m <= real_x_mux;
          img_y_bf_m  <= img_y_mux;
          -- Contexto de orden
          number_m_bf_dev <= number_mux_dev;
        end if;
      end if;
    end process;

    x_process : process (all)
    begin
      real_x_sq_bf_s_36 <= UNSIGNED(real_x_bf_m * real_x_bf_m);
      img_y_sq_bf_s_36  <= UNSIGNED(img_y_bf_m * img_y_bf_m);
      prod_x_y_bf_s_36  <= real_x_bf_m * img_y_bf_m;
    end process;

    sum_reg : process (RESET, clk)
    begin
      if RESET = '1' then
        iter_bf_s         <= (others => '0');
        real_x_sq_bf_s_18 <= (others => '0');
        img_y_sq_bf_s_18  <= (others => '0');
        prod_x_y_bf_s_18  <= (others => '0');
        number_s_bf_dev   <= (others => '0');
        valid_bf_s        <= '0';
        escaped_s_reg     <= '1';
      elsif rising_edge(clk) then
        if internal_stall = '0' then
          -- actualizamos contexto
          iter_bf_s         <= iter_bf_m;
          valid_bf_s        <= valid_bf_m;
          number_s_bf_dev   <= number_m_bf_dev;
          escaped_s_reg     <= escaped_m_point;
          real_x_sq_bf_s_18 <= SIGNED(real_x_sq_bf_s_36(31 downto 14));
          img_y_sq_bf_s_18  <= SIGNED(img_y_sq_bf_s_36(31 downto 14));
          prod_x_y_bf_s_18  <= prod_x_y_bf_s_36(31 downto 14);
          -- actualizamos los puntos
        end if;
      end if;
    end process;

    sum_mod_process : process (all)
    begin
      next_img_y  <= shift_left(prod_x_y_bf_s_18, 1) + C_IMG;
      next_real_x <= real_x_sq_bf_s_18 - img_y_sq_bf_s_18 + C_REAL;
      module      <= unsigned(real_x_sq_bf_s_18) + unsigned(img_y_sq_bf_s_18);
    end process;

    -------------------------------------------------------
    -- ETAPAS
    -------------------------------------------------------
    comp_control : process (all)
    begin
      -- Valores por defecto
      escaped_s_comb    <= escaped_s_reg;
      next_iter         <= (others => '0');
      next_iter_mem     <= (others => '0');
      number_next_dev   <= number_s_bf_dev;
      number_out_bf_dev <= (others => '0');
      sel_last_new_p    <= '0';
      wea_mem           <= '0';
      if (valid_bf_s = '0') then
        sel_last_new_p <= '1';
      else
        -- Primero miramos si el punto había sido marcado antes, si ha sido marcado antes y es el más
        -- viejo, sacamos el punto y pedimos uno nuevo, sino se evalua de forma normal
        if (escaped_s_reg = '0') and (number_s_bf_dev < number_m_bf_dev) then
          -- Es el más viejo y escapa, lo sacamos
          next_iter_mem     <= iter_bf_s;
          number_out_bf_dev <= number_s_bf_dev;
          wea_mem           <= '1';
          sel_last_new_p    <= '1'; -- Pedimos uno nuevo al generador
        elsif (escaped_s_reg = '1') and (iter_bf_s < MAX_ITER) and (module < ESCAPE_THRESH) then
          -- Sigue calculando normalmente
          next_iter       <= iter_bf_s + 1;
          number_next_dev <= number_s_bf_dev;
          escaped_s_comb  <= '1';
        else
          -- El punto ha terminado (por escape o max_iter) y no ha sido marcado antes
          if (number_s_bf_dev > number_m_bf_dev) and (valid_bf_m = '1') then
            -- Si es más nuevo lo mantenemos dando vueltas pero no lo sacamos
            escaped_s_comb  <= '0'; -- Marcamos que ya escapó
            number_next_dev <= number_s_bf_dev;
            next_iter       <= iter_bf_s; -- Guardamos la iteración
          else
            -- Es el más viejo y escapa lo sacamos
            next_iter_mem     <= iter_bf_s;
            number_out_bf_dev <= number_s_bf_dev;
            wea_mem           <= '1';
            sel_last_new_p    <= '1'; -- Pedimos uno nuevo al generador
          end if;
        end if;
      end if;
    end process;

    iter_buffer : process (RESET, clk)
    begin
      if RESET = '1' then
        iter_buf_mem         <= (others => '0');
        wea_ff_mem           <= '0';
        number_out_bf_ff_dev <= (others => '0');
      elsif rising_edge(clk) then
        if internal_stall = '0' then
          wea_ff_mem           <= wea_mem;
          iter_buf_mem         <= next_iter_mem;
          number_out_bf_ff_dev <= number_out_bf_dev;
        end if;
      end if;
    end process;
    -------------------------------------------------------
    -- MULTIPLEXOR DE ENTRADA
    -------------------------------------------------------
    mux_process : process (all)
    begin
      if sel_last_new_p = '1' then
        -- INYECTAR PUNTO NUEVO
        real_x_mux             <= real_coordinate_bf_np;
        img_y_mux              <= img_coordinate_bf_np;
        number_mux_dev         <= number_np_bf_dev;
        valid_mux              <= prefetch_valid;
        iter_mux               <= (others => '0');
        escaped_feedback_point <= '1';
      else
        -- FEEDBACK
        valid_mux              <= valid_bf_s;
        real_x_mux             <= next_real_x;
        img_y_mux              <= next_img_y;
        iter_mux               <= next_iter;
        number_mux_dev         <= number_next_dev;
        escaped_feedback_point <= escaped_s_comb;
      end if;
    end process;

  end Behavioral;
