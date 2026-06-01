extends Control

var questao := {}

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	questao = GameManager.proxima_questao()
	
	# Fundo
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
	vbox.add_theme_constant_override("separation", 24)
	margin.add_child(vbox)
	
	var label_nivel := Label.new()
	label_nivel.text = "Nível %d — Tentativa #%d" % [GameManager.nivel_atual, GameManager.tentativa_atual]
	label_nivel.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	label_nivel.add_theme_font_size_override("font_size", 18)
	vbox.add_child(label_nivel)
	
	var label_enunciado := Label.new()
	label_enunciado.text = questao["enunciado"]
	label_enunciado.autowrap_mode = TextServer.AUTOWRAP_WORD
	label_enunciado.add_theme_font_size_override("font_size", 26)
	label_enunciado.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(label_enunciado)
	
	var input := LineEdit.new()
	input.placeholder_text = "Digite sua resposta (ex: 60.00)"
	input.add_theme_font_size_override("font_size", 22)
	input.custom_minimum_size = Vector2(0, 50)
	input.name = "Input"
	vbox.add_child(input)
	
	var label_erro := Label.new()
	label_erro.text = ""
	label_erro.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	label_erro.name = "LabelErro"
	vbox.add_child(label_erro)
	
	var btn := Button.new()
	btn.text = "CONFIRMAR"
	btn.custom_minimum_size = Vector2(0, 55)
	btn.add_theme_font_size_override("font_size", 20)
	btn.pressed.connect(func(): _ao_confirmar(input, label_erro))
	vbox.add_child(btn)

func _ao_confirmar(input: LineEdit, label_erro: Label) -> void:
	var texto: String = input.text.strip_edges().replace(",", ".")
	
	if not texto.is_valid_float():
		label_erro.text = "⚠ Digite apenas números (ex: 60.00)"
		return
	
	var resposta_dada: float = float(texto)
	var resposta_correta: float = questao["resposta"]
	var correto: bool = abs(resposta_dada - resposta_correta) < 0.01
	
	GameManager.registrar_resposta(resposta_dada, correto)
	GameManager.ultimo_resultado = {
		"correto": correto,
		"resposta_dada": resposta_dada,
		"resposta_correta": resposta_correta,
		"enunciado": questao["enunciado"]
	}
	
	get_tree().change_scene_to_file("res://scenes/Feedback.tscn")
