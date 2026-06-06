extends Control

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var r := GameManager.ultimo_resultado
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
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	# Resultado
	var label_resultado := Label.new()
	label_resultado.add_theme_font_size_override("font_size", 28)
	label_resultado.autowrap_mode = TextServer.AUTOWRAP_WORD
	if r["correto"]:
		label_resultado.text = "✅ Correto! Muito bem!"
		label_resultado.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	else:
		label_resultado.text = "❌ Não foi dessa vez."
		label_resultado.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	vbox.add_child(label_resultado)

	# Detalhes
	var label_detalhe := Label.new()
	label_detalhe.add_theme_font_size_override("font_size", 18)
	label_detalhe.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	label_detalhe.autowrap_mode = TextServer.AUTOWRAP_WORD
	if r["correto"]:
		label_detalhe.text = "Resposta: R$ %.2f" % r["resposta_correta"]
		if r["usou_dica"]:
			label_detalhe.text += "\n💡 Você usou a dica desta vez."
	else:
		label_detalhe.text = "Você respondeu: R$ %.2f\nResposta correta: R$ %.2f" % [
			r["resposta_dada"], r["resposta_correta"]
		]
		if r["metodo"] == "A":
			label_detalhe.text += "\n\n📐 Método A: divida % por 100, depois multiplique pelo valor.\nEx: 25% de R$80 → 0,25 × 80 = R$20"
		else:
			label_detalhe.text += "\n\n📐 Método B: decomponha em partes de 10% e some.\nEx: 25% de R$80 → 10%+10%+5% = 8+8+4 = R$20"
	vbox.add_child(label_detalhe)

	# Aviso se erro foi agendado
	if not r["correto"]:
		var label_aviso := Label.new()
		label_aviso.text = "📅 Este exercício vai aparecer novamente na próxima sessão."
		label_aviso.add_theme_font_size_override("font_size", 15)
		label_aviso.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		label_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(label_aviso)

	var espacador := Control.new()
	espacador.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(espacador)

	# Botões de navegação
	var metodo_atual: String = r["metodo"]
	var proxima_acao := _proxima_acao(sessao, metodo_atual)

	var btn := Button.new()
	btn.text = proxima_acao["label"]
	btn.custom_minimum_size = Vector2(0, 55)
	btn.add_theme_font_size_override("font_size", 20)
	btn.pressed.connect(func():
		GameManager.alternar_metodo()
		get_tree().change_scene_to_file(proxima_acao["cena"])
	)
	vbox.add_child(btn)

	var btn_historico := Button.new()
	btn_historico.text = "📊 Ver histórico"
	btn_historico.custom_minimum_size = Vector2(0, 44)
	btn_historico.add_theme_font_size_override("font_size", 16)
	btn_historico.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Historico.tscn")
	)
	vbox.add_child(btn_historico)

func _proxima_acao(sessao: Dictionary, metodo_atual: String) -> Dictionary:
	var exercicios: Array = sessao["exercicios"]

	# Se ainda tem o outro método para fazer nessa sessão
	if metodo_atual == "A" and "B" in exercicios:
		return {"label": "PRÓXIMO EXERCÍCIO (Método B) ▶", "cena": "res://scenes/Desafio.tscn"}

	# Terminou os dois métodos da sessão
	var proxima_sessao := GameManager.sessao_atual_id + 1
	if proxima_sessao <= 6:
		return {"label": "PRÓXIMA SESSÃO ▶", "cena": _proxima_cena(proxima_sessao)}
	else:
		return {"label": "VER RELATÓRIO FINAL 🏁", "cena": "res://scenes/Relatorio.tscn"}

func _proxima_cena(sessao_id: int) -> String:
	GameManager.sessao_atual_id = sessao_id
	return "res://scenes/Sessao.tscn"
