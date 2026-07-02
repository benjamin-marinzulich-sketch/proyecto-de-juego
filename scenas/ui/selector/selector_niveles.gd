extends Control

# 1. Haz el truco de arrastrar con Ctrl el nodo PantallaPreview aquí:
@onready var pantalla_preview = $PantallaPreview 

@onready var btn_anterior = $HBoxContainer/BtnAnterior
@onready var btn_iniciar = $HBoxContainer/BtnIniciar
@onready var btn_siguiente = $HBoxContainer/BtnSiguiente

var nivel_seleccionado = 1
var nivel_maximo = 3 

# 2. Precargamos las imágenes de tus niveles (¡Asegúrate de poner tus rutas correctas!)
var img_nivel_1 = preload("res://scenas/ui/assets/preview/preview_nivel1.png")
var img_nivel_2 = preload("res://scenas/ui/assets/preview/preview_nivel2.png")
var img_nivel_3 = preload("res://scenas/ui/assets/preview/preview_nivel3.png")

func _ready():
	actualizar_interfaz() # Actualiza la imagen nada más abrir el selector

# Tus funciones de los botones Siguiente y Anterior deberían sumar o restar nivel_seleccionado y luego llamar a esta función:
func actualizar_interfaz():
	# Este 'match' cambia la imagen de la pantalla dependiendo del nivel
	match nivel_seleccionado:
		1:
			pantalla_preview.texture = img_nivel_1
		2:
			pantalla_preview.texture = img_nivel_3
func _on_btn_iniciar_pressed():
	var ruta_nivel = ""
	
	# Revisamos qué número tiene 'nivel_seleccionado' para armar la ruta
	match nivel_seleccionado:
		1:
			# Ojo aquí: Ajusta el nombre del archivo si le pusiste diferente a Nivel1.tscn
			ruta_nivel = "res://scenas/levels/level1/nivel1.tscn" 
		2:
			ruta_nivel = "res://scenas/levels/level3/nivel3.tscn"
		_:
			print("Error: Nivel no configurado")
			return # Si hay un error, cortamos aquí para que el juego no se cierre
			
	# ¡Cambiamos de canal y viajamos al nivel!
	get_tree().change_scene_to_file(ruta_nivel)


func _on_btn_siguiente_pressed() -> void:
	if nivel_seleccionado < nivel_maximo:
		nivel_seleccionado += 1
		actualizar_interfaz() # Cambia la foto de la tele

func _on_btn_anterior_pressed() -> void:
	if nivel_seleccionado > 1:
		nivel_seleccionado -= 1
		actualizar_interfaz() # Cambia la foto de la tele
