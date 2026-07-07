library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.all;

entity tb_fractal_core_oo is
end entity;

architecture test of tb_fractal_core_oo is
    component fractal_core_oo is
        port (
            clk         : in  std_logic;
            RESET       : in  std_logic;
            P_COLOR     : out std_logic_vector(7 downto 0);
            ADDRESS     : out std_logic_vector(18 downto 0);
            WEA         : out std_logic;
            C_REAL_IN   : in  std_logic_vector(17 downto 0);
            C_IMG_IN    : in  std_logic_vector(17 downto 0);
            MAX_ITER_IN : in  std_logic_vector(7 downto 0)
        );
    end component;

    constant CLK_PERIOD   : time    := 10 ns;               -- 100 MHz
    constant TOTAL_PIXELS : natural := 960 * 540;           -- 518400
    constant LAST_ADDR    : unsigned(18 downto 0) := to_unsigned(TOTAL_PIXELS - 1, 19);

    -- Señales de estímulo
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal c_real    : std_logic_vector(17 downto 0) := "111101000101111010";
    signal c_img     : std_logic_vector(17 downto 0) := "000000110000010111";
    signal max_iter  : std_logic_vector(7 downto 0)  := "01100100";  -- 100

    -- Salidas del DUT
    signal p_color   : std_logic_vector(7 downto 0);
    signal address   : std_logic_vector(18 downto 0);
    signal wea       : std_logic;

    -- Contadores de rendimiento
    signal cycle_count : natural := 0;
    signal start_count : boolean := false;
    signal sim_done    : boolean := false;

begin
    -- Instancia del núcleo fractal avanzado
    uut: fractal_core_oo
        port map (
            clk         => clk,
            RESET       => reset,
            P_COLOR     => p_color,
            ADDRESS     => address,
            WEA         => wea,
            C_REAL_IN   => c_real,
            C_IMG_IN    => c_img,
            MAX_ITER_IN => max_iter
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

    -- Detección del final del frame: ADDRESS pasa de 518399 a 0
    finish_proc: process(clk)
        variable prev_addr : unsigned(18 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if reset = '1' then
                prev_addr := (others => '0');
            else
                if prev_addr = LAST_ADDR and unsigned(address) = 0 then
                    sim_done <= true;
                end if;
                prev_addr := unsigned(address);
            end if;
        end if;
    end process;

    -- Informe de resultados
    report_results : process
    begin
        wait until sim_done;
        wait for 0 ns;
        report "==================================================" severity note;
        report "   MEDICION DE RENDIMIENTO DEL NUCLEO AVANZADO   " severity note;
        report "--------------------------------------------------" severity note;
        report "Total de píxeles procesados : " & integer'image(TOTAL_PIXELS) severity note;
        report "Ciclos totales del frame    : " & integer'image(cycle_count) severity note;
        report "Tiempo total (ms)           : " & real'image(real(cycle_count) * 0.00001) severity note;
        report "Ciclos medios por punto     : " & real'image(real(cycle_count) / real(TOTAL_PIXELS)) severity note;
        report "==================================================" severity note;
        stop;
    end process;
end architecture;