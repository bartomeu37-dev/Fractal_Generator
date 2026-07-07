import numpy as np
import time
import matplotlib.pyplot as plt
from numba import njit, prange

# -------------------------------------------------------------------
# Función principal acelerada con Numba (paralelizada)
# -------------------------------------------------------------------
@njit(parallel=True)
def julia_set(c, max_iter, xmin, xmax, ymin, ymax, ancho, alto):
    """
    Calcula el conjunto de Julia para la constante compleja c.
    Devuelve una matriz con el número de iteraciones en cada píxel.
    
    Parámetros:
        c        : constante compleja (ej. -0.8 + 0.156j)
        max_iter : número máximo de iteraciones
        xmin, xmax, ymin, ymax : región del plano complejo a dibujar
        ancho, alto : resolución de la imagen en píxeles
    """
    # Crear array de salida
    resultado = np.zeros((alto, ancho), dtype=np.int32)
    
    # Tamaño de paso en cada eje
    dx = (xmax - xmin) / (ancho - 1)
    dy = (ymax - ymin) / (alto - 1)
    
    # Recorrer todos los píxeles en paralelo con prange
    for j in prange(alto):
        y = ymax - j * dy   # la coordenada y va de arriba a abajo
        for i in range(ancho):
            x = xmin + i * dx
            z = x + 1j * y   # valor complejo inicial
            n = 0
            # Iterar z = z^2 + c hasta que escape o se alcance max_iter
            while abs(z) <= 2.0 and n < max_iter:
                z = z * z + c
                n += 1
            resultado[j, i] = n
    return resultado


# -------------------------------------------------------------------
# Parámetros y generación
# -------------------------------------------------------------------
if __name__ == "__main__":
    # Constante c característica (cambia aquí para otros fractales)
    c = complex(-0.8, 0.156)   # clásico "conejo" de Julia
    
    # Número máximo de iteraciones (a más iteraciones, más detalle)
    max_iter = 100
    
    # Región del plano complejo que queremos ver
    xmin, xmax = -2.0, 2.0
    ymin, ymax = -1.5, 1.5
    
    # Resolución de la imagen
    ancho, alto = 960, 540
    
    # Calcular el fractal
    print("Calculando conjunto de Julia con Numba...")
    t0 = time.time()
    datos = julia_set(c, max_iter, xmin, xmax, ymin, ymax, ancho, alto)
    t1 = time.time()
    print(f"Tiempo de cálculo: {t1 - t0:.3f} s")
    # Mostrar la imagen
    plt.figure(figsize=(10, 7.5))
    # 'hot', 'twilight_shifted' o 'inferno' suelen dar buenos resultados
    plt.imshow(datos, cmap='hot', extent=[xmin, xmax, ymin, ymax])
    plt.colorbar(label='Iteraciones')
    plt.title(f'Conjunto de Julia para c = {c}')
    plt.xlabel('Re(z)')
    plt.ylabel('Im(z)')
    plt.tight_layout()
    plt.show()