#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jan 10 17:44:35 2026

@author: barmirled
"""

import random as rd
import matplotlib.pyplot as plt

def helecho(iteraciones):
    x, y = 0, 0
    puntos_x, puntos_y = [], []
    
    for _ in range(iteraciones):
        r = rd.random()
        if r < 0.01:
            x = 0
            y = 0.16*y
        elif 0.01 <= r < 0.86:
            x = 0.85*x + 0.04*y
            y = -0.04*x + 0.85*y + 1.6
        elif 0.86 <= r < 0.929:
            x = 0.2*x - 0.26*y
            y = 0.23*x + 0.22*y + 1.6
        elif 0.929 <= r < 1:
            x = -0.15*x + 0.28*y
            y = 0.26*x + 0.24*y + 0.44
        
        puntos_x.append(x)
        puntos_y.append(y)
    
    return(puntos_x,puntos_y)

# Dibujo
px, py = helecho(100000)
plt.scatter(px, py, s=0.1, color='green')
plt.show()