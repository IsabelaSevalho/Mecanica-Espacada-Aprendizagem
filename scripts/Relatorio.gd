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

	# ── Scroll cobre tela toda ────────────────────────────────────
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top",    45)
	margin.add_theme_constant_override("margin_left",   28)
	margin.add_theme_constant_override("margin_right",  28)
	margin.add_theme_constant_override("margin_bottom", 40)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)

	var elementos: Array = []

	# ── Estatísticas ──────────────────────────────────────────────
	var total     := GameManager.historico.size()
	var acertos   := GameManager.historico.filter(func(h): return h["correto"]).size()
	var erros     := total - acertos
	var com_dica  := GameManager.historico.filter(func(h): return h["usou_dica"]).size()
	var pct       := int((float(acertos) / float(total)) * 100) if total > 0 else 0

	var acertos_A := GameManager.historico.filter(func(h): return h["correto"] and h["metodo"] == "A").size()
	var total_A   := GameManager.historico.filter(func(h): return h["metodo"] == "A").size()
	var acertos_B := GameManager.historico.filter(func(h): return h["correto"] and h["metodo"] == "B").size()
	var total_B   := GameManager.historico.filter(func(h): return h["metodo"] == "B").size()

	# ── Título + medalha ──────────────────────────────────────────
	var medalha := "🏆" if pct == 100 else ("🥈" if pct >= 70 else "📊")
	var titulo := _label("%s Relatório Final" % medalha, 36, Color.WHITE)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)
	elementos.append(titulo)

	_espaco(vbox, 6)

	var subtitulo := _label(_frase_desempenho(pct), 17, Color(0.65, 0.65, 0.80))
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitulo)
	elementos.append(subtitulo)

	_espaco(vbox, 30)

	# ── Cards de resumo (linha) ───────────────────────────────────
	var grid_resumo := GridContainer.new()
	grid_resumo.columns = 2
	grid_resumo.add_theme_constant_override("h_separation", 12)
	grid_resumo.add_theme_constant_override("v_separation", 12)
	grid_resumo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(grid_resumo)
	elementos.append(grid_resumo)

	grid_resumo.add_child(_card_stat("Total", str(total), "exercícios", Color(0.18, 0.18, 0.30), Color(0.75, 0.75, 1.0)))
	grid_resumo.add_child(_card_stat("Acertos", str(acertos), "%d%%" % pct, Color(0.10, 0.26, 0.14), Color(0.35, 0.95, 0.55)))
	grid_resumo.add_child(_card_stat("Erros", str(erros), "reagendados", Color(0.26, 0.10, 0.10), Color(0.95, 0.40, 0.40)))
	grid_resumo.add_child(_card_stat("Dicas", str(com_dica), "usadas", Color(0.22, 0.16, 0.04), Color(1.0, 0.85, 0.3)))

	_espaco(vbox, 24)

	# ── Barra de progresso ────────────────────────────────────────
	var lbl_barra := _label("Taxa de acerto geral", 15, Color(0.60, 0.60, 0.75))
	vbox.add_child(lbl_barra)
	elementos.append(lbl_barra)

	_espaco(vbox, 6)

	# Container da barra com clip para não vazar
	var barra_wrap := Control.new()
	barra_wrap.custom_minimum_size   = Vector2(0, 26)
	barra_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra_wrap.clip_contents         = true
	vbox.add_child(barra_wrap)
	elementos.append(barra_wrap)

	var barra_bg := ColorRect.new()
	barra_bg.color = Color(0.13, 0.13, 0.22)
	barra_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	barra_wrap.add_child(barra_bg)

	# Verde para >=70%, vinho escuro para abaixo
	var cor_barra := Color(0.20, 0.75, 0.35) if pct >= 70 else Color(0.55, 0.08, 0.15)

	var barra_fill := ColorRect.new()
	barra_fill.color         = cor_barra
	barra_fill.anchor_top    = 0.0
	barra_fill.anchor_bottom = 1.0
	barra_fill.anchor_left   = 0.0
	barra_fill.anchor_right  = 0.0
	barra_fill.offset_left   = 0.0
	barra_fill.offset_right  = 0.0
	barra_fill.offset_top    = 0.0
	barra_fill.offset_bottom = 0.0
	barra_wrap.add_child(barra_fill)

	var lbl_pct := _label("%d%%" % pct, 13, Color(1, 1, 1, 0.9))
	lbl_pct.position = Vector2(8, 4)
	barra_wrap.add_child(lbl_pct)

	# Anima a barra após o fade-in
	await get_tree().create_timer(0.55).timeout
	var tb := create_tween()
	tb.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tb.tween_property(barra_fill, "anchor_right", float(pct) / 100.0, 0.80)

	_espaco(vbox, 24)

	# ── Desempenho por método ─────────────────────────────────────
	var lbl_met := _label("Desempenho por método", 20, Color.WHITE)
	vbox.add_child(lbl_met)
	elementos.append(lbl_met)

	_espaco(vbox, 10)

	var hbox_met := HBoxContainer.new()
	hbox_met.add_theme_constant_override("separation", 12)
	hbox_met.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(hbox_met)
	elementos.append(hbox_met)

	hbox_met.add_child(_card_metodo("A", "Coeficiente Decimal", acertos_A, total_A, Color(0.20, 0.14, 0.36), Color(0.80, 0.60, 1.0)))
	hbox_met.add_child(_card_metodo("B", "Decomposição", acertos_B, total_B, Color(0.10, 0.22, 0.26), Color(0.40, 0.90, 0.90)))

	_espaco(vbox, 24)

	# ── Desempenho por sessão ─────────────────────────────────────
	var lbl_sess := _label("Desempenho por sessão", 20, Color.WHITE)
	vbox.add_child(lbl_sess)
	elementos.append(lbl_sess)

	_espaco(vbox, 10)

	var vbox_sess := VBoxContainer.new()
	vbox_sess.add_theme_constant_override("separation", 8)
	vbox_sess.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(vbox_sess)
	elementos.append(vbox_sess)

	for i in range(1, 7):
		var entradas := GameManager.historico.filter(func(h): return h["sessao"] == i)
		if entradas.is_empty():
			continue
		var ac := entradas.filter(func(h): return h["correto"]).size()
		vbox_sess.add_child(_card_sessao(i, ac, entradas.size()))

	_espaco(vbox, 24)

	# ── Histórico detalhado ───────────────────────────────────────
	var lbl_hist := _label("📋 Histórico detalhado", 20, Color.WHITE)
	vbox.add_child(lbl_hist)
	elementos.append(lbl_hist)

	_espaco(vbox, 10)

	var vbox_hist := VBoxContainer.new()
	vbox_hist.add_theme_constant_override("separation", 8)
	vbox_hist.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(vbox_hist)
	elementos.append(vbox_hist)

	for idx in GameManager.historico.size():
		var entrada: Dictionary = GameManager.historico[idx]
		vbox_hist.add_child(_card_entrada(entrada, idx + 1))

	_espaco(vbox, 28)

	# ── Botão jogar novamente ─────────────────────────────────────
	_btn_principal = _criar_botao("🔄  JOGAR NOVAMENTE", Color(0.22, 0.15, 0.45), Color(0.85, 0.72, 1.0))
	_conectar_btn(_btn_principal, func():
		_sair_para(func():
			GameManager.resetar_jogo()
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")
		)
	)
	vbox.add_child(_btn_principal)
	elementos.append(_btn_principal)

	# ── Fade-in cascata ───────────────────────────────────────────
	await get_tree().process_frame
	_fade_in_tela(elementos)


# ── Tab avança a tela ─────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		get_viewport().set_input_as_handled()
		(_btn_principal.get_meta("btn") as Button).emit_signal("pressed")


# ── Componentes visuais ───────────────────────────────────────────

func _card_stat(rotulo: String, valor: String, detalhe: String, bg: Color, cor: Color) -> PanelContainer:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s := StyleBoxFlat.new()
	s.bg_color    = bg
	s.border_color = bg.lightened(0.18)
	s.set_border_width_all(2)
	s.set_corner_radius_all(14)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	p.add_theme_stylebox_override("panel", s)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	p.add_child(v)

	var lv := _label(valor, 30, cor)
	lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(lv)

	var ll := _label(rotulo, 13, Color(0.65, 0.65, 0.80))
	ll.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(ll)

	var ld := _label(detalhe, 12, cor.darkened(0.2))
	ld.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(ld)

	return p


func _card_metodo(letra: String, nome: String, ac: int, total: int, bg: Color, cor: Color) -> PanelContainer:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s := StyleBoxFlat.new()
	s.bg_color    = bg
	s.border_color = bg.lightened(0.18)
	s.set_border_width_all(2)
	s.set_corner_radius_all(14)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 16
	s.content_margin_bottom = 16
	p.add_theme_stylebox_override("panel", s)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	p.add_child(v)

	var lt := _label("Método %s" % letra, 18, cor)
	lt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(lt)

	var ln := _label(nome, 13, Color(0.65, 0.65, 0.80))
	ln.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(ln)

	var pct_m := int((float(ac) / float(total)) * 100) if total > 0 else 0
	var lr := _label("%d/%d  (%d%%)" % [ac, total, pct_m], 20, cor)
	lr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(lr)

	return p


func _card_sessao(num: int, ac: int, total: int) -> PanelContainer:
	var completo := ac == total
	var bg  := Color(0.10, 0.26, 0.14) if completo else Color(0.16, 0.16, 0.26)
	var brd := Color(0.18, 0.42, 0.22) if completo else Color(0.24, 0.24, 0.38)
	var cor := Color(0.35, 0.95, 0.55) if completo else Color(0.75, 0.75, 0.90)

	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s := StyleBoxFlat.new()
	s.bg_color    = bg
	s.border_color = brd
	s.set_border_width_all(2)
	s.set_corner_radius_all(10)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	p.add_theme_stylebox_override("panel", s)

	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 12)
	p.add_child(hb)

	var icone := _label("✅" if completo else "🔸", 18, Color.WHITE)
	icone.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hb.add_child(icone)

	var lt := _label("Sessão %d" % num, 16, Color.WHITE)
	lt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lt.vertical_alignment    = VERTICAL_ALIGNMENT_CENTER
	hb.add_child(lt)

	var lr := _label("%d / %d acertos" % [ac, total], 16, cor)
	lr.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hb.add_child(lr)

	# mini barra
	var barra_bg := PanelContainer.new()
	barra_bg.custom_minimum_size = Vector2(80, 10)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.15, 0.15, 0.25)
	sb.set_corner_radius_all(5)
	barra_bg.add_theme_stylebox_override("panel", sb)
	barra_bg.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var fill := ColorRect.new()
	fill.color = cor
	fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	fill.anchor_right  = float(ac) / float(total)
	fill.anchor_bottom = 1.0
	barra_bg.add_child(fill)
	hb.add_child(barra_bg)

	return p


func _card_entrada(entrada: Dictionary, numero: int) -> PanelContainer:
	var correto: bool   = entrada["correto"]
	var metodo:  String = entrada.get("metodo", "?")

	var bg_cor := Color(0.10, 0.26, 0.14) if correto else Color(0.26, 0.10, 0.10)
	var borda  := Color(0.18, 0.42, 0.22) if correto else Color(0.42, 0.18, 0.18)
	var cor_v  := Color(0.35, 0.95, 0.55) if correto else Color(0.95, 0.40, 0.40)

	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s := StyleBoxFlat.new()
	s.bg_color    = bg_cor
	s.border_color = borda
	s.set_border_width_all(2)
	s.set_corner_radius_all(12)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	p.add_theme_stylebox_override("panel", s)

	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 14)
	p.add_child(hb)

	# Coluna esquerda
	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(38, 0)
	col.add_theme_constant_override("separation", 2)
	hb.add_child(col)

	var ln := _label("#%d" % numero, 12, Color(0.55, 0.55, 0.70))
	ln.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(ln)

	var li := _label("✅" if correto else "❌", 22, Color.WHITE)
	li.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(li)

	# Separador
	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(2, 0)
	sep.color = borda
	sep.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hb.add_child(sep)

	# Conteúdo
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 5)
	cv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(cv)

	# Badges
	var hbt := HBoxContainer.new()
	hbt.add_theme_constant_override("separation", 6)
	cv.add_child(hbt)

	hbt.add_child(_badge("Sessão %d" % entrada.get("sessao", 0), Color(0.20,0.20,0.38), Color(0.65,0.65,0.90)))
	var cm := Color(0.8,0.6,1.0) if metodo=="A" else Color(0.4,0.9,0.9)
	var bm := Color(0.20,0.14,0.36) if metodo=="A" else Color(0.10,0.24,0.26)
	hbt.add_child(_badge("Método %s" % metodo, bm, cm))
	if entrada.get("usou_dica", false):
		hbt.add_child(_badge("💡 dica", Color(0.22,0.18,0.06), Color(1.0,0.85,0.3)))

	if entrada.get("enunciado","") != "":
		var le := _label(entrada["enunciado"], 13, Color(0.72,0.72,0.88))
		le.autowrap_mode = TextServer.AUTOWRAP_WORD
		cv.add_child(le)

	var txt_r: String
	if correto:
		txt_r = "R$ %.2f  ✓" % entrada.get("resposta_correta", 0.0)
	else:
		txt_r = "Sua resposta: R$ %.2f   →   Correto: R$ %.2f" % [
			entrada.get("resposta_dada", 0.0), entrada.get("resposta_correta", 0.0)]
	var lr := _label(txt_r, 14, cor_v)
	lr.autowrap_mode = TextServer.AUTOWRAP_WORD
	cv.add_child(lr)

	return p


func _badge(texto: String, bg: Color, cor_texto: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color    = bg
	s.border_color = bg.lightened(0.15)
	s.set_border_width_all(1)
	s.set_corner_radius_all(6)
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 3
	s.content_margin_bottom = 3
	p.add_theme_stylebox_override("panel", s)
	p.add_child(_label(texto, 12, cor_texto))
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
		await get_tree().create_timer(0.06 + i * 0.07).timeout
		var t := create_tween()
		t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		t.tween_property(el, "modulate:a", 1.0, 0.26)
		t.parallel().tween_property(el, "position:y", el.position.y - 16, 0.26)


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
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 14
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
		["%",   0.04, 0.08, 48, 0.08],
		["×",   0.91, 0.14, 42, 0.07],
		["÷",   0.06, 0.76, 44, 0.07],
		["+",   0.86, 0.70, 46, 0.06],
		["5/7", 0.87, 0.88, 34, 0.05],
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


func _frase_desempenho(pct: int) -> String:
	if pct == 100: return "Perfeito! Você acertou tudo! 🎉"
	if pct >= 80:  return "Excelente desempenho! Quase lá!"
	if pct >= 60:  return "Bom trabalho! Continue praticando."
	if pct >= 40:  return "Você está progredindo. Tente novamente!"
	return "Continue tentando, a prática leva à perfeição."
