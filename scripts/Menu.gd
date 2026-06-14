extends Control

const FONTE := preload("res://Fonte/FredokaOne-Regular.ttf")

# referências para animação
var _cards: Array = []
var _card_base_y: Array = []

func _ready() -> void:
	anchor_right  = 1.0
	anchor_bottom = 1.0

	# ── Fundo ─────────────────────────────────────────────────────
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.09, 0.09, 0.15)
	add_child(bg)

	# ── Símbolos matemáticos decorativos no fundo ─────────────────
	_adicionar_simbolos()

	# ── Container central ─────────────────────────────────────────
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top",    50)
	margin.add_theme_constant_override("margin_bottom", 40)
	margin.add_theme_constant_override("margin_left",   28)
	margin.add_theme_constant_override("margin_right",  28)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	# ── Título ────────────────────────────────────────────────────
	var titulo1 := _label("Porcentagem", 44, Color.WHITE)
	titulo1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo1)

	var titulo2 := _label("na Prática", 44, Color(0.72, 0.55, 1.0))
	titulo2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo2)

	_espaco(vbox, 18)

	var subtitulo := _label(
		"Aprenda dois métodos para calcular porcentagem\nsem usar regra de três.",
		17, Color(0.72, 0.72, 0.82)
	)
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(subtitulo)

	_espaco(vbox, 50)

	# ── Cards ─────────────────────────────────────────────────────
	var _card_real := _criar_card(
		Color(0.22, 0.15, 0.45),
		Color(0.28, 0.20, 0.55),
		"📅",
		"Modo Real",
		Color(0.85, 0.72, 1.0),
		"Sessões liberadas dia a dia,\ncomo um app de estudos.",
		func():
			GameManager.modo_demonstracao = false
			GameManager.carregar_estado()
			GameManager.iniciar_jogo()
			ir_para_sessao()
	)
	vbox.add_child(_card_real)
	_cards.append(_card_real)

	_espaco(vbox, 16)

	var _card_demo := _criar_card(
		Color(0.10, 0.28, 0.20),
		Color(0.14, 0.36, 0.26),
		"⚡",
		"Modo Demonstração",
		Color(0.35, 0.95, 0.60),
		"Todas as sessões liberadas.\nIdeal para apresentar o projeto.",
		func():
			GameManager.modo_demonstracao = true
			GameManager.sessao_atual_id    = 1
			GameManager.metodo_atual       = "A"
			GameManager.historico          = []
			GameManager.erros_agendados    = []
			ir_para_sessao()
	)
	vbox.add_child(_card_demo)
	_cards.append(_card_demo)

	_espaco(vbox, 40)

	# ── Rodapé ────────────────────────────────────────────────────
	var rodape := _label(
		"6 sessões  •  2 métodos  •  Espaçamento progressivo",
		13, Color(0.50, 0.50, 0.62)
	)
	rodape.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(rodape)

	_espaco(vbox, 6)

	var creditos := _label("abado & ics @ 2026", 12, Color(0.40, 0.40, 0.52))
	creditos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(creditos)

	# Salva Y base dos cards após o layout ser construído
	await get_tree().process_frame
	for c in _cards:
		_card_base_y.append(c.position.y)


# ── Navegação ─────────────────────────────────────────────────────

func ir_para_sessao() -> void:
	get_tree().change_scene_to_file("res://scenes/Sessao.tscn")


# ── Símbolos decorativos ──────────────────────────────────────────

func _adicionar_simbolos() -> void:
	# [ texto, x_frac, y_frac, tamanho, opacidade ]
	var simbolos := [
		["5/7", 0.05, 0.12, 52, 0.10],
		["%",   0.88, 0.08, 58, 0.10],
		["×",   0.92, 0.55, 44, 0.09],
		["÷",   0.06, 0.72, 46, 0.09],
		["+",   0.78, 0.80, 50, 0.08],
		["−",   0.14, 0.42, 48, 0.08],
		["0",   0.82, 0.30, 54, 0.07],
		["%",   0.03, 0.88, 38, 0.07],
		["×",   0.50, 0.93, 36, 0.06],
	]

	for s in simbolos:
		var lbl := Label.new()
		lbl.text         = s[0]
		lbl.add_theme_font_override("font", FONTE)
		lbl.add_theme_font_size_override("font_size", int(s[3]))
		lbl.add_theme_color_override(
			"font_color", Color(1.0, 1.0, 1.0, float(s[4]))
		)
		lbl.set_anchors_preset(Control.PRESET_TOP_LEFT)
		add_child(lbl)

		# posiciona após o primeiro frame para ter o tamanho da tela
		var xf: float = s[1]
		var yf: float = s[2]
		lbl.resized.connect(func(): pass)   # força cálculo de size
		await get_tree().process_frame
		lbl.position = Vector2(
			get_viewport_rect().size.x * xf,
			get_viewport_rect().size.y * yf
		)

		# animação suave de flutuação contínua
		_float_loop(lbl, randf_range(0.0, 6.28))


func _float_loop(node: Control, _phase_offset: float) -> void:
	var origem := node.position
	var amplitude := randf_range(6.0, 14.0)
	var periodo   := randf_range(3.0, 5.5)

	while is_instance_valid(node):
		var t := create_tween()
		t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		t.tween_property(node, "position:y",
			origem.y - amplitude, periodo * 0.5)
		await t.finished

		t = create_tween()
		t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		t.tween_property(node, "position:y",
			origem.y, periodo * 0.5)
		await t.finished


# ── Card ──────────────────────────────────────────────────────────

func _criar_card(
	bg_color:    Color,
	border_color: Color,
	emoji:       String,
	titulo:      String,
	titulo_cor:  Color,
	descricao:   String,
	callback:    Callable
) -> PanelContainer:

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 90)

	var style := StyleBoxFlat.new()
	style.bg_color    = bg_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left   = 20
	style.content_margin_right  = 20
	style.content_margin_top    = 18
	style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	panel.add_child(hbox)

	# Ícone emoji
	var icone := Label.new()
	icone.text = emoji
	icone.add_theme_font_size_override("font_size", 34)
	icone.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icone)

	# Textos
	var text_vbox := VBoxContainer.new()
	text_vbox.add_theme_constant_override("separation", 4)
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_vbox)

	var lbl_titulo := _label(titulo, 20, titulo_cor)
	text_vbox.add_child(lbl_titulo)

	var lbl_desc := _label(descricao, 15, Color(0.82, 0.82, 0.92))
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_vbox.add_child(lbl_desc)

	# Seta
	var seta := _label("▶", 18, Color(0.70, 0.70, 0.85))
	seta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(seta)

	# Botão invisível cobre o card inteiro
	var btn := Button.new()
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.flat = true
	var vazio := StyleBoxEmpty.new()
	for estado in ["normal", "hover", "pressed", "focus"]:
		btn.add_theme_stylebox_override(estado, vazio)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pressed.connect(callback)

	# ── Animações hover ───────────────────────────────────────────
	btn.mouse_entered.connect(func():
		_hover_enter(panel, style, bg_color, border_color, seta)
	)
	btn.mouse_exited.connect(func():
		_hover_exit(panel, style, bg_color, border_color, seta)
	)

	panel.add_child(btn)
	return panel


func _hover_enter(
	panel: PanelContainer,
	style: StyleBoxFlat,
	bg_orig: Color,
	bd_orig: Color,
	seta: Label
) -> void:
	# Sobe o card
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(panel, "position:y", panel.position.y - 6, 0.18)

	# Clareia o fundo e a borda
	var ts := create_tween()
	ts.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	ts.tween_method(func(v: Color): style.bg_color = v,
		style.bg_color, bg_orig.lightened(0.12), 0.18)

	var tb := create_tween()
	tb.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tb.tween_method(func(v: Color): style.border_color = v,
		style.border_color, bd_orig.lightened(0.25), 0.18)

	# Seta avança
	var ta := create_tween()
	ta.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	ta.tween_property(seta, "position:x", seta.position.x + 5, 0.18)


func _hover_exit(
	panel: PanelContainer,
	style: StyleBoxFlat,
	bg_orig: Color,
	bd_orig: Color,
	seta: Label
) -> void:
	# Desce o card de volta
	var t := create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(panel, "position:y", panel.position.y + 6, 0.22)

	# Restaura cores
	var ts := create_tween()
	ts.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	ts.tween_method(func(v: Color): style.bg_color = v,
		style.bg_color, bg_orig, 0.22)

	var tb := create_tween()
	tb.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tb.tween_method(func(v: Color): style.border_color = v,
		style.border_color, bd_orig, 0.22)

	# Seta volta
	var ta := create_tween()
	ta.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	ta.tween_property(seta, "position:x", seta.position.x - 5, 0.22)


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
