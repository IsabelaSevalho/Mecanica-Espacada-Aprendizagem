extends Control

const FONTE := preload("res://Fonte/FredokaOne-Regular.ttf")

var exercicio  := {}
var usou_dica  := false
var _input_ref: LineEdit   = null
var _erro_ref:  Label      = null

func _ready() -> void:
	anchor_right  = 1.0
	anchor_bottom = 1.0
	modulate.a   = 0.0

	var sessao   := GameManager.get_sessao_atual()
	exercicio     = GameManager.get_exercicio(GameManager.metodo_atual, sessao["intencao"])

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

	# ── Tag do método ─────────────────────────────────────────────
	var cor_tag := Color(0.8, 0.6, 1.0) if GameManager.metodo_atual == "A" else Color(0.4, 0.9, 0.9)
	var tag := _label(
		"Método %s  —  Sessão %d  —  %s" % [
			GameManager.metodo_atual,
			GameManager.sessao_atual_id,
			_nome_metodo(GameManager.metodo_atual)
		], 16, cor_tag
	)
	vbox.add_child(tag)
	elementos.append(tag)

	# ── Enunciado ─────────────────────────────────────────────────
	var enunciado := _label(exercicio.get("enunciado", ""), 26, Color.WHITE)
	enunciado.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(enunciado)
	elementos.append(enunciado)

	# ── Campo de resposta ─────────────────────────────────────────
	var input := LineEdit.new()
	input.placeholder_text = "Digite sua resposta (ex: 15.00)"
	input.add_theme_font_override("font", FONTE)
	input.add_theme_font_size_override("font_size", 22)
	input.custom_minimum_size = Vector2(0, 54)
	vbox.add_child(input)
	elementos.append(input)
	_input_ref = input

	# Enter também confirma
	input.text_submitted.connect(func(_t): _ao_confirmar())

	# ── Label de erro/dica ────────────────────────────────────────
	var label_erro := _label("", 15, Color(1.0, 0.4, 0.4))
	label_erro.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(label_erro)
	_erro_ref = label_erro

	# ── Botão dica ────────────────────────────────────────────────
	var sessao_intencao: String = sessao["intencao"]
	if sessao_intencao == "apoio" and exercicio.get("dica", "") != "":
		var btn_dica := _criar_botao("💡 Ver dica", Color(0.18, 0.16, 0.10), Color(1.0, 0.85, 0.3))
		_conectar_btn(btn_dica, func():
			usou_dica = true
			label_erro.text = exercicio["dica"]
			label_erro.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			_animar_entrada_label(label_erro)
		)
		vbox.add_child(btn_dica)
		elementos.append(btn_dica)

	# ── Botão confirmar ───────────────────────────────────────────
	var btn := _criar_botao("CONFIRMAR", Color(0.22, 0.15, 0.45), Color(0.85, 0.72, 1.0))
	_conectar_btn(btn, func(): _ao_confirmar())
	vbox.add_child(btn)
	elementos.append(btn)

	# ── Fade-in cascata ───────────────────────────────────────────
	await get_tree().process_frame
	_fade_in_tela(elementos)
	# Foca o input após animação
	await get_tree().create_timer(0.45).timeout
	input.grab_focus()


# ── Input global: Tab confirma ────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			get_viewport().set_input_as_handled()
			_ao_confirmar()


# ── Lógica de confirmação ─────────────────────────────────────────

func _ao_confirmar() -> void:
	if _input_ref == null or _erro_ref == null:
		return
	var texto: String = _input_ref.text.strip_edges().replace(",", ".")
	if not texto.is_valid_float():
		_erro_ref.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		_erro_ref.text = "⚠ Digite apenas números (ex: 15.00)"
		_animar_shake(_erro_ref)
		return

	var resposta_dada:    float = float(texto)
	var resposta_correta: float = exercicio.get("resposta", 0.0)
	var correto: bool = abs(resposta_dada - resposta_correta) < 0.01

	GameManager.registrar_resposta(exercicio, resposta_dada, correto, usou_dica)
	GameManager.ultimo_resultado = {
		"correto":          correto,
		"resposta_dada":    resposta_dada,
		"resposta_correta": resposta_correta,
		"enunciado":        exercicio.get("enunciado", ""),
		"metodo":           GameManager.metodo_atual,
		"dica":             exercicio.get("dica", ""),
		"usou_dica":        usou_dica
	}

	_sair_para(func():
		get_tree().change_scene_to_file("res://scenes/Feedback.tscn")
	)


# ── Animações ─────────────────────────────────────────────────────

func _fade_in_tela(elementos: Array) -> void:
	var tg := create_tween()
	tg.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tg.tween_property(self, "modulate:a", 1.0, 0.30)

	for i in elementos.size():
		var el: Control = elementos[i]
		el.modulate.a   = 0.0
		el.position.y  += 16
		await get_tree().create_timer(0.07 + i * 0.07).timeout
		var t := create_tween()
		t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		t.tween_property(el, "modulate:a", 1.0, 0.28)
		t.parallel().tween_property(el, "position:y", el.position.y - 16, 0.28)


func _animar_entrada_label(lbl: Label) -> void:
	lbl.modulate.a  = 0.0
	lbl.position.x -= 10
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(lbl, "modulate:a", 1.0, 0.25)
	t.parallel().tween_property(lbl, "position:x", lbl.position.x + 10, 0.25)


func _animar_shake(node: Control) -> void:
	var ox := node.position.x
	for _i in 4:
		var t := create_tween()
		t.tween_property(node, "position:x", ox + 6, 0.05)
		await t.finished
		t = create_tween()
		t.tween_property(node, "position:x", ox - 6, 0.05)
		await t.finished
	node.position.x = ox


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


# ── Símbolos decorativos ──────────────────────────────────────────

func _adicionar_simbolos() -> void:
	var simbolos := [
		["%",   0.04, 0.08, 46, 0.08],
		["×",   0.90, 0.12, 40, 0.07],
		["÷",   0.06, 0.78, 42, 0.07],
		["+",   0.87, 0.72, 44, 0.06],
		["−",   0.50, 0.92, 38, 0.06],
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


func _nome_metodo(m: String) -> String:
	return "Coeficiente Decimal" if m == "A" else "Decomposição"
