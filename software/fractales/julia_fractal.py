#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec 26 18:05:24 2025

@author: barmirled
"""
#este código se ha hecho pensando en la lógica vhdl

import numpy as np
import matplotlib.pyplot as plt
import numba


#estos valores representan el plano complejo donde el fractal se desarrolla
Xmin = -0.75
Ymin = 0.099
Xmax = -0.747
Ymax = 0.102

@numba.jit(parallel=True)
def julia(cimg, creal, xlen, ylen, Imax, Xmin, Ymin, Xmax, Ymax):
    c = complex(creal, cimg)
    x = np.linspace(Xmin, Xmax, xlen)
    y = np.linspace(Ymin, Ymax, ylen)
    
    fractal = np.full((len(y), len(x)), Imax, dtype = int) #creamos una matriz de 2 dimensiones donde el valor maximo es Imax
    
    for i in range(len(y)):
        for n in range(len(x)):
            Iter = 0    #creamos y borramos las variables para los calculos 
            Zy = y[i]
            Zx = x[n]
            modulo_cuadrado = Zx**2 + Zy**2
            
            while Iter < Imax and modulo_cuadrado < 4:
                xsig = Zx**2 - Zy**2 + c.real
                ysig = 2*Zx*Zy + c.imag
                
                Zx = xsig
                Zy = ysig
                
                modulo_cuadrado = Zx**2 + Zy**2
                Iter += 1

            fractal[i, n] = Iter
    return fractal

## Para probar y hacer un fondo de pantalla
width, height = 1920,1080
aspect_ratio = width/height

Imax = 100

y_range = 1.2
x_range = y_range*aspect_ratio

fractal = julia(0.1889, -0.7269, width, height, Imax, -x_range, -y_range, x_range, y_range)

plt.imshow(fractal, extent=[Xmin, Xmax, Ymin, Ymax], cmap="magma")

plt.axis('off')

plt.subplots_adjust(left=0, right=1, top=1, bottom=0)

# Después de calcular fractal
total_puntos = fractal.size
puntos_fuera = np.sum(fractal < Imax)   # puntos que escaparon
porcentaje_fuera = (puntos_fuera / total_puntos) * 100

print(f"Porcentaje de puntos fuera del atractor: {porcentaje_fuera:.2f}%")

def analyze_performance(fractal, Imax, clock_freq_Hz=None, clock_period_s=None, num_units=1):
    """
    Analiza el rendimiento considerando múltiples unidades de cómputo en paralelo.
    
    Parámetros:
    - fractal: matriz 2D con iteraciones por punto.
    - Imax: número máximo de iteraciones (para calcular puntos fuera del atractor).
    - clock_freq_Hz: frecuencia del reloj en Hz.
    - clock_period_s: período del reloj en segundos (alternativo).
    - num_units: número de unidades de cómputo que trabajan en paralelo (cada unidad procesa un punto por ciclo).
    
    Retorna un diccionario con:
    - total_iterations: suma total de iteraciones (trabajo total).
    - effective_cycles: ciclos de reloj efectivos (total_iterations / num_units).
    - frame_time_s: tiempo por frame en segundos.
    - fps_achievable: FPS alcanzables con la frecuencia actual.
    - meets_60fps: booleano que indica si se alcanzan 60 FPS.
    - required_clock_hz: frecuencia mínima necesaria para lograr 60 FPS con num_units.
    - points_outside_pct: porcentaje de puntos fuera del atractor.
    """
    if clock_freq_Hz:
        T_clk = 1.0 / clock_freq_Hz
    elif clock_period_s:
        T_clk = clock_period_s
    else:
        raise ValueError("Debe proporcionar clock_freq_Hz o clock_period_s")
    
    total_iter = np.sum(fractal)          # trabajo total en ciclos (1 iteración = 1 ciclo)
    puntos_total = fractal.size
    
    # Con N unidades trabajando en paralelo, los ciclos efectivos por frame son:
    effective_cycles = total_iter / num_units   # puede ser fraccionario, pero indica media
    
    frame_time = effective_cycles * T_clk
    fps = 1.0 / frame_time if frame_time > 0 else float('inf')
    
    # Frecuencia necesaria para 60 FPS dados num_units y total_iter
    # T_frame_deseado = 1/60 ≈ 0.0166667 s
    # effective_cycles * T_clk <= 1/60  =>  (total_iter/num_units) * (1/f) <= 1/60
    # => f >= (total_iter * 60) / num_units
    required_freq = (total_iter * 60.0) / num_units
    
    puntos_fuera = np.sum(fractal < Imax)
    fuera_pct = 100.0 * puntos_fuera / puntos_total
    
    return {
        'total_iterations': int(total_iter),
        'effective_cycles': effective_cycles,
        'frame_time_s': frame_time,
        'fps_achievable': fps,
        'meets_60fps': fps >= 60.0,
        'required_clock_hz': required_freq,
        'points_outside_pct': fuera_pct,
        'num_points': puntos_total,
        'num_units': num_units
    }

def compute_time_burst(fractal, clock_freq_Hz=None, clock_period_s=None, burst_size=30):
    """
    Calcula tiempo total de procesamiento para arquitectura que procesa
    'burst_size' puntos en paralelo y espera a que todos terminen.

    Parámetros:
    - fractal: matriz 2D con iteraciones por punto (cada entrada = iteraciones realizadas).
    - clock_freq_Hz / clock_period_s: frecuencia o período del reloj.
    - burst_size: número de puntos procesados simultáneamente (por defecto 30).

    Retorna diccionario con:
    - total_batches: número de ráfagas.
    - sum_max_iter: suma de los máximos de iteración por ráfaga.
    - total_time_s: tiempo total en segundos.
    - avg_time_per_point_s: tiempo medio por punto (total_time / num_puntos).
    - fps_achievable: frames por segundo si este tiempo es el de un frame.
    - required_clock_hz_60fps: frecuencia necesaria para conseguir 60 FPS con este burst_size.
    """
    if clock_freq_Hz:
        T_clk = 1.0 / clock_freq_Hz
    elif clock_period_s:
        T_clk = clock_period_s
    else:
        raise ValueError("Debe proporcionar frecuencia o período")

    # Aplanamos la matriz en un array 1D (orden row-major)
    iteraciones = fractal.flatten()
    num_puntos = len(iteraciones)

    # Dividir en ráfagas
    batches = [iteraciones[i:i+burst_size] for i in range(0, num_puntos, burst_size)]
    max_iter_por_batch = [np.max(batch) for batch in batches]

    total_cycles = sum(max_iter_por_batch)   # suma de máximos
    total_time = total_cycles * T_clk

    # Para 60 FPS (frame_time deseado = 1/60 ≈ 0.0166667 s)
    required_cycles_per_frame = 1/60 / T_clk   # ciclos necesarios para 60 fps
    # Como cada ráfaga cuesta max_iter, se necesita que sum(max_iter) <= required_cycles
    # La frecuencia necesaria es: f >= sum(max_iter) * 60
    required_freq_60 = total_cycles * 60.0

    return {
        'num_points': num_puntos,
        'burst_size': burst_size,
        'total_batches': len(batches),
        'sum_max_iter': total_cycles,
        'total_time_s': total_time,
        'avg_time_per_point_s': total_time / num_puntos,
        'fps_achievable': 1.0 / total_time if total_time>0 else float('inf'),
        'required_clock_hz_60fps': required_freq_60
    }


# Supongamos que 'fractal' ya está calculado
result = analyze_performance(fractal, Imax=100, clock_freq_Hz=300e6, num_units=30)

print(f"Puntos totales: {result['num_points']}")
print(f"Iteraciones totales: {result['total_iterations']}")
print(f"Ciclos efectivos (con {result['num_units']} unidades): {result['effective_cycles']:.1f}")
print(f"Tiempo por frame: {result['frame_time_s']*1000:.3f} ms")
print(f"FPS alcanzables: {result['fps_achievable']:.1f}")
print(f"¿Llega a 60 FPS? {result['meets_60fps']}")
print(f"Frecuencia necesaria para 60 FPS: {result['required_clock_hz']/1e6:.1f} MHz")
print(f"% fuera del atractor: {result['points_outside_pct']:.1f}%")

result_burst = compute_time_burst(fractal, clock_freq_Hz=300e6, burst_size=30)

print(f"Ráfagas totales: {result_burst['total_batches']}")
print(f"Suma de máximos por ráfaga (ciclos): {result_burst['sum_max_iter']}")
print(f"Tiempo total por frame: {result_burst['total_time_s']*1000:.3f} ms")
print(f"FPS alcanzables: {result_burst['fps_achievable']:.1f}")
print(f"Frecuencia necesaria para 60 FPS: {result_burst['required_clock_hz_60fps']/1e6:.1f} MHz")


# Guardar
#plt.savefig("julia4.png", dpi=900, bbox_inches='tight', pad_inches=0)
#print("¡Fondo de pantalla guardado como 'mi_fractal_wallpaper.png'!")
#plt.show()

