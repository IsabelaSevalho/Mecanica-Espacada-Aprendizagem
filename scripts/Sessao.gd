extends Control

var _btn_principal: PanelContainer = null

const FONTE := preload("res://Fonte/FredokaOne-Regular.ttf")

func _ready() -> void:
	anchor_right  = 1.0
	anchor_bottom = 1.0
	modulate.a   = 0.0   # começa invisível, faz fade-in geral

	var sessao := GameManager.get_sessao_atual()

	# ── Fundo ─────────────────────────────────────────────────────
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.09, 0.09, 0.15)
	add_child(bg)

	# ── Símbolos decorativos leves ─────────────────────────────────
	_adicionar_simbolos()

	# ── Margin + VBox ─────────────────────────────────────────────
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top",    70)
	margin.add_theme_constant_override("margin_left",   80)
	margin.add_theme_constant_override("margin_right",  80)
	margin.add_theme_constant_override("margin_bottom", 60)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 22)
	margin.add_child(vbox)

	# ── Elementos da tela ─────────────────────────────────────────
	var elementos: Array = []

	var notif := _label("🔔 " + sessao["notificacao"], 20, Color(0.4, 0.9, 0.6))
	notif.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(notif)
	elementos.append(notif)

	var label_sessao := _label(
		"Sessão %d de 6  —  %s" % [sessao["id"], _nome_intencao(sessao["intencao"])],
		28, Color.WHITE
	)
	vbox.add_child(label_sessao)
	elementos.append(label_sessao)

	if sessao["lembrete"] != "":
		var lembrete := _label(_texto_lembrete(sessao["lembrete"]), 16, Color(0.7, 0.7, 0.9))
		lembrete.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(lembrete)
		elementos.append(lembrete)

	_espaco(vbox, 10)

	if sessao["intencao"] == "observar":
		_montar_observacao(vbox, elementos)
	else:
		var btn := _criar_botao("COMEÇAR SESSÃO", Color(0.22, 0.15, 0.45), Color(0.85, 0.72, 1.0))
		_conectar_btn(btn, func():
			_sair_para(func():
				GameManager.metodo_atual = "A"
				get_tree().change_scene_to_file("res://scenes/Desafio.tscn")
			)
		)
		_btn_principal = btn
		vbox.add_child(btn)
		elementos.append(btn)

	# ── Fade-in em cascata ────────────────────────────────────────
	await get_tree().process_frame
	_fade_in_tela(elementos)


# ── Tab avança a tela ─────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		get_viewport().set_input_as_handled()
		if _btn_principal != null:
			var btn := _btn_principal.get_meta("btn") as Button
			btn.emit_signal("pressed")


# ── Observação ────────────────────────────────────────────────────

func _montar_observacao(vbox: VBoxContainer, elementos: Array) -> void:
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

	var index   := [0]
	var todos: Array = []

	for p in passos_A:
		var l := _label(p, 18, Color(0.8, 0.6, 1.0))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		l.modulate.a   = 0.0
		vbox.add_child(l)
		todos.append(l)

	for p in passos_B:
		var l := _label(p, 18, Color(0.4, 0.9, 0.9))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		l.modulate.a   = 0.0
		vbox.add_child(l)
		todos.append(l)

	var btn_proximo := _criar_botao("PRÓXIMO PASSO ▶", Color(0.10, 0.28, 0.20), Color(0.35, 0.95, 0.60))
	_btn_principal = btn_proximo
	vbox.add_child(btn_proximo)
	elementos.append(btn_proximo)

	# Pega referências internas do card
	var btn_proximo_btn  := btn_proximo.get_meta("btn") as Button
	var btn_proximo_lbl  := btn_proximo.get_child(0) as Label

	var terminou := [false]

	btn_proximo_btn.pressed.connect(func():
		if terminou[0]:
			return
		if index[0] < todos.size():
			_revelar_label(todos[index[0]])
			index[0] += 1
		if index[0] >= todos.size():
			terminou[0] = true
			btn_proximo_lbl.text = "IR PARA PRÓXIMA SESSÃO ▶"
	)

	# botão de navegação só ativo após terminar todos os passos
	btn_proximo_btn.pressed.connect(func():
		if not terminou[0]:
			return
		_sair_para(func():
			GameManager.sessao_atual_id = 2
			get_tree().change_scene_to_file("res://scenes/Sessao.tscn")
		)
	)


# ── Animações ─────────────────────────────────────────────────────

func _fade_in_tela(elementos: Array) -> void:
	# Fade geral da tela
	var tg := create_tween()
	tg.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tg.tween_property(self, "modulate:a", 1.0, 0.35)

	# Cada elemento entra com delay em cascata
	for i in elementos.size():
		var el: Control = elementos[i]
		el.modulate.a = 0.0
		el.position.y += 18
		await get_tree().create_timer(0.08 + i * 0.07).timeout
		var t := create_tween()
		t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		t.tween_property(el, "modulate:a", 1.0, 0.30)
		t.parallel().tween_property(el, "position:y", el.position.y - 18, 0.30)


func _revelar_label(lbl: Label) -> void:
	lbl.position.x -= 12
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(lbl, "modulate:a", 1.0, 0.28)
	t.parallel().tween_property(lbl, "position:x", lbl.position.x + 12, 0.28)


func _sair_para(callback: Callable) -> void:
	var t := create_tween()
	t.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "modulate:a", 0.0, 0.22)
	await t.finished
	callback.call()


# ── Botão estilizado com hover ────────────────────────────────────

func _criar_botao(texto: String, bg: Color, cor_texto: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 62)

	var style := StyleBoxFlat.new()
	style.bg_color    = bg
	style.border_color = bg.lightened(0.15)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left   = 28
	style.content_margin_right  = 28
	style.content_margin_top    = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)

	var lbl := _label(texto, 20, cor_texto)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(lbl)

	# botão invisível
	var btn := Button.new()
	btn.name = "Btn"
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.flat = true
	var vazio := StyleBoxEmpty.new()
	for s in ["normal","hover","pressed","focus"]:
		btn.add_theme_stylebox_override(s, vazio)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	btn.mouse_entered.connect(func():
		var t := create_tween()
		t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		t.tween_property(panel, "position:y", panel.position.y - 5, 0.16)
		var ts := create_tween()
		ts.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		ts.tween_method(func(v:Color): style.bg_color = v, style.bg_color, bg.lightened(0.12), 0.16)
	)
	btn.mouse_exited.connect(func():
		var t := create_tween()
		t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		t.tween_property(panel, "position:y", panel.position.y + 5, 0.20)
		var ts := create_tween()
		ts.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		ts.tween_method(func(v:Color): style.bg_color = v, style.bg_color, bg, 0.20)
	)

	panel.add_child(btn)
	# expõe o sinal pressed pelo meta
	panel.set_meta("btn", btn)
	return panel


# ── Símbolos decorativos ──────────────────────────────────────────

func _adicionar_simbolos() -> void:
	var simbolos := [
		["%",   0.04, 0.10, 48, 0.08],
		["×",   0.91, 0.15, 42, 0.07],
		["÷",   0.07, 0.75, 44, 0.07],
		["+",   0.85, 0.70, 46, 0.07],
		["5/7", 0.88, 0.88, 36, 0.06],
	]
	for s in simbolos:
		var lbl := Label.new()
		lbl.text = s[0]
		lbl.add_theme_font_override("font", FONTE)
		lbl.add_theme_font_size_override("font_size", int(s[3]))
		lbl.add_theme_color_override("font_color", Color(1,1,1, float(s[4])))
		add_child(lbl)
		await get_tree().process_frame
		lbl.position = Vector2(
			get_viewport_rect().size.x * float(s[1]),
			get_viewport_rect().size.y * float(s[2])
		)
		_float_loop(lbl)


func _float_loop(node: Control) -> void:
	var origem    := node.position
	var amplitude := randf_range(6.0, 13.0)
	var periodo   := randf_range(3.0, 5.5)
	while is_instance_valid(node):
		var t := create_tween()
		t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		t.tween_property(node, "position:y", origem.y - amplitude, periodo * 0.5)
		await t.finished
		t = create_tween()
		t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		t.tween_property(node, "position:y", origem.y, periodo * 0.5)
		await t.finished


# ── Utilitários ───────────────────────────────────────────────────

func _conectar_btn(panel: PanelContainer, callback: Callable) -> void:
	var btn := panel.get_meta("btn") as Button
	btn.pressed.connect(callback)


func _label(texto: String, tamanho: int, cor: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_override("font", FONTE)
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", cor)
	return l


func _espaco(parent: Control, altura: int) -> void:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, altura)
	parent.add_child(s)


func _nome_intencao(intencao: String) -> String:
	match intencao:
		"observar":    return "Observar"
		"completar":   return "Completar os passos"
		"apoio":       return "Resolver com apoio"
		"sem_apoio":   return "Resolver sem apoio"
		"transferir":  return "Transferir"
		"autonomia":   return "Autonomia total"
	return ""


func _texto_lembrete(chave: String) -> String:
	match chave:
		"resumo_s1":    return "📖 Lembrete: Método A → divida % por 100 e multiplique. Método B → decomponha em 10% e some."
		"resumo_s1_s2": return "📖 Lembrete: você já praticou os dois métodos. Desta vez pode pedir dica se precisar."
	return ""
