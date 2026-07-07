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
    clk      : in std_logic;
    VGA_HS_O : out std_logic;
    VGA_VS_O : out std_logic;
    VGA_R    : out std_logic_vector(3 downto 0);
    VGA_B    : out std_logic_vector(3 downto 0);
    VGA_G    : out std_logic_vector(3 downto 0);
    RESET    : in std_logic
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
  
  component fractal_core is
    generic (
      C_REAL   : signed(17 downto 0)  := "111101000101111010";
      C_IMG    : signed(17 downto 0)  := "000000110000010111";
      MAX_ITER : unsigned(7 downto 0) := "01100100"
    );
    port (
      clk     : in std_logic;
      RESET   : in std_logic;
      P_COLOR : out std_logic_vector(7 downto 0);
      ADDRESS : out std_logic_vector(16 downto 0);
      WEA     : out std_logic);
  end component;

  component blk_mem_gen_0 is
    port (
      clka  : in std_logic;
      ena   : in std_logic;
      wea   : in std_logic_vector(0 downto 0);
      addra : in std_logic_vector(16 downto 0);
      dina  : in std_logic_vector(7 downto 0);
      clkb  : in std_logic;
      enb   : in std_logic;
      addrb : in std_logic_vector(16 downto 0);
      doutb : out std_logic_vector(7 downto 0)
    );
  end component;

  component vga_driver is
    generic (
      ADDRESS_PIXEL_WIDTH : natural := 17
    );
    port (
      ARESET        : in std_logic;
      CLK           : in std_logic;
      VGA_HS_O      : out std_logic;
      VGA_VS_O      : out std_logic;
      VGA_R         : out std_logic_vector (3 downto 0);
      VGA_B         : out std_logic_vector (3 downto 0);
      VGA_G         : out std_logic_vector (3 downto 0);
      PIXEL_IN      : in std_logic_vector (7 downto 0);
      START         : in std_logic;
      ADDRESS_PIXEL : out std_logic_vector(ADDRESS_PIXEL_WIDTH - 1 downto 0)
    );
  end component;

  signal addres_pixel_s    : std_logic_vector(16 downto 0);
  signal pixel_s           : std_logic_vector(7 downto 0);
  signal pixel_clk_s       : std_logic;
  signal p_color_s         : std_logic_vector(7 downto 0);
  signal wea_s             : std_logic;
  signal address_pixel_s_a : std_logic_vector(16 downto 0);
  signal pixel_clk : std_logic;
  signal fractal_clk : std_logic;
  signal clk_bufg : std_logic;

begin

  -------------------------------------------------------
  -- INSTANCIACIÓN DE COMPONENTES
  -------------------------------------------------------
  -- Instanciacion del buffer del reloj
  BUFG_inst : BUFG
    port map (
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
  
  -- Instanciación del componente fractal_core
  fractal_core_inst : fractal_core
  generic map(
    C_REAL   => "111101000101111010",
    C_IMG    => "000000110000010111",
    MAX_ITER => x"FF"
  )
  port map
  (
    clk     => fractal_clk,
    RESET   => RESET,
    P_COLOR => p_color_s,
    ADDRESS => address_pixel_s_a,
    WEA     => wea_s
  );

  -- Instanciación del componente blk_mem_gen_0
  blk_mem_gen_0_inst : blk_mem_gen_0
  port map
  (
    clka  => fractal_clk,
    ena   => '1',
    wea   => (0 => wea_s),
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
    ADDRESS_PIXEL_WIDTH => 17
  )
  port map
  (
    ARESET        => RESET,
    CLK           => pixel_clk,
    VGA_HS_O      => VGA_HS_O,
    VGA_VS_O      => VGA_VS_O,
    VGA_R         => VGA_R,
    VGA_G         => VGA_G,
    VGA_B         => VGA_B,
    PIXEL_IN      => pixel_s,
    START         => '1',
    ADDRESS_PIXEL => addres_pixel_s
  );
end Behavioral;
