----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/20/2026 07:29:49 PM
-- Design Name: 
-- Module Name: vga_module - Behavioral
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

-- Paquete de funciones auxiliares
use work.auxiliary_functions_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity timing_generator is
  generic (
    h_pixels       : natural := 2200;
    v_pixels       : natural := 1125;
    front_porch_v  : natural := 4;
    back_porch_v   : natural := 36;
    active_lines   : natural := 1080;
    v_sync         : natural := 5;
    front_porch_h  : natural := 88;
    back_porch_h   : natural := 148;
    active_columns : natural := 1920;
    h_sync         : natural := 44
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
end timing_generator;

architecture Behavioral of timing_generator is
  signal column_counter : UNSIGNED(calc_num_bits(h_pixels) - 1 downto 0) := (others => '0');
  signal line_counter   : UNSIGNED(calc_num_bits(v_pixels) - 1 downto 0) := (others => '0');
  signal start_line_s   : std_logic                                      := '0';
  signal end_line_s     : std_logic                                      := '0';
  signal start_h_sync_s : std_logic                                      := '0';
  signal end_h_sync_s   : std_logic                                      := '0';
  signal start_frame_s  : std_logic                                      := '0';
  signal end_frame_s    : std_logic                                      := '0';
  signal start_v_sync_s : std_logic                                      := '0';
  signal end_v_sync_s   : std_logic                                      := '0';
  signal ce             : std_logic                                      := '0';
begin

  horizontal_counter : process (PIXEL_CLK, ARESET)
  begin
    if ARESET = '1' then
      column_counter <= (others => '0');
    elsif rising_edge(PIXEL_CLK) then
      column_counter <= column_counter + 1;

      -- reseteamos al llegar al numero de pixeles máximos
      if column_counter = (h_pixels - 1) then
        column_counter <= (others => '0');
        ce             <= '1';
      else
        ce <= '0';
      end if;

      -- Si es 0 sacamos señal de acabar el h_sync
      if column_counter = 0 then
        end_h_sync_s <= '1';
      else
        end_h_sync_s <= '0';
      end if;
      -- si es 148 empezamos la linea
      if column_counter = back_porch_h then
        start_line_s <= '1';
      else
        start_line_s <= '0';
      end if;

      -- Si llegamos al final de active lines avisamos
      if column_counter = (back_porch_h + active_columns) then
        end_line_s <= '1';
      else
        end_line_s <= '0';
      end if;

      -- si llegamos a final de back_porch+active_columns+front_porch_h, activamos la señal de empezar h_sync
      if column_counter = (back_porch_h + active_columns + front_porch_h) then
        start_h_sync_s <= '1';
      else
        start_h_sync_s <= '0';
      end if;
    end if;
  end process;

  vertical_counter : process (PIXEL_CLK, ARESET)
    variable start_frame_state  : std_logic := '0';
    variable end_frame_state    : std_logic := '0';
    variable start_v_sync_state : std_logic := '0';
    variable end_v_sync_state   : std_logic := '0';
  begin
    if ARESET = '1' then
      line_counter <= (others => '0');
      end_v_sync_state   := '0';
      start_frame_state  := '0';
      end_frame_state    := '0';
      start_v_sync_state := '0';
    elsif rising_edge(PIXEL_CLK) then
      -- señales por defecto:
      end_v_sync_s   <= '0';
      start_frame_s  <= '0';
      end_frame_s    <= '0';
      start_v_sync_s <= '0';

      -- solamente contamos cuando acabamos una linea
      if ce = '1' then
        line_counter <= line_counter + 1;
        -- reseteamos al llegar al numero de pixeles máximos
        if line_counter = (v_pixels - 1) then
          line_counter <= (others => '0');
        end if;
      end if;

      -- Si es 0 sacamos señal de acabar el v_sync, generamos una sola señal de reloj
      if line_counter = 0 and end_v_sync_state = '0' then
        end_v_sync_s <= '1';
        end_v_sync_state := '1';
      elsif line_counter /= 0 then
        end_v_sync_state := '0';
      end if;

      -- si es 36 empezamos el frame
      if line_counter = back_porch_v and start_frame_state = '0' then
        start_frame_s <= '1';
        start_frame_state := '1';
      elsif line_counter /= back_porch_v then
        start_frame_state := '0';
      end if;

      -- Si llegamos al final del frame avisamos
      if line_counter = (back_porch_v + active_lines) and end_frame_state = '0' then
        end_frame_s <= '1';
        end_frame_state := '1';
      elsif line_counter /= (back_porch_v + active_lines) then
        end_frame_state := '0';
      end if;

      -- si llegamos a final de back_porch+frame+front_porch_v, activamos la señal de empezar v_sync
      if line_counter = (back_porch_v + active_lines + front_porch_v) and start_frame_state = '0' then
        start_v_sync_s <= '1';
        start_v_sync_state := '1';
      elsif line_counter /= (back_porch_v + active_lines + front_porch_v) then
        start_v_sync_state := '0';
      end if;

    end if;
  end process;
  
  -- Asignaciones concurrentes horizontales
  START_H_SYNC   <= start_h_sync_s;
  END_H_SYNC     <= end_h_sync_s;
  END_LINE       <= end_line_s;
  START_LINE     <= start_line_s;
  CURRENT_COLUMN <= std_logic_vector(column_counter);

  -- Asignaciones concurrentes verticales
  START_V_SYNC <= start_v_sync_s;
  END_V_SYNC   <= end_v_sync_s;
  START_FRAME  <= start_frame_s;
  END_FRAME    <= end_frame_s;
  CURRENT_LINE <= std_logic_vector(line_counter);
end Behavioral;
