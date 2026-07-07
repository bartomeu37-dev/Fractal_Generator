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

entity fractal_core_old is
  generic (
    C_REAL   : signed(17 downto 0)  := "111101000101111010";
    C_IMG    : signed(17 downto 0)  := "000000110000010111";
    MAX_ITER : unsigned(7 downto 0) := "01100100"
  );
  port (
    clk     : in std_logic;
    RESET   : in std_logic;
    P_COLOR : out std_logic_vector(7 downto 0);
    ADDRESS : out std_logic_vector(18 downto 0);
    WEA     : out std_logic);
end fractal_core_old;

architecture Behavioral of fractal_core_old is
  constant ESCAPE_THRESH : unsigned(17 downto 0) := to_unsigned(4 * 2 ** 14, 18);

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
  signal address_s        : unsigned(18 downto 0) := (others => '0');
  signal p_color_s        : std_logic_vector(7 downto 0);

  -------------------------------------------------------
  -- SEÑALES DEL CALCULO
  -------------------------------------------------------
  signal real_coordinate_signed : SIGNED(17 downto 0);
  signal img_coordinate_signed  : SIGNED(17 downto 0);
  type gen_state is (RST, IDLE, COORDINATE_CALC, WAIT_COORD, RESET_ITER, CALC_SQR_PROD_WAIT, IMG_REAL, CALC_MODULE, CALC_SQR_PROD, STORE, END_FRACTAL);
  signal fsm_state_calc : gen_state;
  signal iter           : unsigned(7 downto 0) := (others => '0');

  signal wea_s : std_logic;

begin
  -------------------------------------------------------
  -- INSTANCIACIÓN DE COMPONENTES
  -------------------------------------------------------
  inst_coordinates_generator : component coordinates_generator
    generic map(
      RESX => 960,
      RESY => 540,
      DELTAREAL => "000000000001001001",
      RMIN => "110111011101110111",
      DELTAIMG => "000000000001001001",
      IMIN => "111011001100110011"
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
    -- ASIGNACIONES CONCURRENTES
    -------------------------------------------------------
    real_coordinate_signed <= signed(real_coordinate);
    img_coordinate_signed  <= signed(img_coordinate);
    ADDRESS                <= std_logic_vector(address_s);
    P_COLOR                <= p_color_s;
    WEA                    <= wea_s;

    fractal_process : process (clk, RESET)
      variable module      : unsigned(17 downto 0);
      variable real_x      : signed(17 downto 0);
      variable img_y       : signed(17 downto 0);
      variable real_x_sq   : unsigned(35 downto 0);
      variable img_y_sq    : unsigned(35 downto 0);
      variable prod_x_y    : signed(35 downto 0);
      variable next_real_x : signed(17 downto 0);
      variable next_img_y  : signed(17 downto 0);

      variable real_x_sq_18 : signed(17 downto 0);
      variable img_y_sq_18  : signed(17 downto 0);
      variable prod_x_y_18  : signed(17 downto 0);
    begin
      if RESET = '1' then
        fsm_state_calc <= RST;
      elsif rising_edge(clk) then
        case fsm_state_calc is
          when RST =>
            new_point_s <= '0';
            wea_s       <= '0';
            real_x    := (others      => '0');
            img_y     := (others      => '0');
            real_x_sq := (others      => '0');
            img_y_sq  := (others      => '0');
            module    := (others      => '0');
            address_s      <= (others => '0');
            fsm_state_calc <= IDLE;

          when IDLE =>
            wea_s          <= '0';
            new_point_s    <= '1';
            fsm_state_calc <= WAIT_COORD;
          when WAIT_COORD =>
            new_point_s    <= '0';
            fsm_state_calc <= COORDINATE_CALC;

          when COORDINATE_CALC =>
            real_x := real_coordinate_signed;
            img_y  := img_coordinate_signed;
            fsm_state_calc <= RESET_ITER;

          when RESET_ITER           =>
            iter           <= (others => '0');
            fsm_state_calc <= CALC_SQR_PROD;

          when CALC_SQR_PROD =>
            real_x_sq := unsigned(real_x * real_x);
            img_y_sq  := unsigned(img_y * img_y);
            prod_x_y  := img_y * real_x;
            fsm_state_calc <= CALC_SQR_PROD_WAIT;

          when CALC_SQR_PROD_WAIT =>
            fsm_state_calc <= IMG_REAL;

          when IMG_REAL =>
            real_x_sq_18 := signed(real_x_sq(31 downto 14));
            img_y_sq_18  := signed(img_y_sq(31 downto 14));
            prod_x_y_18  := signed(prod_x_y(31 downto 14));

            next_img_y  := shift_left(prod_x_y_18, 1) + C_IMG;
            next_real_x := real_x_sq_18 - img_y_sq_18 + C_REAL;
            fsm_state_calc <= CALC_MODULE;

          when CALC_MODULE =>
            module := unsigned(real_x_sq_18) + unsigned(img_y_sq_18);
            iter <= iter + 1;
            real_x := next_real_x;
            img_y  := next_img_y;
            fsm_state_calc <= STORE;

          when STORE =>
            if (iter < MAX_ITER) and (module < ESCAPE_THRESH) then
              fsm_state_calc <= CALC_SQR_PROD;
            else
              fsm_state_calc <= IDLE;
              p_color_s      <= std_logic_vector(iter);
              wea_s          <= '1';
              if address_s < (518400 - 1) then
                address_s <= address_s + 1;
              else
                address_s      <= (others => '0');
                fsm_state_calc <= END_FRACTAL;
              end if;
            end if;
          when END_FRACTAL =>
            wea_s <= '0';
          when others =>
            null;
        end case;
      end if;
    end process;
  end Behavioral;
