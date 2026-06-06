extends Control

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.12, 0.12, 0.18)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 100)
	margin.add_theme_constant_override("margin_left", 100)
	margin.add_theme_constant_override("margin_right", 100)
	margin.add_theme_constant_override("margin_bottom", 100)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 30)
	margin.add_child(vbox)

	var titulo := Label.new()
	titulo.text = "Método do Coeficiente Decimal"
	titulo.add_theme_font_size_override("font_size", 32)
	titulo.add_theme_color_override("font_color", Color.WHITE)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)

	var subtitulo := Label.new()
	subtitulo.text = "Como você quer jogar?"
	subtitulo.add_theme_font_size_override("font_size", 20)
	subtitulo.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9))
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitulo)

	var espacador := Control.new()
	espacador.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(espacador)

	var btn_real := Button.new()
	btn_real.text = "📅  Modo Real  (sessões por dias)"
	btn_real.custom_minimum_size = Vector2(0, 60)
	btn_real.add_theme_font_size_override("font_size", 20)
	btn_real.pressed.connect(func():
		GameManager.modo_demonstracao = false
		ir_para_sessao()
	)
	vbox.add_child(btn_real)

	var btn_demo := Button.new()
	btn_demo.text = "⚡  Modo Demonstração  (todas as sessões liberadas)"
	btn_demo.custom_minimum_size = Vector2(0, 60)
	btn_demo.add_theme_font_size_override("font_size", 20)
	btn_demo.pressed.connect(func():
		GameManager.modo_demonstracao = true
		ir_para_sessao()
	)
	vbox.add_child(btn_demo)

func ir_para_sessao() -> void:
	get_tree().change_scene_to_file("res://scenes/Sessao.tscn")
