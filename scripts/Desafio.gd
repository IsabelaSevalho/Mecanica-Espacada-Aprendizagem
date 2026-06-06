extends Control

var exercicio := {}
var usou_dica := false

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var sessao := GameManager.get_sessao_atual()
	exercicio = GameManager.get_exercicio(GameManager.metodo_atual, sessao["intencao"])

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.12, 0.12, 0.18)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 60)
	margin.add_theme_constant_override("margin_left", 80)
	margin.add_theme_constant_override("margin_right", 80)
	margin.add_theme_constant_override("margin_bottom", 60)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	# Tag do método
	var tag := Label.new()
	tag.text = "Método %s  —  Sessão %d  —  %s" % [
		GameManager.metodo_atual,
		GameManager.sessao_atual_id,
		_nome_metodo(GameManager.metodo_atual)
	]
	tag.add_theme_font_size_override("font_size", 16)
	tag.add_theme_color_override("font_color",
		Color(0.8, 0.6, 1.0) if GameManager.metodo_atual == "A" else Color(0.4, 0.9, 0.9)
	)
	vbox.add_child(tag)

	# Enunciado
	var enunciado := Label.new()
	enunciado.text = exercicio.get("enunciado", "")
	enunciado.add_theme_font_size_override("font_size", 24)
	enunciado.add_theme_color_override("font_color", Color.WHITE)
	enunciado.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(enunciado)

	# Campo de resposta
	var input := LineEdit.new()
	input.placeholder_text = "Digite sua resposta (ex: 15.00)"
	input.add_theme_font_size_override("font_size", 22)
	input.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(input)

	# Label de erro
	var label_erro := Label.new()
	label_erro.text = ""
	label_erro.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	vbox.add_child(label_erro)

	# Botão de dica (só aparece se a sessão permite)
	var sessao_intencao: String = sessao["intencao"]
	if sessao_intencao == "apoio" and exercicio.get("dica", "") != "":
		var btn_dica := Button.new()
		btn_dica.text = "💡 Ver dica"
		btn_dica.custom_minimum_size = Vector2(0, 40)
		btn_dica.pressed.connect(func():
			usou_dica = true
			label_erro.text = exercicio["dica"]
			label_erro.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		)
		vbox.add_child(btn_dica)

	# Botão confirmar
	var btn := Button.new()
	btn.text = "CONFIRMAR"
	btn.custom_minimum_size = Vector2(0, 55)
	btn.add_theme_font_size_override("font_size", 20)
	btn.pressed.connect(func(): _ao_confirmar(input, label_erro))
	vbox.add_child(btn)

func _ao_confirmar(input: LineEdit, label_erro: Label) -> void:
	var texto: String = input.text.strip_edges().replace(",", ".")

	if not texto.is_valid_float():
		label_erro.text = "⚠ Digite apenas números (ex: 15.00)"
		label_erro.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		return

	var resposta_dada: float = float(texto)
	var resposta_correta: float = exercicio.get("resposta", 0.0)
	var correto: bool = abs(resposta_dada - resposta_correta) < 0.01

	GameManager.registrar_resposta(exercicio, resposta_dada, correto, usou_dica)

	GameManager.ultimo_resultado = {
		"correto": correto,
		"resposta_dada": resposta_dada,
		"resposta_correta": resposta_correta,
		"enunciado": exercicio.get("enunciado", ""),
		"metodo": GameManager.metodo_atual,
		"dica": exercicio.get("dica", ""),
		"usou_dica": usou_dica
	}

	get_tree().change_scene_to_file("res://scenes/Feedback.tscn")

func _nome_metodo(m: String) -> String:
	return "Coeficiente Decimal" if m == "A" else "Decomposição"
