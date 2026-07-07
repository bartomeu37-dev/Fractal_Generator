#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Dec 27 20:39:55 2025

@author: barmirled
"""

import numpy as np
import matplotlib.pyplot as plt
import numba
import turtle

# la libreria turtle es para dibujar en la pantalla
# la libreria numba es para compilar python y que no tarde 1 hora en hacer las cosas

# creamos un objeto turtle
#t = turtle.Turtle()

# suponemos que tenemos dos RAMs para guardar la lista anterior y luego la lista nueva
RAM_lenght = 10000
RAMA=['']*RAM_lenght # cadena a leer
RAMB=['']*RAM_lenght # cadena a escribir

# declaramos axioma principal
RAMA[0] = 'F'

#@numba.jit(parallel=True)
def generar_l_system_k(iteraciones):
    longitud_actual = 1
    global RAMA,RAMB
    for _ in range(iteraciones):
        ptr_lectura = 0
        ptr_escritura = 0
        while ptr_lectura < longitud_actual:
            if RAMA[ptr_lectura] == 'F':
                RAMB[ptr_escritura] = 'F'
                RAMB[ptr_escritura + 1] = '+'
                RAMB[ptr_escritura + 2] = 'F'
                RAMB[ptr_escritura + 3] = '-'
                RAMB[ptr_escritura + 4] = '-'
                RAMB[ptr_escritura + 5] = 'F'
                RAMB[ptr_escritura + 6] = '+'
                RAMB[ptr_escritura + 7] = 'F'
                ptr_escritura += 8
            elif RAMA[ptr_lectura] == '+':
                RAMB[ptr_escritura] = '+'
                ptr_escritura += 1
            elif RAMA[ptr_lectura] == '-':
                RAMB[ptr_escritura] = '-'
                ptr_escritura += 1
            ptr_lectura += 1
        longitud_actual = ptr_escritura
        RAMA = list(RAMB)
        RAMB = [''] * RAM_lenght
    return RAMA[:longitud_actual]

def dibujar_l_system(instrucciones, angulo, distancia):
    """
    Interpreta la cadena de la RAM y la mueve la tortuga.
    """
    for comando in instrucciones:
        if comando == 'F':
            turtle.forward(distancia)
        elif comando == '+':
            turtle.left(angulo)
        elif comando == '-':
            turtle.right(angulo)

#-------------------------------------------------------------------------------------------------------------
# --- Configuración Visual ---
turtle.speed(0)          # Velocidad máxima de animación
turtle.hideturtle()      # Esconde el icono de la tortuga
turtle.delay(0)          # Elimina el retraso entre trazos (muy importante para fractales)

# Posicionar la tortuga al inicio (como centrar el cursor en una pantalla)
turtle.penup()
turtle.goto(-300, 0) 
turtle.pendown()

# --- Parámetros del Fractal ---
iteraciones = 6
angulo_koch = 60         # Ángulo para la curva de Koch
# Ajustar la longitud del paso: a más iteraciones, pasos más cortos para que quepa
distancia_paso = 3000 / (3**iteraciones) 

# --- Ejecución ---
# Suponiendo que 'resultado' es lo que devuelve tu función generar_l_system_k
resultado = generar_l_system_k(iteraciones)

dibujar_l_system(resultado, angulo_koch, distancia_paso)

# Mantener la ventana abierta al finalizar
turtle.done()
resultado = generar_l_system_k(4)

#turtle.done()