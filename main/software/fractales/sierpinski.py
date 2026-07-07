#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jan 10 17:01:29 2026

@author: barmirled
"""

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
RAMA[0] = 'A'

#@numba.jit(parallel=True)
def generar_sierpinski(iteraciones):
    longitud_actual = 1
    global RAMA,RAMB
    for _ in range(iteraciones):
        ptr_lectura = 0
        ptr_escritura = 0
        while ptr_lectura < longitud_actual:
            if RAMA[ptr_lectura] == 'A':
                RAMB[ptr_escritura] = 'B'
                RAMB[ptr_escritura + 1] = '-'
                RAMB[ptr_escritura + 2] = 'A'
                RAMB[ptr_escritura + 3] = '-'
                RAMB[ptr_escritura + 4] = 'B'
                ptr_escritura += 5
            elif RAMA[ptr_lectura] == 'B':
                RAMB[ptr_escritura] = 'A'
                RAMB[ptr_escritura + 1] = '+'
                RAMB[ptr_escritura + 2] = 'B'
                RAMB[ptr_escritura + 3] = '+'
                RAMB[ptr_escritura + 4] = 'A'
                ptr_escritura += 5
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

# --- Dibujo (Aquí está el cambio clave) ---
def dibujar_sierpinski(instrucciones, distancia):
    for comando in instrucciones:
        # CLAVE: Tanto 'A' como 'B' significan "avanzar"
        if comando == 'A' or comando == 'B':
            turtle.forward(distancia)
        elif comando == '+':
            turtle.left(60)
        elif comando == '-':
            turtle.right(60)

# --- Ejecución ---
it = 6 # Nivel 6 se ve muy bien
instrucciones = generar_sierpinski(it)

turtle.speed(0)
turtle.hideturtle()
# Posicionamos la tortuga para que se vea bien centrado
turtle.penup()
turtle.goto(-200, -200)
turtle.pendown()

dibujar_sierpinski(instrucciones, 5)
turtle.done()