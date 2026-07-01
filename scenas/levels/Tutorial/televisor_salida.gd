extends StaticBody2D

@onready var pantalla_blanca = $CanvasLayer/ColorRect
var ruta_seleccion_nivel = "res://scenas/ui/selector/SelectorNiveles.tscn"
var ya_golpeado = false

# Esta es exactamente la función que Tom está buscando con su bate
func recibir_danio(cantidad_danio: int) -> void:
	# Si ya lo golpeamos, ignoramos el resto para no repetir el efecto
	if ya_golpeado:
		return
		
	ya_golpeado = true
	
	# Desactivamos la colisión para que Tom pueda pasar de largo tras romperlo
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Hacemos la animación del fundido a blanco
	var tween = create_tween()
	tween.tween_property(pantalla_blanca, "modulate:a", 1.0, 0.5)
	
	# Cuando termine el fundido (0.5 seg), cambiamos de escena
	tween.tween_callback(cambiar_de_escena)

func cambiar_de_escena():
	get_tree().change_scene_to_file(ruta_seleccion_nivel)
