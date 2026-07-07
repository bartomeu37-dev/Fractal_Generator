library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.all;

entity tb_fractal_compute_unit is
end entity;

architecture test of tb_fractal_compute_unit is
    -- Componente bajo test
    component fractal_compute_unit is
        generic (
            N_CORES   : natural := 4;
            RESX      : natural := 960;
            RESY      : natural := 540;
            DELTAREAL : signed(17 downto 0) := "000000000001000000";
            RMIN      : signed(17 downto 0) := "111000100000000000";
            DELTAIMG  : signed(17 downto 0) := "000000000001000000";
            IMIN      : signed(17 downto 0) := "111011110010000000"
        );
        port (
            clk         : in  std_logic;
            RESET       : in  std_logic;
            ITER        : out std_logic_vector(7 downto 0);
            C_REAL_IN   : in  std_logic_vector(17 downto 0);
            C_IMG_IN    : in  std_logic_vector(17 downto 0);
            MAX_ITER_IN : in  std_logic_vector(7 downto 0);
            ADDR        : out std_logic_vector(18 downto 0);
            PUSH        : out std_logic
        );
    end component;

    -- Parámetros
    constant CLK_PERIOD     : time    := 10 ns;           -- 100 MHz
    constant TOTAL_PIXELS   : natural := 960 * 540;       -- 518400
    constant LAST_ADDR      : unsigned(18 downto 0) := to_unsigned(TOTAL_PIXELS - 1, 19);

    -- Señales de estímulo
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal c_real    : std_logic_vector(17 downto 0) := "111101000101111010";
    signal c_img     : std_logic_vector(17 downto 0) := "000000110000010111";
    signal max_iter  : std_logic_vector(7 downto 0)  := "01100100";  -- 100

    -- Salidas del DUT
    signal iter_out  : std_logic_vector(7 downto 0);
    signal addr_out  : std_logic_vector(18 downto 0);
    signal push_out  : std_logic;

    -- Contadores de rendimiento
    signal cycle_count : natural := 0;
    signal start_count : boolean := false;
    signal sim_done    : boolean := false;

begin
    -- Instancia de la unidad de cómputo con 80 cores
    uut: fractal_compute_unit
        generic map (
            N_CORES   => 80,
            RESX      => 960,
            RESY      => 540,
            DELTAREAL => "000000000001001001",
            RMIN      => "110111011101110111",
            DELTAIMG  => "000000000001001001",
            IMIN      => "111011001100110011"
        )
        port map (
            clk         => clk,
            RESET       => reset,
            ITER        => iter_out,
            C_REAL_IN   => c_real,
            C_IMG_IN    => c_img,
            MAX_ITER_IN => max_iter,
            ADDR        => addr_out,
            PUSH        => push_out
        );

    -- Generación del reloj
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
        start_count <= true;          -- empezar a contar ciclos
        wait;
    end process;

    -- Contador de ciclos tras el reset
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

    -- Detección del último píxel emitido
    finish_proc: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                sim_done <= false;
            else
                -- Último píxel: PUSH activo y dirección = 518399
                if push_out = '1' and unsigned(addr_out) = LAST_ADDR then
                    sim_done <= true;
                end if;
            end if;
        end if;
    end process;

    -- Informe de resultados
    report_results : process
    begin
        wait until sim_done;
        wait for 0 ns;
        report "==================================================" severity note;
        report "   MEDICION DE RENDIMIENTO: FCU de 80 núcleos    " severity note;
        report "--------------------------------------------------" severity note;
        report "Total de píxeles procesados : " & integer'image(TOTAL_PIXELS) severity note;
        report "Ciclos totales del frame    : " & integer'image(cycle_count) severity note;
        report "Tiempo total (ms)           : " & real'image(real(cycle_count) * 0.00001) severity note;
        report "Ciclos medios por punto     : " & real'image(real(cycle_count) / real(TOTAL_PIXELS)) severity note;
        report "==================================================" severity note;
        stop;
    end process;
end architecture;