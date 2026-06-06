extends Control

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var sessao := GameManager.get_sessao_atual()

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

	# Notificação estilo Duolingo
	var notif := Label.new()
	notif.text = "🔔 " + sessao["notificacao"]
	notif.add_theme_font_size_override("font_size", 20)
	notif.add_theme_color_override("font_color", Color(0.4, 0.9, 0.6))
	notif.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(notif)

	# Número e intenção da sessão
	var label_sessao := Label.new()
	label_sessao.text = "Sessão %d de 6  —  %s" % [sessao["id"], _nome_intencao(sessao["intencao"])]
	label_sessao.add_theme_font_size_override("font_size", 26)
	label_sessao.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(label_sessao)

	# Lembrete se houver
	if sessao["lembrete"] != "":
		var lembrete := Label.new()
		lembrete.text = _texto_lembrete(sessao["lembrete"])
		lembrete.add_theme_font_size_override("font_size", 16)
		lembrete.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9))
		lembrete.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(lembrete)

	var espacador := Control.new()
	espacador.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(espacador)

	# Sessão 1 é só observação — mostra demonstração
	if sessao["intencao"] == "observar":
		_montar_observacao(vbox)
	else:
		var btn := Button.new()
		btn.text = "COMEÇAR SESSÃO"
		btn.custom_minimum_size = Vector2(0, 55)
		btn.add_theme_font_size_override("font_size", 20)
		btn.pressed.connect(func():
			GameManager.metodo_atual = "A"
			get_tree().change_scene_to_file("res://scenes/Desafio.tscn")
		)
		vbox.add_child(btn)

func _montar_observacao(vbox: VBoxContainer) -> void:
	var passos_A := [
		"Exemplo — Método A (Coeficiente Decimal):",
		"Quanto é 25% de R$80?",
		"Passo 1: 25 ÷ 100 = 0,25",
        "Passo 2: 0,25 × 80 = R$20,00 ✅"
	]
	var passos_B := [
		"Exemplo — Método B (Decomposição):",
		"Quanto é 25% de R$80?",
		"10% de 80 = 8  |  10% de 80 = 8  |  5% de 80 = 4",
        "8 + 8 + 4 = R$20,00 ✅"
	]

	var index := [0]
	var labels_A: Array = []
	var labels_B: Array = []

	for p in passos_A:
		var l := Label.new()
		l.text = p
		l.add_theme_font_size_override("font_size", 18)
		l.add_theme_color_override("font_color", Color(0.8, 0.6, 1.0))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		l.visible = false
		vbox.add_child(l)
		labels_A.append(l)

	for p in passos_B:
		var l := Label.new()
		l.text = p
		l.add_theme_font_size_override("font_size", 18)
		l.add_theme_color_override("font_color", Color(0.4, 0.9, 0.9))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		l.visible = false
		vbox.add_child(l)
		labels_B.append(l)

	var todos := labels_A + labels_B
	var btn_proximo := Button.new()
	btn_proximo.text = "PRÓXIMO PASSO ▶"
	btn_proximo.custom_minimum_size = Vector2(0, 50)
	btn_proximo.add_theme_font_size_override("font_size", 18)
	vbox.add_child(btn_proximo)

	btn_proximo.pressed.connect(func():
		if index[0] < todos.size():
			todos[index[0]].visible = true
			index[0] += 1
		if index[0] >= todos.size():
			btn_proximo.text = "IR PARA PRÓXIMA SESSÃO ▶"
			btn_proximo.pressed.disconnect(btn_proximo.pressed.get_connections()[0]["callable"])
			btn_proximo.pressed.connect(func():
				GameManager.sessao_atual_id = 2
				get_tree().change_scene_to_file("res://scenes/Sessao.tscn")
			)
	)

func _nome_intencao(intencao: String) -> String:
	match intencao:
		"observar": return "Observar"
		"completar": return "Completar os passos"
		"apoio": return "Resolver com apoio"
		"sem_apoio": return "Resolver sem apoio"
		"transferir": return "Transferir"
		"autonomia": return "Autonomia total"
	return ""

func _texto_lembrete(chave: String) -> String:
	match chave:
		"resumo_s1": return "📖 Lembrete: Método A → divida % por 100 e multiplique. Método B → decomponha em 10% e some."
		"resumo_s1_s2": return "📖 Lembrete: você já praticou os dois métodos. Desta vez pode pedir dica se precisar."
	return ""
