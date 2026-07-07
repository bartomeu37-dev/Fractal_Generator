import turtle

# ------------------------------------------------------------
# Solución al error Terminator en ejecuciones repetidas
# ------------------------------------------------------------
def reiniciar_turtle_si_terminado():
    """
    Si el módulo turtle está en estado 'terminado' porque la ventana
    se cerró antes, lo reinicia para poder usarlo de nuevo.
    """
    try:
        # Forzamos un acceso a la pantalla para provocar Terminator si ocurrió
        turtle.Screen()
    except turtle.Terminator:
        # Reiniciamos la variable interna que controla el estado
        turtle.TurtleScreen._RUNNING = True
        # Creamos una nueva pantalla
        turtle.Screen().clearscreen()

# Aplica el reinicio antes de cualquier otra instrucción de turtle
reiniciar_turtle_si_terminado()

# ------------------------------------------------------------
# Funciones originales del L-System
# ------------------------------------------------------------
def aplicar_reglas(axioma, reglas, iteraciones):
    """Expande el axioma según las reglas de producción."""
    cadena = axioma
    for _ in range(iteraciones):
        nueva = ""
        for caracter in cadena:
            nueva += reglas.get(caracter, caracter)
        cadena = nueva
    return cadena

def dibujar_lsystem(comandos, angulo, paso):
    """Interpreta los comandos y dibuja con la tortuga."""
    pila = []
    t = turtle.Turtle()
    t.speed(0)
    t.hideturtle()
    turtle.tracer(0, 0)

    for c in comandos:
        if c in ('F', 'G'):
            t.forward(paso)
        elif c == 'f':
            t.penup()
            t.forward(paso)
            t.pendown()
        elif c == '+':
            t.right(angulo)
        elif c == '-':
            t.left(angulo)
        elif c == '[':
            pila.append((t.position(), t.heading()))
        elif c == ']':
            pos, orient = pila.pop()
            t.penup()
            t.setposition(pos)
            t.setheading(orient)
            t.pendown()
    turtle.update()
    turtle.done()

# ------------------------------------------------------------
# Configuración del fractal (planta clásica)
# ------------------------------------------------------------
axioma = "X"
reglas = {
    "X": "F-[[X]+X]+F[+FX]-X",
    "F": "FF"
}
angulo = 25
paso = 5
iteraciones = 5

secuencia = aplicar_reglas(axioma, reglas, iteraciones)
print("Longitud de la secuencia:", len(secuencia))

# Posición inicial y orientación
turtle.setup(800, 800)
turtle.bgcolor("white")
turtle.penup()
turtle.goto(0, -300)
turtle.pendown()
turtle.left(90)   # apunta hacia arriba

dibujar_lsystem(secuencia, angulo, paso)