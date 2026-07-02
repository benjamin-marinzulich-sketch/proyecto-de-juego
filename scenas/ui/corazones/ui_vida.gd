extends CanvasLayer

@onready var corazones: Array[TextureRect] = [
	$Anclaje/Corazones/Corazon1,
	$Anclaje/Corazones/Corazon2,
	$Anclaje/Corazones/Corazon3
]

var tom_ref = null


func _ready() -> void:
	# Reutilizamos el mismo grupo "player" que ya usa Edna para encontrar a Tom
	var jugadores = get_tree().get_nodes_in_group("player")
	if jugadores.size() > 0:
		tom_ref = jugadores[0]
		tom_ref.vida_cambiada.connect(_on_vida_cambiada)
		print("✅ UI de vida conectada a Tom")
	else:
		push_warning("⚠️ UIVida no encontró a Tom. ¿Está en el grupo 'player'?")


func _on_vida_cambiada(nueva_vida: int) -> void:
	# nueva_vida baja de 3 a 0. Apagamos corazones de derecha a izquierda.
	for i in range(corazones.size()):
		var corazon = corazones[i]
		var deberia_estar_visible = i < nueva_vida

		if not deberia_estar_visible and corazon.visible:
			_desaparecer_corazon(corazon)
		elif deberia_estar_visible and not corazon.visible:
			# Por si reiniciás vida en algún momento (power-up, etc.)
			corazon.visible = true
			corazon.modulate.a = 1.0
			corazon.scale = Vector2.ONE


func _desaparecer_corazon(corazon: TextureRect) -> void:
	var tween = create_tween()
	tween.set_parallel(true)

	# Un pequeño "pop" hacia arriba y afuera antes de desvanecerse
	tween.tween_property(corazon, "scale", Vector2(1.5, 1.5), 0.1) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(corazon, "modulate:a", 0.0, 0.3).set_delay(0.05)
	tween.tween_property(corazon, "position:y", corazon.position.y - 10, 0.35) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.chain().tween_callback(func() -> void:
		corazon.visible = false
	)
