----------------------------------------------------------------------------------
-- Testbench para coordinates_generator
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity coordinates_generator_tb is
end coordinates_generator_tb;

architecture behavior of coordinates_generator_tb is

    component coordinates_generator
        generic (
            RESX      : natural;
            RESY      : natural;
            DELTAREAL : SIGNED(17 downto 0);
            RMIN      : SIGNED(17 downto 0);
            DELTAIMG  : SIGNED(17 downto 0);
            IMIN      : SIGNED(17 downto 0)
        );
        port (
            clk          : in std_logic;
            NEW_POINT    : in std_logic;
            X_COORDINATE : out std_logic_vector(17 downto 0);
            Y_COORDINATE : out std_logic_vector(17 downto 0);
            RESET        : in std_logic
        );
    end component;

    -- 2. Señales internas para conectar con el componente
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal new_point    : std_logic := '0';
    signal x_coordinate : std_logic_vector(17 downto 0);
    signal y_coordinate : std_logic_vector(17 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: coordinates_generator
        generic map (
            RESX      => 320,
            RESY      => 240,
            -- Valores Q4.14 para X: de -1.6 a 1.6
            DELTAREAL => "000000000010100100", 
            RMIN      => "111001100110011010",
            -- Valores Q4.14 para Y: de -1.2 a 1.2
            DELTAIMG  => "000000000010100100",
            IMIN      => "111011001100110011"
        )
        port map (
            clk          => clk,
            NEW_POINT    => new_point,
            X_COORDINATE => x_coordinate,
            Y_COORDINATE => y_coordinate,
            RESET        => reset
        );


    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;


    stim_proc: process
    begin
        -- RESETEAMOS durante 50 ns
        reset <= '1';
        new_point <= '0';
        wait for 50 ns;
        
        reset <= '0';
        wait for 50 ns;

        -- BUCLE DE SIMULACIÓN:
        -- Simulamos que el Núcleo Fractal pide puntos continuamente.
        -- Para que se vea bien en la simulación, vamos a pedir un punto, 
        -- y luego "esperar" unos ciclos imitando el tiempo de cálculo del fractal.
        
        for i in 0 to (320 * 5) loop -- Simulamos 5 líneas completas para no hacer el test infinito
            
            -- 1. El motor fractal dice "¡Dame un punto nuevo!"
            new_point <= '1';
            wait for CLK_PERIOD; -- El pulso dura exactamente 1 ciclo de reloj
            
            -- 2. El motor fractal está calculando (bajamos la señal)
            new_point <= '0';
            
            -- Esperamos unos cuantos ciclos aleatorios (ej. 3 ciclos de reloj)
            -- En la vida real esto variaría entre 1 y 1000 ciclos dependiendo del pixel
            wait for CLK_PERIOD * 3; 
            
        end loop;

        -- Fin de la simulación
        -- Detenemos el simulador explícitamente (funciona en Vivado 2008+)
        assert false report "Simulacion terminada con exito." severity failure;
        wait;
    end process;

end behavior;