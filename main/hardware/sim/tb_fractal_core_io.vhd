library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.all;

entity tb_fractal_core_io is
end entity;

architecture test of tb_fractal_core_io is
    component fractal_core_io is
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
            clk         : in  std_logic;
            RESET       : in  std_logic;
            P_COLOR     : out std_logic_vector(7 downto 0);
            WEA         : out std_logic;
            C_REAL_IN   : in  std_logic_vector(17 downto 0);
            C_IMG_IN    : in  std_logic_vector(17 downto 0);
            MAX_ITER_IN : in  std_logic_vector(7 downto 0);
            NUMBER_DEV  : out std_logic_vector(31 downto 0);
            CONTINUE    : in  std_logic
        );
    end component;

    constant CLK_PERIOD   : time    := 10 ns;               -- 100 MHz
    -- Total de píxeles para este núcleo (960*540 con N_CORES=1)
    constant TOTAL_PIXELS : natural := 960 * 540;           -- 518400
    constant LAST_NUMBER  : unsigned(31 downto 0) := to_unsigned(TOTAL_PIXELS - 1, 32);
    constant CORE_ID      : natural := 0;

    -- Señales de estímulo
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal c_real    : std_logic_vector(17 downto 0) := "111101000101111010";
    signal c_img     : std_logic_vector(17 downto 0) := "000000110000010111";
    signal max_iter  : std_logic_vector(7 downto 0)  := "01100100";  -- 100
    signal continue_s : std_logic := '1';   -- siempre activo para no detener el pipeline

    -- Salidas del DUT
    signal p_color   : std_logic_vector(7 downto 0);
    signal wea       : std_logic;
    signal number_dev : std_logic_vector(31 downto 0);

    -- Contadores de rendimiento
    signal cycle_count : natural := 0;
    signal start_count : boolean := false;
    signal sim_done    : boolean := false;

begin
    -- Instancia del núcleo fractal in-order
    uut: fractal_core_io
        generic map (
            CORE_ID   => CORE_ID,
            RESX      => 960,
            RESY      => 540,
            DELTAREAL => "000000000001001001",
            RMIN      => "110111011101110111",
            DELTAIMG  => "000000000001001001",
            N_CORES   => 1,
            IMIN      => "111011001100110011"
        )
        port map (
            clk         => clk,
            RESET       => reset,
            P_COLOR     => p_color,
            WEA         => wea,
            C_REAL_IN   => c_real,
            C_IMG_IN    => c_img,
            MAX_ITER_IN => max_iter,
            NUMBER_DEV  => number_dev,
            CONTINUE    => continue_s
        );

    -- Generación del reloj (se detiene al terminar)
    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Secuencia de reset
    reset_process: process
    begin
        reset <= '1';
        wait for 100 ns;
        wait until rising_edge(clk);
        reset       <= '0';
        start_count <= true;          -- empezar a medir ciclos
        wait;
    end process;

    -- Contador de ciclos (tras el reset)
    cycle_counter: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                cycle_count <= 0;
            elsif start_count then
                cycle_count <= cycle_count + 1;
            end if;
        end if;
    end process;

    -- Detección del final del frame: NUMBER_DEV pasa de LAST_NUMBER a CORE_ID (0)
    finish_proc: process(clk)
        variable prev_number : unsigned(31 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if reset = '1' then
                prev_number := (others => '0');
            else
                if prev_number = LAST_NUMBER and unsigned(number_dev) = CORE_ID then
                    sim_done <= true;
                end if;
                prev_number := unsigned(number_dev);
            end if;
        end if;
    end process;

    -- Informe de resultados
    report_results : process
    begin
        wait until sim_done;
        wait for 0 ns;
        report "==================================================" severity note;
        report "   MEDICION DE RENDIMIENTO DEL NUCLEO IN-ORDER   " severity note;
        report "--------------------------------------------------" severity note;
        report "Total de píxeles procesados : " & integer'image(TOTAL_PIXELS) severity note;
        report "Ciclos totales del frame    : " & integer'image(cycle_count) severity note;
        report "Tiempo total (ms)           : " & real'image(real(cycle_count) * 0.00001) severity note;
        report "Ciclos medios por punto     : " & real'image(real(cycle_count) / real(TOTAL_PIXELS)) severity note;
        report "==================================================" severity note;
        stop;
    end process;
end architecture;