extends Control

var _btn_principal: PanelContainer = null

const FONTE := preload("res://Fonte/FredokaOne-Regular.ttf")

func _ready() -> void:
	anchor_right  = 1.0
	anchor_bottom = 1.0
	modulate.a   = 0.0

	var r      := GameManager.ultimo_resultado
	var sessao := GameManager.get_sessao_atual()

	# ── Fundo ─────────────────────────────────────────────────────
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.09, 0.09, 0.15)
	add_child(bg)

	_adicionar_simbolos()

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top",    70)
	margin.add_theme_constant_override("margin_left",   80)
	margin.add_theme_constant_override("margin_right",  80)
	margin.add_theme_constant_override("margin_bottom", 60)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	var elementos: Array = []

	# ── Resultado ─────────────────────────────────────────────────
	var cor_resultado := Color(0.4, 0.9, 0.4) if r["correto"] else Color(1.0, 0.4, 0.4)
	var txt_resultado := "✅ Correto! Muito bem!" if r["correto"] else "❌ Não foi dessa vez."
	var label_resultado := _label(txt_resultado, 30, cor_resultado)
	label_resultado.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(label_resultado)
	elementos.append(label_resultado)

	# ── Detalhes ──────────────────────────────────────────────────
	var txt_detalhe: String
	if r["correto"]:
		txt_detalhe = "Resposta: R$ %.2f" % r["resposta_correta"]
		if r["usou_dica"]:
			txt_detalhe += "\n💡 Você usou a dica desta vez."
	else:
		txt_detalhe = "Você respondeu: R$ %.2f\nResposta correta: R$ %.2f" % [
			r["resposta_dada"], r["resposta_correta"]
		]
		if r["metodo"] == "A":
			txt_detalhe += "\n\n📐 Método A: divida % por 100, depois multiplique pelo valor.\nEx: 25% de R$80 → 0,25 × 80 = R$20"
		else:
			txt_detalhe += "\n\n📐 Método B: decomponha em partes de 10% e some.\nEx: 25% de R$80 → 10%+10%+5% = 8+8+4 = R$20"

	var label_detalhe := _label(txt_detalhe, 18, Color(0.85, 0.85, 0.85))
	label_detalhe.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(label_detalhe)
	elementos.append(label_detalhe)

	# ── Aviso de reagendamento ────────────────────────────────────
	if not r["correto"]:
		var label_aviso := _label(
			"📅 Este exercício vai aparecer novamente na próxima sessão.",
			15, Color(1.0, 0.85, 0.3)
		)
		label_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(label_aviso)
		elementos.append(label_aviso)

	_espaco(vbox, 10)

	# ── Botão próxima ação ────────────────────────────────────────
	var proxima_acao := _proxima_acao(sessao, r["metodo"])

	_btn_principal = _criar_botao(proxima_acao["label"], Color(0.22, 0.15, 0.45), Color(0.85, 0.72, 1.0))
	_conectar_btn(_btn_principal, func():
		_sair_para(func():
			GameManager.alternar_metodo()
			get_tree().change_scene_to_file(proxima_acao["cena"])
		)
	)
	vbox.add_child(_btn_principal)
	elementos.append(_btn_principal)

	var btn_hist := _criar_botao("📊 Ver histórico", Color(0.10, 0.14, 0.22), Color(0.55, 0.75, 1.0))
	_conectar_btn(btn_hist, func():
		_sair_para(func():
			get_tree().change_scene_to_file("res://scenes/Historico.tscn")
		)
	)
	vbox.add_child(btn_hist)
	elementos.append(btn_hist)

	# ── Fade-in cascata ───────────────────────────────────────────
	await get_tree().process_frame
	_fade_in_tela(elementos)


# ── Tab avança a tela ─────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		get_viewport().set_input_as_handled()
		(_btn_principal.get_meta("btn") as Button).emit_signal("pressed")


# ── Animações ─────────────────────────────────────────────────────

func _fade_in_tela(elementos: Array) -> void:
	var tg := create_tween()
	tg.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tg.tween_property(self, "modulate:a", 1.0, 0.30)

	for i in elementos.size():
		var el: Control = elementos[i]
		el.modulate.a   = 0.0
		el.position.y  += 16
		await get_tree().create_timer(0.07 + i * 0.08).timeout
		var t := create_tween()
		t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		t.tween_property(el, "modulate:a", 1.0, 0.28)
		t.parallel().tween_property(el, "position:y", el.position.y - 16, 0.28)


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
	var btn := panel.get_meta("btn") as Button
	btn.pressed.connect(callback)


# ── Navegação ─────────────────────────────────────────────────────

func _proxima_acao(sessao: Dictionary, metodo_atual: String) -> Dictionary:
	var exercicios: Array = sessao["exercicios"]
	if metodo_atual == "A" and "B" in exercicios:
		return {"label": "PRÓXIMO EXERCÍCIO (Método B) ▶", "cena": "res://scenes/Desafio.tscn"}
	var proxima_sessao := GameManager.sessao_atual_id + 1
	if proxima_sessao <= 6:
		return {"label": "PRÓXIMA SESSÃO ▶", "cena": _proxima_cena(proxima_sessao)}
	else:
		return {"label": "VER RELATÓRIO FINAL 🏁", "cena": "res://scenes/Relatorio.tscn"}


func _proxima_cena(sessao_id: int) -> String:
	GameManager.sessao_atual_id = sessao_id
	return "res://scenes/Sessao.tscn"


# ── Símbolos decorativos ──────────────────────────────────────────

func _adicionar_simbolos() -> void:
	var simbolos := [
		["%",   0.04, 0.08, 46, 0.08],
		["×",   0.90, 0.12, 40, 0.07],
		["÷",   0.06, 0.78, 42, 0.07],
		["+",   0.87, 0.72, 44, 0.06],
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
