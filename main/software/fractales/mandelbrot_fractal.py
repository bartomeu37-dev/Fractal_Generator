#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec 26 20:11:02 2025

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
def mandel(xlen, ylen, Imax, Xmin, Ymin, Xmax, Ymax):
    # x parte real del plano complejo
    # y parte imaginaria del plano complejo
    x = np.linspace(Xmin, Xmax, xlen)
    y = np.linspace(Ymin, Ymax, ylen)

    # matriz fractal donde guardamos los valores de las iteraciones
    fractal = np.full((len(y), len(x)), Imax, dtype = int) #creamos una matriz de 2 dimensiones donde el valor maximo es Imax
    
    
    for i in range(len(y)):
        for n in range(len(x)):
            Iter = 0    #creamos y borramos las variables para los calculos 
            Zy = y[i]
            Zx = x[n]
            modulo_cuadrado = Zx**2 + Zy**2
            
            while Iter < Imax and modulo_cuadrado < 4:
                xsig = Zx**2 - Zy**2 + x[n]
                ysig = 2*Zx*Zy + y[i]
                
                Zx = xsig
                Zy = ysig
                
                modulo_cuadrado = Zx**2 + Zy**2
                Iter = Iter + 1
            # suavizamos fronteras del fractal
            fractal[i, n] = Iter
    return fractal

fractal = mandel(1920, 1080, 300, Xmin, Ymin, Xmax, Ymax)

plt.imshow(fractal, extent=[Xmin, Xmax, Ymin, Ymax], cmap="magma")