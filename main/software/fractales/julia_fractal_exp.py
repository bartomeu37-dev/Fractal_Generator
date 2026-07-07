#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Dec 27 21:52:46 2025

@author: barmirled
"""

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
                xsig = np.exp(Zx**3-3*Zx*(Zy**2))*np.cos(3*(Zx**2)*Zy-Zy**3)+c.real
                ysig = np.exp(Zx**3-3*Zx*(Zy**2))*np.sin(3*(Zx**2)*Zy-Zy**3)+c.imag
                
                Zx = xsig
                Zy = ysig
                
                modulo_cuadrado = Zx**2 + Zy**2
                Iter += 1
            # suavizamos fronteras del fractal
            fractal[i, n] = Iter
    return fractal

## Para probar y hacer un fondo de pantalla
width, height = 3840,2160
aspect_ratio = width/height

Imax = 600

y_range = 1.2
x_range = y_range*aspect_ratio

fractal = julia(0, -0.59, width, height, Imax, -x_range, -y_range, x_range, y_range)

plt.imshow(fractal, extent=[Xmin, Xmax, Ymin, Ymax], cmap="magma")

plt.axis('off')

plt.subplots_adjust(left=0, right=1, top=1, bottom=0)

# Guardar
plt.savefig("julia5.png", dpi=900, bbox_inches='tight', pad_inches=0)
print("¡Fondo de pantalla guardado como 'mi_fractal_wallpaper.png'!")
plt.show()