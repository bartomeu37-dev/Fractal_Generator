#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jan 10 18:13:49 2026

@author: barmirled
"""

import numpy as np
import matplotlib.pyplot as plt
import numba

@numba.jit(parallel=True)
def lyapunov(secuencia, iters=150, res=1000, alpha=.78):
    # Definimos el plano (a, b)
    a_vals = np.linspace(2, 4, res)
    b_vals = np.linspace(2, 4, res)
    
    # Matriz para guardar el exponente de cada pixel
    mapa = np.zeros((res, res))

    for i, a in enumerate(a_vals):
        for j, b in enumerate(b_vals):
            x = 0.5
            suma_log = 0
            
            # 1. Fase de calentamiento (estabilizar x)
            for _ in range(50):
                # Elegimos r según la secuencia (A o B)
                for char in secuencia:
                    r = a if char == 'A' else b
                    if x > 0.5:
                        x = r * x * (1 - x)
                    else:
                        x = r * x * (1 - x) + 0.25 * (alpha - 1) * (r - 2)
            # 2. Cálculo del exponente
            for _ in range(iters):
                for char in secuencia:
                    r = a if char == 'A' else b
                    # Derivada del mapa logístico: r*(1 - 2x)
                    derivada = abs(r * (1 - 2 * x))
                    if derivada > 0:
                        suma_log += np.log2(derivada)
                    if x > .5:
                        x = r * x * (1 - x)
                    else:
                        x = r*x*(1-x) + .25*(alpha -1)*(r-2)
            mapa[j, i] = suma_log / (iters * len(secuencia))
    return mapa

# Ejecución
sec = "ABAB"
resultado = lyapunov(sec)
# Visualización para que se vea como tu imagen azul
plt.figure(figsize=(10, 12), facecolor='white')
# Filtramos para resaltar las zonas estables (negativos)
plt.imshow(resultado, cmap='ocean', extent=[2, 4, 2, 4]) 
plt.axis('off')
plt.show()