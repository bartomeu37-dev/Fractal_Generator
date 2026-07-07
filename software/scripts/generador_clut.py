#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun May 24 13:59:53 2026

@author: barmirled
"""

import math
import numpy as np
import matplotlib.pyplot as plt

def generar_y_visualizar():
    nombres_paletas = [
        "Arcoíris Psicodélico",
        "Fuego / Magma",
        "Océano / Hielo",
        "Escala de Grises"
    ]

    # Matriz para la imagen: 4 filas (paletas), 256 columnas (colores), 3 canales (RGB)
    imagen_paletas = np.zeros((4, 256, 3), dtype=np.uint8)
    
    # Lista para ir guardando el código VHDL
    vhdl = []
    vhdl.append("process(clk_148_5)")
    vhdl.append("begin")
    vhdl.append("    if rising_edge(clk_148_5) then")
    vhdl.append("        case sel_paleta is")

    for paleta in range(4):
        bin_sel = f"{paleta:02b}"
        vhdl.append(f"            -- Paleta {paleta}: {nombres_paletas[paleta]}")
        vhdl.append(f"            when \"{bin_sel}\" =>")
        vhdl.append("                case to_integer(unsigned(iteracion)) is")
        
        for i in range(256):
            if i == 0:
                r_hex, g_hex, b_hex = 0, 0, 0
            else:
                frecuencia = 0.1
                
                if paleta == 0:
                    fase_r, fase_g, fase_b = 0, 2, 4
                elif paleta == 1:
                    fase_r, fase_g, fase_b = 0, -1.5, -3
                elif paleta == 2:
                    fase_r, fase_g, fase_b = -3, 0, 1.5
                else:
                    fase_r, fase_g, fase_b = 0, 0, 0

                # Cálculo base
                r_float = math.sin(frecuencia * i + fase_r) * 127 + 128
                g_float = math.sin(frecuencia * i + fase_g) * 127 + 128
                b_float = math.sin(frecuencia * i + fase_b) * 127 + 128
                
                # Ajustes específicos
                if paleta == 1: b_float = max(0, b_float - 64)
                if paleta == 2: r_float = max(0, r_float - 64)

                # Convertimos al hardware real (4 bits por canal: 0 a 15)
                r_hex = int(r_float) >> 4
                g_hex = int(g_float) >> 4
                b_hex = int(b_float) >> 4

            # --- PARTE VISUAL (MATPLOTLIB) ---
            # Para mostrarlo en el PC, re-escalamos ese valor de 4 bits (0-15) 
            # a un valor de 8 bits (0-255) multiplicando por 17 (ya que 15 * 17 = 255)
            # Esto te muestra exactamente la pérdida de color que tendrá el FPGA
            imagen_paletas[paleta, i, 0] = r_hex * 17 # Rojo
            imagen_paletas[paleta, i, 1] = g_hex * 17 # Verde
            imagen_paletas[paleta, i, 2] = b_hex * 17 # Azul

            # --- PARTE CÓDIGO (VHDL) ---
            vhdl.append(f"                    when {i:<3} => vga_rgb <= x\"{r_hex:X}{g_hex:X}{b_hex:X}\";")
            
        vhdl.append("                    when others => vga_rgb <= x\"000\";")
        vhdl.append("                end case;")
        vhdl.append("")

    vhdl.append("            when others =>")
    vhdl.append("                vga_rgb <= x\"000\";")
    vhdl.append("        end case;")
    vhdl.append("    end if;")
    vhdl.append("end process;")

    # Imprimir el código VHDL en la terminal
    print("\n".join(vhdl))

    # Mostrar el gráfico con Matplotlib
    plt.figure(figsize=(12, 4))
    # 'aspect=auto' permite que las franjas se estiren horizontalmente
    plt.imshow(imagen_paletas, aspect='auto') 
    
    # Configurar las etiquetas del gráfico
    plt.yticks(ticks=[0, 1, 2, 3], labels=nombres_paletas)
    plt.xlabel("Iteraciones (0 a 255)")
    plt.title("Previsualización de Paletas CLUT (Simulando VGA 12-bit de Nexys 4)")
    
    # Hacer que la ventana se ajuste bien
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    generar_y_visualizar()