extends CanvasLayer

# --- CONTENEDORES ---
@onready var contenedor_principal = $VBoxContainer
@onready var contenedor_opciones = $ContenedorOpciones

# --- BOTONES PRINCIPALES ---
@onready var btn_continuar = $VBoxContainer/BtnContinuar
@onready var btn_opciones = $VBoxContainer/BtnOpciones
@onready var btn_salir = $VBoxContainer/BtnSalir
@onready var btn_home = $VBoxContainer/BtnHome

# --- ELEMENTOS DE OPCIONES ---
@onready var btn_volver = $ContenedorOpciones/Btnvolver
@onready var slider_volumen = $ContenedorOpciones/SliderVolumen

func _ready():
	hide() # Oculta todo el menú al inicio
	
	# Estado por defecto: Mostrar principal, ocultar opciones
	contenedor_principal.show()
	contenedor_opciones.hide()
	
	# Conexión de botones principales (asumiendo que ya los conectaste desde el editor o aquí)
	btn_continuar.pressed.connect(_on_btn_continuar_pressed)
	btn_home.pressed.connect(_on_btn_home_pressed)
	btn_opciones.pressed.connect(_on_btn_opciones_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	
	# Conexión de opciones
	btn_volver.pressed.connect(_on_btn_volver_pressed)
	slider_volumen.value_changed.connect(_on_slider_volumen_value_changed)
	
	# Configuración del volumen (-30 decibelios es casi silencio, 0 es normal)
	slider_volumen.min_value = -30.0
	slider_volumen.max_value = 0.0
	slider_volumen.value = 0.0

# --- CONTROL DEL MENÚ ---
func activar_pausa():
	contenedor_principal.show()
	contenedor_opciones.hide()
	show()
	get_tree().paused = true

func _on_btn_continuar_pressed():
	hide()
	get_tree().paused = false

func _on_btn_home_pressed():
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://scenas/ui/menu principal/Menuprincipal.tscn") # Pon tu ruta real
	hide()
	
func _on_btn_salir_pressed():
	get_tree().quit()

# --- LÓGICA DE OPCIONES ---
func _on_btn_opciones_pressed():
	# Oculta tus 4 botones y muestra el slider
	contenedor_principal.hide()
	contenedor_opciones.show()

func _on_btn_volver_pressed():
	# Oculta el slider y vuelve a mostrar tus 4 botones
	contenedor_opciones.hide()
	contenedor_principal.show()

func _on_slider_volumen_value_changed(value: float):
	# Ajusta el volumen del juego
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, value)
	
	# Si se baja al mínimo, lo mutea completamente
	if value <= slider_volumen.min_value:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)


func _on_btnvolver_pressed() -> void:
	pass # Replace with function body.
	
func _input(event):
	if event.is_action_pressed("pausa"):
		if get_tree().paused:
			_on_btn_continuar_pressed()
		else:
			activar_pausa()
