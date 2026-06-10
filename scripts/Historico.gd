extends Control

var _btn_principal: PanelContainer = null

const FONTE := preload("res://Fonte/FredokaOne-Regular.ttf")

func _ready() -> void:
	anchor_right  = 1.0
	anchor_bottom = 1.0
	modulate.a   = 0.0

	# ── Fundo ─────────────────────────────────────────────────────
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.09, 0.09, 0.15)
	add_child(bg)

	_adicionar_simbolos()

	# ── Layout principal ──────────────────────────────────────────
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top",    60)
	margin.add_theme_constant_override("margin_left",   70)
	margin.add_theme_constant_override("margin_right",  70)
	margin.add_theme_constant_override("margin_bottom", 60)
	add_child(margin)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 0)
	margin.add_child(outer)

	var elementos: Array = []

	# ── Cabeçalho ─────────────────────────────────────────────────
	var titulo := _label("📊 Histórico de Tentativas", 34, Color.WHITE)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(titulo)
	elementos.append(titulo)

	_espaco(outer, 6)

	# Resumo rápido
	var total   := GameManager.historico.size()
	var acertos := GameManager.historico.filter(func(e): return e["correto"]).size()
	var txt_resumo := "0 tentativas ainda" if total == 0 \
		else "%d tentativa%s  •  %d ✅  •  %d ❌" % [
			total, "s" if total > 1 else "",
			acertos, total - acertos
		]
	var resumo := _label(txt_resumo, 17, Color(0.60, 0.60, 0.75))
	resumo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(resumo)
	elementos.append(resumo)

	_espaco(outer, 28)

	# ── Área rolável ───────────────────────────────────────────────
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	elementos.append(scroll)

	var lista := VBoxContainer.new()
	lista.add_theme_constant_override("separation", 10)
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(lista)

	if GameManager.historico.is_empty():
		var vazio := _label("Nenhuma tentativa registrada ainda.", 18, Color(0.50, 0.50, 0.65))
		vazio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lista.add_child(vazio)
	else:
		for i in GameManager.historico.size():
			var entrada: Dictionary = GameManager.historico[i]
			lista.add_child(_criar_card_entrada(entrada, i + 1))

	_espaco(outer, 20)

	# ── Botão voltar ──────────────────────────────────────────────
	_btn_principal = _criar_botao("← VOLTAR", Color(0.14, 0.12, 0.24), Color(0.75, 0.65, 1.0))
	_conectar_btn(_btn_principal, func():
		_sair_para(func():
			get_tree().change_scene_to_file("res://scenes/Desafio.tscn")
		)
	)
	outer.add_child(_btn_principal)
	elementos.append(_btn_principal)

	# ── Fade-in cascata ───────────────────────────────────────────
	await get_tree().process_frame
	_fade_in_tela(elementos)


# ── Tab avança a tela ─────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		get_viewport().set_input_as_handled()
		(_btn_principal.get_meta("btn") as Button).emit_signal("pressed")


# ── Card de cada entrada ──────────────────────────────────────────

func _criar_card_entrada(entrada: Dictionary, numero: int) -> PanelContainer:
	var correto: bool = entrada["correto"]
	var metodo:  String = entrada.get("metodo", "?")

	var bg_cor  := Color(0.10, 0.26, 0.14) if correto else Color(0.26, 0.10, 0.10)
	var borda   := Color(0.18, 0.42, 0.22) if correto else Color(0.42, 0.18, 0.18)
	var cor_num := Color(0.35, 0.95, 0.55) if correto else Color(0.95, 0.40, 0.40)
	var icone   := "✅" if correto else "❌"

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color    = bg_cor
	style.border_color = borda
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left   = 18
	style.content_margin_right  = 18
	style.content_margin_top    = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	panel.add_child(hbox)

	# Número + ícone
	var col_esq := VBoxContainer.new()
	col_esq.add_theme_constant_override("separation", 2)
	col_esq.custom_minimum_size = Vector2(40, 0)
	hbox.add_child(col_esq)

	var lbl_num := _label("#%d" % numero, 13, Color(0.55, 0.55, 0.70))
	lbl_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_esq.add_child(lbl_num)

	var lbl_icone := _label(icone, 22, Color.WHITE)
	lbl_icone.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_esq.add_child(lbl_icone)

	# Separador visual
	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(2, 0)
	sep.color = borda
	sep.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(sep)

	# Conteúdo central
	var col_mid := VBoxContainer.new()
	col_mid.add_theme_constant_override("separation", 5)
	col_mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(col_mid)

	# Sessão + método badge
	var hbox_tag := HBoxContainer.new()
	hbox_tag.add_theme_constant_override("separation", 8)
	col_mid.add_child(hbox_tag)

	var badge_sessao := _badge("Sessão %d" % entrada.get("sessao", 0), Color(0.20, 0.20, 0.38), Color(0.65, 0.65, 0.90))
	hbox_tag.add_child(badge_sessao)

	var cor_metodo := Color(0.8, 0.6, 1.0) if metodo == "A" else Color(0.4, 0.9, 0.9)
	var bg_metodo  := Color(0.20, 0.14, 0.36) if metodo == "A" else Color(0.10, 0.24, 0.26)
	var badge_met  := _badge("Método %s" % metodo, bg_metodo, cor_metodo)
	hbox_tag.add_child(badge_met)

	if entrada.get("usou_dica", false):
		hbox_tag.add_child(_badge("💡 dica", Color(0.22, 0.18, 0.06), Color(1.0, 0.85, 0.3)))

	# Enunciado resumido
	var enunciado_txt: String = entrada.get("enunciado", "")
	if enunciado_txt != "":
		var lbl_enunciado := _label(enunciado_txt, 14, Color(0.75, 0.75, 0.88))
		lbl_enunciado.autowrap_mode = TextServer.AUTOWRAP_WORD
		col_mid.add_child(lbl_enunciado)

	# Resposta dada vs correta
	var cor_resp := Color(0.35, 0.95, 0.55) if correto else Color(0.95, 0.40, 0.40)
	var txt_resp: String
	if correto:
		txt_resp = "R$ %.2f  ✓" % entrada.get("resposta_correta", 0.0)
	else:
		txt_resp = "Sua resposta: R$ %.2f   →   Correto: R$ %.2f" % [
			entrada.get("resposta_dada", 0.0),
			entrada.get("resposta_correta", 0.0)
		]
	var lbl_resp := _label(txt_resp, 15, cor_resp)
	lbl_resp.autowrap_mode = TextServer.AUTOWRAP_WORD
	col_mid.add_child(lbl_resp)

	# Animação de entrada com delay por índice
	panel.modulate.a = 0.0
	return panel


# ── Badge pequeno ─────────────────────────────────────────────────

func _badge(texto: String, bg: Color, cor_texto: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color    = bg
	s.border_color = bg.lightened(0.15)
	s.set_border_width_all(1)
	s.set_corner_radius_all(6)
	s.content_margin_left   = 8
	s.content_margin_right  = 8
	s.content_margin_top    = 3
	s.content_margin_bottom = 3
	p.add_theme_stylebox_override("panel", s)
	var l := _label(texto, 13, cor_texto)
	p.add_child(l)
	return p


# ── Animações ─────────────────────────────────────────────────────

func _fade_in_tela(elementos: Array) -> void:
	var tg := create_tween()
	tg.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tg.tween_property(self, "modulate:a", 1.0, 0.30)

	for i in elementos.size():
		var el: Control = elementos[i]
		el.modulate.a  = 0.0
		el.position.y += 16
		await get_tree().create_timer(0.06 + i * 0.08).timeout
		var t := create_tween()
		t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		t.tween_property(el, "modulate:a", 1.0, 0.28)
		t.parallel().tween_property(el, "position:y", el.position.y - 16, 0.28)

	# Cards da lista entram em cascata separada
	await get_tree().create_timer(0.35).timeout
	var scroll := elementos[2] as ScrollContainer
	if scroll == null:
		return
	var lista := scroll.get_child(0) as VBoxContainer
	if lista == null:
		return
	for i in lista.get_child_count():
		var card := lista.get_child(i) as Control
		if card == null:
			continue
		card.position.x -= 20
		await get_tree().create_timer(i * 0.06).timeout
		var t := create_tween()
		t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		t.tween_property(card, "modulate:a", 1.0, 0.25)
		t.parallel().tween_property(card, "position:x", card.position.x + 20, 0.25)


func _sair_para(callback: Callable) -> void:
	var t := create_tween()
	t.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "modulate:a", 0.0, 0.20)
	await t.finished
	callback.call()


# ── Botão com hover ───────────────────────────────────────────────

func _criar_botao(texto: String, bg: Color, cor_texto: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 58)

	var style := StyleBoxFlat.new()
	style.bg_color     = bg
	style.border_color = bg.lightened(0.15)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left   = 28
	style.content_margin_right  = 28
	style.content_margin_top    = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)

	var lbl := _label(texto, 19, cor_texto)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(lbl)

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
	panel.set_meta("btn", btn)
	return panel


func _conectar_btn(panel: PanelContainer, callback: Callable) -> void:
	(panel.get_meta("btn") as Button).pressed.connect(callback)


# ── Símbolos decorativos ──────────────────────────────────────────

func _adicionar_simbolos() -> void:
	var simbolos := [
		["%",   0.04, 0.08, 46, 0.07],
		["×",   0.90, 0.12, 40, 0.06],
		["÷",   0.06, 0.78, 42, 0.06],
		["+",   0.87, 0.72, 44, 0.06],
	]
	for s in simbolos:
		var lbl := Label.new()
		lbl.text = s[0]
		lbl.add_theme_font_override("font", FONTE)
		lbl.add_theme_font_size_override("font_size", int(s[3]))
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, float(s[4])))
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
