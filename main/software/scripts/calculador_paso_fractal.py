#!/usr/bin/env python3
# -*- coding: utf-8 -*-

def float_to_hdl_twos_complement(val):
    """
    Convierte un float a formato Complemento a 2 de 18 bits para VHDL (tipo signed):
    - 1 bit de signo
    - 3 bits de parte entera
    - 14 bits de parte fraccionaria (Q4.14)
    """
    # 1. Escalar por 2^14 (Desplazar la coma 14 posiciones)
    q_val = int(round(val * (1 << 14)))
    
    # 2. Limitar al máximo y mínimo de 18 bits con signo
    max_val = (1 << 17) - 1   # 131071
    min_val = -(1 << 17)      # -131072
    
    if q_val > max_val: q_val = max_val
    elif q_val < min_val: q_val = min_val
        
    # 3. Aplicar complemento a 2 real mediante máscara bitwise
    val_final = q_val & 0x3FFFF
        
    # Formatear
    bin_str = f"{val_final:018b}"
    bin_hdl = f'"{bin_str}"'
    hex_hdl = f"18'h{val_final:05X}"
    
    return val_final, bin_hdl, hex_hdl

def calcular_plano_julia_hdl(width, height, center_re=0.0, center_im=0.0, zoom=1.0):
    # Altura base ideal para ver todo el fractal grande sin cortarse
    base_height = 2.4  
    
    # Rango visible en función del zoom
    im_range = base_height / zoom
    re_range = im_range * (width / height)
    
    im_min = center_im - (im_range / 2)
    im_max = center_im + (im_range / 2)
    re_min = center_re - (re_range / 2)
    re_max = center_re + (re_range / 2)
    
    step_re = (re_max - re_min) / (width - 1)
    step_im = (im_max - im_min) / (height - 1)
    
    resultados = {
        "RMIN (re_min)": re_min,
        "DELTAREAL (step_re)": step_re,
        "IMIN (im_min)": im_min,
        "DELTAIMG (step_im)": step_im
    }
    
    print(f"--- PARÁMETROS DEL LIENZO (RESOLUCIÓN: {width}x{height} | ZOOM: {zoom}x) ---")
    for nombre, valor in resultados.items():
        _, bin_hdl, _ = float_to_hdl_twos_complement(valor)
        print(f"{nombre:<20} : {bin_hdl}  -- (Valor Float: {valor:.6f})")

def calcular_constante_c(nombre, c_re, c_im):
    val_re, bin_re, _ = float_to_hdl_twos_complement(c_re)
    val_im, bin_im, _ = float_to_hdl_twos_complement(c_im)
    print(f"\n--- CONSTANTE C: {nombre} ---")
    print(f"C_REAL => {bin_re} (Decimal para tu contador: {val_re if c_re >= 0 else val_re - 262144})")
    print(f"C_IMG  => {bin_im} (Decimal para tu contador: {val_im if c_im >= 0 else val_im - 262144})")

if __name__ == "__main__":
    ANCHO = 960
    ALTO = 540
    
    # 1. Calculamos el lienzo perfecto para la pantalla (Zoom 1.0 centra toda la figura)
    calcular_plano_julia_hdl(ANCHO, ALTO, center_re=0.0, center_im=0.0, zoom=1.0)
    
    # 2. Calculamos algunas constantes hermosas para la animación
    calcular_constante_c("El Conejo de Douady (Formas redondas y conectadas)", -0.123, 0.745)
    calcular_constante_c("Galaxias y Espirales", 0.285, 0.013)
    calcular_constante_c("Valle del Hipocampo", -0.800, 0.156)