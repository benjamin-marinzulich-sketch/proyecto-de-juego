extends Control

@onready var btn_anterior = $HBoxContainer/BtnAnterior
@onready var btn_iniciar = $HBoxContainer/BtnIniciar
@onready var btn_siguiente = $HBoxContainer/BtnSiguiente

var nivel_seleccionado = 1
var nivel_maximo = 5 # Cambia esto a tu cantidad total de niveles

# Este diccionario simula tu sistema de guardado.
# true = desbloqueado (jefe anterior derrotado), false = bloqueado
# En un juego completo, esto debería estar en un Autoload (Global.gd)
var progreso_niveles = {
	1: true,  # El nivel 1 siempre está desbloqueado
	2: false, # Bloqueado hasta vencer al jefe del nivel 1
	3: false,
	4: false,
	5: false
}

func _ready():
	# Conectamos las señales de los botones mediante código
	btn_anterior.pressed.connect(_on_btn_anterior_pressed)
	btn_siguiente.pressed.connect(_on_btn_siguiente_pressed)
	btn_iniciar.pressed.connect(_on_btn_iniciar_pressed)
	
	actualizar_interfaz()

func _on_btn_anterior_pressed():
	if nivel_seleccionado > 1:
		nivel_seleccionado -= 1
		actualizar_interfaz()

func _on_btn_siguiente_pressed():
	if nivel_seleccionado < nivel_maximo:
		nivel_seleccionado += 1
		actualizar_interfaz()

func actualizar_interfaz():
	# Lógica principal de bloqueo
	if progreso_niveles[nivel_seleccionado]:
		# Si está desbloqueado
		btn_iniciar.disabled = false
		btn_iniciar.text = "Jugar Nivel " + str(nivel_seleccionado)
	else:
		# Si el jefe anterior no ha sido derrotado
		btn_iniciar.disabled = true
		btn_iniciar.text = "Bloqueado (Derrota al Jefe)"

func _on_btn_iniciar_pressed():
	print("Cargando el nivel ", nivel_seleccionado, "...")
	# Aquí cargas tu escena:
	# get_tree().change_scene_to_file("res://Nivel_" + str(nivel_seleccionado) + ".tscn")
