----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2026 07:16:44 PM
-- Design Name: 
-- Module Name: coordinates_generator - Behavioral
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

entity coordinates_generator is
  generic (
    RESX : natural := 320;
    RESY : natural := 240;

    -- DELTAREAL = 0.01
    DELTAREAL : SIGNED(17 downto 0) := "000000000010100100";
    -- RMIN = -1.6
    RMIN : SIGNED(17 downto 0) := "111001100110011010";

    -- DELTAIMG = 0.01
    DELTAIMG : SIGNED(17 downto 0) := "000000000010100100";
    -- IMIN = -1.2
    IMIN : SIGNED(17 downto 0) := "111011001100110011"
  );
  port (
    clk          : in std_logic;
    NEW_POINT    : in std_logic;
    X_COORDINATE : out std_logic_vector(17 downto 0);
    Y_COORDINATE : out std_logic_vector(17 downto 0);
    X_POSITION   : out std_logic_vector(17 downto 0);
    Y_POSITION   : out std_logic_vector(17 downto 0);
    RESET        : in std_logic);
end coordinates_generator;

architecture Behavioral of coordinates_generator is
  signal reset_real      : std_logic;
  signal count_x         : unsigned(17 downto 0) := (others => '0');
  signal enable_add_real : std_logic;
  signal real_coordinate : SIGNED(17 downto 0);
  --
  signal x_coordinate_s     : signed(17 downto 0);
  signal x_coordinate_reg_s : signed(17 downto 0);
  signal pre_x_coordinate_s : signed(17 downto 0);
  signal sel_mux            : std_logic;

  signal reset_img      : std_logic;
  signal count_y        : unsigned(17 downto 0) := (others => '0');
  signal enable_add_img : std_logic;
  signal img_coordinate : SIGNED(17 downto 0);
  --
  signal y_coordinate_s     : signed(17 downto 0);
  signal y_coordinate_reg_s : signed(17 downto 0);
  signal pre_y_coordinate_s : signed(17 downto 0);
  signal sel_mux_y          : std_logic;
begin

  -------------------------------------------------------
  -- PUNTOS X
  -------------------------------------------------------
  -------------------------------------------------------
  -- ASIGNACIONES CONCURRENTES
  -------------------------------------------------------
  -- comparador del final de resolucion
  reset_real <= '1' when count_x = TO_UNSIGNED((RESX - 1), 18) else
    '0';

  -- sumador de deltareal + señal del registro
  x_coordinate_s <= x_coordinate_reg_s + DELTAREAL;

  -- multiplexor para resetear registro
  pre_x_coordinate_s <= RMIN when sel_mux = '1' else
    x_coordinate_s;

  -- enable del registro real de x
  enable_add_real <= RESET or NEW_POINT or reset_real;

  -- or para el reset del registro
  sel_mux <= RESET or reset_real;
  -------------------------------------------------------
  -- CONTADOR DE X
  -------------------------------------------------------
  counter18x : process (clk)
  begin
    if rising_edge(clk) then
      if RESET = '1' then
        count_x <= (others => '0');
      elsif NEW_POINT = '1' then
        if reset_real = '1' then
          count_x <= (others => '0'); -- Retorno de carro
        else
          count_x <= count_x + 1; -- Siguiente pixel
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------
  -- REGISTRO DE COORDENADAS REALES
  -------------------------------------------------------
  real18x : process (clk)
  begin
    if rising_edge(clk) then
      if enable_add_real = '1' then
        x_coordinate_reg_s <= pre_x_coordinate_s;
      end if;
    end if;
  end process;

  -------------------------------------------------------
  -- PUNTOS Y
  -------------------------------------------------------
  -------------------------------------------------------
  -- ASIGNACIONES CONCURRENTES
  -------------------------------------------------------
  -- comparador del final de resolucion
  reset_img <= '1' when count_y = TO_UNSIGNED((RESY - 1), 18) else
    '0';

  -- sumador de deltaimg + señal del registro
  y_coordinate_s <= y_coordinate_reg_s + DELTAIMG;

  -- multiplexor para resetear registro
  pre_y_coordinate_s <= IMIN when sel_mux_y = '1' else
    y_coordinate_s;

  -- enable del registro real de y
  enable_add_img <= RESET or (NEW_POINT and reset_real) or reset_img;

  -- or para el reset del registro
  sel_mux_y <= RESET or reset_img;
  -------------------------------------------------------
  -- CONTADOR DE Y
  -------------------------------------------------------
  counter18y : process (clk)
  begin
    if rising_edge(clk) then
      if RESET = '1' then
        count_y <= (others => '0');
      elsif (NEW_POINT = '1' and reset_real = '1') then
        if reset_img = '1' then
          count_y <= (others => '0');
        else
          count_y <= count_y + 1;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------
  -- REGISTRO DE COORDENADAS IMAGINARIAS
  -------------------------------------------------------
  real18y : process (clk)
  begin
    if rising_edge(clk) then
      if enable_add_img = '1' then
        y_coordinate_reg_s <= pre_y_coordinate_s;
      end if;
    end if;
  end process;

  -------------------------------------------------------
  -- SALIDAS
  -------------------------------------------------------
  X_COORDINATE <= std_logic_vector(x_coordinate_reg_s);
  Y_COORDINATE <= std_logic_vector(y_coordinate_reg_s);
  X_POSITION   <= std_logic_vector(count_x);
  Y_POSITION   <= std_logic_vector(count_y);
end Behavioral;
