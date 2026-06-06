extends Control

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.12, 0.12, 0.18)
	add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 60)
	margin.add_theme_constant_override("margin_left", 80)
	margin.add_theme_constant_override("margin_right", 80)
	margin.add_theme_constant_override("margin_bottom", 60)
	scroll.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)

	# Título
	var titulo := Label.new()
	titulo.text = "🏁 Relatório Final"
	titulo.add_theme_font_size_override("font_size", 32)
	titulo.add_theme_color_override("font_color", Color.WHITE)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)

	# Totais gerais
	var total := GameManager.historico.size()
	var acertos := GameManager.historico.filter(func(h): return h["correto"]).size()
	var com_dica := GameManager.historico.filter(func(h): return h["usou_dica"]).size()

	var label_geral := Label.new()
	label_geral.text = "Total de exercícios: %d\nAcertos: %d  |  Erros: %d\nUsou dica: %d vez(es)" % [
		total, acertos, total - acertos, com_dica
	]
	label_geral.add_theme_font_size_override("font_size", 20)
	label_geral.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	vbox.add_child(label_geral)

	# Separador
	var sep := HSeparator.new()
	vbox.add_child(sep)

	# Desempenho por método
	var acertos_A := GameManager.historico.filter(func(h): return h["correto"] and h["metodo"] == "A").size()
	var total_A := GameManager.historico.filter(func(h): return h["metodo"] == "A").size()
	var acertos_B := GameManager.historico.filter(func(h): return h["correto"] and h["metodo"] == "B").size()
	var total_B := GameManager.historico.filter(func(h): return h["metodo"] == "B").size()

	var label_metodos := Label.new()
	label_metodos.text = "📐 Método A (Coeficiente Decimal): %d/%d acertos\n📐 Método B (Decomposição): %d/%d acertos" % [
		acertos_A, total_A, acertos_B, total_B
	]
	label_metodos.add_theme_font_size_override("font_size", 18)
	label_metodos.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	vbox.add_child(label_metodos)

	var sep2 := HSeparator.new()
	vbox.add_child(sep2)

	# Desempenho por sessão
	var label_sessoes := Label.new()
	label_sessoes.text = "📅 Desempenho por sessão:"
	label_sessoes.add_theme_font_size_override("font_size", 18)
	label_sessoes.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(label_sessoes)

	for i in range(1, 7):
		var entradas := GameManager.historico.filter(func(h): return h["sessao"] == i)
		if entradas.size() == 0:
			continue
		var ac := entradas.filter(func(h): return h["correto"]).size()
		var label_s := Label.new()
		label_s.text = "  Sessão %d: %d/%d acertos" % [i, ac, entradas.size()]
		label_s.add_theme_font_size_override("font_size", 16)
		label_s.add_theme_color_override("font_color",
			Color(0.4, 0.9, 0.4) if ac == entradas.size() else Color(0.85, 0.85, 0.85)
		)
		vbox.add_child(label_s)

	var sep3 := HSeparator.new()
	vbox.add_child(sep3)

	# Histórico detalhado
	var label_hist := Label.new()
	label_hist.text = "📋 Histórico detalhado:"
	label_hist.add_theme_font_size_override("font_size", 18)
	label_hist.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(label_hist)

	for entrada in GameManager.historico:
		var icone := "✅" if entrada["correto"] else "❌"
		var l := Label.new()
		l.text = "%s S%d [%s] R$%.2f (correto: R$%.2f)%s" % [
			icone,
			entrada["sessao"],
			entrada["metodo"],
			entrada["resposta_dada"],
			entrada["resposta_correta"],
			"  💡" if entrada["usou_dica"] else ""
		]
		l.add_theme_font_size_override("font_size", 14)
		l.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(l)

	var espacador := Control.new()
	espacador.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(espacador)

	# Botão reiniciar
	var btn_reiniciar := Button.new()
	btn_reiniciar.text = "🔄 Jogar novamente"
	btn_reiniciar.custom_minimum_size = Vector2(0, 55)
	btn_reiniciar.add_theme_font_size_override("font_size", 20)
	btn_reiniciar.pressed.connect(func():
		GameManager.sessao_atual_id = 1
		GameManager.historico = []
		GameManager.erros_agendados = []
		GameManager.metodo_atual = "A"
		GameManager.data_inicio = ""
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")
	)
	vbox.add_child(btn_reiniciar)
